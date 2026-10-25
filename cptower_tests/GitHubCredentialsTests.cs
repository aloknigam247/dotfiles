using CpTower;
using Xunit;

namespace CpTower.Tests;

public sealed class GitHubCredentialsTests {
    [Fact]
    public void UsesAnEnvironmentTokenOnlyForItsConfiguredHost() {
        var environment = new Dictionary<string, string?> {
            ["COPILOT_GH_HOST"] = "microsoft.ghe.com",
            ["GH_TOKEN"] = "enterprise-token",
        };

        string? Read(string name) => environment.GetValueOrDefault(name);

        Assert.Equal("enterprise-token", GitHubCredentials.EnvironmentToken("microsoft.ghe.com", Read));
        Assert.Null(GitHubCredentials.EnvironmentToken("github.com", Read));
    }

    [Fact]
    public void DefaultsAnEnvironmentTokenToGitHubDotCom() {
        var environment = new Dictionary<string, string?> { ["GH_TOKEN"] = "github-token" };

        string? Read(string name) => environment.GetValueOrDefault(name);

        Assert.Equal("github-token", GitHubCredentials.EnvironmentToken("github.com", Read));
    }
}
