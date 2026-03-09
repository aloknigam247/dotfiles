using System;
using System.Collections.Generic;
using System.Management.Automation.Subsystem.Prediction;
using System.Threading;
using System.Threading.Tasks;

namespace PSDirectoryPredictor;

public sealed class DirectoryPredictor : ICommandPredictor, IDisposable
{
    public Guid Id { get; } = new("b5f6c7d8-e9f0-1a2b-3c4d-5e6f7a8b9c0d");
    public string Name => "Directory";
    public string Description => "Fuzzy directory predictor for cd/Set-Location commands";

    private readonly DirectoryHistory _history = new();

    // cd command prefixes to detect (lowercase, with trailing space)
    private static readonly string[] CdPrefixes = { "cd ", "sl ", "chdir ", "set-location " };

    public DirectoryPredictor()
    {
        // Bootstrap history on background thread
        Task.Run(() => _history.BootstrapFromHistoryFile());
    }

    public SuggestionPackage GetSuggestion(
        PredictionClient client,
        PredictionContext context,
        CancellationToken cancellationToken)
    {
        string input = context.InputAst.Extent.Text;
        string? partial = ExtractPartialPath(input);
        if (partial is null)
            return default;

        var matches = _history.GetMatches(partial);
        if (matches.Count == 0)
            return default;

        var suggestions = new List<PredictiveSuggestion>();
        // Determine which cd prefix the user typed
        string cmdPrefix = GetCommandPrefix(input);

        foreach (var (path, _) in matches)
        {
            // Quote paths containing spaces
            string quotedPath = path.Contains(' ') ? $"\"{path}\"" : path;
            suggestions.Add(new PredictiveSuggestion($"{cmdPrefix}{quotedPath}"));
        }

        return new SuggestionPackage(suggestions);
    }

    public bool CanAcceptFeedback(PredictionClient client, PredictorFeedbackKind feedback)
    {
        return feedback is PredictorFeedbackKind.CommandLineAccepted
            or PredictorFeedbackKind.CommandLineExecuted;
    }

    public void OnCommandLineAccepted(PredictionClient client, IReadOnlyList<string> history)
    {
        foreach (var line in history)
        {
            _history.ProcessHistoryLines(line);
        }
    }

    public void OnCommandLineExecuted(PredictionClient client, string commandLine, bool success)
    {
        // Also process on execution for immediate feedback
        if (success)
        {
            _history.ProcessHistoryLines(commandLine);
        }
    }

    public void OnSuggestionDisplayed(PredictionClient client, uint session, int countOrIndex) { }
    public void OnSuggestionAccepted(PredictionClient client, uint session, string acceptedSuggestion) { }

    private static string? ExtractPartialPath(string input)
    {
        string lower = input.ToLowerInvariant();
        foreach (var prefix in CdPrefixes)
        {
            if (lower.StartsWith(prefix))
            {
                string rest = input.Substring(prefix.Length).Trim();
                // Strip leading quotes
                if (rest.StartsWith('"') || rest.StartsWith('\''))
                    rest = rest.Substring(1);
                // Strip trailing quotes
                if (rest.EndsWith('"') || rest.EndsWith('\''))
                    rest = rest.Substring(0, rest.Length - 1);

                return rest.Length > 0 ? rest : null;
            }
        }

        // Also handle -Path / -LiteralPath parameter
        if (lower.StartsWith("set-location"))
        {
            int pathIdx = lower.IndexOf("-path ");
            if (pathIdx < 0) pathIdx = lower.IndexOf("-literalpath ");
            if (pathIdx >= 0)
            {
                int valueStart = input.IndexOf(' ', pathIdx + 1) + 1;
                if (valueStart > 0 && valueStart < input.Length)
                {
                    string rest = input.Substring(valueStart).Trim().Trim('"', '\'');
                    return rest.Length > 0 ? rest : null;
                }
            }
        }

        return null;
    }

    private static string GetCommandPrefix(string input)
    {
        string lower = input.ToLowerInvariant();
        foreach (var prefix in CdPrefixes)
        {
            if (lower.StartsWith(prefix))
                return input.Substring(0, prefix.Length);
        }
        return "cd ";
    }

    public void Dispose() { }
}
