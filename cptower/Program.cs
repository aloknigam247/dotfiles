using CpTower;

string? githubUser = null;
var installFirewall = false;
var port = 8770;
for (var i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--github-user" when i + 1 < args.Length:
            githubUser = args[i + 1];
            i++;
            break;
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
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

builder.Services.AddSingleton(sp => new AhpRelay(githubUser, sp.GetRequiredService<ILogger<AhpRelay>>()));
builder.Services.AddSingleton<HostRegistry>();
builder.Services.AddSingleton<DiscoveryService>();

var app = builder.Build();

FirewallManager.Ensure(port, app.Logger);

app.UseWebSockets();

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

// Only hosts discovered by `/hosts` are bridged, as the app fetches the catalog before connecting.
app.Map("/ws/{hostPort:int}/{**path}", async (HttpContext context, int hostPort, string? path, HostRegistry registry, AhpRelay relay) =>
{
    if (registry.Get(hostPort) is not { } host)
    {
        context.Response.StatusCode = StatusCodes.Status404NotFound;
        return;
    }

    await relay.RelayAsync(context, host, path ?? "");
});

app.Logger.LogInformation("cptower listening on http://0.0.0.0:{Port}  (GET /hosts, ws /ws/{{port}}), signing clients in as {Account}",
    port, githubUser ?? "the GitHub CLI's active account");
app.Run();
return 0;
