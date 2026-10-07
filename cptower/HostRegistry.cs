using System.Collections.Concurrent;

namespace CpTower;

/// <summary>
/// A discovered, live AHP host reachable on a loopback port. <see cref="Pid"/> is the copilot process
/// that owned the listener when it was probed, and <see cref="Token"/> the shared connection token the
/// host accepted (null when it needs none); neither is advertised by `/hosts`.
/// </summary>
public sealed record HostInfo(int Port, int Pid, string Label, string Protocol, int Sessions, string? Token)
{
    /// <summary>Stable id the app uses to build the routed path `/ws/{id}`.</summary>
    public string Id => Port.ToString();
}

/// <summary>
/// Thread-safe registry of the currently live hosts. The discovery service is the sole writer;
/// the `/hosts` endpoint and the WebSocket relay read it.
/// </summary>
public sealed class HostRegistry
{
    private readonly ConcurrentDictionary<int, HostInfo> hosts = new();

    public IReadOnlyList<HostInfo> Snapshot() => hosts.Values.OrderBy(h => h.Port).ToList();

    public HostInfo? Get(int port) => hosts.TryGetValue(port, out var host) ? host : null;

    /// <summary>Adds or replaces the host on its port.</summary>
    public void Add(HostInfo host) => hosts[host.Port] = host;

    public void Remove(int port) => hosts.TryRemove(port, out _);
}
