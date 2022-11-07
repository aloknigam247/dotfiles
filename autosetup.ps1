#TODO: install choco function
#TODO: check for admin role
#TODO: winget first install Y error
#TODO: install fonts

function DrawMenu {
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
        if ($menuItems[$i] -ne $null) {
            $item = $menuItems[$i]
            if ($Multiselect) {
                if ($selection -contains $i) {
                    $item = ' ' + $item
                } else {
                    $item = ' ' + $item
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
            $result = $selection | where {$_ -ne $pos}
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
                if ($vkeycode -eq 38 -or $press.Character -eq 'k') {$pos--}
                if ($vkeycode -eq 40 -or $press.Character -eq 'j') {$pos++}
                if ($vkeycode -eq 36) { $pos = 0 }
                if ($vkeycode -eq 35) { $pos = $menuItems.length - 1 }
                if ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
                if ($pos -lt 0) {$pos = 0}
                if ($vkeycode -eq 27) {$pos = $null }
                if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
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

    if ($ReturnIndex -eq $false -and $pos -ne $null)
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

$script:scoop = $false
function ensure_scoop {
    Get-Command scoop 2>&1
    if ($? -eq $false) {
        echo "Scoop not insalled"
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        scoop bucket add extras
    }
    echo "Scoop insalled"
    $script:scoop = $true
}

function scoop_install {
    echo "scoop install"
    $script:scoop
    if ($script:scoop -eq $false) {
        ensure_scoop
    }
    $pkgs = $args[0]
    if ($pkgs.Length -eq 0) {
        return
    }

    foreach ($pkg in $pkgs) {
        scoop which $pkg
        $status = $?
        if ($status -eq $true) {
            Write-Verbose "Package $pkg already installed" -verbose
        } else {
            scoop install --no-update-scoop $pkg
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

$app_list = @("neovim", "powershell", "win_pkgs", "windows_terminal")
Write-Output "Application List: (space to select, enter to install)"
$app_install = Menu $app_list -Multiselect

$root = Get-Location
foreach ($app in $app_install) {
    Write-Output "`nInstalling: $app"
    Set-Location $app
    $cwd = Get-Location
    if (Test-Path setup.ps1) {
        # reset supported tags
        $choco_pkgs = @()
        $scoop_pkgs = @()
        $winget_pkgs = @()
        $files = @{}

        . .\setup.ps1

        Write-Output "Installing Packages"
        choco_install $choco_pkgs
        scoop_install $scoop_pkgs
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
