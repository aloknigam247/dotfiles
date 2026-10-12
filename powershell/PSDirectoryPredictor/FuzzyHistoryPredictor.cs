using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation.Subsystem.Prediction;
using System.Threading;
using System.Threading.Tasks;

namespace PSDirectoryPredictor;

public sealed class FuzzyHistoryPredictor : ICommandPredictor, IDisposable {
    public Guid Id { get; } = new("c6a7d8e9-f0a1-2b3c-4d5e-6f7a8b9c0d1e");
    public string Name => "FuzzyHistory";
    public string Description => "Fuzzy history predictor for all commands";

    private readonly object _lock = new();
    private readonly Dictionary<string, HistoryEntry> _entries = new(StringComparer.OrdinalIgnoreCase);
    private volatile List<HistoryEntry> _snapshot = new();

    public FuzzyHistoryPredictor() {
        Task.Run(() => BootstrapFromHistoryFile());
    }

    private void BootstrapFromHistoryFile() {
        string historyPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "Microsoft", "Windows", "PowerShell", "PSReadLine",
            "ConsoleHost_history.txt");

        if (!File.Exists(historyPath)) return;

        try {
            var allLines = File.ReadAllLines(historyPath);
            int start = Math.Max(0, allLines.Length - 5000);
            var baseTime = DateTime.UtcNow.AddDays(-30);
            double step = 30.0 / Math.Max(allLines.Length - start, 1);

            lock (_lock) {
                for (int i = start; i < allLines.Length; i++) {
                    string line = allLines[i].Trim();
                    if (line.Length > 0) {
                        UpsertEntry(line, baseTime.AddDays(step * (i - start)));
                    }
                }
                _snapshot = new List<HistoryEntry>(_entries.Values);
            }
        } catch {
            // Best effort bootstrap
        }
    }

    public SuggestionPackage GetSuggestion(
        PredictionClient client,
        PredictionContext context,
        CancellationToken cancellationToken) {
        string input = context.InputAst.Extent.Text;
        if (string.IsNullOrWhiteSpace(input) || input.Length < 2)
            return default;

        var entries = _snapshot;
        var scored = new List<(string Command, double Score)>();

        foreach (var entry in entries) {
            if (entry.Command.Equals(input, StringComparison.OrdinalIgnoreCase))
                continue;

            int matchScore = FuzzyMatcher.Score(input, entry.Command);
            if (matchScore < 0) continue;

            double frecency = GetFrecencyScore(entry);
            double combined = matchScore * 2.0 + frecency;
            scored.Add((entry.Command, combined));
        }

        scored.Sort((a, b) => b.Score.CompareTo(a.Score));

        int count = Math.Min(scored.Count, 5);
        if (count == 0) return default;

        var suggestions = new List<PredictiveSuggestion>(count);
        for (int i = 0; i < count; i++) {
            suggestions.Add(new PredictiveSuggestion(scored[i].Command));
        }
        return new SuggestionPackage(suggestions);
    }

    public bool CanAcceptFeedback(PredictionClient client, PredictorFeedbackKind feedback) {
        return feedback is PredictorFeedbackKind.CommandLineAccepted
            or PredictorFeedbackKind.CommandLineExecuted;
    }

    public void OnCommandLineAccepted(PredictionClient client, IReadOnlyList<string> history) {
        foreach (var line in history) {
            string trimmed = line.Trim();
            if (trimmed.Length > 0 && !trimmed.Contains('\n') && !trimmed.Contains('\r')) {
                AddEntry(trimmed, DateTime.UtcNow);
            }
        }
    }

    public void OnCommandLineExecuted(PredictionClient client, string commandLine, bool success) {
        if (success) {
            string trimmed = commandLine.Trim();
            if (trimmed.Length > 0 && !trimmed.Contains('\n') && !trimmed.Contains('\r')) {
                AddEntry(trimmed, DateTime.UtcNow);
            }
        }
    }

    public void OnSuggestionDisplayed(PredictionClient client, uint session, int countOrIndex) { }
    public void OnSuggestionAccepted(PredictionClient client, uint session, string acceptedSuggestion) { }

    private void AddEntry(string command, DateTime timestamp) {
        lock (_lock) {
            UpsertEntry(command, timestamp);
            _snapshot = new List<HistoryEntry>(_entries.Values);
        }
    }

    private void UpsertEntry(string command, DateTime timestamp) {
        if (_entries.TryGetValue(command, out var existing)) {
            existing.VisitCount++;
            if (timestamp > existing.LastUsed)
                existing.LastUsed = timestamp;
        } else {
            _entries[command] = new HistoryEntry {
                Command = command,
                VisitCount = 1,
                LastUsed = timestamp
            };
        }
    }

    private static double GetFrecencyScore(HistoryEntry entry) {
        var age = DateTime.UtcNow - entry.LastUsed;
        double recency;
        if (age.TotalHours < 1) recency = 4.0;
        else if (age.TotalDays < 1) recency = 2.0;
        else if (age.TotalDays < 7) recency = 1.0;
        else if (age.TotalDays < 30) recency = 0.5;
        else recency = 0.25;
        return entry.VisitCount * recency;
    }

    public void Dispose() { }

    private class HistoryEntry {
        public string Command { get; set; } = string.Empty;
        public int VisitCount { get; set; }
        public DateTime LastUsed { get; set; }
    }
}
