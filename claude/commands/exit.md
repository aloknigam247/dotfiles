Review this session and identify reusable knowledge.

## Phase 1: Deep Session Analysis

Before suggesting updates, perform a structured replay of the session:

1. **What was built?** List every new file, class, pattern, or workflow created in this session.
2. **What existing patterns were followed?** Identify which conventions/templates from the codebase were reused — these are already documented (or should be).
3. **What NEW patterns were established?** If we created something for the first time (new type of component, new workflow, new integration), that pattern is the highest-value knowledge to capture. Ask: "If someone needed to create another one of these, what steps would they follow?"
4. **What broke or surprised?** Gotchas, bugs, workarounds — but only if they'd trip someone up again.
5. **Diff against existing CLAUDE.md** — Read the project CLAUDE.md and check: what's already documented vs what's new from this session?

## Phase 2: Categorize Findings

Map each finding to the right category:

1. **Project CLAUDE.md** — Project-specific conventions, patterns, build commands, file structure, gotchas
2. **User CLAUDE.md** (`~/.claude/CLAUDE.md`) — Cross-project preferences, environment setup, workflow habits
3. **Project commands** (`.claude/commands/`) — User-invoked slash commands specific to this project
4. **User commands** (`~/.claude/commands/`) — User-invoked slash commands across all projects
5. **Project skills** (`.claude/skills/<name>/SKILL.md`) — Auto-triggered behaviors specific to this project
6. **User skills** (`~/.claude/skills/<name>/SKILL.md`) — Auto-triggered behaviors across all projects
7. **Auto memory** (`~/.claude/projects/.../memory/`) — Reusable insights, patterns, debugging notes
8. **Permissions** (`.claude/settings.json` → `permissions.allow`) — If you were repeatedly prompted to approve safe, read-only, or idempotent commands (linters, formatters, tests, git read ops, project scripts), suggest adding them as pre-allowed patterns. For permissions that cannot be set in settings.json (e.g., `--allowedTools`, `--disallowedTools`, `--permission-mode`, `--dangerously-skip-permissions`), suggest the CLI flag usage instead

## Phase 3: Present and Apply

Present your findings ranked by reuse value (highest first). Use AskUserQuestion to let the user pick which categories to update (multi-select). Then apply only the selected updates. After updating (or confirming nothing to update), say goodbye.

## Rules
- **Prioritize creation patterns over gotchas** — "how to create X" saves 30 min; "Y has a bug" saves 5 min
- Only suggest knowledge that saves time on future reuse — skip one-off or obvious things
- Keep suggestions minimal: one line per insight, no duplication of existing entries
- If an existing entry is stale or redundant, suggest removing it
- If nothing worth saving, say so
- **Prioritize skills and commands**: Actively look for repeatable workflows or multi-step patterns from the session that could become slash commands or auto-triggered skills. Don't dismiss categories 3–6 without concrete reasoning.
- **Reusable scripts**: If any scripts were created during the session, evaluate whether they are general-purpose (not session-specific). Suggest saving useful ones to a shared scripts location (e.g., dotfiles or a scripts folder) so they can be reused later.
