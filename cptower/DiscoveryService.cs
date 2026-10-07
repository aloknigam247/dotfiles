using System.Diagnostics;
using System.Net;

namespace CpTower;

/// <summary>
/// Reconciles the live host set on demand: enumerate loopback listeners owned by the copilot
/// process, probe each for AHP, and drop hosts whose listener has gone away. Ports that require a
/// connection token are probed with the tokens listed for them in <see cref="HostTokens"/>, and the
/// lines that are no longer live are pruned from that file: those whose port lost its copilot listener,
/// whose token the host rejects, or that another listed token supersedes. Enriches labels from the
/// `ahp-host-{port}.log` files when the probe did not report a working directory. Discovery, including
/// the pruning, runs only when <see cref="RefreshAsync"/> is called (the app hits `/hosts` right before
/// it connects), so cptower neither probes ports nor edits the file in the background.
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
        var dead = new HashSet<HostTokens.Entry>();
        var candidates = CopilotListeners();
        var sharedTokens = HostTokens.Load();

        foreach (var host in registry.Snapshot())
        {
            // A new owning process or a deleted line means the port no longer serves the shared host.
            if (!candidates.TryGetValue(host.Port, out var pid)
                || pid != host.Pid
                || (host.Token is not null && !sharedTokens[host.Port].Contains(host.Token)))
            {
                log.LogInformation("host gone: port {Port} ({Label})", host.Port, host.Label);
                registry.Remove(host.Port);
            }
        }

        // Known hosts are re-probed too, which catches a listener restarted on its port with a new token.
        foreach (var (port, pid) in candidates)
        {
            string? accepted = null;
            var probe = default(AhpProbe.Result);
            var listed = sharedTokens[port].ToList();
            string?[] attempts = [.. listed.OfType<string>().Distinct(), null];
            foreach (var attempt in attempts)
            {
                probe = await AhpProbe.ProbeAsync(port, attempt, token);
                if (probe.Ok)
                {
                    accepted = attempt;
                    break;
                }

                if (probe.Unauthorized)
                {
                    dead.Add(new(port, attempt));
                }
            }

            if (probe.Ok)
            {
                // A host has a single connection token, so every other line for its port is stale.
                if (accepted is not null)
                {
                    dead.UnionWith(listed.Where(t => t != accepted).Select(t => new HostTokens.Entry(port, t)));
                }

                Register(port, pid, probe, accepted);
                continue;
            }

            // A known host survives a transient failure; it is dropped once the host rejects its token.
            if (registry.Get(port) is { } stale && dead.Contains(new(port, stale.Token)))
            {
                log.LogInformation("host gone: port {Port} ({Label})", port, stale.Label);
                registry.Remove(port);
            }

            // The last attempt carries no token, so a refusal means the port needs one that is not listed.
            if (probe.Unauthorized)
            {
                log.LogInformation("port {Port} requires a connection token; add its /ahp start connect URL to {File}",
                    port, HostTokens.FilePath);
            }
        }

        PruneLines(dead);
    }

    /// <summary>Maps each loopback port a copilot process listens on to that process id.</summary>
    private static Dictionary<int, int> CopilotListeners()
    {
        var allListeners = TcpTable.Listeners();
        var copilotPids = Process.GetProcessesByName("copilot").Select(p => p.Id).ToHashSet();
        return allListeners
            .Where(l => IsLoopback(l.Address) && copilotPids.Contains(l.OwningPid))
            .GroupBy(l => l.Port)
            .ToDictionary(g => g.Key, g => g.First().OwningPid);
    }

    private void Register(int port, int pid, AhpProbe.Result probe, string? connectionToken)
    {
        var known = registry.Get(port);
        var label = probe.Label ?? LabelFromLog(port) ?? $"Copilot ({port})";
        registry.Add(new HostInfo(port, pid, label, probe.Protocol ?? "unknown", probe.Sessions, connectionToken));
        if (known is null || known.Token != connectionToken)
        {
            log.LogInformation("host up: port {Port} proto {Proto} sessions {Sessions} token {Token} ({Label})",
                port, probe.Protocol, probe.Sessions, connectionToken is null ? "none" : "shared", label);
        }
    }

    /// <summary>
    /// Removes the hosts.url lines in <paramref name="dead"/> and those whose port has no copilot
    /// listener. The listener table is read only after the file (and only if it holds a connection
    /// line), so a line saved for a host started during this pass is kept.
    /// </summary>
    private void PruneLines(HashSet<HostTokens.Entry> dead)
    {
        try
        {
            Dictionary<int, int>? live = null;
            var removed = HostTokens.Prune(e => dead.Contains(e) || !(live ??= CopilotListeners()).ContainsKey(e.Port));
            if (removed.Count > 0)
            {
                log.LogInformation("removed {Count} stale line(s) for port(s) {Ports} from {File}",
                    removed.Count, string.Join(", ", removed.Select(e => e.Port).Distinct()), HostTokens.FilePath);
            }
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
        {
            log.LogWarning("could not prune {File}: {Error}", HostTokens.FilePath, ex.Message);
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
