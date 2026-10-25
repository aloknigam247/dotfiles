using System.Collections.Concurrent;
using System.Net.WebSockets;
using System.Text.Json;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace CpTower.Tests;

internal sealed class WebSocketTestHost : IAsyncDisposable {
    private readonly ConcurrentQueue<Exception> errors = new();
    private readonly WebApplication app;

    private WebSocketTestHost(WebApplication app) {
        this.app = app;
    }

    public Uri Uri => new UriBuilder(app.Urls.Single()) { Scheme = "ws" }.Uri;

    public static async Task<WebSocketTestHost> StartAsync(RequestDelegate handler) {
        var builder = WebApplication.CreateBuilder();
        builder.Logging.ClearProviders();
        builder.WebHost.UseUrls("http://127.0.0.1:0");
        var app = builder.Build();
        var host = new WebSocketTestHost(app);
        app.UseWebSockets();
        app.Run(async context => {
            try {
                await handler(context);
            } catch (Exception ex) when (ex is not OperationCanceledException) {
                host.errors.Enqueue(ex);
                throw;
            }
        });
        await app.StartAsync();
        return host;
    }

    public static async Task<JsonDocument> ReceiveAsync(WebSocket socket, CancellationToken token = default) {
        var buffer = new byte[16384];
        using var message = new MemoryStream();
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(token);
        timeout.CancelAfter(TimeSpan.FromSeconds(10));
        ValueWebSocketReceiveResult received;
        do {
            received = await socket.ReceiveAsync(buffer.AsMemory(), timeout.Token);
            if (received.MessageType == WebSocketMessageType.Close) {
                throw new InvalidDataException("The test WebSocket closed before its response.");
            }
            message.Write(buffer, 0, received.Count);
        } while (!received.EndOfMessage);

        return JsonDocument.Parse(message.ToArray());
    }

    public static Task SendAsync(WebSocket socket, object message, CancellationToken token = default) =>
        socket.SendAsync(JsonSerializer.SerializeToUtf8Bytes(message), WebSocketMessageType.Text, true, token);

    public async ValueTask DisposeAsync() {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(10));
        await app.StopAsync(timeout.Token);
        await app.DisposeAsync();
        if (!errors.IsEmpty) {
            throw new AggregateException(errors);
        }
    }
}
