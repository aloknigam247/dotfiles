$powershell_path = "C:\Program Files\PowerShell\7\pwsh.exe"

$scoop_pkgs = @(
    "PSFzf"
    "fzf"
    "posh-git"
)

$winget_pkgs = @(
    "gerardog.gsudo"
)

if ((Test-Path -Path $powershell_path) -eq $false) {
    $winget_pkgs.Add("Microsoft.PowerShell.Preview")
}

$files = @{
    "profile.ps1" = $PROFILE.AllUsersAllHosts;
}
