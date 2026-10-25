using System.Net;
using System.Net.WebSockets;
using System.Text.Json;

namespace CpTower;

/// <summary>
/// Confirms an AHP listener using its advertised protocol versions and session catalog.
/// </summary>
internal static class AhpProbe {
    private const string RootChannel = "ahp-root://";

    public readonly record struct Result(
        bool Ok, string? Protocol, string? Label, int Sessions, bool Unauthorized = false, string? Error = null);

    public static async Task<Result> ProbeAsync(int port, string? connectionToken, CancellationToken outer) {
        string[] versions = [];
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(outer);
        cts.CancelAfter(TimeSpan.FromSeconds(4));
        var token = cts.Token;

        for (var attempt = 0; attempt < 2; attempt++) {
            using var ws = new ClientWebSocket();
            ws.Options.CollectHttpResponseDetails = true;
            ws.Options.KeepAliveInterval = TimeSpan.Zero;
            try {
                await ws.ConnectAsync(HostUri(port, connectionToken), token);
                await SendAsync(ws, new {
                    id = 1,
                    jsonrpc = "2.0",
                    method = "initialize",
                    @params = new {
                        channel = RootChannel,
                        clientId = $"cptower-{Guid.NewGuid():N}",
                        clientInfo = new { name = "cptower" },
                        protocolVersions = versions,
                    },
                }, token);

                using var initialize = await ReceiveResponseAsync(ws, 1, token);
                var response = initialize.RootElement;
                if (response.TryGetProperty("error", out var error)) {
                    if (attempt == 0 && error.TryGetProperty("code", out var code)
                        && code.ValueKind == JsonValueKind.Number && code.GetInt32() == -32005
                        && error.TryGetProperty("data", out var data)
                        && data.TryGetProperty("supportedVersions", out var supported)
                        && supported.ValueKind == JsonValueKind.Array) {
                        versions = supported.EnumerateArray().Select(version =>
                            version.ValueKind == JsonValueKind.String
                                && !string.IsNullOrWhiteSpace(version.GetString())
                                ? version.GetString()!
                                : throw new InvalidDataException("AHP advertised an invalid protocol version."))
                            .Distinct().ToArray();
                        if (versions.Length > 0) {
                            // A failed version negotiation closes the connection.
                            continue;
                        }
                    }
                    return new Result(false, null, null, 0, Error: "AHP initialization was rejected.");
                }

                if (!response.TryGetProperty("result", out var initialized)
                    || !initialized.TryGetProperty("protocolVersion", out var selected)
                    || selected.ValueKind != JsonValueKind.String
                    || string.IsNullOrWhiteSpace(selected.GetString())) {
                    throw new InvalidDataException("AHP initialization did not select a protocol version.");
                }

                var protocol = selected.GetString();
                var directory = initialized.TryGetProperty("defaultDirectory", out var value)
                    && value.ValueKind == JsonValueKind.String ? value.GetString() : null;
                await SendAsync(ws, new {
                    id = 2,
                    jsonrpc = "2.0",
                    method = "listSessions",
                    @params = new { channel = RootChannel },
                }, token);
                using var sessions = await ReceiveResponseAsync(ws, 2, token);
                if (!sessions.RootElement.TryGetProperty("result", out var catalog)
                    || !catalog.TryGetProperty("items", out var items) || items.ValueKind != JsonValueKind.Array) {
                    return new Result(true, protocol, DisplayPath(directory), 0,
                        Error: "The AHP host did not return its session catalog.");
                }
                return new Result(true, protocol, DisplayPath(LabelFrom(items) ?? directory), items.GetArrayLength());
            } catch (OperationCanceledException) when (outer.IsCancellationRequested) {
                throw;
            } catch (OperationCanceledException) {
                return new Result(false, null, null, 0, Error: "AHP discovery timed out.");
            } catch (Exception ex) when (ex is IOException or JsonException or InvalidOperationException
                or WebSocketException) {
                return new Result(false, null, null, 0,
                    ws.HttpStatusCode == HttpStatusCode.Unauthorized, ex.Message);
            } finally {
                await CloseQuietly(ws);
            }
        }

        return new Result(false, null, null, 0, Error: "AHP version negotiation failed.");
    }

    private static Uri HostUri(int port, string? connectionToken) => connectionToken is null
        ? new Uri($"ws://127.0.0.1:{port}/")
        : new Uri($"ws://127.0.0.1:{port}/?tkn={Uri.EscapeDataString(connectionToken)}");

    private static string? DisplayPath(string? value) =>
        value is not null && Uri.TryCreate(value, UriKind.Absolute, out var uri) && uri.IsFile ? uri.LocalPath : value;

    private static async Task CloseQuietly(ClientWebSocket ws) {
        if (ws.State is not (WebSocketState.Open or WebSocketState.CloseReceived)) {
            return;
        }
        try {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(1));
            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, null, cts.Token);
        } catch (Exception ex) when (ex is OperationCanceledException or WebSocketException) {
            // A failed negotiation may already have closed the peer.
        }
    }

    private static string? LabelFrom(JsonElement items) {
        foreach (var item in items.EnumerateArray()) {
            if (item.TryGetProperty("workingDirectories", out var dirs) && dirs.ValueKind == JsonValueKind.Array
                && dirs.GetArrayLength() > 0 && dirs[0].ValueKind == JsonValueKind.String) {
                return dirs[0].GetString();
            }
            if (item.TryGetProperty("title", out var title) && title.ValueKind == JsonValueKind.String) {
                return title.GetString();
            }
        }
        return null;
    }

    private static async Task SendAsync(ClientWebSocket ws, object payload, CancellationToken token) {
        var bytes = JsonSerializer.SerializeToUtf8Bytes(payload);
        await ws.SendAsync(bytes, WebSocketMessageType.Text, true, token);
    }

    private static async Task<JsonDocument> ReceiveResponseAsync(
        ClientWebSocket ws, int requestId, CancellationToken token) {
        var buffer = new byte[16 * 1024];
        using var message = new MemoryStream();
        while (true) {
            message.SetLength(0);
            WebSocketReceiveResult received;
            do {
                received = await ws.ReceiveAsync(buffer, token);
                if (received.MessageType == WebSocketMessageType.Close) {
                    throw new InvalidDataException("The AHP host closed before replying.");
                }
                message.Write(buffer, 0, received.Count);
            } while (!received.EndOfMessage);

            var response = JsonDocument.Parse(message.ToArray());
            var root = response.RootElement;
            if (root.ValueKind == JsonValueKind.Object && !root.TryGetProperty("method", out _)
                && root.TryGetProperty("id", out var id) && id.ValueKind == JsonValueKind.Number
                && id.TryGetInt32(out var value) && value == requestId) {
                return response;
            }
            response.Dispose();
        }
    }
}
