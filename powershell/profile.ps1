
#  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
# ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
# ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
# ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
# ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
# ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

# Auto Update
# ```````````
Start-Job {
    Set-Location ~/dotfiles
    git pull
    $git_status = git status --short

    if ($git_status) {
        $dt = Get-Date
        git add .
        git commit -m "Updated at $dt"
        rm .git\index.lock # fix lock error
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


# Aliases
# ```````
# Msys2
New-Alias -Name pacman -Value C:\msys64\usr\bin\pacman.exe

# Functions
# `````````
function eprc {
    nvim $PROFILE.AllUsersAllHosts
}

function evrc {
    # nvim $env:LOCALAPPDATA\nvim\init.vim -O $env:LOCALAPPDATA\nvim\lua\plugins.lua
    nvim $env:LOCALAPPDATA\nvim\lua\plugins.lua
}

function v {
   C:\Users\aloknigam\scoop\shims\neovide.exe --multigrid $args
}

function vpcl {
    nvim -c "PlugClean! | only" -c qa
}

function vpi {
    nvim -c "PlugInstall | only" -c qa
}

function pdbg {
    code .
    python -m debugpy --listen 5678 --wait-for-client $args
}

# Msys2 functions
function grep {
    C:\msys64\usr\bin\grep --color=auto -En $args
}

function fnd {
    C:\msys64\usr\bin\find.exe $args  | C:\msys64\usr\bin\sed 's|/|\\|g'
}

function la {
    C:\msys64\usr\bin\ls.exe -AF --color=auto $args
}

function ll {
    C:\msys64\usr\bin\ls.exe -lF --color=auto $args
}

function lla {
    C:\msys64\usr\bin\ls.exe -AlF --color=auto $args
}

Remove-Alias ls # remove default alias for ls
function ls {
    C:\msys64\usr\bin\ls.exe -F --color=auto $args
}

Remove-Alias rm
function rm {
    C:\msys64\usr\bin\rm.exe -rf $args
}

function tree {
    C:\msys64\usr\bin\tree.exe -CF $args
}

function treea {
    C:\msys64\usr\bin\tree.exe -aCF $args
}

function which($arg) {
    $cm = Get-Command $arg[0]
    $type = $cm.CommandType

    if ($type -eq "Function") {
        $cm.Definition
    } elseif ($type -eq "Application") {
        $cm.Source
    } else {
        Write-Host "Unknown"
    }
}

# Path functions
function desktop {
    Set-Location 'C:\Users\aloknigam\OneDrive - Microsoft\Desktop\'
}

# Git functions
function gs {
    git status --ignore-submodules=all --short --branch --show-stash --ahead-behind $args
}

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
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced


# Posh-git
#Import-Module C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1
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


# Prompt Styling
# ``````````````
function promptGen {
    $blocks = @(
        @{
            'text' = '$dir_icon  '
            'fg' = '#8AC926'
        }
        @{
            'text' = '$(Get-Location)'
            'fg' = '#A3BCF9'
            'styles' = "italic"
        },
        @{
            'text' = " ⟩⟩"
            'fg' = '#8AC926'
            'styles' = 'bold'
        }
        @{
            'text' = '$git_branch'
            'fg' = '#F4B860'
            'styles' = "italic"
        },
        @{
            'text' = "⟩⟩ "
            'fg' = '#8AC926'
            'styles' = 'bold'
        }
    )

    $prompt_string = ""
    foreach ($block in $blocks) {
        $prompt_string += Format-Text @block
    }

    return $prompt_string + "`e[0m"
}

$prompt_string = promptGen
function prompt {
    if ($env:COMPUTERNAME -eq "ALOKNIGAM-IDC") {
        $branch = git symbolic-ref --short HEAD 2>&1
            if ($? -eq $false) {
                $branch = $null
            }
    } else {
        $branch = git branch --show-current 2>&1
            if ($? -eq $false) {
                $branch = $null
            }
    }
    $git_branch = ""
    $dir_icon = ""
    if ($null -ne $branch) {
        $dir_icon = ""
        $git_branch = "  $branch "
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

# Settings
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit # exit on ^D
$env:PYTHONPYCACHEPREFIX = "$env:LOCALAPPDATA\Temp"
