using System.Text;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.WebUtilities;

namespace CpTower;

/// <summary>
/// The connect URLs shared for token-protected AHP hosts (those started with `/ahp start`) in
/// `$XDG_CONFIG_HOME/cptower/hosts.url` (default `~/.config`), a file edited by hand. Each line is a
/// host's full connect URL, e.g. `ws://127.0.0.1:54687/?tkn=...`; its port maps the token to the host
/// listening there. Discovery re-reads the file on every refresh and prunes the lines that are no
/// longer live; every other line (comments starting with `#`, blanks) is left untouched.
/// </summary>
internal static partial class HostTokens {
    /// <summary>A connection line: its loopback port and the token it carries (null when it has none).</summary>
    public readonly record struct Entry(int Port, string? Token);

    public static string FilePath { get; } = Path.Combine(ConfigHome(), "cptower", "hosts.url");

    /// <summary>Returns the listed tokens per port, the most recently added (last) line first.</summary>
    public static ILookup<int, string?> Load() {
        var entries = new List<Entry>();
        if (TryRead(out var text, out _)) {
            foreach (Match line in LinePattern().Matches(text)) {
                if (TryParse(line.Value, out var entry)) {
                    entries.Add(entry);
                }
            }
        }

        entries.Reverse();
        return entries.ToLookup(e => e.Port, e => e.Token);
    }

    /// <summary>
    /// Removes the connection lines <paramref name="isDead"/> selects and returns them. The file is
    /// rewritten only when a line is removed, and not at all when it changed after being read, so an
    /// edit saved meanwhile is never overwritten (the next pass prunes instead).
    /// </summary>
    public static List<Entry> Prune(Func<Entry, bool> isDead) {
        var kept = new StringBuilder();
        var removed = new List<Entry>();
        if (!TryRead(out var text, out var stamp)) {
            return removed;
        }

        foreach (Match line in LinePattern().Matches(text)) {
            if (TryParse(line.Value, out var entry) && isDead(entry)) {
                removed.Add(entry);
            } else {
                kept.Append(line.Value);
            }
        }

        if (removed.Count == 0 || File.GetLastWriteTimeUtc(FilePath) != stamp) {
            return [];
        }

        File.WriteAllText(FilePath, kept.ToString());
        return removed;
    }

    private static string ConfigHome() {
        var xdg = Environment.GetEnvironmentVariable("XDG_CONFIG_HOME");
        return !string.IsNullOrWhiteSpace(xdg) && Path.IsPathFullyQualified(xdg)
            ? xdg
            : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".config");
    }

    private static bool TryParse(string line, out Entry entry) {
        entry = default;
        var text = line.Trim();
        if (text.StartsWith('#')) {
            return false;
        }

        var match = UrlPattern().Match(text);
        if (!match.Success
            || !Uri.TryCreate(match.Value, UriKind.Absolute, out var uri)
            || !uri.IsLoopback
            || uri.IsDefaultPort) {
            return false;
        }

        var token = QueryHelpers.ParseQuery(uri.Query).TryGetValue("tkn", out var values) ? values.ToString() : "";
        entry = new Entry(uri.Port, token.Length > 0 ? token : null);
        return true;
    }

    private static bool TryRead(out string text, out DateTime stamp) {
        stamp = default;
        text = "";
        try {
            stamp = File.GetLastWriteTimeUtc(FilePath);
            text = File.ReadAllText(FilePath);
            return true;
        } catch (Exception ex) when (ex is IOException or UnauthorizedAccessException) {
            // A missing or unreadable file just means no hosts have been shared.
            return false;
        }
    }

    /// <summary>One line including its terminator, so kept lines keep their line endings.</summary>
    [GeneratedRegex(@"[^\n]*\n|[^\n]+$")]
    private static partial Regex LinePattern();

    [GeneratedRegex(@"ws://[^\s""']+")]
    private static partial Regex UrlPattern();
}
