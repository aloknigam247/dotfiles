# cptower

**Copilot AHP multiplexer.** A Windows host-side service that discovers every live
[Agent Host Protocol](https://microsoft.github.io/agent-host-protocol/) (AHP) host Copilot is running
on the machine and exposes them all behind **one** port, so the qvim companion app can reach every
session from a single endpoint.

## What it does

- **Discovers** live AHP hosts **when `/hosts` is requested** by enumerating loopback TCP listeners
  owned by `copilot` processes and confirming each with an AHP `initialize` handshake. The app hits
  `/hosts` right before it connects, so this point-in-time scan is enough and cptower does not probe
  ports in the background. This is authoritative — the lingering `~/.copilot/logs/ahp-host-*.log`
  files are not (they outlive dead hosts and miss interactively-started ones), so they are used only
  to enrich a host's label.
- **Routes** WebSocket traffic: a client connecting to `ws://<cptower>:8770/ws/<port>` is bridged to
  the loopback AHP host on `<port>` via a YARP reverse proxy with dynamic in-memory routes.
- **Advertises** the catalog at `GET /hosts` — a JSON array of `{ id, port, label, protocol,
  sessions }`, one entry per live host.
- **Manages its own firewall rule** ("cptower", inbound TCP on the chosen port), self-elevating once
  via UAC if the rule is missing.

## Run

Requires the .NET 9 SDK.

```ps1
dotnet run -c Release                 # listens on 0.0.0.0:8770
dotnet run -c Release -- --port 9000  # override the port
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

## Files

| File                  | Purpose                                                              |
| --------------------- | ------------------------------------------------------------------- |
| `Program.cs`          | Entry point: arg parse, Kestrel, DI wiring, `/hosts`, YARP mapping. |
| `TcpTable.cs`         | P/Invoke `GetExtendedTcpTable` → loopback listeners with owning PID. |
| `AhpProbe.cs`         | AHP `initialize` + `listSessions` handshake to confirm a host.      |
| `HostRegistry.cs`     | Thread-safe registry of live hosts with a change event.             |
| `DiscoveryService.cs` | On-demand reconcile (enumerate → probe → register), run from `/hosts`.    |
| `ProxyRoutes.cs`      | Keeps YARP's in-memory routes in sync with the registry.            |
| `FirewallManager.cs`  | Idempotent, self-elevating inbound firewall rule.                   |

## Security

`copilot --ahp-host` has no authentication, and cptower exposes the discovered hosts to the LAN. Only
run it on a trusted network.
