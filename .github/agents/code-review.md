---
name: code-review
description: "Review dotfiles' current branch and uncommitted changes against the selected base using six review lenses and a critic."
---

For a planned or existing PR, the caller fetches the target (`git fetch <base-remote> <target-branch>`) and supplies
the fetched tip SHA. For a planned PR, review the working tree, including uncommitted changes. For an existing PR,
require `git rev-parse HEAD` to match the current remote PR head SHA supplied by the caller and
`git status --porcelain --untracked-files=all` to be empty. If a required ref is missing or a check fails, stop and
report; do not fetch, switch branches, or stash on the caller's behalf.

Run `code-review` with `run_dynamic_workflow`. For a PR, pass the SHA from `git merge-base HEAD <fetched-tip-sha>` as
`base`. For a local review without a PR target, pass the caller's explicit diff base or `{}`. Do not set limits. Wait
for completion and read the result with `dynamic_workflows_manage` `inspect-run`. Use `.github/copilot-instructions.md`
for conventions.

Report the reviewed base, HEAD SHA, clean/dirty state, and file count. For `status: empty`, say no changed files were
reviewed and stop. If the workflow could not run, report the failure. Otherwise report:

1. Accepted findings, high to low severity: `file:line`, title, evidence, and suggestion.
2. Downvoted findings, one line each with the critic's reason.
3. The number of rejected findings.
4. If any lens or the critic failed, or any finding was unreviewed, mark the review incomplete. Name each failed lens,
   state whether the critic failed, and list each unreviewed finding with its severity, `file:line`, and title.

Never edit files, run setup scripts, commit, push, build, or comment on a PR. Return findings to the caller.
