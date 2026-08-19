---
name: batch-fix-issues
description: Use when the user wants to fix several GitHub issues in one batch / slot in parallel — "fix these issues in a batch", "work through a batch of issues", "clear a slot of issues", "fix issues in parallel", "batch fix", "pick a batch of issues and fix them". Selects a low-conflict set of issues from the repo, presents a checklist for the user to confirm which go in the current slot, then drives each issue to a merged PR through a dedicated per-issue agent that runs the fix-issue skill in its own worktree. Coordinates the human plan/fix/merge gates across all agents, keeps conflicting issues out of the same slot, and never lets a blocker on one issue stall the others.
---

# Batch Fix Issues

Fix a **slot** (batch) of GitHub issues at once. Each issue is owned end-to-end by a **dedicated
agent** that runs the **`fix-issue`** skill in its **own worktree**, so the fixes never step on each
other. This skill is the *orchestrator*: it chooses a low-conflict slot, gets the user to confirm the
checklist, launches and supervises the per-issue agents, relays the human gates (plan / fix / merge),
and keeps one issue's trouble from blocking the rest.

This skill does **not** re-implement the fix workflow — the per-issue agents do that by following
`fix-issue` verbatim. Read `fix-issue/SKILL.md` for the single-issue contract; this file only adds
the batching, conflict-avoidance, and coordination layer on top.

## Principles

- **One agent, one issue, one worktree.** Every issue in the slot is handled by its own dedicated
  agent running `fix-issue` in a dedicated `.worktree/<work-issue>-<slug>` checkout. Agents never
  share a worktree, a branch, or a build tree.
- **Batch by conflict, not by convenience.** Prefer issues that touch **disjoint** files. When full
  disjointness is impossible, prefer the combination with the **least** overlap. An issue that
  **touches almost everything** is never batched — it runs in a slot of its own.
- **The user owns the slot.** You *propose* a slot; the user confirms the final checklist (add /
  remove issues) before any agent starts.
- **The user owns every gate.** Plan acceptance, fix acceptance, and merge are **human decisions**,
  exactly as in `fix-issue`. Agents pause at each gate and you relay it to the user — agents never
  self-approve their own plan, fix, or merge.
- **Isolate failure.** A blocker, failed build, rejected plan, or stuck review on one issue must
  **never** stall the others. Park the troubled issue, keep the rest moving, and report the blocker.
- **Verify, don't assume.** Slot membership, agent state, PR state, and merge state are all read from
  real output (`git`, `gh`, `read_agent`) — never asserted from memory.

## Concepts

- **Slot** — the set of issues fixed together in one run. Chosen to minimise cross-issue conflict.
- **Footprint** — the set of files an issue is expected to change. Drives conflict scoring.
- **Per-issue agent** — a `general-purpose` background agent whose entire job is to run `fix-issue`
  for exactly one issue in its own worktree, reporting back at each human gate.
- **Gate** — a point where `fix-issue` requires a human decision: plan accept/edit/reject (step 4–5),
  fix accept/request-changes (step 7), review/merge (step 10). This orchestrator surfaces every gate
  to the user via `ask_user` and relays the answer back to the owning agent.

## Input

An optional list of issues (numbers, `#123`, or URLs) and/or a slot size. All optional.

- If the user named specific issues, those are the **candidate pool**.
- If the user did not name issues, build the candidate pool yourself (see step 1) — any open issue is
  fair game, assigned or not, exactly as `fix-issue` selects.
- Default slot size is **3** concurrent issues unless the user asks for more. Keep it small enough
  that the user can realistically service three plan/fix/merge gates.

## Steps

### 1. Build the candidate pool

If the user gave a list, use it. Otherwise pull open issues (same query `fix-issue` uses):

```pwsh
gh issue list --state open --limit 40 `
  --json number,title,labels,assignees,updatedAt `
  --jq '.[] | {number,title,labels:[.labels[].name],assignee:(.assignees[0].login // "unassigned"),updatedAt}'
```

Drop anything that already has an open PR targeting it (it's mid-flight):

```pwsh
gh pr list --state open --json number,title,body,headRefName
```

Aim for a candidate pool a bit larger than the slot size (e.g. 6–10) so the conflict analysis has
room to pick a clean subset. If there are no open issues, say so and stop.

### 2. Estimate each candidate's footprint

For every candidate, estimate the set of files it will touch. In preference order:

1. **Triage metadata.** Issues produced by the `triage` skill carry **Affected files & components** —
   lift those paths directly. This is the cheapest and most reliable source.
2. **Body / comments.** Explicit file paths or component names in the issue text.
3. **Quick investigation.** For anything still vague, launch **parallel `explore` agents** (one per
   unclear issue) that answer only: *"Which files/directories would a fix for this issue most likely
   change? List repo-relative paths, no code edits."* Keep these read-only and short.

Mark an issue as **global** when a fix would realistically touch a broad, shared surface — a
repo-wide rename, a formatting/lint sweep, a change to a core file that nearly everything imports, or
a build/CI config that every job depends on. Global issues are never batched.

Write the footprints to a scratch JSON file (git-ignored `tmp/`, or the session `files/` folder):

```json
[
  { "issue": 123, "title": "fix scoop installer", "files": ["scoop/setup.ps1"] },
  { "issue": 130, "title": "repo-wide rename", "global": true, "files": [] }
]
```

### 3. Compute the proposed slot

Run the packer — it groups candidates into `slot` / `deferred` / `solo`, choosing the least-conflict
combination and pushing "touches everything" issues to `solo`:

```pwsh
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.copilot\skills\batch-fix-issues\scripts\compute-slot.ps1" `
  -FootprintPath "<footprint.json>" -SlotSize <n>
```

Useful knobs: `-HighConflict <k>` (pairwise shared-file count at/above which two issues are too
conflicting to batch — lower is stricter), `-GlobalThreshold <k>` (footprint size treated as
"touches everything"). The script prints a checklist plus JSON:

- **slot** — the proposed batch (each entry notes its overlap with the rest, or "no conflict").
- **deferred** — candidates left out because they conflict too much with a slot member, or the slot
  is full. These are the next slot's material.
- **solo** — global issues that must run alone.

Read the JSON, don't eyeball it. If the whole pool turns out mutually conflicting, the slot may end
up as a single issue — that is the correct answer, not a failure.

### 4. Present the checklist and get the slot confirmed

Show the user the proposed slot as a **checklist** via `ask_user` (a multi-select of the candidate
issues), pre-checking the packer's `slot` and listing, for each, its title and conflict note. In the
`ask_user` message also spell out:

- which issues were **deferred** and why (overlap with which slot member, or slot full),
- which are **solo/global** and therefore excluded from any batch,
- the recommended slot size and that each checked issue will get its own worktree + agent.

Let the user check/uncheck freely. If the user adds back a pair the packer flagged as high-conflict,
warn them once (name the shared files) and proceed if they insist — it's their call. The **final set
of checked issues is the slot.** If the user checks nothing, stop.

Record the slot in the session DB so progress survives across turns:

```sql
CREATE TABLE IF NOT EXISTS batch_slot (
  issue INTEGER PRIMARY KEY,
  title TEXT,
  worktree TEXT,
  agent_id TEXT,
  state TEXT DEFAULT 'queued',   -- queued|planning|plan-gate|implementing|fix-gate|pr|checks|merge-gate|merged|blocked|parked
  note TEXT
);
```

### 5. Launch one dedicated agent per slot issue

For each checked issue, launch a **`general-purpose` background agent** (mode `background`) whose sole
job is to run `fix-issue` for that one issue **in its own worktree**. Launch them together (parallel).
The worktree path is fixed by the `fix-issue` convention, so the orchestrator already knows it:
`.worktree/<work-issue-number>-<short-slug>` under the repo root.

Give each agent a fully self-contained prompt (background agents share no context). It must include:

- **Scope:** "You own GitHub issue #<n> only. Run the `fix-issue` skill for it end to end."
- **Worktree, not in-place:** "Use the **worktree** option in `fix-issue` step 5. Create and work in
  `.worktree/<n>-<slug>` off `origin/<default-branch>`. Do all edits, builds, tests, `git`, and `gh`
  from that worktree path (`git -C <wt> ...` / `cd <wt>;`). Never touch the main checkout or any other
  worktree." Do **not** offer the in-place option — batching requires isolation.
- **The gate-relay protocol (below):** "You do **not** call `ask_user` for the plan, fix, or merge
  gates. At each gate, stop, post a `GATE` report as described, and wait for my reply via a new turn.
  Apply my decision, then continue."
- **The full issue context** you already gathered (title, body, relevant comments, footprint) so the
  agent doesn't re-fetch blindly.
- **Isolation duty:** "If you hit a blocker you cannot clear, report `BLOCKED` with the reason and
  stop — do not thrash. Never modify shared repo state outside your worktree."

Store each returned `agent_id` in `batch_slot`.

#### Gate-relay protocol

Human gates cannot be answered by the agents themselves — the *user* owns them, and several agents
would otherwise ask at once. So each agent reports gates to **you**, and you relay to the user:

1. When an agent reaches a gate it ends its turn with a single structured line, e.g.
   `GATE plan #<n>: <one-line summary> | plan file: <path>` or
   `GATE fix #<n>: <summary> | diff stat: <...>` or
   `GATE merge #<n>: <PR url>, checks green`. For the **plan** gate it must also have opened the plan
   in mdview per `fix-issue` step 4 (it can do that from its worktree), or told you it could not.
2. You surface that gate to the user with `ask_user` (accept / edit / reject for plan; accept /
   request-changes for fix; merge / wait / leave-open for merge) — mirroring `fix-issue` exactly.
3. You relay the user's answer back to the owning agent with `write_agent` (e.g. "User accepted the
   plan — implement it" / "User requests changes: <notes>" / "User approved merge — run
   `gh pr merge`"). The agent resumes from where it paused.
4. `BLOCKED`/`BUILD-FAILED`/`REVIEW` reports are handled the same way — surface, decide with the user,
   relay back.

Batch gates when you can: if two agents are both waiting at a plan gate, you may present them in one
`ask_user` with a field per issue, to save the user round-trips. Never merge or approve on the user's
behalf.

### 6. Supervise the slot to completion

Drive all agents concurrently. You'll be **notified when a background agent finishes a turn**; on each
notification `read_agent` the agent, update its `state` in `batch_slot`, and act:

- **A gate report** → run the relay protocol (step 5), then `write_agent` the decision.
- **A blocker** (`BLOCKED`, unresolved build failure, rejected plan the user won't revise) → mark that
  issue `blocked`/`parked` in `batch_slot`, tell the user briefly, and **move on**. Do **not** hold up
  the other agents. Offer to revisit parked issues after the slot drains, or to swap in a `deferred`
  candidate from step 3 if capacity frees up.
- **Merged** → mark `merged`. The agent runs `fix-issue` steps 11–12 (sync default branch, rebuild,
  clean up its worktree/branch) for its own issue.

Keep a short running status the user can read at a glance — one line per issue: state, and the next
action (waiting on user gate / agent working / blocked). Regenerate it from `batch_slot` whenever the
user asks "where are we".

Because each agent syncs and rebuilds the **main checkout** in `fix-issue` step 11 after its merge,
serialise that step when two agents merge close together: let one finish its default-branch
sync/rebuild before telling the next to merge, so two agents don't `switch`/`pull` the main checkout
at the same time. (Their worktrees are independent; only the shared main checkout needs serialising.)

### 7. Close out the slot

When every slot issue has reached a terminal state (`merged`, or `parked`/`blocked` with the reason
recorded):

1. Post a **slot summary**: per issue — PR URL + merge state, or the blocker that parked it.
2. Confirm each merged issue auto-closed (`gh issue view <n> --json state,closedAt`) and that its
   worktree/branch were removed (the owning agent does this via `fix-issue` step 12; verify with
   `git -C <repo-root> worktree list` and `git -C <repo-root> branch`).
3. Verify the main checkout is clean and current: `git -C <repo-root> switch <default-branch>`,
   `git -C <repo-root> pull --ff-only`, `git -C <repo-root> status --porcelain` (empty).
4. If any issues were **parked** or **deferred**, offer to start the **next slot**: re-run steps 2–4
   over the remaining pool (footprints may have shifted now that files changed) and present a fresh
   checklist.
5. Delete the scratch footprint/status files. Drop or keep the `batch_slot` table as the user prefers.

## Notes

- **Never batch a `solo`/global issue.** If the user insists on including a repo-wide change, run it as
  a slot of one and say why.
- **Conflicts detected late.** If two agents' *actual* diffs collide despite disjoint footprints
  (e.g. both edit a shared config discovered mid-fix), don't auto-resolve: park the later one, tell the
  user, and let the first merge before rebasing the second onto the new default branch.
- **Don't over-parallelise the human.** More agents than the user can service just means idle agents
  waiting at gates. Prefer a smaller slot with fast turnaround over a large one that stalls.
- **Read the fix-issue contract.** Every per-issue guarantee — reproduce-before-plan, plan-before-code,
  verify-before-ask, green-before-handoff, resolve-every-comment, clean-current-checkout — is enforced
  by the agent running `fix-issue`, not restated here. If that skill changes, this one inherits it.
