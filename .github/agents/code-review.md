---
name: code-review
description: "Review dotfiles' current branch and uncommitted changes against the default branch using six review lenses and a critic."
---

Run the `code-review` dynamic workflow with `run_dynamic_workflow`. Pass `{ "base": "<ref>" }` only when the user names
a base; otherwise pass `{}`. Do not set limits. Wait for its completion notification, then read the result with
`dynamic_workflows_manage` `inspect-run`. Reviewers use `.github/copilot-instructions.md` for repository conventions.

Report:

1. Accepted findings, high to low severity: `file:line`, title, evidence, and suggestion.
2. Downvoted findings, one line each with the critic's reason.
3. The number of rejected findings.
4. Failed lenses, unreviewed findings, or a failed critic, stated plainly.

Never edit files, run setup scripts, commit, push, build, or comment on a PR; the user decides what to fix.
