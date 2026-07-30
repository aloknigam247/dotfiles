BUG(git): .gitconfig is overriden by MDB and should be ignored there
FEAT(ai): instruction to segregate which diagram provider to use for which case. mermaid, draw.io, d2, plotly
FEAT(autosetup): read all requirements once and then install them in groups or parallel and merge duplicates
FEAT(cmdline): don't save prompts from copilot and file line number for nvim
FEAT(cmdline): make something which can generate cmdline using copilot and replace in the commandline
FEAT(completer): completions for copilot command
FEAT(copilot): configure copilot statusline
FEAT(copilot): for markdown powershell codeblock should be ps1
FEAT(copilot): git pull or push indicator in statusline
FEAT(copilot): mapping to delete word backword
FEAT(edge): create auto theme switch edge with catppuccin colors
FEAT(mcp): persistant terminal
FEAT(native tools): The commands are run in a peristant terminal, which can be reused to avoid cs everytime
FEAT(ppt): see d2 diagrams are rendering and if cli can be used now
FEAT(pwsh): command line filter to remove commands optons like copilot prompts, git commit message, vim line number
FEAT(security): Scan all installations for security related
FEAT(skill): create to draw diagrams which tells which diagram to draw from mermaid, drawio, d2
FEAT(skill): see plantuml diagrams are rendering if plantuml can be used
FIX(setup): git-completer not ported
PERF(mcp): use rust for MCP tools ?
REFACTOR: autosetup.ps1 needs a review on how to optimize and speedup installation/update
REFACTOR: configure copilot: list all things to move https://github.com/drvoss/everything-copilot-cli/blob/main/guides/migration-from-claude-code.md
REFACTOR: refactor D: drive
REFACTOR: remove packages which are not used, reduce load
TODO(copilot): Copilot cli extensions: https://htek.dev/articles/github-copilot-cli-extensions-complete-guide
TODO: add mdview and qvim to path
TODO: namping rules for file, directory, git branches.
