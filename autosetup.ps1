#Requires -RunAsAdministrator

param(
     [switch]$update = $false,
     [string[]]$install
     )

# Variables
$collected_packages = @{}
$package_managers = @("npm", "pip", "pipx", "scoop", "winget")
$SCOOP_DIR = "D:\Scoop"

function DrawMenu {
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
        if ($null -ne $menuItems[$i]) {
            $item = $menuItems[$i]
            if ($Multiselect) {
                if ($selection -contains $i) {
                    $item = "[x] " + $item
                } else {
                    $item = "[ ] " + $item
                }
            }
            if ($i -eq $menuPosition) {
                Write-Host "> $($item)" -ForegroundColor Green
            } else {
                Write-Host "  $($item)"
            }
        }
    }
}

function Toggle-Selection {
    param ($pos, [array]$selection)
        if ($selection -contains $pos) {
            $result = $selection | Where-Object {$_ -ne $pos}
        } else {
            $selection += $pos
                $result = $selection
        }
    $result
}

function Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
    $vkeycode = 0
    $pos = 0
    $selection = @()
    if ($menuItems.Length -gt 0) {
        try {
            [console]::CursorVisible=$false #prevents cursor flickering
            DrawMenu $menuItems $pos $Multiselect $selection
            while ($vkeycode -ne 13 -and $vkeycode -ne 27) {
                $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
                $vkeycode = $press.virtualkeycode
                if ($vkeycode -eq 38) { $pos-- }
                if ($vkeycode -eq 40) { $pos++ }
                if ($vkeycode -eq 36) { $pos = 0 }
                if ($vkeycode -eq 35) { $pos = $menuItems.length - 1 }
                if ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
                if ($pos -lt 0) { $pos = 0 }
                if ($vkeycode -eq 27) { $pos = $null }
                if ($pos -ge $menuItems.length) { $pos = $menuItems.length -1 }
                if ($vkeycode -ne 27) {
                    $startPos = [System.Console]::CursorTop - $menuItems.Length
                    [System.Console]::SetCursorPosition(0, $startPos)
                    DrawMenu $menuItems $pos $Multiselect $selection
                }
            }
        } finally {
            [System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
            [console]::CursorVisible = $true
        }
    } else {
        $pos = $null
    }

    if ($ReturnIndex -eq $false -and $null -ne $pos) {
        if ($Multiselect){
            return $menuItems[$selection]
        } else {
            return $menuItems[$pos]
        }
    } else {
        if ($Multiselect){
            return $selection
        } else {
            return $pos
        }
    }
}

function installScoop {
    param(
        [switch]$update
    )
    $ErrorActionPreference = "Stop"
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        writeLog INFO "Scoop not installed. Installing"
        $installer = Join-Path $env:TEMP "scoop-$([guid]::NewGuid()).ps1"
        try {
            Invoke-RestMethod https://get.scoop.sh -OutFile $installer
            if (Test-Path "D:\") {
                & $installer -RunAsAdmin -ScoopDir $SCOOP_DIR
                New-Item -ItemType SymbolicLink -Path ~\scoop -Target $SCOOP_DIR | Out-Null
            } else {
                & $installer -RunAsAdmin
            }
        } finally {
            if (Test-Path -LiteralPath $installer) { Remove-Item -LiteralPath $installer }
        }
        foreach ($bucket in "extras", "versions") {
            scoop bucket add $bucket
            if ($LASTEXITCODE -ne 0) { throw "scoop bucket add $bucket failed (exit $LASTEXITCODE)" }
        }
        writeLog INFO "Scoop installed"
    }
    if ($update) {
        $update_output = scoop update 6>&1
        if ($LASTEXITCODE -ne 0) {
            $update_output | Out-Host
            throw "Scoop update failed (exit code $LASTEXITCODE)"
        }
        writeLog INFO "Scoop updated"
    }
}

function resolvePackageLauncher($manager) {
    $prefix = @()
    switch ($manager) {
        "npm" {
            $shim = Get-Command npm.cmd -CommandType Application -ErrorAction Stop | Select-Object -First 1
            $dir = Split-Path $shim.Path
            $path = Join-Path $dir "node.exe"
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                $path = (Get-Command node.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Path
            }
            $cli = Join-Path $dir "node_modules\npm\bin\npm-cli.js"
            if (-not (Test-Path -LiteralPath $cli -PathType Leaf)) { throw "Missing npm CLI: $cli" }
            $prefix = @($cli)
        }
        "scoop" {
            $path = Join-Path $PSHOME "pwsh.exe"
            $shim = (Get-Command scoop.ps1 -CommandType ExternalScript -ErrorAction Stop | Select-Object -First 1).Path
            $prefix = @("-NoProfile", "-NonInteractive", "-File", $shim)
        }
        default {
            $app = Get-Command "$manager.exe" -CommandType Application -ErrorAction Stop | Select-Object -First 1
            $path = $app.Path
        }
    }
    @{ manager = $manager; path = $path; prefix = $prefix }
}

function invokePackageCommand($launcher, [string[]]$arguments, [switch]$capture) {
    $process = [Diagnostics.Process]::new()
    $info = $process.StartInfo
    $info.FileName = $launcher.path
    $info.UseShellExecute = $false
    $info.RedirectStandardError = $info.RedirectStandardInput = $info.RedirectStandardOutput = $true
    $info.CreateNoWindow = $true
    if ($launcher.manager -in "pip", "pipx") { $info.Environment["PIP_NO_INPUT"] = "1" }
    foreach ($arg in @($launcher.prefix) + $arguments) { $info.ArgumentList.Add($arg) }
    $started = $false
    try {
        $started = $process.Start()
        $process.StandardInput.Close()
        $pipes = foreach ($channel in "StandardOutput", "StandardError") {
            $buffer = [char[]]::new(4096)
            $reader = $process.$channel
            @{ buffer = $buffer; channel = $channel; reader = $reader; task = $reader.ReadAsync($buffer, 0, 4096)
                text = if ($capture) { [Text.StringBuilder]::new() } }
        }
        while ($pipes[0].task -or $pipes[1].task) {
            $ready = $false
            foreach ($pipe in $pipes) {
                if (-not $pipe.task -or -not $pipe.task.IsCompleted) { continue }
                $ready = $true
                $length = $pipe.task.GetAwaiter().GetResult()
                if ($length -eq 0) {
                    $pipe.task = $null
                    continue
                }
                $chunk = [string]::new($pipe.buffer, 0, $length)
                if ($capture) {
                    [void]$pipe.text.Append($chunk)
                } else {
                    @{ channel = $pipe.channel; kind = "chunk"; text = $chunk }
                }
                $pipe.task = $pipe.reader.ReadAsync($pipe.buffer, 0, $pipe.buffer.Length)
            }
            if (-not $ready) { [Threading.Thread]::Sleep(10) }
        }
        while (-not $process.WaitForExit(50)) { }
        if ($capture) {
            @{ code = $process.ExitCode; stderr = $pipes[1].text.ToString(); stdout = $pipes[0].text.ToString() }
        } else {
            @{ code = $process.ExitCode; kind = "exit" }
        }
    } finally {
        try {
            if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        } finally {
            $process.Dispose()
        }
    }
}

function readPackageCommand($launcher, [string[]]$arguments) {
    $result = invokePackageCommand $launcher $arguments -capture
    if ($result.code -ne 0) {
        if ($launcher.manager -eq "winget" -and $arguments[0] -eq "list" -and $result.code -eq -1978335212) {
            return ""
        }
        throw "$($launcher.manager) $arguments (exit $($result.code)): $($result.stderr) $($result.stdout)"
    }
    $result.stdout
}

function newPackageOperation($launcher, [string[]]$packages, [string[]]$arguments, $targets) {
    @{ arguments = $arguments; kind = "operation"; launcher = $launcher; manager = $launcher.manager
        packages = $packages; targets = $targets }
}

function pythonPackageName([string]$spec) {
    if ($spec -match "^\s*([A-Za-z0-9][A-Za-z0-9._-]*)\s*(?:$|[\[<>=!~;@])") { $spec = $Matches[1] }
    $spec -replace "[-_.]+", "-"
}

function pipInstall($launcher, [string[]]$pkgs, [switch]$update) {
    $installed = @{}
    $json = readPackageCommand $launcher @("list", "--format=json")
    $packages = ConvertFrom-Json $json -AsHashtable -NoEnumerate -ErrorAction Stop
    if ($packages -isnot [array]) { throw "Invalid pip list: expected an array" }
    foreach ($package in $packages) {
        if (-not $package.name) { throw "Missing name in pip list" }
        $installed[(pythonPackageName $package.name)] = $true
    }
    $selected = @($pkgs.Where({ $installed.ContainsKey((pythonPackageName $_)) -eq $update.IsPresent }))
    if ($selected.Count) {
        $verb = if ($update) { @("install", "--upgrade") } else { "install" }
        newPackageOperation $launcher $selected (@($verb) + $selected)
    }
}

function pipxInstall($launcher, [string[]]$pkgs, [switch]$update) {
    $installed = @{}
    $json = readPackageCommand $launcher @("list", "--json")
    $venvs = (ConvertFrom-Json $json -AsHashtable -ErrorAction Stop).venvs
    if ($venvs -isnot [Collections.IDictionary]) { throw "Missing venvs in pipx list" }
    foreach ($venv in $venvs.GetEnumerator()) {
        $name = $venv.Value.metadata.main_package.package
        if (-not $name) { throw "Missing main package in pipx environment '$($venv.Key)'" }
        $installed[(pythonPackageName $venv.Key)] = $installed[(pythonPackageName $name)] = $true
    }
    $verb = if ($update) { "upgrade" } else { "install" }
    foreach ($pkg in $pkgs) {
        if ($installed.ContainsKey((pythonPackageName $pkg)) -eq $update.IsPresent) {
            newPackageOperation $launcher @($pkg) @($verb, $pkg)
        }
    }
}

function updateScoopAppPaths {
    $profile_path = Join-Path $PSScriptRoot "powershell\profile.ps1"
    $scoop_dir = if (Test-Path -LiteralPath $SCOOP_DIR) { $SCOOP_DIR } else { "$HOME\scoop" }
    $app_paths = Get-ChildItem -LiteralPath "$scoop_dir\shims" -File -Filter "*.shim" -ErrorAction Stop |
        Select-String -Pattern "^path\s*=\s*`"(.+)`"" |
        ForEach-Object {
            Split-Path -Parent ($_.Matches[0].Groups[1].Value -replace "^.*?\\apps\\", "$scoop_dir\apps\")
        } |
        Sort-Object -Unique
    $content = Get-Content -LiteralPath $profile_path -Raw -ErrorAction Stop
    $line = "`$scoop_app_paths = `"$($app_paths -join ";")`""

    if ($content -notmatch '(?m)^\$scoop_app_paths = [^\r\n]*') {
        throw "No `$scoop_app_paths line found in $profile_path"
    }
    if ($Matches[0] -ne $line) {
        Set-Content -LiteralPath $profile_path -Value $content.Replace($Matches[0], $line) -NoNewline -ErrorAction Stop
        writeLog UPDATE "Updated Scoop app paths in $profile_path"
    }
}

function readScoopInventory($launcher) {
    $inventory = @{}
    $json = readPackageCommand $launcher @("export")
    $apps = (ConvertFrom-Json $json -AsHashtable -ErrorAction Stop).apps
    if ($apps -isnot [array]) { throw "Invalid Scoop export: expected apps array" }
    foreach ($app in $apps) {
        if (-not $app.Name) { throw "Missing name in Scoop export" }
        # Like scoop prefix, prefer the user install when both scopes contain the same app.
        if (-not $inventory.ContainsKey($app.Name) -or ($app.Info -split ", ") -notcontains "Global install") {
            $inventory[$app.Name] = $app
        }
    }
    $inventory
}

function readScoopPrefix($launcher, $name) {
    $prefix = (readPackageCommand $launcher @("prefix", $name)).Trim()
    if (-not $prefix -or -not (Test-Path -LiteralPath $prefix -PathType Container)) {
        throw "Missing installed prefix for $name"
    }
    $prefix
}

function readScoopTarget($launcher, $target) {
    $json = if ($target.manifest) {
        if ($target.manifest -match "^(https?|ftp)://") {
            (Invoke-WebRequest -Uri $target.manifest -ErrorAction Stop).Content
        } else {
            Get-Content -LiteralPath $target.manifest -Raw -ErrorAction Stop
        }
    } else {
        readPackageCommand $launcher @("cat", $target.query)
    }
    $version = (ConvertFrom-Json $json -AsHashtable -ErrorAction Stop).version
    if ($version -isnot [string] -or -not $version.Trim()) { throw "Manifest has no version" }
    $version
}

function scoopInstall($launcher, [string[]]$pkgs, [switch]$update) {
    $targets = [ordered]@{}
    $installed = readScoopInventory $launcher
    foreach ($pkg in $pkgs) {
        $name = ($pkg -split "/")[-1]
        if ($installed.ContainsKey($name) -ne $update.IsPresent) { continue }
        try {
            $target = @{ global = $false; manifest = $null; name = $name; query = $pkg }
            if ($update) {
                $entry = $installed[$name]
                $flags = $entry.Info -split ", "
                if (-not $entry.Version -or $flags -contains "Install failed") { throw "Incomplete install" }
                $target.global = $flags -contains "Global install"
                $prefix = readScoopPrefix $launcher $name
                $file = Join-Path $prefix "scoop-install.json"
                if (-not (Test-Path -LiteralPath $file)) { $file = Join-Path $prefix "install.json" }
                $record = Get-Content -LiteralPath $file -Raw -ErrorAction Stop | ConvertFrom-Json -AsHashtable
                if ($record -isnot [Collections.IDictionary]) { throw "Invalid install record: $file" }
                if ($record.hold -is [bool] -and $record.hold) {
                    @{ kind = "skip"; text = "$pkg - Held" }
                    continue
                }
                if ($record.bucket) {
                    $target.query = "$($record.bucket)/$name"
                } elseif ($record.url) {
                    $target.manifest = $record.url
                } else {
                    $target.query = "main/$name"
                }
            }
            $target.version = readScoopTarget $launcher $target
            $targets[$pkg] = $target
        } catch {
            @{ kind = "failure"; text = "$pkg`: $_" }
        }
    }
    if ($targets.Count) {
        $verb = if ($update) { @("update", "-s") } else { @("install", "--no-update-scoop", "-s") }
        newPackageOperation $launcher @($targets.Keys) ($verb + @($targets.Keys)) $targets
    }
}

function testScoopVersion($version, $target, $start, $end) {
    if ($target -ne "nightly") { return $version -eq $target }
    if ($version -notmatch "^nightly-(\d{8})$") { return $false }
    $date = [datetime]::MinValue
    [datetime]::TryParseExact($Matches[1], "yyyyMMdd", [cultureinfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None, [ref]$date) -and $date -ge $start.Date -and $date -le $end.Date
}

function confirmScoopTargets($op, $start, $end) {
    $installed = readScoopInventory $op.launcher
    foreach ($pkg in $op.packages) {
        try {
            $target = $op.targets[$pkg]
            $entry = $installed[$target.name]
            $flags = $entry.Info -split ", "
            if (-not $entry.Version -or $flags -contains "Install failed" -or
                ($flags -contains "Global install") -ne $target.global) { throw "Missing or incomplete install" }
            $null = readScoopPrefix $op.launcher $target.name
            $expected = $target.version
            if (-not (testScoopVersion $entry.Version $expected $start $end)) {
                $expected = readScoopTarget $op.launcher $target
                if (-not (testScoopVersion $entry.Version $expected $start $end)) {
                    throw "Target not verified: expected $expected, found $($entry.Version)"
                }
            }
        } catch {
            @{ kind = "failure"; text = "$pkg`: $_" }
        }
    }
}

function npmInstall($launcher, [string[]]$pkgs, [switch]$update) {
    $json = readPackageCommand $launcher @("ls", "--global", "--depth=0", "--json")
    $list = ConvertFrom-Json $json -AsHashtable -NoEnumerate -ErrorAction Stop
    if ($list -isnot [Collections.IDictionary]) { throw "Invalid npm inventory" }
    $installed = $list.dependencies ?? @{}
    if ($installed -isnot [Collections.IDictionary]) { throw "Invalid npm dependencies" }
    $selected = @($pkgs.Where({ $installed.Contains(($_ -replace "(?<=.)@[^/]*$", "")) -eq $update.IsPresent }))
    if ($selected.Count) {
        $verb = if ($update) { "update" } else { "install" }
        newPackageOperation $launcher $selected (@($verb, "-g") + $selected)
    }
}

function wingetInstall($launcher, [string[]]$pkgs, [switch]$update) {
    $status = readPackageCommand $launcher @("list", "--accept-source-agreements", "--disable-interactivity")
    $verb = if ($update) { "upgrade" } else { "install" }
    $flags = @("--accept-package-agreements", "--accept-source-agreements", "--disable-interactivity", "--silent")
    foreach ($pkg in $pkgs) {
        if (($status -cmatch "(?<!\S)$([regex]::Escape($pkg))(?!\S)") -eq $update.IsPresent) {
            newPackageOperation $launcher @($pkg) (@($verb, "-e", "--id", $pkg) + $flags)
        }
    }
}

function invokePackageWork($op) {
    $ErrorActionPreference = "Stop"
    if ($op.kind -eq "discover") {
        $launcher = resolvePackageLauncher $op.manager
        & "$($op.manager)Install" -launcher $launcher -pkgs $op.packages -update:$op.update
        return
    }

    $start = Get-Date
    $code = $null
    invokePackageCommand $op.launcher $op.arguments | ForEach-Object {
        if ($_.kind -eq "exit") { $code = $_.code } else { $_ }
    }
    if ($op.manager -eq "winget" -and $op.arguments[0] -eq "upgrade" -and $code -eq -1978335189) {
        @{ kind = "skip"; text = "No applicable update" }
    } elseif ($null -eq $code -or $code -ne 0) {
        throw "$($op.manager) $($op.arguments) (exit $code)"
    } elseif ($op.manager -eq "scoop") {
        confirmScoopTargets $op $start (Get-Date)
    }
}

function plainPackageText([string]$text) {
    $text -replace "\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)" -replace "\x1b\[[0-?]*[ -/]*[@-~]" `
        -replace "\t", "    " -replace "[\x00-\x1f\x7f-\x9f]"
}

function addPackageLine($ui, $job, [string]$text, [switch]$failure) {
    $panel = $ui.panels[$job.op.manager]
    $line = plainPackageText $text
    $tag = $job.op.manager
    if ($job.package) {
        $tag += "/$($job.package)"
        $display = "[$($job.package)] $line"
    } else {
        $display = $line
    }
    if ($failure) {
        $panel.failure = $display
        $ui.failures.Add("[$tag] $line")
    }
    if ($panel.lines.Count -eq 4) { $null = $panel.lines.Dequeue() }
    $panel.lines.Enqueue($display)
    if (-not $ui.live) { [Console]::WriteLine("[$tag] $line") }
    $ui.dirty = $true
}

function receivePackageChunk($ui, $job, $event) {
    $channel = $event.channel
    $text = $job.pending[$channel] + $event.text
    $lines = $text.Split("`n")
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($i -eq $lines.Count - 1) {
            # Keep a trailing CR: the next read may complete a CRLF.
            $job.pending[$channel] = $line -replace "(?s)^.*\r(?=.)", ""
        } else {
            addPackageLine $ui $job (($line -replace "\r$") -replace "(?s)^.*\r")
        }
    }
}

function getPackageConsole {
    if ([Console]::IsOutputRedirected -or -not $Host.UI.SupportsVirtualTerminal -or
        $Host.Name -ne "ConsoleHost" -or $env:TERM -eq "dumb") { return }
    try {
        @{ height = [Console]::WindowHeight; width = [Console]::WindowWidth - 1 }
    } catch [IO.IOException] { return }
}

function fitPackageLine([string]$line, [int]$width) {
    if ($Host.UI.RawUI.LengthInBufferCells($line) -le $width) { return $line }
    $cells = 0
    $elements = [Globalization.StringInfo]::GetTextElementEnumerator($line)
    while ($elements.MoveNext()) {
        $cells += $Host.UI.RawUI.LengthInBufferCells($elements.GetTextElement())
        if ($cells -gt $width) { return $line.Substring(0, $elements.ElementIndex) }
    }
    $line
}

function renderPackageOutput($ui) {
    if (-not $ui.live) { return }
    $size = getPackageConsole
    $height = 5 * $ui.panels.Count
    if (-not $size -or $size.height -le $height -or $size.width -lt 1) {
        $ui.live = $false
        foreach ($name in $ui.panels.Keys) {
            [Console]::WriteLine("[$name] $($ui.mode)")
            foreach ($line in $ui.panels[$name].lines) { [Console]::WriteLine("[$name] $line") }
        }
        return
    }
    if (-not $ui.dirty -and $ui.width -eq $size.width) { return }
    $frame = [Text.StringBuilder]::new()
    if ($ui.rows) { [void]$frame.Append("`e[$($ui.rows)F") }
    foreach ($name in $ui.panels.Keys) {
        $panel = $ui.panels[$name]
        $status = if ($panel.failure) { "failed: $($panel.failure)" } else { plainPackageText $panel.status }
        $heading = "$name - $($ui.mode) [$status]"
        $lines = @($heading) + $panel.lines.ToArray() + (@("") * (4 - $panel.lines.Count))
        $content = $lines -join "`n"
        if ($ui.rows -and $ui.width -eq $size.width -and $content -ceq $panel.previous) {
            [void]$frame.Append("`e[5E")
        } else {
            foreach ($line in $lines) {
                [void]$frame.AppendLine("`e[2K$(fitPackageLine $line $size.width)")
            }
            $panel.previous = $content
        }
    }
    [Console]::Write($frame.ToString())
    $ui.dirty = $false
    $ui.rows = $height
    $ui.width = $size.width
}

function stopPackageOperations($jobs) {
    # Stopping the runspace unwinds invokePackageCommand's finally and kills only its child tree.
    foreach ($job in $jobs) {
        try { $job.ps.Stop() } finally { $job.ps.Dispose(); $job.output.Dispose() }
    }
}

function runPackageOperations($work, $ui, $onComplete) {
    if (-not $work.Count) { return }
    $jobs = [Collections.Generic.List[object]]::new()
    $state = [Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()
    $helpers = @("confirmScoopTargets", "invokePackageCommand", "invokePackageWork", "newPackageOperation",
        "npmInstall", "pipInstall", "pipxInstall", "pythonPackageName", "readPackageCommand", "readScoopInventory",
        "readScoopPrefix", "readScoopTarget", "resolvePackageLauncher", "scoopInstall", "testScoopVersion",
        "wingetInstall")
    foreach ($name in $helpers) {
        $definition = (Get-Command $name -CommandType Function).Definition
        $state.Commands.Add([Management.Automation.Runspaces.SessionStateFunctionEntry]::new($name, $definition))
    }
    $workerLog = {
        param($type, $message)
        if ($type -eq "ERROR") { Write-Error $message -ErrorAction Continue }
        else { Write-Information $message -InformationAction Continue }
    }
    $state.Commands.Add([Management.Automation.Runspaces.SessionStateFunctionEntry]::new("writeLog", "$workerLog"))
    $pool = [runspacefactory]::CreateRunspacePool($state)
    try {
        if (-not $pool.SetMaxRunspaces($work.Count)) { throw "Cannot size package worker pool" }
        $pool.Open()
        foreach ($op in $work) {
            $ps = [powershell]::Create()
            $output = [Management.Automation.PSDataCollection[psobject]]::new()
            $package = if ($op.kind -eq "operation" -and $op.manager -in "pipx", "winget") { $op.packages[0] }
            $job = @{ op = $op; output = $output; package = $package; pending = @{}; ps = $ps; skipped = $false }
            $jobs.Add($job)
            $ps.RunspacePool = $pool
            $null = $ps.AddCommand("invokePackageWork").AddParameter("op", $op)
            $job.handle = $ps.BeginInvoke[psobject, psobject]($null, $output)
        }
        while ($jobs.Count) {
            foreach ($job in $jobs.ToArray()) {
                # Sample completion before draining so the final drain cannot miss a late record.
                $done = $job.handle.IsCompleted
                $panel = $ui.panels[$job.op.manager]
                foreach ($event in $job.output.ReadAll()) {
                    switch ($event.kind) {
                        "chunk" { receivePackageChunk $ui $job $event }
                        "failure" { addPackageLine $ui $job $event.text -failure }
                        "operation" { $ui.operations.Add($event) }
                        "skip" {
                            $job.skipped = $true
                            addPackageLine $ui $job "Skipped: $($event.text)"
                        }
                    }
                }
                foreach ($stream in "Error", "Information", "Warning") {
                    foreach ($record in $job.ps.Streams.$stream.ReadAll()) {
                        addPackageLine $ui $job "$record" -failure:($stream -eq "Error")
                    }
                }
                foreach ($record in $job.ps.Streams.Progress.ReadAll()) {
                    $job.progress = $record.StatusDescription
                    $panel.status = $job.progress
                    $ui.dirty = $true
                }
                if (-not $done) { continue }
                foreach ($line in $job.pending.Values) {
                    if ($line) { addPackageLine $ui $job ($line.TrimEnd("`r")) }
                }
                try {
                    $null = $job.ps.EndInvoke($job.handle)
                } catch {
                    addPackageLine $ui $job "$($job.op.packages -join ', '): $($_.Exception.Message)" -failure
                }
                $job.ps.Dispose()
                $job.output.Dispose()
                [void]$jobs.Remove($job)
                if ($job.op.kind -eq "operation" -and -not $job.skipped) { $panel.completed++ }
                if (-not $jobs.Where({ $_.op.manager -eq $job.op.manager })) {
                    $panel.status = if ($panel.completed) { "done" } else { "skipped" }
                    if ($onComplete) { & $onComplete $job.op.manager }
                }
                $ui.dirty = $true
            }
            renderPackageOutput $ui
            if ($jobs.Count) { Start-Sleep -Milliseconds 50 }
        }
    } finally {
        try {
            if ($jobs.Count) {
                [Console]::Error.WriteLine("Package work interrupted; service-owned installers may still be running.")
            }
            stopPackageOperations $jobs
        } finally { $pool.Dispose() }
    }
}

function installCollectedPackages($collected, [switch]$update) {
    $bootstrap = $true
    $discover = [Collections.Generic.List[object]]::new()
    $ui = @{
        dirty = $true; failures = [Collections.Generic.List[string]]::new(); live = $false
        mode = if ($update) { "Updating" } else { "Installing" }
        operations = [Collections.Generic.List[object]]::new(); panels = [ordered]@{}; rows = 0
    }
    foreach ($name in ($collected.Keys | Sort-Object)) {
        if ($collected[$name].Count -or $name -eq "scoop") {
            $ui.panels[$name] = @{
                completed = 0; lines = [Collections.Generic.Queue[string]]::new(); status = "pending"
            }
        }
    }
    try {
        installScoop -update:$update | Out-Host
    } catch {
        $bootstrap = $false
        addPackageLine $ui @{ op = @{ manager = "scoop" } } "Bootstrap: $_" -failure
    }
    foreach ($name in $ui.panels.Keys) {
        if (-not $collected[$name].Count -or ($name -eq "scoop" -and -not $bootstrap)) { continue }
        $discover.Add(@{
            kind = "discover"; manager = $name; packages = @($collected[$name].Keys); update = [bool]$update
        })
    }
    runPackageOperations $discover $ui

    $refresh = {
        param($name)
        if ($name -eq "scoop") {
            $job = @{ op = @{ manager = "scoop" } }
            try {
                updateScoopAppPaths 6>&1 | ForEach-Object { addPackageLine $ui $job "$_" }
            } catch {
                addPackageLine $ui $job "Profile path refresh: $_" -failure
            }
        }
    }
    $active = @($ui.operations | ForEach-Object { $_.manager } | Sort-Object -Unique)
    if ($bootstrap -and "scoop" -notin $active) { & $refresh "scoop" }
    foreach ($name in @($ui.panels.Keys)) {
        if ($name -in $active) {
            $ui.panels[$name].status = "running"
        } elseif ($ui.panels[$name].failure) {
            $ui.panels[$name].status = "failed"
        } else {
            $ui.panels.Remove($name)
        }
    }
    if ($ui.operations.Count) {
        $size = getPackageConsole
        $ui.live = $size -and $size.height -gt 5 * $ui.panels.Count -and $size.width -gt 0
        if (-not $ui.live) {
            foreach ($name in $active) { [Console]::WriteLine("[$name] $($ui.mode)") }
        }
        renderPackageOutput $ui
        runPackageOperations $ui.operations $ui $refresh
    }
    foreach ($failure in $ui.failures) { [Console]::Error.WriteLine($failure) }
    if ($ui.failures.Count) { throw "$($ui.failures.Count) package error(s); see the manager summary above." }
}

function githubInstall {
    param(
        [hashtable[]]$pkgs,
        [switch]$update
    )
    if ($pkgs.Length -eq 0) {
        return
    }

    $versionFile = "$env:XDG_STATE_HOME\autosetup\github-releases.json"
    if (Test-Path $versionFile) {
        $versions = Get-Content $versionFile -Raw | ConvertFrom-Json -AsHashtable
    } else {
        $versions = @{}
    }

    foreach ($pkg in $pkgs) {
        $repo = $pkg.repo
        $installed = $versions.ContainsKey($repo)

        if (-not $installed -and $update) {
            continue
        }

        $latestTag = gh release view --repo $repo --json tagName --jq ".tagName"
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($latestTag)) {
            writeLog ERROR "Failed to resolve latest release tag: $repo"
            continue
        }
        $latestTag = $latestTag.Trim()

        if ($installed -and $versions[$repo] -eq $latestTag) {
            writeLog INFO "GitHub release up to date: $repo ($latestTag)"
            continue
        }
        if ($installed) {
            writeLog UPDATE "Updating GitHub release: $repo -> $latestTag"
        } else {
            writeLog UPDATE "Installing GitHub release: $repo ($latestTag)"
        }

        if (-not (Test-Path $pkg.dir)) {
            New-Item -ItemType Directory -Path $pkg.dir | Out-Null
        }
        $tmp = Join-Path $env:TEMP ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tmp | Out-Null
        try {
            gh release download $latestTag --repo $repo --pattern $pkg.asset --dir $tmp
            if ($LASTEXITCODE -ne 0) {
                writeLog ERROR "Failed to download release asset: $repo ($($pkg.asset))"
                continue
            }
            $downloaded = @(Get-ChildItem -File $tmp)
            if ($downloaded.Count -ne 1) {
                writeLog ERROR "Expected exactly one asset for $repo, got $($downloaded.Count)"
                continue
            }
            $asset = $downloaded[0]
            switch ($asset.Extension) {
                ".zip" { Expand-Archive -Path $asset.FullName -DestinationPath $pkg.dir -Force }
                ".exe" { Move-Item -Path $asset.FullName -Destination $pkg.dir -Force }
                default {
                    writeLog ERROR "Unsupported asset type for $repo`: $($asset.Name)"
                    continue
                }
            }
            $versions[$repo] = $latestTag
        } finally {
            Remove-Item -Recurse -Force $tmp
        }
    }

    $stateDir = Split-Path $versionFile
    if (-not (Test-Path $stateDir)) {
        New-Item -ItemType Directory -Path $stateDir | Out-Null
    }
    $versions | ConvertTo-Json | Set-Content -Path $versionFile
}

function linkConfigs {
    param(
        [hashtable]$files
    )
    foreach ($key in $files.keys) {
        $src = (Resolve-Path -LiteralPath $key -ErrorAction Stop).Path
        foreach ($dest in @($files[$key])) {
            $dir = Split-Path -Parent $dest
            if (-not (Test-Path $dir)) {
                mkdir $dir
            }
            if (Test-Path $dest) {
                $target = Get-Item $dest | Select-Object -ExpandProperty Target
                if ($target -eq $src) {
                    Write-Verbose "$src already linked" -verbose
                    continue
                }
                backupConfig $dest
                Remove-Item -Force -Path $dest
            }
            Write-Output "Linking $src --> $dest"
            New-Item -ItemType SymbolicLink -Path $dest -Target $src
        }
    }
}

function copyOrUpdateConfigs {
    param(
        [hashtable]$files,
        [switch]$update
    )
    foreach ($key in $files.keys) {
        $src = (Resolve-Path -LiteralPath $key -ErrorAction Stop).Path
        foreach ($dest in @($files[$key])) {
            $dir = Split-Path -Parent $dest
            if ($update) {
                if (Test-Path $dest) {
                    $srcFile = Get-Item $src
                    $destFile = Get-Item $dest
                    if ($srcFile.LastWriteTime -gt $destFile.LastWriteTime) {
                        Write-Output "Copying $src --> $dest"
                        Copy-Item $src $dest
                    } elseif ($srcFile.LastWriteTime -lt $destFile.LastWriteTime) {
                        Write-Output "Copying $dest --> $src"
                        Copy-Item $dest $src
                    }
                }
            } else {
                if (-not (Test-Path $dir)) {
                    mkdir $dir
                }
                if (Test-Path $dest) {
                    if (Compare-Object (Get-Content $src) (Get-Content $dest)) {
                        backupConfig $dest
                        Write-Output "Copying $src --> $dest"
                        Copy-Item -Force -Path $src -Destination $dest
                    } else {
                        Write-Verbose "$src already exists" -verbose
                    }
                } else {
                    Write-Output "Copying $src --> $dest"
                    Copy-Item -Path $src -Destination $dest
                }
            }
        }
    }
}

function backupConfig {
    param(
        [string]$dest
    )
    $orig = "${dest}.orig"
    if (Test-Path $orig) {
        return
    }
    $item = Get-Item -Force -Path $dest -ErrorAction SilentlyContinue
    if (-not $item) {
        return
    }
    if ($item.LinkType) {
        Write-Output "backup link $dest --> $orig"
        New-Item -ItemType SymbolicLink -Path $orig -Target $item.Target | Out-Null
    } else {
        Write-Output "backup $dest --> $orig"
        Copy-Item -Path $dest -Destination $orig
    }
}

function deployConfigs {
    param(
        [hashtable]$files
    )
    foreach ($key in $files.keys) {
        $src = (Resolve-Path -LiteralPath $key -ErrorAction Stop).Path
        foreach ($dest in @($files[$key])) {
            $dir = Split-Path -Parent $dest
            if (-not (Test-Path $dir)) {
                mkdir $dir
            }
            $item = Get-Item -Force -Path $dest -ErrorAction SilentlyContinue
            if ($item -and $item.LinkType) {
                backupConfig $dest
                Write-Output "Removing link $dest"
                Remove-Item -Force -Path $dest
                Write-Output "Deploying $src --> $dest"
                Copy-Item -Path $src -Destination $dest
            } elseif ($item) {
                if ((Get-FileHash $src).Hash -ne (Get-FileHash $dest).Hash) {
                    backupConfig $dest
                    Write-Output "Deploying $src --> $dest"
                    Copy-Item -Force -Path $src -Destination $dest
                } else {
                    Write-Verbose "$src already deployed" -verbose
                }
            } else {
                Write-Output "Deploying $src --> $dest"
                Copy-Item -Path $src -Destination $dest
            }
        }
    }
}

function writeLog {
    param(
        [ValidateSet('INFO', 'ERROR', 'UPDATE')]
        [Parameter(Mandatory = $true)]
        [string]$type,
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    $color_map = @{
        "INFO" = "Blue";
        "ERROR" = "Red";
        "UPDATE" = "Yellow"
    }

    $color = $color_map[$type]

    Write-Host -ForegroundColor White -BackgroundColor $color -NoNewline " $type "
    Write-Host -ForegroundColor $color " $message"
}

# ╾─────────────────────────────────────────╼ main execution ╾─────────────────────────────────────────╼
$all_pkgs = Get-ChildItem -Recurse -Filter "setup.ps1" -Depth 1 | ForEach-Object { $_.Directory.BaseName }

if ($update) {
    writeLog INFO "Updating all installed packages"
    $pkg_list = $all_pkgs
} elseif ($install) {
    writeLog INFO "Installing $install"
    $pkg_list = $install
} else {
    Write-Output "Package List: (space to select, enter to install)"
    $pkg_list = Menu $all_pkgs -Multiselect
}

$module_requirements = [System.Collections.Generic.List[hashtable]]::new()
$root = Get-Location
foreach ($manager in $package_managers) {
    $collected_packages[$manager] = [System.Collections.Specialized.OrderedDictionary]::new(
        [System.StringComparer]::Ordinal
    )
}

foreach ($pkg in $pkg_list) {
    writeLog INFO "Package: $pkg"

    Set-Location -LiteralPath $pkg -ErrorAction Stop
    $cwd = Get-Location

    if (Test-Path setup.ps1) {
        $files = @{}
        $files_copy = @{}
        $files_deploy = @{}
        $github_pkgs = @()
        $npm_pkgs = @()
        $pip_pkgs = @()
        $pipx_pkgs = @()
        $scoop_pkgs = @()
        $winget_pkgs = @()

        . .\setup.ps1

        foreach ($manager in $package_managers) {
            $packages = [string[]](Get-Variable -Name "${manager}_pkgs" -ValueOnly)
            foreach ($package in $packages) {
                $collected_packages[$manager][$package] = $null
            }
        }
        $module_requirements.Add(@{
            pkg_dir = $cwd
            files = $files
            files_copy = $files_copy
            files_deploy = $files_deploy
            github_pkgs = $github_pkgs
        })
    } else {
        writeLog ERROR "No setup.ps1 found for $pkg"
    }
    Set-Location $root
}

foreach ($requirements in $module_requirements) {
    $pkg_dir = $requirements.pkg_dir
    Set-Location -LiteralPath $pkg_dir -ErrorAction Stop
    if ($update) {
        writeLog INFO "Updating Configs"

        copyOrUpdateConfigs -update $requirements.files_copy
        deployConfigs $requirements.files_deploy
        githubInstall -update $requirements.github_pkgs
    } else {
        writeLog INFO "Installing Configs"

        copyOrUpdateConfigs $requirements.files_copy
        deployConfigs $requirements.files_deploy
        githubInstall $requirements.github_pkgs
        linkConfigs $requirements.files
    }
    Set-Location $root
}

if ($module_requirements.Count -gt 0) {
    $finished = $false
    try {
        installCollectedPackages $collected_packages -update:$update
        $finished = $true
    } catch {
        $finished = $true
        throw
    } finally {
        # A stopped -File pipeline can otherwise report success to its caller.
        if (-not $finished) { exit 1 }
    }
}
