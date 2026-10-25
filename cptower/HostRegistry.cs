using System.Collections.Concurrent;

namespace CpTower;

/// <summary>
/// A discovered AHP host routed by cptower's integer <see cref="Port"/> path.
/// </summary>
public sealed record HostInfo(
    int Port, int Pid, string Label, string Protocol, int Sessions, string? Token,
    MissionControlHost? MissionControl = null) {
    public string Id => MissionControl?.EnvironmentId ?? Port.ToString();

    public bool IsLocal => MissionControl is null;
}

public sealed record MissionControlHost(string EnvironmentId, string GitHubHost);

/// <summary>
/// Thread-safe registry shared by direct-listener and Mission Control discovery.
/// </summary>
public sealed class HostRegistry {
    private readonly ConcurrentDictionary<int, HostInfo> hosts = new();

    public IReadOnlyList<HostInfo> Snapshot() => hosts.Values.OrderBy(h => h.Port).ToList();

    public HostInfo? Get(int port) => hosts.TryGetValue(port, out var host) ? host : null;

    public void Add(HostInfo host) => hosts[host.Port] = host;

    public void Remove(int port) => hosts.TryRemove(port, out _);
}
