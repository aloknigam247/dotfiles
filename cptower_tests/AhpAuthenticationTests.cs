using System.Security.Cryptography;
using System.Text.Json;
using CpTower;
using Microsoft.AspNetCore.WebUtilities;
using Sodium;
using Xunit;

namespace CpTower.Tests;

public sealed class AhpAuthenticationTests {
    [Fact]
    public void CreatesAConnectionBoundSealedCredential() {
        const string challenge = "00112233445566778899aabbccddeeff";
        const string resource = "https://api.microsoft.ghe.com";
        const string token = "enterprise-test-token";
        var keys = PublicKeyBox.GenerateKeyPair();
        var keyId = WebEncoders.Base64UrlEncode(SHA256.HashData(keys.PublicKey), 0, 8);
        using var initialized = JsonDocument.Parse($$"""
            {
              "_meta": {
                "copilot.authChallenge": {
                  "challenge": "{{challenge}}",
                  "required": true,
                  "responseMaxAgeSeconds": 300
                },
                "copilot.encryptionRequired": ["auth-token"]
              }
            }
            """);
        using var root = JsonDocument.Parse($$"""
            {
              "_meta": {
                "copilot.encryptionKeys": [
                  {
                    "algorithm": "x25519-sealedbox",
                    "keyId": "{{keyId}}",
                    "publicKey": "{{Convert.ToBase64String(keys.PublicKey)}}",
                    "use": "auth-token"
                  }
                ]
              }
            }
            """);

        var sealedToken = AhpAuthentication.CreateToken(
            initialized.RootElement, root.RootElement, resource, token);

        var parts = sealedToken.Split('.');
        Assert.Equal(new[] { "copilot-sealed", "v1", keyId }, parts[..3]);
        var plaintext = SealedPublicKeyBox.Open(WebEncoders.Base64UrlDecode(parts[3]), keys);
        using var payload = JsonDocument.Parse(plaintext);
        var context = payload.RootElement.GetProperty("ctx");
        var connection = context.GetProperty("connection");
        Assert.Equal("text", payload.RootElement.GetProperty("cty").GetString());
        Assert.Equal(token, payload.RootElement.GetProperty("value").GetString());
        Assert.Equal("auth-token", context.GetProperty("purpose").GetString());
        Assert.Equal(resource, context.GetProperty("resource").GetString());
        Assert.Equal(challenge, connection.GetProperty("challenge").GetString());
        Assert.Matches("^[0-9a-f]{32}$", connection.GetProperty("nonce").GetString()!);
        Assert.InRange(connection.GetProperty("issuedAt").GetInt64(),
            DateTimeOffset.UtcNow.AddMinutes(-1).ToUnixTimeSeconds(), DateTimeOffset.UtcNow.ToUnixTimeSeconds());
    }

    [Fact]
    public void ExtractsGitHubAuthoritiesFromProtectedResources() {
        using var root = JsonDocument.Parse("""
            {
              "agents": [
                {
                  "protectedResources": [
                    { "resource": "https://api.github.com" },
                    { "resource": "https://api.microsoft.ghe.com" },
                    { "resource": "https://example.com" }
                  ]
                }
              ]
            }
            """);

        var resources = AhpAuthentication.Resources(root.RootElement);

        Assert.Equal(new[] {
            new AhpAuthentication.Resource("https://api.github.com", "github.com"),
            new AhpAuthentication.Resource("https://api.microsoft.ghe.com", "microsoft.ghe.com"),
        }, resources);
    }

    [Fact]
    public void RefusesPlaintextWhenTheHostRequiresEncryption() {
        using var initialized = JsonDocument.Parse("""
            { "_meta": { "copilot.encryptionRequired": ["auth-token"] } }
            """);
        using var root = JsonDocument.Parse("""{ "_meta": {} }""");

        var error = Assert.Throws<InvalidDataException>(() => AhpAuthentication.CreateToken(
            initialized.RootElement, root.RootElement, "https://api.github.com", "secret"));

        Assert.Equal("The host did not advertise a supported auth-token encryption key.", error.Message);
    }
}
