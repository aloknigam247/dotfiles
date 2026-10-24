using System.Net.WebSockets;
using CpTower;
using Microsoft.AspNetCore.Http;
using Xunit;
using static CpTower.Tests.WebSocketTestHost;

namespace CpTower.Tests;

public sealed class AhpProbeTests {
    [Fact]
    public async Task NegotiatesTheHostsAdvertisedVersionOnANewConnection() {
        var connections = 0;
        await using var server = await StartAsync(async context => {
            Interlocked.Increment(ref connections);
            using var socket = await context.WebSockets.AcceptWebSocketAsync();
            using var initialize = await ReceiveAsync(socket, context.RequestAborted);
            var offered = initialize.RootElement.GetProperty("params").GetProperty("protocolVersions")
                .EnumerateArray().Select(version => version.GetString()).ToArray();
            if (!offered.Contains("7.2.0")) {
                await SendAsync(socket, new {
                    error = new {
                        code = -32005,
                        data = new { supportedVersions = new[] { "7.2.0" } },
                        message = "Unsupported protocol version",
                    },
                    id = 1,
                    jsonrpc = "2.0",
                });
                await socket.CloseOutputAsync(WebSocketCloseStatus.ProtocolError, null, context.RequestAborted);
                return;
            }

            await SendAsync(socket, new {
                id = 1,
                jsonrpc = "2.0",
                result = new { defaultDirectory = "file:///D:/fallback", protocolVersion = "7.2.0" },
            });
            using var list = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("listSessions", list.RootElement.GetProperty("method").GetString());
            await SendAsync(socket, new {
                id = 2,
                jsonrpc = "2.0",
                result = new { items = new[] { new { workingDirectories = new[] { "file:///D:/project" } } } },
            });
            await socket.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, null, context.RequestAborted);
        });

        var result = await AhpProbe.ProbeAsync(server.Uri.Port, null, CancellationToken.None);

        Assert.True(result.Ok);
        Assert.Equal("7.2.0", result.Protocol);
        Assert.Equal(@"D:\project", result.Label);
        Assert.Equal(1, result.Sessions);
        Assert.Equal(2, connections);
    }

    [Fact]
    public async Task ReportsARejectedConnectionToken() {
        await using var server = await StartAsync(context => {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return Task.CompletedTask;
        });

        var result = await AhpProbe.ProbeAsync(server.Uri.Port, "test-connection-token", CancellationToken.None);

        Assert.False(result.Ok);
        Assert.True(result.Unauthorized);
    }
}
