using System.Buffers.Binary;
using System.Security.Cryptography;
using System.Text;

namespace CpTower;

internal sealed class MissionControlDiscovery(
    GitHubCredentials credentials, MissionControlService missionControl,
    HostRegistry registry, ILogger<MissionControlDiscovery> log) {
    private const int RouteRange = 1_000_000_000;
    private const int RouteStart = 1_000_000_000;

    public async Task RefreshAsync(CancellationToken token) {
        var discovered = new List<(MissionControlEnvironment Environment, string GitHubHost)>();
        var refreshed = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var authorities = await credentials.GetHostsAsync(token);
        log.LogDebug("checking {Count} authenticated GitHub host(s) for Mission Control environments",
            authorities.Count);
        var results = await Task.WhenAll(authorities.Select(async authority => {
            try {
                var environments = await missionControl.ListEnvironmentsAsync(authority, token);
                log.LogDebug("Mission Control on {Host} returned {Count} environment(s)",
                    authority, environments.Count);
                return (Authority: authority, Environments: environments, Success: true);
            } catch (Exception ex) when (ex is HttpRequestException or InvalidDataException
                or InvalidOperationException) {
                log.LogWarning("could not discover Mission Control environments on {Host}: {Error}",
                    authority, ex.Message);
                return (Authority: authority, Environments: (IReadOnlyList<MissionControlEnvironment>)[],
                    Success: false);
            }
        }));
        foreach (var result in results.Where(value => value.Success)) {
            refreshed.Add(result.Authority);
            discovered.AddRange(result.Environments
                .Where(value => value.Kind == "user-local" && value.Status == "online")
                .Select(value => (value, result.Authority)));
        }

        var used = registry.Snapshot().Select(value => value.Port).ToHashSet();
        var current = registry.Snapshot().Where(value => !value.IsLocal)
            .ToDictionary(value => (value.MissionControl!.GitHubHost, value.MissionControl.EnvironmentId));
        var live = new HashSet<(string GitHubHost, string EnvironmentId)>();
        foreach (var (environment, authority) in discovered
            .OrderBy(value => value.GitHubHost).ThenBy(value => value.Environment.Id)) {
            var key = (authority, environment.Id);
            live.Add(key);
            var route = current.TryGetValue(key, out var known) ? known.Port
                : Route(authority, environment.Id, used);
            used.Add(route);
            registry.Add(new HostInfo(
                route, 0, environment.Name, environment.Capabilities?.AhpVersion ?? "unknown",
                environment.Capabilities?.CurrentSessions ?? 0, null,
                new MissionControlHost(environment.Id, authority)));
            if (known is null) {
                log.LogInformation(
                    "Mission Control host up: route {Route}, environment {Environment} ({Label})",
                    route, environment.Id, environment.Name);
            }
        }

        foreach (var host in registry.Snapshot().Where(value => value.MissionControl is { } remote
            && refreshed.Contains(remote.GitHubHost)
            && !live.Contains((remote.GitHubHost, remote.EnvironmentId)))) {
            log.LogInformation("Mission Control host gone: environment {Environment} ({Label})",
                host.MissionControl!.EnvironmentId, host.Label);
            registry.Remove(host.Port);
        }
    }

    internal static int Route(string githubHost, string environmentId, ISet<int> used) {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes($"{githubHost}\0{environmentId}"));
        var route = RouteStart + (int)(BinaryPrimitives.ReadUInt32BigEndian(bytes) % RouteRange);
        while (!used.Add(route)) {
            route++;
            if (route == RouteStart + RouteRange) {
                route = RouteStart;
            }
        }
        return route;
    }
}
