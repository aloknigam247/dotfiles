$powershell_path = "C:\Program Files\PowerShell\7\pwsh.exe"

$scoop_pkgs = @(
    "PSFzf"
    "fzf"
    "posh-git"
)

if ((Test-Path -Path $powershell_path) -eq $false) {
    $winget_pkgs = @(
        "gerardog.gsudo"
        "Microsoft.PowerShell.Preview"
    )
} else {
    $winget_pkgs = @(
        "gerardog.gsudo"
    )
}

$files = @{
    "profile.ps1" = $(powershell '$PROFILE') # powershell 5
    "profile.ps1" = $(pwsh -Command 'echo $PROFILE') # powershell 7
}
