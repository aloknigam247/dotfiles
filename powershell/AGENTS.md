# PowerShell navigation

## Profile startup

[setup.ps1](setup.ps1) maps `profile.ps1` to PowerShell 7's all-users/all-hosts profile and maps
`profile5.ps1` to the Windows PowerShell profile. It also links the GitCompleter module directory.

[profile.ps1](profile.ps1) returns before loading configuration if `_IsShellInteractive` is false.
Register GitCompleter after PSFzf so it replaces PSFzf's Git completer.

Do not source the full profile as an unattended check: its interactive `Auto Update` job can pull, commit, and push.
The [profile5.ps1](profile5.ps1) file contains only `./profile.ps1`; do not assume it supplies a separate module stack.

## Module and feature lookup

| Area | Start here |
| --- | --- |
| AI command routing | `Get-AiBackend`, `agency`, `ai`, and `copilot` in `profile.ps1`. |
| AI completion | `Update-CopilotModelCompletion` and the `agency, ai, copilot` completer in `profile.ps1`. |
| Git completion | [GitCompleter.psm1](GitCompleter/GitCompleter.psm1): `Register-GitCompleter` and its helpers. |
| Prediction | [PSDirectoryPredictor](PSDirectoryPredictor/README.md): repository-owned C# module; its [project](PSDirectoryPredictor/PSDirectoryPredictor.csproj) builds outside the checkout. |
| Prompt and themes | `Get-GitStatus`, `_populatePrompt`, `prompt`, and the `_set*Theme` functions in `profile.ps1`. |
| PSFzf | External module imported and configured in the `FZF Setup` section of `profile.ps1`. |
| Service launcher | `Start-CpTower` in `profile.ps1`; service navigation is in the [cptower guide](../cptower/AGENTS.md). |

For adding a module or exporting completion helpers, follow the
[repository instructions](../.github/copilot-instructions.md#adding-a-powershell-module-package).
