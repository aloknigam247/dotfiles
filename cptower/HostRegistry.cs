using System.Collections.Concurrent;

namespace CpTower;

/// <summary>A discovered, live AHP host reachable on a loopback port.</summary>
public sealed record HostInfo(int Port, string Label, string Protocol, int Sessions)
{
    /// <summary>Stable id the app uses to build the routed path `/ws/{id}`.</summary>
    public string Id => Port.ToString();
}

/// <summary>
/// Thread-safe registry of the currently live hosts. The discovery service is the sole writer;
/// the HTTP endpoint and proxy-config updater read snapshots.
/// </summary>
public sealed class HostRegistry
{
    private readonly ConcurrentDictionary<int, HostInfo> hosts = new();

    /// <summary>Raised (with the full current snapshot) whenever a host is added or removed.</summary>
    public event Action<IReadOnlyList<HostInfo>>? Changed;

    public IReadOnlyList<HostInfo> Snapshot() => hosts.Values.OrderBy(h => h.Port).ToList();

    public bool Contains(int port) => hosts.ContainsKey(port);

    public void Add(HostInfo host)
    {
        hosts[host.Port] = host;
        Changed?.Invoke(Snapshot());
    }

    public void Remove(int port)
    {
        if (hosts.TryRemove(port, out _))
        {
            Changed?.Invoke(Snapshot());
        }
    }
}
