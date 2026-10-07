using System.ComponentModel;
using System.Diagnostics;
using System.Net.WebSockets;
using System.Text.Json;
using Microsoft.AspNetCore.WebUtilities;

namespace CpTower;

/// <summary>
/// Bridges a client WebSocket on `/ws/{port}` to the loopback AHP host on that port, adding the host's
/// shared connection token, and signs the connection in with a GitHub CLI account (`githubUser`, else
/// gh's active account): once the host answers the client's `initialize`, cptower sends `authenticate`
/// itself (before passing the answer on) and drops the reply. A client without a GitHub token, such as
/// the qvim app, can then subscribe to and steer sessions, which the host otherwise refuses with
/// `AuthRequired`.
/// </summary>
internal sealed class AhpRelay(string? githubUser, ILogger<AhpRelay> log) {
    // The host silently ignores requests with a string id, so cptower's own request uses a number far
    // above any client's counter (clients number their requests from 1).
    private const long AuthRequestId = 4_000_000_000_001;
    private const string GitHubResource = "https://api.github.com";
    private const string RootChannel = "ahp-root://";

    private static readonly string AuthRequestIdJson = JsonSerializer.Serialize(AuthRequestId);
    private static readonly TimeSpan CloseGrace = TimeSpan.FromSeconds(2);

    /// <summary>The account clients are signed in as, for logs.</summary>
    private string Account => githubUser ?? "the GitHub CLI's active account";

    public async Task RelayAsync(HttpContext context, HostInfo host, string path) {
        if (!context.WebSockets.IsWebSocketRequest) {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            return;
        }

        using var upstream = new ClientWebSocket();
        var githubToken = GitHubTokenAsync(context.RequestAborted);
        try {
            await upstream.ConnectAsync(HostUri(host, path, context.Request.Query), context.RequestAborted);
        } catch (Exception ex) when (ex is WebSocketException or HttpRequestException) {
            log.LogWarning("port {Port}: AHP host refused the bridge: {Error}", host.Port, ex.Message);
            context.Response.StatusCode = StatusCodes.Status502BadGateway;
            return;
        }

        using var downstream = await context.WebSockets.AcceptWebSocketAsync();
        var bridge = new Bridge(downstream, upstream, githubToken, Account, host.Port, log);
        using var stop = CancellationTokenSource.CreateLinkedTokenSource(context.RequestAborted);
        var toClient = bridge.HostToClientAsync(stop.Token);
        var toHost = bridge.ClientToHostAsync(stop.Token);
        try {
            await Task.WhenAny(toClient, toHost);
            // One side closed: let the other finish the close handshake briefly before cutting it off.
            await Task.WhenAny(Task.WhenAll(toClient, toHost), Task.Delay(CloseGrace, context.RequestAborted));
        } finally {
            stop.Cancel();
            await Task.WhenAll(Quietly(toClient), Quietly(toHost));
        }
    }

    /// <summary>Returns the GitHub CLI's github.com token for `githubUser` (else its active account), or null without one.</summary>
    private async Task<string?> GitHubTokenAsync(CancellationToken token) {
        try {
            var psi = new ProcessStartInfo("gh") {
                ArgumentList = { "auth", "token", "--hostname", "github.com" },
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                UseShellExecute = false,
            };
            if (githubUser is not null) {
                psi.ArgumentList.Add("--user");
                psi.ArgumentList.Add(githubUser);
            }

            using var proc = Process.Start(psi);
            if (proc is null) {
                return null;
            }

            var output = await proc.StandardOutput.ReadToEndAsync(token);
            await proc.WaitForExitAsync(token);
            return proc.ExitCode == 0 && output.Trim() is { Length: > 0 } value ? value : null;
        } catch (Exception ex) when (ex is Win32Exception or InvalidOperationException) {
            return null;
        }
    }

    /// <summary>The host URL for the client's path and query, with the shared token replacing any client `tkn`.</summary>
    private static Uri HostUri(HostInfo host, string path, IQueryCollection query) {
        var parameters = query.Where(q => q.Key != "tkn").ToList();
        if (host.Token is not null) {
            parameters.Add(new("tkn", host.Token));
        }

        return new Uri(QueryHelpers.AddQueryString($"ws://127.0.0.1:{host.Port}/{path}", parameters));
    }

    private static async Task Quietly(Task task) {
        try {
            await task;
        } catch (Exception) {
            // Either side going away (cancelled, aborted, or closed mid-message) just ends the bridge.
        }
    }

    /// <summary>One bridged connection: a pump per direction, sharing the injected-auth state.</summary>
    private sealed class Bridge(WebSocket client, WebSocket host, Task<string?> githubToken, string account, int port, ILogger log) {
        private readonly SemaphoreSlim hostSend = new(1, 1);

        // Raw JSON of the client's `initialize` request id, set by the client pump before it forwards it.
        private volatile string? initializeId;

        public async Task ClientToHostAsync(CancellationToken token) {
            var buffer = new byte[16 * 1024];
            using var message = new MemoryStream();
            while (await ReadMessageAsync(client, buffer, message, token) is { } type) {
                if (initializeId is null && type == WebSocketMessageType.Text) {
                    initializeId = InitializeIdOf(message);
                }

                await SendToHostAsync(Payload(message), type, token);
            }

            await host.CloseOutputAsync(client.CloseStatus ?? WebSocketCloseStatus.NormalClosure, client.CloseStatusDescription, token);
        }

        public async Task HostToClientAsync(CancellationToken token) {
            var buffer = new byte[16 * 1024];
            var inspecting = true;
            using var message = new MemoryStream();
            while (await ReadMessageAsync(host, buffer, message, token) is { } type) {
                if (inspecting && type == WebSocketMessageType.Text && ResponseOf(message) is { } response) {
                    if (response.Id == AuthRequestIdJson) {
                        LogAuthResult(response);
                        inspecting = false;
                        continue;
                    }

                    // Sign in before the client sees `initialize` succeed, so its follow-up requests are authenticated.
                    if (response.Id == initializeId && response.Ok) {
                        inspecting = await AuthenticateAsync(token);
                    }
                }

                await client.SendAsync(Payload(message), type, true, token);
            }

            await client.CloseOutputAsync(host.CloseStatus ?? WebSocketCloseStatus.NormalClosure, host.CloseStatusDescription, token);
        }

        /// <summary>Sends `authenticate` to the host; returns whether its reply is still to come.</summary>
        private async Task<bool> AuthenticateAsync(CancellationToken token) {
            var githubTokenValue = await githubToken;
            if (githubTokenValue is null) {
                log.LogWarning("port {Port}: no GitHub CLI token for {Account} (`gh auth token`); the client stays unauthenticated",
                    port, account);
                return false;
            }

            var request = JsonSerializer.SerializeToUtf8Bytes(new {
                jsonrpc = "2.0",
                id = AuthRequestId,
                method = "authenticate",
                @params = new { channel = RootChannel, resource = GitHubResource, token = githubTokenValue },
            });
            await SendToHostAsync(request, WebSocketMessageType.Text, token);
            return true;
        }

        private void LogAuthResult(Response response) {
            if (response.Ok) {
                log.LogInformation("port {Port}: client signed in to the AHP host as {Account}", port, account);
            } else {
                log.LogWarning("port {Port}: AHP host rejected the GitHub CLI token for {Account}: {Error}", port, account, response.Error);
            }
        }

        private async Task SendToHostAsync(ReadOnlyMemory<byte> payload, WebSocketMessageType type, CancellationToken token) {
            await hostSend.WaitAsync(token);
            try {
                await host.SendAsync(payload, type, true, token);
            } finally {
                hostSend.Release();
            }
        }
    }

    private readonly record struct Response(string Id, bool Ok, string? Error);

    /// <summary>Returns the raw JSON id of a JSON-RPC `initialize` request, or null for anything else.</summary>
    private static string? InitializeIdOf(MemoryStream message) {
        try {
            using var doc = JsonDocument.Parse(Payload(message));
            var root = doc.RootElement;
            return root.ValueKind == JsonValueKind.Object
                && root.TryGetProperty("method", out var method)
                && method.ValueKind == JsonValueKind.String
                && method.GetString() == "initialize"
                && root.TryGetProperty("id", out var id)
                ? id.GetRawText()
                : null;
        } catch (JsonException) {
            return null;
        }
    }

    /// <summary>Returns a JSON-RPC response's raw id and outcome, or null when the message is not a response.</summary>
    private static Response? ResponseOf(MemoryStream message) {
        try {
            using var doc = JsonDocument.Parse(Payload(message));
            var root = doc.RootElement;
            if (root.ValueKind != JsonValueKind.Object || !root.TryGetProperty("id", out var id)) {
                return null;
            }

            if (root.TryGetProperty("error", out var error)) {
                var text = error.ValueKind == JsonValueKind.Object
                    && error.TryGetProperty("message", out var msg)
                    && msg.ValueKind == JsonValueKind.String
                    ? msg.GetString()
                    : error.GetRawText();
                return new Response(id.GetRawText(), false, text);
            }

            return root.TryGetProperty("result", out _) ? new Response(id.GetRawText(), true, null) : null;
        } catch (JsonException) {
            return null;
        }
    }

    private static ReadOnlyMemory<byte> Payload(MemoryStream message) => message.GetBuffer().AsMemory(0, (int)message.Length);

    /// <summary>Reads one whole message into <paramref name="message"/>; returns its type, or null on close.</summary>
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
