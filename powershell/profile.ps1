# Auto Update
# ```````````
if ([Environment]::UserInteractive) {
    Start-Job {
        Set-Location D:/dotfiles
        git pull
        $git_status = git status --short

        if ($git_status) {
            $dt = Get-Date
            git add .
            git commit -m "Updated at $dt"
            Remove-Item .git\index.lock # fix lock error
            git push

            # Send ballon notification
            Add-Type -AssemblyName System.Windows.Forms
            $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
            $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
            $balmsg.BalloonTipText = " "
            $balmsg.BalloonTipTitle = "dotfiles updated"
            $balmsg.Visible = $true
            $balmsg.ShowBalloonTip(20000)
        }
    } | Out-Null
}


# Aliases
# ```````
# Msys2
New-Alias -Name pacman -Value D:\Scoop\apps\msys2\current\usr\bin\pacman.exe

# Functions
# `````````
Remove-Alias ls
Remove-Alias rm
function bash    { D:\Scoop\apps\msys2\current\usr\bin\bash.exe -c $args[0] }
function bat     { D:\Scoop\shims\bat.exe --style='numbers,changes' --italic-text=always $args }
function fnd     { D:\Scoop\apps\msys2\current\usr\bin\find.exe $args | D:\Scoop\apps\msys2\current\usr\bin\sed 's|/|\\|g' }
function grep    { D:\Scoop\apps\msys2\current\usr\bin\grep.exe --color=auto -En $args }
function la      { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AF --color=auto $args }
function lla     { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AlF --color=auto $args }
function ls      { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -F --color=auto $args }
function pdbg    { code .; python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client $args }
function rm      { D:\Scoop\apps\msys2\current\usr\bin\rm.exe -rf $args }
function tree    { D:\Scoop\apps\msys2\current\usr\bin\tree.exe -CF $args }
function treea   { D:\Scoop\apps\msys2\current\usr\bin\tree.exe -aCF $args }
function v($arg) { Start-Job -ScriptBlock {D:\scoop\shims\neovide.exe --size=2100x1254 --no-tabs -- $using:arg} | ForEach-Object { "Job Id: " + $_.Id } }

function e ($arg) {
    $code_ext = @('cs', 'ps1', 'psm1')

    if ($null -eq $arg) {
        $ext = ''
    } else {
        $ext = $arg.split('.')[-1]
    }

    if ( $null -ne $env:SSH_CLIENT ) {
        nvim $arg
    }
    elseif ( $ext -in $code_ext) {
        code $arg
    } else {
        v $arg
    }
}

function which($arg) {
    $cm = Get-Command $arg -ErrorAction SilentlyContinue
    $type = $cm.CommandType

    if ($type -eq "Function") {
        Format-Text "󰊕 $arg" -fg "#FF0022" -styles bold, italic
        $temp_file = "$env:TEMP\tmp.ps1"
        Write-Output $cm.Definition > $temp_file
        bat -p -P $temp_file
        Remove-Item $temp_file
    } elseif ($type -eq "Application") {
        Format-Text " $arg" -fg "#EEE82C" -styles bold, italic
        $cm.Source
    } elseif ($type -eq "Alias") {
        Format-Text " $arg" -fg "#5D2E8C" -styles bold, italic
        $cm.DisplayName
    } else {
        Write-Host "Unknown"
    }
}

function sed {
    [CmdletBinding()]
    param (
        [switch] $i,
        [switch] $n,
        [switch] $r,
        [Parameter(Mandatory = $true)]
        [string] $pattern,
        [string[]] $files

    )

    # echo $PSBoundParameters

    $param_n = $n ? '-n' : ''
    $param_i = $i ? '-i' : ''
    $param_r = $r ? '-r' : ''

    foreach($file in $files) {
        if($i) {
            dos2unix -b -q $file
        }
        Invoke-Expression "D:\Scoop\apps\msys2\current\usr\bin\sed.exe $param_i $param_n $param_r $pattern $file"
        if($i) {
            unix2dos -b -q $file
        }
    }
}

# Path functions
function desktop { Set-Location $([Environment]::GetFolderPath("Desktop")) }

# Git functions
Remove-Alias -Force gc
function gc {
    git checkout $args
    $stash = git stash list
    if ( $null -ne $stash ) {
        if ( $stash.Gettype() -eq [String] ) {
            Format-Text -bg "#F97068" -fg "#FFFFFF" $stash
        } elseif ( $stash.Gettype() -eq [Object[]] ) {
            foreach ( $st in $stash ) {
                Format-Text -bg "#F97068" -fg "#FFFFFF" $st
            }
        } else {
            Write-Host $stash
        }
    }
}

Remove-Alias -Force gl
function gl {
    git log --color=always --pretty="%C(#B4AD2D) %C(#DBD56E)%h %Creset- %C(#88AB75) %s %C(#216E82)󰔟 %ar on %ah %C(#7D7C84)<%C(#ACABB0)%an %C(#7D7C84) %ae>%C(#DE8F6E)%d" $args
}

function gs {
    git status --ignore-submodules=all --short --branch --show-stash --ahead-behind $args
}

# Substrate functions
function scmd {
    $cmd = "/k SET INETROOT=E:\substrate& cd /d E:\substrate& E:\substrate\tools\path1st\myenv.cmd"
    $cmd = $cmd + "& cd /d " + (Get-Location) + "& " + $args[0]
    Write-Host -ForegroundColor Blue "Executing: " $cmd
    cmd $cmd
}

# Get TODO from current directory
function Get-TODO {
    param(
        [Parameter(Position = 0)]
        [ValidateSet('all', 'random', 'stats')]
        [String] $type = 'All'
    )

    process {
        $tag_list = @('BUG', 'DOCME', 'FEAT', 'FIX', 'FIXME', 'HACK', 'PERF', 'REFACTOR', 'TEST', 'TODO', 'THOUGHT')

        if ($type -eq 'All') {
            # Get list of all
            $pattern = $tag_list -join '|'
            rg "($pattern):"  --trim --sort path -nw --color=always
        }
        elseif ($type -eq 'Random') {
            # Get random tag
            $pattern = $tag_list -join '|'
            rg "($pattern):"  --trim --sort path -nw --color=always | Get-Random -Count 3
        }
        elseif ($type -eq 'Stats') {
            # Generate count per tag
            $tag_map = @{}
            $total = 0
            foreach ($tag in $tag_list) {
                $count = (rg "${tag}:" -cwI | Measure-Object -Sum).Sum
                if ($count -gt 0) {
                    $total += $count
                    $tag_map[$tag] = $count
                }
            }
            Format-Table -AutoSize -HideTableHeaders -InputObject $tag_map
            Write-Host "TOTAL    $total" -ForegroundColor Blue
        }
    }
}

# Format text for colors and formatting
function Format-Text {
    param(
        [Parameter(ParameterSetName = "Complete")]
        [Parameter(Position=0)]
        [String]$text,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [String]$bg,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [String]$fg,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [ValidateSet("blink","bold","hidden","italic","reverse","strikethrough","underline")]
        [Array]$styles,

        [Parameter(ParameterSetName = "HeadOnly")]
        [Switch]$headonly,

        [Parameter(ParameterSetName = "Complete")]
        [Switch]$noreset
    )

    $head = ""

    # create background header
    if ($bg -ne "") {
        $bg_r_hex = "0x$($bg.Substring(1, 2))"
        $bg_g_hex = "0x$($bg.Substring(3, 2))"
        $bg_b_hex = "0x$($bg.Substring(5, 2))"
        $bg_r = [int]$bg_r_hex
        $bg_g = [int]$bg_g_hex
        $bg_b = [int]$bg_b_hex
        $head = "48;2;$bg_r;$bg_g;$bg_b"
    }

    # create forground header
    if ($fg -ne "") {
        if ($head -ne "") { $head += ";" } # seperator
        $fg_r_hex = "0x$($fg.Substring(1, 2))"
        $fg_g_hex = "0x$($fg.Substring(3, 2))"
        $fg_b_hex = "0x$($fg.Substring(5, 2))"
        $fg_r = [int]$fg_r_hex
        $fg_g = [int]$fg_g_hex
        $fg_b = [int]$fg_b_hex
        $head += "38;2;$fg_r;$fg_g;$fg_b"
    }

    # create effects header
    foreach ($style in $styles) {
        if ($head -ne "") { $head += ";" } # seperator
        switch ($style) {
            "blink"         { $head += "5" }
            "bold"          { $head += "1" }
            "hidden"        { $head += "8" }
            "italic"        { $head += "3" }
            "reverse"       { $head += "7" }
            "strikethrough" { $head += "9" }
            "underline"     { $head += "4" }
        }
    }

    if ($head -ne "") {
        $head = "`e[$head" + "m"
        if ($headOnly -eq $true) {
            return $head 
        }
        $head += $text
        if ($noreset -eq $false) {
            $head += "`e[0m"
        }
    } else {
        $head = $text
    }

    return $head
}

# Autocompletion
# ``````````````
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward # Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward # Autocompletion for arrow keys
try{
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced
} catch {
    Write-Error "Error occured in setting PredictionSource"
    Write-Error $_
}

# posh-git
Import-Module posh-git

# winget tab completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}


# FZF Setup
# `````````
# https://www.devguru.com/content/technologies/wsh/wshshell-sendkeys.html
Import-Module PSFzf

Set-PsFzfOption `
    -PSReadlineChordProvider 'Alt+p' `
    -PSReadlineChordReverseHistory 'Alt+h' `
    -PSReadlineChordSetLocation 'Alt+d' `
    -PSReadlineChordReverseHistoryArgs 'Alt+a'
Set-PSReadLineKeyHandler -Key Alt+t -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

$env:FZF_DEFAULT_OPTS='
    --height=~70% --layout=reverse --border=rounded --border-label=" FZF " --border-label-pos=5 --info=inline --prompt=" " --pointer="→" --preview="bat.exe --style=numbers {}" --preview-window="right,70%,border-rounded" --preview-label="(Preview)"
    --color=fg:#ffffff,bg:-1,hl:#71b7c2
    --color=fg+:#f0a330,bg+:#873df5,hl+:#a7daeb
    --color=info:#afaf87,prompt:#d7005f,pointer:#ff59f1
    --color=marker:#000000,spinner:#f0a6f5,header:#87afaf
'

# Prompt Styling
# ``````````````
$prompt_script = @{}

# FEAT: identifier for dirty git dir
function promptGen {
    $blocks = @(
        @{
            'params'  = @{
                'text' = '$script:dir_icon '
                'fg'   = '#8AC926'
            }
            'execute' = @{
                'sequence' = 2
                'script'   = {
                    $script:dir_icon = ""
                    if ($script:git_branch -ne "") {
                        $script:dir_icon = ""
                    }
                    if ($null -ne $env:SSH_CLIENT) {
                        $script:dir_icon = "󰅟"
                    }
                }
            }
        }
        @{
            'params' = @{
                'text'   = '$(Get-Location)'
                'fg'     = '#A3BCF9'
                'styles' = "italic"
            }
        },
        @{
            'params' = @{
                'text'   = ' ⟩⟩'
                'fg'     = '#8AC926'
                'styles' = 'bold'
            }
        },
        @{
            'params'  = @{
                'text'   = '$script:git_branch'
                'fg'     = '#F4B860'
                'styles' = "bold"
            }
            'execute' = @{
                'sequence' = 1
                'script'   = {
                    $git_branch = ""
                    $branch = git rev-parse --abbrev-ref HEAD
                    if ($null -eq $branch) {
                        $git_branch = ""
                    }
                    elseif ($branch -eq "HEAD" -Or $branch.StartsWith("heads/")) {
                        $branch = git describe --tags --always
                        if ($null -eq $branch) {
                            $git_branch = ""
                        }
                        elseif ($branch[0] -eq "v") {
                            $git_branch = " 󰓽 $branch "
                        }
                        else {
                            $git_branch = "  $branch "
                        }
                    }
                    elseif ($branch) {
                        $branch = $branch.Replace("heads/", "")
                        $branch = $branch.Replace("users/$env:username", "~")
                        $git_branch = "  $branch "
                    }
                    $script:git_branch = $git_branch
                }
            }
        },
        @{
            'params'  = @{
                'text' = '$script:git_diff'
                'fg'   = '#FF6347'
            }
            'execute' = @{
                'sequence' = 4
                'script'   = {
                    if ($script:git_branch) {
                        $script:git_diff = "󰦓 "
                    }
                    else {
                        $script:git_diff = ""
                    }
                }
            }
        },
        @{
            'params' = @{
                'text'   = '$script:git_sep '
                'fg'     = '#8AC926'
                'styles' = 'bold'
            }
            'execute' = @{
                'sequence' = 3
                'script'   = {
                    if ($script:git_branch) {
                        $script:git_sep = "⟩⟩"
                    }
                    else {
                        $script:git_sep = ""
                    }
                }
            }
        }
    )

    $prompt_string = ""
    foreach ($block in $blocks) {
        if ($block.ContainsKey('cond')) {
            $cont = Invoke-Command -ScriptBlock $block.cond
            if (-not $cont) {
                continue
            }
        }
        $params = $block.params
        $prompt_string += Format-Text @params
        if ($block.ContainsKey('execute')) {
            $execute = $block.execute
            $prompt_script[$execute.sequence] = $execute.script
        }
    }

    return $prompt_string + "`e[0m"
}

$prompt_string = promptGen
function prompt {
    $count = $prompt_script.Count
    $i = 0
    while ($i -le $count) {
        $script = $prompt_script[$i]
        if ($script) {
            Invoke-Command $script
        }
        $i = $i + 1
    }

    $ExecutionContext.InvokeCommand.ExpandString($prompt_string)
}

Set-PSReadLineOption -Colors @{
    "Command" = (Format-Text -headOnly -fg "#F42C04" -styles "bold");
    "Comment" = (Format-Text -headOnly -fg "#989FCE");
    "Emphasis" = (Format-Text -headOnly -fg "#ECA400");
    "Keyword" = (Format-Text -headOnly -fg "#F7F4F3" -styles "italic");
    "ListPredictionSelected" = (Format-Text -headOnly -styles "reverse");
    "Member" = (Format-Text -headOnly -styles "italic");
    "Number" = (Format-Text -headOnly -fg "#F24333");
    "Parameter" = (Format-Text -headOnly -fg "#9183EC");
    "Selection" = (Format-Text -headOnly -bg "#3C6E71");
    "String" = (Format-Text -headOnly -fg "#E4FF1A");
}

Set-PSReadLineOption -ContinuationPrompt '... '

# Source rg command line completer
. D:\Scoop\apps\ripgrep\current\complete\_rg.ps1

# Neovim settings
$env:XDG_CACHE_HOME  = 'D:\apps'
$env:XDG_CONFIG_HOME = 'D:\apps'
$env:XDG_DATA_HOME   = 'D:\apps'
$env:XDG_LOG_HOME    = 'D:\apps'
$env:XDG_STATE_HOME  = 'D:\apps'

# Settings
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit # exit on ^D
$PSNativeCommandUseErrorActionPreference = $false
$env:PSModulePath += ";P:\aloknigam;E:\aloknigam"
$env:PYTHONPYCACHEPREFIX = "$env:LOCALAPPDATA\Temp"
$env:RUFF_CACHE_DIR = "$env:LOCALAPPDATA\Temp"
$env:LESSUTFCHARDEF='23fb-23fe:p,2665:p,26a1:p,2b58:p,e000-e00a:p,e0a0-e0a2:p,e0a3:p,e0b0-e0b3:p,e0b4-e0c8:p,e0ca:p,e0cc-e0d4:p,e200-e2a9:p,e300-e3e3:p,e5fa-e6a6:p,e700-e7c5:p,ea60-ebeb:p,f000-f2e0:p,f300-f32f:p,f400-f532:p,f500-fd46:p,f0001-f1af0:p' # fix less nerd fond rendering