$term_installed = Get-AppxPackage -Name "Microsoft.WindowsTerminal"

if ($null -eq $term_installed) {
    $winget_pkgs = @(
        "Microsoft.WindowsTerminal.Preview" # FIX: use non preview version now
    )

    $files = @{
        "settings.json" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json";
    }
} else {
    $files = @{
        "settings.json" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
    }
}
