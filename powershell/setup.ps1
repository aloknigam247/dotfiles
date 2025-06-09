$powershell_path = "C:\Program Files\PowerShell\7\pwsh.exe"

$scoop_pkgs = @(
    "PSFzf"
    "fzf"
    "posh-git"
)

$winget_pkgs = @(
    "gerardog.gsudo"
    "Microsoft.PowerShell"
)

$files = @{
    "profile5.ps1" = $(powershell '$PROFILE.AllUsersAllHosts') # powershell 5
    "profile.ps1"  = $(pwsh -Command 'echo $PROFILE.AllUsersAllHosts') # powershell 7
}
