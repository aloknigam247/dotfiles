# configs
Config files for various applications

Clone using the submodule command:
```sh
git clone --recurse-submodules git@github.com:aloknigam247/dotfiles.git
```

OR

```sh
git clone --recurse-submodules https://github.com/aloknigam247/dotfiles.git
```

OR

```sh
gh repo clone https://github.com/aloknigam247/dotfiles.git -- --recurse-submodules
```

## PowerShell completion

Use Tab with `copilot`, `agency`, or `ai` for command/option suggestions, enum values, local `--agent` names,
and `--root` directories. `ai` follows the wrapper's repository routing; `agency copilot` and `agency cp` support
engine options. Native Agency subcommands complete only `--help` and `--root`.

`ai` reads the stored local `origin` URL, following `gitdir`/`commondir` pointers for worktrees. Routing never starts Git.
Global/system settings, includes, worktree-specific overrides, and URL rewrites are not resolved.

The shared registration in `powershell\profile.ps1` contains the catalogs; refresh them from `copilot.exe --help`
and `agency.exe copilot --help`. Agent identifiers come from local Markdown filenames in the user and repository
agent directories; see [custom agent configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration).
Unmatched values retain PowerShell's filename fallback. Agent discovery honors literal `--root`, not `-C` or `--add-dir`.

Run the isolated completion checks:

```ps1
pwsh -NoProfile -File .\powershell\test_ai_completion.ps1
```
