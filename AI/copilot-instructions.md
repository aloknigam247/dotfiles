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

* Hard-wrap at **100 characters** per line (not 80) as the default for everything you write or edit. Do not re-flow fenced code blocks, tables, long URLs, or lines the surrounding file deliberately keeps unwrapped.
* When adding or editing items in ordered lists, enums, switch cases, XML elements, dictionary entries, or similar sequences where order doesn't affect behavior, maintain **alphabetical order**. This applies to any collection where reordering has no semantic impact (e.g., using directives, property declarations, configuration entries).
* When adding new fields/properties to an existing file, **do not reorder existing fields** — keep them in their original order. Add each new field in its correct alphabetical position **interspersed** among the existing entries when doing so does not break semantic ordering (e.g., the existing entries are already alphabetical and the surrounding code has no order dependency). If the existing entries are not in a clean alphabetical order, or inserting in place would require moving a pre-existing entry, add the new field(s) as a contiguous alphabetical block instead. Never move a pre-existing entry. This keeps diffs minimal while preserving order where it's cheap to do so.
* **Do not use `<c>` or `<code>` tags in C# XML doc comments.** Reference identifiers, literals (`null`, `true`, `false`), and method names as plain text — no inline-code markup. (Use `<see cref="..."/>` only when an actual cross-reference is needed.)

## Code comments

Comment sparingly and only to aid future readers of the code itself. A comment must earn its place by
explaining something the code cannot express on its own.

* Explain **why**, not **what** — only when the reasoning is non-obvious from the code.
* Keep comments minimal, factual, and self-contained. Do not add narrative or background.
* Do NOT include transient or external context in code/config comments:
  * no issue/PR/ticket numbers, links, or "see #NN"
  * no changelog, history, migration notes, or "previously/now" framing
  * no time/effort estimates, cost figures, or benchmarks stated as prose
  * no restating of docs the reader can read themselves (e.g. how a tool's option works)
  * no author names, dates, or TODOs without an owner
* Prefer zero comments over a comment that merely restates the adjacent code.
* Put rationale, history, and cross-references in the commit message or PR description — not in the
  source. Those channels carry context without biasing every future reader of the file.

## Git

* Always use **conventional commit** message style: `<type>: <description>`. Common types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`, `style`, `build`.
* Use the same **conventional commit** format for **PR titles**: `<type>: <description>`, using the same set of types.

## Azure DevOps
When working with Azure DevOps CLI (az boards, az repos), always include --project parameter and URL-encode spaces with %20 in tags and queries.

## Workflow

* Default to discussion. When I ask a how/why/what/should question, answer in words and lay
  out options — do not install packages, run commands, write, or edit files until I explicitly
  ask for a plan or say "implement". Treat design questions as read-only.
* Read-only investigation to answer a question is fine (view/grep/glob). The line is mutating
  or installing — no package installs, no scripts that change state, no file writes — without
  an explicit go-ahead.

## Scope

* Do the least that fully satisfies the ask, and no more. Prefer the smallest, simplest change;
  reuse what the platform or existing tools already provide instead of reimplementing it; do not
  add parameters, abstractions, or handling for cases that were not requested.
* If solving the task seems to require going beyond its stated scope — touching unrelated code,
  adding new capabilities, or changing behavior nobody asked for — stop and ask me before
  expanding scope, rather than deciding unilaterally.
