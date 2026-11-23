# dotfiles navigation

Repository conventions and package/module authoring rules live in
[.github/copilot-instructions.md](.github/copilot-instructions.md).

## Module lookup

| Module | Start here |
| --- | --- |
| `AI` | [Guide](AI/AGENTS.md): Copilot agents, skills, configuration, and deployment. |
| `clangd` | Platform configs selected by [setup](clangd/setup) and [setup.ps1](clangd/setup.ps1). |
| `cptower` | [Guide](cptower/AGENTS.md): AHP service entrypoints and development. |
| `cptower_tests` | Test project linked from the [cptower guide](cptower/AGENTS.md#layout). |
| `git` | [Deployment](git/setup.ps1), [commitlint guide](git/commitlint.md), and [hook](git/hooks/commit-msg). |
| `mcp` | [server.py](mcp/server.py) and [runner.ps1](mcp/runner.ps1); launch configuration in the [AI guide](AI/AGENTS.md). |
| `mdview` | [config.toml](mdview/config.toml) and [setup.ps1](mdview/setup.ps1); configuration, not app source. |
| `neovim` | [Guide](neovim/AGENTS.md): startup, plugin configuration, and editor workflow. |
| `powershell` | [Guide](powershell/AGENTS.md): profile startup and module lookup. |
| `tcsh` | [tcshrc](tcsh/tcshrc), including its Completions block, [precmd](tcsh/precmd), and [setup](tcsh/setup). |
| `win_pkgs` | Shared Windows tool packages in [setup.ps1](win_pkgs/setup.ps1). |

Other directories hold one tool's config; list the directory and read its `setup` or `setup.ps1`, if present, for
linked files and destinations.

## Install and link flow

Run installers only from the root of the checkout that should own the live config links, never a temporary worktree.
Read the selected module's setup first: these scripts change installed software and user configuration.

- [autosetup](autosetup) is the Bash installer. Its `app_list` selects modules; each module's `setup` supplies file
  links and shell commands. The installer backs up existing destinations, links files, then evaluates the commands.
- [autosetup.ps1](autosetup.ps1) requires elevation. It discovers `setup.ps1` modules, selects them with `-install`,
  the interactive menu, or `-update`, then collects their declarations. It deploys configurations and GitHub releases
  before dispatching the deduplicated package lists. Follow `linkConfigs`, `copyOrUpdateConfigs`, and `deployConfigs`
  for destination handling; update mode can copy newer user settings back into the repository.
  Selecting a module also runs `updateScoopAppPaths`, which rewrites `$scoop_app_paths` in
  [powershell/profile.ps1](powershell/profile.ps1).

## Shared entrypoints

- [.commitlint-scopes.json](.commitlint-scopes.json): repository scopes consumed by
  [git/commitlint.config.js](git/commitlint.config.js).
- [.gitmodules](.gitmodules): submodule paths and upstream URLs; see [README.md](README.md) for cloning.
- [mappings.md](mappings.md): Visual Studio and VS Code shortcut reference.
- [menu.sh](menu.sh): standalone Bash menu demo, not the menu used by either installer.
