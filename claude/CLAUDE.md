## Environment

The user's environment is **Windows with PowerShell 7**. Always use PowerShell syntax (not bash/sh) for shell commands, scripts, and status lines. Use `pwsh` not `bash`.

* Prefer double quotes over single quotes
* Do not add over-engineered solutions — only implement what is directly needed and will be used
* When accuracy matters (calculations, data processing, file manipulation, bulk operations), prefer writing a script (PowerShell or Python) over doing it inline or mentally. Scripts are verifiable, rerunnable, and less error-prone.
* When a PowerShell script outputs Nerd Font icons through pipes, set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` at the top — otherwise icons render as missing glyphs.
