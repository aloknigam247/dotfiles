$choco_pkgs = @(
    "poshgit"
)

$winget_pkgs = @(
    "Microsoft.PowerShell.Preview",
    "gerardog.gsudo"
)

$files = @{
    "profile.ps1" = $PROFILE.AllUsersAllHosts;
}
