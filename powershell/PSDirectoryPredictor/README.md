# PSDirectoryPredictor

A PowerShell 7 [command predictor](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors) that suggests directories when typing `cd` or `Set-Location`, ranked by frecency (frequency + recency).

## How it works

1. On import, bootstraps from the last 5000 lines of PSReadLine history (`ConsoleHost_history.txt`)
2. Watches executed commands in real time for `cd`/`Set-Location` invocations
3. When you start typing `cd <partial>`, suggests matching directories using fuzzy matching combined with a frecency score

### Fuzzy matching

Subsequence-based scorer with bonuses for:
- Consecutive character matches
- Matches at path segment boundaries (`\`, `/`, `-`, `_`)
- Exact case matches
- First character matches

### Frecency scoring

Directories are scored by visit count weighted by recency:

| Last visited | Weight |
|---|---|
| < 1 hour | 4.0 |
| < 1 day | 2.0 |
| < 1 week | 1.0 |
| < 1 month | 0.5 |
| Older | 0.25 |

## Supported commands

- `cd <path>`
- `Set-Location <path>`
- `Set-Location -Path <path>`
- `Set-Location -LiteralPath <path>`
- `sl <path>`, `chdir <path>`

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
