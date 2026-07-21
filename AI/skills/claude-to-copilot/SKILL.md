---
name: claude-to-copilot
description: Use when the user wants to migrate a repository from Claude Code to GitHub Copilot CLI — converting CLAUDE.md, .claude/agents, and .claude/skills into Copilot equivalents (AGENTS.md, .github/agents, .github/skills). Trigger phrases include "migrate from claude", "claude to copilot", "convert claude files", "migrate claude code", and "copilot migration".
---

# Claude Code → Copilot CLI Migration

Migrate a repository's Claude Code configuration to the equivalent GitHub Copilot CLI setup, flag anything Copilot does not support, and deliver the change as a pull request.

## Scope

Confirm with the user before starting if any of these are unclear:

1. Target is a Copilot-**only** repo (prefer `AGENTS.md`) or must keep working with both tools.
2. Whether to open a PR or just make local changes.
3. Whether to also migrate `.claude/skills` and `.claude/agents`, or only instruction files.

Do not delete Claude files until the user confirms this is a one-way migration.

## Mapping

| Claude Code | Copilot CLI | Notes |
|-------------|-------------|-------|
| Root `CLAUDE.md` | Root `AGENTS.md` | Primary project instructions. |
| `<module>/CLAUDE.md` | `<module>/AGENTS.md` | Nested `AGENTS.md` **auto-loads** when working on files in that directory — mirrors the per-module layout. |
| `.claude/agents/*.md` | `.github/agents/*.md` | Custom subagents. Fix frontmatter (see gaps). |
| `.claude/skills/<name>/SKILL.md` | `.github/skills/<name>/SKILL.md` | Skills. Reword `$ARGUMENTS`, move temp-file paths (see gaps). |
| `.claude/settings.local.json` | (drop) | Local Claude settings; remove from `.gitignore`. |
| `.claude/settings.json` | `.github/copilot` settings / discard | Review per setting; most have no Copilot equivalent. |

**`AGENTS.md` vs `.github/copilot-instructions.md`:** For a Copilot-only repo prefer `AGENTS.md` — it supports nested per-directory files that auto-load, matching Claude's `CLAUDE.md` layout. `copilot-instructions.md` is a single root file with no nesting. Use it only if the user specifically wants the GitHub-web-UI-recognized filename.

## Steps

### 1. Discover every Claude asset

```ps1
Get-ChildItem -Recurse -Force -Filter CLAUDE.md | Select-Object FullName
Get-ChildItem -Recurse -Force -Directory -Filter ".claude" | Select-Object FullName
```

Also grep for stray references:

```ps1
git grep -n -i "claude" -- ":!*.lock"
```

Enumerate `.claude/agents/`, `.claude/skills/`, `.claude/settings*.json`, and any `.gitignore` entries mentioning `.claude`.

### 2. Check for unsupported content (do this in parallel with conversion)

Review each Claude file for constructs Copilot handles differently — see the **Copilot support gaps** section. Collect a list of anything that has no clean Copilot equivalent and report it to the user before finalizing.

### 3. Convert files

- Copy each `CLAUDE.md` to `AGENTS.md` at the same path (root and every module).
- If the root file has a "module lookup" / index table, repoint paths from `<module>/CLAUDE.md` to `<module>/AGENTS.md`.
- Move `.claude/agents/*` → `.github/agents/*` and fix agent frontmatter.
- Move `.claude/skills/*` → `.github/skills/*` and adjust skill bodies.
- Preserve content verbatim otherwise; do not rewrite guidance the user relies on.

### 4. Remove Claude artifacts (after user confirms one-way)

- Delete all `CLAUDE.md` files and the entire `.claude/` directory.
- Update `.gitignore`: drop `.claude/...` entries; add any new temp-file names introduced by reworded skills.

### 5. Validate

- Confirm nested `AGENTS.md` files load (opening a file in a module should surface its instructions).
- Run the repo's own lint/format/type/test gates if the migration touched code or config (usually it does not).
- `git status` should show only intended additions/deletions/renames.

### 6. Ship

```ps1
git checkout -b chore/migrate-claude-to-copilot
git add -A
git commit -m "chore: migrate Claude config to Copilot"
git push -u origin chore/migrate-claude-to-copilot
gh pr create --base <default-branch> --fill
```

Use conventional-commit style. If the repo requires a co-author trailer, include it.

## Copilot support gaps (flag these)

These are the real differences to check for and resolve; report any you cannot resolve cleanly.

- **Skill arguments (`$ARGUMENTS`)** — Claude skills interpolate `$ARGUMENTS`/`$1` placeholders. Copilot skills do not substitute these the same way. Reword the skill so it reads the user's request from context instead of a literal `$ARGUMENTS` token.
- **Skill temp files** — Claude skills sometimes write temp files under the skill's own directory. In Copilot, write throwaway files to the **repo root** (or the session workspace) instead, and add their names to `.gitignore`. Use a GUID in temp filenames to avoid collisions across concurrent sessions.
- **Agent frontmatter** — Claude subagent frontmatter fields may not map 1:1. Copilot agent frontmatter expects `name` and `description` (and optional `tools`); drop or translate Claude-specific keys.
- **Settings** — `.claude/settings*.json` (permissions, hooks, MCP config) has no direct instruction-file equivalent; MCP servers are configured separately in Copilot. Review each setting rather than copying the file.
- **Slash commands / `.claude/commands`** — if present, Copilot has its own command model; these usually become skills or prompt files, not a direct copy.
- **Model-specific wording** — instructions that name "Claude" or Claude-only tools should be generalized or repointed to Copilot equivalents.

## Notes

- Copy first, delete last, so a failed conversion never loses the original.
- Keep the diff a pure move/rename where possible so reviewers can see content is unchanged.
- Nested `AGENTS.md` is the key advantage — never flatten per-module instructions into one root file.
