using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

namespace CpTower;

/// <summary>
/// Confirms a loopback port is a live AHP host by running the minimal client handshake
/// (initialize, then listSessions) and extracting a human label from the reported sessions.
/// A port owned by copilot that answers initialize is authoritative proof it is an AHP host,
/// which the lingering ahp-host-*.log files are not.
/// </summary>
internal static class AhpProbe
{
    public readonly record struct Result(bool Ok, string? Protocol, string? Label, int Sessions);

    public static async Task<Result> ProbeAsync(int port, CancellationToken outer)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(outer);
        cts.CancelAfter(TimeSpan.FromSeconds(4));
        var token = cts.Token;

        using var ws = new ClientWebSocket();
        ws.Options.KeepAliveInterval = TimeSpan.Zero;
        try
        {
            await ws.ConnectAsync(new Uri($"ws://127.0.0.1:{port}/"), token);

            await SendAsync(ws, new
            {
                jsonrpc = "2.0",
                id = 1,
                method = "initialize",
                @params = new
                {
                    protocolVersions = new[] { "0.9.0", "0.7.0" },
                    clientInfo = new { name = "cptower", version = "1.0" },
                    capabilities = new { },
                },
            }, token);

            string? protocol = null;
            string? label = null;
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
                    await SendAsync(ws, new { jsonrpc = "2.0", id = 2, method = "listSessions", @params = new { } }, token);
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
            return new Result(protocol is not null, protocol, label, sessions);
        }
        catch (Exception)
        {
            return new Result(false, null, null, 0);
        }
    }

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
