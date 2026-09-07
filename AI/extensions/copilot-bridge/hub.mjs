// copilot-bridge hub: a detached, zero-dependency WebSocket server that bridges
// Copilot CLI sessions. The port is the lock -- whoever binds it first is the hub;
// a loser exits on EADDRINUSE. The hub self-terminates once no peers remain.
//
// Wire protocol: JSON text frames, envelope { type, role?, sessionId?, requestId?, data? }.
// See CLIENT.md for the full specification.
//
// Trust model: loopback-only, no auth. Even so, the hub validates roles, the
// handshake, and every frame it decodes so a misbehaving peer cannot corrupt
// routing, escalate its role, or exhaust memory.

import http from "node:http";
import crypto from "node:crypto";

const HOST = "127.0.0.1";
const PORT = 47823;
const WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

const HEARTBEAT_MS = 15_000;
const GRACE_MS = 30_000;
const PERMISSION_TIMEOUT_MS = Number(process.env.COPILOT_BRIDGE_PERMISSION_TIMEOUT_MS ?? 60_000);

// Resource ceilings. Loopback traffic is small; these only exist to bound a buggy
// or hostile peer.
const MAX_FRAME_BYTES = 1 << 20; // 1 MiB per frame
const MAX_MESSAGE_BYTES = 1 << 20; // 1 MiB reassembled
const MAX_BUFFER_BYTES = 4 << 20; // 4 MiB unparsed inbound backlog
const MAX_WRITE_BACKLOG_BYTES = 8 << 20; // drop a client that will not drain

const peers = new Set(); // all live Peer objects
let graceTimer = null;

class Peer {
    constructor(socket) {
        this.socket = socket;
        this.role = null; // "session" | "client"
        this.sessionId = null;
        this.meta = {};
        this.helloReceived = false;
        this.alive = true;
        this.buffer = Buffer.alloc(0);
        this.fragmenting = false; // inside a fragmented message
        this.fragmentOpcode = 0;
        this.fragments = [];
        this.fragmentBytes = 0;
        this.fatal = null; // protocol violation -> connection must close
    }

    send(obj) {
        try {
            if (this.socket.writableLength > MAX_WRITE_BACKLOG_BYTES) {
                this.fatal = "write backlog exceeded";
                closePeer(this);
                return;
            }
            this.socket.write(encodeFrame(0x1, Buffer.from(JSON.stringify(obj))));
        } catch {
            /* peer went away; close handler will clean up */
        }
    }

    close() {
        const socket = this.socket;
        try {
            socket.end(encodeFrame(0x8, Buffer.alloc(0))); // flush a close frame, then FIN
        } catch {
            /* ignore */
        }
        const t = setTimeout(() => {
            try {
                socket.destroy();
            } catch {
                /* ignore */
            }
        }, 200);
        t.unref?.();
    }
}

function acceptKey(key) {
    return crypto
        .createHash("sha1")
        .update(key + WS_GUID)
        .digest("base64");
}

// Server frames are never masked.
function encodeFrame(opcode, payload) {
    const len = payload.length;
    let header;
    if (len < 126) {
        header = Buffer.alloc(2);
        header[1] = len;
    } else if (len < 65536) {
        header = Buffer.alloc(4);
        header[1] = 126;
        header.writeUInt16BE(len, 2);
    } else {
        header = Buffer.alloc(10);
        header[1] = 127;
        header.writeBigUInt64BE(BigInt(len), 2);
    }
    header[0] = 0x80 | opcode; // FIN + opcode
    return Buffer.concat([header, payload]);
}

// Decode as many complete frames as are buffered. Enforces RFC 6455 framing rules
// (client masking, RSV clear, control-frame constraints, fragmentation ordering)
// and the size ceilings. On any violation it sets peer.fatal and stops.
function drainFrames(peer) {
    const out = [];
    let buf = peer.buffer;
    while (buf.length >= 2) {
        const b0 = buf[0];
        const b1 = buf[1];
        if ((b0 & 0x70) !== 0) {
            peer.fatal = "reserved bits set";
            break;
        }
        const fin = (b0 & 0x80) !== 0;
        const opcode = b0 & 0x0f;
        const masked = (b1 & 0x80) !== 0;
        const isControl = opcode >= 0x8;
        let len = b1 & 0x7f;
        let offset = 2;

        if (isControl && (!fin || len > 125)) {
            peer.fatal = "malformed control frame";
            break;
        }
        if (len === 126) {
            if (buf.length < offset + 2) break;
            len = buf.readUInt16BE(offset);
            offset += 2;
        } else if (len === 127) {
            if (buf.length < offset + 8) break;
            const big = buf.readBigUInt64BE(offset);
            if (big > BigInt(MAX_FRAME_BYTES)) {
                peer.fatal = "frame too large";
                break;
            }
            len = Number(big);
            offset += 8;
        }
        if (len > MAX_FRAME_BYTES) {
            peer.fatal = "frame too large";
            break;
        }
        if (!masked) {
            peer.fatal = "client frame not masked";
            break;
        }
        if (buf.length < offset + 4) break;
        const mask = buf.subarray(offset, offset + 4);
        offset += 4;
        if (buf.length < offset + len) break;

        const raw = buf.subarray(offset, offset + len);
        const payload = Buffer.allocUnsafe(len);
        for (let i = 0; i < len; i++) payload[i] = raw[i] ^ mask[i & 3];
        buf = buf.subarray(offset + len);

        if (opcode === 0x0) {
            if (!peer.fragmenting) {
                peer.fatal = "continuation without an open message";
                break;
            }
            peer.fragments.push(payload);
            peer.fragmentBytes += len;
            if (peer.fragmentBytes > MAX_MESSAGE_BYTES) {
                peer.fatal = "message too large";
                break;
            }
            if (fin) {
                out.push({ opcode: peer.fragmentOpcode, payload: Buffer.concat(peer.fragments) });
                peer.fragmenting = false;
                peer.fragments = [];
                peer.fragmentBytes = 0;
            }
        } else if (opcode === 0x1 || opcode === 0x2) {
            if (peer.fragmenting) {
                peer.fatal = "new data frame during fragmentation";
                break;
            }
            if (fin) {
                out.push({ opcode, payload });
            } else {
                peer.fragmenting = true;
                peer.fragmentOpcode = opcode;
                peer.fragments = [payload];
                peer.fragmentBytes = len;
            }
        } else if (opcode === 0x8 || opcode === 0x9 || opcode === 0xa) {
            out.push({ opcode, payload });
        } else {
            peer.fatal = "unknown opcode";
            break;
        }
    }
    peer.buffer = buf;
    return out;
}

function broadcast(obj, { excludeSessionId, rolesOnly } = {}) {
    for (const peer of peers) {
        if (!peer.role) continue;
        if (rolesOnly && peer.role !== rolesOnly) continue;
        if (excludeSessionId && peer.sessionId === excludeSessionId) continue;
        peer.send(obj);
    }
}

function hasClient() {
    for (const peer of peers) if (peer.role === "client") return true;
    return false;
}

// requestId -> { peer (requesting session), timer }
const pendingPermissions = new Map();

function resolvePending(requestId, decisionData) {
    const pending = pendingPermissions.get(requestId);
    if (!pending) return;
    clearTimeout(pending.timer);
    pendingPermissions.delete(requestId);
    pending.peer.send({ type: "permission.decision", requestId, data: decisionData });
}

// Route an inject to session peers. Exact sessionId match wins; otherwise a prefix
// must resolve to exactly one session, else it is dropped as ambiguous. An omitted
// (undefined/null) target broadcasts to every session. Empty/non-string is rejected.
function routeInject(target, data) {
    if (target === undefined || target === null) {
        for (const p of peers) if (p.role === "session") p.send({ type: "inject", data });
        return;
    }
    if (typeof target !== "string" || target.length === 0) return;
    let exact = null;
    const prefixMatches = [];
    for (const p of peers) {
        if (p.role !== "session" || !p.sessionId) continue;
        if (p.sessionId === target) exact = p;
        else if (p.sessionId.startsWith(target)) prefixMatches.push(p);
    }
    if (exact) {
        exact.send({ type: "inject", data });
    } else if (prefixMatches.length === 1) {
        prefixMatches[0].send({ type: "inject", data });
    }
    // zero or ambiguous prefix matches -> drop
}

function handleMessage(peer, obj) {
    if (typeof obj !== "object" || obj === null || typeof obj.type !== "string") return;

    if (obj.type === "hello") {
        if (peer.helloReceived) return; // role is immutable once declared
        peer.helloReceived = true;
        peer.role = obj.role === "client" ? "client" : "session";
        peer.sessionId = typeof obj.sessionId === "string" && obj.sessionId ? obj.sessionId : null;
        peer.meta = obj.data ?? {};
        cancelGrace();
        return;
    }

    if (!peer.helloReceived) return; // must announce a role first

    switch (obj.type) {
        case "permission.request": {
            if (peer.role !== "session") return; // only sessions request permission
            const requestId = obj.requestId;
            if (typeof requestId !== "string" || !requestId) return;
            if (pendingPermissions.has(requestId)) return; // duplicate id -> ignore
            if (!hasClient()) {
                peer.send({
                    type: "permission.decision",
                    requestId,
                    data: { decision: "ask", reason: "no bridge client connected" },
                });
                return;
            }
            const timer = setTimeout(() => {
                resolvePending(requestId, { decision: "ask", reason: "bridge client timed out" });
            }, PERMISSION_TIMEOUT_MS);
            timer.unref?.();
            pendingPermissions.set(requestId, { peer, timer });
            broadcast(
                { type: "permission.request", sessionId: peer.sessionId, requestId, data: obj.data },
                { rolesOnly: "client" }
            );
            return;
        }

        case "permission.decision": {
            if (peer.role !== "client") return; // only clients decide
            const decision = obj.data?.decision;
            if (decision !== "allow" && decision !== "deny" && decision !== "ask") return; // validate
            const pending = pendingPermissions.get(obj.requestId);
            if (!pending) return; // already resolved (first-responder wins)
            clearTimeout(pending.timer);
            pendingPermissions.delete(obj.requestId);
            const reason = typeof obj.data?.reason === "string" ? obj.data.reason : undefined;
            pending.peer.send({ type: "permission.decision", requestId: obj.requestId, data: { decision, reason } });
            return;
        }

        case "inject": {
            if (peer.role !== "client") return; // sessions cannot inject
            routeInject(obj.sessionId, obj.data);
            return;
        }

        default:
            if (peer.role !== "session") return; // only sessions produce mirror traffic
            broadcast({ ...obj, sessionId: peer.sessionId }, { rolesOnly: "client" });
            return;
    }
}

function closePeer(peer) {
    peer.close();
    removePeer(peer);
}

function removePeer(peer) {
    if (!peers.has(peer)) return;
    peers.delete(peer);
    const wasClient = peer.role === "client";
    // Fail any permission requests still owned by this (leaving) session.
    for (const [requestId, pending] of pendingPermissions) {
        if (pending.peer === peer) {
            clearTimeout(pending.timer);
            pendingPermissions.delete(requestId);
        }
    }
    // If the last client left, immediately resolve outstanding requests as ask so
    // no session is stuck waiting the full timeout for an approver that is gone.
    if (wasClient && !hasClient()) {
        for (const requestId of [...pendingPermissions.keys()]) {
            resolvePending(requestId, { decision: "ask", reason: "no bridge client connected" });
        }
    }
    maybeShutdown();
}

function maybeShutdown() {
    if (peers.size > 0) return;
    cancelGrace();
    graceTimer = setTimeout(() => {
        if (peers.size === 0) process.exit(0);
    }, GRACE_MS);
    graceTimer.unref?.();
}

function cancelGrace() {
    if (graceTimer) {
        clearTimeout(graceTimer);
        graceTimer = null;
    }
}

function feed(peer, chunk) {
    if (chunk && chunk.length) peer.buffer = Buffer.concat([peer.buffer, chunk]);
    if (peer.buffer.length > MAX_BUFFER_BYTES) {
        closePeer(peer);
        return;
    }
    for (const frame of drainFrames(peer)) {
        if (frame.opcode === 0x8) {
            closePeer(peer);
            return;
        } else if (frame.opcode === 0x9) {
            try {
                peer.socket.write(encodeFrame(0xa, frame.payload)); // pong
            } catch {
                /* ignore */
            }
        } else if (frame.opcode === 0xa) {
            peer.alive = true;
        } else if (frame.opcode === 0x1) {
            let obj;
            try {
                obj = JSON.parse(frame.payload.toString("utf8"));
            } catch {
                continue;
            }
            handleMessage(peer, obj);
        }
        // 0x2 (binary) is not part of the protocol -> ignored
    }
    if (peer.fatal) closePeer(peer);
}

const server = http.createServer((_req, res) => {
    res.writeHead(426, { "content-type": "text/plain" });
    res.end("copilot-bridge hub: upgrade required");
});

server.on("upgrade", (req, socket, head) => {
    const key = req.headers["sec-websocket-key"];
    const upgrade = String(req.headers["upgrade"] ?? "").toLowerCase();
    const version = String(req.headers["sec-websocket-version"] ?? "");
    if (!key || upgrade !== "websocket" || version !== "13") {
        socket.destroy();
        return;
    }
    socket.write(
        "HTTP/1.1 101 Switching Protocols\r\n" +
            "Upgrade: websocket\r\n" +
            "Connection: Upgrade\r\n" +
            `Sec-WebSocket-Accept: ${acceptKey(key)}\r\n\r\n`
    );

    const peer = new Peer(socket);
    peers.add(peer);
    cancelGrace();

    socket.on("data", (chunk) => feed(peer, chunk));
    socket.on("close", () => removePeer(peer));
    socket.on("error", () => removePeer(peer));

    if (head && head.length) feed(peer, head); // bytes that arrived with the upgrade
});

const heartbeat = setInterval(() => {
    for (const peer of peers) {
        if (peer.alive === false) {
            closePeer(peer);
            continue;
        }
        peer.alive = false;
        try {
            peer.socket.write(encodeFrame(0x9, Buffer.alloc(0))); // ping
        } catch {
            removePeer(peer);
        }
    }
}, HEARTBEAT_MS);
heartbeat.unref?.();

server.on("error", (err) => {
    if (err.code === "EADDRINUSE") process.exit(0); // another hub won the race
    process.exit(1);
});

server.listen(PORT, HOST, () => {
    maybeShutdown(); // exit if nobody ever attaches; a connecting peer cancels this
});
