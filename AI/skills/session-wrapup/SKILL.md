---
name: session-wrapup
description: Review the current session and capture reusable knowledge, instructions, and automation opportunities for future Copilot sessions.
---

# Session Wrapup

Use this skill when the user asks to wrap up a session, capture learnings, save memory, or preserve reusable instructions from the current conversation.

## Workflow

1. Review the full session and identify reusable knowledge:
   - User preferences and durable working style instructions
   - Repository-specific instructions or project conventions
   - Repeated workflows that should become a skill
   - Commands, scripts, or setup changes that should be preserved
   - Tooling assumptions, environment details, and local machine conventions
2. Categorize each finding by destination:
   - Repository instructions: `.github\copilot-instructions.md`
   - User instructions: `AI\copilot-instructions.md`
   - User skills: `AI\skills\<skill-name>\SKILL.md`
   - Setup links: `AI\setup.ps1`
   - Project automation: the relevant package or script in this repository
3. Present the findings to the user before making changes:
   - Show the proposed destination for each item
   - Call out anything that is Copilot-unsupported or needs a different implementation
   - Ask which items to apply when there are multiple reasonable choices
4. Apply only the approved changes.
5. Keep Claude files untouched unless the user explicitly asks to edit them.

## Guidelines

- Prefer adding Copilot files under `AI\` so `AI\setup.ps1` can link them to the correct local Copilot locations.
- Do not create or migrate Claude slash commands directly when Copilot has no equivalent command mechanism; convert reusable workflows to skills instead.
- Do not assume a Claude-specific tool, hook, setting, or path works in Copilot. Verify the Copilot equivalent and explain unsupported items.
- Preserve source-of-truth dotfiles in this repository instead of editing only files under the user profile.
