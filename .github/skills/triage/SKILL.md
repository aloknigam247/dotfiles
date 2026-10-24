---
name: triage
description: Use when the user wants to triage a task/bug/idea into a well-formed GitHub issue for a future agent to implement. Discusses the task, investigates what needs doing and where, classifies it, and creates a GitHub issue only after the user accepts. Trigger phrases include "triage", "triage this", "create an issue", "file an issue", "turn this into a task", "raise a ticket".
---

# Triage

Turn a rough task, bug, or idea into a **well-formed GitHub issue** that a *different agent* can implement later with no prior conversation context. The skill discusses the task, investigates this **dotfiles repo** to find what needs doing and where, classifies it, and — **only after the user explicitly accepts** — creates the issue in this project's GitHub repo.

## Principles

- **Discuss first, create last.** Never run `gh issue create` until the user has reviewed the drafted issue and explicitly accepted it.
- **The issue is for another agent, at another time.** Write it as a self-contained task: enough context, file references, and acceptance criteria that an agent with zero conversation history can pick it up and implement it.
- **Anchor to stable identifiers, not coordinates.** An issue is implemented at an unknown later time against a changed tree. Reference symbols, `setup.ps1` variables, config keys, and search patterns — never line numbers, occurrence counts, or verbatim multi-line snapshots that the repo will invalidate. A frozen inventory goes stale *and* misleads: the implementing agent trusts it as exhaustive and skips rediscovering occurrences added after the issue was filed. The issue points the way; the implementing agent re-discovers the exact scope.
- **Match detail to task type.** For a narrow **bug**, ground the diagnosis in a tight snippet of the actual defect.
  For **broad sweeps** (a rename, a convention change across modules), staleness dominates: give a discovery recipe
  (search patterns + stable anchors), not an enumerated file list.
- **Ask for missing details.** Do not guess when scope, expected behavior, or acceptance criteria are ambiguous.

## Input

The user provides a task, bug report, or idea in their request. It may be vague (e.g., "the statusline flickers on git pull") or a feature ask. It may also come from a line in `tasks.md` (which uses `TYPE(scope): description` shorthand).

## Repo shape (important context for investigation)

This is a **cross-platform dotfiles / config repo**, mostly PowerShell plus per-application config.

- Each top-level directory is a **package/module** (e.g., `powershell`, `neovim`, `git`, `bash`, `zsh`, `tmux`, `mcp`, `AI`, `windows_terminal`). There is **no module-lookup table** — the directory name *is* the module.
- Each package typically has a `setup.ps1` declaring `$scoop_pkgs`, `$winget_pkgs`, `$pip_pkgs`, `$pipx_pkgs`, `$psgallery_pkgs`, `$files`, `$files_copy`. `autosetup.ps1` dot-sources each `setup.ps1` and runs the install/link functions.
- Conventions live in the root `AGENTS.md` (code style: 1TBS; how to add a package manager to `autosetup.ps1`; how to ship a PowerShell module).
- There are **no unit tests**. "Validation" means things like: re-running `autosetup.ps1`, reloading the PowerShell profile, confirming symlinks, or manually exercising the changed config.

## Steps

### 1. Understand and discuss the task

1. Restate the task in your own words to confirm understanding.
2. Determine the **type of work**: bug, new feature, refactor, docs, chore, etc. (This informs the category later.)
3. Ask the user any clarifying questions needed to write a complete task. Use the `ask_user` tool. Typical gaps to probe:
   - Expected vs. actual behavior (for bugs)
   - Which package/module(s) it touches (e.g., `powershell`, `neovim`, `git`)
   - Scope boundaries (what is explicitly *out of scope*)
   - Acceptance criteria / definition of done
   - Any constraints (cross-platform Windows/Linux, backwards compatibility, specific tools to touch or avoid)
   - How the change should be **verified** (re-run setup, reload profile, symlink check, manual step)
4. Do **not** proceed to investigation until the task is clear enough to investigate.

### 2. Investigate "what needs to be done, and where" (via subagent)

Launch a fresh **general-purpose** subagent (via the Task tool) with **no prior conversation context** — build the prompt from scratch. This keeps the main conversation clean.

The subagent prompt must include:
- The **task description** as clarified in step 1
- The **task type** (bug/feature/refactor/etc.)
- The instruction to read the root `AGENTS.md` for conventions, and to treat each top-level directory as a package/module
- The **investigation goals** below

The subagent is responsible for:
1. Reading the root `AGENTS.md` for conventions (code style, `autosetup.ps1` wiring, module-shipping rules) and any package-local notes.
2. Using grep/glob/view to locate the work. **Scale the output to the task type**: for a narrow bug, the specific files / functions / `setup.ps1` variables / config keys at fault; for a broad sweep (rename, cross-module convention change), the **distinct surfaces** touched, one representative entry point each, and the grep/glob patterns that locate the rest — not a frozen enumeration.
3. Identifying the **package/module(s)** involved (top-level directory names).
4. Confirming the **root cause** (for bugs) by tracing the actual code/config — not guessing.
5. Sketching a **proposed approach** consistent with existing patterns (e.g., the `setup.ps1` variable convention, `linkConfigs`/`$files` symlinks, profile registration, 1TBS style).
6. Noting **validation implications**: how a future agent verifies the change (e.g., `pwsh -NoProfile -File autosetup.ps1 ...`, reload `$PROFILE`, confirm a symlink exists, exercise a keybinding), and any existing behavior that could regress.
7. Flagging any ambiguity or missing information the user still needs to resolve.
8. Assessing source complexity, deliverables, and any required decomposition or merge under the policy below.

The subagent must **return a structured report** containing:
- `affected` — representative entry points as `{file, symbol, why}`. For bugs, the specific site(s). For a broad sweep, **one canonical example per surface**, not an exhaustive inventory
- `searchStrategy` — the grep/glob patterns and stable anchors (function names, `setup.ps1` variables, config keys) that let the implementing agent **re-discover the full scope** later; replaces a frozen file enumeration
- `modules` — the package/module(s) involved (top-level directory names)
- `rootCause` — for bugs, the confirmed root cause with file:line references (or "n/a")
- `approach` — the proposed implementation approach
- `validation` — how to verify the change (commands / manual steps) and any regression risk
- `openQuestions` — anything still unclear
- `slices` — proposed parent/child drafts and real dependencies under the policy below, or "n/a"
- `sourceComplexity` — low, medium, or high, with a concise production-source rationale; flag scope that cannot yet
  be rated in `openQuestions`
- `deliverables` — each leaf's outcome, named consumer/use, and completion demonstration under the policy below
- `mergeProposals` — any necessary merges and approval details required by the policy below, or "n/a"

Reference stable anchors (symbols, `setup.ps1` variables, config keys), **never line numbers or occurrence counts** in the enumerated scope — the issue is implemented later against a moved tree.

If the subagent returns `openQuestions`, resolve them with the user (via `ask_user`) before drafting the issue.

#### Source complexity and decomposition

Judge actual production code, scripts, and shipped configuration: behavioral scope, component coupling, interfaces,
state/lifecycle changes, migrations/invariants, and unresolved design. Exclude test additions/updates, fixtures,
harnesses, matrix breadth, coverage, test runtime, and test-writing effort. Keep validation with each implementation
slice; never omit tests or create test-only slices merely because testing is large.

Docs, research, or test-only work with no production changes has low source complexity, not necessarily low effort.
Rate tracking parents by their aggregate requested source scope across children, not coordination overhead or a sum
of child ratings. Unknown scope is not automatically low or high: inspect the request and source, then clarify any
remaining uncertainty before assigning a rating.

Each implementation leaf must produce a concrete, independently usable or demonstrable outcome. Name its consumer/use
and completion demonstration. Valid outcomes include user behavior or an actually consumable API, CLI, library, or
artifact; documentation and research findings count for their respective task types. Prerequisites are allowed, but no
leaf may end as unused schema, scaffolding, or transport awaiting a later integration issue to become useful. Passing
tests/builds alone is not the feature deliverable. Avoid artificial file/layer/test splits.

Default to low/medium source complexity for implementation leaves:

- **Low** — a localized, well-understood behavioral/configuration change.
- **Medium** — one coherent bounded outcome across a small connected set of components, with clear contracts and
  manageable invariants.
- **High** — broad or tightly coupled behavior, interfaces, or state changes. Prefer smaller, complete low/medium
  functional slices. Use tracking-only parents for scope, completion, and children, not implementation assignments.
  Decompose into non-overlapping outcomes; reassess children recursively, using nested tracking parents where needed.

If a useful low/medium split is not possible, propose merging the necessary tasks. Explain exactly which tasks combine,
the usable outcome, the revised source complexity and rationale, and the tradeoff. Use `ask_user` to approve the
**specific merge and any complexity increase before adopting it or filing issues**. A higher-complexity leaf is allowed
only for that approved merged scope; record its actual rating, rationale, and user approval. Never downgrade the rating
to fit or treat approval as a blanket exception. If declined, revise toward another complete outcome or leave the split
unresolved.

Preserve full request coverage and real dependencies; independent children may proceed in parallel. Parent containment
is not a blocked-by dependency. Use no LOC, file-count, or time quotas. If uncertainty prevents a bounded estimate,
investigate or clarify; merge approval does not resolve design questions or justify a lower rating.

### 3. Search for duplicate and related issues

Before classifying and drafting, search the repo's existing issues (open **and** recently closed) so
you don't file a duplicate and so you can link genuinely related work. Use the affected files/modules
and key terms from step 2 to build the search.

```ps1
# Broad keyword search across open + closed issues (repo is inferred from cwd):
gh issue list --state all --search "<keywords>" --limit 30 `
  --json number,title,state,labels,url
```

Run a couple of searches with different terms (the symptom, the module name, the affected
file/`setup.ps1` variable). Repeat for every proposed child, including nested children. Reuse suitable existing issues
instead of duplicating their work; check whether an existing parent's children actually cover its remaining scope.

Then judge each hit:

- **Duplicate** — an existing issue already covers *the same task* (same root cause / same change).
  - **Inform the user** of the duplicate (number, title, state, URL) via chat, and **ask** — using
    `ask_user` — whether to stop (treat as duplicate) or proceed anyway (e.g., the existing one is
    stale or out of scope). Do **not** silently create a second copy.
  - If the user chooses to stop, do not create an issue; summarize the existing duplicate and finish.
- **Related** — a different but connected issue (a dependency, a parent epic, or adjacent work).
  - **Inform the user** of the related issue(s) in chat, and record them for linking in step 6.
  - Classify each relationship using the relationship types GitHub actually supports through `gh`:
    - **Blocked by** — the new issue can't be done until issue N is done -> `--blocked-by N`.
    - **Blocking** — issue N can't proceed until the new issue is done -> `--blocking N`.
    - **Parent / sub-issue** — the new issue is part of a larger tracked issue -> `gh issue edit
      <parent> --add-sub-issue <new>` (or `--parent` at create time).
    - GitHub has **no** generic "related" or "duplicate" relationship type, so for a plain
      association that isn't a dependency or hierarchy, reference it inline in the issue body
      (e.g., a "Related issues" bullet linking `#N`) instead of inventing a relationship.

### 4. Classify the task

Assign **exactly one** category from the fixed set below (these map 1:1 to GitHub labels and mirror the Conventional Commit types used in this repo):

| Category      | Use case                                        |
|---------------|-------------------------------------------------|
| `bug`         | Something is broken or behaves incorrectly      |
| `feature`     | New capability                                  |
| `refactor`    | Restructuring without behavior change           |
| `docs`        | Documentation changes                           |
| `chore`       | Maintenance, dependencies, cleanup              |
| `performance` | Speed/memory/efficiency improvements            |
| `tech-debt`   | Paying down accumulated shortcuts               |

Pick the **single** category that best fits (the primary type of work). Use the issue title's
Conventional Commit type as the tiebreaker.

**Additionally**, apply the cross-cutting `spike` label when the task is **investigation /
exploration only** — the work is to research, evaluate, prototype-and-throw-away, or answer a
question, and its deliverable does **not** change any code or docs in the repo. A spike's acceptance
criteria are findings/recommendations (e.g., "document whether X is feasible"), not a shipped change.
`spike` is added **in addition to** the single category (usually paired with `chore`; the category
still reflects the *kind* of follow-up work the spike informs). Do **not** apply `spike` to any task
whose definition of done includes editing code or documentation.

Every newly created child, including a child of an existing parent or a nested tracking parent, also needs the exact
`sub-issue` label and a native GitHub parent/sub-issue link.
A tracking parent gets that label only if it is also a child.

Every standalone issue, tracking parent, and child also needs exactly one of `complexity: low`, `complexity: medium`,
or `complexity: high`, matching its rating under the [source policy](#source-complexity-and-decomposition).
Complexity and hierarchy labels are metadata; they do not replace the category or change the `spike` rules.

### 5. Draft the issue and present it for acceptance

For a split request, draft the entire parent/child plan together. Keep the standalone draft path below; use separate
`tmp\triage-<guid>-<slice>.md` files for split drafts. Apply the review and mdview gates to every draft, including
tracking parents, and classify each under step 4. Show reused issue links, hierarchy, dependencies, and any merge
proposals or approvals from step 2 with the drafts.

1. Compose the issue **title** in Conventional Commit style: `<type>: <short description>` (e.g., `fix: statusline flickers on git pull`).
2. Compose the issue **body** with these sections (omit a section only if truly not applicable):
   - **Summary** — one or two sentences.
   - **Context / Background** — why this matters; the reported symptom or motivation. **For a narrow bug**, include a **small code/config snippet** of the current/problematic code (a handful of lines with a `file:line` reference) to make the problem concrete. **For a broad sweep**, describe the *pattern* and the surfaces involved rather than pasting a frozen snapshot or occurrence count.
   - **Affected files & modules** — for a narrow bug, the specific `file` -> `symbol` -> reason sites. For a broad sweep, the **surfaces** with one representative entry point each plus the **discovery command** that finds the rest (from `searchStrategy`), prefixed with a note: *"This is a starting map, not an exhaustive inventory — re-run the discovery searches below and treat their output as authoritative; occurrences may have been added since this issue was filed."* Name the package/module (top-level directory).
   - **Proposed approach** — the subagent's `approach`, plus root cause for bugs. Include a **small snippet** illustrating the change (a short before/after, or a minimal sketch of the new `setup.ps1` entry / function signature / config key) whenever it makes the intent clearer — keep it to a handful of lines, not full implementations. Respect repo conventions (1TBS, `pwsh`, double quotes, `setup.ps1` variable pattern).
   - **Acceptance criteria** — each leaf's outcome, consumer/use, and completion demonstration from `deliverables`,
     expressed as a checklist under the [decomposition policy](#source-complexity-and-decomposition).
   - **Source complexity** — each issue's actual rating and production-source rationale under the
     [decomposition policy](#source-complexity-and-decomposition), with any approved merge's scope and user approval.
     Tracking parents also state "tracking-only, not an implementation assignment" and explain their aggregate scope.
   - **Validation** — **always required.** Spell out how a future agent (or the user) verifies the change is done, since this repo has no unit tests:
     - The exact command(s) to run (e.g., `pwsh -NoProfile -ExecutionPolicy Bypass -File autosetup.ps1 <args>`, or reloading the profile with `. $PROFILE`).
     - Any **symlink / file-link checks** (e.g., confirm `$files`/`linkConfigs` produced the expected link).
     - Any **manual step** to exercise the change (e.g., open a new shell, trigger the keybinding, run the tool) and the expected result.
     - Existing behavior that must **not** regress, and how to confirm it.
   - **Out of scope** — what this task must not touch.
3. Write the draft to `tmp/triage-issue.md` (git-ignored) so the user can edit it directly. Show a chat summary with the
   proposed **title**, **category/label(s)** (including complexity and `spike` if applicable), and any **related issues
   to link** (from step 3) with their relationship type.
4. **Validate the draft with the `rubber-duck` agent (always).** Before presenting the issue to the user, launch a `rubber-duck` subagent (via the Task tool) and give it the full drafted issue plus enough context (task description, affected files, root cause) to check it. Ask it to catch: incorrect root-cause claims, wrong `file:line`/symbol references, flawed proposed approach, missing or infeasible acceptance criteria, and gaps in the validation steps. Incorporate its high-signal feedback into `tmp/triage-issue.md`, then re-read the file. If the rubber-duck flags a blocking problem you cannot resolve from the code, ask the user before proceeding.
   Review all parent/child drafts and merge proposals together against the
   [decomposition policy](#source-complexity-and-decomposition). Reject orphan integration work, missing usable
   outcomes, consumers or demonstrations, gaps/overlap, testing-derived sizing, unapproved above-medium leaves,
   unresolved design, and missing native links or labels. Match each merge's scope and actual rating to its approval.
5. **⛔ HARD RULE — ALWAYS open the draft in mdview before asking for acceptance. No exceptions.**
   The `ask_user` accept/edit/reject gate below MUST NOT be presented until `tmp/triage-issue.md` has
   been rendered in the mdview app for the user — a chat summary alone is never sufficient. Render it:
   ```pwsh
   & D:\mdview\target\release\mdview.exe tmp/triage-issue.md
   ```
   If the release binary is missing, build it (`cargo build --release -p mdview`) or fall back to
   `cargo run --release -p mdview -- tmp/triage-issue.md`, then continue. If mdview cannot be launched
   at all, say so explicitly and get the user's go-ahead before falling back to a chat-only review — do
   not silently skip it. **Re-open the draft in mdview again after any edit round** before re-presenting.
6. **Ask the user to accept, edit, or reject** using the `ask_user` tool (accept / edit / reject). If they choose "edit", let them edit `tmp/triage-issue.md` (and/or adjust the category) and wait for confirmation, then re-read the file and re-open it in mdview (per the hard rule above) before re-presenting.
   Require explicit acceptance of the whole reviewed plan before creating any issue. Scope changes after acceptance
   require re-review, reopening affected drafts, and renewed acceptance.

### 6. Create the GitHub issue — only if accepted

**Only run this step if the user accepted in step 5.** If rejected, delete the draft files and stop.

Use the bundled helper script — it derives the repo root, ensures every label exists (creating it if missing), extracts the title from the first `# ` heading, writes the body to a git-ignored temp file, creates the issue assigned to `@me`, links any dependency and parent relationships, and prints the title and URL:

```ps1
& .\.github\skills\triage\scripts\new_issue.ps1 `
  -Complexity <low|medium|high> -Draft tmp\triage-issue.md -Label <category>[,spike] `
  [-BlockedBy <n,...>] [-Blocking <n,...>] [-Parent <n>]
```

- Pass the accepted rating explicitly via required `-Complexity`. The helper adds its canonical label and rejects
  conflicting complexity labels in `-Label` before any GitHub calls; identical complexity labels are deduplicated.
- Pass the chosen category to `-Label`, adding `spike` to the label array when the task is
  investigation/exploration only (step 4).
- Pass related **dependency** issues via `-BlockedBy` / `-Blocking` (from step 3) to link them through
  GitHub's issue relationships at creation time.
- Pass `-Parent <n>` for every new child. The helper ensures/adds the `sub-issue` label and creates the native link with
  `--parent`; use the same path for existing parents and recursively nested children.
- Create accepted parents and prerequisites before children that need their issue numbers. To reuse an existing issue
  as a child, ensure/add its `sub-issue` label and attach it with `gh issue edit <parent> --add-sub-issue <existing>`.
- For accepted backfills or reused issues, read their current labels and source scope before rating under the
  [source policy](#source-complexity-and-decomposition). Use `gh issue edit --add-label` and `--remove-label` to add the
  chosen complexity label and remove only contradictory complexity labels. Preserve category, `spike`, `sub-issue`,
  and all unrelated labels; never replace the full label list.
- If creation or linking fails, stop and report any created URLs. Inspect GitHub and repair partial results before any
  retry; never blindly recreate an issue that may already exist.

Before reporting success, read back every created, reused, or backfilled issue's labels
(`gh issue view <n> --json labels,url`) and verify exactly one canonical complexity label matching the accepted rating.
Missing, conflicting, or multiple complexity labels fail verification; repair them without changing unrelated labels.
For children, read native hierarchy (`gh api repos/<owner>/<repo>/issues/<child>/parent` and the parent's paginated
`sub_issues` endpoint). Confirm accepted categories, exact `sub-issue` labels, hierarchy, and dependencies.
Body references alone do not establish a native relationship. Then report all issue URLs and linked relationships.

### 7. Cleanup

1. Delete the reviewed draft files and any temp body file.
2. Show a short summary: issue URL, title, assigned label(s), and any linked related issues.
