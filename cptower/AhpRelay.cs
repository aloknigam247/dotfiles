using System.Net.WebSockets;
using System.Security.Cryptography;
using System.Text.Json;
using Azure;
using Azure.Messaging.WebPubSub.Clients;

namespace CpTower;

/// <summary>
/// Authenticates the upstream connection before transparently relaying the client's AHP traffic.
/// </summary>
internal sealed class AhpRelay {
    private const string RootChannel = "ahp-root://";

    private static readonly TimeSpan CloseGrace = TimeSpan.FromSeconds(2);

    private readonly Func<HostInfo, string, IQueryCollection, CancellationToken, Task<IAhpConnection>> connectHost;
    private readonly Func<string, CancellationToken, Task<string>> githubToken;
    private readonly ILogger<AhpRelay> log;

    public AhpRelay(
        Func<string, CancellationToken, Task<string>> githubToken, ILogger<AhpRelay> log,
        Func<HostInfo, string, IQueryCollection, CancellationToken, Task<IAhpConnection>>? connectHost = null) {
        this.connectHost = connectHost ?? WebSocketAhpConnection.ConnectAsync;
        this.githubToken = githubToken;
        this.log = log;
    }

    public async Task RelayAsync(HttpContext context, HostInfo host, string path) {
        if (!context.WebSockets.IsWebSocketRequest) {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            return;
        }

        IAhpConnection upstream;
        try {
            upstream = await connectHost(host, path, context.Request.Query, context.RequestAborted);
        } catch (Exception ex) when (ex is IOException or InvalidOperationException
            or WebSocketException or HttpRequestException or RequestFailedException) {
            log.LogWarning("host {Host}: AHP host refused the bridge: {Error}", host.Id, ex.Message);
            context.Response.StatusCode = StatusCodes.Status502BadGateway;
            return;
        }
        await using var disposeUpstream = upstream;

        using var downstream = await context.WebSockets.AcceptWebSocketAsync();
        using var stop = CancellationTokenSource.CreateLinkedTokenSource(context.RequestAborted);
        var handshake = new Handshake(downstream, upstream, githubToken, host.Id, log);
        try {
            if (!await handshake.InitializeAsync(stop.Token)) {
                return;
            }

            var toClient = CopyToClientAsync(upstream, downstream, stop.Token);
            var toHost = CopyToHostAsync(downstream, upstream, stop.Token);
            try {
                await await Task.WhenAny(toClient, toHost);
                await Task.WhenAny(Task.WhenAll(toClient, toHost), Task.Delay(CloseGrace, stop.Token));
            } finally {
                stop.Cancel();
                await Task.WhenAll(Quietly(toClient), Quietly(toHost));
            }
        } catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested) {
            log.LogDebug("host {Host}: client disconnected", host.Id);
        } catch (Exception ex) when (ex is IOException or WebSocketException
            or RequestFailedException or SendMessageFailedException) {
            log.LogWarning("host {Host}: AHP bridge closed: {Error}", host.Id, ex.Message);
        }
    }

    private static async Task Quietly(Task task) {
        try {
            await task;
        } catch (Exception ex) when (ex is IOException or OperationCanceledException or WebSocketException
            or RequestFailedException or SendMessageFailedException) {
            // The remaining pump is cancelled after either peer closes.
        }
    }

    private sealed class Handshake(
        WebSocket client, IAhpConnection host, Func<string, CancellationToken, Task<string>> githubToken,
        string hostId, ILogger log) {
        private bool hideRootNotifications;
        private JsonElement? initializeId;
        private readonly List<byte[]> pending = [];
        private long requestId = 4_000_000_000_001;

        public async Task<bool> InitializeAsync(CancellationToken token) {
            var buffer = new byte[16 * 1024];
            using var message = new MemoryStream();
            IReadOnlyList<AhpAuthentication.Resource> resources = [];
            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(token);
            timeout.CancelAfter(TimeSpan.FromSeconds(30));
            try {
                var type = await ReadMessageAsync(client, buffer, message, timeout.Token);
                if (type is null) {
                    return false;
                }
                if (type != WebSocketMessageType.Text) {
                    throw new InvalidDataException("Expected an AHP initialize request.");
                }

                using var request = JsonDocument.Parse(Payload(message));
                var root = request.RootElement;
                if (root.ValueKind != JsonValueKind.Object || !root.TryGetProperty("id", out var id)
                    || id.ValueKind is not (JsonValueKind.Number or JsonValueKind.String)
                    || !root.TryGetProperty("method", out var method) || method.GetString() != "initialize") {
                    throw new InvalidDataException("Expected an AHP initialize request.");
                }
                initializeId = id.Clone();
                var wantsRoot = root.TryGetProperty("params", out var parameters)
                    && parameters.TryGetProperty("initialSubscriptions", out var subscriptions)
                    && subscriptions.ValueKind == JsonValueKind.Array
                    && subscriptions.EnumerateArray().Any(value =>
                        value.ValueKind == JsonValueKind.String && value.GetString() == RootChannel);
                await host.SendAsync(Payload(message), timeout.Token);

                var response = await ReceiveResponseAsync(id, timeout.Token);
                if (!response.Root.TryGetProperty("result", out var initialized)) {
                    await client.SendAsync(response.Payload, WebSocketMessageType.Text, true, token);
                    await client.CloseOutputAsync(WebSocketCloseStatus.ProtocolError, "AHP initialize failed.", token);
                    return false;
                }

                var state = RootState(initialized);
                if (state is null) {
                    hideRootNotifications = !wantsRoot;
                    var subscribed = await RequestAsync("subscribe", new { channel = RootChannel }, timeout.Token);
                    if (!subscribed.TryGetProperty("snapshot", out var snapshot)
                        || !snapshot.TryGetProperty("resource", out var channel)
                        || channel.GetString() != RootChannel || !snapshot.TryGetProperty("state", out var value)) {
                        throw new InvalidDataException("The AHP root subscription returned no root snapshot.");
                    }
                    state = value;
                }
                resources = AhpAuthentication.Resources(state.Value);
                foreach (var resource in resources) {
                    var credential = await githubToken(resource.Host, timeout.Token).WaitAsync(timeout.Token);
                    if (string.IsNullOrWhiteSpace(credential)) {
                        throw new InvalidOperationException($"No GitHub credential is available for {resource.Host}.");
                    }
                    var sealedToken = AhpAuthentication.CreateToken(
                        initialized, state.Value, resource.Uri, credential, host.TrustedAuthenticationKey);
                    await RequestAsync("authenticate", new {
                        channel = RootChannel,
                        resource = resource.Uri,
                        token = sealedToken,
                    }, timeout.Token);
                    log.LogInformation("host {Host}: client authenticated for {Resource}", hostId, resource.Uri);
                }

                if (hideRootNotifications) {
                    await SendAsync(host, new {
                        jsonrpc = "2.0",
                        method = "unsubscribe",
                        @params = new { channel = RootChannel },
                    }, timeout.Token);
                    // Drain notifications from our temporary subscription before starting the transparent relay.
                    await RequestAsync("ping", new { channel = RootChannel }, timeout.Token);
                }

                await client.SendAsync(response.Payload, WebSocketMessageType.Text, true, token);
                foreach (var notification in pending) {
                    await client.SendAsync(notification, WebSocketMessageType.Text, true, token);
                }
                return true;
            } catch (OperationCanceledException) when (!token.IsCancellationRequested) {
                return await FailAsync("AHP authentication timed out.", resources, token);
            } catch (Exception ex) when (ex is CryptographicException or DllNotFoundException
                or EntryPointNotFoundException or IOException or InvalidOperationException or JsonException
                or WebSocketException or RequestFailedException or SendMessageFailedException) {
                return await FailAsync(ex.Message, resources, token);
            }
        }

        private async Task<bool> FailAsync(
            string error, IReadOnlyList<AhpAuthentication.Resource> resources, CancellationToken token) {
            log.LogWarning("host {Host}: cptower authentication failed: {Error}", hostId, error);
            await SendClientAsync(client, new {
                error = new {
                    code = -32007,
                    data = new { resources = resources.Select(value => new { resource = value.Uri }) },
                    message = $"cptower: {error}",
                },
                id = initializeId,
                jsonrpc = "2.0",
            }, token);
            await client.CloseOutputAsync(WebSocketCloseStatus.PolicyViolation, "AHP authentication failed.", token);
            return false;
        }

        private async Task<JsonElement> RequestAsync(string method, object parameters, CancellationToken token) {
            var id = JsonSerializer.SerializeToElement(requestId++);
            if (initializeId is { } original && SameId(id, original)) {
                id = JsonSerializer.SerializeToElement(requestId++);
            }
            await SendAsync(host, new { id, jsonrpc = "2.0", method, @params = parameters }, token);
            var response = await ReceiveResponseAsync(id, token);
            if (response.Root.TryGetProperty("result", out var result)) {
                return result;
            }
            var code = response.Root.TryGetProperty("error", out var error)
                && error.TryGetProperty("code", out var value) && value.ValueKind == JsonValueKind.Number
                ? value.GetRawText() : "unknown";
            throw new InvalidOperationException($"AHP {method} failed with error {code}.");
        }

        private async Task<(byte[] Payload, JsonElement Root)> ReceiveResponseAsync(
            JsonElement expectedId, CancellationToken token) {
            while (await host.ReceiveAsync(token) is { } payload) {
                using var document = JsonDocument.Parse(payload);
                var root = document.RootElement;
                if (root.ValueKind == JsonValueKind.Object) {
                    if (!root.TryGetProperty("method", out _) && root.TryGetProperty("id", out var id)
                        && SameId(id, expectedId)) {
                        return (payload, root.Clone());
                    }
                    if (hideRootNotifications && !root.TryGetProperty("id", out _)
                        && root.TryGetProperty("params", out var parameters)
                        && parameters.TryGetProperty("channel", out var channel)
                        && channel.ValueKind == JsonValueKind.String && channel.GetString() == RootChannel) {
                        continue;
                    }
                }
                pending.Add(payload);
            }
            throw new InvalidDataException("The AHP host closed during authentication.");
        }

        private static JsonElement? RootState(JsonElement initialized) {
            if (initialized.TryGetProperty("snapshots", out var snapshots)) {
                foreach (var snapshot in snapshots.EnumerateArray()) {
                    if (snapshot.TryGetProperty("resource", out var channel) && channel.GetString() == RootChannel
                        && snapshot.TryGetProperty("state", out var state)) {
                        return state;
                    }
                }
            }
            return null;
        }

        private static bool SameId(JsonElement left, JsonElement right) =>
            left.ValueKind == right.ValueKind && (left.ValueKind == JsonValueKind.String
                ? left.GetString() == right.GetString() : left.GetRawText() == right.GetRawText());
    }

    private static async Task CopyToClientAsync(
        IAhpConnection source, WebSocket destination, CancellationToken token) {
        while (await source.ReceiveAsync(token) is { } payload) {
            await destination.SendAsync(payload, WebSocketMessageType.Text, true, token);
        }
        if (destination.State is WebSocketState.Open or WebSocketState.CloseReceived) {
            await destination.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, null, token);
        }
    }

    private static async Task CopyToHostAsync(
        WebSocket source, IAhpConnection destination, CancellationToken token) {
        var buffer = new byte[16 * 1024];
        using var message = new MemoryStream();
        while (await ReadMessageAsync(source, buffer, message, token) is { } type) {
            if (type != WebSocketMessageType.Text) {
                throw new InvalidDataException("The AHP client sent a non-text WebSocket message.");
            }
            await destination.SendAsync(Payload(message), token);
        }
        await destination.CloseAsync(token);
    }

    private static ReadOnlyMemory<byte> Payload(MemoryStream message) =>
        message.GetBuffer().AsMemory(0, (int)message.Length);

    private static Task SendAsync(IAhpConnection connection, object message, CancellationToken token) =>
        connection.SendAsync(JsonSerializer.SerializeToUtf8Bytes(message), token);

    private static async Task SendClientAsync(WebSocket socket, object message, CancellationToken token) =>
        await socket.SendAsync(
            JsonSerializer.SerializeToUtf8Bytes(message), WebSocketMessageType.Text, true, token);

    private static async Task<WebSocketMessageType?> ReadMessageAsync(
        WebSocket socket, byte[] buffer, MemoryStream message, CancellationToken token) {
        message.SetLength(0);
        ValueWebSocketReceiveResult result;
        do {
            result = await socket.ReceiveAsync(buffer.AsMemory(), token);
            if (result.MessageType == WebSocketMessageType.Close) {
                return null;
            }

            message.Write(buffer, 0, result.Count);
        } while (!result.EndOfMessage);

        return result.MessageType;
    }
}
