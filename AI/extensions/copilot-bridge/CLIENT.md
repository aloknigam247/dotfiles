# copilot-bridge protocol

This document specifies the wire protocol so you can write your own client (to watch session activity
and/or answer tool-permission requests). The reference implementation is `client.mjs`.

## Connection

- Transport: **WebSocket**, plain text frames.
- URL: `ws://127.0.0.1:47823` (localhost only, no authentication).
- The hub is started automatically by the first Copilot session that attaches. If nothing is
  listening yet, start a Copilot session (with the extension enabled) or run `hub.mjs` yourself.

## Envelope

Every frame is a single JSON object:

```jsonc
{
  "type": "string",       // required — message kind
  "role": "string",       // only on the initial "hello"
  "sessionId": "string",  // which Copilot session the message concerns
  "requestId": "string",  // permission request/response correlation id
  "data": { }             // type-specific payload
}
```

Unknown fields are ignored. Unknown `type` values are treated as mirror traffic and forwarded to
connected clients, so stick to the types below.

## Handshake

Immediately after connecting, send exactly one `hello` declaring your role:

```json
{ "type": "hello", "role": "client", "data": { "name": "my-client" } }
```

- `role: "client"` — a watcher/approver (your program). Clients receive all mirror traffic **and**
  `permission.request` messages, and may send `permission.decision` and `inject`.
- `role: "session"` — reserved for the Copilot extension shim (producer-only: it sends activity and
  receives permission decisions, but does not consume mirror traffic). Do not use this from a client.

A connection with no `hello` receives nothing and cannot participate. The role is fixed by the first
`hello`: any later `hello` is ignored, and the hub only honours `permission.decision`/`inject` from
clients and `permission.request`/mirror activity from sessions.

## Messages the hub sends to a client

Mirror traffic (one per event, `sessionId` identifies the source session):

| `type`               | `data` fields                        | Meaning                          |
| -------------------- | ------------------------------------ | -------------------------------- |
| `session.start`      | `cwd`                                | A session attached.              |
| `session.end`        | —                                    | A session detached.             |
| `user.prompt`        | `prompt`                             | User submitted a prompt.         |
| `assistant.message`  | `content`, `messageId`               | Assistant produced a reply.      |
| `tool.requested`     | `toolName`, `toolArgs`, `phase`      | A tool wants to run (pending).   |
| `tool.complete`      | `toolName`, `success`, `result`      | A tool finished (and its output).|

`tool.requested` is only a request to run — it is emitted before the permission decision, so a call
that is later denied still produces a `tool.requested` but no successful `tool.complete`.

Permission request (only clients receive these):

```json
{
  "type": "permission.request",
  "sessionId": "abc123",
  "requestId": "3f9c…",
  "data": { "toolName": "shell", "toolArgs": { "command": "rm -rf x" } }
}
```

## Messages a client sends

Answer a permission request by echoing its `requestId`:

```json
{
  "type": "permission.decision",
  "requestId": "3f9c…",
  "data": { "decision": "allow", "reason": "approved by my-client" }
}
```

- `decision` is one of `"allow"`, `"deny"`, `"ask"`.
  - `allow` / `deny` — override the CLI's permission check for that tool call.
  - `ask` — decline to decide; the session falls back to its normal local prompt.
- `reason` is optional free text; shown to the user when a call is denied.

Rules:

- **First responder wins.** If multiple clients are connected, the first matching
  `permission.decision` resolves the request; later ones for the same `requestId` are ignored.
- **Timeout.** If no client answers within 60 s, the hub resolves the request as `ask`.
- **No client.** If a permission request arrives while no client is connected, the hub resolves it as
  `ask` immediately.

A client may also observe silently — you are not required to answer permission requests, but if you
never do, sessions will just wait for the timeout and then prompt locally.

### Injecting a message into a session

A client can push a user prompt into one Copilot session (or all of them). Only clients may inject;
sessions are producer-only and cannot inject into each other.

```json
{
  "type": "inject",
  "sessionId": "a1b2c3",
  "data": { "prompt": "run the tests and summarise failures" }
}
```

- `sessionId` — routing target. An **exact** session-id match is delivered to that session; otherwise
  the value is treated as a **prefix** and delivered only if it matches exactly one session (an
  ambiguous prefix matching several sessions is dropped). Omit `sessionId` entirely to broadcast the
  prompt to every connected session. An empty string is rejected (it does **not** broadcast).
- `data.prompt` — the text delivered as a new user turn via the session's `send()`.
- Sending `inject` from a `session`-role peer is ignored by the hub, so no extension can inject.

## Minimal client

```js
const ws = new WebSocket("ws://127.0.0.1:47823");
ws.onopen = () => ws.send(JSON.stringify({ type: "hello", role: "client", data: { name: "min" } }));
ws.onmessage = (e) => {
    const m = JSON.parse(e.data);
    if (m.type === "permission.request") {
        ws.send(JSON.stringify({
            type: "permission.decision",
            requestId: m.requestId,
            data: { decision: "allow" },
        }));
    } else {
        console.log(m.type, m.sessionId, m.data);
    }
};
```

## Notes

- The hub speaks standard RFC 6455. Any WebSocket library in any language works; you are not tied to
  Node.
- Frames are not batched — one JSON object per WebSocket message.
- The hub replies to WebSocket `ping` with `pong` and sends its own pings; a compliant client library
  handles this transparently.
