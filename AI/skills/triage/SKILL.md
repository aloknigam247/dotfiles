---
description: >-
  Triage a task, bug, or idea into a GitHub issue, or revise an existing issue. Investigate, check duplicates,
  draft, review, and obtain acceptance before publishing. Use for triage, create an issue, file an issue,
  turn this into a task, or rewrite this issue.
name: triage
---

# Triage: shared personal skill

Prepare an actionable issue for an implementer with no conversation history. Do not implement the task during triage.

## Load the repository policy

Resolve the target checkout and GitHub repository from the current working directory, not this skill's directory.
Read its applicable instructions, `.github\triage.md`, and guides for the affected areas.

The repository policy supplies category selection, domain-specific investigation and validation requirements, and any
special issue template. This skill owns the shared process below. Do not duplicate architecture, commands, or
conventions already defined in repository guides. If policy is missing or contradictory, clarify before drafting.

## Investigate and plan

1. Confirm the requested outcome, affected surfaces, actual versus expected behavior, constraints, and exclusions.
   Resolve ambiguous scope with `ask_user`.
2. Give a fresh general-purpose investigator the clarified task, target checkout, repository policy, and relevant
   guides. Request source-backed findings, not implementation. For a spike, map the questions rather than solving it.
3. Collect affected surfaces, representative file/symbol anchors, discovery searches, confirmed bug cause, proposed
   approach, consumer and completion demonstration, validation cases, source complexity, and unresolved questions.
   Include any child scopes, dependencies, and proposed merges. Resolve open questions before drafting.
4. Search open and closed issues using the symptom, symbols, and requested capability. Read candidate matches; repeat
   for every proposed child. Show duplicates with hyperlinks and ask whether to reuse, stop, or draft distinct work.
5. Keep the complete plan separate from issue bodies: titles, labels, ratings and rationale, native relationships,
   reused issues, and recorded merge approvals.

## Source complexity and decomposition

Assess production code, scripts, shipped configuration, interfaces, coupling, lifecycle, migrations, and invariants.
Do not rate by lines, file counts, time, test volume, fixtures, harnesses, coverage, or test runtime.

| Rating | Meaning |
|---|---|
| Low | Localized, well-understood change |
| Medium | One bounded outcome across connected components with manageable invariants |
| High | Broad or tightly coupled behavior beyond those bounds |

Default implementation leaves to low/medium. Each must name a usable outcome, its consumer, and a completion
demonstration. A consumable API, CLI, library, or artifact qualifies; unused scaffolding awaiting later integration
does not. Keep required tests with their implementation.

Use tracking-only parents for non-overlapping children that collectively cover the request. Reassess nested children,
reuse existing work, and keep independent work parallel. Rate parents by aggregate source scope, not coordination.
No production changes means low source complexity; do not split docs, research, or test-only work merely for size.

If a useful split requires merging beyond medium, explain the exact combined scope, outcome, actual rating, and
tradeoff. Obtain explicit approval for that merge and complexity increase before adopting it. Record the approval;
never downgrade a rating or treat approval as a blanket exception. Clarify uncertainty rather than guessing a rating.

## Draft the issue

Use a Conventional Commit-style title and the repository's category policy. The primary category follows the prefix:
`ci` maps to `chore`, `feat` to `feature`, `fix` to `bug`, and `perf` to `performance`; category-name prefixes map to
themselves. Keep labels in metadata, including exactly one `complexity: low`, `complexity: medium`, or
`complexity: high`. Every native child also needs `sub-issue`.

A spike produces findings without changing repository code or documentation. Use questions and decision criteria,
not implementation tests; the repository policy determines how its category labels combine.

Start the body with a short what-and-why paragraph, never a Summary heading. Use the title's heading set unless an
explicit tracking role or repository-specific template applies:

| Type | Headings, in order |
|---|---|
| Bug | Current behavior; Root cause; Proposed fix; Acceptance and validation |
| Docs | Documentation gap; Proposed update; Review criteria |
| Feature | Problem; Proposed solution; Acceptance and validation |
| Maintenance | Current problem; Proposed change; Behavior to preserve, when needed; Validation |
| Performance | Current performance; Proposed improvement; Measurement and success criteria |
| Spike | Questions to answer; Investigation scope; Deliverables and decision criteria |
| Tracking parent | Outcome; Done when; Decisions, only for shared rules |

Add Alternatives considered, Out of scope, or Risks only for actionable content. A tracking parent's Outcome starts
with "Tracking only — not an implementation assignment." Keep implementation and tests in its leaves, and express
child ordering through native dependencies rather than a body list.

State each requirement once. Prefer comparison tables, checklists, and scenario/expected-result test matrices.
Reference authoritative repository guidance instead of repeating it. Use stable symbols and discovery recipes for
broad changes, not frozen inventories. Keep a small diagnostic snippet for a narrow bug or a necessary fixture.
Replace copied source with verified immutable source links; do not paste full proposed test implementations.

Name affected existing tests, changed-behavior cases, exact meaningful oracles, and applicable validation commands.
New behavior checks must fail before the fix; preservation checks must pass before and after. Reference shared test
setup, but retain any unique constraints absent from the linked source. Never present proposed helpers as existing APIs.

## Diagrams

Add a diagram only when clearer than prose. Keep one unless Current and Proposed differ in shape.

| Change | Diagram |
|---|---|
| Classes, interfaces, inheritance, ownership | `classDiagram` |
| Data schema | `erDiagram` |
| Dependencies across modules | `flowchart LR`, one subgraph per module |
| Local fix in one function | None; table or small snippet |
| Order of calls across components | `sequenceDiagram` |
| Several branches or decisions | `flowchart LR` |
| States and transitions | `stateDiagram-v2` |

Label Current or Proposed and highlight the change. Use explicit fill, stroke, and text colors where supported.
Keep labels short, with no `#` or `{}` inside them. Flowchart label lines are at most 24 characters, split with
`<br/>`; use short module titles and pipe edge labels. Literal diagram fixtures use `text` fences, not rendered Mermaid.

## Review and acceptance

Write separate GUID-named drafts in the checkout's ignored `tmp` directory. Keep titles separate from publishable
bodies. Have a fresh independent rubber-duck reviewer check the drafts against the request and investigation.
If that reviewer is unavailable, report it and ask before substituting a review method.

Reject unsupported claims, missing requirements or edge cases, weak or infeasible tests, false dependencies,
incomplete child coverage, unused integration fragments, and unapproved high-complexity leaves.

For each issue, generate a GUID-named preview with this YAML frontmatter in order, followed immediately by the
complete, exact publishable body:

```yaml
---
repo: <owner/repo>
title: "<exact issue title>"
Complexity: <low|medium|high>
---
```

Compose previews directly from their body files; do not summarize the body or replace it with a link. The metadata
is preview-only and must not be included in the GitHub body.

Resolve findings, open the full plan and every issue preview in mdview, and present clickable issue links. Use
`ask_user` for explicit acceptance before publication. Regenerate and reopen edited previews; scope changes require
renewed review and acceptance. If mdview is unavailable, report the blocker and obtain approval before using a
chat-only preview.

## Relations and publication

Publish through `gh` with an explicit target repository and body file. For new issues, ensure accepted labels exist
and assign `@me`. Create parents before their new descendants. Read back every successful creation before proceeding.
Check native relationships before adding them; preserve an existing different parent rather than force-reparenting.

| Relationship | Native representation |
|---|---|
| Blocked by / blocking | `issues/<blocked>/dependencies/blocked_by`, with the blocker's database id |
| Parent / child | `issues/<parent>/sub_issues`, with the child's database id |

Use the REST paths under `repos/<owner>/<repo>/`. Read the child's `parent` endpoint and paginated relationship
lists; compare database ids, not bare issue numbers. An API failure or HTTP 422 proves nothing: continue only when
readback confirms the exact edge. On partial creation, report the URL and inspect before retrying; never create blindly.

Drop association-only "related", "see also", and "follow-up" links. Do not create relationship headings, child lists,
or metadata footers. Retain inline issue references only when needed to express a behavior owner or scope boundary.
Do not remove a parent/dependency declaration from an existing body until its native link is confirmed.

For existing issues, change only accepted fields. Add/remove specific metadata labels rather than replacing all labels.
Verify the final body, title, state, accepted labels, and native links against the accepted plan.
Report partial failures explicitly. Clean up only this task's temporary drafts after publication or rejection.

## Existing-issue rewrites

Snapshot the live body and metadata, and read relevant comments and linked decisions. Preserve meaningful qualifiers,
requirements, oracles, unresolved choices, normative scope, approval markers, and diagram meaning.
Do not silently choose between conflicting policies or claim current source implements a requested feature.

For requested compression, consolidate repetition and replace source/test dumps with verified references and complete
behavior matrices. Keep a disposition of removed sections for the reviewer; do not impose a word cap that drops content.
Formatting-only rewrites preserve examples and diagrams unless their modification is approved.

Give an independent judge the original, candidate, decisions, and dispositions. Revise until no substantive loss
remains, then use the acceptance gate above. Immediately before editing, confirm the live issue still matches the
snapshot; stop on concurrent changes. Publish the body file and read it back before reporting success.
