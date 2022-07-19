
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
# Set-Alias -Name v -Value "C:\Users\aloknigam\Downloads\goneovim-windows\goneovim-windows\goneovim.exe"
Set-Alias -Name spslocal -Value "d:\nugetcache\onedrive.deploymentagentsdk.9.0.288-g69360218f1\\loadsandbox.ps1"

# Functions
# `````````
function eprc {
    nvim $PROFILE.AllUsersAllHosts
}

function evrc {
    nvim $env:LOCALAPPDATA\nvim\init.vim
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

# Msys2 functions
Remove-Alias ls # remove default alias for ls

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

function desktop {
    Set-Location 'C:\Users\aloknigam\OneDrive - Microsoft\Desktop\'
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
        [Switch]$notail
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
        if ($noTail -eq $false) {
            $head += "`e[0m"
        }
    } else {
        $head = $text
    }

    return $head
}


New-Alias -Name pacman -Value C:\msys64\usr\bin\pacman.exe


# Autocompletion
# ``````````````
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward # Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward # Autocompletion for arrow keys
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced


# Posh-git
Import-Module C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1

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
            'text' = '$dir_icon  ';
            'fg' = '#8AC926';
            'styles' = "italic"
        }
        @{
            'text' = '$(Get-Location)'
        },
        @{
            'text' = '$git_branch'
        },
        @{
            'text' = " ⟩⟩ "
        }
    )
    
    $prompt_string = ""
    foreach ($block in $blocks) {
        $prompt_string += Format-Text @block -noTail
    }

    return $prompt_string + "`e[0m"
}

$prompt_string = promptGen

function prompt {
    $branch = Get-GitBranch
    $git_branch = ""
    $dir_icon = ""
    if ($null -ne $branch) {
        $dir_icon = ""
        $git_branch = " ⟩⟩  $branch"
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
