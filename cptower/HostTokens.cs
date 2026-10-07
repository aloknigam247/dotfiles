using System.Text.RegularExpressions;
using Microsoft.AspNetCore.WebUtilities;

namespace CpTower;

/// <summary>
/// Reads the connection tokens shared for token-protected AHP hosts (those started with `/ahp start`)
/// from `$XDG_CONFIG_HOME/cptower/hosts.url` (default `~/.config`). Each line is the host's full connect
/// URL, e.g. `ws://127.0.0.1:54687/?tkn=...`; its port maps the token to the host listening there.
/// Lines starting with `#` are comments. The file is re-read on every refresh and never written here.
/// </summary>
internal static partial class HostTokens {
    public static string FilePath { get; } = Path.Combine(ConfigHome(), "cptower", "hosts.url");

    /// <summary>Returns the shared tokens per port, the most recently added (last) line first.</summary>
    public static ILookup<int, string> Load() {
        var entries = new List<(int Port, string Token)>();
        try {
            foreach (var line in File.ReadLines(FilePath)) {
                if (TryParse(line, out var port, out var token)) {
                    entries.Add((port, token));
                }
            }
        } catch (Exception ex) when (ex is IOException or UnauthorizedAccessException) {
            // A missing or unreadable file just means no tokens have been shared.
        }

        entries.Reverse();
        return entries.ToLookup(e => e.Port, e => e.Token);
    }

    private static string ConfigHome() {
        var xdg = Environment.GetEnvironmentVariable("XDG_CONFIG_HOME");
        return !string.IsNullOrWhiteSpace(xdg) && Path.IsPathFullyQualified(xdg)
            ? xdg
            : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".config");
    }

    private static bool TryParse(string line, out int port, out string token) {
        port = 0;
        token = "";
        var text = line.Trim();
        if (text.StartsWith('#')) {
            return false;
        }

        var match = UrlPattern().Match(text);
        if (!match.Success
            || !Uri.TryCreate(match.Value, UriKind.Absolute, out var uri)
            || !uri.IsLoopback
            || uri.IsDefaultPort
            || !QueryHelpers.ParseQuery(uri.Query).TryGetValue("tkn", out var values)
            || string.IsNullOrEmpty(values.ToString())) {
            return false;
        }

        port = uri.Port;
        token = values.ToString();
        return true;
    }

    [GeneratedRegex(@"ws://[^\s""']+")]
    private static partial Regex UrlPattern();
}
