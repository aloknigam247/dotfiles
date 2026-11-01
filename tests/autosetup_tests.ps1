[CmdletBinding()]
param(
    [string]$Source = (Join-Path (Split-Path $PSScriptRoot) "autosetup.ps1")
)

$ErrorActionPreference = "Stop"
$saved_environment = @{}
$source_errors = $null
$source_tokens = $null
$script:managers = @("npm", "pip", "pipx", "psgallery", "scoop", "winget")
$original_location = Get-Location
$repo = Split-Path (Resolve-Path -LiteralPath $Source).Path
$script:fixture = Join-Path (Split-Path $PSScriptRoot) "tmp\autosetup_tests_$([guid]::NewGuid())"
$source_ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $Source, [ref]$source_tokens, [ref]$source_errors
)
if ($source_errors.Count) {
    throw ($source_errors.Message -join "`n")
}
$script:source_functions = [scriptblock]::Create(($source_ast.EndBlock.Statements | Where-Object {
    $_ -is [System.Management.Automation.Language.FunctionDefinitionAst]
} | ForEach-Object { $_.Extent.Text }) -join "`n")
# Keep the shipped statements, but not the administrator-only entry point.
$script:source_main = [scriptblock]::Create(($source_ast.EndBlock.Statements | Where-Object {
    $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst]
} | ForEach-Object { $_.Extent.Text }) -join "`n")

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "FAIL: $Message"
    }
}

function Assert-Sequence {
    param($Actual, $Expected, [string]$Message)
    $actual_json = ConvertTo-Json -InputObject @($Actual) -Compress -Depth 10
    $expected_json = ConvertTo-Json -InputObject @($Expected) -Compress -Depth 10
    Assert-True ($actual_json -ceq $expected_json) "$Message`nExpected: $expected_json`nActual: $actual_json"
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern)
    try {
        & $Action | Out-Null
    } catch {
        Assert-True ($_.Exception.Message -like $Pattern) "Unexpected error: $($_.Exception.Message)"
        return
    }
    throw "FAIL: expected error matching '$Pattern'."
}

function Assert-FixturePath {
    param([string]$Path)
    $resolved = [System.IO.Path]::GetFullPath($Path)
    Assert-True ($resolved.StartsWith("$script:fixture\", [System.StringComparison]::OrdinalIgnoreCase)) `
        "Path escaped the disposable fixture: $Path"
}

function Assert-FileMap {
    param([hashtable]$Files, [string]$Origin)
    foreach ($key in $Files.Keys) {
        Assert-FixturePath (Join-Path $Origin $key)
        foreach ($destination in @($Files[$key])) {
            Assert-FixturePath $destination
        }
    }
}

function New-SetupModule {
    param([string]$Name, [string]$Setup, [string]$FixtureRoot = $script:fixture)
    $directory = Join-Path $FixtureRoot $Name
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $directory "setup.ps1") -Value $Setup
    Set-Content -LiteralPath (Join-Path $directory "config.txt") -Value "$Name source"
    return $directory
}

function Record-Call {
    param([string]$Kind, [object]$Data, [bool]$Update = $false)
    $script:events.Add([pscustomobject]@{
        Data = $Data
        Kind = $Kind
        Origin = (Get-Location).Path
        Update = $Update
    })
    if ($Kind -eq $script:fail_dispatch) {
        throw "fixture dispatch failure: $Kind"
    }
}

function Invoke-Collection {
    param(
        [string]$ErrorPolicy = "Stop",
        [string]$Failure = "",
        [string]$FixtureRoot = $script:fixture,
        [switch]$Interactive,
        [string[]]$Modules,
        [switch]$RealFiles,
        [switch]$RealSetups,
        [switch]$Update
    )

    $file_helpers = @{}
    $ErrorActionPreference = $ErrorPolicy
    $install = $Modules
    $location = Get-Location
    $script:events = [System.Collections.Generic.List[object]]::new()
    $script:fail_dispatch = $Failure
    $env:AUTOSETUP_TEST_EFFECT = "seed"
    $env:XDG_STATE_HOME = Join-Path $FixtureRoot "initial_state"
    if ($Interactive) {
        $install = $null
    }

    . $script:source_functions
    foreach ($name in @("copyOrUpdateConfigs", "deployConfigs", "linkConfigs")) {
        $file_helpers[$name] = (Get-Item -LiteralPath "Function:$name").ScriptBlock
    }

    function copyOrUpdateConfigs {
        param([hashtable]$files, [switch]$update)
        Record-Call "copy" $files $update.IsPresent
        if ($RealFiles) {
            Assert-FileMap $files $cwd.Path
            & $file_helpers["copyOrUpdateConfigs"] -files $files -update:$update
        }
    }
    function deployConfigs {
        param([hashtable]$files)
        Record-Call "deploy" $files
        if ($RealFiles) {
            Assert-FileMap $files $cwd.Path
            & $file_helpers["deployConfigs"] -files $files
        }
    }
    function githubInstall {
        param([hashtable[]]$pkgs, [switch]$update, [string]$stateHome)
        Record-Call "github" @{ Packages = @($pkgs); StateHome = $stateHome } $update.IsPresent
    }
    function linkConfigs {
        param([hashtable]$files)
        Record-Call "link" $files
        if ($RealFiles) {
            Assert-FileMap $files $cwd.Path
            & $file_helpers["linkConfigs"] -files $files
        }
    }
    function Menu {
        param($menuItems, [switch]$Multiselect)
        Assert-True $Interactive.IsPresent "Unexpected interactive selection."
        Assert-True $Multiselect.IsPresent "The menu must remain multiselect."
        Record-Call "menu" $menuItems
        return $Modules
    }
    function writeLog {
        param([string]$type, [string]$message)
        if ($type -eq "ERROR") {
            Record-Call "error" $message
        }
    }
    foreach ($manager in $script:managers) {
        $body = 'param([string[]]$pkgs, [switch]$update); Record-Call "__MANAGER__" $pkgs $update.IsPresent'
        Set-Item -LiteralPath "Function:${manager}Install" `
            -Value ([scriptblock]::Create($body.Replace("__MANAGER__", $manager)))
    }
    if ($RealSetups) {
        function New-Object {
            param([string]$ComObject)
            Assert-True ($ComObject -eq "Shell.Application") "Unexpected COM activation."
            return $script:font_shell
        }
        function powershell {
            Record-Call "profile5" @($args)
            return (Join-Path $script:fixture "profiles\profile5.ps1")
        }
        function pwsh {
            Record-Call "profile7" @($args)
            return (Join-Path $script:fixture "profiles\profile7.ps1")
        }
    }

    try {
        Set-Location -LiteralPath $FixtureRoot
        . $script:source_main 4>$null 6>$null | Out-Null
        return $script:events.ToArray()
    } finally {
        $script:last_location = (Get-Location).Path
        Set-Location -LiteralPath $location.Path
    }
}

foreach ($name in @(
    "AUTOSETUP_TEST_EFFECT", "LOCALAPPDATA", "TEMP", "XDG_CACHE_HOME", "XDG_CONFIG_HOME",
    "XDG_DATA_HOME", "XDG_LOG_HOME", "XDG_STATE_HOME"
)) {
    $saved_environment[$name] = [System.Environment]::GetEnvironmentVariable($name)
}

try {
    New-Item -ItemType Directory -Path $script:fixture | Out-Null
    foreach ($name in @("alpha", "beta")) {
        $setup = @'
Record-Call "setup" @{ Module = "__NAME__"; Previous = $env:AUTOSETUP_TEST_EFFECT; Source = $cwd.Path }
$env:AUTOSETUP_TEST_EFFECT = "__NAME__"
$env:XDG_STATE_HOME = Join-Path $script:fixture "state\__NAME__"
$files = @{ "config.txt" = @(
    (Join-Path $script:fixture "targets\__NAME__\link.txt"),
    (Join-Path $script:fixture "targets\__NAME__\second_link.txt")
) }
$files_copy = @{ "config.txt" = (Join-Path $script:fixture "targets\__NAME__\copy.txt") }
$files_deploy = @{ "config.txt" = (Join-Path $script:fixture "targets\__NAME__\deploy.txt") }
$github_pkgs = @(
    @{ repo = "fixture/release"; asset = "__NAME__.exe"; dir = "release" },
    @{ repo = "fixture/release"; asset = "__NAME__.zip"; dir = "other_release" }
)
'@
        foreach ($manager in $script:managers) {
            $setup += "`n`$${manager}_pkgs = @(`"shared`", `"shared`", `"__NAME__`")"
        }
        New-SetupModule $name $setup.Replace("__NAME__", $name) | Out-Null
    }
    New-SetupModule "gamma" @'
Record-Call "setup" @{
    Module = "gamma"
    Packages = @{
        npm = @($npm_pkgs)
        pip = @($pip_pkgs)
        pipx = @($pipx_pkgs)
        psgallery = @($psgallery_pkgs)
        scoop = @($scoop_pkgs)
        winget = @($winget_pkgs)
    }
    Previous = $env:AUTOSETUP_TEST_EFFECT
    Source = $cwd.Path
}
'@ | Out-Null

    foreach ($update in @($false, $true)) {
        $calls = @(Invoke-Collection -Modules @("beta", "alpha", "BETA", ".\alpha") -Update:$update)
        $expected_previous = if ($update) { @("seed", "alpha", "beta") } else { @("seed", "beta") }
        $selected = if ($update) { @("alpha", "beta", "gamma") } else { @("beta", "alpha") }
        $setups = @($calls | Where-Object Kind -eq "setup")
        Assert-Sequence $setups.Data.Module $selected "Setup selection/order/count changed."
        Assert-Sequence $setups.Data.Previous $expected_previous "Setup side effects did not reach the next module."
        $expected_kinds = @($selected | ForEach-Object { "setup" })
        foreach ($module in $selected) {
            $expected_kinds += @("copy", "deploy", "github")
            if (-not $update) {
                $expected_kinds += "link"
            }
            $expected_kinds += $script:managers
        }
        Assert-Sequence $calls.Kind $expected_kinds "Collection/dispatch phase or helper order changed."
        foreach ($call in $calls) {
            if ($call.Kind -ne "setup") {
                $expected_update = $update -and $call.Kind -notin @("deploy", "link")
                Assert-True ($call.Update -eq $expected_update) "Wrong update switch for $($call.Kind)."
            }
        }
        foreach ($manager in $script:managers) {
            $packages = @($calls | Where-Object Kind -eq $manager | ForEach-Object { $_.Data })
            $expected = @("shared") + @($selected | Where-Object { $_ -ne "gamma" })
            Assert-Sequence $packages $expected "$manager lost first-seen package identity/order."
        }
        foreach ($setup_call in $setups) {
            $expected_origin = Join-Path $script:fixture $setup_call.Data.Module
            Assert-True ($setup_call.Origin -eq $expected_origin) "Setup ran outside its module."
            Assert-True ($setup_call.Data.Source -eq $expected_origin) "Setup received the wrong source directory."
            if ($setup_call.Data.Module -eq "gamma") {
                foreach ($manager in $script:managers) {
                    Assert-True ($setup_call.Data.Packages[$manager].Count -eq 0) `
                        "The $manager declaration was not reset before evaluating the next setup."
                }
            }
        }
        foreach ($call in @($calls | Where-Object { $_.Kind -in @("copy", "deploy", "link", "github") })) {
            $module = Split-Path $call.Origin -Leaf
            if ($module -eq "gamma") {
                $data = if ($call.Kind -eq "github") { $call.Data.Packages } else { $call.Data }
                Assert-True ($data.Count -eq 0) "Omitted declarations leaked into gamma."
            } elseif ($call.Kind -eq "github") {
                Assert-Sequence $call.Data.Packages.asset @("$module.exe", "$module.zip") "Release assets merged."
                Assert-Sequence $call.Data.Packages.dir @("release", "other_release") "Release destinations changed."
                Assert-True ($call.Data.StateHome -eq (Join-Path $script:fixture "state\$module")) `
                    "GitHub inventory context drifted."
            } else {
                foreach ($destination in @($call.Data["config.txt"])) {
                    Assert-True ($destination.StartsWith((Join-Path $script:fixture "targets\$module\"))) `
                        "Same-named config sources lost their destination."
                }
            }
        }
        Assert-True ($script:last_location -eq $script:fixture) "Successful execution did not restore root."
        $last_effect = if ($update) { "beta" } else { "alpha" }
        Assert-True ($env:AUTOSETUP_TEST_EFFECT -eq $last_effect) "Setup side effects were rewound."
        Assert-True ($env:XDG_STATE_HOME -eq (Join-Path $script:fixture "state\$last_effect")) `
            "Dispatch rewound the final environment."
    }

    $calls = @(Invoke-Collection -Interactive -Modules @("gamma", "beta"))
    Assert-Sequence ($calls | Where-Object Kind -eq "setup").Data.Module @("gamma", "beta") `
        "Interactive selection changed."
    $empty_helpers = @($calls | Where-Object { $_.Origin -eq (Join-Path $script:fixture "gamma") })
    foreach ($manager in $script:managers) {
        $empty_call = @($empty_helpers | Where-Object Kind -eq $manager)
        Assert-True ($empty_call.Count -eq 1 -and $empty_call[0].Data.Count -eq 0) `
            "Config-only modules must retain the empty $manager helper call."
    }
    Assert-Sequence (@(Invoke-Collection -Interactive -Modules @())).Kind @("menu") `
        "Empty interactive selection dispatched work."
    $empty_root = Join-Path $script:fixture "empty"
    New-Item -ItemType Directory -Path $empty_root | Out-Null
    Assert-True (@(Invoke-Collection -FixtureRoot $empty_root -Update).Count -eq 0) "Empty update dispatched work."
    Write-Output "PASS: collection, first-seen dedupe, selection, helper order, maps, and setup context"

    $declared_packages = @("tool", "tool", ".\pkg", "Tool", "tool@1", "tool@2", "file:..\archive.tgz", "localpkg")
    $expected_packages = @("tool", ".\pkg", "Tool", "tool@1", "tool@2", "file:..\archive.tgz", "localpkg")
    $identity_root = Join-Path $script:fixture "declared_names"
    $quoted_packages = ($declared_packages | ForEach-Object { "`"$_`"" }) -join ", "
    $identity_setup = ($script:managers | ForEach-Object { "`$${_}_pkgs = @($quoted_packages)" }) -join "`n"
    foreach ($name in @("alpha", "beta")) {
        $directory = New-SetupModule -Name $name -FixtureRoot $identity_root -Setup $identity_setup
        New-Item -ItemType Directory -Path (Join-Path $directory "localpkg") | Out-Null
    }
    foreach ($update in @($false, $true)) {
        $calls = @(Invoke-Collection -FixtureRoot $identity_root -Modules @("alpha", "beta") -Update:$update)
        foreach ($manager in $script:managers) {
            $manager_calls = @($calls | Where-Object Kind -eq $manager)
            Assert-Sequence $manager_calls.Origin @("$identity_root\alpha", "$identity_root\beta") `
                "$manager dispatch lost module order."
            Assert-Sequence $manager_calls[0].Data $expected_packages `
                "$manager did not preserve exact declared names and first-seen order."
            Assert-Sequence $manager_calls[1].Data @() "$manager repeated identical names from another setup."
        }
    }
    Write-Output "PASS: exact declared names deduplicate per manager without case, version, or path interpretation"

    foreach ($policy in @("Continue", "Stop")) {
        Assert-Throws { Invoke-Collection -ErrorPolicy $policy -Modules @("does_not_exist") } "*does_not_exist*"
        Assert-True ($script:last_location -eq $script:fixture) "Invalid directory did not restore root."
    }
    New-Item -ItemType Directory -Path (Join-Path $script:fixture "missing_setup") | Out-Null
    $calls = @(Invoke-Collection -Modules @("missing_setup"))
    Assert-Sequence $calls.Kind @("error") "Missing setup was not reported."
    Assert-True ($calls[0].Data -like "No setup.ps1 found*") "Missing setup error changed."
    Assert-True ($script:last_location -eq $script:fixture) "Missing setup did not restore root."
    New-SetupModule "throwing" 'throw "fixture setup failure"' | Out-Null
    Assert-Throws { Invoke-Collection -Modules @("alpha", "throwing") } "*fixture setup failure*"
    Assert-Sequence $script:events.Kind @("setup") "Dispatch ran after collection failed."
    Assert-True ($script:last_location -eq $script:fixture) "Setup failure did not restore root."
    Assert-Throws { Invoke-Collection -Modules @("alpha") -Failure "npm" } "*fixture dispatch failure: npm*"
    Assert-Sequence $script:events.Kind @("setup", "copy", "deploy", "github", "link", "npm") `
        "Dispatch continued after an installer failure."
    Assert-True ($script:last_location -eq $script:fixture) "Dispatch failure did not restore root."
    Write-Output "PASS: visible missing/invalid setup errors and root restoration on collection/dispatch failure"

    & {
        # Native package absence is a nonzero exit, not a terminating PowerShell error.
        $PSDefaultParameterValues = @{ "pip:ErrorAction" = "Continue" }
        . $script:source_functions
        $script:native_calls = [System.Collections.Generic.List[string]]::new()
        function writeLog { param($type, $message) }
        function Invoke-RestMethod { throw "Unexpected network request." }
        function pip {
            [CmdletBinding()]
            param([Parameter(ValueFromRemainingArguments)][string[]]$Arguments)
            if ($Arguments[0] -eq "show") {
                if ($Arguments[1] -ne "present") {
                    $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
                        [System.Exception]::new("Package absent"), "PackageAbsent",
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound, $Arguments[1]
                    ))
                }
            } else {
                $script:native_calls.Add("pip $($Arguments -join ' ')")
            }
        }
        function pipx { $script:native_calls.Add("pipx $($args -join ' ')") }
        function npm {
            if ($args[0] -eq "list") {
                if ($args[-1] -eq "present") { "present" }
            } else {
                $script:native_calls.Add("npm $($args -join ' ')")
            }
        }
        function Get-Module {
            param([switch]$ListAvailable, [string]$Name)
            if ($Name -eq "present") { [pscustomobject]@{ Name = $Name } }
        }
        function Install-Module {
            param([string]$Name, [switch]$Force, [string]$Scope)
            $script:native_calls.Add("psgallery install $Name")
        }
        function Update-Module {
            param([string]$Name)
            $script:native_calls.Add("psgallery update $Name")
        }
        function scoop {
            if ($args[0] -eq "list") {
                $script:native_calls.Add("scoop list")
                [pscustomobject]@{ Name = "present" }
            } else {
                $script:native_calls.Add("scoop $($args -join ' ')")
            }
        }
        function winget {
            if ($args[0] -eq "list") {
                if ($args[3] -eq "present") {
                    "Found present"
                } else {
                    "No installed package found matching input criteria."
                }
            } else {
                $script:native_calls.Add("winget $($args -join ' ')")
            }
        }
        foreach ($update in @($false, $true)) {
            $script:native_calls.Clear()
            $script:scoop_installed = @("present")
            foreach ($manager in $script:managers) {
                & "${manager}Install" -pkgs @("present", "absent") -update:$update
            }
            $expected = if ($update) {
                @(
                    "npm update -g present", "pip install --upgrade present", "pipx upgrade present",
                    "psgallery update present", "scoop update -s present",
                    "winget upgrade -e --id present --accept-package-agreements --accept-source-agreements"
                )
            } else {
                @(
                    "npm install -g absent", "pip install absent", "pipx install absent",
                    "psgallery install absent", "scoop install --no-update-scoop -s absent",
                    "winget install -e --id absent --accept-package-agreements --accept-source-agreements"
                )
            }
            Assert-Sequence $script:native_calls.ToArray() $expected "Installer eligibility or command flags changed."
        }
        foreach ($update in @($false, $true)) {
            $script:native_calls.Clear()
            $script:scoop_installed = ""
            scoopInstall -pkgs @() -update:$update
            $expected = if ($update) { @("scoop update", "scoop list") } else { @("scoop list") }
            Assert-Sequence $script:native_calls.ToArray() $expected "Empty Scoop bootstrap behavior changed."
        }
    }
    Write-Output "PASS: real installer helpers retain install/update eligibility and empty Scoop bootstrap"

    & {
        . $script:source_functions
        $script:release_calls = [System.Collections.Generic.List[string]]::new()
        $state_a = Join-Path $script:fixture "github_state_a"
        $state_b = Join-Path $script:fixture "github_state_b"
        $env:TEMP = Join-Path $script:fixture "download_temp"
        $env:XDG_STATE_HOME = $state_b
        foreach ($directory in @("$state_a\autosetup", "$state_b\autosetup", $env:TEMP)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        Set-Content -LiteralPath "$state_a\autosetup\github-releases.json" -Value '{"fixture/release":"v1"}'
        Set-Content -LiteralPath "$state_b\autosetup\github-releases.json" -Value '{"fixture/release":"v2"}'
        function writeLog { param($type, $message) }
        function gh {
            $global:LASTEXITCODE = 0
            $script:release_calls.Add($args -join " ")
            if ($args[1] -eq "view") {
                return "v2"
            }
            Assert-True ($args[1] -eq "download") "Unexpected GitHub command."
            $asset = $args[[array]::IndexOf($args, "--pattern") + 1]
            $directory = $args[[array]::IndexOf($args, "--dir") + 1]
            Assert-FixturePath $directory
            if ($asset.EndsWith(".zip")) {
                $payload = Join-Path $script:fixture "archive_payload.txt"
                Set-Content -LiteralPath $payload -Value "release payload"
                Compress-Archive -LiteralPath $payload -DestinationPath (Join-Path $directory $asset)
            } else {
                Set-Content -LiteralPath (Join-Path $directory $asset) -Value "release payload"
            }
        }
        $package = @{ asset = "tool.exe"; dir = (Join-Path $script:fixture "release_a"); repo = "fixture/release" }
        githubInstall -pkgs @($package) -update -stateHome $state_a | Out-Null
        Assert-True (Test-Path -LiteralPath "$($package.dir)\tool.exe") "Captured inventory did not permit update."
        Assert-True ((Get-Content "$state_a\autosetup\github-releases.json" -Raw | ConvertFrom-Json).`
            "fixture/release" -eq "v2") "Captured inventory was not updated."
        Assert-True ((Get-Content "$state_b\autosetup\github-releases.json" -Raw).Trim() -ceq
            '{"fixture/release":"v2"}') "Dispatch wrote to the final environment's inventory instead."
        Assert-True ($env:XDG_STATE_HOME -eq $state_b) "GitHub dispatch mutated the final environment."
        $before_calls = $script:release_calls.Count
        githubInstall -pkgs @(@{
            asset = "absent.exe"; dir = (Join-Path $script:fixture "absent_release"); repo = "fixture/absent"
        }) -update -stateHome $state_a | Out-Null
        Assert-True ($script:release_calls.Count -eq $before_calls) "Update discovered/installed an absent release."
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $script:fixture "absent_release"))) `
            "Update created an absent release destination."
        $package = @{ asset = "tool.zip"; dir = (Join-Path $script:fixture "release_b"); repo = "fixture/new" }
        githubInstall -pkgs @($package) | Out-Null
        Assert-True (Test-Path -LiteralPath "$($package.dir)\archive_payload.txt") `
            "Default state-home ZIP install failed."
        Assert-True ((Get-Content "$state_b\autosetup\github-releases.json" -Raw | ConvertFrom-Json).`
            "fixture/new" -eq "v2") "Default GitHub inventory behavior changed."
        $before_downloads = @($script:release_calls | Where-Object { $_ -like "release download*" })
        githubInstall -pkgs @($package) | Out-Null
        Assert-Sequence @($script:release_calls | Where-Object { $_ -like "release download*" }) `
            $before_downloads "An up-to-date release was downloaded again."
        Assert-True (@(Get-ChildItem -LiteralPath $env:TEMP).Count -eq 0) "Release scratch directories leaked."
    }
    Write-Output ("PASS: real GitHub helper preserves captured/default inventory, assets, " +
        "update eligibility, and reruns")

    $script:font_copies = [System.Collections.Generic.List[string]]::new()
    $script:font_store = [pscustomobject]@{ Installed = $false }
    $script:font_store | Add-Member -MemberType ScriptMethod -Name Items -Value {
        if ($this.Installed) { [pscustomobject]@{ Name = "JetBrainsMono Nerd Font" } }
    }
    $script:font_store | Add-Member -MemberType ScriptMethod -Name CopyHere -Value {
        param($Path)
        Assert-FixturePath $Path
        $script:font_copies.Add($Path)
    }
    $script:font_shell = [pscustomobject]@{}
    $script:font_shell | Add-Member -MemberType ScriptMethod -Name Namespace -Value {
        param($Id)
        Assert-True ($Id -eq 0x14) "Unexpected font namespace."
        return $script:font_store
    }
    $setup_root = Join-Path $script:fixture "real_setups"
    foreach ($name in @("fonts", "neovim", "powershell")) {
        $directory = New-SetupModule -Name $name -FixtureRoot $setup_root `
            -Setup (Get-Content -LiteralPath (Join-Path $repo "$name\setup.ps1") -Raw)
        Assert-True ((Get-Content -LiteralPath "$directory\setup.ps1" -Raw).TrimEnd() -ceq
            (Get-Content -LiteralPath (Join-Path $repo "$name\setup.ps1") -Raw).TrimEnd()) `
            "Real setup content drifted."
    }
    New-Item -ItemType Directory -Path "$setup_root\fonts\fonts" | Out-Null
    Set-Content -LiteralPath "$setup_root\fonts\fonts\fixture.ttf" -Value "fixture font"
    $calls = @(Invoke-Collection -FixtureRoot $setup_root -Modules @("fonts", "neovim", "powershell") -RealSetups)
    Assert-Sequence $script:font_copies.ToArray() @("$setup_root\fonts\fonts\fixture.ttf") `
        "Font setup lost its origin."
    $profile_calls = @($calls | Where-Object { $_.Kind -in @("profile5", "profile7") })
    Assert-Sequence $profile_calls.Kind @("profile7", "profile5", "profile7") "Profile discovery count/order changed."
    foreach ($call in $profile_calls) {
        Assert-True ($call.Origin -eq "$setup_root\powershell") "Profile discovery ran outside its module."
    }
    $profile_map = ($calls | Where-Object {
        $_.Kind -eq "link" -and $_.Origin -eq "$setup_root\powershell"
    }).Data
    Assert-True ($profile_map["profile.ps1"] -eq (Join-Path $script:fixture "profiles\profile7.ps1")) `
        "Resolved PowerShell profile destination changed."
    Assert-True ($profile_map["GitCompleter"] -eq (Join-Path $script:fixture "profiles\Modules\GitCompleter")) `
        "Resolved module destination changed."
    $nvim_map = ($calls | Where-Object { $_.Kind -eq "link" -and $_.Origin -eq "$setup_root\neovim" }).Data
    Assert-True ($nvim_map["init.lua"] -eq "D:\apps\nvim\lua\init.lua") `
        "Neovim destinations were not resolved at setup."
    foreach ($name in @("XDG_CACHE_HOME", "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_LOG_HOME", "XDG_STATE_HOME")) {
        Assert-True ([System.Environment]::GetEnvironmentVariable($name) -eq "D:\apps") `
            "Lost Neovim environment effect."
    }
    $script:font_store.Installed = $true
    $script:font_copies.Clear()
    Invoke-Collection -FixtureRoot $setup_root -Modules @("fonts", "FONTS") -RealSetups | Out-Null
    Assert-True ($script:font_copies.Count -eq 0) "Already installed fonts were copied again."
    Write-Output "PASS: actual font, Neovim environment, and PowerShell profile setups with isolated external effects"

    $file_root = Join-Path $script:fixture "file_helpers"
    $file_setup = @'
$files = @{ "config.txt" = (Join-Path $script:fixture "file_targets\__NAME__\link.txt") }
$files_copy = @{ "config.txt" = (Join-Path $script:fixture "file_targets\__NAME__\copy.txt") }
$files_deploy = @{ "config.txt" = (Join-Path $script:fixture "file_targets\__NAME__\deploy.txt") }
'@
    foreach ($name in @("alpha", "beta")) {
        New-SetupModule -Name $name -FixtureRoot $file_root -Setup $file_setup.Replace("__NAME__", $name) | Out-Null
        $target = Join-Path $script:fixture "file_targets\$name"
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        foreach ($file in @("copy.txt", "deploy.txt", "link.txt")) {
            Set-Content -LiteralPath (Join-Path $target $file) -Value "original $name $file"
        }
    }
    Invoke-Collection -FixtureRoot $file_root -Modules @("alpha", "beta") -RealFiles | Out-Null
    foreach ($name in @("alpha", "beta")) {
        $target = Join-Path $script:fixture "file_targets\$name"
        foreach ($file in @("copy.txt", "deploy.txt", "link.txt")) {
            Assert-True ((Get-Content -LiteralPath (Join-Path $target $file) -Raw).Trim() -ceq "$name source") `
                "Wrong module content for $name/$file."
            Assert-True ((Get-Content -LiteralPath (Join-Path $target "$file.orig") -Raw).Trim() -ceq
                "original $name $file") "Backup lost original content for $name/$file."
        }
        Assert-True ((Get-Item -LiteralPath "$target\link.txt").LinkType -eq "SymbolicLink") "Config is not a symlink."
        Assert-True ((Get-Item -LiteralPath "$target\link.txt").Target -eq "$file_root\$name\config.txt") `
            "Link points at the wrong module source."
    }
    $rerun = @(Invoke-Collection -FixtureRoot $file_root -Modules @("alpha", "beta") -RealFiles)
    Assert-True (@($rerun | Where-Object Kind -eq "error").Count -eq 0) "Config rerun logged an error."
    foreach ($name in @("alpha", "beta")) {
        $target = Join-Path $script:fixture "file_targets\$name"
        Assert-True ((Get-Content "$target\copy.txt.orig" -Raw).Trim() -ceq "original $name copy.txt") `
            "An existing backup was overwritten."
    }
    Set-Content "$file_root\alpha\config.txt" -Value "alpha newer source"
    (Get-Item "$file_root\alpha\config.txt").LastWriteTime = [datetime]"2030-01-02"
    (Get-Item "$script:fixture\file_targets\alpha\copy.txt").LastWriteTime = [datetime]"2030-01-01"
    Set-Content "$script:fixture\file_targets\beta\copy.txt" -Value "beta newer destination"
    (Get-Item "$file_root\beta\config.txt").LastWriteTime = [datetime]"2030-01-01"
    (Get-Item "$script:fixture\file_targets\beta\copy.txt").LastWriteTime = [datetime]"2030-01-02"
    $calls = @(Invoke-Collection -FixtureRoot $file_root -Update -RealFiles)
    Assert-True (@($calls | Where-Object Kind -eq "link").Count -eq 0) "Update linked configs."
    Assert-True ((Get-Content "$script:fixture\file_targets\alpha\copy.txt" -Raw).Trim() -ceq "alpha newer source") `
        "Update failed to copy a newer source outward."
    Assert-True ((Get-Content "$file_root\beta\config.txt" -Raw).Trim() -ceq "beta newer destination") `
        "Update failed to copy a newer destination inward."
    Assert-True ((Get-Content "$script:fixture\file_targets\beta\deploy.txt" -Raw).Trim() -ceq
        "beta newer destination") "Deployment no longer follows the updated source."
    Write-Output ("PASS: real config helpers preserve origins, symlinks, copies, deployments, backups, " +
        "and update direction")

    $smoke_root = Join-Path $script:fixture "real_module_smoke"
    $smoke_files = @{
        clangd = "config_win.yaml"
        mdview = "config.toml"
        windows_terminal = "settings.json"
    }
    foreach ($name in @("clangd", "mdview", "windows_terminal")) {
        $directory = New-SetupModule -Name $name -FixtureRoot $smoke_root `
            -Setup (Get-Content -LiteralPath (Join-Path $repo "$name\setup.ps1") -Raw)
        Copy-Item -LiteralPath (Join-Path $repo "$name\$($smoke_files[$name])") -Destination $directory
    }
    $env:LOCALAPPDATA = Join-Path $smoke_root "targets\local"
    $env:XDG_CONFIG_HOME = Join-Path $smoke_root "targets\xdg"
    foreach ($update in @($false, $false, $true)) {
        $calls = @(Invoke-Collection -FixtureRoot $smoke_root -Modules @("clangd", "mdview", "windows_terminal") `
            -Update:$update -RealFiles)
        Assert-True ($script:last_location -eq $smoke_root) "Real module smoke did not restore root."
        $destinations = @(
            "$env:LOCALAPPDATA\clangd\config.yaml",
            "$env:XDG_CONFIG_HOME\mdview\config.toml",
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        )
        foreach ($destination in $destinations) {
            Assert-FixturePath $destination
            Assert-True (Test-Path -LiteralPath $destination) "Real module smoke did not create $destination."
        }
        Assert-True ((Get-FileHash $destinations[0]).Hash -eq
            (Get-FileHash "$smoke_root\clangd\config_win.yaml").Hash) `
            "Real clangd configuration differs."
        Assert-True ((Get-FileHash $destinations[1]).Hash -eq (Get-FileHash "$smoke_root\mdview\config.toml").Hash) `
            "Real mdview configuration differs."
        Assert-True ((Get-FileHash $destinations[2]).Hash -eq
            (Get-FileHash "$smoke_root\windows_terminal\settings.json").Hash) `
            "Real terminal configuration differs."
    }
    Write-Output "PASS: real clangd, mdview, and Windows Terminal install/rerun/update smoke in disposable paths"
    Write-Output "PASS: all autosetup regression checks"
} finally {
    Set-Location -LiteralPath $original_location.Path
    foreach ($name in $saved_environment.Keys) {
        [System.Environment]::SetEnvironmentVariable($name, $saved_environment[$name])
    }
    if (Test-Path -LiteralPath $script:fixture) {
        Remove-Item -LiteralPath $script:fixture -Recurse -Force
    }
}
