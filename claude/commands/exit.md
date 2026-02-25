Review this session and identify reusable knowledge. For each category below, check if there is anything worth saving. Present your findings and ask the user which ones they want to update:

1. **Project CLAUDE.md** — Project-specific conventions, patterns, build commands, file structure, gotchas
2. **User CLAUDE.md** (`~/.claude/CLAUDE.md`) — Cross-project preferences, environment setup, workflow habits
3. **Project commands** (`.claude/commands/`) — User-invoked slash commands specific to this project
4. **User commands** (`~/.claude/commands/`) — User-invoked slash commands across all projects
5. **Project skills** (`.claude/skills/<name>/SKILL.md`) — Auto-triggered behaviors specific to this project
6. **User skills** (`~/.claude/skills/<name>/SKILL.md`) — Auto-triggered behaviors across all projects
7. **Auto memory** (`~/.claude/projects/.../memory/`) — Reusable insights, patterns, debugging notes

Rules:
- Only suggest knowledge that saves time on future reuse — skip one-off or obvious things
- Keep suggestions minimal: one line per insight, no duplication of existing entries
- If an existing entry is stale or redundant, suggest removing it
- If nothing worth saving, say so

Use AskUserQuestion to let the user pick which categories to update (multi-select). Then apply only the selected updates. After updating (or confirming nothing to update), say goodbye.
