# copilot-bridge — agent guide

Guidance for AI agents editing this extension. For the wire protocol see `CLIENT.md`. Keep both in
sync when behavior changes.

## What this is

A local, no-auth WebSocket bridge across GitHub Copilot CLI sessions. Three parts:

- `hub.mjs` — detached, zero-dependency server. Hand-rolled RFC 6455 (no `ws` package). The TCP
  port is the lock: first binder is the hub, a loser exits on `EADDRINUSE`. Self-terminates
  `GRACE_MS` after the last peer leaves. Validates roles, handshake, and every decoded frame.
- `extension.mjs` — per-session shim loaded by the CLI (one process per session). Bootstraps the
  hub if absent, then mirrors this session's activity and forwards permission checks. Sessions are
  **producer-only**: they send activity and receive decisions/injects, but never consume mirror
  traffic.
- `client.mjs` — reference terminal client (watch stream, answer `[a/d/s]` prompts, `/say`).

## Roles and trust model

- Two peer roles, fixed by the first `hello`: `session` and `client`.
- The hub only honors `permission.request` + mirror activity from **sessions**, and
  `permission.decision` + `inject` from **clients**. Never route a message that lets one role act as
  the other — this separation is load-bearing, not cosmetic.
- Loopback-only, no auth. Assume any local peer may be buggy or hostile: validate before trusting.
  Preserve the frame validation, size ceilings, and role gating in `hub.mjs`.

## Conventions

- **ES modules, zero runtime dependencies.** Node built-ins + the global `WebSocket` only; the hub
  additionally speaks raw framing via `node:http`/`node:crypto`. Do **not** add npm dependencies.
- Constants live at the top of each file (`HOST`, `PORT`, `HEARTBEAT_MS`, `GRACE_MS`,
  `PERMISSION_TIMEOUT_MS`, the `MAX_*` ceilings in `hub.mjs`; `HUB_URL`, `BOOTSTRAP_ATTEMPTS`,
  `OUTBOX_MAX`, etc. in `extension.mjs`). Add new tunables there, not inline.
- The port is fixed at `47823` in `hub.mjs`, `extension.mjs`, and `client.mjs`. Keep the hub and
  extension in agreement on the URL.
- Avoid environment variables for configuration. The one exception is
  `COPILOT_BRIDGE_PERMISSION_TIMEOUT_MS`, which `hub.mjs` reads only so `verify.mjs` can shorten the
  permission timeout for its timeout-fallback test.

## Protocol changes

Any change to message `type`s, envelope fields, or routing MUST update `CLIENT.md` and add or adjust
a test in `verify.mjs`. Treat unknown `type`s as forward-compatible
(ignore, don't crash). Current mirror types: `session.start`, `session.end`, `user.prompt`,
`assistant.message`, `tool.requested` (pending, pre-decision), `tool.complete`. Client→hub types:
`permission.decision`, `inject`.

## Testing

`verify.mjs` spawns its own hub and drives the protocol end-to-end (a real `WebSocket` peer plus a
hand-rolled raw client for framing tests). It binds the fixed bridge port, so run it only when no
live session hub is up:

```powershell
node verify.mjs
```

Must be green before you finish. Run `node --check` on any `.mjs` you touch. When you change hub
behavior, add a test rather than loosening an existing one.

## Gotchas

- Extensions run under `copilot.exe`, not `node`. `extension.mjs` resolves a real `node` to spawn the
  detached hub — don't assume `process.execPath` is Node.
- `mySessionId` is declared before `joinSession` on purpose (hooks can fire before the session
  resolves); keep it above the call to avoid a temporal-dead-zone crash.
- Reloading the extension in a session does **not** restart an already-running hub. To pick up hub
  changes, stop the hub process first, then the next session respawns the updated one.
- Slash commands (`/say`, `/sayall`) are a `client.mjs` convenience only — never parse them in the
  hub. Clients inject via an explicit `{ type: "inject", … }` envelope.
