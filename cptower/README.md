# cptower

**Copilot AHP multiplexer.** A Windows host-side service that discovers direct and Mission Control
[Agent Host Protocol](https://microsoft.github.io/agent-host-protocol/) (AHP) hosts and exposes them
behind **one** port, so the qvim companion app can reach every session from a single endpoint.

## What it does

- **Discovers** live AHP hosts **when `/hosts` is requested** by enumerating loopback TCP listeners
  owned by `copilot` processes. It first asks the host which protocol versions it supports, reconnects
  with that list, and reads the session catalog. The app hits `/hosts` right before it connects, so
  this point-in-time scan is enough and cptower does not probe ports in the background.
- **Discovers Mission Control hosts** from each authenticated GitHub account's environment collection.
  Every online `user-local` environment receives a deterministic synthetic integer route, preserving
  the app's existing `/ws/<port>` contract without storing or configuring environment IDs.
- **Routes** WebSocket traffic: a client connecting to `ws://<cptower>:8770/ws/<port>` is bridged to
  either the loopback AHP listener or its Mission Control environment. Direct token-protected hosts
  receive their shared `?tkn=` token upstream. Mission Control traffic uses Azure Web PubSub's reliable
  JSON protocol, including group membership, chunking, acknowledgements, and reconnect recovery.
- **Signs clients in**: before returning the client's successful `initialize`, cptower reads the
  host-advertised protected resource and obtains a credential for that GitHub host. It accepts
  `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN` when `COPILOT_GH_HOST` or `GH_HOST` identifies
  the same host; otherwise it calls `gh auth token --hostname <host>`. If the host requires encrypted
  credentials, cptower uses its advertised connection challenge and X25519 sealed-box key. The client
  receives an explicit AHP error if authentication fails instead of starting an unusable session.
- **Advertises** the catalog at `GET /hosts` — a JSON array of `{ id, port, label, protocol,
  sessions }`, one entry per live host.
- **Manages its own firewall rule** ("cptower", inbound TCP on the chosen port), self-elevating once
  via UAC if the rule is missing.

## Run

Requires the .NET 9 SDK and GitHub CLI (`gh`) credentials for each GitHub host to discover Mission
Control environments and authenticate clients. A matching `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or
`GITHUB_TOKEN` can be used when `COPILOT_GH_HOST` or `GH_HOST` explicitly names its GitHub host.

```ps1
dotnet run -c Release                           # listens on 0.0.0.0:8770
dotnet run -c Release -- --port 9000            # override the port
dotnet run -c Release -- --github-user <login>  # choose this gh login on each advertised host
```

`Start-CpTower` logs stdout and stderr to `cptower.log` beside
[`hosts.url`](#token-protected-hosts-ahp-start). Each new process overwrites the log; calling it while
cptower is already running leaves the log intact.

Framework-dependent single-file publish used for `dist/cptower.exe`:

```ps1
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
```

To run at logon, register the published exe as a Task Scheduler task triggered "At log on" (this also
avoids a repeated UAC prompt if the firewall rule already exists).

## Endpoints

| Route            | Purpose                                                            |
| ---------------- | ------------------------------------------------------------------ |
| `GET /hosts`     | JSON catalog of direct and online user-local Mission Control hosts. |
| `ws /ws/{port}`  | WebSocket bridge to the catalog entry's integer route.              |

## Token-protected hosts (`/ahp start`)

A host started from an interactive session with `/ahp start` rejects every connection (HTTP 401)
whose URL lacks its connection token — a random value printed once in the `/ahp start` output and
stored nowhere cptower can read. Share it by adding the host's connect URL (the
`ws://127.0.0.1:<port>/?tkn=<token>` part of the `Connect:` line) as a line of
`$XDG_CONFIG_HOME/cptower/hosts.url` (default `~/.config/cptower/hosts.url`):

```text
# one connect URL per line; its port maps the token to the host
ws://127.0.0.1:54687/?tkn=<token>
```

The connection token only opens that local WebSocket. Keep it in `hosts.url`; GitHub authentication
is a separate step and its token must never be written to this file.

cptower re-reads the file on every `/hosts`, probes each port with its listed tokens (last line first)
and then without one, and in the same pass removes the lines that are no longer live, leaving comments
and other lines as they are:

- lines whose port no longer has a `copilot` listener (the CLI exited or ran `/ahp stop`);
- lines whose token the host rejects;
- lines that another listed token for the same port supersedes (a host has a single token).

The file is changed only while answering `/hosts`; there is no background check. Known hosts are
re-probed each time, so a listener restarted on the same port with a new token is caught too.
Deleting a line yourself stops cptower sharing that host from the next `/hosts`. A pass that finds the
file changed since it read it skips the write, so an edit you save meanwhile is never overwritten. Add
a line only after `/ahp start`, since a line for a port nothing listens on is removed on the next
`/hosts`. cptower resolves the path from its own environment, so it must see the same
`XDG_CONFIG_HOME` you use; `Start-CpTower` launches it from the profile, which sets it.

## Files

| File                  | Purpose                                                              |
| --------------------- | ------------------------------------------------------------------- |
| `Program.cs`          | Entry point: arg parse, Kestrel, DI wiring, `/hosts`, `/ws/{port}` mapping. |
| `TcpTable.cs`         | P/Invoke `GetExtendedTcpTable` → loopback listeners with owning PID. |
| `AhpAuthentication.cs` | Validates host auth metadata and seals GitHub credentials.          |
| `AhpConnection.cs`  | Common direct/remote AHP connection surface.                       |
| `AhpEnvelopeCodec.cs` | AHP payload chunking and reassembly inside Web PubSub messages.   |
| `AhpProbe.cs`         | Host-version negotiation and `listSessions` discovery handshake.    |
| `HostTokens.cs`       | Reads and prunes the connect URLs in `$XDG_CONFIG_HOME/cptower/hosts.url`. |
| `HostRegistry.cs`     | Thread-safe registry of live hosts.                                 |
| `GitHubCredentials.cs` | Resolves a credential for each host-advertised GitHub authority.   |
| `DiscoveryService.cs` | On-demand reconcile (enumerate → probe → register → prune `hosts.url`), run from `/hosts`. |
| `AhpRelay.cs`         | `/ws/{port}` WebSocket relay: adds `tkn`, signs the client in with the GitHub CLI token. |
| `MissionControl.cs`   | Mission Control environment discovery and connection credentials.   |
| `MissionControlAhpConnection.cs` | Reliable Web PubSub transport for AHP payloads.          |
| `MissionControlDiscovery.cs` | Online user-local environment catalog and synthetic routes.  |
| `FirewallManager.cs`  | Idempotent, self-elevating inbound firewall rule.                   |

## Security

cptower exposes the discovered hosts to the LAN with no authentication of its own: it attaches direct
hosts' shared connection tokens, obtains Mission Control connection credentials, and signs every client
in with your matching GitHub credential. Anyone who can reach port 8770 can therefore read and steer
your shared sessions as you. Only run it on a trusted network.
