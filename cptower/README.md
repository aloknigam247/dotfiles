# cptower

**Copilot AHP multiplexer.** A Windows host-side service that discovers every live
[Agent Host Protocol](https://microsoft.github.io/agent-host-protocol/) (AHP) host Copilot is running
on the machine and exposes them all behind **one** port, so the qvim companion app can reach every
session from a single endpoint.

## What it does

- **Discovers** live AHP hosts **when `/hosts` is requested** by enumerating loopback TCP listeners
  owned by `copilot` processes and confirming each with an AHP 0.9 `initialize` handshake. The app hits
  `/hosts` right before it connects, so this point-in-time scan is enough and cptower does not probe
  ports in the background. This is authoritative — the lingering `~/.copilot/logs/ahp-host-*.log`
  files are not (they outlive dead hosts and miss interactively-started ones), so they are used only
  to enrich a host's label. Hosts started with `/ahp start` are only found once their connection
  token is shared (see [Token-protected hosts](#token-protected-hosts-ahp-start)).
- **Routes** WebSocket traffic: a client connecting to `ws://<cptower>:8770/ws/<port>` is bridged to
  the loopback AHP host on `<port>` by a small relay. For a token-protected host the relay adds the
  shared token (`?tkn=`) upstream, so clients never need it.
- **Signs clients in**: a host refuses to let an unauthenticated client subscribe to or steer a session
  (`AuthRequired`, `-32007`). Once the host answers a client's `initialize`, the relay sends
  `authenticate` with a GitHub CLI token (`gh auth token --hostname github.com`, for the account given
  by `--github-user` or else gh's active one; `Start-CpTower` passes `aloknigam_microsoft`) and hides
  the reply, so the qvim app can send messages without a GitHub login of its own. A host binds to the
  first GitHub account that signs in to it and refuses any other (`-32009`), so to switch accounts
  restart the host (`/ahp restart`, or `/ahp stop` then `/ahp start`) and update its line in `hosts.url`.
- **Advertises** the catalog at `GET /hosts` — a JSON array of `{ id, port, label, protocol,
  sessions }`, one entry per live host.
- **Manages its own firewall rule** ("cptower", inbound TCP on the chosen port), self-elevating once
  via UAC if the rule is missing.

## Run

Requires the .NET 9 SDK, and the GitHub CLI (`gh`) signed in to github.com for the sign-in above.

```ps1
dotnet run -c Release                           # listens on 0.0.0.0:8770
dotnet run -c Release -- --port 9000            # override the port
dotnet run -c Release -- --github-user <login>  # sign clients in as this gh account
```

Single-file publish for deployment to another machine:

```ps1
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true
```

To run at logon, register the published exe as a Task Scheduler task triggered "At log on" (this also
avoids a repeated UAC prompt if the firewall rule already exists).

## Endpoints

| Route            | Purpose                                                        |
| ---------------- | ------------------------------------------------------------- |
| `GET /hosts`     | JSON catalog of discovered AHP hosts.                         |
| `ws /ws/{port}`  | WebSocket bridge to the loopback AHP host on `{port}`.        |

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
| `AhpProbe.cs`         | AHP 0.9 `initialize` + `listSessions` handshake to confirm a host.  |
| `HostTokens.cs`       | Reads and prunes the connect URLs in `$XDG_CONFIG_HOME/cptower/hosts.url`. |
| `HostRegistry.cs`     | Thread-safe registry of live hosts.                                 |
| `DiscoveryService.cs` | On-demand reconcile (enumerate → probe → register → prune `hosts.url`), run from `/hosts`. |
| `AhpRelay.cs`         | `/ws/{port}` WebSocket relay: adds `tkn`, signs the client in with the GitHub CLI token. |
| `FirewallManager.cs`  | Idempotent, self-elevating inbound firewall rule.                   |

## Security

cptower exposes the discovered hosts to the LAN with no authentication of its own: it attaches each
host's shared connection token (stored in plain text in `hosts.url`) and signs every client that
reaches it in as your GitHub CLI account. Anyone who can reach port 8770 can therefore read and steer
your shared sessions as you. Only run it on a trusted network.
