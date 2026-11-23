# Neovim navigation

## Startup

[setup.ps1](setup.ps1) maps `init.vim` to the Neovim config root and `init.lua` to `lua/init.lua` beneath it;
[setup](setup) supplies the Bash-side mappings. Follow these files for destinations and prerequisites.

[init.vim](init.vim) sets editor options, GUI settings, and Vimscript autocmds, then calls `require("init")`.
[init.lua](init.lua) defines shared helpers and configuration, bootstraps lazy.nvim, collects `addPlugin` specs,
and ends with `require("lazy").setup(plugins, lazy_config)`. It is not a separate top-level startup alternative.

## Configuration lookup

Plugin configuration is grouped inside `init.lua`, not split into repository `lua/plugins` modules.
Search the named section or plugin repository string before searching the whole checkout.

| Area | Location |
| --- | --- |
| Commands and shared mappings | `Commands` and `Mappings` sections in `init.lua`. |
| Completion | `Completion` section in `init.lua`. |
| Debugging | `Debugger` section in `init.lua`. |
| Editor and GUI options | `init.vim`; GUI usage is linked from [README.md](README.md#gui-settings). |
| Formatting | `Formatting` section in `init.lua`. |
| Language servers | `LSP` section in `init.lua`, including Mason and `vim.lsp.config`. |
| Markdown preview | [README workflow](README.md#markdown-preview). |
| Plugin loading | `addPlugin`, `lazy_config`, and the final lazy.nvim setup in `init.lua`. |
| Queries | [queries](queries/), grouped by Treesitter language. |
| Snippets | [snippets](snippets/), including [markdown.json](snippets/markdown.json). |
| Spelling | [en.utf-8.add](en.utf-8.add). |
| UI and themes | `Colorscheme`, `Status Column`, `Status Line`, `Tab Line`, `UI`, and `Winbar` sections in `init.lua`. |

## Working on configuration

Add or change a plugin's `addPlugin` block in its existing feature section. Follow its repository identifier to
plugin implementation; `require(...)` calls here do not imply a matching source module in this repository.
Restart Neovim to check configuration changes: `lazy_config.change_detection` disables automatic reload detection.

For isolated plugin behavior checks, see [test_harness.md](test_harness.md). It describes a development harness,
not an existing test suite. Full startup can clone lazy.nvim and load configured plugins.
