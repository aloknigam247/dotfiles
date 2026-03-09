using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;

namespace PSDirectoryPredictor;

public sealed class DirectoryHistory
{
    private readonly Dictionary<string, DirectoryEntry> _entries = new(StringComparer.OrdinalIgnoreCase);
    private readonly ReaderWriterLockSlim _lock = new();
    private volatile List<DirectoryEntry> _snapshot = new();

    // Regex to extract path from cd/Set-Location commands
    private static readonly Regex CdRegex = new(
        @"^\s*(?:cd|sl|chdir|Set-Location)\s+(?:-(?:Path|LiteralPath)\s+)?[""']?(.+?)[""']?\s*$",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);

    public void BootstrapFromHistoryFile()
    {
        string historyPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "Microsoft", "Windows", "PowerShell", "PSReadLine",
            "ConsoleHost_history.txt");

        if (!File.Exists(historyPath)) return;

        try
        {
            // Read last 5000 lines
            var allLines = File.ReadAllLines(historyPath);
            int start = Math.Max(0, allLines.Length - 5000);
            var lines = new ArraySegment<string>(allLines, start, allLines.Length - start);

            // Use a rough timestamp: spread entries over the last month for frecency
            var baseTime = DateTime.UtcNow.AddDays(-30);
            double step = 30.0 / Math.Max(lines.Count, 1);

            int idx = 0;
            foreach (var line in lines)
            {
                var path = ExtractPath(line);
                if (path is not null)
                {
                    var timestamp = baseTime.AddDays(step * idx);
                    AddEntry(path, timestamp);
                }
                idx++;
            }
        }
        catch
        {
            // Swallow — best effort bootstrap
        }
    }

    public void ProcessHistoryLines(string commandLine)
    {
        var path = ExtractPath(commandLine);
        if (path is not null)
        {
            AddEntry(path, DateTime.UtcNow);
        }
    }

    public List<(string Path, double Score)> GetMatches(string partial, int maxResults = 2)
    {
        var entries = _snapshot; // volatile read — no lock needed
        var results = new List<(string Path, double Score)>();

        foreach (var entry in entries)
        {
            // Match against full path
            int fullScore = FuzzyMatcher.Score(partial, entry.FullPath);

            // Also match against last segment (directory name)
            string lastSegment = Path.GetFileName(entry.FullPath.TrimEnd('\\', '/'));
            int segScore = lastSegment.Length > 0 ? FuzzyMatcher.Score(partial, lastSegment) : -1;

            int matchScore = Math.Max(fullScore, segScore);
            if (matchScore < 0) continue;

            double frecency = entry.GetFrecencyScore();
            double combined = matchScore * 2.0 + frecency;

            results.Add((entry.FullPath, combined));
        }

        results.Sort((a, b) => b.Score.CompareTo(a.Score));
        if (results.Count > maxResults)
            results.RemoveRange(maxResults, results.Count - maxResults);

        return results;
    }

    private static string? ExtractPath(string line)
    {
        var match = CdRegex.Match(line);
        if (!match.Success) return null;

        string raw = match.Groups[1].Value.Trim();
        if (string.IsNullOrWhiteSpace(raw)) return null;

        // Skip if it looks like a variable or expression
        if (raw.StartsWith('$') || raw.StartsWith('(')) return null;

        return NormalizePath(raw);
    }

    private static string? NormalizePath(string raw)
    {
        try
        {
            // Expand ~ to home directory
            if (raw.StartsWith('~'))
            {
                string home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                raw = Path.Combine(home, raw.Length > 1 ? raw.Substring(2) : "");
            }

            // Expand environment variables
            raw = Environment.ExpandEnvironmentVariables(raw);

            // Normalize separators and get full path (best effort)
            raw = raw.Replace('/', '\\');
            if (Path.IsPathRooted(raw))
            {
                raw = Path.GetFullPath(raw);
            }

            // Remove trailing separator unless root
            if (raw.Length > 3 && raw.EndsWith('\\'))
                raw = raw.TrimEnd('\\');

            return raw;
        }
        catch
        {
            return null;
        }
    }

    private void AddEntry(string path, DateTime timestamp)
    {
        _lock.EnterWriteLock();
        try
        {
            if (_entries.TryGetValue(path, out var existing))
            {
                existing.VisitCount++;
                if (timestamp > existing.LastVisited)
                    existing.LastVisited = timestamp;
            }
            else
            {
                _entries[path] = new DirectoryEntry
                {
                    FullPath = path,
                    VisitCount = 1,
                    LastVisited = timestamp
                };
            }

            // Rebuild snapshot
            _snapshot = new List<DirectoryEntry>(_entries.Values);
        }
        finally
        {
            _lock.ExitWriteLock();
        }
    }
}

public class DirectoryEntry
{
    public string FullPath { get; set; } = string.Empty;
    public int VisitCount { get; set; }
    public DateTime LastVisited { get; set; }

    public double GetFrecencyScore()
    {
        var age = DateTime.UtcNow - LastVisited;
        double recency;

        if (age.TotalHours < 1) recency = 4.0;
        else if (age.TotalDays < 1) recency = 2.0;
        else if (age.TotalDays < 7) recency = 1.0;
        else if (age.TotalDays < 30) recency = 0.5;
        else recency = 0.25;

        return VisitCount * recency;
    }
}
