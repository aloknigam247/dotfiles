$winget_pkgs = @(
    "Microsoft.WindowsTerminal"
)

$files = @{
    # FIX: symlink does not work
    "settings.json" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
}