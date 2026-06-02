## User

* Address the user as **Alok** when needed.

## Environment

The user's environment is **Windows with PowerShell 7**. Always use PowerShell syntax (not bash/sh) for shell commands, scripts, and status lines. Use `pwsh` not `bash`.

* Prefer double quotes over single quotes
* Do not add over-engineered solutions — only implement what is directly needed and will be used
* When accuracy matters (calculations, data processing, file manipulation, bulk operations), prefer writing a script (PowerShell or Python) over doing it inline or mentally. Scripts are verifiable, rerunnable, and less error-prone.
* When a PowerShell script outputs Nerd Font icons through pipes, set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` at the top — otherwise icons render as missing glyphs.
* Always use `pwsh` instead of `powershell` when invoking PowerShell (e.g., `pwsh -NoProfile -File script.ps1`).
* When creating temp files (e.g., in skills or commands), use a GUID in the filename to avoid collisions across concurrent sessions. Generate via `pwsh -c "[guid]::NewGuid().ToString()"`.
* `using module` is required to expose PowerShell classes from `.psm1` files — `Import-Module` only exposes functions. `using module` must be the first statement in the script and caches classes at parse time (requires terminal restart on module changes).
* When running PowerShell from the Bash tool, `$` variables are stripped by bash. Always write a `.ps1` file first and invoke with `pwsh -NoProfile -ExecutionPolicy Bypass -File script.ps1` instead of inline `-Command` with `$` variables.
* **Never predict or mentally compute math results.** Always use the `mcp__native_tools__calculator` tool for any calculation — arithmetic, unit conversions, percentages, etc. Trust the tool's output, not mental math.
* Prefer `sed` over PowerShell string replacement for in-place file text replacements.
* When inserting Nerd Font glyphs (or any private-use Unicode characters) into source files, prefer PowerShell unicode escapes (e.g., `` "`u{E0B6}" ``) over pasting literal glyphs. The Edit tool can fail to match strings containing private-use codepoints, so escapes make edits reliable.

## Code Style

* When adding or editing items in ordered lists, enums, switch cases, XML elements, dictionary entries, or similar sequences where order doesn't affect behavior, maintain **alphabetical order**. This applies to any collection where reordering has no semantic impact (e.g., using directives, property declarations, configuration entries).
* When adding new fields/properties to an existing file, **do not reorder existing fields** — keep them in their original order. Add each new field in its correct alphabetical position **interspersed** among the existing entries when doing so does not break semantic ordering (e.g., the existing entries are already alphabetical and the surrounding code has no order dependency). If the existing entries are not in a clean alphabetical order, or inserting in place would require moving a pre-existing entry, add the new field(s) as a contiguous alphabetical block instead. Never move a pre-existing entry. This keeps diffs minimal while preserving order where it's cheap to do so.
* **Do not use `<c>` or `<code>` tags in C# XML doc comments.** Reference identifiers, literals (`null`, `true`, `false`), and method names as plain text — no inline-code markup. (Use `<see cref="..."/>` only when an actual cross-reference is needed.)

## Git

* Always use **conventional commit** message style: `<type>: <description>`. Common types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`, `style`, `build`.

## Azure DevOps
When working with Azure DevOps CLI (az boards, az repos), always include --project parameter and URL-encode spaces with %20 in tags and queries.
