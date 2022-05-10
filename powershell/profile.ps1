
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
        $dt = Get-Date -Format "dd-MM-yyyy"
        git add .
        git commit -m "$dt updates"
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
Set-Alias -Name v -Value nvim

# Functions
# `````````
function evrc {
    nvim $env:LOCALAPPDATA\nvim\init.vim
}

function vpcl {
    nvim -c PlugClean! -c qa
}

function vpi {
    nvim -c PlugInstall -c qa
}

# Msys2 functions
function grep {
    C:\msys64\usr\bin\grep.exe --color=auto -n $args
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

# oh-my-posh
# ``````````
Import-Module oh-my-posh
oh-my-posh --init --shell pwsh --config C:\Users\aloknigam\.oh-my-posh\themes\rudolfs-light.omp.json | Invoke-Expression
