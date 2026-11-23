# dotfiles navigation

Repository conventions and package/module authoring rules live in
[.github/copilot-instructions.md](.github/copilot-instructions.md).

## Module lookup

| Module | Start here |
| --- | --- |
| `AI` | [Guide](AI/AGENTS.md): Copilot agents, skills, configuration, and deployment. |
| `arch` | [Arch icon](arch/arch_icon.png). |
| `bash` | [bashrc](bash/bashrc), [aliases](bash/aliases.bash), and [setup](bash/setup). |
| `bat` | Catppuccin syntax themes and their destinations in [setup.ps1](bat/setup.ps1). |
| `clangd` | Platform configs selected by [setup](clangd/setup) and [setup.ps1](clangd/setup.ps1). |
| `cptower` | [Guide](cptower/AGENTS.md): AHP service entrypoints and development. |
| `cptower_tests` | Test project linked from the [cptower guide](cptower/AGENTS.md#layout). |
| `fonts` | Font assets and installation in [setup](fonts/setup) and [setup.ps1](fonts/setup.ps1). |
| `gdb` | [gdbinit](gdb/gdbinit) and [setup](gdb/setup). |
| `git` | [Deployment](git/setup.ps1), [commitlint guide](git/commitlint.md), and [hook](git/hooks/commit-msg). |
| `glow` | [Latte](glow/catppuccin-latte.json) and [Mocha](glow/catppuccin-mocha.json) rendering themes. |
| `lazygit` | [config.yml](lazygit/config.yml), light/dark themes, and [setup.ps1](lazygit/setup.ps1). |
| `mcp` | [server.py](mcp/server.py) and [runner.ps1](mcp/runner.ps1); launch configuration in the [AI guide](AI/AGENTS.md). |
| `mdview` | [config.toml](mdview/config.toml) and [setup.ps1](mdview/setup.ps1); configuration, not app source. |
| `neovim` | [Guide](neovim/AGENTS.md): startup, plugin configuration, and editor workflow. |
| `powershell` | [Guide](powershell/AGENTS.md): profile load order and module lookup. |
| `powertoys` | Settings backup in [powertoys](powertoys/). |
| `shell` | Readline [inputrc](shell/inputrc) and [setup](shell/setup). |
| `tcsh` | [tcshrc](tcsh/tcshrc), including its Completions block, [precmd](tcsh/precmd), and [setup](tcsh/setup). |
| `tmux` | [tmux.conf](tmux/tmux.conf) and [setup](tmux/setup). |
| `ubuntu` | Apt package commands in [setup](ubuntu/setup). |
| `vim` | [vimrc](vim/vimrc), [gvimrc](vim/gvimrc), and [setup](vim/setup). |
| `vscode` | [Installation notes and reference links](vscode/README.md). |
| `win_pkgs` | Shared Windows tool packages in [setup.ps1](win_pkgs/setup.ps1). |
| `windows_terminal` | [settings.json](windows_terminal/settings.json) and [setup.ps1](windows_terminal/setup.ps1). |
| `zsh` | [zshrc](zsh/zshrc), [dircolors](zsh/dircolors), and [setup](zsh/setup). |

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
- [AI/setup.ps1](AI/setup.ps1): Copilot deployment declarations; see the [AI guide](AI/AGENTS.md).
- [mappings.md](mappings.md): Visual Studio and VS Code shortcut reference.
- [menu.sh](menu.sh): standalone Bash menu demo, not the menu used by either installer.
