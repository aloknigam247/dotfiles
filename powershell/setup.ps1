$scoop_pkgs = @(
    "PSFzf"
    "fzf"
    "posh-git"
    "zoxide"
)

$winget_pkgs = @(
    "Microsoft.PowerShell.Preview",
    "gerardog.gsudo"
)

$files = @{
    "profile.ps1" = $PROFILE.AllUsersAllHosts;
}
