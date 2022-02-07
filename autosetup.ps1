$profile_path = $PROFILE.CurrentUserAllHosts
echo "Installing Powershell Profile at [$profile_path]"

if (Test-Path $profile_path) {
    Move-Item -Path $profile_path -Destination "$profile_path.orig"
}

$cwd = Get-Location
New-Item -ItemType SymbolicLink -Path $profile_path -Target "$cwd\powershell\profile.ps1"