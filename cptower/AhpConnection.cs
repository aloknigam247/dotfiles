using System.Net.WebSockets;
using Microsoft.AspNetCore.WebUtilities;

namespace CpTower;

internal interface IAhpConnection : IAsyncDisposable {
    AhpAuthentication.AuthenticationKey? TrustedAuthenticationKey { get; }

    Task CloseAsync(CancellationToken token);

    Task<byte[]?> ReceiveAsync(CancellationToken token);

    Task SendAsync(ReadOnlyMemory<byte> payload, CancellationToken token);
}

internal sealed class AhpConnectionFactory(
    MissionControlService missionControl, ILogger<MissionControlAhpConnection> missionControlLog) {
    public Task<IAhpConnection> ConnectAsync(
        HostInfo host, string path, IQueryCollection query, CancellationToken token) =>
        host.MissionControl is { } remote
            ? MissionControlAhpConnection.ConnectAsync(remote, missionControl, missionControlLog, token)
            : WebSocketAhpConnection.ConnectAsync(host, path, query, token);
}

internal sealed class WebSocketAhpConnection(ClientWebSocket socket) : IAhpConnection {
    public AhpAuthentication.AuthenticationKey? TrustedAuthenticationKey => null;

    public static async Task<IAhpConnection> ConnectAsync(
        HostInfo host, string path, IQueryCollection query, CancellationToken token) {
        var socket = new ClientWebSocket();
        try {
            await socket.ConnectAsync(HostUri(host, path, query), token);
            return new WebSocketAhpConnection(socket);
        } catch {
            socket.Dispose();
            throw;
        }
    }

    public async Task CloseAsync(CancellationToken token) {
        if (socket.State is WebSocketState.Open or WebSocketState.CloseReceived) {
            await socket.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, null, token);
        }
    }

    public async ValueTask DisposeAsync() {
        socket.Dispose();
        await ValueTask.CompletedTask;
    }

    public async Task<byte[]?> ReceiveAsync(CancellationToken token) {
        var buffer = new byte[16 * 1024];
        using var message = new MemoryStream();
        ValueWebSocketReceiveResult received;
        do {
            received = await socket.ReceiveAsync(buffer.AsMemory(), token);
            if (received.MessageType == WebSocketMessageType.Close) {
                return null;
            }
            if (received.MessageType != WebSocketMessageType.Text) {
                throw new InvalidDataException("The AHP host sent a non-text WebSocket message.");
            }
            message.Write(buffer, 0, received.Count);
        } while (!received.EndOfMessage);
        return message.ToArray();
    }

    public async Task SendAsync(ReadOnlyMemory<byte> payload, CancellationToken token) =>
        await socket.SendAsync(payload, WebSocketMessageType.Text, true, token);

    private static Uri HostUri(HostInfo host, string path, IQueryCollection query) {
        var parameters = query.Where(value => value.Key != "tkn").ToList();
        if (host.Token is not null) {
            parameters.Add(new("tkn", host.Token));
        }
        return new Uri(QueryHelpers.AddQueryString($"ws://127.0.0.1:{host.Port}/{path}", parameters));
    }
}
