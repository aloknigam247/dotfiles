using Yarp.ReverseProxy.Configuration;

namespace CpTower;

/// <summary>
/// Keeps the YARP route/cluster table in sync with the live host registry. Each host gets a route
/// matching `/ws/{port}` that forwards the WebSocket upgrade to `http://127.0.0.1:{port}/`, so the
/// app reaches every host through the single external port by path alone.
/// </summary>
public sealed class ProxyRoutes(InMemoryConfigProvider provider, HostRegistry registry) : IHostedService
{
    public Task StartAsync(CancellationToken cancellationToken)
    {
        registry.Changed += Apply;
        Apply(registry.Snapshot());
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        registry.Changed -= Apply;
        return Task.CompletedTask;
    }

    private void Apply(IReadOnlyList<HostInfo> hosts)
    {
        var routes = new List<RouteConfig>();
        var clusters = new List<ClusterConfig>();

        foreach (var host in hosts)
        {
            var clusterId = $"c{host.Port}";
            routes.Add(new RouteConfig
            {
                RouteId = $"r{host.Port}",
                ClusterId = clusterId,
                Match = new RouteMatch { Path = $"/ws/{host.Port}/{{**catchall}}" },
                Transforms = new[] { new Dictionary<string, string> { ["PathPattern"] = "/{**catchall}" } },
            });
            routes.Add(new RouteConfig
            {
                RouteId = $"r{host.Port}-root",
                ClusterId = clusterId,
                Match = new RouteMatch { Path = $"/ws/{host.Port}" },
                Transforms = new[] { new Dictionary<string, string> { ["PathPattern"] = "/" } },
            });
            clusters.Add(new ClusterConfig
            {
                ClusterId = clusterId,
                Destinations = new Dictionary<string, DestinationConfig>
                {
                    ["d1"] = new DestinationConfig { Address = $"http://127.0.0.1:{host.Port}/" },
                },
            });
        }

        provider.Update(routes, clusters);
    }
}
