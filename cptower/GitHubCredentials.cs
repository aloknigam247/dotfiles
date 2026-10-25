using System.ComponentModel;
using System.Diagnostics;
using System.Text.Json;

namespace CpTower;

internal sealed class GitHubCredentials(
    string? githubUser, ILogger<GitHubCredentials>? log = null) {
    public async Task<IReadOnlyList<string>> GetHostsAsync(CancellationToken token) {
        var hosts = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (ConfiguredHost(Environment.GetEnvironmentVariable) is { } configured) {
            hosts.Add(configured);
        }

        Process process;
        try {
            process = Process.Start(StartGh("auth", "status", "--no-refresh", "--json", "hosts"))
                ?? throw new InvalidOperationException("Could not start the GitHub CLI.");
        } catch (Win32Exception) {
            if (hosts.Count > 0) {
                return hosts.Order().ToArray();
            }
            throw new InvalidOperationException("Install gh or configure COPILOT_GH_HOST with a matching token.");
        }
        using (process) {
            var error = process.StandardError.ReadToEndAsync(token);
            var output = process.StandardOutput.ReadToEndAsync(token);
            await Task.WhenAll(output, error, process.WaitForExitAsync(token));
            if (process.ExitCode != 0) {
                if (hosts.Count > 0) {
                    return hosts.Order().ToArray();
                }
                throw new InvalidOperationException("Could not list authenticated GitHub hosts.");
            }
            try {
                var status = await output;
                log?.LogDebug("gh auth status returned {Length} character(s)", status.Length);
                using (var document = JsonDocument.Parse(status)) {
                    foreach (var property in document.RootElement.GetProperty("hosts").EnumerateObject()) {
                        log?.LogDebug("gh host {Host} reported account state(s): {States}",
                            property.Name, string.Join(", ", property.Value.EnumerateArray().Select(account =>
                                account.TryGetProperty("state", out var state) ? state.GetString() : "missing")));
                    }
                }
                foreach (var host in AuthenticatedHosts(status, githubUser)) {
                    hosts.Add(host);
                }
            } catch (Exception ex) when (ex is JsonException or InvalidOperationException) {
                throw new InvalidOperationException("gh returned invalid authentication status JSON.", ex);
            }
        }
        return hosts.Order().ToArray();
    }

    internal static IReadOnlyList<string> AuthenticatedHosts(string json, string? user) {
        using var document = JsonDocument.Parse(json);
        var hosts = new List<string>();
        foreach (var property in document.RootElement.GetProperty("hosts").EnumerateObject()) {
            var valid = property.Value.EnumerateArray().Any(account =>
                account.TryGetProperty("state", out var state) && state.GetString() == "success"
                && (user is null || account.TryGetProperty("login", out var login)
                    && login.GetString() == user));
            if (valid) {
                hosts.Add(property.Name);
            }
        }
        return hosts;
    }

    public async Task<string> GetTokenAsync(string host, CancellationToken token) {
        if (githubUser is null && EnvironmentToken(host, Environment.GetEnvironmentVariable) is { } configured) {
            return configured;
        }

        return await GetStoredTokenAsync(host, token);
    }

    public Task<string> GetMissionControlTokenAsync(string host, CancellationToken token) =>
        ConfiguredHost(Environment.GetEnvironmentVariable) is { } configured
            && configured.Equals(host, StringComparison.OrdinalIgnoreCase)
            ? GetTokenAsync(host, token)
            : GetStoredTokenAsync(host, token);

    private async Task<string> GetStoredTokenAsync(string host, CancellationToken token) {
        var start = StartGh("auth", "token", "--hostname", host);
        if (githubUser is not null) {
            start.ArgumentList.Add("--user");
            start.ArgumentList.Add(githubUser);
        }
        foreach (var name in new[] {
            "COPILOT_GITHUB_TOKEN", "GH_ENTERPRISE_TOKEN", "GH_TOKEN", "GITHUB_ENTERPRISE_TOKEN", "GITHUB_TOKEN",
        }) {
            start.Environment.Remove(name);
        }

        Process process;
        try {
            process = Process.Start(start) ?? throw new InvalidOperationException("Could not start the GitHub CLI.");
        } catch (Win32Exception) {
            throw new InvalidOperationException("Install gh or set a GitHub token and its matching GH_HOST.");
        }
        using (process) {
            try {
                var error = process.StandardError.ReadToEndAsync(token);
                var output = process.StandardOutput.ReadToEndAsync(token);
                await Task.WhenAll(output, error, process.WaitForExitAsync(token));
                var value = (await output).Trim();
                if (process.ExitCode != 0 || value.Length == 0) {
                    throw new InvalidOperationException(
                        $"No gh credential for {githubUser ?? "the active account"} on {host}; "
                        + $"run gh auth login --hostname {host}.");
                }
                return value;
            } finally {
                if (!process.HasExited) {
                    process.Kill(entireProcessTree: true);
                }
            }
        }
    }

    internal static string? EnvironmentToken(string host, Func<string, string?> environment) {
        var token = new[] { "COPILOT_GITHUB_TOKEN", "GH_TOKEN", "GITHUB_TOKEN" }
            .Select(environment).FirstOrDefault(value => !string.IsNullOrWhiteSpace(value));
        if (token is null) {
            return null;
        }

        var configuredHost = ConfiguredHost(environment) ?? "github.com";
        return configuredHost.Equals(host, StringComparison.OrdinalIgnoreCase) ? token.Trim() : null;
    }

    internal static string? ConfiguredHost(Func<string, string?> environment) {
        var configuredHost = environment("COPILOT_GH_HOST") ?? environment("GH_HOST");
        if (string.IsNullOrWhiteSpace(configuredHost)) {
            return null;
        }
        var address = configuredHost.Contains("://") ? configuredHost : $"https://{configuredHost}";
        if (!Uri.TryCreate(address, UriKind.Absolute, out var uri) || uri.Scheme != "https"
            || uri.UserInfo.Length != 0 || !uri.IsDefaultPort || uri.AbsolutePath != "/"
            || uri.Query.Length != 0 || uri.Fragment.Length != 0) {
            throw new InvalidOperationException("COPILOT_GH_HOST or GH_HOST is not a valid GitHub host.");
        }
        return uri.Host;
    }

    private static ProcessStartInfo StartGh(params string[] arguments) {
        var start = new ProcessStartInfo("gh") {
            CreateNoWindow = true,
            RedirectStandardError = true,
            RedirectStandardOutput = true,
            UseShellExecute = false,
        };
        foreach (var argument in arguments) {
            start.ArgumentList.Add(argument);
        }
        return start;
    }
}
