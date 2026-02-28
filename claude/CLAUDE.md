## Environment

The user's environment is **Windows with PowerShell 7**. Always use PowerShell syntax (not bash/sh) for shell commands, scripts, and status lines. Use `pwsh` not `bash`.

* Prefer double quotes over single qoutes
* Do not add over-engineered solutions — only implement what is directly needed and will be used

## Knowledge Capture

While working, proactively identify reusable knowledge and suggest minimal updates to claude files:

- **Project CLAUDE.md**: Project-specific conventions, patterns, build commands, file structure, gotchas
- **User CLAUDE.md** (`~/.claude/CLAUDE.md`): Cross-project preferences, environment setup, workflow habits
- **Project commands** (`.claude/commands/`): User-invoked slash commands specific to a project
- **User commands** (`~/.claude/commands/`): User-invoked slash commands across all projects
- **Project skills** (`.claude/skills/<name>/SKILL.md`): Auto-triggered behaviors specific to a project (e.g., running tests, lint rules)
- **User skills** (`~/.claude/skills/<name>/SKILL.md`): Auto-triggered behaviors across all projects

**Rules**:
- Only capture knowledge that saves time on future reuse — skip one-off or obvious things
- Keep updates minimal: one line per insight, no duplication of existing entries
- Suggest updates at end of task, don't interrupt workflow
- Never bloat files — if an entry becomes stale or redundant, suggest removing it
- **Generalize, don't copy**: Capture abstract patterns and steps, not session-specific examples. Write knowledge as reusable instructions that apply to any similar future task, not as a transcript of what was done in the current session
