---
name: batch-fix-issues
description: Use when the user wants to fix several GitHub issues in one batch / slot in parallel — "fix these issues in a batch", "work through a batch of issues", "clear a slot of issues", "fix issues in parallel", "batch fix", "pick a batch of issues and fix them". Selects a low-conflict set of issues from the repo, presents a checklist for the user to confirm which go in the current slot, then drives each issue to a merged PR through a dedicated per-issue agent that runs the fix-issue skill in its own worktree. The orchestrator owns all shared repo state (base SHA, worktree creation, main-checkout sync/rebuild/cleanup); agents stay inside their own worktree and never touch the main checkout. Coordinates the human plan/fix/merge/cleanup gates across all agents through machine-readable relay events, keeps conflicting issues out of the same slot, detects late collisions, and never lets a blocker on one issue stall the others.
---

# Batch Fix Issues

Fix a **slot** (batch) of GitHub issues at once. Each issue is owned end-to-end by a **dedicated
agent** that runs the **`fix-issue`** skill in its **own worktree**, so the fixes never step on each
other. This skill is the *orchestrator*: it picks a low-conflict slot, gets the user to confirm the
checklist, owns all shared repository state, runs and supervises the per-issue agents, relays the
human gates (plan / fix / merge / cleanup), and keeps one issue's trouble from blocking the rest.

This skill does **not** re-implement the fix workflow — the per-issue agents do that by following
`fix-issue`. Read `fix-issue/SKILL.md` for the single-issue contract; this file adds the batching,
conflict-avoidance, isolation, and coordination layer on top, and defines the **explicit overrides**
(below) that make `fix-issue` safe to run many-at-once.

## Execution contract

This section is binding and governs every run — it is not advisory.

- **Follow the steps in order.** Execute steps 1→7 as written. Do not skip, reorder, merge, or
  improvise steps, and do not substitute your own workflow for the one specified here. Every
  guarantee in this file and in `fix-issue` must actually be carried out, not assumed.
- **Optional input means apply the default, never ask.** When the user omits an input (issue list,
  slot size, knobs), silently apply this skill's default and proceed. Absent input is *permission to
  use the default*, not a prompt to clarify.
- **`ask_user` is allowed only at the points this skill sanctions:** the **step-4 slot checklist**,
  and the **gate relays** in steps 5–6 (plan / fix / merge / cleanup, plus any relayed
  blocker / build / review / question event — see the event table in step 5). Nowhere else. In
  particular, do **not** open a run with any preliminary "how should we proceed / how many issues /
  which approach / just to confirm" question — that meta-prompt is prohibited. The step-4 checklist
  is where the user adjusts scope and slot size.
- **The orchestrator owns shared repo state.** The base SHA, `.worktree/` ignore, worktree creation,
  and every operation on the **main checkout** (default-branch sync, rebuild, worktree/branch
  cleanup) are done by *you*, serialised, never by the agents. Agents act only inside their own
  worktree. This is what makes parallel `fix-issue` runs safe.
- **Agents never call `ask_user`.** Every human interaction `fix-issue` would trigger becomes a
  typed relay event to you (step 5 event table). You surface it with `ask_user` and relay the answer
  back with `write_agent`.
- **When unsure, re-read the step, don't invent.** If a step is ambiguous, follow its literal
  instruction and the referenced script/JSON output rather than deviating. Verify state from real
  `git` / `gh` / `read_agent` output, never from memory.

## Principles

- **One agent, one issue, one worktree.** Every issue in the slot is handled by its own dedicated
  agent running `fix-issue` in a dedicated `.worktree/<work-issue>-<slug>` checkout that **you
  pre-create**. Agents never share a worktree, a branch, or a build tree, and never make their own.
- **Batch by conflict, not by convenience.** Prefer issues that touch **disjoint** files. When full
  disjointness is impossible, prefer the combination with the **least** overlap. An issue that
  **touches almost everything** is never batched — it runs in a slot of its own.
- **Resolve the real work issue before packing.** A candidate may have a sub-issue that becomes the
  actual work issue (its branch, PR, and worktree key off that number). Resolve it up front so the
  footprint, worktree path, and tracking row are keyed correctly.
- **The user owns the slot.** You *propose* a slot; the user confirms the final checklist (add /
  remove issues) before any agent starts. Any checklist change is **re-packed** before launch.
- **The user owns every gate.** Plan acceptance, fix acceptance, merge, and post-merge cleanup are
  **human decisions**. Agents pause at each gate and you relay it — agents never self-approve.
- **Isolate failure.** A blocker, failed build, rejected plan, stuck review, or a **lost/failed
  agent** on one issue must **never** stall the others. Park the troubled issue, keep the rest
  moving, and report it.
- **Detect collisions, don't hope.** Compare agents' *actual* changed-file sets at the fix and merge
  gates — footprints are estimates and can drift. Park or rebase on real overlap.
- **Verify, don't assume.** Slot membership, work-issue numbers, agent state, changed files, PR
  state, and merge state come from real output (`git`, `gh`, `read_agent`) — never from memory.

## Concepts

- **Slot** — the set of issues fixed together in one run. Chosen to minimise cross-issue conflict.
- **Candidate issue vs work issue** — the candidate is what the user chose; the *work issue* is what
  `fix-issue` actually fixes (the candidate itself, or its first open sub-issue). Branch, PR, and
  worktree key off the **work issue**.
- **Footprint** — the set of files an issue is expected to change. Drives conflict scoring.
- **Base SHA** — the single `origin/<default-branch>` commit, captured at launch, that **every**
  worktree is created from, so all agents start from an identical, frozen base.
- **Per-issue agent** — a `general-purpose` background agent whose entire job is to run `fix-issue`
  for exactly one work issue in a worktree you pre-created, reporting every gate as a relay event.
- **Relay event** — a single machine-readable JSON line an agent emits at the end of a turn when it
  needs a human decision or hit trouble (step 5). The orchestrator parses it, surfaces it via
  `ask_user`, and relays the answer with `write_agent`.

## Input

An optional list of issues (numbers, `#123`, or URLs) and/or a slot size. All optional.

- If the user named specific issues, those are the **candidate pool**.
- If the user did not name issues, build the pool yourself (see step 1) — any open issue is
  fair game, assigned or not, exactly as `fix-issue` selects.
- Default slot size is **10** concurrent issues unless the user asks for a different number. Slot
  size sets how many plan/fix/merge gates the user has in flight; the packer still keeps slot
  members low-conflict. Do not ask the user to pick a size — apply the default per the Execution
  contract and let the step-4 checklist adjust it. Always pass the effective size to the packer as
  `-SlotSize`.

## Steps

### 1. Build the candidate pool and resolve work issues

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

Aim for a candidate pool larger than the slot so the conflict analysis has room to pick a clean
subset: target `max(slotSize + 5, 2 × slotSize)` candidates, capped at what the repo actually has
open. If there are no open issues, say so and stop.

**Resolve each candidate's work issue now**, before footprinting — the same way `fix-issue` step 1
does (native sub-issues first, then task-list checkboxes; pick the lowest-numbered open sub-issue if
any, else the candidate itself). Record both numbers; everything downstream (footprint, worktree
path, branch, tracking row) keys off the **work issue**. If all of a candidate's sub-tasks are
already closed, drop it and say so.

### 2. Estimate each work issue's footprint

For every work issue, estimate the set of files it will touch. In preference order:

1. **Triage metadata.** Issues from the `triage` skill carry **Affected files & components** —
   lift those paths directly. This is the cheapest and most reliable source.
2. **Body / comments.** Explicit file paths or component names in the issue text.
3. **Quick investigation.** For anything still vague, launch **parallel `explore` agents** (one per
   unclear issue) that answer only: *"Which files/directories would a fix for this issue most likely
   change? List repo-relative paths, no code edits."* Keep these read-only and short.

Mark an issue as **global** when a fix would realistically touch a broad, shared surface — a
repo-wide rename, a formatting/lint sweep, a change to a core file nearly everything imports, or
a build/CI config that every job depends on. Global issues are never batched.

If investigation still cannot name any files, leave `files` empty: the packer routes it to the
**unknown** bucket instead of treating it as conflict-free. Do not batch an unknown-footprint issue.

Write the footprints to a scratch JSON file (git-ignored `tmp/`, or the session `files/` folder),
keyed by **work issue** number. Paths may be exact files, directory prefixes (`src/`), or globs
(`src/**`) — the packer expands them against the repo's tracked files:

```json
[
  { "issue": 123, "title": "fix scoop installer", "files": ["scoop/setup.ps1"] },
  { "issue": 130, "title": "repo-wide rename", "global": true, "files": [] },
  { "issue": 131, "title": "vague crash",        "files": [] }
]
```

### 3. Compute the proposed slot

Run the packer — it groups candidates into `slot` / `deferred` / `solo` / `unknown`, choosing the
best low-conflict combination (it seeds from every candidate and keeps the largest, lowest-overlap
slot) and pushing "touches everything" issues to `solo`:

```pwsh
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.copilot\skills\batch-fix-issues\scripts\compute-slot.ps1" `
  -FootprintPath "<footprint.json>" -SlotSize <n> -RepoRoot "<repo-root>"
```

Useful knobs: `-HighConflict <k>` (pairwise shared-file count at/above which two issues are too
conflicting to batch — **default 1**, so any shared file excludes a pairing; raise it to allow some
overlap), `-GlobalThreshold <k>` (expanded footprint size treated as "touches everything").
`-RepoRoot` lets the packer expand directory/glob footprints via `git ls-files`. The script prints a
checklist plus JSON:

- **slot** — the proposed batch (each entry notes its overlap with the rest, or "no conflict").
- **deferred** — candidates left out because they conflict too much with a slot member, or the slot
  is full. These are the next slot's material.
- **solo** — global issues that must run alone.
- **unknown** — issues with no usable footprint; investigate them before they can be batched.

Read the JSON, don't eyeball it. If the whole pool turns out mutually conflicting, the slot may end
up as a single issue — that is the correct answer, not a failure.

### 4. Present the checklist and get the slot confirmed

Show the user the proposed slot as a **checklist** via `ask_user` (a multi-select of the candidate
issues), pre-checking the packer's `slot` and listing, for each, its work-issue number, title, and
conflict note. In the `ask_user` message also spell out:

- which issues were **deferred** and why (overlap with which slot member, or slot full),
- which are **solo/global** and therefore excluded from any batch,
- which have an **unknown footprint** and need investigation first,
- the recommended slot size and that each checked issue gets its own worktree + agent.

Let the user check/uncheck freely. **Any change to the selection re-packs**: rebuild the footprint
list from the final checked set and re-run the packer over it, so freed capacity re-fills and every
remaining conflict is rescored against the *actual* final slot. If the user forces back a pair the
packer flags as high-conflict, warn once (name the shared files) and proceed if they insist — it's
their call, but it will be watched by the collision check in step 6. The **final re-packed set of
checked issues is the slot.** If the user checks nothing, stop.

Create a fresh **run id** and record the slot in the session DB so progress survives across turns:

```sql
CREATE TABLE IF NOT EXISTS batch_slot (
  run_id       TEXT    NOT NULL,
  slot_id      INTEGER NOT NULL,
  candidate    INTEGER NOT NULL,   -- issue the user picked
  work_issue   INTEGER,            -- issue fix-issue actually fixes (sub-issue or candidate)
  title        TEXT,
  slug         TEXT,
  branch       TEXT,
  worktree     TEXT,
  base_sha     TEXT,
  agent_id     TEXT,
  last_seq     INTEGER DEFAULT 0,  -- highest relay-event seq seen from the agent
  pending_gate TEXT,               -- event type currently awaiting the user, or NULL
  changed      TEXT,               -- JSON list of the agent's actual changed files (steps 6)
  state        TEXT DEFAULT 'queued',
  note         TEXT,
  PRIMARY KEY (run_id, candidate)
);
```

State machine (`state`):
`queued → planning → plan-gate → implementing → fix-gate → pr → checks → review →
merge-gate → merged → verify-gate → cleaning → done`, with the off-ramps
`blocked`, `parked`, `lost` (agent stopped emitting / crashed), and `failed`.

Insert the slot rows in a single transaction under one `run_id` so a resumed or repeated run never
mixes with stale rows.

### 5. Prepare shared state, then launch one agent per slot issue

**Prepare the shared base first — the orchestrator does this once, before any agent starts:**

```pwsh
$repo = git rev-parse --show-toplevel
git -C $repo fetch origin
$default  = (git -C $repo symbolic-ref --short refs/remotes/origin/HEAD) -replace '^origin/',''
$base_sha = git -C $repo rev-parse "origin/$default"
```

Ensure `.worktree/` is git-ignored **now**, once, on the default branch (so no agent has to commit
that itself and race the others). Then **pre-create every worktree and branch** off the frozen
`$base_sha`:

```pwsh
$slug = "<short-slug>"                       # per work issue
$wt   = Join-Path $repo ".worktree\<work-issue>-$slug"
git -C $repo worktree add -b "fix/<work-issue>-$slug" $wt $base_sha
```

If a branch or worktree with that name already exists (an interrupted earlier run), do **not** blow
it away: record the issue as `parked` with a note and surface it in step 6 for the user to resume or
discard. Store `branch`, `worktree`, and `base_sha` in `batch_slot`.

Then, for each slot issue, launch a **`general-purpose` background agent** whose sole job is to run
`fix-issue` for that one work issue **in the worktree you already created**. Launch them in parallel
and store each returned `agent_id` in `batch_slot`.

Give each agent a fully self-contained prompt (background agents share no context). It must include
the following, stated as hard overrides of `fix-issue`:

- **Scope:** "You own work issue #<work> only (candidate #<candidate>). Run `fix-issue` for it
  end to end, except for the overrides below."
- **Pre-made worktree — do not create your own.** "Your worktree already exists at `<wt>` on branch
  `fix/<work>-<slug>`, created off base `<base_sha>`. **Skip `fix-issue` step 5's branch/worktree
  creation and its location prompt.** Do all edits, builds, tests, `git`, and `gh` from `<wt>` (`git
  -C <wt> ...` / `cd <wt>;`). Never touch the main checkout or any other worktree."
- **You never run the shared/main-checkout steps.** "Do **not** run `fix-issue` steps 11–12 (default
  branch sync, rebuild, worktree/branch cleanup). Those are the orchestrator's. When your PR is
  merged, emit a `MERGED` event and stop."
- **You never call `ask_user`.** "For **every** point where `fix-issue` would ask the user, stop,
  emit the matching relay event as your final line, and wait for my reply on the next turn. Apply my
  decision and continue." Then include the event table below.
- **The full issue context** you already gathered (title, body, relevant comments, resolved
  work-issue number, footprint) so the agent doesn't re-fetch blindly.
- **Isolation duty:** "If you hit a blocker you cannot clear, emit `BLOCKED` and stop — do not
  thrash. Never modify shared repo state outside your worktree."
- **Heartbeat:** "If a turn does real work but reaches no gate, end it with a `PROGRESS` event so I
  know you're alive."

#### Relay events (machine-readable)

Every agent turn that needs the human, hit trouble, or made progress **ends with exactly one JSON
line** prefixed with the sentinel `@@BFX`, e.g.:

```
@@BFX {"runId":"<id>","workIssue":123,"seq":4,"type":"GATE_PLAN","payload":{"planFile":"<abs path>","mdview":"opened","summary":"..."}}
```

`seq` increments per event from that agent; ignore any event whose `seq` is not greater than
`last_seq` for that issue (guards against a re-read replaying a stale gate). The `type` values and
the `fix-issue` interaction each replaces:

| `type`         | Replaces (fix-issue)                              | You surface as `ask_user`               |
|----------------|---------------------------------------------------|-----------------------------------------|
| `GATE_PLAN`    | step 4 plan accept/edit/reject (mdview opened)    | accept / edit / reject                  |
| `GATE_FIX`     | step 7 fix accept/request-changes                 | accept / request-changes                |
| `GATE_MERGE`   | step 10 review/merge                              | merge / wait / leave-open               |
| `GATE_CLEANUP` | step 12 "confirm merged + verified" before cleanup| confirm cleanup / keep branch           |
| `NEED_INPUT`   | any other `fix-issue` `ask_user` (sub-issue dep, existing-PR choice, ambiguous repro, step-3 open questions, dirty tree, mdview-launch failure, expensive-build fallback, validation blocker, missing-CI, review dispute) — `payload.question` says which | present the question verbatim, options in payload |
| `BLOCKED`      | an unrecoverable blocker                          | decide: retry / park / swap-in deferred |
| `BUILD_FAILED` | step 8 CI failure the agent can't resolve         | decide with the user                    |
| `REVIEW`       | step 9 review feedback needing a human call        | decide with the user                    |
| `PROGRESS`     | (heartbeat, no user action)                       | none — just update `last_seq`           |
| `MERGED`       | PR merged; agent stops before steps 11–12         | none — orchestrator runs post-merge     |

You relay the answer back with `write_agent` (e.g. "User accepted the plan — implement it" / "User
requests changes: <notes>" / "User approved merge — run `gh pr merge`"). Update `state`,
`last_seq`, and `pending_gate` in `batch_slot` on every event.

**Plan gates are reviewed one at a time, not batched.** When plan gates arrive:

1. Wait until you have a sensible set of plans ready (or all), then **tell the user, in plain
   text, that all N plans are ready** and ask whether they'd like to discuss first — do not
   force a decision yet.
2. Walk the user through the plans **one plan at a time**: present a single plan, get its
   accept / edit / reject decision, relay it to the owning agent, and only then move to the next.

For the **fix** and **merge** gates you may batch when convenient: if two agents wait at the same
fix or merge gate, you may present them in one `ask_user` with a field per issue, to save
round-trips. Never merge or approve on the user's behalf.

### 6. Supervise the slot to completion

Drive all agents concurrently. You'll be **notified when an agent finishes a turn**; on each
notification `read_agent` the agent, parse its trailing `@@BFX` event, update `batch_slot`, and act:

- **A gate/`NEED_INPUT` event** → run the relay protocol (step 5), then `write_agent` the decision.
- **`BLOCKED` / `BUILD_FAILED` / `REVIEW`** → surface to the user; if unrecoverable, mark the issue
  `blocked`/`parked`, tell the user briefly, and **move on** — do not stall the others. Offer to
  revisit parked issues later, or to swap in a `deferred` candidate if capacity frees up (a swap-in
  re-runs steps 2–5 for that one issue: footprint, re-pack against the *active* slot, pre-create its
  worktree, launch).
- **A turn that ends with no parseable `@@BFX` event, or `read_agent` shows the agent failed/idle
  with no pending gate** → treat it as `lost`/`failed`. Don't hang the slot on it: mark it, tell the
  user, and offer to relaunch that one issue (fresh agent, same pre-made worktree) or park it.
- **`MERGED`** → mark `merged`. The agent has stopped; the **orchestrator** now runs the post-merge
  work for that issue (below), then the cleanup gate.

**Collision detection (footprints are only estimates).** Before you relay a `GATE_FIX` or
`GATE_MERGE`, get the agent's *actual* changed files (have the gate payload include
`git -C <wt> diff --name-only <base_sha>...HEAD`, stored in `batch_slot.changed`). Compare against
every other **active, unmerged** issue's `changed`:

- Overlap found → do **not** auto-resolve. Park the *later* issue (the one not yet merged), tell
  the user, and let the first land; then have the parked agent rebase onto the new default and
  re-validate before its own merge gate.

**Post-merge work is the orchestrator's, and serialised.** When an issue reports `MERGED`, run its
`fix-issue`-equivalent post-merge sequence on the **main checkout yourself**, and hold a mutex so no
two of these overlap (only one may `switch`/`pull`/rebuild the main checkout at once; worktrees are
independent):

```pwsh
gh pr view <pr> --json state,mergedAt,mergeCommit,url
git -C $repo switch $default
git -C $repo pull --ff-only
# rebuild if the merge changed anything buildable; re-run the targeted suite; paste results
```

If a later slot branch has fallen behind because an earlier peer merged, instruct that agent (via
`write_agent`) to rebase its worktree onto `origin/$default` and re-validate **before** you
relay its merge gate — never merge a stale branch.

Keep a short running status the user can read at a glance — one line per issue: work-issue number,
state, and next action (waiting on user gate / agent working / blocked / lost). Rebuild it from
`batch_slot` whenever the user asks "where are we".

### 7. Close out the slot

When every slot issue has reached a terminal state (`done`, or `parked`/`blocked`/`lost`/`failed`
with the reason recorded):

1. For each `merged` issue, relay its **`GATE_CLEANUP`**: confirm with the user that
   the merge is verified, then have the owning agent — or you, if the agent has already stopped —
   remove its worktree and branch (`fix-issue` step 12), and mark the issue `done`. Never clean up a
   branch the user has not confirmed.
2. Post a **slot summary**: per issue — work-issue number, PR URL + merge state, or the blocker that
   parked it.
3. Verify from real output: `gh issue view <work> --json state,closedAt` (each merged issue
   auto-closed via its `Closes` link), `git -C $repo worktree list`, and `git -C $repo branch` (the
   slot's worktrees/branches are gone).
4. Confirm the main checkout is clean and current: `git -C $repo switch $default`,
   `git -C $repo pull --ff-only`, `git -C $repo status --porcelain` (empty).
5. If any issues were **parked**, **deferred**, or **lost**, offer the **next slot**: re-run
   steps 2–4 over the remaining pool (footprints may have shifted as files changed) under a new
   `run_id`, and present a fresh checklist.
6. Delete the scratch footprint/status files. Drop or keep `batch_slot` as the user prefers.

## Notes

- **Never batch a `solo`/global or `unknown` issue.** If the user insists on a repo-wide change, run
  it as a slot of one and say why. Investigate unknown footprints before they can enter a slot.
- **Conflicts detected late.** The step-6 collision check compares real diffs; if two agents' actual
  changes collide despite disjoint footprints (e.g. both edit a shared config found mid-fix), don't
  auto-resolve: park the later one and let the first merge before rebasing the second
  onto the new default branch.
- **Frozen base, moving default.** Every worktree starts from the one `base_sha` for clean
  isolation, but the real default branch moves as peers merge, so later branches must rebase
  and re-validate before their merge gate — the base SHA is a starting line, not the merge target.
- **Don't over-parallelise the human.** More agents than the user can service just means idle agents
  waiting at gates. Prefer a smaller slot with fast turnaround over a large one that stalls.
- **Read the fix-issue contract.** Every fix guarantee — reproduce-before-plan, plan-before-code,
  verify-before-ask, green-before-handoff, resolve-every-comment — is met by the agent running
  `fix-issue`, not restated here. This skill overrides only branch/worktree creation (step 5), the
  shared main-checkout steps (11–12), and the `ask_user` calls (all routed through relay events). If
  `fix-issue` changes, this one inherits it — re-check the override points and the event table.
