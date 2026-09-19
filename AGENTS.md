## Code Style

- Use 1TBS (One True Brace Style) for all languages: opening brace on the same line, `else` on the same line as the closing brace
  ```
  if () {
  } else {
  }
  ```

## Naming conventions

Authoritative rules live in `AI/copilot-instructions.md` (Nomenclature). In short:

- Files and directories: lowercase `snake_case`.
- Git branches: lowercase `kebab-case`.
- Never distinguish two paths or branches only by capitalization.

Preserve verbatim (do not snake-case): tool-/language-required literal names (`README.md`, `AGENTS.md`,
`LICENSE`, `SKILL.md`, `setup.ps1`), PowerShell module directories and their `.psm1`/`.psd1`, C#
class-per-file sources, vendored/upstream assets at canonical names (fonts, `git-prompt.sh`,
`zsh-autosuggestions`, `lazy-lock.json`, `en.utf-8.add`), and names a tool loads by an exact
identifier (`AI/`, Copilot `copilot-instructions.md`/`mcp-config.json`/skill and extension directories,
git hooks like `commit-msg`, and theme files keyed by a shared identifier such as the `DELTA_FEATURES`
glow themes).

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
