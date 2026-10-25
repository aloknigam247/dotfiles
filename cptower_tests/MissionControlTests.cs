using System.Net;
using System.Text;
using CpTower;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace CpTower.Tests;

public sealed class MissionControlTests {
    [Fact]
    public void FindsAuthenticatedHostsAndCanFilterByLogin() {
        const string json = """
            {
              "hosts": {
                "github.com": [
                  { "active": true, "login": "", "state": "error" },
                  { "active": false, "login": "other", "state": "success" }
                ],
                "microsoft.ghe.com": [
                  { "active": true, "login": "aloknigam", "state": "success" }
                ]
              }
            }
            """;

        Assert.Equal(["github.com", "microsoft.ghe.com"], GitHubCredentials.AuthenticatedHosts(json, null));
        Assert.Equal(["github.com"], GitHubCredentials.AuthenticatedHosts(json, "other"));
    }

    [Fact]
    public async Task ListsEnvironmentsAndMintsConnectionCredentials() {
        var requests = new List<HttpRequestMessage>();
        using var http = new HttpClient(new FakeHandler(request => {
            requests.Add(Clone(request));
            var body = request.RequestUri!.AbsolutePath.EndsWith("/connect")
                ? """
                    {
                      "access_token": "wps-secret",
                      "client_id": "client-1",
                      "encrypted_github_token": "copilot-sealed.v1.key.payload",
                      "encrypted_github_token_scope": "user",
                      "environment_status": "online",
                      "expires_at": "2099-10-24T15:00:00Z",
                      "groups": {
                        "broadcast": "broadcast",
                        "clients": "clients",
                        "to_client": "to-client",
                        "to_host": "to-host"
                      },
                      "host_encryption_key": {
                        "algorithm": "x25519-sealedbox",
                        "key_id": "key",
                        "public_key": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                        "use": "auth-token"
                      },
                      "hub": "hub",
                      "subprotocol": "json.reliable.webpubsub.azure.v1",
                      "wps_endpoint": "wss://example.webpubsub.azure.com/client/hubs/hub"
                    }
                    """
                : """
                    [{
                      "capabilities": {
                        "ahp_version": "1.0.0",
                        "current_sessions": 3,
                        "max_sessions": null
                      },
                      "id": "environment-1",
                      "kind": "user-local",
                      "name": "Copilot CLI",
                      "status": "online"
                    }]
                    """;
            return new HttpResponseMessage(HttpStatusCode.OK) {
                Content = new StringContent(body, Encoding.UTF8, "application/json"),
            };
        }));
        var service = new MissionControlService(
            (host, _) => Task.FromResult(host == "microsoft.ghe.com" ? "github-secret" : ""),
            http, NullLogger<MissionControlService>.Instance,
            _ => new Uri("https://api.test/cmc_internal/api/agents/"));

        var environments = await service.ListEnvironmentsAsync("microsoft.ghe.com", CancellationToken.None);
        var connection = await service.ConnectAsync(
            new MissionControlHost("environment-1", "microsoft.ghe.com"), null, CancellationToken.None);
        var uri = service.WebSocketUri(connection);

        var environment = Assert.Single(environments);
        Assert.Equal("environment-1", environment.Id);
        Assert.Equal("1.0.0", environment.Capabilities!.AhpVersion);
        Assert.Equal(3, environment.Capabilities.CurrentSessions);
        Assert.Equal("client-1", connection.ClientId);
        Assert.Equal("json.reliable.webpubsub.azure.v1", connection.Subprotocol);
        Assert.Equal("example.webpubsub.azure.com", uri.Host);
        Assert.Contains("access_token=wps-secret", uri.Query);
        Assert.Contains("clientId=client-1", uri.Query);
        Assert.Equal(2, requests.Count);
        Assert.All(requests, request => {
            Assert.Equal("Bearer", request.Headers.Authorization!.Scheme);
            Assert.Equal("github-secret", request.Headers.Authorization.Parameter);
            Assert.Contains("GitHubCopilotCLI", request.Headers.UserAgent.ToString());
        });
    }

    [Fact]
    public void SyntheticRoutesAreStableAndResolveCollisions() {
        var used = new HashSet<int>();
        var first = MissionControlDiscovery.Route("microsoft.ghe.com", "environment-1", used);
        var duplicate = MissionControlDiscovery.Route("microsoft.ghe.com", "environment-1",
            new HashSet<int> { first });
        var repeated = MissionControlDiscovery.Route("microsoft.ghe.com", "environment-1", new HashSet<int>());

        Assert.InRange(first, 1_000_000_000, 1_999_999_999);
        Assert.Equal(first, repeated);
        Assert.NotEqual(first, duplicate);
    }

    private static HttpRequestMessage Clone(HttpRequestMessage request) {
        var copy = new HttpRequestMessage(request.Method, request.RequestUri);
        foreach (var header in request.Headers) {
            copy.Headers.TryAddWithoutValidation(header.Key, header.Value);
        }
        return copy;
    }

    private sealed class FakeHandler(Func<HttpRequestMessage, HttpResponseMessage> handle) : HttpMessageHandler {
        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request, CancellationToken cancellationToken) =>
            Task.FromResult(handle(request));
    }
}
