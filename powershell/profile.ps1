
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
    nvim $PROFILE.CurrentUserAllHosts
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

New-Alias -Name pacman -Value C:\msys64\usr\bin\pacman.exe


# Autocompletion
# ``````````````
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward # Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward # Autocompletion for arrow keys
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced


# Posh-git
Import-Module C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1


# Prompt Styling
# ``````````````
function promptGen {
    $blocks = @(
        @{
            'text' = '$(Get-Location)'
        },
        @{
            'text' = " > "
        }
    )
    
    $prompt_string = ""
    foreach ($block in $blocks) {
        if ($block.Contains('text')) {
            $prompt_string += $block['text']
        }
    }

    return $prompt_string
}

$prompt_string = promptGen

function prompt {
    "$prompt_string"
    #"`e[48;5;27m " + $(get-location) + " $(Get-GitBranch) `e[0m "
}

$readline = Get-PSReadLineOption
Set-PSReadLineOption -Colors @{ Command = $PSStyle.Italic + $readline.CommandColor }


# Settings
$env:PYTHONPYCACHEPREFIX = "$env:LOCALAPPDATA\Temp"
