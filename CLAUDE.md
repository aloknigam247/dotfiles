## Project Structure

- Each package has a directory with a `setup.ps1` that declares variables (`$scoop_pkgs`, `$winget_pkgs`, `$pip_pkgs`, `$pipx_pkgs`, `$psgallery_pkgs`, `$files`, `$files_copy`)
- `autosetup.ps1` dot-sources each package's `setup.ps1` and runs the corresponding install functions

## Adding a New Package Manager to autosetup.ps1

1. Create a `<name>Install` function with params `[string[]]$pkgs` and `[switch]$update` — follow the existing pattern (check installed, install or update)
2. Add `$<name>_pkgs = @()` to the variable init block (around line 370+)
3. Wire `<name>Install -update $<name>_pkgs` into the update branch
4. Wire `<name>Install $<name>_pkgs` into the install branch
