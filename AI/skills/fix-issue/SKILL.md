---
name: fix-issue
description: Use when the user wants to work on / fix / implement a GitHub issue — either a specific one by number or URL, or "pick an issue and fix it" with no issue named, in which case it selects one from the repo's open issues regardless of assignee. Pulls the issue (and its first open sub-issue, if any), reproduces the bug first when it is a bug, produces an implementation plan for the user to accept, implements it after acceptance, verifies the fix and hands the user steps to confirm it themselves, opens a PR linked to the issue, fixes PR build/CI failures, addresses and resolves every PR review comment, hands the PR back to the user to review and close, then after the merge syncs and rebuilds the default branch and cleans up the branch/worktree. Trigger phrases include "fix issue", "fix #123", "work on issue", "implement this issue", "pick up an issue", "start on #123", "address the PR comments".
---

# Fix Issue

Take an existing GitHub issue from "assigned" to "PR ready for review", the user accepts the plan
before any code is written, and the user accepts the fix before any PR is raised.

## Principles

- **One task at a time.** If the issue has sub-issues or a task list, work **exactly one** of them
  per run — the first one that is still open/unchecked. Never batch sub-tasks.
- **Never work on the default branch.** Every fix goes on a new `fix/<issue>-<slug>` branch, in the
  current checkout or in a dedicated worktree under `.worktree/` — the user chooses which.
- **Reproduce before you plan.** For bugs, a failing reproduction (preferably an automated failing
  test) must exist *before* the plan is drafted. No repro → no plan.
- **Plan before code.** Nothing is edited until the user accepts the plan via `ask_user`.
- **Verify before you ask.** Every acceptance criterion is checked against a real run *before* the
  user is asked to accept, and the user is handed concrete steps (with the exact artifact path) to
  confirm it themselves. Never ask someone to accept a change you have not exercised end to end.
- **No PR without acceptance.** The user must accept the implemented fix before `gh pr create`.
- **Green before handoff.** PR checks must be green (or the remaining failures proven pre-existing
  and unrelated) before asking the user to review.
- **Every review comment gets closed.** No PR is handed back while a review thread is unresolved —
  each comment is either fixed, or answered with reasoning and explicitly agreed as out of scope.
- **Finish at a clean, current checkout.** After a merge, sync the default branch, rebuild if the
  merge changed anything buildable, and confirm the result — the run is not done until the user's
  working checkout reflects the merged code.
- **Verify, don't assume.** Run the real test/build commands and paste real output. A claim is not
  proof.

## About plan mode

This skill implements its own planning phase:

- Research + plan drafting is delegated to a **`general-purpose`** subagent (fresh context).
- The draft is critiqued by the **`rubber-duck`** agent before the user sees it.
- The user gate is an explicit `ask_user` accept / edit / reject.

If the user hands over an **already-accepted plan** (e.g. from their own `/plan` run, or a previous
interrupted run of this skill), skip step 3 and use that plan — but first confirm via `ask_user` that
it is still current. Do not treat a vague "I know what needs doing" as an accepted plan.

## Input

An issue number (`123`, `#123`) or issue URL — **optional**.

If the user did **not** name an issue, pull one from the repo yourself. **Do not filter by assignee**
— any open issue is fair game, assigned or not:

```pwsh
gh issue list --state open --limit 30 `
  --json number,title,labels,assignees,updatedAt `
  --jq '.[] | {number,title,labels:[.labels[].name],assignee:(.assignees[0].login // "unassigned"),updatedAt}'
```

Rank the candidates and present the top few (number, title, labels, assignee) via `ask_user` so the
user picks one. Recommend a default using, in order:

1. Issues explicitly flagged as ready/priority by the repo's own labels.
2. Small, well-specified issues with a clear reproduction or acceptance criteria.
3. Oldest `updatedAt` among the remainder.

Mention the current assignee for the recommendation so the user can redirect if someone else is
already on it — but never exclude an issue just because it is assigned. If the repo has no open
issues, say so and stop.

If the user says "just pick one", take your top-ranked candidate, announce which issue you chose and
why, and continue.

## Steps

### 1. Pull the issue and select exactly one task

If no issue was given, first select one per **Input** above. Then fetch the full issue:

```pwsh
gh issue view <n> --json number,title,body,labels,state,url,assignees,comments
```

Read the `comments` too — decisions there often supersede the body.

Then resolve sub-tasks, in this order:

1. **Native sub-issues** (the `{owner}/{repo}` placeholders are substituted by `gh` from the current
   repo; the API-version header is required for this endpoint):
   ```pwsh
   gh api -H "X-GitHub-Api-Version: 2026-03-10" `
     "repos/{owner}/{repo}/issues/<n>/sub_issues" `
     --jq '[.[] | select(.state=="open")] | sort_by(.number) | (.[0] // empty) | {number,title,state}'
   ```
   **Empty output means there are no open sub-issues** (either none exist or all are closed) — not an
   error. A `404`/`410` means the repo or API version does not expose sub-issues — fall through to
   task-list checkboxes rather than treating it as "no sub-tasks".
2. **Task-list checkboxes** in the body (`- [ ]` / `- [x]`), if there are no native sub-issues.

Selection rule:

- No sub-tasks → the issue itself is the task.
- Sub-tasks exist → pick **exactly one**:
  - native sub-issues: the **open** one with the **lowest issue number** (the API returns them
    unordered/paginated, so "first" must mean lowest number, not response order);
  - task-list checkboxes: the **first unchecked `- [ ]`** in document order.

  That single sub-task is the entire scope of this run. State clearly in chat which sub-task was
  picked and that the rest are deferred to later runs. If the picked sub-task obviously depends on a
  later one, say so and confirm the choice with `ask_user` rather than silently re-ordering.
- All sub-tasks done → tell the user and stop. (To distinguish "no sub-tasks" from "all sub-tasks
  closed", re-run the call without the `select(.state=="open")` filter and check the total count.)

Record the **work issue number** (the sub-issue if one was picked, else the parent) — it is what the
PR links to.

**Check for an existing PR** before doing any work:

```pwsh
gh pr list --state open --search "<work-issue-number> in:body" --json number,title,url,headRefName
```

If a PR already targets this issue, report it and `ask_user` whether to (a) continue on that PR's
branch, (b) start fresh anyway, or (c) stop. Never open a duplicate PR silently.

### 2. Reproduce (bugs only)

If the issue is a bug (label `bug`, or the body describes broken/incorrect behavior), reproduce it
**before planning**:

1. Derive reproduction steps from the issue body/comments; ask via `ask_user` if they are ambiguous
   or environment-specific.
2. Reproduce in the smallest form that actually fails, in this preference order:
   - a **failing automated test** in the repo's existing test framework (best — it becomes the
     regression test),
   - a minimal script/command that demonstrates the wrong output,
   - a manual run with captured evidence (for visual/UI issues, use the repo's capture script or
     visual-validation skill if one exists).
3. Run it and **paste the actual failing output** into chat. Confirm the observed failure matches the
   reported symptom.
4. If it does **not** reproduce: stop, report exactly what you tried and what happened, and ask via
   `ask_user` whether to (a) gather more info, (b) proceed on code inspection alone, or (c) abandon.
   Never silently plan a fix for an unreproduced bug.

Keep the failing test — it is the first acceptance criterion of the fix.

For non-bug issues (feature/refactor/docs/chore), skip to step 3, but still note the current
observable behavior as a baseline.

### 3. Research and draft the plan

**First check whether the issue already carries the research.** Issues produced by the `triage` skill
contain **Proposed approach**, **Affected files & components**, **Testing requirements**, and (for
bugs) a root cause. If those sections are present, **do not launch a research subagent** — lift them
straight into the plan, and spend your effort only on verifying that the `file:line` references and
symbols still exist in the current tree (things drift after triage). Note any drift in the plan.

Otherwise, launch a **`general-purpose`** subagent with **no prior conversation context** — write the
prompt from scratch. Include:

- The full issue (or sub-issue) title, body, and relevant comments.
- The confirmed reproduction and its failing output, if any.
- The instruction to first read the repo's `AGENTS.md` / `.github/copilot-instructions.md` and any
  nested `AGENTS.md` in the subtrees it will touch, and to honor the repo's stated
  correctness/performance invariants, conventions, and test tiers.
- The instruction to **investigate only — write no code, make no edits**.

The subagent must return:

- `rootCause` — for bugs, the confirmed cause with `file:line` refs (traced, not guessed); else `n/a`.
- `affected` — `{file, symbol, why}` entries for everything that changes or is added.
- `snippets` — short verbatim current code with `file:line` captions.
- `steps` — ordered implementation steps, each small enough to verify independently.
- `tests` — which test tier/target maps to the change, existing tests that will break, new test names
  + the exact assertion each makes, and the exact command to run them.
- `risks` — invariants that must not break, and what is explicitly out of scope.
- `openQuestions` — resolve these with the user via `ask_user` before drafting.

### 4. Present the plan and get acceptance

1. Write the plan to a git-ignored scratch path (prefer `tmp/fix-issue-<n>-plan.md`; if `tmp/` is not
   ignored, use the session `files/` folder) with sections: **Task**, **Reproduction**, **Root
   cause**, **Approach**, **Step-by-step changes**, **Tests**, **Risks / out of scope**, **Acceptance
   criteria**.
2. **Rubber-duck non-trivial plans.** If the plan touches more than two files, changes a hot/shared
   path, or has invariant/performance implications, launch the `rubber-duck` agent over the plan file
   (give it the research findings too). Ask it to catch: unverified root cause, `file:line` refs that
   don't match reality, invariant violations, acceptance criteria that aren't concretely verifiable,
   and tests that use soft assertions or don't pin *this specific* fix. Act on substantive findings
   and revise; ignore style nits. For a genuinely small, contained fix, skip this and say you skipped
   it.
3. Summarize the plan in chat (concise — the file has the detail).
4. `ask_user`: **accept / edit / reject**. On "edit", let the user edit the plan file, wait for
   confirmation, re-read it, and re-present. On "reject", delete the plan file and stop.

**Write no production code before acceptance.** The failing repro test from step 2 is the only
pre-acceptance artifact.

### 5. Implement

**The fix always goes on a new branch — never commit directly to the default branch.**

1. **Pre-flight.** Confirm the tree is clean and the base is fresh:
   ```pwsh
   git status --porcelain          # must be empty
   git fetch origin
   ```
   If the working tree is dirty or you are mid-rebase/merge, stop and `ask_user` whether to stash or
   abort — never carry unrelated uncommitted changes into the fix. Skipping `git fetch` means
   branching off a stale base and eating avoidable conflicts and CI failures.

2. **Ask where the branch should live.** Use `ask_user` with two options:
   - **worktree** (recommended when the user is likely to keep using the main checkout, or when the
     repo has an expensive build tree) — a separate checkout under `.worktree/` in the same repo;
   - **in-place** — `git switch -c` in the current checkout.

   Pick the branch name first: `fix/<work-issue-number>-<short-slug>` (or the repo's own convention
   if it has one).

   **Worktree option:**
   ```pwsh
   $repo   = git rev-parse --show-toplevel
   $branch = "fix/<work-issue-number>-<short-slug>"
   $wt     = Join-Path $repo ".worktree\<work-issue-number>-<short-slug>"

   git -C $repo worktree add -b $branch $wt origin/<default-branch>
   ```
   - The worktree directory is `.worktree/<work-issue-number>-<short-slug>` **inside the repo root**,
     one directory per issue.
   - Ensure `.worktree/` is ignored — check `git check-ignore -q .worktree`; if it is not ignored, add
     `.worktree/` to `.gitignore` and commit that separately (`chore: ignore .worktree`) *before*
     creating the worktree, so the nested checkout never shows up as untracked noise.
   - After creating it, **`cd` into the worktree and do all work there.** The shell tool starts a
     fresh process each call, so pass the worktree path explicitly every time (`git -C $wt ...`, or
     `cd $wt;` at the start of the command) — never assume the cwd carried over.
   - Use worktree-relative paths for every edit/create/view call. Writing to the main checkout path
     defeats the isolation.
   - The worktree needs its own build/configure step; do not reuse the main checkout's build output.
   - **Never share, symlink, or junction a build/dependency directory between the worktree and the
     main checkout** to "save time" on an expensive configure. A package manager (vcpkg, npm, cargo,
     nuget) running in the worktree can *delete and rebuild* whatever it finds there, destroying the
     main checkout's artifacts. If a fresh configure turns out to be prohibitively slow, stop and
     `ask_user` whether to switch to the in-place branch instead — never work around it by pointing
     the worktree at shared state.

   **In-place option:**
   ```pwsh
   git switch -c fix/<work-issue-number>-<short-slug> origin/<default-branch>
   ```

3. Implement the plan's steps in order. Stay inside the plan's scope — if implementation reveals the
   plan is wrong, stop, say so, and return to step 4 with a revised plan rather than improvising.
4. Run the tests named in the plan. The repro test must now pass. Use the smallest targeted
   build/lint/test commands covering the change; escalate to the full suite only if targeted runs
   suggest wider impact.
5. Paste the real command output. If the repo defines a visual/manual gate for this kind of change,
   run it and inspect the result — a green test run alone is not proof. When working in a worktree,
   confirm you are validating **that** worktree's binary/artifacts, not a stale one from the main
   checkout.
6. Commit in conventional-commit style, referencing the issue:
   ```
   fix: <description>

   Refs #<work-issue-number>
   ```

### 6. Verify the fix, and tell the user how to verify it

The plan's acceptance criteria are the checklist. Work through **every one** and show real evidence
before the user is asked to accept anything.

1. **Re-run the reproduction from step 2.** The exact command/test that failed before the fix must
   now pass. Paste both the "before" failure and the "after" pass so the delta is visible.
2. **Walk the acceptance criteria explicitly.** For each one, state how it was checked and the
   result. If a criterion cannot be checked automatically, say so and cover it in the manual steps
   below — never silently mark it done.
3. **Check for regressions.** Run the targeted suite; if the change touches shared/hot code, run the
   full suite. Confirm no previously passing test now fails.
4. **Re-run new or timing-sensitive tests several times** (5–10×) before trusting them. A test that
   passes once may be flaky; say so if a rerun was needed.
5. **Read your own test source.** Confirm the assertion that pins the fix is a *hard* failure
   (`QCOMPARE`/`assert`/`expect`), not a warning, log line, or soft threshold that would pass even
   with the bug present.
6. **Exercise the real artifact when the issue is user-visible.** A green unit test does not prove a
   GUI/CLI/service behaves correctly. Build and run the actual binary, and use the repo's visual or
   manual gate if it defines one.
7. **Confirm the artifact is not stale.** Compare the build output's mtime against the branch's last
   commit time; if the binary is older, delete it and rebuild. Incremental linkers routinely skip
   relinking an executable when only a library changed. When in a worktree, confirm you are running
   **that worktree's** artifact, not the main checkout's.

Then give the user **copy-pasteable verification instructions** — assume they will not read the
diff:

- The **absolute path to the built artifact** they should run.
- The **exact command** to launch it, including any fixture/config file you created for the purpose.
- **Numbered steps** describing what to do and what they should observe if the fix works.
- A **negative check** — the thing that used to be broken, or a case that must *not* trigger — so a
  false positive is detectable.
- Where useful, an **A/B comparison** against the unfixed build (e.g. the default branch's binary)
  so the difference is unambiguous.
- Any **environmental caveat** that could make verification fail for reasons unrelated to the fix
  (global hotkeys, permissions, missing runtime, ports in use).

Keep any fixture files you generate for this in the repo's ignored scratch dir, and delete them in
cleanup.

### 7. Get the fix accepted, then raise the PR

1. Show the user `git --no-pager diff <base>...HEAD --stat` plus a short summary of what changed and
   the test evidence. If you are in a worktree, run every `git`/`gh` command from that worktree
   (`git -C $wt ...` / `cd $wt;`) — this applies to steps 7, 8, and 9 throughout.
2. `ask_user`: **accept / request changes / abandon**. On "request changes", iterate in steps 5–6
   and re-present. **Do not create a PR until accepted.**
3. On acceptance, push and open the PR (use an **absolute** body path — the repo root from
   `git rev-parse --show-toplevel` — so it doesn't depend on the shell's cwd):
   ```pwsh
   git push -u origin HEAD
   gh pr create --title "<type>: <description>" --body-file "<repo-root>\tmp\fix-issue-<n>-pr.md"
   ```
   The PR body must contain:
   - **Summary** of the change.
   - **Testing** — the commands run and their results.
   - A closing link: `Closes #<work-issue-number>`. If a sub-issue was worked, also add
     `Part of #<parent-issue-number>` — and **do not** close the parent.
4. Report the PR URL.

### 8. Fix the PR build

Watch CI and drive it to green:

```pwsh
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.copilot\skills\fix-issue\scripts\watch-pr-checks.ps1"
```

The script polls `gh pr checks` for the current branch until every check concludes, then prints the
failing jobs and their logs. Pass `-TimeoutMinutes` / `-IntervalSeconds` to tune, `-LogLines` to
change how much log tail is dumped.

For each failure:

1. Read the actual log — never guess from the job name.
2. Fix it locally, reproducing the failure locally first where possible.
3. Commit (`fix: <what>` / `ci: <what>`) and push; re-run the script to confirm.
4. Repeat until green.

If a failure is **pre-existing or unrelated** (fails on the base branch too), prove it — e.g. check
the base branch's latest run with `gh run list --branch <base> --limit 5` — report it to the user,
and do not silently absorb it into this PR.

Re-run a flaky-looking failure once before treating it as real, and say so if a rerun was needed.

If **no checks are ever reported** (the script keeps printing "No checks reported yet"), the repo may
have no CI on PRs. After ~2 minutes of nothing, stop polling, confirm with the user whether CI is
expected, and if not, skip to step 9 — noting explicitly that the PR has no CI coverage and local
test results are the only evidence.

### 9. Resolve every review comment

A PR is not ready for handoff while any review feedback is open. This includes comments from human
reviewers, GitHub Copilot code review, and any bot.

1. Pull the feedback — reviews, inline comments, and issue-level comments (inline review comments do
   **not** appear in `gh pr view --comments`, so fetch both):
   ```pwsh
   gh pr view <pr> --json reviews,comments
   gh api "repos/{owner}/{repo}/pulls/<pr>/comments" `
     --jq '.[] | {id,path,line,user:.user.login,body,in_reply_to_id}'
   ```
2. Triage each comment into: **accept** (valid — fix it), **discuss** (unclear or you disagree), or
   **out of scope** (valid but belongs in a separate issue).
3. For **accept**: make the change, run the relevant tests, and commit referencing what it addresses
   (`fix: <what>` / `refactor: <what>`). Batch related fixes into coherent commits; do not squash
   unrelated feedback into one opaque commit.
4. For **discuss** and **out of scope**: do **not** silently ignore them. Reply on the thread with
   your reasoning, and for out-of-scope items offer to file a follow-up issue (use the `triage` skill
   if available). If you disagree with a reviewer, surface it to the user via `ask_user` rather than
   unilaterally dismissing it.
5. **Reply to every comment**, then **resolve every thread.** Replying:
   ```pwsh
   gh api -X POST "repos/{owner}/{repo}/pulls/<pr>/comments/<comment-id>/replies" -f body="<reply>"
   ```
   Resolving a review thread needs GraphQL (`resolveReviewThread`); fetch the thread IDs and resolve
   each:
   ```pwsh
   gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{id isResolved isOutdated comments(first:1){nodes{body path}}}}}}}' `
     -f o=<owner> -f r=<repo> -F n=<pr>

   gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id=<threadId>
   ```
   If resolving fails (permissions, or the thread belongs to a review you can't resolve), say so
   explicitly and list the unresolved threads — do not claim they are closed.
6. Push the fixes and **re-run step 8** — new commits re-trigger CI, and the build must be green
   again after review fixes.
7. **Exit condition:** every review thread is resolved (or explicitly listed as intentionally
   unresolved with the user's agreement) **and** checks are green. Verify with a final
   `reviewThreads` query showing `isResolved: true` — do not assert this from memory.

Repeat this step for each new round of review feedback until no open threads remain.

### 10. Hand off for review

Once checks are green:

1. Post a short summary: work issue, PR URL, what changed, test/CI evidence, review comments
   addressed (and any deliberately left unresolved), and any sub-tasks still open on the parent issue.
2. `ask_user`: ask the user to **review the PR and close/merge it** — offer to (a) wait while they
   review, (b) merge on their say-so (`gh pr merge`), or (c) leave it open. **Never merge without an
   explicit instruction.**
3. If the user asks you to merge, confirm afterwards that the work issue auto-closed via the `Closes`
   link, and remind them that each remaining sub-task on the parent issue needs a fresh run of this
   skill.
4. If the user leaves the PR open and later comes back with more feedback, go back to **step 9** —
   the "all comments closed" bar applies to every round.

### 11. After the merge: sync, rebuild, re-verify

As soon as the PR is merged — whether you merged it or the user did — bring the user's checkout up
to date. Do **not** leave them on a stale default branch.

1. **Confirm the merge and the issue state** rather than trusting the report:
   ```pwsh
   gh pr view <pr> --json state,mergedAt,mergeCommit,url
   gh issue view <work-issue-number> --json state,closedAt
   ```
   If the issue did not auto-close, close it manually and say why the `Closes` link did not fire.
2. **Switch to the default branch and pull** in the main checkout (not the worktree, which is about
   to be removed):
   ```pwsh
   git -C <repo-root> switch <default-branch>
   git -C <repo-root> pull --ff-only
   ```
   If `--ff-only` fails, the local default branch has diverged — usually local commits you made
   during the run (e.g. a `chore: ignore .worktree`). Do not force anything: inspect with
   `git log --oneline origin/<default-branch>..HEAD`, then `git rebase origin/<default-branch>` to
   replay them, and tell the user exactly which commits are still unpushed and how to push or drop
   them.
3. **Rebuild if the merge changed anything buildable.** Merged commits from other people can land
   alongside yours. Build the whole project, not just your target — a new test file or source file
   added by the merge will not exist as a build artifact otherwise, and test runners will fail with
   "executable not found".
4. **Re-run the test suite against the merged code.** Your branch passing is not the same as the
   merge result passing; a semantic conflict only shows up post-merge. Paste the result.
5. **Confirm the shipped artifact is rebuilt from merged code**, using the same staleness check from
   step 6 (mtime vs. merge commit time; force-rebuild if the linker skipped it).

If anything fails here, treat it as a live regression and fix it — do not close out the run with a
broken default branch.

### 12. Cleanup

Delete the scratch plan / PR-body files, and any fixture/config files you generated for the
verification steps.

Leave the branch and worktree alone until the user confirms the PR is merged **and** they have
verified the merged behaviour — a green CI run can still ship a visually or functionally broken
result. Once they confirm, remove everything the run created:

```pwsh
# worktree runs only — remove the checkout first, or the branch delete will be refused
git -C <repo-root> worktree remove .worktree\<work-issue-number>-<short-slug>
git -C <repo-root> worktree prune

# delete the local branch (safe form first)
git -C <repo-root> branch -d fix/<work-issue-number>-<short-slug>

# drop stale remote-tracking refs for branches deleted on the remote
git -C <repo-root> fetch --prune
```

Notes:

- `branch -d` refuses to delete a branch git thinks is unmerged. After a **squash** or **rebase**
  merge that is expected — the commits were rewritten, so the original branch never appears merged.
  Confirm the PR really is merged (step 11), then use `git branch -D`. Never reach for `-D` just
  because `-d` complained, without checking.
- If the remote branch still exists (no auto-delete-on-merge), remove it too:
  `git push origin --delete fix/<work-issue-number>-<short-slug>`.
- `git worktree remove` fails if the worktree has uncommitted changes. Inspect them before forcing —
  they may be work you have not committed. Only then use `--force`.
- After removing a worktree, check the `.worktree/` parent is actually gone; an empty leftover
  directory is untracked noise. Remove it if nothing else lives there.
- Verify the end state and show it: `git -C <repo-root> worktree list`,
  `git -C <repo-root> branch`, and `git -C <repo-root> status --porcelain` (should be empty).

Then `git -C <repo-root> worktree prune` if any stale entries remain.
