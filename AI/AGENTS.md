# AI navigation

## File lookup

| Path | Purpose |
| --- | --- |
| [agents](agents/) | Personal agent definitions; use [catppuccin.agent.md](agents/catppuccin.agent.md) as a format example. |
| [copilot-instructions.md](copilot-instructions.md) | Setup-linked user-global instructions. |
| [mcp-config.json](mcp-config.json) | MCP server launch configuration for [native-tools](../mcp/server.py). |
| [settings.json](settings.json) | Copilot user settings deployed as a copy, not a symlink. |
| [setup.ps1](setup.ps1) | Package requirements and authoritative user-profile deployment destinations. |
| [skills](skills/) | Skill entrypoints and their supporting reference files and scripts. |

## Adding definitions

- Agent: add `agents/<name>.agent.md`, following the linked example's YAML frontmatter and Markdown body.
- Skill: add `skills/<name>/SKILL.md` with `description` and `name` frontmatter, then the task instructions.
  [triage/SKILL.md](skills/triage/SKILL.md) is a format example; keep supporting files inside the skill directory
  and link them from its entrypoint.

The agent and skill directories are linked as directories by `setup.ps1`; additions inside them need no new
per-file deployment mapping. For installation and update behavior, follow the
[root install flow](../AGENTS.md#install-and-link-flow) rather than running this declaration file alone.
