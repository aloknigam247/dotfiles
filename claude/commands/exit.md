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
8. **Permissions** — If you were repeatedly prompted to approve safe, read-only, or idempotent commands, suggest adding them as `allowed-tools` in the relevant skill's SKILL.md frontmatter (scoped to that skill). Only suggest `settings.json` or `settings.local.json` permissions for commands not tied to any specific skill.

## Phase 3: Present and Apply

Present your findings ranked by reuse value (highest first). Use AskUserQuestion to let the user pick which categories to update (multi-select). Then apply only the selected updates. After updating (or confirming nothing to update), say goodbye.

## Rules
- **Prioritize creation patterns over gotchas** — "how to create X" saves 30 min; "Y has a bug" saves 5 min
- Only capture knowledge that saves time on future reuse — skip one-off or obvious things
- Keep suggestions minimal: one line per insight, no duplication of existing entries
- Suggest updates at end of task, don't interrupt workflow
- Never bloat files — if an entry becomes stale or redundant, suggest removing it
- If nothing worth saving, say so
- **Generalize, don't copy**: Capture abstract patterns and steps, not session-specific examples. Write knowledge as reusable instructions that apply to any similar future task, not as a transcript of what was done in the current session
- **Prioritize new patterns over gotchas**: When a session establishes a new creation pattern (e.g., "how to create a strategy", "how to add a new API endpoint"), that is the highest-value knowledge to capture — more than bugs or one-off fixes
- **Prioritize skills and commands**: Actively look for repeatable workflows or multi-step patterns from the session that could become slash commands or auto-triggered skills. Don't dismiss categories 3–6 without concrete reasoning.
- **Reusable scripts**: If any scripts were created during the session, evaluate whether they are general-purpose (not session-specific). Suggest saving useful ones to a shared scripts location (e.g., dotfiles or a scripts folder) so they can be reused later.
- **Reduce permission friction**: When a skill or command triggers repeated permission prompts for safe, read-only, or idempotent commands (e.g., git read ops, CLI queries), suggest adding those as `allowed-tools` in the skill's SKILL.md frontmatter so the user doesn't have to approve them every time.
- **Prefer CLAUDE.local.md**: When both `CLAUDE.md` and `CLAUDE.local.md` exist in a project, write updates to `CLAUDE.local.md` (not checked in) instead of `CLAUDE.md` (checked in) — unless the change is meant to be shared with the team.
