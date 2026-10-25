using System.Net.WebSockets;
using System.Security.Cryptography;
using System.Text.Json;
using CpTower;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Logging.Abstractions;
using Sodium;
using Xunit;
using static CpTower.Tests.WebSocketTestHost;

namespace CpTower.Tests;

public sealed class AhpRelayTests {
    [Fact]
    public async Task AuthenticatesBeforeReturningInitializeAndThenRelaysTraffic() {
        const string challenge = "00112233445566778899aabbccddeeff";
        const string resource = "https://api.microsoft.ghe.com";
        const string token = "enterprise-test-token";
        var authenticated = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
        var hosts = new List<string>();
        var keys = PublicKeyBox.GenerateKeyPair();
        var keyId = WebEncoders.Base64UrlEncode(SHA256.HashData(keys.PublicKey), 0, 8);
        await using var upstream = await StartAsync(async context => {
            using var socket = await context.WebSockets.AcceptWebSocketAsync();
            using var initialize = await ReceiveAsync(socket, context.RequestAborted);
            var initializeId = initialize.RootElement.GetProperty("id").Clone();
            await SendAsync(socket, new {
                id = initializeId,
                jsonrpc = "2.0",
                result = new {
                    _meta = new Dictionary<string, object> {
                        ["copilot.authChallenge"] = new {
                            challenge,
                            required = true,
                            responseMaxAgeSeconds = 300,
                        },
                        ["copilot.encryptionRequired"] = new[] { "auth-token" },
                    },
                    protocolVersion = "0.9.0",
                    snapshots = Array.Empty<object>(),
                },
            });

            using var subscribe = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("subscribe", subscribe.RootElement.GetProperty("method").GetString());
            await SendAsync(socket, new {
                jsonrpc = "2.0",
                method = "root/sessionAdded",
                @params = new { channel = "ahp-root://", summary = new { resource = "ahp-session:/hidden" } },
            });
            await SendAsync(socket, new {
                id = subscribe.RootElement.GetProperty("id").Clone(),
                jsonrpc = "2.0",
                result = new {
                    snapshot = new {
                        resource = "ahp-root://",
                        state = new {
                            _meta = new Dictionary<string, object> {
                                ["copilot.encryptionKeys"] = new[] {
                                    new {
                                        algorithm = "x25519-sealedbox",
                                        keyId,
                                        publicKey = Convert.ToBase64String(keys.PublicKey),
                                        use = "auth-token",
                                    },
                                },
                            },
                            agents = new[] {
                                new {
                                    protectedResources = new[] { new { resource } },
                                },
                            },
                        },
                    },
                },
            });

            using var authentication = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("authenticate", authentication.RootElement.GetProperty("method").GetString());
            var sealedToken = authentication.RootElement.GetProperty("params").GetProperty("token").GetString()!;
            var plaintext = SealedPublicKeyBox.Open(
                WebEncoders.Base64UrlDecode(sealedToken.Split('.')[3]), keys);
            using var payload = JsonDocument.Parse(plaintext);
            Assert.Equal(token, payload.RootElement.GetProperty("value").GetString());
            Assert.Equal(challenge, payload.RootElement.GetProperty("ctx").GetProperty("connection")
                .GetProperty("challenge").GetString());
            authenticated.SetResult();
            await SendAsync(socket, new {
                id = authentication.RootElement.GetProperty("id").Clone(),
                jsonrpc = "2.0",
                result = new { },
            });

            using var unsubscribe = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("unsubscribe", unsubscribe.RootElement.GetProperty("method").GetString());
            using var ping = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("ping", ping.RootElement.GetProperty("method").GetString());
            await SendAsync(socket, new {
                id = ping.RootElement.GetProperty("id").Clone(),
                jsonrpc = "2.0",
                result = new { },
            });

            using var list = await ReceiveAsync(socket, context.RequestAborted);
            Assert.Equal("listSessions", list.RootElement.GetProperty("method").GetString());
            await SendAsync(socket, new {
                id = list.RootElement.GetProperty("id").Clone(),
                jsonrpc = "2.0",
                result = new { items = new[] { new { resource = "ahp-session:/live" } } },
            });
            await socket.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, null, context.RequestAborted);
        });
        await using var proxy = await StartProxyAsync(upstream.Uri.Port, null, (host, _) => {
            hosts.Add(host);
            return Task.FromResult(token);
        });
        using var client = new ClientWebSocket();
        await client.ConnectAsync(proxy.Uri, CancellationToken.None);
        await SendAsync(client, new {
            id = "client-initialize",
            jsonrpc = "2.0",
            method = "initialize",
            @params = new {
                channel = "ahp-root://",
                clientId = "test-client",
                protocolVersions = new[] { "0.9.0" },
            },
        });

        using var initialized = await ReceiveAsync(client);
        Assert.True(authenticated.Task.IsCompletedSuccessfully);
        Assert.Equal("client-initialize", initialized.RootElement.GetProperty("id").GetString());
        Assert.Equal(new[] { "microsoft.ghe.com" }, hosts);

        await SendAsync(client, new {
            id = 2,
            jsonrpc = "2.0",
            method = "listSessions",
            @params = new { channel = "ahp-root://" },
        });
        using var sessions = await ReceiveAsync(client);
        Assert.Equal("ahp-session:/live",
            sessions.RootElement.GetProperty("result").GetProperty("items")[0].GetProperty("resource").GetString());
    }

    [Fact]
    public async Task ReturnsAnInitializeErrorWhenCredentialsAreUnavailable() {
        const string resource = "https://api.microsoft.ghe.com";
        await using var upstream = await StartAsync(async context => {
            using var socket = await context.WebSockets.AcceptWebSocketAsync();
            using var initialize = await ReceiveAsync(socket, context.RequestAborted);
            await SendAsync(socket, new {
                id = initialize.RootElement.GetProperty("id").Clone(),
                jsonrpc = "2.0",
                result = new {
                    protocolVersion = "0.9.0",
                    snapshots = new[] {
                        new {
                            resource = "ahp-root://",
                            state = new {
                                agents = new[] {
                                    new {
                                        protectedResources = new[] { new { resource } },
                                    },
                                },
                            },
                        },
                    },
                },
            });
        });
        await using var proxy = await StartProxyAsync(upstream.Uri.Port, null,
            (_, _) => throw new InvalidOperationException("No matching enterprise credential."));
        using var client = new ClientWebSocket();
        await client.ConnectAsync(proxy.Uri, CancellationToken.None);
        await SendAsync(client, new {
            id = "client-initialize",
            jsonrpc = "2.0",
            method = "initialize",
            @params = new {
                channel = "ahp-root://",
                clientId = "test-client",
                initialSubscriptions = new[] { "ahp-root://" },
                protocolVersions = new[] { "0.9.0" },
            },
        });

        using var response = await ReceiveAsync(client);
        Assert.Equal("client-initialize", response.RootElement.GetProperty("id").GetString());
        Assert.Equal(-32007, response.RootElement.GetProperty("error").GetProperty("code").GetInt32());
        Assert.Contains("No matching enterprise credential",
            response.RootElement.GetProperty("error").GetProperty("message").GetString());
    }

    [Fact]
    [Trait("Category", "Live")]
    public async Task ConnectsThroughAConfiguredCptower() {
        var proxyUrl = Environment.GetEnvironmentVariable("CPTOWER_TEST_PROXY_URL");
        if (string.IsNullOrWhiteSpace(proxyUrl)) {
            return;
        }

        using var client = new ClientWebSocket();
        await client.ConnectAsync(new Uri(proxyUrl), CancellationToken.None);
        await SendAsync(client, new {
            id = 1,
            jsonrpc = "2.0",
            method = "initialize",
            @params = new {
                channel = "ahp-root://",
                clientId = $"cptower-packaged-test-{Guid.NewGuid():N}",
                initialSubscriptions = new[] { "ahp-root://" },
                protocolVersions = new[] { "0.9.0" },
            },
        });
        using var initialized = await ReceiveAsync(client);
        Assert.True(initialized.RootElement.TryGetProperty("result", out _));

        await SendAsync(client, new {
            id = 2,
            jsonrpc = "2.0",
            method = "listSessions",
            @params = new { channel = "ahp-root://" },
        });
        using var sessions = await ReceiveAsync(client);
        var items = sessions.RootElement.GetProperty("result").GetProperty("items").EnumerateArray().ToArray();
        Assert.NotEmpty(items);
        var session = items[0].GetProperty("resource").GetString();
        await SendAsync(client, new {
            id = 3,
            jsonrpc = "2.0",
            method = "subscribe",
            @params = new { channel = session },
        });
        using var subscribed = await ReceiveResponseAsync(client, 3);
        Assert.Equal(session, subscribed.RootElement.GetProperty("result")
            .GetProperty("snapshot").GetProperty("resource").GetString());
        await client.CloseAsync(WebSocketCloseStatus.NormalClosure, null, CancellationToken.None);
    }

    [Fact]
    [Trait("Category", "Live")]
    public async Task ConnectsToAConfiguredLiveHost() {
        var hostUrl = Environment.GetEnvironmentVariable("CPTOWER_TEST_AHP_URL");
        var token = Environment.GetEnvironmentVariable("CPTOWER_TEST_GITHUB_TOKEN");
        if (string.IsNullOrWhiteSpace(hostUrl) || string.IsNullOrWhiteSpace(token)) {
            return;
        }

        var uri = new Uri(hostUrl);
        var connectionToken = QueryHelpers.ParseQuery(uri.Query)["tkn"].ToString();
        var probe = await AhpProbe.ProbeAsync(uri.Port, connectionToken, CancellationToken.None);
        Assert.True(probe.Ok, probe.Error);
        Assert.NotNull(probe.Protocol);
        Assert.True(probe.Sessions > 0);

        await using var proxy = await StartProxyAsync(uri.Port, connectionToken, (_, _) => Task.FromResult(token));
        using var client = new ClientWebSocket();
        await client.ConnectAsync(proxy.Uri, CancellationToken.None);
        await SendAsync(client, new {
            id = 1,
            jsonrpc = "2.0",
            method = "initialize",
            @params = new {
                channel = "ahp-root://",
                clientId = $"cptower-test-{Guid.NewGuid():N}",
                initialSubscriptions = new[] { "ahp-root://" },
                protocolVersions = new[] { "0.9.0" },
            },
        });
        using var initialized = await ReceiveAsync(client);
        Assert.True(initialized.RootElement.TryGetProperty("result", out _));

        await SendAsync(client, new {
            id = 2,
            jsonrpc = "2.0",
            method = "listSessions",
            @params = new { channel = "ahp-root://" },
        });
        using var sessions = await ReceiveAsync(client);
        Assert.NotEmpty(sessions.RootElement.GetProperty("result").GetProperty("items").EnumerateArray());
        await client.CloseAsync(WebSocketCloseStatus.NormalClosure, null, CancellationToken.None);
    }

    private static Task<WebSocketTestHost> StartProxyAsync(
        int hostPort, string? connectionToken, Func<string, CancellationToken, Task<string>> token) {
        var relay = new AhpRelay(token, NullLogger<AhpRelay>.Instance);
        var host = new HostInfo(hostPort, 0, "test", "unknown", 0, connectionToken);
        return StartAsync(context => relay.RelayAsync(context, host, ""));
    }

    private static async Task<JsonDocument> ReceiveResponseAsync(ClientWebSocket socket, int id) {
        while (true) {
            var message = await ReceiveAsync(socket);
            if (message.RootElement.TryGetProperty("id", out var responseId)
                && responseId.ValueKind == JsonValueKind.Number && responseId.GetInt32() == id) {
                return message;
            }
            message.Dispose();
        }
    }
}
