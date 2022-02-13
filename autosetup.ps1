$app_list = @("nvim", "powershell", "windows_terminal")

Write-Output "Application List:"
for ($i=0; $i -lt $app_list.Count; $i++) {
    "    ${i}: {0}" -f $app_list[$i]
}

$opt = Read-Host "Space seperated index list of dotfiles to install"
foreach ($o in $opt.Split(" ")) {
    $app = $app_list[[int]$o]
    Write-Output "Installing: $app"
    Set-Location $app
    $cwd = Get-Location
    if (Test-Path setup.ps1) {
        . .\setup.ps1

        foreach ($key in $files.keys) {
            $src = "$cwd\$key"
            $dest = $files[$key]
            if (Test-Path $dest) {
                Write-Output "backup $dest --> ${dest}.orig"
                Move-Item -Force -Path $dest -Destination "${dest}.orig"
            }
            $dir = Split-Path -Parent $dest
            if (-not (Test-Path $dir)) {
                mkdir $dir
            }
            Write-Output "Linking $src --> $dest"
            New-Item -ItemType SymbolicLink -Path $dest -Target $src
        }
    } else {
        Write-Output "No setup.ps1 found for $app"
    }
    Set-Location -
}
