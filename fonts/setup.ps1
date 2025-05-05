$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
$installed_fonts = $fonts.Items() | Select-Object -Property Name | Out-String

if ($installed_fonts.Contains("JetBrainsMono Nerd Font") -eq $false) {
    Get-ChildItem .\fonts\ | ForEach-Object { $fonts.CopyHere($_.FullName) }
}