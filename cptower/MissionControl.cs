using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace CpTower;

internal sealed record MissionControlCapabilities(
    [property: JsonPropertyName("ahp_version")] string? AhpVersion,
    [property: JsonPropertyName("current_sessions")] int? CurrentSessions,
    [property: JsonPropertyName("max_sessions")] int? MaxSessions);

internal sealed record MissionControlConnection(
    [property: JsonPropertyName("access_token")] string AccessToken,
    [property: JsonPropertyName("client_id")] string ClientId,
    [property: JsonPropertyName("encrypted_github_token")] string? EncryptedGithubToken,
    [property: JsonPropertyName("encrypted_github_token_scope")] string? EncryptedGithubTokenScope,
    [property: JsonPropertyName("environment_status")] string EnvironmentStatus,
    [property: JsonPropertyName("expires_at")] string ExpiresAt,
    [property: JsonPropertyName("groups")] MissionControlGroups Groups,
    [property: JsonPropertyName("host_encryption_key")] MissionControlKey HostEncryptionKey,
    [property: JsonPropertyName("hub")] string Hub,
    [property: JsonPropertyName("subprotocol")] string Subprotocol,
    [property: JsonPropertyName("wps_endpoint")] string WpsEndpoint);

internal sealed record MissionControlEnvironment(
    [property: JsonPropertyName("capabilities")] MissionControlCapabilities? Capabilities,
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("kind")] string Kind,
    [property: JsonPropertyName("name")] string Name,
    [property: JsonPropertyName("status")] string Status);

internal sealed record MissionControlGroups(
    [property: JsonPropertyName("broadcast")] string Broadcast,
    [property: JsonPropertyName("clients")] string Clients,
    [property: JsonPropertyName("to_client")] string ToClient,
    [property: JsonPropertyName("to_host")] string ToHost);

internal sealed record MissionControlKey(
    [property: JsonPropertyName("algorithm")] string Algorithm,
    [property: JsonPropertyName("key_id")] string KeyId,
    [property: JsonPropertyName("public_key")] string PublicKey,
    [property: JsonPropertyName("use")] string Use) {
    public AhpAuthentication.AuthenticationKey AsAuthenticationKey() =>
        new(Algorithm, KeyId, PublicKey, Use);
}

internal sealed class MissionControlService {
    private static readonly JsonSerializerOptions Json = new() {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
    };

    private readonly Func<string, Uri> resolveApiBase;
    private readonly Func<MissionControlConnection, Uri>? resolveWebSocket;
    private readonly Func<string, CancellationToken, Task<string>> token;
    private readonly HttpClient http;
    private readonly ILogger<MissionControlService> log;

    public MissionControlService(
        GitHubCredentials credentials, HttpClient http, ILogger<MissionControlService> log)
        : this(credentials.GetMissionControlTokenAsync, http, log, ApiBase, null) {
    }

    internal MissionControlService(
        Func<string, CancellationToken, Task<string>> token, HttpClient http,
        ILogger<MissionControlService> log, Func<string, Uri> apiBase,
        Func<MissionControlConnection, Uri>? webSocketUri = null) {
        this.token = token;
        this.http = http;
        this.log = log;
        resolveApiBase = apiBase;
        resolveWebSocket = webSocketUri;
    }

    public async Task<MissionControlConnection> ConnectAsync(
        MissionControlHost host, string? clientId, CancellationToken token) {
        var path = $"environments/{Uri.EscapeDataString(host.EnvironmentId)}"
            + (clientId is null ? "/connect" : $"/reconnect?client_id={Uri.EscapeDataString(clientId)}");
        var deadline = DateTimeOffset.UtcNow.AddSeconds(35);
        while (true) {
            using var response = await SendAsync(host.GitHubHost, path, token);
            if (response.StatusCode == HttpStatusCode.Accepted) {
                if (DateTimeOffset.UtcNow >= deadline) {
                    throw new InvalidOperationException(
                        $"Mission Control environment {host.EnvironmentId} did not become ready.");
                }
                var delay = response.Headers.RetryAfter?.Delta ?? TimeSpan.FromSeconds(5);
                var remaining = deadline - DateTimeOffset.UtcNow;
                if (delay > remaining) {
                    delay = remaining;
                }
                log.LogInformation(
                    "Mission Control environment {Environment} is waking; retrying in {Delay}s",
                    host.EnvironmentId, delay.TotalSeconds);
                await Task.Delay(delay, token);
                continue;
            }
            await EnsureSuccessAsync(response, $"connect to Mission Control environment {host.EnvironmentId}", token);
            var connection = await ReadJsonAsync<MissionControlConnection>(response, token);
            ValidateConnection(connection, clientId);
            return connection;
        }
    }

    public async Task<IReadOnlyList<MissionControlEnvironment>> ListEnvironmentsAsync(
        string githubHost, CancellationToken token) {
        using var response = await SendAsync(githubHost, "environments", token);
        await EnsureSuccessAsync(response, $"list Mission Control environments on {githubHost}", token);
        return await ReadJsonAsync<MissionControlEnvironment[]>(response, token);
    }

    public Uri WebSocketUri(MissionControlConnection connection) {
        if (resolveWebSocket is not null) {
            return resolveWebSocket(connection);
        }
        if (!Uri.TryCreate(connection.WpsEndpoint, UriKind.Absolute, out var endpoint)
            || endpoint.Scheme != "wss" || !endpoint.Host.EndsWith(".webpubsub.azure.com")
            || endpoint.UserInfo.Length != 0) {
            throw new InvalidDataException("Mission Control returned an invalid Web PubSub endpoint.");
        }
        var builder = new UriBuilder(endpoint);
        var query = builder.Query.TrimStart('?');
        if (query.Length > 0) {
            query += "&";
        }
        query += $"access_token={Uri.EscapeDataString(connection.AccessToken)}";
        query += $"&clientId={Uri.EscapeDataString(connection.ClientId)}";
        builder.Query = query;
        return builder.Uri;
    }

    internal static Uri ApiBase(string githubHost) {
        var host = githubHost.ToLowerInvariant();
        var apiHost = host == "github.com" ? "api.github.com"
            : host.EndsWith(".ghe.com") ? $"api.{host}"
            : throw new InvalidOperationException($"Mission Control is not supported for GitHub host {githubHost}.");
        return new Uri($"https://{apiHost}/cmc_internal/api/agents/");
    }

    private async Task<HttpResponseMessage> SendAsync(string githubHost, string path, CancellationToken token) {
        var credential = await this.token(githubHost, token);
        var request = new HttpRequestMessage(HttpMethod.Get, new Uri(resolveApiBase(githubHost), path));
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", credential);
        request.Headers.UserAgent.ParseAdd("GitHubCopilotCLI");
        try {
            return await http.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, token);
        } finally {
            request.Dispose();
        }
    }

    private static async Task EnsureSuccessAsync(
        HttpResponseMessage response, string operation, CancellationToken token) {
        if (response.IsSuccessStatusCode) {
            return;
        }
        var requestId = response.Headers.TryGetValues("X-GitHub-Request-Id", out var values)
            ? values.FirstOrDefault() : null;
        var detail = requestId is null ? "" : $" (request {requestId})";
        await response.Content.LoadIntoBufferAsync(token);
        throw new HttpRequestException(
            $"Could not {operation}: HTTP {(int)response.StatusCode}{detail}.", null, response.StatusCode);
    }

    private static async Task<T> ReadJsonAsync<T>(HttpResponseMessage response, CancellationToken token) {
        try {
            var value = await response.Content.ReadFromJsonAsync<T>(Json, token);
            return value ?? throw new InvalidDataException("Mission Control returned an empty JSON response.");
        } catch (JsonException ex) {
            throw new InvalidDataException("Mission Control returned invalid JSON.", ex);
        }
    }

    private static void ValidateConnection(MissionControlConnection value, string? expectedClientId) {
        if (string.IsNullOrWhiteSpace(value.AccessToken) || string.IsNullOrWhiteSpace(value.ClientId)
            || string.IsNullOrWhiteSpace(value.Subprotocol) || string.IsNullOrWhiteSpace(value.WpsEndpoint)
            || value.Groups is null || value.HostEncryptionKey is null
            || string.IsNullOrWhiteSpace(value.Groups.Broadcast)
            || string.IsNullOrWhiteSpace(value.Groups.Clients)
            || string.IsNullOrWhiteSpace(value.Groups.ToClient)
            || string.IsNullOrWhiteSpace(value.Groups.ToHost)) {
            throw new InvalidDataException("Mission Control returned incomplete connection credentials.");
        }
        if (expectedClientId is not null && value.ClientId != expectedClientId) {
            throw new InvalidDataException("Mission Control changed the client ID during reconnect.");
        }
        if (value.Subprotocol != "json.reliable.webpubsub.azure.v1") {
            throw new InvalidDataException($"Mission Control returned unsupported subprotocol {value.Subprotocol}.");
        }
        if (value.EnvironmentStatus != "online") {
            throw new InvalidDataException(
                $"Mission Control returned environment status {value.EnvironmentStatus} with connection credentials.");
        }
        if (!DateTimeOffset.TryParse(value.ExpiresAt, out var expires) || expires <= DateTimeOffset.UtcNow) {
            throw new InvalidDataException("Mission Control returned expired connection credentials.");
        }
    }
}
