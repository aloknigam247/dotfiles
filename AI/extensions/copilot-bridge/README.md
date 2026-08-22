# copilot-bridge

A local bridge that connects multiple **GitHub Copilot CLI** sessions. It mirrors every session's
chat to all other attached sessions and lets an external client watch the traffic and answer tool
permission prompts on your behalf.

- **Chat sharing** — user prompts and assistant replies from each session are relayed to any
  connected client. Copilot sessions are **producer-only**: they forward their own activity but do
  not display other sessions' chat.
- **Permission bridge** — when a session hits a tool-permission check, the request is forwarded to a
  connected client, which replies `allow` / `deny` / `ask`. With no client connected (or on timeout),
  the session falls back to the normal local prompt.

Everything runs on `127.0.0.1`, with **no authentication** — it is intended for local use only.

## How it works

```
 session A ─ extension.mjs ─┐
 session B ─ extension.mjs ─┤  ws://127.0.0.1:47823   ┌────────┐  ws://   client(s)
 session C ─ extension.mjs ─┼───────────────────────► │  hub   │ ◄───────  (watch / approve)
                            └───────────────────────► └────────┘
```

- Each Copilot session forks its own `extension.mjs` (extensions are per-session processes).
- The **first** extension to start **spawns the hub** as a detached background process. The port
  `47823` is the lock: whoever binds it first is the hub; any other hub process exits immediately.
- Each extension is **producer-only**: it sends its own activity to the hub but does not render other
  sessions' activity. The hub fans mirror traffic out to connected **clients** only.
- The hub **self-terminates** ~30 s after the last session detaches (kept honest by a WebSocket
  heartbeat), and is re-spawned automatically by the next session that starts.

Zero runtime dependencies: the extension and client use Node's built-in global `WebSocket` (Node 22+),
and the hub implements a minimal WebSocket server itself. No `npm install` is required.

## Install

The extension ships as part of the `AI` dotfiles package. `AI/setup.ps1` symlinks it into the user
Copilot extensions directory:

```
AI\extensions\copilot-bridge  →  ~\.copilot\extensions\copilot-bridge
```

Run the normal dotfiles setup (which invokes `linkConfigs`), or create the link manually:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.copilot\extensions" | Out-Null
New-Item -ItemType SymbolicLink -Path "$HOME\.copilot\extensions\copilot-bridge" `
    -Target "D:\dotfiles\AI\extensions\copilot-bridge"
```

### Enable extensions

Copilot CLI loads extensions only when the **EXTENSIONS** experimental feature is enabled. Turn it on
with `/experimental` (or the settings UI), then start a new session. Confirm it loaded with `/env` —
`copilot-bridge` should appear under extensions.

## Usage

1. Start one or more Copilot CLI sessions in separate terminals. They auto-connect; the first one
   brings up the hub. Each session forwards its own prompts, replies, and tool activity, but does not
   display other sessions' chat (sessions are producer-only).
2. Start the reference client to watch all sessions and approve permissions:

   ```powershell
   node "$HOME\.copilot\extensions\copilot-bridge\client.mjs"          # interactive
   node "$HOME\.copilot\extensions\copilot-bridge\client.mjs" --allow-all
   node "$HOME\.copilot\extensions\copilot-bridge\client.mjs" --deny-all
   ```

   In interactive mode it prints each session's stream and prompts `[a/d/s]` for every permission
   request — type `a` to allow, `d` to deny, or `s` to defer to the session's own local prompt, then
   press Enter. `--allow-all` / `--deny-all` skip the prompt and log the auto-decision instead. The
   client can be any program that speaks the protocol in `CLIENT.md`.

   The mirror stream shows each tool call: `tool?` when a call is requested (with its command/args,
   pending approval) and `tool<` with its result and ok/FAIL when it finishes. It also shows prompts
   (`user:`) and replies (`asst:`).

   To push a message into a running session, type `/say <sessionId> <message>` (the `<sessionId>` is
   the 6-char `[abc123]` tag shown on that session's lines; a prefix is enough) or `/sayall <message>`
   to send to every session.

## Writing a client

A client is any program that connects to `ws://127.0.0.1:47823` and speaks the JSON protocol in
`CLIENT.md`. The `/say` and `/sayall` shortcuts are conveniences of the reference `client.mjs` only —
they are **not** part of the wire protocol. Your own client is expected to:

- **Announce itself once.** Immediately after connecting, send exactly one
  `{ "type": "hello", "role": "client", "data": { "name": "<your-client>" } }`. The role is fixed by
  this first `hello`; the hub ignores any later `hello` and drops messages from a peer that never sent
  one. A client that omits `hello` receives nothing.
- **Consume mirror traffic.** Expect `session.start` / `session.end`, `user.prompt`,
  `assistant.message`, `tool.requested` (a pending call, before approval), and `tool.complete` (with
  its result). Each carries a `sessionId` identifying the source session. Treat unknown `type`s as
  forward-compatible and ignore them.
- **Answer permission requests.** For every `permission.request` (fields `sessionId`, `requestId`,
  `data.toolName`, `data.toolArgs`), reply with a `permission.decision` echoing the same `requestId`
  and a `data.decision` of `allow`, `deny`, or `ask` (`ask` defers to the session's own local prompt).
  Only the **first** client to answer a given `requestId` wins; if no client answers, the session
  falls back locally after the hub timeout. Answering is optional — a client may observe silently.
- **Inject with an explicit envelope, not slash text.** To push a prompt into a session, send
  `{ "type": "inject", "sessionId": "<id>", "data": { "prompt": "<text>" } }`. Do **not** send the raw
  `/say …` line as the prompt — that shorthand belongs to the reference client and would be delivered
  verbatim. Use an exact session id or a prefix that uniquely identifies one session; omit `sessionId`
  to broadcast to all sessions. An empty `sessionId` or an ambiguous prefix is rejected.
- **Stay within the client role.** The hub only accepts `permission.decision` and `inject` from
  clients; it never lets a client inject as, or impersonate, a session. Send well-formed, masked
  WebSocket frames (any standard client library does this) — malformed or oversized frames are
  dropped and the connection is closed.

See `CLIENT.md` for exact message shapes and a minimal example.

## Files

| File           | Role                                                                       |
| -------------- | -------------------------------------------------------------------------- |
| `extension.mjs` | Per-session shim: bootstrap/connect, mirror activity, forward permissions. |
| `hub.mjs`       | Detached hub: WebSocket server, broadcast, permission routing, lifecycle.  |
| `client.mjs`    | Reference terminal client (watch stream + approve permissions).            |
| `README.md`     | This guide.                                                                |
| `CLIENT.md`     | Wire-protocol spec for writing your own client.                            |

## Configuration

- **Port** is fixed at `47823` in `hub.mjs` and `extension.mjs`.
- The client honours `COPILOT_BRIDGE_URL` if you need to point it elsewhere (default
  `ws://127.0.0.1:47823`).
- Timeouts (heartbeat, grace, permission) are constants at the top of `hub.mjs` / `extension.mjs`.

## Troubleshooting

- **Sessions don't see each other** — ensure the `EXTENSIONS` flag is enabled and check `/env`. Each
  session must have loaded `copilot-bridge`.
- **Permission prompts still appear locally** — that is the fallback: it means no client is connected,
  the client answered `ask`, or the request timed out.
- **Port already in use** — another hub (or unrelated process) holds `47823`. A duplicate hub exits on
  its own; if a stray process holds the port, stop it: `Get-NetTCPConnection -LocalPort 47823`.
- **Not every prompt is bridged** — the bridge forwards tool-use permission checks via the
  `onPreToolUse` hook. Some built-in prompts may not route through it and will still ask locally.

## Security

No authentication and no encryption. The hub binds `127.0.0.1` only, but any local process can
connect, observe all session chat, and answer permission requests. Use only on a trusted machine.
