---
name: ppt
description: Use when the user wants to create, build, or generate a PowerPoint (.pptx) presentation / slide deck — "make a deck", "build a presentation", "turn these notes into slides". Produces a themed 16:9 .pptx with formatted text, tables, metric tiles, and diagrams and charts built as native, editable PowerPoint objects with a modern look.
---

# PowerPoint Builder

Build a polished, themed `.pptx` from a topic or an outline. Text, tables, diagrams and charts are
laid out together on a consistent 16:9 theme. Every diagram and chart is built from native
PowerPoint objects — shapes, connectors, tables and charts — so it stays editable. Never insert a
diagram or chart as an image.

## Prerequisites

Python with `python-pptx` builds the deck; nothing else is needed. Verification (step 5) is
Windows-only: it drives PowerPoint through `pywin32`.

## Workflow

1. **Gather intent.** Confirm with the user (use the ask tool, one question at a
   time): topic/title, audience, approximate slide count, visual style/theme, and
   any content/outline. If they have notes, build from those; otherwise draft an
   outline from the topic and proceed.

2. **Plan slides.** Sketch a slide list (title → agenda → content slides →
   summary). For each content slide decide: text-only, text + diagram or chart,
   table, or metric tiles. Keep one idea per slide.

3. **Build each visual natively** with the `Deck` builder for its type. Builders lay the diagram out
   automatically from its data and apply the modern style in **`reference/diagrams.md`**.

   | Diagram or chart | Builder |
   |---|---|
   | Flowchart | `flowchart()` |
   | Sequence diagram | `sequence()` |
   | Class diagram | `class_diagram()` |
   | State diagram | `state_diagram()` |
   | ER diagram | `er_diagram()` |
   | Use case diagram | `use_case()` |
   | Software architecture (nested containers) | `architecture()` |
   | Agent flow | `agent_flow()` |
   | Event modeling | `event_model()` |
   | User journey | `user_journey()` |
   | Block diagram | `block()` |
   | Gantt chart | `gantt()` |
   | Timeline | `timeline()` |
   | Mind map | `mind_map()` |
   | Org chart | `org_chart()` |
   | Tree view | `tree_view()` |
   | Quadrant chart | `quadrant()` |
   | Venn diagram | `venn()` |
   | Sankey diagram | `sankey()` |
   | Bar & line chart | `bar_line()` |
   | Area, pie, doughnut, radar chart | `chart()` with kind `area`, `pie`, `doughnut`, `radar` |
   | Scatter chart | `scatter()` |
   | Bubble chart | `bubble()` |
   | Box plot | `box_plot()` |
   | Histogram | `histogram()` |
   | Heatmap | `heatmap()` |
   | Sunburst chart | `sunburst()` |
   | Candlestick chart | `candlestick()` |

   Any other diagram type: compose it from `node()`, `link()`, `table()` and `chart()` in the same
   style.

   - Text stays at 11 pt or larger. Builders never shrink text: if a diagram doesn't fit, they try
     the other direction, then raise "split the diagram" — split it across slides.
   - Keep a diagram to 40 nodes or fewer.
   - Pass layout hints (`direction`, `rank`, `groups`, `pos`) only when the automatic layout needs
     help.

4. **Build the deck** with `scripts/pptlib` (`Deck` helper). Write a small build script that adds
   slides, text, tables (`table()`), tiles, the visuals from step 3, and photos or logos with
   `img_fit()`. API + copy-paste recipes: **`reference/layout.md`** and **`reference/diagrams.md`**.

5. **Verify — required where PowerPoint is available.** python-pptx can save a file PowerPoint
   cannot open, and text metrics are estimates. Run:
   ```ps1
   python scripts/com_check.py deck.pptx preview/ --json preview/report.json
   ```
   It opens the deck read-only without a window, exports every slide to PNG, and reports text
   overflow, overlapping shapes, unglued connectors and missing alt text. Fix every finding, then
   look at the PNGs. It never closes PowerPoint, so it is safe while the user has decks open.
   Without PowerPoint, at least confirm the file opens.

6. **Deliver** the `.pptx` path. Offer revisions (theme, slide count, 4:3).

## Theme

Default is Modern Minimal (slate + sky blue), 16:9. Override colors/fonts via `Deck(theme={...})` —
keys and examples in `reference/layout.md`. Diagrams and charts take their colours from the theme
`palette`, so they always match the deck.

## Critical: shadow gotcha — do not regress

`shadow.inherit=False` inserts an empty `<a:effectLst/>`; appending a **second**
one makes XML that PowerPoint refuses to open (python-pptx still saves it). Always
add shadows through `Deck.rect(..., shadow=True)`, which reuses the existing
element. This is the first thing to check if a generated deck won't open.

## Files

| Path | Purpose |
|---|---|
| `scripts/pptlib/` | `Deck` helper: theme, text, shapes, tables, charts, diagram builders, layout engine |
| `scripts/com_check.py` | verify a deck through PowerPoint: slide PNGs + layout findings |
| `reference/layout.md` | `Deck` API, layout recipes, verification |
| `reference/diagrams.md` | modern diagram style and every diagram/chart builder |
| `tests/` | self-test, fixtures and layout benchmark (`python tests/selftest.py`) |

## Cleanup

Build artifacts (build scripts, `preview/`) are scratch — put them in a temp working dir, not the
repo, and remove them after delivering. The `.pptx` is self-contained, so nothing else needs to ship
with it.
