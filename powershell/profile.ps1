
#  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
# ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
# ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
# ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
# ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
# ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

# Auto Update
Start-Job {
    Set-Location ~/dotfiles
    git pull
    $git_status = git status

    if ($git_status) {
        $dt = Get-Date -Format "dd-MM-yyyy"
        git add .
        git commit -m "$dt updates"
        git push
    }
}

# Aliases
Set-Alias -Name v -Value nvim
Set-Alias -Name choco -Value 'C:\ProgramData\chocolatey\bin\choco.exe'

Import-Module oh-my-posh
oh-my-posh --init --shell pwsh --config C:\Users\aloknigam\.oh-my-posh\themes\rudolfs-light.omp.json | Invoke-Expression
