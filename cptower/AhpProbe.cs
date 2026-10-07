using System.Net;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

namespace CpTower;

/// <summary>
/// Confirms a loopback port is a live AHP host by running the minimal client handshake
/// (initialize, then listSessions, both on the AHP 0.9 root channel) and extracting a human label
/// from the reported sessions. Hosts started with `/ahp start` reject the upgrade (401) unless the
/// URL carries their connection token as `?tkn=`. A port owned by copilot that answers initialize is
/// authoritative proof it is an AHP host, which the lingering ahp-host-*.log files are not.
/// </summary>
internal static class AhpProbe
{
    private const string RootChannel = "ahp-root://";

    public readonly record struct Result(bool Ok, string? Protocol, string? Label, int Sessions, bool Unauthorized = false);

    public static async Task<Result> ProbeAsync(int port, string? connectionToken, CancellationToken outer)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(outer);
        cts.CancelAfter(TimeSpan.FromSeconds(4));
        var token = cts.Token;

        using var ws = new ClientWebSocket();
        ws.Options.CollectHttpResponseDetails = true;
        ws.Options.KeepAliveInterval = TimeSpan.Zero;
        try
        {
            await ws.ConnectAsync(HostUri(port, connectionToken), token);

            await SendAsync(ws, new
            {
                jsonrpc = "2.0",
                id = 1,
                method = "initialize",
                @params = new
                {
                    channel = RootChannel,
                    clientId = $"cptower-{Guid.NewGuid():N}",
                    protocolVersions = new[] { "0.9.0", "0.7.0" },
                    clientInfo = new { name = "cptower", version = "1.0" },
                    capabilities = new { },
                },
            }, token);

            string? defaultDirectory = null;
            string? label = null;
            string? protocol = null;
            var sessions = 0;

            while (true)
            {
                using var doc = await ReceiveAsync(ws, token);
                if (doc is null)
                {
                    break;
                }

                var root = doc.RootElement;
                if (!root.TryGetProperty("id", out var idEl))
                {
                    continue;
                }

                var id = idEl.GetInt32();
                if (id == 1)
                {
                    if (!root.TryGetProperty("result", out var res))
                    {
                        return new Result(false, null, null, 0);
                    }

                    protocol = res.TryGetProperty("protocolVersion", out var pv) ? pv.GetString() : null;
                    defaultDirectory = res.TryGetProperty("defaultDirectory", out var dd) && dd.ValueKind == JsonValueKind.String
                        ? dd.GetString()
                        : null;
                    await SendAsync(ws, new
                    {
                        jsonrpc = "2.0",
                        id = 2,
                        method = "listSessions",
                        @params = new { channel = RootChannel },
                    }, token);
                }
                else if (id == 2)
                {
                    if (root.TryGetProperty("result", out var res) && res.TryGetProperty("items", out var items))
                    {
                        sessions = items.GetArrayLength();
                        label = LabelFrom(items);
                    }

                    break;
                }
            }

            await CloseQuietly(ws);
            return new Result(protocol is not null, protocol, DisplayPath(label ?? defaultDirectory), sessions);
        }
        catch (Exception)
        {
            return new Result(false, null, null, 0, ws.HttpStatusCode == HttpStatusCode.Unauthorized);
        }
    }

    private static Uri HostUri(int port, string? connectionToken) => connectionToken is null
        ? new Uri($"ws://127.0.0.1:{port}/")
        : new Uri($"ws://127.0.0.1:{port}/?tkn={Uri.EscapeDataString(connectionToken)}");

    /// <summary>AHP 0.9 reports directories as `file://` URIs; show them as local paths.</summary>
    private static string? DisplayPath(string? value) =>
        value is not null && Uri.TryCreate(value, UriKind.Absolute, out var uri) && uri.IsFile ? uri.LocalPath : value;

    private static async Task CloseQuietly(ClientWebSocket ws)
    {
        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(1));
            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, null, cts.Token);
        }
        catch
        {
            // The AHP host closes its side without a proper close handshake; ignore.
        }
    }

    private static string? LabelFrom(JsonElement items)
    {
        foreach (var item in items.EnumerateArray())
        {
            if (item.TryGetProperty("workingDirectories", out var dirs) && dirs.GetArrayLength() > 0)
            {
                return dirs[0].GetString();
            }

            if (item.TryGetProperty("title", out var title))
            {
                return title.GetString();
            }
        }

        return null;
    }

    private static async Task SendAsync(ClientWebSocket ws, object payload, CancellationToken token)
    {
        var bytes = JsonSerializer.SerializeToUtf8Bytes(payload);
        await ws.SendAsync(bytes, WebSocketMessageType.Text, true, token);
    }

    private static async Task<JsonDocument?> ReceiveAsync(ClientWebSocket ws, CancellationToken token)
    {
        var buffer = new byte[16 * 1024];
        using var ms = new MemoryStream();
        WebSocketReceiveResult res;
        do
        {
            res = await ws.ReceiveAsync(buffer, token);
            if (res.MessageType == WebSocketMessageType.Close)
            {
                return null;
            }

            ms.Write(buffer, 0, res.Count);
        }
        while (!res.EndOfMessage);

        return JsonDocument.Parse(Encoding.UTF8.GetString(ms.ToArray()));
    }
}
