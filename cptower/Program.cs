using CpTower;
using Yarp.ReverseProxy.Configuration;

var port = 8770;
var installFirewall = false;
for (var i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--install-firewall":
            installFirewall = true;
            break;
        case "--port" when i + 1 < args.Length && int.TryParse(args[i + 1], out var p):
            port = p;
            i++;
            break;
    }
}

if (installFirewall)
{
    return FirewallManager.AddRule(port);
}

var builder = WebApplication.CreateBuilder(args);
builder.Logging.AddSimpleConsole(o => o.TimestampFormat = "HH:mm:ss ");
// YARP logs every proxied destination URL, which carries a host's connection token.
builder.Logging.AddFilter("Yarp", LogLevel.Warning);
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

builder.Services.AddSingleton<HostRegistry>();
builder.Services.AddSingleton<DiscoveryService>();
builder.Services.AddHostedService<ProxyRoutes>();
builder.Services.AddReverseProxy().LoadFromMemory(new List<RouteConfig>(), new List<ClusterConfig>());

var app = builder.Build();

FirewallManager.Ensure(port, app.Logger);

app.MapGet("/hosts", async (HostRegistry registry, DiscoveryService discovery, CancellationToken ct) =>
{
    await discovery.RefreshAsync(ct);
    return Results.Json(registry.Snapshot().Select(h => new
    {
        id = h.Id,
        port = h.Port,
        label = h.Label,
        protocol = h.Protocol,
        sessions = h.Sessions,
    }));
});

app.MapReverseProxy();

app.Logger.LogInformation("cptower listening on http://0.0.0.0:{Port}  (GET /hosts, ws /ws/{{port}})", port);
app.Run();
return 0;
