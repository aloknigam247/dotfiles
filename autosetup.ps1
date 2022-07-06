#TODO: install choco function

function choco_install {
    $pkgs = $args[0]
    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        $status = choco list --localonly $pkg
        if ($status[-1] -eq "1 packages installed.") {
            Write-Verbose "Package $pkg already installed" -verbose
        } else {
            choco install $pkg -y
        }
    }
}

function winget_install {
    $pkgs = $args[0]
    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        $status = winget list -e --id $pkg
        if ($status[2] -eq "No installed package found matching input criteria.") {
            winget install -e --id $pkg
        } else {
            Write-Verbose "Package $pkg already installed" -verbose
        }
    }
}

$app_list = @("nvim", "powershell", "win_pkgs", "windows_terminal")
$app_install = @()

Write-Output "Application List:"
for ($i=0; $i -lt $app_list.Count; $i++) {
    "    ${i}: {0}" -f $app_list[$i]
}

$opt = Read-Host "Space seperated index list of dotfiles to install (* for all)"

if ($opt -eq "*") {
    $app_install = $app_list
} else {
    foreach ($o in $opt.Split(" ")) {
        $app_install += $app_list[$o]
    }
}

$root = Get-Location
foreach ($app in $app_install) {
    Write-Output "`nInstalling: $app"
    Set-Location $app
    $cwd = Get-Location
    if (Test-Path setup.ps1) {
        # reset supported tags
        $choco_pkgs = @()
        $winget_pkgs = @()
        $files = @{}

        . .\setup.ps1

        Write-Output "Installing Packages"
        choco_install $choco_pkgs
        winget_install $winget_pkgs

        Write-Output "Installing Configs"
        foreach ($key in $files.keys) {
            $src = "$cwd\$key"
            $dest = $files[$key]
            $dir = Split-Path -Parent $dest
            if (-not (Test-Path $dir)) {
                mkdir $dir
            }
            if (Test-Path $dest) {
                $target = Get-Item $dest | Select-Object -ExpandProperty Target
                if ($target -eq $src) {
                    Write-Verbose "$src already linked" -verbose
                } else {
                    Write-Output "backup $dest --> ${dest}.orig"
                    Move-Item -Force -Path $dest -Destination "${dest}.orig"
                    Write-Output "Linking $src --> $dest"
                    New-Item -ItemType SymbolicLink -Path $dest -Target $src
                }
            } else {
                Write-Output "Linking $src --> $dest"
                New-Item -ItemType SymbolicLink -Path $dest -Target $src
            }
        }
    } else {
        Write-Output "No setup.ps1 found for $app"
    }
    Set-Location $root
}
