using System.Diagnostics;
using System.Net;

namespace CpTower;

/// <summary>
/// Reconciles the live host set on demand: enumerate loopback listeners owned by the copilot
/// process, probe newly seen ports for AHP, and drop hosts whose listener has gone away. Enriches
/// labels from the `ahp-host-{port}.log` files when the probe did not report a working directory.
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
        var copilotPids = Process.GetProcessesByName("copilot").Select(p => p.Id).ToHashSet();
        var allListeners = TcpTable.Listeners();
        var candidates = allListeners
            .Where(l => IsLoopback(l.Address) && copilotPids.Contains(l.OwningPid))
            .Select(l => l.Port)
            .ToHashSet();

        foreach (var host in registry.Snapshot())
        {
            if (!candidates.Contains(host.Port))
            {
                log.LogInformation("host gone: port {Port} ({Label})", host.Port, host.Label);
                registry.Remove(host.Port);
            }
        }

        foreach (var port in candidates)
        {
            if (registry.Contains(port))
            {
                continue;
            }

            var probe = await AhpProbe.ProbeAsync(port, token);
            if (!probe.Ok)
            {
                continue;
            }

            var label = probe.Label ?? LabelFromLog(port) ?? $"Copilot ({port})";
            registry.Add(new HostInfo(port, label, probe.Protocol ?? "unknown", probe.Sessions));
            log.LogInformation("host up: port {Port} proto {Proto} sessions {Sessions} ({Label})",
                port, probe.Protocol, probe.Sessions, label);
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
