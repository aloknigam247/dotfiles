#Requires -RunAsAdministrator

param(
     [switch]$update = $false,
     [string[]]$install
     )

# Variables
$SCOOP_DIR = "D:\Scoop"

function DrawMenu {
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
        if ($null -ne $menuItems[$i]) {
            $item = $menuItems[$i]
            if ($Multiselect) {
                if ($selection -contains $i) {
                    $item = ' ' + $item
                } else {
                    $item = ' ' + $item
                }
            }
            if ($i -eq $menuPosition) {
                Write-Host "> $($item)" -ForegroundColor Green
            } else {
                Write-Host "  $($item)"
            }
        }
    }
}

function Toggle-Selection {
    param ($pos, [array]$selection)
        if ($selection -contains $pos) {
            $result = $selection | Where-Object {$_ -ne $pos}
        } else {
            $selection += $pos
                $result = $selection
        }
    $result
}

function Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
    $vkeycode = 0
    $pos = 0
    $selection = @()
    if ($menuItems.Length -gt 0) {
        try {
            [console]::CursorVisible=$false #prevents cursor flickering
            DrawMenu $menuItems $pos $Multiselect $selection
            while ($vkeycode -ne 13 -and $vkeycode -ne 27) {
                $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
                $vkeycode = $press.virtualkeycode
                if ($vkeycode -eq 38) { $pos-- }
                if ($vkeycode -eq 40) { $pos++ }
                if ($vkeycode -eq 36) { $pos = 0 }
                if ($vkeycode -eq 35) { $pos = $menuItems.length - 1 }
                if ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
                if ($pos -lt 0) { $pos = 0 }
                if ($vkeycode -eq 27) { $pos = $null }
                if ($pos -ge $menuItems.length) { $pos = $menuItems.length -1 }
                if ($vkeycode -ne 27) {
                    $startPos = [System.Console]::CursorTop - $menuItems.Length
                    [System.Console]::SetCursorPosition(0, $startPos)
                    DrawMenu $menuItems $pos $Multiselect $selection
                }
            }
        }
        finally {
            [System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
            [console]::CursorVisible = $true
        }
    }
    else {
        $pos = $null
    }

    if ($ReturnIndex -eq $false -and $null -ne $pos)
    {
        if ($Multiselect){
            return $menuItems[$selection]
        }
        else {
            return $menuItems[$pos]
        }
    }
    else
    {
        if ($Multiselect){
            return $selection
        }
        else {
            return $pos
        }
    }
}

$script:scoop_installed = ""
function installScoop {
    param(
        [switch]$update
    )
    Get-Command scoop *>&1 | Out-Null
    if ($? -eq $false) {
        writeLog INFO "Scoop not installed. Installing"
        Invoke-RestMethod get.scoop.sh -outfile "$env:TEMP\install.ps1"
        if (Test-Path "D:\") {
            & $env:TEMP\install.ps1 -RunAsAdmin -ScoopDir $SCOOP_DIR
            New-Item -ItemType SymbolicLink -Path ~\scoop -Target D:\Scoop
        } else {
            & $env:TEMP\install.ps1 -RunAsAdmin
        }
        Remove-Item $env:TEMP\install.ps1
        scoop bucket add extras
        scoop bucket add versions
        writeLog INFO "Scoop installed"
    }
    if ($update){
        scoop update
        writeLog INFO "Scoop updated"
    }

    $installed = scoop list | ForEach-Object { $_.Name }
    if ($null -eq $installed) {
        $script:scoop_installed = ""
    } else {
        $script:scoop_installed = $installed
    }
}

function pipInstall {
    param (
        [string[]]$pkgs,
        [switch]$update
    )

    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        pip show $pkg *>&1 | Out-Null
        $installed = $?

        if ($installed -eq $true -and $update) {
            # update package
            writeLog UPDATE "Updating pip package: $pkg"
            pip install --upgrade $pkg
        }
        elseif ($installed -eq $false -and -not $update) {
            # install package
            writeLog UPDATE "Installing pip package: $pkg"
            pip install $pkg
        }
    }
}

function pipxInstall {
    param (
        [string[]]$pkgs,
        [switch]$update
    )

    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        pip show $pkg *>&1 | Out-Null
        $installed = $?

        if ($installed -eq $true -and $update) {
            # update package
            writeLog UPDATE "Updating pipx package: $pkg"
            pipx upgrade $pkg
        }
        elseif ($installed -eq $false -and -not $update) {
            # install package
            writeLog UPDATE "Installing pipx package: $pkg"
            pipx install $pkg
        }
    }
}

function scoopInstall {
    param(
        [string[]]$pkgs,
        [switch]$update
    )

    if ($script:scoop_installed.Length -eq 0) {
        if ($update) {
            installScoop -update
        } else {
            installScoop
        }
    }

    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        $installed = $script:scoop_installed.Contains($pkg)

        if ($installed -eq $true -and $update) {
            # update package
            writeLog UPDATE "Updating scoop package: $pkg"
            scoop update -s $pkg
        }
        elseif ($installed -eq $false -and -not $update) {
            # install package
            writeLog UPDATE "Installing scoop package: $pkg"
            scoop install --no-update-scoop -s $pkg
        }
    }
}

function wingetInstall {
    param(
        [string[]]$pkgs,
        [switch]$update
    )
    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        $status = winget list -e --id $pkg

        if ($status.Contains("No installed package found matching input criteria.")) {
            $installed = $false
        } else {
            $installed = $true
        }

        if ($installed -eq $true -and $update) {
            # update package
            writeLog UPDATE "Updating winget package: $pkg"
            winget upgrade -e --id $pkg
        }
        elseif ($installed -eq $false -and -not $update) {
            # install package
            writeLog UPDATE "Installing winget package: $pkg"
            winget install -e --id $pkg
        }
    }
}

function linkConfigs {
    param(
        [hashtable]$files
    )
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
            }
            else {
                Write-Output "backup $dest --> ${dest}.orig"
                Move-Item -Force -Path $dest -Destination "${dest}.orig"
                Write-Output "Linking $src --> $dest"
                New-Item -ItemType SymbolicLink -Path $dest -Target $src
            }
        }
        else {
            Write-Output "Linking $src --> $dest"
            New-Item -ItemType SymbolicLink -Path $dest -Target $src
        }
    }
}

function copyOrUpdateConfigs {
    param(
        [hashtable]$files,
        [switch]$update
    )
    foreach ($key in $files.keys) {
        $src = "$cwd\$key"
        $dest = $files[$key]
        $dir = Split-Path -Parent $dest
        if ($update) {
            if (Test-Path $dest) {
                $srcFile = Get-Item $src
                $destFile = Get-Item $dest
                if ($srcFile.LastWriteTime -gt $destFile.LastWriteTime) {
                    Write-Output "Copying $src --> $dest"
                    Copy-Item $src $dest
                } elseif ($srcFile.LastWriteTime -lt $destFile.LastWriteTime) {
                    Write-Output "Copying $dest --> $src"
                    Copy-Item $dest $src
                }
            }
        } else {
            if (-not (Test-Path $dir)) {
                mkdir $dir
            }
            if (Test-Path $dest) {
                if(Compare-Object (Get-Content $src) (Get-Content $dest)) {
                    Write-Output "backup $dest --> ${dest}.orig"
                    Move-Item -Force -Path $dest -Destination "${dest}.orig"
                    Write-Output "Copying $src --> $dest"
                    Copy-Item -Path $src -Destination $dest
                } else {
                    Write-Verbose "$src already exists" -verbose
                }
            }
            else {
                Write-Output "Copying $src --> $dest"
                Copy-Item -Path $src -Destination $dest
            }
        }

    }
}

function writeLog {
    param(
        [ValidateSet('INFO', 'ERROR', 'UPDATE')]
        [Parameter(Mandatory = $true)]
        [string]$type,
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    $color_map = @{
        "INFO" = "Blue";
        "ERROR" = "Red";
        "UPDATE" = "Yellow"
    }

    $color = $color_map[$type]

    Write-Host -ForegroundColor White -BackgroundColor $color -NoNewline " $type "
    Write-Host -ForegroundColor $color " $message"
}

$all_pkgs = Get-ChildItem -Recurse -Filter "setup.ps1" | ForEach-Object { $_.Directory.BaseName }

if ($update) {
    writeLog INFO "Updating all installed packages"
    $pkg_list = $all_pkgs
}
elseif ($install) {
    writeLog INFO "Installing $install"
    $pkg_list = $install
    
} else {
    Write-Output "Package List: (space to select, enter to install)"
    $pkg_list = Menu $all_pkgs -Multiselect
}

$root = Get-Location
foreach ($pkg in $pkg_list) {
    writeLog INFO "Package: $pkg"

    Set-Location $pkg
    $cwd = Get-Location

    if (Test-Path setup.ps1) {
        $pip_pkgs = @()
        $pipx_pkgs = @()
        $scoop_pkgs = @()
        $winget_pkgs = @()
        $files = @{}
        $files_copy = @{}

        . .\setup.ps1

        if ($update) {
            pipInstall -update $pip_pkgs
            pipxInstall -update $pipx_pkgs
            scoopInstall -update $scoop_pkgs
            wingetInstall -update $winget_pkgs
            copyOrUpdateConfigs -update $files_copy
        } else {
            pipInstall $pip_pkgs
            pipxInstall $pipx_pkgs
            scoopInstall $scoop_pkgs
            wingetInstall $winget_pkgs

            writeLog INFO "Installing Configs"
            linkConfigs $files
            copyOrUpdateConfigs $files_copy
        }
    } else {
        writeLog ERROR "No setup.ps1 found for $pkg"
    }
    Set-Location $root
}
