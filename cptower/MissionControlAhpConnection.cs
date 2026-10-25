using System.Collections.Concurrent;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading.Channels;
using Azure.Messaging.WebPubSub.Clients;

namespace CpTower;

internal sealed class MissionControlAhpConnection : IAhpConnection {
    private const string RootChannel = "ahp-root://";

    private readonly Channel<byte[]> incoming = Channel.CreateBounded<byte[]>(new BoundedChannelOptions(256) {
        FullMode = BoundedChannelFullMode.Wait,
        SingleReader = false,
        SingleWriter = false,
    });
    private readonly AhpEnvelopeCodec envelopes = new();
    private readonly HashSet<long> closedGenerations = [];
    private readonly ConcurrentDictionary<string, byte> requests = new();
    private readonly MissionControlHost host;
    private readonly ILogger log;
    private readonly MissionControlService missionControl;
    private readonly SemaphoreSlim credentialGate = new(1, 1);
    private readonly SemaphoreSlim receiveGate = new(1, 1);
    private readonly SemaphoreSlim sendGate = new(1, 1);
    private readonly WebPubSubClient webPubSub;

    private MissionControlConnection? connection;
    private long? generation;
    private string? handshakeId;
    private bool joined;
    private bool stopped;

    private MissionControlAhpConnection(
        MissionControlHost host, MissionControlService missionControl, ILogger log) {
        this.host = host;
        this.log = log;
        this.missionControl = missionControl;
        var credential = new WebPubSubClientCredential(token =>
            new ValueTask<Uri>(GetAccessUriAsync(token)));
        webPubSub = new WebPubSubClient(credential, new WebPubSubClientOptions {
            AutoReconnect = false,
            AutoRejoinGroups = true,
            Protocol = new WebPubSubJsonReliableProtocol(),
        });
        webPubSub.Disconnected += args => {
            if (!stopped) {
                Fail(new IOException(
                    $"Mission Control Web PubSub disconnected: {args.DisconnectedMessage?.Reason ?? "unknown"}."));
            }
            return Task.CompletedTask;
        };
        webPubSub.GroupMessageReceived += OnGroupMessageAsync;
        webPubSub.RejoinGroupFailed += args => {
            Fail(new IOException($"Could not rejoin Mission Control group {args.Group}.", args.Exception));
            return Task.CompletedTask;
        };
        webPubSub.Stopped += _ => {
            if (!stopped) {
                Fail(new IOException("The Mission Control Web PubSub client stopped."));
            }
            return Task.CompletedTask;
        };
    }

    public AhpAuthentication.AuthenticationKey? TrustedAuthenticationKey =>
        connection?.HostEncryptionKey.AsAuthenticationKey();

    public static async Task<IAhpConnection> ConnectAsync(
        MissionControlHost host, MissionControlService missionControl, ILogger log,
        CancellationToken token) {
        var result = new MissionControlAhpConnection(host, missionControl, log);
        try {
            await result.webPubSub.StartAsync(token);
            var value = result.CurrentConnection();
            await result.webPubSub.JoinGroupAsync(value.Groups.ToClient, cancellationToken: token);
            await result.webPubSub.JoinGroupAsync(value.Groups.Broadcast, cancellationToken: token);
            await result.webPubSub.JoinGroupAsync(value.Groups.Clients, cancellationToken: token);
            result.joined = true;
            await result.SendCapabilitiesAsync(token);
            return result;
        } catch {
            await result.DisposeAsync();
            throw;
        }
    }

    public async Task CloseAsync(CancellationToken token) {
        stopped = true;
        incoming.Writer.TryComplete();
        await webPubSub.StopAsync().WaitAsync(token);
    }

    public async ValueTask DisposeAsync() {
        stopped = true;
        incoming.Writer.TryComplete();
        await webPubSub.DisposeAsync();
        credentialGate.Dispose();
        receiveGate.Dispose();
        sendGate.Dispose();
    }

    public async Task<byte[]?> ReceiveAsync(CancellationToken token) {
        try {
            return await incoming.Reader.ReadAsync(token);
        } catch (ChannelClosedException ex) when (ex.InnerException is null) {
            return null;
        } catch (ChannelClosedException ex) {
            throw new IOException("The Mission Control AHP connection closed.", ex.InnerException);
        }
    }

    public async Task SendAsync(ReadOnlyMemory<byte> payload, CancellationToken token) {
        var normalized = NormalizeClientId(payload);
        TrackRequest(normalized);
        await sendGate.WaitAsync(token);
        try {
            var group = CurrentConnection().Groups.ToHost;
            foreach (var envelope in envelopes.Encode(normalized)) {
                await webPubSub.SendToGroupAsync(
                    group, envelope, WebPubSubDataType.Json, noEcho: true,
                    fireAndForget: false, cancellationToken: token);
            }
        } finally {
            sendGate.Release();
        }
    }

    private MissionControlConnection CurrentConnection() =>
        connection ?? throw new InvalidOperationException("Mission Control has not issued connection credentials.");

    private async Task<Uri> GetAccessUriAsync(CancellationToken token) {
        await credentialGate.WaitAsync(token);
        try {
            var value = await missionControl.ConnectAsync(host, connection?.ClientId, token);
            connection = value;
            return missionControl.WebSocketUri(value);
        } finally {
            credentialGate.Release();
        }
    }

    private async Task OnGroupMessageAsync(WebPubSubGroupMessageEventArgs args) {
        await receiveGate.WaitAsync(args.CancellationToken);
        try {
            var value = CurrentConnection();
            var message = args.Message;
            if (message.DataType != WebPubSubDataType.Json) {
                throw new InvalidDataException("Mission Control sent a non-JSON group message.");
            }
            if (message.Group == value.Groups.Clients) {
                using var control = JsonDocument.Parse(message.Data.ToMemory());
                var notice = control.RootElement;
                if (notice.TryGetProperty("kind", out var envelopeKind)
                    && envelopeKind.GetString() == "message"
                    && notice.TryGetProperty("data", out var data)) {
                    notice = data;
                }
                if (notice.TryGetProperty("kind", out var kind) && kind.GetString() == "host_offline") {
                    throw new IOException($"Mission Control environment {host.EnvironmentId} went offline.");
                }
                return;
            }
            if (message.Group != value.Groups.ToClient && message.Group != value.Groups.Broadcast) {
                throw new InvalidDataException("Mission Control sent a message from an unexpected group.");
            }

            var decoded = envelopes.Decode(message.Data, message.Group);
            if (decoded.Kind == AhpEnvelopeKind.Closed) {
                if (decoded.Generation is { } closed) {
                    closedGenerations.Add(closed);
                    if (generation is null || generation == closed) {
                        throw new IOException("The remote AHP host closed this client lane.");
                    }
                } else {
                    throw new IOException("The remote AHP host closed this client lane.");
                }
                return;
            }
            if (decoded.Kind is AhpEnvelopeKind.Capabilities or AhpEnvelopeKind.Pending) {
                return;
            }
            foreach (var payload in decoded.Payloads) {
                await DeliverAsync(payload, decoded.Generation, args.CancellationToken);
            }
        } catch (OperationCanceledException) when (stopped) {
            return;
        } catch (Exception ex) when (ex is IOException or InvalidDataException or JsonException
            or Azure.RequestFailedException or SendMessageFailedException) {
            Fail(ex);
        } finally {
            receiveGate.Release();
        }
    }

    private async Task DeliverAsync(byte[] payload, long? hostGeneration, CancellationToken token) {
        using var document = JsonDocument.Parse(payload);
        var root = document.RootElement;
        if (root.ValueKind != JsonValueKind.Object
            || !root.TryGetProperty("jsonrpc", out var version) || version.GetString() != "2.0") {
            throw new InvalidDataException("The remote host sent an invalid AHP message.");
        }
        var responseId = ResponseId(root);
        if (handshakeId is not null) {
            if (responseId != handshakeId) {
                return;
            }
            if (hostGeneration is { } closed && closedGenerations.Contains(closed)) {
                throw new IOException("The remote host replied from a closed AHP generation.");
            }
            generation = hostGeneration;
            handshakeId = null;
            closedGenerations.Clear();
            if (root.TryGetProperty("result", out _)) {
                await SendCapabilitiesAsync(token);
            }
        } else if (hostGeneration is not null && generation is not null && hostGeneration != generation) {
            if (responseId is not null && requests.ContainsKey(responseId)) {
                throw new IOException("The remote host replied from a replaced AHP generation.");
            }
            return;
        }
        if (responseId is not null) {
            requests.TryRemove(responseId, out _);
        }
        await incoming.Writer.WriteAsync(payload, token);
    }

    private void Fail(Exception error) {
        log.LogWarning("Mission Control environment {Environment}: {Error}", host.EnvironmentId, error.Message);
        incoming.Writer.TryComplete(error);
    }

    private byte[] NormalizeClientId(ReadOnlyMemory<byte> payload) {
        using var document = JsonDocument.Parse(payload);
        var root = document.RootElement;
        if (!root.TryGetProperty("method", out var method)
            || method.GetString() is not ("initialize" or "reconnect")) {
            return payload.ToArray();
        }
        var node = JsonNode.Parse(payload.Span) as JsonObject
            ?? throw new InvalidDataException("The AHP request is not a JSON object.");
        if (node["params"] is not JsonObject parameters) {
            throw new InvalidDataException("The AHP handshake request has no params object.");
        }
        parameters["clientId"] = CurrentConnection().ClientId;
        return JsonSerializer.SerializeToUtf8Bytes(node);
    }

    private static string? ResponseId(JsonElement root) {
        if (root.TryGetProperty("method", out _) || !root.TryGetProperty("id", out var id)
            || id.ValueKind is not (JsonValueKind.Number or JsonValueKind.String)) {
            return null;
        }
        return id.GetRawText();
    }

    private async Task SendCapabilitiesAsync(CancellationToken token) {
        if (!joined) {
            return;
        }
        var envelope = BinaryData.FromObjectAsJson(new { accepts = new[] { "batch" }, kind = "capabilities" });
        await webPubSub.SendToGroupAsync(
            CurrentConnection().Groups.ToHost, envelope, WebPubSubDataType.Json,
            noEcho: true, fireAndForget: false, cancellationToken: token);
    }

    private void TrackRequest(ReadOnlyMemory<byte> payload) {
        using var document = JsonDocument.Parse(payload);
        var root = document.RootElement;
        if (!root.TryGetProperty("method", out var method) || !root.TryGetProperty("id", out var id)
            || id.ValueKind is not (JsonValueKind.Number or JsonValueKind.String)) {
            return;
        }
        var value = id.GetRawText();
        if (requests.Count >= 1024) {
            throw new InvalidOperationException("Too many AHP requests are awaiting responses.");
        }
        if (!requests.TryAdd(value, 0)) {
            throw new InvalidOperationException($"AHP request ID {value} is already awaiting a response.");
        }
        if (method.GetString() is "initialize" or "reconnect") {
            handshakeId = value;
            closedGenerations.Clear();
        }
    }
}
