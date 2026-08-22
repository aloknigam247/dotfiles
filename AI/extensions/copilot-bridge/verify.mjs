// copilot-bridge self-check harness.
//
// Spawns a hub on the fixed bridge port and exercises the wire protocol end-to-end
// without needing Copilot. It uses two kinds of synthetic peer:
//   - a WebSocket peer (Node's global WebSocket) for high-level protocol tests, and
//   - a raw TCP peer (hand-rolled RFC 6455 client) for framing-level tests
//     (masking, fragmentation, ping-interleave, large payloads).
//
//   node verify.mjs
//
// Run it only when no live session hub is up, since it binds the same fixed port.
// Exits non-zero on any failure.

import net from "node:net";
import crypto from "node:crypto";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const HUB = fileURLToPath(new URL("./hub.mjs", import.meta.url));
const PORT = 47823;
const URL_ = `ws://127.0.0.1:${PORT}`;
// Fast permission timeout (via the hub's env override) so the timeout-fallback test
// does not take the full 60s.
const PERM_TIMEOUT_MS = 800;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Poll an array-returning getter until pred matches an element or the deadline passes.
async function waitFor(getArr, pred, ms = 1500) {
    const end = Date.now() + ms;
    for (;;) {
        const found = getArr().find(pred);
        if (found) return found;
        if (Date.now() >= end) return null;
        await sleep(10);
    }
}

// Let the hub settle so "should NOT arrive" assertions are meaningful.
const settle = (ms = 200) => sleep(ms);

// --- WebSocket peer (high-level protocol) ----------------------------------

async function openWS(role, sessionId, name) {
    return await new Promise((resolve) => {
        const ws = new WebSocket(URL_);
        const recv = [];
        const peer = {
            ws,
            recv,
            send: (obj) => ws.send(JSON.stringify(obj)),
            close: () => {
                try {
                    ws.close();
                } catch {
                    /* ignore */
                }
            },
        };
        ws.onmessage = (e) => {
            try {
                recv.push(JSON.parse(e.data));
            } catch {
                /* ignore non-JSON */
            }
        };
        ws.onopen = () => {
            if (role) ws.send(JSON.stringify({ type: "hello", role, sessionId, data: { name } }));
            resolve(peer);
        };
        ws.onerror = () => resolve(null);
    });
}

// --- Raw RFC 6455 client (framing-level) -----------------------------------

function encodeClientFrame(opcode, payload, { fin = true, mask = true } = {}) {
    const len = payload.length;
    const maskBit = mask ? 0x80 : 0x00;
    let header;
    if (len < 126) {
        header = Buffer.alloc(2);
        header[1] = maskBit | len;
    } else if (len < 65536) {
        header = Buffer.alloc(4);
        header[1] = maskBit | 126;
        header.writeUInt16BE(len, 2);
    } else {
        header = Buffer.alloc(10);
        header[1] = maskBit | 127;
        header.writeBigUInt64BE(BigInt(len), 2);
    }
    header[0] = (fin ? 0x80 : 0x00) | opcode;
    if (!mask) return Buffer.concat([header, payload]);
    const key = crypto.randomBytes(4);
    const masked = Buffer.allocUnsafe(len);
    for (let i = 0; i < len; i++) masked[i] = payload[i] ^ key[i & 3];
    return Buffer.concat([header, key, masked]);
}

async function openRaw() {
    return await new Promise((resolve, reject) => {
        const socket = net.connect(PORT, "127.0.0.1");
        const key = crypto.randomBytes(16).toString("base64");
        let handshakeDone = false;
        let rbuf = Buffer.alloc(0);
        const messages = [];
        const pongs = [];
        const state = { closed: false };

        const peer = {
            socket,
            messages,
            pongs,
            state,
            raw: (buf) => socket.write(buf),
            frame: (opcode, payload, opts) => socket.write(encodeClientFrame(opcode, payload, opts)),
            sendJSON: (obj, opts) => socket.write(encodeClientFrame(0x1, Buffer.from(JSON.stringify(obj)), opts)),
            hello: (role, sessionId, name) =>
                socket.write(encodeClientFrame(0x1, Buffer.from(JSON.stringify({ type: "hello", role, sessionId, data: { name } })))),
            ping: (payload = Buffer.alloc(0)) => socket.write(encodeClientFrame(0x9, payload)),
            // Send a JSON message split across a first data frame + a continuation,
            // optionally interleaving a ping between the fragments.
            sendFragmentedJSON: (obj, { withPing = false } = {}) => {
                const full = Buffer.from(JSON.stringify(obj));
                const mid = Math.floor(full.length / 2);
                socket.write(encodeClientFrame(0x1, full.subarray(0, mid), { fin: false }));
                if (withPing) socket.write(encodeClientFrame(0x9, Buffer.from("hb")));
                socket.write(encodeClientFrame(0x0, full.subarray(mid), { fin: true }));
            },
            close: () => {
                try {
                    socket.write(encodeClientFrame(0x8, Buffer.alloc(0)));
                    socket.destroy();
                } catch {
                    /* ignore */
                }
            },
        };

        function drainServerFrames() {
            let buf = rbuf;
            while (buf.length >= 2) {
                const b0 = buf[0];
                const b1 = buf[1];
                const opcode = b0 & 0x0f;
                let len = b1 & 0x7f;
                let off = 2;
                if (len === 126) {
                    if (buf.length < off + 2) break;
                    len = buf.readUInt16BE(off);
                    off += 2;
                } else if (len === 127) {
                    if (buf.length < off + 8) break;
                    len = Number(buf.readBigUInt64BE(off));
                    off += 8;
                }
                if (buf.length < off + len) break;
                const payload = buf.subarray(off, off + len);
                buf = buf.subarray(off + len);
                if (opcode === 0x1) {
                    try {
                        messages.push(JSON.parse(payload.toString("utf8")));
                    } catch {
                        /* ignore */
                    }
                } else if (opcode === 0x9) {
                    socket.write(encodeClientFrame(0xa, payload)); // reply pong
                } else if (opcode === 0xa) {
                    pongs.push(payload);
                } else if (opcode === 0x8) {
                    state.closed = true;
                }
            }
            rbuf = buf;
        }

        socket.on("connect", () => {
            socket.write(
                `GET / HTTP/1.1\r\n` +
                    `Host: 127.0.0.1:${PORT}\r\n` +
                    `Upgrade: websocket\r\n` +
                    `Connection: Upgrade\r\n` +
                    `Sec-WebSocket-Key: ${key}\r\n` +
                    `Sec-WebSocket-Version: 13\r\n\r\n`
            );
        });
        socket.on("data", (chunk) => {
            rbuf = Buffer.concat([rbuf, chunk]);
            if (!handshakeDone) {
                const idx = rbuf.indexOf("\r\n\r\n");
                if (idx === -1) return;
                const header = rbuf.slice(0, idx).toString("utf8");
                rbuf = rbuf.subarray(idx + 4);
                handshakeDone = true;
                if (!/HTTP\/1\.1 101/.test(header)) {
                    reject(new Error("handshake not 101"));
                    return;
                }
                resolve(peer);
            }
            if (handshakeDone) drainServerFrames();
        });
        socket.on("error", () => {
            state.closed = true;
        });
        socket.on("close", () => {
            state.closed = true;
        });
    });
}

// --- test runner -----------------------------------------------------------

const tests = [];
function test(name, fn) {
    tests.push({ name, fn });
}

let failures = 0;
let passes = 0;

async function runAll() {
    for (const t of tests) {
        const opened = [];
        const track = (p) => {
            if (p) opened.push(p);
            return p;
        };
        try {
            await Promise.race([
                t.fn({ track }),
                sleep(6000).then(() => {
                    throw new Error("test timed out");
                }),
            ]);
            console.log(`PASS  ${t.name}`);
            passes++;
        } catch (err) {
            console.log(`FAIL  ${t.name} -- ${err.message}`);
            failures++;
        } finally {
            for (const p of opened) {
                try {
                    p.close();
                } catch {
                    /* ignore */
                }
            }
            await settle(60);
        }
    }
}

function expect(cond, msg) {
    if (!cond) throw new Error(msg);
}

// =========================== BASELINE TESTS ================================

test("session and client can connect and handshake", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C = track(await openWS("client", undefined, "C"));
    expect(A && C, "both peers connected");
});

test("producer-only mirror: activity reaches clients, not other sessions or self", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "assistant.message", data: { content: "hello world" } });
    const got = await waitFor(() => C.recv, (m) => m.type === "assistant.message" && m.data?.content === "hello world");
    expect(got, "client received the mirrored message");
    expect(got.sessionId === "sessionAAA", "hub stamped the sender sessionId");
    await settle(150);
    expect(!B.recv.some((m) => m.type === "assistant.message"), "peer session did NOT receive it");
    expect(!A.recv.some((m) => m.type === "assistant.message"), "sender did NOT receive its own echo");
});

test("mirror preserves nested data fields (tool args + result)", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "tool.requested", data: { toolName: "shell", toolArgs: { command: "ls -la" } } });
    A.send({ type: "tool.complete", data: { toolName: "shell", success: true, result: "total 0" } });
    const req = await waitFor(() => C.recv, (m) => m.type === "tool.requested");
    const done = await waitFor(() => C.recv, (m) => m.type === "tool.complete");
    expect(req?.data?.toolArgs?.command === "ls -la", "toolArgs.command preserved");
    expect(done?.data?.success === true && done?.data?.result === "total 0", "success+result preserved");
});

test("multiple clients all receive mirrored activity", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C1 = track(await openWS("client", undefined, "C1"));
    const C2 = track(await openWS("client", undefined, "C2"));
    await settle(120);
    A.send({ type: "user.prompt", data: { prompt: "ping" } });
    const g1 = await waitFor(() => C1.recv, (m) => m.type === "user.prompt");
    const g2 = await waitFor(() => C2.recv, (m) => m.type === "user.prompt");
    expect(g1 && g2, "both clients received the prompt");
});

test("permission request routes to clients only, decision returns to requester", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "r1", data: { toolName: "shell" } });
    const req = await waitFor(() => C.recv, (m) => m.type === "permission.request" && m.requestId === "r1");
    expect(req, "client received permission.request");
    expect(req.sessionId === "sessionAAA", "request carries requester sessionId");
    await settle(120);
    expect(!B.recv.some((m) => m.type === "permission.request"), "peer session did NOT receive the request");
    C.send({ type: "permission.decision", requestId: "r1", data: { decision: "allow", reason: "ok" } });
    const dec = await waitFor(() => A.recv, (m) => m.type === "permission.decision" && m.requestId === "r1");
    expect(dec?.data?.decision === "allow", "requesting session got the allow decision");
});

test("first-responder wins among multiple clients", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C1 = track(await openWS("client", undefined, "C1"));
    const C2 = track(await openWS("client", undefined, "C2"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "r2", data: { toolName: "shell" } });
    await waitFor(() => C1.recv, (m) => m.requestId === "r2");
    await waitFor(() => C2.recv, (m) => m.requestId === "r2");
    C1.send({ type: "permission.decision", requestId: "r2", data: { decision: "allow" } });
    C2.send({ type: "permission.decision", requestId: "r2", data: { decision: "deny" } });
    await settle(250);
    const decisions = A.recv.filter((m) => m.type === "permission.decision" && m.requestId === "r2");
    expect(decisions.length === 1, `exactly one decision delivered (got ${decisions.length})`);
    expect(decisions[0].data.decision === "allow", "the first (allow) decision won");
});

test("no client connected -> immediate ask fallback", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "r3", data: { toolName: "shell" } });
    const dec = await waitFor(() => A.recv, (m) => m.type === "permission.decision" && m.requestId === "r3", 1000);
    expect(dec?.data?.decision === "ask", "session got an immediate ask");
});

test("inject: client -> exact sessionId reaches only that session", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    C.send({ type: "inject", sessionId: "sessionAAA", data: { prompt: "go" } });
    const got = await waitFor(() => A.recv, (m) => m.type === "inject" && m.data?.prompt === "go");
    expect(got, "target session received the inject");
    await settle(150);
    expect(!B.recv.some((m) => m.type === "inject"), "non-target session did NOT receive it");
});

test("inject: client -> unique prefix reaches the matching session", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    C.send({ type: "inject", sessionId: "sessionA", data: { prompt: "prefix" } });
    const got = await waitFor(() => A.recv, (m) => m.type === "inject" && m.data?.prompt === "prefix");
    expect(got, "prefix-matched session received the inject");
    await settle(150);
    expect(!B.recv.some((m) => m.type === "inject"), "the other session did NOT receive it");
});

test("inject: client -> omitted sessionId broadcasts to all sessions, no clients", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    C.send({ type: "inject", data: { prompt: "all" } });
    const gotA = await waitFor(() => A.recv, (m) => m.type === "inject" && m.data?.prompt === "all");
    const gotB = await waitFor(() => B.recv, (m) => m.type === "inject" && m.data?.prompt === "all");
    expect(gotA && gotB, "both sessions received the broadcast inject");
    await settle(120);
    expect(!C.recv.some((m) => m.type === "inject"), "client did NOT receive the inject echo");
});

test("inject from a session role is ignored (no extension can inject)", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "inject", sessionId: "sessionBBB", data: { prompt: "nope" } });
    await settle(300);
    expect(!B.recv.some((m) => m.type === "inject"), "session-originated inject was dropped");
});

test("framing: masked single frame is parsed (raw session -> client)", async ({ track }) => {
    const R = track(await openRaw());
    const C = track(await openWS("client", undefined, "C"));
    R.hello("session", "sessionRAW", "R");
    await settle(120);
    R.sendJSON({ type: "assistant.message", data: { content: "masked-ok" } });
    const got = await waitFor(() => C.recv, (m) => m.type === "assistant.message" && m.data?.content === "masked-ok");
    expect(got, "client received the masked frame's message");
});

test("framing: fragmented text frame is reassembled", async ({ track }) => {
    const R = track(await openRaw());
    const C = track(await openWS("client", undefined, "C"));
    R.hello("session", "sessionRAW", "R");
    await settle(120);
    R.sendFragmentedJSON({ type: "assistant.message", data: { content: "fragmented-payload" } });
    const got = await waitFor(() => C.recv, (m) => m.type === "assistant.message" && m.data?.content === "fragmented-payload");
    expect(got, "reassembled fragmented message delivered");
});

test("framing: ping interleaved between fragments -> pong + message intact", async ({ track }) => {
    const R = track(await openRaw());
    const C = track(await openWS("client", undefined, "C"));
    R.hello("session", "sessionRAW", "R");
    await settle(120);
    R.sendFragmentedJSON({ type: "assistant.message", data: { content: "interleaved" } }, { withPing: true });
    const got = await waitFor(() => C.recv, (m) => m.type === "assistant.message" && m.data?.content === "interleaved");
    expect(got, "message survived the interleaved ping");
    const pong = await waitFor(() => R.pongs, () => true, 1000);
    expect(pong, "hub answered the interleaved ping with a pong");
});

test("framing: large payload (>64KiB) is delivered intact", async ({ track }) => {
    const R = track(await openRaw());
    const C = track(await openWS("client", undefined, "C"));
    R.hello("session", "sessionRAW", "R");
    await settle(120);
    const big = "x".repeat(70000);
    R.sendJSON({ type: "assistant.message", data: { content: big } });
    const got = await waitFor(() => C.recv, (m) => m.type === "assistant.message" && m.data?.content?.length === 70000, 2500);
    expect(got, "70000-char payload received intact");
});

// =========================== MORE TESTS ===================================

test("role: a session-role peer cannot answer a permission.decision", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const Evil = track(await openWS("session", "sessionEVIL", "E"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "h1", data: { toolName: "shell" } });
    await waitFor(() => C.recv, (m) => m.requestId === "h1");
    Evil.send({ type: "permission.decision", requestId: "h1", data: { decision: "allow" } });
    await settle(250);
    expect(!A.recv.some((m) => m.type === "permission.decision" && m.requestId === "h1"), "session-sent decision was rejected");
});

test("role: a second hello cannot change an established peer's role", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    await settle(120);
    // B tries to become a client, then inject -- must be ignored on both counts.
    B.send({ type: "hello", role: "client", data: { name: "promoted" } });
    await settle(120);
    B.send({ type: "inject", sessionId: "sessionAAA", data: { prompt: "escalated" } });
    await settle(300);
    expect(!A.recv.some((m) => m.type === "inject"), "role remained immutable; inject was dropped");
});

test("validation: an invalid decision value is rejected", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "h2", data: { toolName: "shell" } });
    await waitFor(() => C.recv, (m) => m.requestId === "h2");
    C.send({ type: "permission.decision", requestId: "h2", data: { decision: "yolo" } });
    await settle(200);
    const bad = A.recv.find((m) => m.type === "permission.decision" && m.requestId === "h2" && m.data?.decision === "yolo");
    expect(!bad, "the bogus decision value did not reach the session");
});

test("disconnect: last client leaving resolves pending permission as ask", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "h3", data: { toolName: "shell" } });
    await waitFor(() => C.recv, (m) => m.requestId === "h3");
    C.close();
    const dec = await waitFor(() => A.recv, (m) => m.type === "permission.decision" && m.requestId === "h3", 2000);
    expect(dec?.data?.decision === "ask", "session got a prompt ask fallback promptly after client left");
});

test("timeout: unanswered permission falls back to ask quickly", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    track(await openWS("client", undefined, "C")); // present but silent
    await settle(120);
    A.send({ type: "permission.request", requestId: "h4", data: { toolName: "shell" } });
    const dec = await waitFor(() => A.recv, (m) => m.type === "permission.decision" && m.requestId === "h4", PERM_TIMEOUT_MS + 1500);
    expect(dec?.data?.decision === "ask", "timed-out request resolved as ask");
});

test("inject: empty-string sessionId is rejected (no accidental broadcast)", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionBBB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    C.send({ type: "inject", sessionId: "", data: { prompt: "empty" } });
    await settle(300);
    expect(!A.recv.some((m) => m.type === "inject"), "empty sessionId did not broadcast to A");
    expect(!B.recv.some((m) => m.type === "inject"), "empty sessionId did not broadcast to B");
});

test("inject: ambiguous prefix does not fan out to multiple sessions", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const B = track(await openWS("session", "sessionAAB", "B"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    C.send({ type: "inject", sessionId: "session", data: { prompt: "ambig" } });
    await settle(300);
    const hitA = A.recv.some((m) => m.type === "inject");
    const hitB = B.recv.some((m) => m.type === "inject");
    expect(!(hitA && hitB), "ambiguous prefix was not delivered to both sessions");
});

test("framing: an unmasked client frame is rejected", async ({ track }) => {
    const R = track(await openRaw());
    const C = track(await openWS("client", undefined, "C"));
    R.hello("session", "sessionRAW", "R");
    await settle(120);
    R.frame(0x1, Buffer.from(JSON.stringify({ type: "assistant.message", data: { content: "unmasked" } })), { mask: false });
    await settle(300);
    expect(!C.recv.some((m) => m.data?.content === "unmasked"), "unmasked frame was not mirrored");
    expect(R.state.closed, "hub closed the connection that sent an unmasked frame");
});

test("duplicate requestId does not corrupt routing", async ({ track }) => {
    const A = track(await openWS("session", "sessionAAA", "A"));
    const C = track(await openWS("client", undefined, "C"));
    await settle(120);
    A.send({ type: "permission.request", requestId: "dup", data: { toolName: "a" } });
    await waitFor(() => C.recv, (m) => m.requestId === "dup");
    A.send({ type: "permission.request", requestId: "dup", data: { toolName: "b" } });
    await settle(150);
    C.send({ type: "permission.decision", requestId: "dup", data: { decision: "allow" } });
    await settle(250);
    const decisions = A.recv.filter((m) => m.type === "permission.decision" && m.requestId === "dup");
    expect(decisions.length <= 1, `at most one decision routed for a duplicate id (got ${decisions.length})`);
});

// --- main ------------------------------------------------------------------

const hub = spawn(process.execPath, [HUB], {
    stdio: "ignore",
    env: {
        ...process.env,
        COPILOT_BRIDGE_PERMISSION_TIMEOUT_MS: String(PERM_TIMEOUT_MS),
    },
});
hub.on("error", () => {});

await sleep(500);
await runAll();

console.log(`\n${passes} passed, ${failures} failed`);

try {
    hub.kill();
} catch {
    /* ignore */
}
process.exit(failures === 0 ? 0 : 1);
