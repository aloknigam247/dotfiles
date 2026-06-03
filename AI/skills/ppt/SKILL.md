---
name: ppt
description: Use when the user wants to create, build, or generate a PowerPoint (.pptx) presentation / slide deck — "make a deck", "build a presentation", "turn these notes into slides". Produces a themed 16:9 .pptx with formatted text, tables, metric tiles, and diagrams/charts rendered from Mermaid, D2, draw.io, or Plotly and aligned beside the text.
---

# PowerPoint Builder

Build a polished, themed `.pptx` from a topic or an outline. Text and diagrams are
laid out together on a consistent 16:9 theme. Diagrams come from real engines
(Mermaid / D2 / draw.io / Plotly) rendered to PNG, or from editable native PPTX
shapes.

## Prerequisites

Tools are **not** auto-installed by this skill. At minimum you need Python + `python-pptx`; each
diagram engine adds its own tool. Full source/version table and per-engine notes:
**`reference/engines.md`**. If a tool is missing, `render_diagram.py` fails with the exact install
command.

## Workflow

1. **Gather intent.** Confirm with the user (use the ask tool, one question at a
   time): topic/title, audience, approximate slide count, visual style/theme, and
   any content/outline. If they have notes, build from those; otherwise draft an
   outline from the topic and proceed.

2. **Plan slides.** Sketch a slide list (title → agenda → content slides →
   summary). For each content slide decide: text-only, text + diagram, table, or
   metric tiles. Keep one idea per slide.

3. **Pick a diagram engine per visual** (see `reference/engines.md`):
   - architecture / flow / sequence → **Mermaid** (`*.mmd`)
   - clean node graphs / containers → **D2** (`*.d2`)
   - a diagram the user already has → **draw.io** (`*.drawio`)
   - data charts (bar/line/pie) → **Plotly** (`*.py` defining `fig`)
   - must stay editable in PowerPoint → **native shapes** via `Deck.node()`

4. **Render diagrams to PNG** into a working `img/` folder:
   ```ps1
   python scripts/render_diagram.py mermaid arch.mmd img/arch.png --scale 3
   ```
   Use `--scale 3` for crisp slides. Native shapes need no render step.

5. **Build the deck** with `scripts/pptlib.py` (`Deck` helper). Write a small
   build script that adds slides, text, tables, tiles, and places PNGs with
   `img_fit()` inside framed cards next to the text. API + copy-paste recipes:
   **`reference/layout.md`**.

6. **Verify visually — required.** python-pptx can save a file PowerPoint cannot
   open. Export slides to PNG via PowerPoint COM (snippet in `reference/layout.md`)
   and inspect them, or at least confirm the file opens. If it won't open, suspect
   the shadow gotcha below.

7. **Deliver** the `.pptx` path. Offer revisions (theme, slide count, 4:3).

## Theme

Default is Modern Minimal (slate + sky blue), 16:9. Override colors/fonts via `Deck(theme={...})` — keys
and examples in `reference/layout.md`. Match diagram colors to the deck (the
Mermaid theme in `assets/mermaid-theme.json` already does).

## Critical: shadow gotcha — do not regress

`shadow.inherit=False` inserts an empty `<a:effectLst/>`; appending a **second**
one makes XML that PowerPoint refuses to open (python-pptx still saves it). Always
add shadows through `Deck.rect(..., shadow=True)`, which reuses the existing
element. This is the first thing to check if a generated deck won't open.

## Files

| Path | Purpose |
|---|---|
| `scripts/pptlib.py` | `Deck` helper: theme, text, shapes, tables, `img_fit` |
| `scripts/render_diagram.py` | render Mermaid/D2/draw.io/Plotly source → PNG |
| `assets/mermaid-theme.json` | Mermaid theme matching the deck palette |
| `reference/engines.md` | engines, prerequisites, install sources, per-engine notes |
| `reference/layout.md` | pptlib API + layout recipes + verification |

## Cleanup

Build artifacts (`img/`, working `*.mmd`/`*.d2`, `preview/`) are scratch — put them
in a temp working dir, not the repo, and remove them after delivering. The `.pptx`
is self-contained (images are embedded), so nothing else needs to ship with it.
