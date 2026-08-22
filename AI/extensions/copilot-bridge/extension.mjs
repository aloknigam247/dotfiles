// copilot-bridge extension: a per-session shim that connects to the local hub
// (bootstrapping it if absent), mirrors this session's chat/tool activity to all
// other attached sessions, renders their activity into this timeline, and forwards
// tool-permission checks to a connected bridge client.
//
// Zero dependencies: uses Node's global WebSocket client and @github/copilot-sdk.

import { joinSession } from "@github/copilot-sdk/extension";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";
import { existsSync } from "node:fs";
import { delimiter, join, basename } from "node:path";

const HUB_URL = "ws://127.0.0.1:47823";
const HUB_PATH = fileURLToPath(new URL("./hub.mjs", import.meta.url));
const CONNECT_TIMEOUT_MS = 500;
const BOOTSTRAP_ATTEMPTS = 12;
const BACKOFF_MS = 150;
const RECONNECT_MS = 1_000;
const OUTBOX_MAX = 500; // cap queued activity so a long outage cannot grow unbounded
const PERMISSION_TIMEOUT_MS = 65_000;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Declared before joinSession so hook callbacks that fire early can reference it
// without hitting the temporal dead zone; it is assigned once the session resolves.
let mySessionId = null;

const session = await joinSession({
    hooks: {
        onSessionStart: () => {
            send({ type: "session.start", data: { cwd: process.cwd() } });
        },
        onSessionEnd: () => {
            send({ type: "session.end" });
        },
        onUserPromptSubmitted: (input) => {
            send({ type: "user.prompt", data: { prompt: input.prompt } });
        },
        onPreToolUse: async (input) => {
            // Report the pending call with its args here: the pre-use hook is the
            // reliable source of toolArgs (the actual command/input). This is only a
            // request to run -- tool.complete reports whether it actually ran.
            send({ type: "tool.requested", data: { toolName: input.toolName, toolArgs: input.toolArgs, phase: "pending" } });
            return await requestPermission(input);
        },
    },
});

mySessionId = session.sessionId;

// Forward this session's activity to the hub.
session.on("assistant.message", (event) => {
    send({
        type: "assistant.message",
        data: { content: event.data?.content, messageId: event.data?.messageId },
    });
});
session.on("tool.execution_complete", (event) => {
    send({
        type: "tool.complete",
        data: {
            toolName: event.data?.toolName,
            success: event.data?.success,
            result: summarizeResult(event.data),
        },
    });
});

// Best-effort extraction of a tool's textual result across SDK payload shapes.
function summarizeResult(data) {
    if (!data) return undefined;
    const raw = data.result ?? data.output ?? data.content ?? data.stdout;
    if (raw == null) return undefined;
    const text = typeof raw === "string" ? raw : JSON.stringify(raw);
    return text.length > 400 ? text.slice(0, 400) + "…" : text;
}

// --- hub connection management ---------------------------------------------

let ws = null;
let connecting = false;
let reconnectTimer = null;
const outbox = []; // frames queued while disconnected
const pendingPermissions = new Map(); // requestId -> resolve(decisionObj|undefined)

function send(obj) {
    const frame = { ...obj, sessionId: mySessionId };
    const text = JSON.stringify(frame);
    if (ws && ws.readyState === 1) {
        try {
            ws.send(text);
            return;
        } catch {
            /* fall through to queue + reconnect */
        }
    }
    enqueue(text);
    void ensureConnected();
}

function enqueue(text) {
    outbox.push(text);
    if (outbox.length > OUTBOX_MAX) outbox.splice(0, outbox.length - OUTBOX_MAX); // drop oldest
}

function flushOutbox() {
    while (outbox.length && ws && ws.readyState === 1) {
        const text = outbox[0];
        try {
            ws.send(text);
        } catch {
            return; // keep it queued; a reconnect will retry
        }
        outbox.shift();
    }
}

// The extension is forked by the Copilot CLI's own runtime, so process.execPath is
// copilot.exe -- not a Node interpreter that can run hub.mjs. Locate a real Node.
function resolveNode() {
    if (process.env.COPILOT_BRIDGE_NODE && existsSync(process.env.COPILOT_BRIDGE_NODE)) {
        return process.env.COPILOT_BRIDGE_NODE;
    }
    const exe = basename(process.execPath).toLowerCase();
    if (exe === "node" || exe === "node.exe") return process.execPath;
    const names = process.platform === "win32" ? ["node.exe"] : ["node"];
    for (const dir of (process.env.PATH ?? "").split(delimiter)) {
        if (!dir) continue;
        for (const name of names) {
            const candidate = join(dir, name);
            if (existsSync(candidate)) return candidate;
        }
    }
    return process.platform === "win32" ? "node.exe" : "node"; // last resort: PATH lookup
}

function spawnHub() {
    try {
        const child = spawn(resolveNode(), [HUB_PATH], { detached: true, stdio: "ignore" });
        // spawn reports failures such as ENOENT asynchronously via an error event, not
        // by throwing; without this listener that event would crash the extension.
        child.on("error", () => {});
        child.unref();
    } catch {
        /* another session may have started it; rendezvous retry will find it */
    }
}

function tryConnect() {
    return new Promise((resolve) => {
        let socket;
        try {
            socket = new WebSocket(HUB_URL);
        } catch {
            resolve(null);
            return;
        }
        const timer = setTimeout(() => {
            try {
                socket.close();
            } catch {
                /* ignore */
            }
            resolve(null);
        }, CONNECT_TIMEOUT_MS);
        socket.onopen = () => {
            clearTimeout(timer);
            resolve(socket);
        };
        socket.onerror = () => {
            clearTimeout(timer);
            resolve(null);
        };
    });
}

async function ensureConnected() {
    if (connecting || (ws && ws.readyState === 1)) return;
    connecting = true;
    try {
        for (let attempt = 0; attempt < BOOTSTRAP_ATTEMPTS; attempt++) {
            const socket = await tryConnect();
            if (socket) {
                attachSocket(socket);
                return;
            }
            if (attempt === 0) spawnHub();
            await sleep(BACKOFF_MS);
        }
        // Still down after a full bootstrap round: keep trying so a session that
        // outlives a hub outage reconnects on its own.
        scheduleReconnect();
    } finally {
        connecting = false;
    }
}

function scheduleReconnect() {
    if (reconnectTimer) return;
    reconnectTimer = setTimeout(() => {
        reconnectTimer = null;
        void ensureConnected();
    }, RECONNECT_MS);
    reconnectTimer.unref?.();
}

function attachSocket(socket) {
    ws = socket;
    socket.onmessage = (event) => onHubMessage(event.data);
    socket.onclose = () => {
        if (ws === socket) ws = null;
        void ensureConnected();
    };
    socket.onerror = () => {
        try {
            socket.close();
        } catch {
            /* ignore */
        }
    };
    socket.send(
        JSON.stringify({
            type: "hello",
            role: "session",
            sessionId: mySessionId,
            data: { cwd: process.cwd() },
        })
    );
    flushOutbox();
}

function onHubMessage(raw) {
    let msg;
    try {
        msg = JSON.parse(typeof raw === "string" ? raw : raw.toString());
    } catch {
        return;
    }

    if (msg.type === "permission.decision") {
        const resolve = pendingPermissions.get(msg.requestId);
        if (resolve) {
            pendingPermissions.delete(msg.requestId);
            resolve(msg.data);
        }
        return;
    }

    if (msg.type === "inject") {
        const prompt = msg.data?.prompt;
        if (typeof prompt === "string" && prompt.length) {
            void session.send(prompt).catch(() => {});
        }
        return;
    }
    // Sessions are producer-only: any other mirrored peer activity is ignored here
    // and is consumed only by connected clients.
}

// Ask the bridge client (via the hub) to decide a tool permission. Resolves to a
// hook output object, or undefined to fall through to the CLI's normal prompt.
function requestPermission(input) {
    return new Promise((resolve) => {
        if (!ws || ws.readyState !== 1) {
            resolve(undefined); // no bridge -> normal local prompt
            return;
        }
        const requestId = randomUUID();
        const timer = setTimeout(() => {
            if (pendingPermissions.delete(requestId)) resolve(undefined);
        }, PERMISSION_TIMEOUT_MS);

        pendingPermissions.set(requestId, (decision) => {
            clearTimeout(timer);
            if (!decision || decision.decision === "ask") {
                resolve(undefined);
                return;
            }
            resolve({
                permissionDecision: decision.decision,
                permissionDecisionReason: decision.reason,
            });
        });

        send({
            type: "permission.request",
            requestId,
            data: { toolName: input.toolName, toolArgs: input.toolArgs },
        });
    });
}

await ensureConnected();
