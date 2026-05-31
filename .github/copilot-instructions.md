## Code Style

- Use 1TBS (One True Brace Style) for all languages: opening brace on the same line, `else` on the same line as the closing brace
  ```
  if () {
  } else {
  }
  ```

## Project Structure

- Each package has a directory with a `setup.ps1` that declares variables (`$scoop_pkgs`, `$winget_pkgs`, `$pip_pkgs`, `$pipx_pkgs`, `$psgallery_pkgs`, `$files`, `$files_copy`)
- `autosetup.ps1` dot-sources each package's `setup.ps1` and runs the corresponding install functions

## Adding a New Package Manager to autosetup.ps1

1. Create a `<name>Install` function with params `[string[]]$pkgs` and `[switch]$update` — follow the existing pattern (check installed, install or update)
2. Add `$<name>_pkgs = @()` to the variable init block (around line 370+)
3. Wire `<name>Install -update $<name>_pkgs` into the update branch
4. Wire `<name>Install $<name>_pkgs` into the install branch

## Adding a PowerShell Module Package

To ship a `.psm1` from the repo so it loads via `Import-Module <Name>`:

1. Create `<package>/<ModuleName>/<ModuleName>.psm1` (PowerShell auto-discovers a single `.psm1` under a directory of the same name on `$env:PSModulePath` — no `.psd1` manifest needed).
2. In the package's `setup.ps1`, add to `$files`:
   ```powershell
   "<ModuleName>" = "$(Split-Path $(pwsh -Command 'echo $PROFILE.AllUsersAllHosts'))\Modules\<ModuleName>"
   ```
   `linkConfigs` symlinks the directory to `C:\Program Files\PowerShell\7\Modules\<ModuleName>`, which is on the default `$env:PSModulePath`.
3. In `powershell/profile.ps1`, add `Import-Module <ModuleName>` plus any registration calls.
4. Every helper function referenced by a script block passed to `Register-ArgumentCompleter` must be in `Export-ModuleMember` — module-private functions are not visible to those blocks even when defined inside the module.
