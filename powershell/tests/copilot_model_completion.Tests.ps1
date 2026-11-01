Describe "Copilot model completion and maintenance" {
    BeforeAll {
        $errors = $null
        $tokens = $null
        $script:originalLocation = $PWD.Path
        $script:originalProfile = $PROFILE
        $script:repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $script:profilePath = Join-Path $script:repositoryRoot "powershell\profile.ps1"
        $script:fixtureRoot = Join-Path $script:repositoryRoot (
            "tmp\copilot_model_completion_$([guid]::NewGuid().ToString())")
        New-Item -ItemType Directory -Path $script:fixtureRoot -Force | Out-Null

        $script:profileAst = [System.Management.Automation.Language.Parser]::ParseFile(
            $script:profilePath, [ref]$tokens, [ref]$errors)
        if ($errors.Count) {
            throw ($errors.Message -join "`n")
        }
        $definitions = @($script:profileAst.EndBlock.Statements | Where-Object {
            ($_ -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -in @(
                "_ParseRootArg", "agency", "ai", "copilot", "Get-AgencySubcommands", "Get-AiBackend",
                "Update-CopilotModelCompletion"
            )) -or ($_ -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $_.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $_.Left.VariablePath.UserPath -eq "script:copilotModels")
        })
        $script:registrations = @($script:profileAst.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.GetCommandName() -eq "Register-ArgumentCompleter" -and
                $node.Extent.Text -match "-CommandName agency, ai, copilot"
        }, $false))
        $script:definitionSource = (@($definitions.Extent.Text) + $script:registrations[0].Extent.Text) -join "`n"
        . ([scriptblock]::Create($script:definitionSource))
        $script:productionModels = @($script:copilotModels)

        function Get-CompletionText {
            param([string]$Line)
            (TabExpansion2 $Line $Line.Length).CompletionMatches | ForEach-Object CompletionText
        }

        function Get-SourceBytes {
            [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($script:sourcePath))
        }

        function Set-FixtureProfile {
            param(
                [System.Text.Encoding]$Encoding = [System.Text.UTF8Encoding]::new($true, $true),
                [string]$Text
            )
            [byte[]]$bytes = $Encoding.GetPreamble() + $Encoding.GetBytes($Text)
            [System.IO.File]::WriteAllBytes($script:sourcePath, $bytes)
        }

        function Set-TestCatalog {
            param([string]$Words)
            $literal = $Words.Replace("\", "\\").Replace('"', '\"').Replace('$', '\$').Replace('`', '\`')
            $output = @(
                "    --model)"
                ('        COMPREPLY=($(compgen -W "' + $literal + '" -- "${cur}"))')
                "        return 0"
                "        ;;"
            ) -join "`n"
            [System.IO.File]::WriteAllText($script:catalogPath, $output)
        }

        function Assert-UpdateFails {
            param([string]$Message = "*")
            $beforeBytes = Get-SourceBytes
            $beforeModels = $script:copilotModels -join [char]0
            $beforeTarget = [System.IO.FileInfo]::new($script:linkPath).LinkTarget
            { Update-CopilotModelCompletion -Confirm:$false } | Should -Throw -ExpectedMessage $Message
            Get-SourceBytes | Should -BeExactly $beforeBytes
            ($script:copilotModels -join [char]0) | Should -BeExactly $beforeModels
            [System.IO.FileInfo]::new($script:linkPath).LinkTarget | Should -BeExactly $beforeTarget
            @(Get-ChildItem -LiteralPath $script:caseRoot -Filter ".*.tmp" -File).Count | Should -Be 0
        }
    }

    BeforeEach {
        $script:copilotModels = @("auto", "claude-test", "gpt-test")
        $script:prefix = "# `u{03A9} `u{1F680}`r`n`$before = 'unchanged'`r`n"
        $stubSource = @'
param([string]$Action, [string]$Shell)
if ($Action -ne "completion" -or $Shell -ne "bash") {
    throw "Unexpected catalog command."
}
[System.IO.File]::AppendAllText((Join-Path $PSScriptRoot "calls___ID__.txt"), "call`n")
[System.IO.File]::ReadAllText((Join-Path $PSScriptRoot "catalog___ID__.txt"))
$global:LASTEXITCODE = [int][System.IO.File]::ReadAllText((Join-Path $PSScriptRoot "exit___ID__.txt"))
'@
        $script:suffix = "`r`nfunction Set-OtherValue { `$script:copilotModels = @('nested') }`r`n"
        $script:caseId = [guid]::NewGuid().ToString()
        $script:caseRoot = Join-Path $script:fixtureRoot $script:caseId
        New-Item -ItemType Directory -Path $script:caseRoot | Out-Null
        $script:callsPath = Join-Path $script:caseRoot "calls_$($script:caseId).txt"
        $script:catalogPath = Join-Path $script:caseRoot "catalog_$($script:caseId).txt"
        $script:exitPath = Join-Path $script:caseRoot "exit_$($script:caseId).txt"
        $script:linkPath = Join-Path $script:caseRoot "deployed_$($script:caseId).ps1"
        $script:sourcePath = Join-Path $script:caseRoot "source_$($script:caseId).ps1"
        $script:stubPath = Join-Path $script:caseRoot "copilot_$($script:caseId).ps1"
        $script:PROFILE = [pscustomobject]@{ AllUsersAllHosts = $script:linkPath }
        Set-FixtureProfile -Text (
            $script:prefix + "`$script:copilotModels = @(`r`n    'obsolete'`r`n)" + $script:suffix)
        [System.IO.File]::CreateSymbolicLink($script:linkPath, $script:sourcePath) | Out-Null
        [System.IO.File]::WriteAllText($script:callsPath, "")
        [System.IO.File]::WriteAllText($script:exitPath, "0")
        Set-TestCatalog "gpt-test auto"
        [System.IO.File]::WriteAllText($script:stubPath, $stubSource.Replace("__ID__", $script:caseId))
        Set-Location $script:caseRoot
        Mock Get-Command {
            [pscustomobject]@{ Source = $script:stubPath }
        } -ParameterFilter {
            $Name -eq "copilot.exe" -and $CommandType -eq [System.Management.Automation.CommandTypes]::Application
        }
        Mock copilot.exe { throw "Automatic discovery is not allowed." }
    }

    AfterEach {
        Set-Location $script:repositoryRoot
        if ($script:caseRoot -and (Test-Path -LiteralPath $script:caseRoot)) {
            Remove-Item -LiteralPath $script:caseRoot -Recurse -Force
        }
    }

    AfterAll {
        Set-Location $script:originalLocation
        $script:PROFILE = $script:originalProfile
        if ($script:fixtureRoot -and (Test-Path -LiteralPath $script:fixtureRoot)) {
            Remove-Item -LiteralPath $script:fixtureRoot -Recurse -Force
        }
    }

    Context "Shared model completion" {
        It "uses one registration and one sorted, nonempty static catalog" {
            $script:registrations.Count | Should -Be 1
            $assignments = @($script:profileAst.EndBlock.Statements | Where-Object {
                $_ -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $_.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $_.Left.VariablePath.UserPath -eq "script:copilotModels"
            })
            $assignments.Count | Should -Be 1
            $script:productionModels.Count | Should -BeGreaterThan 0
            $sorted = [string[]]$script:productionModels.Clone()
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            ($script:productionModels -join [char]0) | Should -BeExactly ($sorted -join [char]0)
            @($script:productionModels | Sort-Object -CaseSensitive -Unique).Count |
                Should -Be $script:productionModels.Count
        }

        It "completes <Command> <Form>" -ForEach @(
            foreach ($command in @("agency", "ai", "copilot")) {
                foreach ($form in @("--model ", "--model=")) {
                    @{ Command = $command; Form = $form }
                }
            }
        ) {
            $expected = if ($Form.EndsWith("=")) {
                @("--model=auto", "--model=claude-test", "--model=gpt-test")
            } else {
                @("auto", "claude-test", "gpt-test")
            }
            (Get-CompletionText "$Command $Form") -join "," | Should -BeExactly ($expected -join ",")
        }

        It "filters <Command> <Form><Prefix>" -ForEach @(
            foreach ($command in @("agency", "ai", "copilot")) {
                foreach ($form in @("--model ", "--model=")) {
                    foreach ($prefix in @("gpt", "GPT")) {
                        @{ Command = $command; Form = $form; Prefix = $prefix }
                    }
                }
            }
        ) {
            $expected = if ($Form.EndsWith("=")) { "--model=gpt-test" } else { "gpt-test" }
            @(Get-CompletionText "$Command $Form$Prefix").Count | Should -Be 1
            Get-CompletionText "$Command $Form$Prefix" | Should -BeExactly $expected
        }

        It "does not invent a model for a nonmatching prefix" {
            @(Get-CompletionText "copilot --model no_such_model_").Count | Should -Be 0
            @(Get-CompletionText "copilot --model=no_such_model_").Count | Should -Be 0
        }

        It "handles a quoted prefix in <Line>" -ForEach @(
            @{ Expected = "gpt-test"; Line = "copilot --model 'gpt" }
            @{ Expected = "--model=gpt-test"; Line = "copilot --model='gpt" }
        ) {
            Get-CompletionText $Line | Should -BeExactly $Expected
        }

        It "quotes model punctuation without changing the displayed identifier" {
            $script:copilotModels = @("provider/model:v1+small")
            $line = "copilot --model=provider/"
            $matches = @((TabExpansion2 $line $line.Length).CompletionMatches)
            $matches.Count | Should -Be 1
            $matches[0].CompletionText | Should -BeExactly "--model='provider/model:v1+small'"
            $matches[0].ListItemText | Should -BeExactly "provider/model:v1+small"
        }

        It "escapes embedded quotes in model suggestions" {
            $script:copilotModels = @("gpt-'quoted")
            Get-CompletionText "copilot --model gpt" | Should -BeExactly "'gpt-''quoted'"
            Get-CompletionText "copilot --model=gpt" | Should -BeExactly "--model='gpt-''quoted'"
        }

        It "uses the catalog for the <Backend> ai backend" -ForEach @(
            @{ Backend = "agency"; Origin = "https://example.invalid/team/repository" }
            @{ Backend = "copilot"; Origin = "https://github.com/example/repository" }
        ) {
            $gitDirectory = Join-Path $script:caseRoot ".git"
            New-Item -ItemType Directory -Path $gitDirectory | Out-Null
            [System.IO.File]::WriteAllText(
                (Join-Path $gitDirectory "config"), "[remote `"origin`"]`nurl = $Origin`n")
            Get-AiBackend -RootDir $script:caseRoot | Should -BeExactly $Backend
            (Get-CompletionText "ai --model ") -join "," | Should -BeExactly "auto,claude-test,gpt-test"
        }

        It "completes Agency's <Engine> engine prefix" -ForEach @(
            @{ Engine = "copilot" }
            @{ Engine = "cp" }
        ) {
            (Get-CompletionText "agency $Engine --model ") -join "," |
                Should -BeExactly "auto,claude-test,gpt-test"
        }

        It "preserves flags, enums, subcommands, and native Agency exclusions" {
            Get-CompletionText "copilot --" | Should -Contain "--model"
            (Get-CompletionText "copilot --mode ") -join "," | Should -BeExactly "autopilot,interactive,plan"
            Get-CompletionText "agency fin" | Should -BeExactly "finish-pr"
            (Get-CompletionText "agency finish-pr ") -join "," | Should -BeExactly "--help,--root"
            (Get-CompletionText "agency finish-pr --model ") -join "," | Should -BeExactly "--help,--root"
            (Get-CompletionText "agency --source ") -join "," |
                Should -BeExactly "company,organization,personal,playground,repo,spec"
        }

        It "preserves repo agent discovery and root-directory completion" {
            $agentDirectory = Join-Path $script:caseRoot ".github\agents"
            $gitDirectory = Join-Path $script:caseRoot ".git"
            $rootDirectory = Join-Path $script:caseRoot "root_$($script:caseId)"
            New-Item -ItemType Directory -Path $agentDirectory, $gitDirectory, $rootDirectory | Out-Null
            [System.IO.File]::WriteAllText(
                (Join-Path $gitDirectory "config"),
                "[remote `"origin`"]`nurl = https://github.com/example/repository`n")
            [System.IO.File]::WriteAllText((Join-Path $agentDirectory "fixture_agent.agent.md"), "fixture")
            Get-CompletionText "ai --agent fixture_" | Should -BeExactly "fixture_agent"
            $line = "agency --root $rootDirectory"
            $matches = @((TabExpansion2 $line $line.Length).CompletionMatches)
            $matches.Count | Should -Be 1
            $matches[0].ResultType | Should -Be "ProviderContainer"
            $matches[0].CompletionText.TrimEnd("\") | Should -BeExactly $rootDirectory
        }

        It "passes an unsuggested model through ai unchanged" {
            function Capture-ModelArguments { $script:forwardedArguments = @($args) }
            Mock Get-AiBackend { "Capture-ModelArguments" }
            ai --model "byok/custom:model+v1"
            ($script:forwardedArguments -join ",") | Should -BeExactly "--model,byok/custom:model+v1"
        }

        It "does not discover models while loading definitions or completing" {
            . ([scriptblock]::Create($script:definitionSource))
            Get-CompletionText "copilot --model " | Should -Contain $script:productionModels[0]
            Should -Invoke copilot.exe -Times 0 -Exactly
            [System.IO.File]::ReadAllText($script:callsPath) | Should -BeExactly ""
            $automatic = @(foreach ($statement in $script:profileAst.EndBlock.Statements) {
                if ($statement -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) {
                    $statement.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.CommandAst] -and
                            ($node.GetCommandName() -eq "Update-CopilotModelCompletion" -or
                            ($node.GetCommandName() -eq "copilot.exe" -and $node.Extent.Text -match "completion"))
                    }, $true)
                }
            })
            $automatic.Count | Should -Be 0
        }
    }

    Context "Update-CopilotModelCompletion" {
        It "updates only the array, preserves the link, and refreshes existing completion" {
            $beforeTarget = [System.IO.FileInfo]::new($script:linkPath).LinkTarget
            $result = Update-CopilotModelCompletion -Confirm:$false
            $expected = $script:prefix + "`$script:copilotModels = @(`r`n    'auto'`r`n    'gpt-test'`r`n)" +
                $script:suffix
            $result.Changed | Should -BeTrue
            $result.ModelCount | Should -Be 2
            $result.SourcePath | Should -BeExactly $script:sourcePath
            [System.IO.File]::ReadAllText($script:sourcePath) | Should -BeExactly $expected
            [System.IO.FileInfo]::new($script:linkPath).LinkTarget | Should -BeExactly $beforeTarget
            ($script:copilotModels -join ",") | Should -BeExactly "auto,gpt-test"
            (Get-CompletionText "copilot --model ") -join "," | Should -BeExactly "auto,gpt-test"
            [System.IO.File]::ReadAllLines($script:callsPath).Count | Should -Be 1
            @(Get-ChildItem -LiteralPath $script:caseRoot -Filter ".*.tmp" -File).Count | Should -Be 0
        }

        It "refreshes stale session values without replacing an unchanged file" {
            Update-CopilotModelCompletion -Confirm:$false | Out-Null
            $before = Get-SourceBytes
            $script:copilotModels = @("session-only")
            $lock = [System.IO.File]::Open(
                $script:sourcePath, [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
            try {
                $result = Update-CopilotModelCompletion -Confirm:$false
                $result.Changed | Should -BeFalse
                $result.ModelCount | Should -Be 2
                Get-SourceBytes | Should -BeExactly $before
                (Get-CompletionText "ai --model ") -join "," | Should -BeExactly "auto,gpt-test"
            } finally {
                $lock.Dispose()
            }
        }

        It "refreshes the existing callback after its dot-sourced loader has returned" {
            function Import-CompletionFixture {
                . ([scriptblock]::Create($script:definitionSource))
            }
            . Import-CompletionFixture
            (Get-CompletionText "copilot --model ") -join [char]0 |
                Should -BeExactly ($script:productionModels -join [char]0)
            Set-TestCatalog "auto refreshed-test"
            Update-CopilotModelCompletion -Confirm:$false | Out-Null
            (Get-CompletionText "copilot --model ") -join "," | Should -BeExactly "auto,refreshed-test"
        }

        It "supports strict-mode callers" {
            Set-StrictMode -Version Latest
            try {
                (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            } finally {
                Set-StrictMode -Off
            }
        }

        It "validates WhatIf without mutating file, link, or session (current file: <Current>)" -ForEach @(
            @{ Current = $false }
            @{ Current = $true }
        ) {
            if ($Current) {
                Update-CopilotModelCompletion -Confirm:$false | Out-Null
            }
            $before = Get-SourceBytes
            $beforeTarget = [System.IO.FileInfo]::new($script:linkPath).LinkTarget
            $script:copilotModels = @("session-only")
            [System.IO.File]::WriteAllText($script:callsPath, "")
            $result = Update-CopilotModelCompletion -WhatIf
            $result.Changed | Should -BeFalse
            $result.ModelCount | Should -Be 2
            Get-SourceBytes | Should -BeExactly $before
            [System.IO.FileInfo]::new($script:linkPath).LinkTarget | Should -BeExactly $beforeTarget
            ($script:copilotModels -join ",") | Should -BeExactly "session-only"
            [System.IO.File]::ReadAllLines($script:callsPath).Count | Should -Be 1
        }

        It "does not refresh when real confirmation is declined (current file: <Current>)" -ForEach @(
            @{ Current = $false }
            @{ Current = $true }
        ) {
            if ($Current) {
                Update-CopilotModelCompletion -Confirm:$false | Out-Null
            }
            $before = Get-SourceBytes
            $resultPath = Join-Path $script:caseRoot "declined_$($script:caseId).json"
            $runnerPath = Join-Path $script:caseRoot "confirmation_$($script:caseId).ps1"
            $runner = @'
param([string]$ProfilePath, [string]$ProfileLink, [string]$MockApplication, [string]$ResultPath)
$ErrorActionPreference = "Stop"
$global:PROFILE = [pscustomobject]@{ AllUsersAllHosts = $ProfileLink }
$script:copilotModels = @("session-only")
$errors = $null
$tokens = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($ProfilePath, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors.Message -join "`n") }
$definition = $ast.EndBlock.Statements | Where-Object {
    $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $_.Name -eq "Update-CopilotModelCompletion"
}
. ([scriptblock]::Create($definition.Extent.Text))
function Get-Command {
    [CmdletBinding()]
    param([string[]]$Name, [System.Management.Automation.CommandTypes]$CommandType)
    if ($Name -ne "copilot.exe" -or $CommandType -ne "Application") { throw "Unexpected application lookup." }
    [pscustomobject]@{ Source = $MockApplication }
}
$result = Update-CopilotModelCompletion -Confirm
[pscustomobject]@{ Changed = $result.Changed; Models = @($script:copilotModels) } |
    ConvertTo-Json | Set-Content -LiteralPath $ResultPath -Encoding utf8NoBOM
'@
            [System.IO.File]::WriteAllText($runnerPath, $runner)
            $application = Get-Command pwsh -CommandType Application | Select-Object -First 1
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new($application.Source)
            $startInfo.CreateNoWindow = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.UseShellExecute = $false
            foreach ($argument in @(
                "-NoProfile", "-File", $runnerPath, "-ProfilePath", $script:profilePath,
                "-ProfileLink", $script:linkPath, "-MockApplication", $script:stubPath, "-ResultPath", $resultPath
            )) {
                $startInfo.ArgumentList.Add($argument)
            }
            $process = [System.Diagnostics.Process]::Start($startInfo)
            try {
                $stderr = $process.StandardError.ReadToEndAsync()
                $stdout = $process.StandardOutput.ReadToEndAsync()
                $process.StandardInput.WriteLine("N")
                $process.StandardInput.Close()
                if (-not $process.WaitForExit([int][TimeSpan]::FromSeconds(30).TotalMilliseconds)) {
                    Stop-Process -Id $process.Id -Force
                    throw "The confirmation fixture did not exit."
                }
                $process.ExitCode | Should -Be 0 -Because "$($stdout.Result) $($stderr.Result)"
                $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
                $result.Changed | Should -BeFalse
                ($result.Models -join ",") | Should -BeExactly "session-only"
                Get-SourceBytes | Should -BeExactly $before
            } finally {
                $process.Dispose()
            }
        }

        It "selects the first application on PATH" {
            Mock Get-Command {
                @([pscustomobject]@{ Source = $script:stubPath }, [pscustomobject]@{ Source = "Z:\missing.exe" })
            } -ParameterFilter {
                $Name -eq "copilot.exe" -and $CommandType -eq [System.Management.Automation.CommandTypes]::Application
            }
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            [System.IO.File]::ReadAllLines($script:callsPath).Count | Should -Be 1
        }

        It "accepts static quoted and escaped punctuation without evaluating it" {
            $errors = $null
            $expected = [string[]]@(
                '$(throw)', "back``tick", "cash`$money", 'double"quote', "literal\slash",
                "provider/name:v1+test@edge", "single'quote", "z-model"
            )
            $tokens = $null
            $words = @'
z-model provider/name:v1+test@edge single\'quote 'cash$money' 'back`tick' 'double"quote' 'literal\slash' '$(throw)'
'@
            [Array]::Sort($expected, [System.StringComparer]::Ordinal)
            Set-TestCatalog $words
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            ($script:copilotModels -join [char]0) | Should -BeExactly ($expected -join [char]0)
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $script:sourcePath, [ref]$tokens, [ref]$errors)
            $errors.Count | Should -Be 0
            $assignment = $ast.EndBlock.Statements | Where-Object {
                $_ -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $_.Left.VariablePath.UserPath -eq "script:copilotModels"
            }
            $values = @($assignment.Right.Expression.SubExpression.Statements |
                ForEach-Object { $_.PipelineElements[0].Expression.Value })
            ($values -join [char]0) | Should -BeExactly ($expected -join [char]0)
        }

        It "decodes double-quoted segments and their supported or literal backslashes" {
            $expected = [string[]]@("back\slash", "cash`$value", "joinedword", "kept\slash", 'quoted"model')
            $words = @'
"back\\slash" "cash\$value" "joined"'word' "kept\slash" "quoted\"model"
'@
            Set-TestCatalog $words
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            ($script:copilotModels -join [char]0) | Should -BeExactly ($expected -join [char]0)
        }

        It "handles a single model without collapsing the stored array" {
            Set-TestCatalog "single-model"
            $result = Update-CopilotModelCompletion -Confirm:$false
            $result.Changed | Should -BeTrue
            $result.ModelCount | Should -Be 1
            ($script:copilotModels -is [string[]]) | Should -BeTrue
            Get-CompletionText "copilot --model " | Should -BeExactly "single-model"
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeFalse
        }

        It "accepts CRLF completion output" {
            $text = [System.IO.File]::ReadAllText($script:catalogPath).Replace("`n", "`r`n")
            [System.IO.File]::WriteAllText($script:catalogPath, $text)
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
        }

        It "rejects invalid static words: <Name>" -ForEach @(
            @{ Name = "double-quoted expansion"; Words = 'auto "$MODEL"' }
            @{ Name = "duplicate"; Words = "auto auto" }
            @{ Name = "duplicate after decoding"; Words = "auto 'auto'" }
            @{ Name = "empty list"; Words = "" }
            @{ Name = "empty word"; Words = "auto ''" }
            @{ Name = "escaped whitespace"; Words = 'auto two\ words' }
            @{ Name = "expansion"; Words = 'auto $MODEL' }
            @{ Name = "glob expansion"; Words = "auto gpt-*" }
            @{ Name = "incomplete escape"; Words = "auto gpt-\" }
            @{ Name = "operator"; Words = "auto gpt;other" }
            @{ Name = "quoted whitespace"; Words = "auto 'two words'" }
            @{ Name = "substitution"; Words = 'auto $(whoami)' }
            @{ Name = "unclosed double quote"; Words = 'auto "gpt' }
            @{ Name = "unclosed quote"; Words = "auto 'gpt" }
            @{ Name = "whitespace-only list"; Words = "   " }
        ) {
            Set-TestCatalog $Words
            Assert-UpdateFails
        }

        It "rejects control characters in the catalog" -ForEach @(
            @{ Character = [char]0; Name = "NUL" }
            @{ Character = [char]9; Name = "tab" }
            @{ Character = [char]0x7F; Name = "DEL" }
        ) {
            Set-TestCatalog "auto gpt${Character}test"
            Assert-UpdateFails "*control characters*"
        }

        It "rejects a missing, malformed, or ambiguous branch: <Name>" -ForEach @(
            @{ Name = "bad quoting"; Transform = { param($text) $text.Replace('gpt-test auto"', 'gpt-test auto') } }
            @{ Name = "duplicate branch"; Transform = { param($text) "$text`n$text" } }
            @{
                Name = "dynamic outer quote"
                Transform = { param($text) $text.Replace("gpt-test auto", 'auto $MODEL') }
            }
            @{ Name = "empty output"; Transform = { param($text) "" } }
            @{ Name = "malformed duplicate"; Transform = { param($text) "$text`n--model)`nbroken`n;;" } }
            @{ Name = "missing branch"; Transform = { param($text) $text.Replace("--model)", "--other)") } }
        ) {
            $text = [System.IO.File]::ReadAllText($script:catalogPath)
            [System.IO.File]::WriteAllText($script:catalogPath, (& $Transform $text))
            Assert-UpdateFails
        }

        It "fails without changing state when the application cannot be resolved" {
            Mock Get-Command { throw [System.Management.Automation.CommandNotFoundException]::new("missing copilot") } `
                -ParameterFilter {
                    $Name -eq "copilot.exe" -and
                        $CommandType -eq [System.Management.Automation.CommandTypes]::Application
                }
            Assert-UpdateFails "*missing copilot*"
            [System.IO.File]::ReadAllText($script:callsPath) | Should -BeExactly ""
        }

        It "rejects a nonzero discovery exit even when stdout contains a valid catalog" {
            [System.IO.File]::WriteAllText($script:exitPath, "19")
            Assert-UpdateFails "*exit code 19*"
        }

        It "resolves a relative symlink target against the link directory" {
            [System.IO.File]::Delete($script:linkPath)
            $relative = [System.IO.Path]::GetFileName($script:sourcePath)
            [System.IO.File]::CreateSymbolicLink($script:linkPath, $relative) | Out-Null
            Set-Location $script:repositoryRoot
            (Update-CopilotModelCompletion -Confirm:$false).SourcePath | Should -BeExactly $script:sourcePath
            [System.IO.FileInfo]::new($script:linkPath).LinkTarget | Should -BeExactly $relative
        }

        It "rejects a missing deployed link" {
            $script:PROFILE.AllUsersAllHosts = Join-Path $script:caseRoot "missing_$($script:caseId).ps1"
            Assert-UpdateFails
        }

        It "rejects a regular deployed file instead of assuming it is repository-backed" {
            $script:PROFILE.AllUsersAllHosts = $script:sourcePath
            Assert-UpdateFails "*symbolic link with one target*"
        }

        It "rejects multiple symlink targets" {
            $originalTarget = (Get-TypeData -TypeName System.IO.FileInfo).Members["Target"]
            try {
                Update-TypeData -TypeName System.IO.FileInfo -MemberName Target -MemberType ScriptProperty `
                    -Value { @("first", "second") } -Force
                Assert-UpdateFails "*symbolic link with one target*"
            } finally {
                Update-TypeData -TypeName System.IO.FileInfo -MemberName Target -MemberType AliasProperty `
                    -Value $originalTarget.ReferencedMemberName -Force
            }
        }

        It "rejects a symlink chain" {
            $chainPath = Join-Path $script:caseRoot "chain_$($script:caseId).ps1"
            [System.IO.File]::CreateSymbolicLink($chainPath, $script:sourcePath) | Out-Null
            [System.IO.File]::Delete($script:linkPath)
            [System.IO.File]::CreateSymbolicLink($script:linkPath, $chainPath) | Out-Null
            Assert-UpdateFails "*regular file*"
        }

        It "rejects a missing source without changing the link or session" {
            $beforeTarget = [System.IO.FileInfo]::new($script:linkPath).LinkTarget
            $beforeModels = $script:copilotModels -join ","
            [System.IO.File]::Delete($script:sourcePath)
            { Update-CopilotModelCompletion -Confirm:$false } | Should -Throw
            Test-Path -LiteralPath $script:sourcePath | Should -BeFalse
            [System.IO.FileInfo]::new($script:linkPath).LinkTarget | Should -BeExactly $beforeTarget
            ($script:copilotModels -join ",") | Should -BeExactly $beforeModels
        }

        It "rejects an invalid profile anchor: <Name>" -ForEach @(
            @{ Name = "dynamic"; Text = '$script:copilotModels = @(Get-Date)' }
            @{ Name = "interpolation"; Text = '$script:copilotModels = @("$env:MODEL")' }
            @{ Name = "missing"; Text = '$unrelated = @("auto")' }
            @{ Name = "multiple"; Text = '$script:copilotModels = @("a"); $script:copilotModels = @("b")' }
            @{ Name = "nested array"; Text = '$script:copilotModels = @(@("a"))' }
            @{ Name = "nested only"; Text = 'function Hidden { $script:copilotModels = @("a") }' }
            @{ Name = "not array"; Text = '$script:copilotModels = "auto"' }
            @{ Name = "not strings"; Text = '$script:copilotModels = @(1, 2)' }
            @{ Name = "pipeline"; Text = '$script:copilotModels = @("a" | Out-String)' }
            @{ Name = "redirection"; Text = '$script:copilotModels = @("a" > "output.txt")' }
            @{ Name = "syntax error"; Text = '$script:copilotModels = @(' }
            @{ Name = "trap"; Text = '$script:copilotModels = @(trap { continue }; "a")' }
            @{ Name = "unscoped"; Text = '$copilotModels = @("auto")' }
            @{ Name = "wrong operator"; Text = '$script:copilotModels += @("a")' }
        ) {
            Set-FixtureProfile -Text $Text
            Assert-UpdateFails
        }

        It "accepts a static comma array or an empty static array: <Text>" -ForEach @(
            @{ Text = '$script:copilotModels = @("old", "older")' }
            @{ Text = '$script:copilotModels = @()' }
        ) {
            Set-FixtureProfile -Text $Text
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            ($script:copilotModels -join ",") | Should -BeExactly "auto,gpt-test"
        }

        It "preserves exact <Kind> bytes with <Ending> newlines outside the array" -ForEach @(
            foreach ($kind in @("utf16-be", "utf16-le", "utf32-be", "utf32-le", "utf8", "utf8-bom")) {
                foreach ($ending in @("CRLF", "LF")) {
                    @{ Ending = $ending; Kind = $kind }
                }
            }
        ) {
            $encoding = switch ($Kind) {
                "utf16-be" { [System.Text.UnicodeEncoding]::new($true, $true, $true) }
                "utf16-le" { [System.Text.UnicodeEncoding]::new($false, $true, $true) }
                "utf32-be" { [System.Text.UTF32Encoding]::new($true, $true, $true) }
                "utf32-le" { [System.Text.UTF32Encoding]::new($false, $true, $true) }
                "utf8" { [System.Text.UTF8Encoding]::new($false, $true) }
                "utf8-bom" { [System.Text.UTF8Encoding]::new($true, $true) }
            }
            $newLine = if ($Ending -eq "CRLF") { "`r`n" } else { "`n" }
            $prefix = $script:prefix.Replace("`r`n", $newLine)
            $suffix = $script:suffix.Replace("`r`n", $newLine)
            Set-FixtureProfile -Encoding $encoding -Text (
                $prefix + "`$script:copilotModels = @(${newLine}    'old'${newLine})" + $suffix)
            $expected = $prefix + "`$script:copilotModels = @(${newLine}    'auto'${newLine}    'gpt-test'${newLine})" +
                $suffix
            [byte[]]$expectedBytes = $encoding.GetPreamble() + $encoding.GetBytes($expected)
            (Update-CopilotModelCompletion -Confirm:$false).Changed | Should -BeTrue
            Get-SourceBytes | Should -BeExactly ([Convert]::ToBase64String($expectedBytes))
        }

        It "rejects malformed encoded input unchanged" -ForEach @(
            @{ Bytes = [byte[]]@(0x80); Name = "invalid UTF-8" }
            @{ Bytes = [byte[]]@(0xFF, 0xFE, 0x00); Name = "incomplete UTF-16" }
            @{ Bytes = [byte[]]@(0xFF, 0xFE, 0x00, 0x00, 0x00); Name = "incomplete UTF-32" }
        ) {
            [System.IO.File]::WriteAllBytes($script:sourcePath, $Bytes)
            Assert-UpdateFails
        }

        It "leaves file and session unchanged when sibling creation fails" {
            $script:blockedPath = Join-Path $script:caseRoot "blocked_$($script:caseId)"
            New-Item -ItemType Directory -Path $script:blockedPath | Out-Null
            Mock Join-Path { $script:blockedPath } -ParameterFilter {
                $Path -eq $script:caseRoot -and $ChildPath -like ".source_*.tmp"
            }
            Assert-UpdateFails
            Test-Path -LiteralPath $script:blockedPath -PathType Container | Should -BeTrue
        }

        It "removes the temporary file after an atomic replacement failure" {
            $lock = [System.IO.File]::Open(
                $script:sourcePath, [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
            try {
                Assert-UpdateFails
            } finally {
                $lock.Dispose()
            }
        }

        It "performs validation even under WhatIf" {
            Set-TestCatalog "auto auto"
            $before = Get-SourceBytes
            { Update-CopilotModelCompletion -WhatIf } | Should -Throw "*duplicate*"
            Get-SourceBytes | Should -BeExactly $before
            ($script:copilotModels -join ",") | Should -BeExactly "auto,claude-test,gpt-test"
        }
    }
}
