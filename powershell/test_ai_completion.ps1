param(
    [string]$ProfilePath = (Join-Path $PSScriptRoot "profile.ps1")
)

if ([Environment]::GetCommandLineArgs() -notcontains "-NoProfile" -or
    [Environment]::GetCommandLineArgs() -notcontains "-File") {
    throw "Run in an isolated process: pwsh -NoProfile -File `"$PSCommandPath`"."
}

$assertions = 0
$global:copilot_context = "long_context"
$global:copilot_model = "test-model"
$global:copilot_reasoning_effort = "high"
$effortValues = @("high", "low", "max", "medium", "minimal", "none", "xhigh")
$ErrorActionPreference = "Stop"
$functionNames = @("_ParseRootArg", "agency", "ai", "copilot", "Get-AgencySubcommands", "Get-AiBackend")
$parseErrors = $null
$personalNames = @("catppuccin", "duplicate", "personal", "'quote''agent'", "'space agent'")
$projectNames = @("duplicate", "project")
$PSNativeCommandUseErrorActionPreference = $false
$sourceValues = @("company", "organization", "personal", "playground", "repo", "spec")
$tokens = $null

Set-StrictMode -Version Latest

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
    $script:assertions++
}

function Assert-Set {
    param([object[]]$Actual, [object[]]$Expected, [string]$Message)
    $actualJson = ConvertTo-Json -InputObject @($Actual | Sort-Object -CaseSensitive) -Compress
    $expectedJson = ConvertTo-Json -InputObject @($Expected | Sort-Object -CaseSensitive) -Compress
    Assert-True ($actualJson -ceq $expectedJson) "$Message`nExpected: $expectedJson`nActual: $actualJson"
}

function Assert-Sequence {
    param([object[]]$Actual, [object[]]$Expected, [string]$Message)
    $actualJson = ConvertTo-Json -InputObject @($Actual) -Compress
    $expectedJson = ConvertTo-Json -InputObject @($Expected) -Compress
    Assert-True ($actualJson -ceq $expectedJson) "$Message`nExpected: $expectedJson`nActual: $actualJson"
}

function Get-CompletionResults {
    param([string]$Line, [int]$Cursor = -1)
    if ($Cursor -lt 0) {
        $Cursor = $Line.Length
    }
    $previousDenyGit = $global:AiCompletionTest.DenyGit
    $global:AiCompletionTest.DenyGit = $true
    try {
        [System.Management.Automation.CommandCompletion]::CompleteInput($Line, $Cursor, $null).CompletionMatches
    } finally {
        $global:AiCompletionTest.DenyGit = $previousDenyGit
    }
}

function Assert-Completion {
    param([string]$Line, [string[]]$Expected, [int]$Cursor = -1)
    $actual = @(Get-CompletionResults $Line $Cursor | ForEach-Object CompletionText)
    Assert-Set $actual $Expected "Completion mismatch: $Line (cursor $Cursor)"
}

function Get-HelpFlags {
    param([string]$HelpText)
    $flags = @(
        foreach ($match in [regex]::Matches($HelpText, "(?m)^\s+(?:-[A-Za-z],\s+)?(--[a-z][a-z0-9-]*)\b")) {
            $match.Groups[1].Value
        }
        foreach ($match in [regex]::Matches($HelpText, "(?m)^\s+(-[A-Za-z])(?:,\s+--|\s+<)")) {
            $match.Groups[1].Value
        }
        foreach ($aliases in [regex]::Matches($HelpText, "\[aliases: ([^\]]+)\]")) {
            foreach ($match in [regex]::Matches($aliases.Groups[1].Value, "--[a-z][a-z0-9-]*")) {
                $match.Value
            }
        }
    )
    $flags | Sort-Object -CaseSensitive -Unique
}

function New-AgentFixture {
    param([string]$Directory, [string]$Name)
    [System.IO.Directory]::CreateDirectory($Directory) | Out-Null
    [System.IO.File]::WriteAllText(
        (Join-Path $Directory $Name),
        "---`nname: unrelated_display_name`ndescription: completion fixture`n---`nFixture instructions.`n"
    )
}

function Invoke-WrapperCapture {
    param([string]$Command, [string[]]$Arguments, [bool]$FailEngine = $false)
    $global:AiCompletionTest.EngineArguments = @()
    $global:AiCompletionTest.EngineCommand = ""
    $global:AiCompletionTest.FailEngine = $FailEngine
    $global:AiCompletionTest.Launches.Clear()
    $global:AiCompletionTest.Prompts.Clear()
    $global:AiCompletionTest.TerminalArguments = @()
    & $Command @Arguments | Out-Null
    $terminalArguments = $global:AiCompletionTest.TerminalArguments
    Assert-True ($terminalArguments.Count -gt 0) "$Command did not reach the inert terminal stub."
    $body = @($terminalArguments | Where-Object { $_ -is [scriptblock] })
    Assert-True ($body.Count -eq 1) "$Command did not pass exactly one terminal script block."
    $argumentIndex = [Array]::IndexOf($terminalArguments, "-args")
    Assert-True ($argumentIndex -ge 0) "$Command omitted terminal script arguments."
    $bodyArguments = $terminalArguments[$argumentIndex + 1]
    & $body[0] @bodyArguments 2>&1 | Out-Null
}

$copilotEnums = @{
    "--context" = @("default", "long_context")
    "--effort" = $effortValues
    "--log-level" = @("all", "debug", "default", "error", "info", "none", "warning")
    "--mode" = @("autopilot", "interactive", "plan")
    "--output-format" = @("json", "text")
    "--reasoning-effort" = $effortValues
    "--stream" = @("off", "on")
}
$profileAst = [System.Management.Automation.Language.Parser]::ParseFile(
    $ProfilePath, [ref]$tokens, [ref]$parseErrors)
Assert-True ($parseErrors.Count -eq 0) "Profile parse errors: $(@($parseErrors | ForEach-Object Message) -join '; ')"
$registrations = @($profileAst.FindAll({
    param($node)
    $node -is [System.Management.Automation.Language.CommandAst] -and
        $node.GetCommandName() -eq "Register-ArgumentCompleter" -and
        $node.Extent.Text -match "-CommandName\s+(?:agency|ai|copilot)\b"
}, $false))
Assert-True ($registrations.Count -eq 1) `
    "Expected one shared native registration for agency, ai, and copilot; found $($registrations.Count)."
$registration = $registrations[0]
$nameParameter = @($registration.CommandElements | Where-Object {
    $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq "CommandName"
})[0]
$nameIndex = [Array]::IndexOf(@($registration.CommandElements), $nameParameter)
Assert-Set @($registration.CommandElements[$nameIndex + 1].SafeGetValue()) @("agency", "ai", "copilot") `
    "The shared registration must cover exactly the three wrappers."
Assert-True ($registration.Extent.Text -match "\s-Native\b") "The shared registration must be native."

foreach ($name in $functionNames) {
    $definition = $profileAst.Find({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }, $false)
    Assert-True ($null -ne $definition) "Missing production function: $name"
    Set-Item -Path "Function:\global:$name" -Value $definition.Body.GetScriptBlock()
}

$copilotHelp = copilot.exe --help | Out-String
Assert-True ($LASTEXITCODE -eq 0) "copilot.exe --help failed."
$agencyHelp = agency.exe copilot --help | Out-String
Assert-True ($LASTEXITCODE -eq 0) "agency.exe copilot --help failed."
$agencyFlags = @(Get-HelpFlags (($agencyHelp -split "EXTRA_ARGS you can pass:", 2)[0]))
$commandSection = [regex]::Match($copilotHelp, "(?ms)^Commands:\r?\n(.*?)^Options:").Groups[1].Value
$copilotCommands = @(
    [regex]::Matches($commandSection, "(?m)^  ([a-z][a-z-]*)\s") | ForEach-Object { $_.Groups[1].Value }
    "plugins"
) | Sort-Object -CaseSensitive -Unique
$copilotFlags = @((Get-HelpFlags $copilotHelp) + @("--effort", "--enable-reasoning-summaries")) |
    Sort-Object -CaseSensitive -Unique
Assert-True ($copilotCommands -contains "login") "Copilot command help parsing did not find login."
Assert-True ($copilotFlags -contains "--model") "Copilot flag help parsing did not find --model."
Assert-True ($agencyFlags -contains "--profile") "Agency flag help parsing did not find --profile."

$global:AiCompletionTest = @{
    AgentReads = [System.Collections.Generic.List[string]]::new()
    Backend = (Get-Item "Function:\Get-AiBackend").ScriptBlock
    BackendCalls = [System.Collections.Generic.List[string]]::new()
    DenyGit = $false
    EngineArguments = @()
    EngineCommand = ""
    FailDirectory = ""
    FailEngine = $false
    GitCalls = [System.Collections.Generic.List[string]]::new()
    GitExecutable = (Get-Command git -CommandType Application).Source
    Launches = [System.Collections.Generic.List[string]]::new()
    Prompts = [System.Collections.Generic.List[string]]::new()
    TerminalArguments = @()
    Warnings = [System.Collections.Generic.List[string]]::new()
}

function global:Get-AiBackend {
    param([string]$RootDir)
    $global:AiCompletionTest.BackendCalls.Add($RootDir)
    $previousDenyGit = $global:AiCompletionTest.DenyGit
    $global:AiCompletionTest.DenyGit = $true
    try {
        & $global:AiCompletionTest.Backend -RootDir $RootDir
    } finally {
        $global:AiCompletionTest.DenyGit = $previousDenyGit
    }
}

function global:Get-ChildItem {
    [CmdletBinding()]
    param([string]$LiteralPath, [string]$Filter, [switch]$File)
    $global:AiCompletionTest.AgentReads.Add($LiteralPath)
    if ($LiteralPath -eq $global:AiCompletionTest.FailDirectory) {
        throw [System.UnauthorizedAccessException]::new("Fixture access denied.")
    }
    Microsoft.PowerShell.Management\Get-ChildItem @PSBoundParameters
}

function global:git {
    if ($global:AiCompletionTest.DenyGit) {
        $global:AiCompletionTest.GitCalls.Add(($args -join " "))
        throw "Backend lookup and completion must not invoke Git."
    }
    & $global:AiCompletionTest.GitExecutable @args
    $global:LASTEXITCODE = $LASTEXITCODE
}

function global:Write-Warning {
    [CmdletBinding()]
    param([string]$Message)
    $global:AiCompletionTest.Warnings.Add($Message)
    Microsoft.PowerShell.Utility\Write-Warning -Message $Message
}

function global:Start-CpTower {
    $global:AiCompletionTest.Launches.Add("Start-CpTower")
}

function global:wt {
    $global:AiCompletionTest.Launches.Add("wt")
    $global:AiCompletionTest.TerminalArguments = @($args)
}

function global:agency.exe {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments)][object[]]$EngineArguments)
    $ErrorActionPreference = "Continue"
    $global:AiCompletionTest.EngineArguments = @($EngineArguments)
    $global:AiCompletionTest.EngineCommand = "agency.exe"
    $global:AiCompletionTest.Launches.Add("agency.exe")
    if ($global:AiCompletionTest.FailEngine) {
        $record = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new("Fixture engine failure."),
            "FixtureEngineFailure", "OperationStopped", $null)
        $PSCmdlet.WriteError($record)
    }
}

function global:copilot.exe {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments)][object[]]$EngineArguments)
    $ErrorActionPreference = "Continue"
    $global:AiCompletionTest.EngineArguments = @($EngineArguments)
    $global:AiCompletionTest.EngineCommand = "copilot.exe"
    $global:AiCompletionTest.Launches.Add("copilot.exe")
    if ($global:AiCompletionTest.FailEngine) {
        $record = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new("Fixture engine failure."),
            "FixtureEngineFailure", "OperationStopped", $null)
        $PSCmdlet.WriteError($record)
    }
}

function global:Read-Host {
    param([string]$Prompt)
    $global:AiCompletionTest.Prompts.Add($Prompt)
}

. ([scriptblock]::Create($registration.Extent.Text))

$initialHome = $env:COPILOT_HOME
$initialLocation = Get-Location
$fixtureId = [guid]::NewGuid().ToString()
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\tmp\ai_completion_$fixtureId"))
$outsideRoot = Join-Path ([System.IO.Path]::GetTempPath()) "ai_completion_$fixtureId"
$azureRoot = Join-Path $fixtureRoot "azure"
$githubRoot = Join-Path $fixtureRoot "github"
$noOriginRoot = Join-Path $fixtureRoot "no_origin"
$pathRoot = Join-Path $fixtureRoot "paths"
$userRoot = Join-Path $fixtureRoot "user"
$userAgents = Join-Path $userRoot "agents"
$projectAgents = Join-Path $githubRoot ".github\agents"
$allAgentNames = @($personalNames + $projectNames) | Sort-Object -CaseSensitive -Unique
$allCopilot = @($copilotCommands + $copilotFlags + "--root") | Sort-Object -CaseSensitive -Unique
$allAgency = @($allCopilot + $agencyFlags + (Get-AgencySubcommands) + @("copilot", "cp")) |
    Sort-Object -CaseSensitive -Unique

try {
    foreach ($directory in @($azureRoot, $githubRoot, $noOriginRoot, $outsideRoot, $pathRoot, $userRoot)) {
        [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    }
    foreach ($repository in @($azureRoot, $githubRoot, $noOriginRoot)) {
        git -C $repository init --quiet
        Assert-True ($LASTEXITCODE -eq 0) "Could not initialize fixture repository: $repository"
    }
    git -C $azureRoot remote add origin "https://dev.azure.com/example/project/_git/repo"
    Assert-True ($LASTEXITCODE -eq 0) "Could not add the non-GitHub fixture origin."
    git -C $githubRoot remote add origin "https://github.com/example/repo.git"
    Assert-True ($LASTEXITCODE -eq 0) "Could not add the GitHub fixture origin."
    foreach ($name in @(
        "catppuccin.agent.md", "duplicate.agent.md", "personal.md", "quote'agent.agent.md", "space agent.md"
    )) {
        New-AgentFixture $userAgents $name
    }
    foreach ($name in @("duplicate.md", "project.agent.md")) {
        New-AgentFixture $projectAgents $name
    }
    New-AgentFixture (Join-Path $azureRoot ".github\agents") "ado.agent.md"
    New-AgentFixture (Join-Path $outsideRoot ".github\agents") "outside.agent.md"
    [System.IO.File]::WriteAllText((Join-Path $userAgents "ignored.txt"), "Not an agent.")
    $env:COPILOT_HOME = $userRoot
    Set-Location $githubRoot

    Assert-True ((Get-AiBackend $githubRoot) -eq "copilot") "File-only GitHub routing failed."
    Assert-Completion "copilot " $allCopilot
    Assert-Completion "agency " $allAgency
    Assert-Completion "ai " $allCopilot
    foreach ($command in @("agency", "agency copilot", "agency cp", "ai", "copilot")) {
        Assert-Completion "$command --mo" @("--mode", "--model", "--mouse")
        Assert-Completion "$command --MO" @("--mode", "--model", "--mouse")
        $line = "$command --model auto"
        # PowerShell supplies the complete token even when the caret is inside it.
        Assert-Completion $line @("--model") ($line.IndexOf("--model") + "--mo".Length)
        foreach ($option in $copilotEnums.Keys | Sort-Object) {
            Assert-Completion "$command $option " $copilotEnums[$option]
            Assert-Completion "$command $option=$($copilotEnums[$option][0])" `
                @("$option=$($copilotEnums[$option][0])")
        }
        Assert-Completion "$command --mode p" @("plan")
        Assert-Completion "$command --mode 'p'" @("plan")
        $line = "$command --mode p --model auto"
        Assert-Completion $line @("plan") $line.IndexOf(" --model")
        $line = "$command --mode plan --model auto"
        Assert-Completion $line @("plan") ($line.IndexOf("plan") + "p".Length)
        Assert-Completion "$command --agent ca" @("catppuccin")
        Assert-Completion "$command --agent=ca" @("--agent=catppuccin")
        Assert-Completion "$command --agent `"ca`"" @("catppuccin")
        Assert-Completion "$command --agent='quote''ag'" @("--agent='quote''agent'")
    }
    foreach ($command in @("agency", "agency copilot", "agency cp")) {
        Assert-Completion "$command --pro" @("--profile", "--profile-only", "--project", "--prompt")
        foreach ($option in @("--agent-type", "--source", "--type")) {
            Assert-Completion "$command $option " $sourceValues
            Assert-Completion "$command $option pe" @("personal")
            Assert-Completion "$command $option=pe" @("$option=personal")
        }
        Assert-Completion "$command --result-type " @("pr", "standard")
        Assert-Completion "$command -a ca" @("catppuccin")
    }
    Assert-Completion "agency copilot " @(
        @($allCopilot + $agencyFlags) | Sort-Object -CaseSensitive -Unique
    )
    Assert-Completion "agency cp " @(
        @($allCopilot + $agencyFlags) | Sort-Object -CaseSensitive -Unique
    )
    Assert-Completion "agency finish" @("finish-pr")
    Assert-Completion "agency finish-pr " @("--help", "--root")
    Assert-Completion "agency config --" @("--help", "--root")
    Assert-Completion "agency --mode plan finish-pr --mo" @("--mode", "--model", "--mouse")
    Assert-Completion "copilot login --mo" @("--mode", "--model", "--mouse")
    Assert-Completion "copilot login m" @()
    Assert-Completion "copilot.exe --mo" @()
    Assert-Completion "agency.exe --mo" @()
    Assert-Completion "copilot --agent " $allAgentNames
    Assert-Completion "copilot --agent quo" @("'quote''agent'")
    Assert-Completion "copilot --agent=spa" @("--agent='space agent'")
    Assert-Completion "agency --source personal --agent " $personalNames
    Assert-Completion "agency --source repo --agent " $projectNames
    foreach ($sourceOption in @("--agent-type", "--source", "--type")) {
        Assert-Completion "agency $sourceOption=repo -a " $projectNames
    }
    foreach ($source in @("company", "organization", "playground", "spec")) {
        Assert-Completion "agency --source $source --agent ca" @()
    }

    New-AgentFixture $userAgents "new_agent.agent.md"
    Assert-Completion "copilot --agent new_" @("new_agent")
    [System.IO.File]::Delete((Join-Path $userAgents "new_agent.agent.md"))
    Assert-Completion "copilot --agent new_" @()

    $global:AiCompletionTest.FailDirectory = $userAgents
    $global:AiCompletionTest.Warnings.Clear()
    Assert-Completion "copilot --agent pro" @("project")
    Assert-True ($global:AiCompletionTest.Warnings.Count -gt 0) "An unreadable agent source must report a warning."
    Assert-True ($global:AiCompletionTest.Warnings[0].Contains($userAgents)) "The warning must identify its source."
    $global:AiCompletionTest.FailDirectory = ""

    $nestedRoot = Join-Path $githubRoot "nested\child"
    [System.IO.Directory]::CreateDirectory($nestedRoot) | Out-Null
    Set-Location $nestedRoot
    Assert-Completion "copilot --agent pro" @("project")
    Assert-Completion "ai --pro" @("--prompt")
    Assert-Completion "ai --root `"$azureRoot`" --pro" @("--profile", "--profile-only", "--project", "--prompt")
    Assert-Completion "copilot --root `"$azureRoot`" --agent ad" @("ado")
    Assert-Completion "agency --root `"$azureRoot`" --agent ad" @("ado")
    Assert-Completion "agency --root `"$azureRoot`" finish-pr --" @("--help", "--root")

    $linkedRoot = Join-Path $fixtureRoot "linked"
    New-AgentFixture (Join-Path $linkedRoot ".github\agents") "linked.agent.md"
    [System.IO.File]::WriteAllText((Join-Path $linkedRoot ".git"), "gitdir: $(Join-Path $githubRoot '.git')`n")
    git -C $linkedRoot rev-parse --git-dir | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) "The worktree-style gitfile fixture must be recognized by Git."
    Set-Location $linkedRoot
    Assert-Completion "copilot --agent lin" @("linked")
    Assert-Completion "ai --pro" @("--prompt")

    $commonRoot = Join-Path $fixtureRoot "linked common"
    $commonGitDir = Join-Path $githubRoot ".git"
    $worktreeGitDir = Join-Path $commonGitDir "worktrees\completion"
    New-AgentFixture (Join-Path $commonRoot ".github\agents") "shared.agent.md"
    [System.IO.Directory]::CreateDirectory($worktreeGitDir) | Out-Null
    [System.IO.File]::Copy((Join-Path $commonGitDir "HEAD"), (Join-Path $worktreeGitDir "HEAD"))
    [System.IO.File]::WriteAllText(
        (Join-Path $worktreeGitDir "commondir"),
        [System.IO.Path]::GetRelativePath($worktreeGitDir, $commonGitDir))
    [System.IO.File]::WriteAllText(
        (Join-Path $commonRoot ".git"),
        "gitdir: $([System.IO.Path]::GetRelativePath($commonRoot, $worktreeGitDir))")
    git -C $commonRoot rev-parse --git-dir | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) "Git must recognize the relative gitdir/commondir fixture."
    $commonNested = Join-Path $commonRoot "src\child"
    [System.IO.Directory]::CreateDirectory($commonNested) | Out-Null
    Set-Location $commonNested
    Assert-True ((Get-AiBackend $commonNested) -eq "copilot") "Relative commondir routing failed."
    Assert-Completion "ai --pro" @("--prompt")
    Assert-Completion "ai --agent sha" @("shared")
    git -C $githubRoot remote set-url origin "https://dev.azure.com/example/project/_git/repo"
    Assert-True ($LASTEXITCODE -eq 0) "Could not change the fixture origin."
    Assert-Completion "ai --pro" @("--profile", "--profile-only", "--project", "--prompt")
    Assert-True ((Get-AiBackend $commonNested) -eq "agency") "The shared config change was not visible immediately."
    git -C $githubRoot remote set-url origin "https://github.com/example/repo.git"
    Assert-True ($LASTEXITCODE -eq 0) "Could not restore the fixture origin."
    Assert-Completion "ai --pro" @("--prompt")

    $noOriginConfig = Join-Path $noOriginRoot ".git\config"
    $originalConfig = [System.IO.File]::ReadAllText($noOriginConfig)
    foreach ($case in @(
        @{
            Backend = "agency"
            Config = @(
                "[remote `"origin`"]"
                "    url = https://dev.azure.com/example/project/_git/repo # github.com is only a comment"
            )
            Name = "comment does not change the host"
        },
        @{
            Backend = "agency"
            Config = @(
                "[remote `"origin`"]"
                "    url = https://dev.azure.com/example/project/_git/repo"
                "    url = https://github.com/example/repo.git"
            )
            Name = "first URL wins"
        },
        @{
            Backend = "agency"
            Config = @("[remote `"Origin`"]", "    url = https://github.com/example/repo.git")
            Name = "origin name is case-sensitive"
        },
        @{
            Backend = "copilot"
            Config = @(
                "  [REMOTE `"origin`" ] ; section comment"
                "    URL = `"https://github.com/example/repo.git`" # URL comment"
            )
            Name = "quotes and section whitespace"
        },
        @{
            Backend = "agency"
            Config = @("[remote `"upstream`"]", "    url = https://github.com/example/repo.git")
            Name = "unrelated remote is ignored"
        }
    )) {
        $configText = $case.Config -join "`n"
        [System.IO.File]::WriteAllText($noOriginConfig, "$originalConfig`n$configText`n")
        Assert-True ((Get-AiBackend $noOriginRoot) -eq $case.Backend) "Config parsing failed: $($case.Name)"
    }
    [System.IO.File]::WriteAllText($noOriginConfig, $originalConfig)
    Assert-True ((Get-AiBackend $noOriginRoot) -eq "agency") "Removing the origin must be visible immediately."

    $brokenRoot = Join-Path $fixtureRoot "broken_gitdir"
    $missingConfigRoot = Join-Path $fixtureRoot "missing_config"
    [System.IO.Directory]::CreateDirectory($brokenRoot) | Out-Null
    [System.IO.Directory]::CreateDirectory((Join-Path $missingConfigRoot ".git")) | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $brokenRoot ".git"), "Not a gitdir pointer.")
    [System.IO.File]::WriteAllText((Join-Path $worktreeGitDir "commondir"), "")
    foreach ($case in @(
        @{ Message = "Invalid gitdir pointer:"; Root = $brokenRoot },
        @{ Message = "Invalid commondir pointer:"; Root = $commonRoot },
        @{ Message = "config"; Root = $missingConfigRoot }
    )) {
        $failure = $null
        try {
            Get-AiBackend $case.Root | Out-Null
        } catch {
            $failure = $_
        }
        Assert-True ($null -ne $failure) "Broken Git metadata must not silently choose a backend."
        Assert-True ($failure.Exception.Message -match $case.Message) "The error must identify the broken metadata."
    }

    foreach ($route in @(
        @{ Backend = "agency"; Root = $azureRoot },
        @{ Backend = "agency"; Root = $noOriginRoot },
        @{ Backend = "copilot"; Root = $githubRoot },
        @{ Backend = "copilot"; Root = $outsideRoot }
    )) {
        Set-Location $route.Root
        Assert-True ((Get-AiBackend $route.Root) -eq $route.Backend) "Incorrect backend for $($route.Root)."
        $expected = if ($route.Backend -eq "agency") { $allAgency } else { $allCopilot }
        Assert-Completion "ai " $expected
        Assert-Completion "ai --mode p" @("plan")
    }
    Assert-Completion "copilot --agent out" @("outside")

    [System.IO.Directory]::CreateDirectory((Join-Path $pathRoot "plain")) | Out-Null
    [System.IO.Directory]::CreateDirectory((Join-Path $pathRoot "space directory")) | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $pathRoot "ordinary.txt"), "Filename fallback fixture.")
    Set-Location $pathRoot
    foreach ($command in @("agency", "agency cp", "ai", "copilot")) {
        $paths = @(Get-CompletionResults "$command --root ")
        Assert-Set @($paths.ListItemText) @("plain", "space directory") "$command must complete directories."
        Assert-True (@($paths | Where-Object ResultType -NE ProviderContainer).Count -eq 0) `
            "$command --root returned a non-directory while directories matched."
        $spacePath = @(Get-CompletionResults "$command --root spa")
        Assert-True ($spacePath.Count -eq 1) "$command must complete the directory prefix."
        Assert-True ($spacePath[0].CompletionText -match "^['`"].*space directory['`"]$") `
            "$command must quote paths containing spaces."
        $absolutePaths = @(Get-CompletionResults "$command --root `"$pathRoot\spa")
        Assert-True ($absolutePaths.Count -eq 1) "$command must complete a quoted absolute directory prefix."
        Assert-True ($absolutePaths[0].ResultType -eq "ProviderContainer") "The absolute result must be a directory."
    }
    foreach ($line in @("copilot --mode *", "agency --agent *", "copilot --agent no_match_")) {
        $fallback = @(Get-CompletionResults $line)
        Assert-True (@($fallback | Where-Object {
            $_.ResultType -notin @("ProviderContainer", "ProviderItem")
        }).Count -eq 0) `
            "No-match input must not produce fabricated catalog candidates: $line"
    }
    $wildcardFallback = @(Get-CompletionResults "copilot --mode *")
    Assert-True ($wildcardFallback.Count -gt 0) "The native wildcard filename fallback must remain available."
    $env:COPILOT_HOME = Join-Path $fixtureRoot "missing_home"
    $emptyFallback = @(Get-CompletionResults "copilot --agent ")
    Assert-True ($emptyFallback.Count -gt 0) "Missing local agents must preserve native filename fallback."
    Assert-True (@($emptyFallback | Where-Object {
        $_.ResultType -notin @("ProviderContainer", "ProviderItem")
    }).Count -eq 0) "Missing local agents must not produce fake names."
    $env:COPILOT_HOME = $userRoot

    foreach ($command in @("agency", "ai", "copilot")) {
        $global:AiCompletionTest.AgentReads.Clear()
        $global:AiCompletionTest.BackendCalls.Clear()
        Assert-Completion "$command --mo" @("--mode", "--model", "--mouse")
        Assert-Completion "$command --mode p" @("plan")
        Assert-True ($global:AiCompletionTest.AgentReads.Count -eq 0) "Non-agent completion scanned agent directories."
        if ($command -eq "ai") {
            Assert-True ($global:AiCompletionTest.BackendCalls.Count -gt 0) "ai must resolve its actual backend."
        } else {
            Assert-True ($global:AiCompletionTest.BackendCalls.Count -eq 0) "$command performed an ai backend lookup."
        }
    }
    Assert-True ($global:AiCompletionTest.Launches.Count -eq 0) "Completion invoked a launcher or AI executable."
    Assert-True ($global:AiCompletionTest.GitCalls.Count -eq 0) "Backend lookup or completion attempted to invoke Git."

    Set-Location $githubRoot
    Invoke-WrapperCapture "agency" @("--root", $azureRoot, "finish-pr", "https://example.test/pr")
    Assert-Set $global:AiCompletionTest.Prompts @("Press any key to exit") "Native Agency commands must pause."
    Assert-Sequence $global:AiCompletionTest.EngineArguments @("finish-pr", "https://example.test/pr") `
        "The native Agency command must forward its original arguments."
    Assert-True ($global:AiCompletionTest.TerminalArguments[2] -eq $azureRoot) "The wrapper lost its root directory."
    foreach ($alias in @("copilot", "cp")) {
        Invoke-WrapperCapture "agency" @($alias, "--mode", "plan")
        Assert-Sequence $global:AiCompletionTest.EngineArguments @($alias, "--mode", "plan") `
            "Explicit passthrough changed."
        Assert-True ($global:AiCompletionTest.Prompts.Count -eq 0) "Successful explicit passthrough must not pause."
        Invoke-WrapperCapture "agency" @($alias, "--mode", "plan") $true
        Assert-Set $global:AiCompletionTest.Prompts @("Agency exited with error, press any key to exit") `
            "Failed explicit passthrough must still pause."
    }
    Invoke-WrapperCapture "agency" @("--mode", "plan", "finish-pr")
    Assert-Sequence $global:AiCompletionTest.EngineArguments @(
        "copilot", "--model", "test-model", "--reasoning-effort", "high", "--context", "long_context",
        "--mode", "plan", "finish-pr"
    ) "The default Agency engine path or configured defaults changed."
    Assert-True ($global:AiCompletionTest.Prompts.Count -eq 0) "The successful default engine path must not pause."
    Invoke-WrapperCapture "ai" @("--root", $azureRoot, "--mode", "plan")
    Assert-True ($global:AiCompletionTest.EngineCommand -eq "agency.exe") "ai ignored its non-GitHub --root."
    Invoke-WrapperCapture "ai" @("--root", $githubRoot, "--mode", "plan")
    Assert-True ($global:AiCompletionTest.EngineCommand -eq "copilot.exe") "ai ignored its GitHub --root."
    Assert-Sequence $global:AiCompletionTest.EngineArguments @(
        "--model", "test-model", "--reasoning-effort", "high", "--context", "long_context", "--mode", "plan"
    ) "Copilot arguments or configured defaults changed."
    foreach ($command in @("agency", "ai", "copilot")) {
        $failure = $null
        $global:AiCompletionTest.Launches.Clear()
        try {
            & $command --root (Join-Path $fixtureRoot "does_not_exist")
        } catch {
            $failure = $_
        }
        Assert-True ($null -ne $failure) "$command must still reject an invalid root."
        Assert-True ($failure.Exception.Message -match "Invalid directory:") "$command changed its root error."
        Assert-True (@($global:AiCompletionTest.Launches | Where-Object { $_ -ne "Start-CpTower" }).Count -eq 0) `
            "$command launched a terminal despite an invalid root."
    }

    Write-Output "PASS: $assertions assertions across agency, ai, and copilot."
    Write-Output "Profile: $([System.IO.Path]::GetFullPath($ProfilePath))"
} finally {
    Set-Location $initialLocation
    $env:COPILOT_HOME = $initialHome
    foreach ($directory in @($fixtureRoot, $outsideRoot)) {
        if ([System.IO.Directory]::Exists($directory)) {
            [System.IO.Directory]::Delete($directory, $true)
        }
    }
}
