// copilot-bridge reference client: connects to the local hub, prints the mirrored
// activity of every attached Copilot session, and answers tool-permission requests.
//
// Usage:
//   node client.mjs               interactive (prompt allow/deny per request)
//   node client.mjs --allow-all   auto-approve every permission request
//   node client.mjs --deny-all    auto-deny every permission request
//
// Zero dependencies: uses Node's global WebSocket client.

import readline from "node:readline";

const HUB_URL = process.env.COPILOT_BRIDGE_URL ?? "ws://127.0.0.1:47823";
const MODE = process.argv.includes("--allow-all")
    ? "allow"
    : process.argv.includes("--deny-all")
      ? "deny"
      : "interactive";

const short = (sid) => (sid ? String(sid).slice(0, 6) : "??????");

// Render tool args/result compactly on one line for the mirror log.
function fmt(value) {
    if (value == null) return "";
    if (typeof value === "string") {
        return value.length > 200 ? value.slice(0, 200) + "…" : value;
    }
    if (typeof value === "object" && typeof value.command === "string") {
        return value.command; // shell-like tools: show the actual command
    }
    const text = JSON.stringify(value);
    return text.length > 200 ? text.slice(0, 200) + "…" : text;
}

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const askQueue = [];
let currentAsk = null; // [ws, msg] while a permission awaits an answer
let currentWs = null; // latest live socket, used for inject commands

function connect() {
    let ws;
    try {
        ws = new WebSocket(HUB_URL);
    } catch (err) {
        console.error(`connect failed: ${err.message}; retrying in 1s`);
        setTimeout(connect, 1000);
        return;
    }

    ws.onopen = () => {
        ws.send(JSON.stringify({ type: "hello", role: "client", data: { name: "reference-client" } }));
        currentWs = ws;
        console.log(`connected to ${HUB_URL} (mode: ${MODE})`);
        console.log("commands: /say <sessionId> <message> | /sayall <message>");
    };

    ws.onmessage = (event) => handle(ws, event.data);

    ws.onclose = () => {
        if (currentWs === ws) currentWs = null;
        // Drop permission prompts tied to this dead socket so we never answer into a
        // closed connection and stale questions do not block new ones.
        askQueue.length = 0;
        currentAsk = null;
        console.error("disconnected; retrying in 1s");
        setTimeout(connect, 1000);
    };

    ws.onerror = () => {
        try {
            ws.close();
        } catch {
            /* ignore */
        }
    };
}

function handle(ws, raw) {
    let msg;
    try {
        msg = JSON.parse(typeof raw === "string" ? raw : raw.toString());
    } catch {
        return;
    }
    const tag = `[${short(msg.sessionId)}]`;

    switch (msg.type) {
        case "user.prompt":
            console.log(`${tag} user: ${msg.data?.prompt ?? ""}`);
            break;
        case "assistant.message":
            console.log(`${tag} asst: ${msg.data?.content ?? ""}`);
            break;
        case "tool.requested": {
            const args = fmt(msg.data?.toolArgs);
            console.log(`${tag} tool? ${msg.data?.toolName ?? ""}${args ? " " + args : ""} (pending)`);
            break;
        }
        case "tool.complete": {
            const result = fmt(msg.data?.result);
            const ok = msg.data?.success ? "ok" : "FAIL";
            console.log(`${tag} tool< ${msg.data?.toolName ?? ""} ${ok}${result ? " " + result : ""}`);
            break;
        }
        case "session.start":
            console.log(`${tag} + session joined (${msg.data?.cwd ?? ""})`);
            break;
        case "session.end":
            console.log(`${tag} - session left`);
            break;
        case "permission.request":
            enqueuePermission(ws, msg);
            break;
        default:
            break;
    }
}

function decide(ws, msg, decision, reason) {
    ws.send(
        JSON.stringify({
            type: "permission.decision",
            requestId: msg.requestId,
            data: { decision, reason },
        })
    );
}

function enqueuePermission(ws, msg) {
    if (MODE !== "interactive") {
        const tag = `[${short(msg.sessionId)}]`;
        console.log(`${tag} PERMISSION auto-${MODE}: ${msg.data?.toolName ?? "tool"} ${fmt(msg.data?.toolArgs)}`);
        decide(ws, msg, MODE, `reference-client --${MODE}-all`);
        return;
    }
    askQueue.push([ws, msg]);
    drainAskQueue();
}

function drainAskQueue() {
    if (currentAsk || askQueue.length === 0) return;
    currentAsk = askQueue.shift();
    const [, msg] = currentAsk;
    const tag = `[${short(msg.sessionId)}]`;
    console.log(`${tag} PERMISSION: ${msg.data?.toolName ?? "tool"} ${fmt(msg.data?.toolArgs)}`);
    process.stdout.write("  allow / deny / ask? [a/d/s] ");
}

// Inject a prompt into a Copilot session (or all sessions when sid is null).
function inject(sid, prompt) {
    if (!currentWs || currentWs.readyState !== 1) {
        console.error("  not connected");
        return;
    }
    currentWs.send(JSON.stringify({ type: "inject", sessionId: sid ?? undefined, data: { prompt } }));
    console.log(`  injected into ${sid ? short(sid) : "all sessions"}: ${prompt}`);
}

rl.on("line", (line) => {
    const text = line.trim();

    // Explicit slash commands are always interpreted as commands, even while a
    // permission prompt is pending, so an inject is never swallowed as an answer.
    if (text === "/sayall" || text === "/say") {
        console.error(`  usage: ${text === "/say" ? "/say <sessionId> <message>" : "/sayall <message>"}`);
        return;
    }
    if (text.startsWith("/sayall ")) {
        inject(null, text.slice("/sayall ".length));
        return;
    }
    if (text.startsWith("/say ")) {
        const rest = text.slice("/say ".length);
        const sp = rest.indexOf(" ");
        if (sp <= 0) {
            console.error("  usage: /say <sessionId> <message>");
        } else {
            inject(rest.slice(0, sp), rest.slice(sp + 1));
        }
        return;
    }

    if (currentAsk) {
        const [ws, msg] = currentAsk;
        currentAsk = null;
        const a = text.toLowerCase();
        const decision = a === "a" ? "allow" : a === "d" ? "deny" : "ask";
        decide(ws, msg, decision, "reference-client interactive");
        drainAskQueue();
        return;
    }

    if (text.length) {
        console.error("  commands: /say <sessionId> <message> | /sayall <message>");
    }
});

connect();
