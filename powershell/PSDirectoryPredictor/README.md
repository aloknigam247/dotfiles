# PSDirectoryPredictor

A PowerShell 7 [command predictor](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors) module that provides two predictors, both ranked by frecency (frequency + recency):

| Predictor | Tag | Description |
|---|---|---|
| **Directory** | `[Directory]` | Suggests directories when typing `cd` or `Set-Location` |
| **FuzzyHistory** | `[FuzzyHistory]` | Fuzzy matches against all command history |

## How it works

Both predictors bootstrap from the last 5000 lines of PSReadLine history (`ConsoleHost_history.txt`) and watch executed commands in real time.

### Directory predictor

Triggers on `cd`/`Set-Location` commands and suggests matching directory paths.

Supported commands:
- `cd <path>`
- `Set-Location <path>`
- `Set-Location -Path <path>`
- `Set-Location -LiteralPath <path>`
- `sl <path>`, `chdir <path>`

### FuzzyHistory predictor

Triggers on any input (minimum 2 characters) and suggests matching commands from history. Exact matches are skipped since PSReadLine already handles those. Returns up to 5 suggestions.

### Fuzzy matching

Subsequence-based scorer with bonuses for:
- Consecutive character matches
- Matches at path segment boundaries (`\`, `/`, `-`, `_`)
- Exact case matches
- First character matches

### Frecency scoring

Entries are scored by visit count weighted by recency:

| Last visited | Weight |
|---|---|
| < 1 hour | 4.0 |
| < 1 day | 2.0 |
| < 1 week | 1.0 |
| < 1 month | 0.5 |
| Older | 0.25 |

## Build

Requires .NET 8 SDK.

```powershell
dotnet build -c Release
```

Output goes to `bin/Release/net8.0/`.

## Install

```powershell
Import-Module path\to\PSDirectoryPredictor.psd1
```

To load on startup, add the `Import-Module` line to your `$PROFILE`.

## Requirements

- PowerShell 7.2+
- .NET 8.0
