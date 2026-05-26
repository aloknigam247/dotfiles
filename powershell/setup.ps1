$powershell_path = "C:\Program Files\PowerShell\7\pwsh.exe"

$scoop_pkgs = @(
    "PSFzf"
    "fzf"
)

$winget_pkgs = @(
    "gerardog.gsudo"
    "Microsoft.PowerShell"
)

$files = @{
    "GitCompleter" = "$(Split-Path $(pwsh -Command 'echo $PROFILE.AllUsersAllHosts'))\Modules\GitCompleter"
    "profile5.ps1" = $(powershell '$PROFILE') # powershell 5
    "profile.ps1"  = $(pwsh -Command 'echo $PROFILE.AllUsersAllHosts') # powershell 7
}
