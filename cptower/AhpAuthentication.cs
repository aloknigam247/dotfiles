using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.WebUtilities;
using Sodium;

namespace CpTower;

internal static class AhpAuthentication {
    internal readonly record struct AuthenticationKey(
        string Algorithm, string KeyId, string PublicKey, string Use);

    internal readonly record struct Resource(string Uri, string Host);

    public static IReadOnlyList<Resource> Resources(JsonElement root) {
        var resources = new List<Resource>();
        if (!root.TryGetProperty("agents", out var agents) || agents.ValueKind != JsonValueKind.Array) {
            throw new InvalidDataException("The AHP root snapshot has no agents array.");
        }

        foreach (var agent in agents.EnumerateArray()) {
            if (!agent.TryGetProperty("protectedResources", out var protectedResources)) {
                continue;
            }
            if (protectedResources.ValueKind != JsonValueKind.Array) {
                throw new InvalidDataException("The AHP host advertised invalid protected resources.");
            }

            foreach (var resource in protectedResources.EnumerateArray()) {
                if (!resource.TryGetProperty("resource", out var value) || value.ValueKind != JsonValueKind.String) {
                    throw new InvalidDataException("The AHP host advertised an invalid protected resource.");
                }
                var address = value.GetString()!;
                if (!System.Uri.TryCreate(address, UriKind.Absolute, out var uri)
                    || uri.Scheme != "https" || !uri.IsDefaultPort || uri.UserInfo.Length != 0
                    || uri.AbsolutePath != "/" || uri.Query.Length != 0 || uri.Fragment.Length != 0) {
                    continue;
                }

                var host = uri.Host;
                if (host == "api.github.com" || (host.StartsWith("api.") && host.EndsWith(".ghe.com"))) {
                    resources.Add(new Resource(address, host["api.".Length..]));
                }
            }
        }

        return resources.Distinct().ToArray();
    }

    public static string CreateToken(
        JsonElement initialized, JsonElement root, string resource, string token,
        AuthenticationKey? trustedKey = null) {
        var encryptionRequired = false;
        var hasAuthKey = false;
        JsonElement? recipient = null;
        var initializeMeta = Metadata(initialized);
        var rootMeta = Metadata(root);
        if (initializeMeta is { } meta && meta.TryGetProperty("copilot.encryptionRequired", out var purposes)) {
            if (purposes.ValueKind != JsonValueKind.Array) {
                throw new InvalidDataException("The host advertised invalid token encryption requirements.");
            }
            foreach (var purpose in purposes.EnumerateArray()) {
                if (purpose.ValueKind != JsonValueKind.String) {
                    throw new InvalidDataException("The host advertised an invalid token encryption purpose.");
                }
                encryptionRequired |= purpose.GetString() == "auth-token";
            }
        }

        var connection = ConnectionContext(initializeMeta);
        if (rootMeta is { } stateMeta && stateMeta.TryGetProperty("copilot.encryptionKeys", out var keys)) {
            if (keys.ValueKind != JsonValueKind.Array) {
                throw new InvalidDataException("The host advertised invalid encryption keys.");
            }
            foreach (var key in keys.EnumerateArray()) {
                if (StringProperty(key, "use") != "auth-token") {
                    continue;
                }
                hasAuthKey = true;
                if (StringProperty(key, "algorithm") == "x25519-sealedbox") {
                    recipient = key;
                    break;
                }
            }
        }

        if (recipient is not { } selected) {
            if (connection is not null || encryptionRequired || hasAuthKey) {
                throw new InvalidDataException("The host did not advertise a supported auth-token encryption key.");
            }
            return token;
        }

        var encodedKey = StringProperty(selected, "publicKey");
        var keyId = StringProperty(selected, "keyId");
        var algorithm = StringProperty(selected, "algorithm");
        var use = StringProperty(selected, "use");
        if (trustedKey is { Algorithm: not "x25519-sealedbox" }) {
            throw new InvalidDataException(
                "Mission Control selected an auth-token encryption algorithm cptower does not support.");
        }
        if (trustedKey is { } trusted && (trusted.Algorithm != algorithm || trusted.KeyId != keyId
            || trusted.PublicKey != encodedKey || trusted.Use != use)) {
            throw new InvalidDataException("The AHP host key does not match the key trusted through Mission Control.");
        }
        byte[] publicKey;
        try {
            publicKey = Convert.FromBase64String(encodedKey);
        } catch (FormatException) {
            throw new InvalidDataException("The host advertised an invalid authentication public key.");
        }
        if (publicKey.Length != SealedPublicKeyBox.RecipientPublicKeyBytes
            || Convert.ToBase64String(publicKey) != encodedKey
            || WebEncoders.Base64UrlEncode(SHA256.HashData(publicKey), 0, 8) != keyId) {
            throw new InvalidDataException("The host's authentication key does not match its key ID.");
        }

        var plaintext = JsonSerializer.SerializeToUtf8Bytes(new {
            cty = "text",
            ctx = new { connection, purpose = "auth-token", resource },
            value = token,
        }, new JsonSerializerOptions { DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull });
        try {
            var ciphertext = SealedPublicKeyBox.Create(plaintext, publicKey);
            return $"copilot-sealed.v1.{keyId}.{WebEncoders.Base64UrlEncode(ciphertext)}";
        } finally {
            CryptographicOperations.ZeroMemory(plaintext);
        }
    }

    private static object? ConnectionContext(JsonElement? metadata) {
        if (metadata is not { } meta || !meta.TryGetProperty("copilot.authChallenge", out var binding)) {
            return null;
        }
        if (binding.ValueKind != JsonValueKind.Object
            || !binding.TryGetProperty("required", out var required)
            || required.ValueKind is not (JsonValueKind.False or JsonValueKind.True)) {
            throw new InvalidDataException("The host advertised an invalid authentication challenge.");
        }
        if (!required.GetBoolean() && !binding.TryGetProperty("challenge", out _)) {
            return null;
        }

        var challenge = StringProperty(binding, "challenge");
        if (challenge.Length != 32 || challenge.Any(c => c is not (>= '0' and <= '9' or >= 'a' and <= 'f'))
            || (binding.TryGetProperty("responseMaxAgeSeconds", out var age)
                && (!age.TryGetInt32(out var seconds) || seconds <= 0))) {
            throw new InvalidDataException("The host advertised an invalid authentication challenge.");
        }
        return new {
            challenge,
            issuedAt = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
            nonce = Convert.ToHexStringLower(RandomNumberGenerator.GetBytes(16)),
        };
    }

    private static JsonElement? Metadata(JsonElement value) {
        if (!value.TryGetProperty("_meta", out var metadata)) {
            return null;
        }
        if (metadata.ValueKind != JsonValueKind.Object) {
            throw new InvalidDataException("The host advertised invalid AHP metadata.");
        }
        return metadata;
    }

    private static string StringProperty(JsonElement value, string name) {
        if (value.ValueKind != JsonValueKind.Object || !value.TryGetProperty(name, out var property)
            || property.ValueKind != JsonValueKind.String || string.IsNullOrWhiteSpace(property.GetString())) {
            throw new InvalidDataException($"The host's authentication metadata has an invalid {name}.");
        }
        return property.GetString()!;
    }
}
