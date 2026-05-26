$script:FlagCache = @{}

function Get-GitLocalBranch {
    param([string] $Filter = "")
    $branches = git for-each-ref --format="%(refname:short)" refs/heads/ 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    @($branches) | Where-Object { $_ -like "$Filter*" } | Sort-Object
}

function Get-GitRemoteBranch {
    param([string] $Filter = "")
    $branches = git for-each-ref --format="%(refname:short)" refs/remotes/ 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    @($branches) |
        Where-Object { -not $_.EndsWith("/HEAD") -and $_ -like "$Filter*" } |
        Sort-Object
}

function Get-GitTag {
    param([string] $Filter = "")
    $tags = git for-each-ref --format="%(refname:short)" refs/tags/ 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    @($tags) | Where-Object { $_ -like "$Filter*" } | Sort-Object
}

function Get-GitRemote {
    param([string] $Filter = "")
    $remotes = git remote 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    @($remotes) | Where-Object { $_ -like "$Filter*" } | Sort-Object
}

function Get-GitStash {
    param([string] $Filter = "")
    $stashes = git stash list --format="%gd" 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    @($stashes) | Where-Object { $_ -like "$Filter*" }
}

function Get-GitSubcommand {
    param([string] $Filter = "")
    $builtin = @(
        "add", "branch", "checkout", "cherry-pick", "clean", "clone",
        "commit", "config", "diff", "fetch", "init", "log", "merge",
        "mv", "pull", "push", "rebase", "reflog", "remote", "reset",
        "restore", "revert", "rm", "show", "stash", "status", "switch",
        "tag", "worktree"
    )
    $aliases = @()
    $raw = git config --get-regexp "^alias\." 2>$null
    if ($LASTEXITCODE -eq 0 -and $raw) {
        $aliases = @($raw) | ForEach-Object {
            $key = ($_ -split "\s+", 2)[0]
            $key -replace "^alias\.", ""
        }
    }
    @($builtin + $aliases) |
        Where-Object { $_ -like "$Filter*" } |
        Sort-Object -Unique
}

function Get-GitSubcommandFlag {
    param(
        [Parameter(Mandatory = $true)][string] $Subcommand,
        [string] $Filter = ""
    )
    if (-not $script:FlagCache.ContainsKey($Subcommand)) {
        $raw = git $Subcommand --git-completion-helper 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $raw) {
            $script:FlagCache[$Subcommand] = @()
        } else {
            $flags = ($raw -join " ") -split "\s+" |
                Where-Object { $_ -like "--*" -or $_ -like "-?" } |
                Sort-Object -Unique
            $script:FlagCache[$Subcommand] = @($flags)
        }
    }
    $script:FlagCache[$Subcommand] | Where-Object { $_ -like "$Filter*" }
}

function Get-GitWorkingFile {
    param(
        [switch] $IncludeUntracked,
        [string] $Filter = ""
    )
    $modified = git diff --name-only 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    $files = @($modified)
    if ($IncludeUntracked) {
        $untracked = git ls-files --others --exclude-standard 2>$null
        if ($LASTEXITCODE -eq 0) { $files += @($untracked) }
    }
    $files | Where-Object { $_ -and $_ -like "$Filter*" } | Sort-Object -Unique
}

function Get-GitConfigKey {
    param([string] $Filter = "")
    $common = @(
        "core.autocrlf", "core.editor", "init.defaultBranch", "merge.tool",
        "pull.rebase", "push.default", "rerere.enabled", "user.email", "user.name"
    )
    $set = git config --list --name-only 2>$null
    if ($LASTEXITCODE -ne 0) { $set = @() }
    @($common + @($set)) |
        Where-Object { $_ -and $_ -like "$Filter*" } |
        Sort-Object -Unique
}

function Get-GitCommandContext {
    param(
        $CommandAst,
        [string] $WordToComplete = ""
    )
    $elements = @($CommandAst.CommandElements)
    $valueConsuming = @("-C", "-c")
    $i = 1
    $subcommand = $null
    $remainingArgs = @()
    while ($i -lt $elements.Count) {
        $token = $elements[$i].Extent.Text
        if ($valueConsuming -contains $token) {
            $i += 2
            continue
        }
        if ($token -match "^--(git-dir|work-tree|namespace|exec-path)(=.*)?$") {
            if ($token.Contains("=")) { $i += 1 } else { $i += 2 }
            continue
        }
        if ($token.StartsWith("-") -and $null -eq $subcommand) {
            $i += 1
            continue
        }
        if ($null -eq $subcommand) {
            $subcommand = $token
        } elseif (-not $token.StartsWith("-")) {
            $remainingArgs += $token
        }
        $i += 1
    }
    # If the cursor is mid-token, $WordToComplete is non-empty and matches the trailing positional.
    # Drop it so $remainingArgs only contains already-completed positionals.
    if ($WordToComplete) {
        if ($remainingArgs.Count -gt 0 -and $remainingArgs[-1] -eq $WordToComplete) {
            if ($remainingArgs.Count -eq 1) {
                $remainingArgs = @()
            } else {
                $remainingArgs = $remainingArgs[0..($remainingArgs.Count - 2)]
            }
        } elseif ($null -ne $subcommand -and $remainingArgs.Count -eq 0 -and $subcommand -eq $WordToComplete) {
            $subcommand = $null
        }
    }
    @{
        Subcommand = $subcommand
        Args       = @($remainingArgs)
    }
}

function Register-GitCompleter {
    [CmdletBinding()]
    param(
        [string[]] $RefSubcommand    = @("branch", "checkout", "cherry-pick", "diff",
                                          "log", "merge", "rebase", "reset", "show", "switch"),
        [string[]] $RemoteSubcommand = @("fetch", "pull", "push"),
        [string[]] $FileSubcommand   = @("add", "restore"),
        [string[]] $FunctionName     = @("gc", "gwa"),
        [string]   $ParameterName    = "Branch"
    )

    $stashSubs = @("apply", "branch", "drop", "list", "pop", "push", "save", "show")
    $stashRefSubs = @("apply", "drop", "pop", "show")

    $nativeBlock = {
        param($wordToComplete, $commandAst, $cursorPosition)
        $ctx = Get-GitCommandContext -CommandAst $commandAst -WordToComplete $wordToComplete
        $sub = $ctx.Subcommand
        $positional = $ctx.Args
        $results = @()

        if ($wordToComplete.StartsWith("-") -and $sub) {
            $results = Get-GitSubcommandFlag -Subcommand $sub -Filter $wordToComplete
        } elseif ($null -eq $sub) {
            $results = Get-GitSubcommand -Filter $wordToComplete
        } elseif ($sub -eq "stash") {
            if ($positional.Count -eq 0) {
                $results = $stashSubs | Where-Object { $_ -like "$wordToComplete*" }
            } elseif ($stashRefSubs -contains $positional[0]) {
                $results = Get-GitStash -Filter $wordToComplete
            }
        } elseif ($sub -eq "config") {
            $results = Get-GitConfigKey -Filter $wordToComplete
        } elseif ($FileSubcommand -contains $sub) {
            $results = Get-GitWorkingFile -IncludeUntracked:($sub -eq "add") -Filter $wordToComplete
        } elseif ($RemoteSubcommand -contains $sub) {
            if ($positional.Count -eq 0) {
                $results = Get-GitRemote -Filter $wordToComplete
            } elseif ($sub -eq "pull") {
                $results = Get-GitRemoteBranch -Filter $wordToComplete
            } else {
                $results = Get-GitLocalBranch -Filter $wordToComplete
            }
        } elseif ($RefSubcommand -contains $sub) {
            $results = @()
            $results += Get-GitLocalBranch  -Filter $wordToComplete
            $results += Get-GitRemoteBranch -Filter $wordToComplete
            $results += Get-GitTag          -Filter $wordToComplete
        }

        $results | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
        }
    }.GetNewClosure()

    Register-ArgumentCompleter -Native -CommandName git -ScriptBlock $nativeBlock

    $functionBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-GitLocalBranch -Filter $wordToComplete | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
        }
    }

    Register-ArgumentCompleter -CommandName $FunctionName -ParameterName $ParameterName -ScriptBlock $functionBlock
}

Export-ModuleMember -Function `
    Get-GitCommandContext,
    Get-GitConfigKey,
    Get-GitLocalBranch,
    Get-GitRemote,
    Get-GitRemoteBranch,
    Get-GitStash,
    Get-GitSubcommand,
    Get-GitSubcommandFlag,
    Get-GitTag,
    Get-GitWorkingFile,
    Register-GitCompleter
