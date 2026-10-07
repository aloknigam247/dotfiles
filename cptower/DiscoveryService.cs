using System.Diagnostics;
using System.Net;

namespace CpTower;

/// <summary>
/// Reconciles the live host set on demand: enumerate loopback listeners owned by the copilot
/// process, probe newly seen ports for AHP, and drop hosts whose listener has gone away. Ports that
/// require a connection token are probed with the tokens shared for them in <see cref="HostTokens"/>.
/// Enriches labels from the `ahp-host-{port}.log` files when the probe did not report a working directory.
/// Discovery runs only when <see cref="RefreshAsync"/> is called (the app hits `/hosts` right before
/// it connects), so cptower does not probe ports in the background.
/// </summary>
public sealed class DiscoveryService(HostRegistry registry, ILogger<DiscoveryService> log)
{
    private static readonly string LogDir =
        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".copilot", "logs");

    private readonly SemaphoreSlim gate = new(1, 1);

    /// <summary>Runs one reconciliation pass, serialized so concurrent `/hosts` calls share the work.</summary>
    public async Task RefreshAsync(CancellationToken token)
    {
        await gate.WaitAsync(token);
        try
        {
            await ReconcileAsync(token);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            log.LogWarning(ex, "discovery refresh failed");
        }
        finally
        {
            gate.Release();
        }
    }

    private async Task ReconcileAsync(CancellationToken token)
    {
        var allListeners = TcpTable.Listeners();
        var copilotPids = Process.GetProcessesByName("copilot").Select(p => p.Id).ToHashSet();
        var candidates = allListeners
            .Where(l => IsLoopback(l.Address) && copilotPids.Contains(l.OwningPid))
            .GroupBy(l => l.Port)
            .ToDictionary(g => g.Key, g => g.First().OwningPid);
        var sharedTokens = HostTokens.Load();

        foreach (var host in registry.Snapshot())
        {
            // A new owning process or a withdrawn token means the port no longer serves the probed host.
            if (!candidates.TryGetValue(host.Port, out var pid)
                || pid != host.Pid
                || (host.Token is not null && !sharedTokens[host.Port].Contains(host.Token)))
            {
                log.LogInformation("host gone: port {Port} ({Label})", host.Port, host.Label);
                registry.Remove(host.Port);
            }
        }

        foreach (var (port, pid) in candidates)
        {
            if (registry.Contains(port))
            {
                continue;
            }

            string? connectionToken = null;
            var probe = default(AhpProbe.Result);
            string?[] attempts = [.. sharedTokens[port], null];
            foreach (var attempt in attempts)
            {
                probe = await AhpProbe.ProbeAsync(port, attempt, token);
                if (probe.Ok)
                {
                    connectionToken = attempt;
                    break;
                }
            }

            if (!probe.Ok)
            {
                if (probe.Unauthorized)
                {
                    log.LogInformation("port {Port} requires a connection token; add its /ahp start connect URL to {File}",
                        port, HostTokens.FilePath);
                }

                continue;
            }

            var label = probe.Label ?? LabelFromLog(port) ?? $"Copilot ({port})";
            registry.Add(new HostInfo(port, pid, label, probe.Protocol ?? "unknown", probe.Sessions, connectionToken));
            log.LogInformation("host up: port {Port} proto {Proto} sessions {Sessions} token {Token} ({Label})",
                port, probe.Protocol, probe.Sessions, connectionToken is null ? "none" : "shared", label);
        }
    }

    private static bool IsLoopback(IPAddress addr) => IPAddress.IsLoopback(addr);

    private static string? LabelFromLog(int port)
    {
        try
        {
            var path = Path.Combine(LogDir, $"ahp-host-{port}.log");
            if (!File.Exists(path))
            {
                return null;
            }

            var first = File.ReadLines(path).FirstOrDefault();
            const string marker = " for ";
            var idx = first?.LastIndexOf(marker, StringComparison.Ordinal) ?? -1;
            return idx >= 0 ? first![(idx + marker.Length)..].Trim() : null;
        }
        catch
        {
            return null;
        }
    }
}
