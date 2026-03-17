## Environment

The user's environment is **Windows with PowerShell 7**. Always use PowerShell syntax (not bash/sh) for shell commands, scripts, and status lines. Use `pwsh` not `bash`.

* Prefer double quotes over single quotes
* Do not add over-engineered solutions — only implement what is directly needed and will be used
* When accuracy matters (calculations, data processing, file manipulation, bulk operations), prefer writing a script (PowerShell or Python) over doing it inline or mentally. Scripts are verifiable, rerunnable, and less error-prone.
* When a PowerShell script outputs Nerd Font icons through pipes, set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` at the top — otherwise icons render as missing glyphs.
* When creating temp files (e.g., in skills or commands), use a GUID in the filename to avoid collisions across concurrent sessions. Generate via `powershell -c "[guid]::NewGuid().ToString()"`.
* `using module` is required to expose PowerShell classes from `.psm1` files — `Import-Module` only exposes functions. `using module` must be the first statement in the script and caches classes at parse time (requires terminal restart on module changes).
* When running PowerShell from the Bash tool, `$` variables are stripped by bash. Always write a `.ps1` file first and invoke with `powershell -NoProfile -ExecutionPolicy Bypass -File script.ps1` instead of inline `-Command` with `$` variables.

## Azure DevOps
When working with Azure DevOps CLI (az boards, az repos), always include --project parameter and URL-encode spaces with %20 in tags and queries.
