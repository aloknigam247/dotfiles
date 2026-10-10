# pptlib API & Layout Cookbook

`scripts/pptlib/` (a package) wraps python-pptx for themed **16:9** decks. Import it and
drive a `Deck`. All positions are in **inches**; the canvas is 13.333 × 7.5.

```python
import sys; sys.path.insert(0, "scripts")
from pptlib import Deck
d = Deck()                       # default Modern Minimal (slate + sky blue)
s = d.slide()                    # blank slide
d.header(s, "Architecture", "System Overview", 3)   # kicker, title, page number
d.save(r"D:\out\Deck.pptx")
```

## Theme

Override any color (hex, no `#`) or font:

```python
d = Deck(theme={"accent": "E11D48", "accent2": "7C3AED", "font": "Calibri"})
```

Keys: `navy, navy_dk, accent, accent2, light, white, text, muted, warn, panel,
card_border, subtle, line, font, mono, palette`. Each color key is also exposed as an uppercase
`RGBColor` attribute (e.g. `d.NAVY`, `d.ACCENT`) for use in `fill=`/`color=`. `line` colours
connectors. `palette` is six hex colours (default: `accent`, `accent2`, `warn`, then emerald, rose
and violet); it is written into the presentation theme, so charts and diagram node kinds use it.

## Core methods

| Method | Purpose |
|---|---|
| `slide()` | add a blank slide |
| `header(s, kicker, title, num)` | standard slide chrome: bg, accent bar, title, footer |
| `footer(s, num, label)` | footer strip only |
| `rect(s, x, y, w, h, fill=, line=, shape=, shadow=)` | a shape; `shadow=True` is safe (see note) |
| `node(s, x, y, w, h, text, ..., kind=, name=)` | labelled box; `kind=` gives the modern diagram style |
| `styled_node(s, x, y, w, h, text, kind=, size=, prst=, ...)` | a node in the style of its kind |
| `link(s, src, dst, label, src_site=, dst_site=, via=, route=, ...)` | connector glued to two shapes |
| `label(s, cx, cy, text, size=)` | text chip on the background colour (edge labels) |
| `ports(sp, top, right, bottom, left)` | more connection sites per side (rect, roundRect, hexagon) |
| `measure(text, size=, bold=)`, `wrap(text, max_w, ...)` | text width (inches) in the deck font |
| `text_size(text, size=, max_w=)`, `fit_shape(text, prst, size=)` | text block / shape sizes |
| `alt_text(shape, text)`, `group(s, shapes, name=, alt=)` | alt text; group shapes with alt text |
| `connector(s, x1, y1, x2, y2, color=, width=)` | straight connector line |
| `textbox(s, x, y, w, h, anchor=)` | returns a text frame |
| `para(tf, first=, align=, space_before=, space_after=)` | add a paragraph |
| `run(p, text, size=, color=, bold=, italic=, mono=)` | add a styled run |
| `bullet(tf, text, level=, size=, color=, bold=, ...)` | a natively-bulleted paragraph |
| `table(s, x, y, w, h, headers, rows, col_widths=, col_align=, alt=, ...)` | a themed native table |
| `chart(s, kind, x, y, w, h, categories, series, title=, alt=, ...)` | a native editable chart (bar/column/line/pie/area/area_stacked/doughnut/radar) |
| `bar_line()`, `scatter()`, `bubble()`, `histogram()`, `heatmap()`, `candlestick()`, `box_plot()`, `sunburst()` | native charts in the modern style (`pptlib/charts.py`) |
| `img_fit(s, path, bx, by, bw, bh, align=, valign=, alt=)` | insert image scaled to fit a box, aspect-preserved |
| `save(path)` | write the .pptx |

**Glued links:** `link()` draws a connector glued to both shapes, so it follows them when they
move. Routes are right-angled with at most five segments (PowerPoint's limit); a longer route raises
"split the diagram or add layout hints". Name diagram shapes `Node: ...`, labels `Label: ...` and
frames `Container: ...` (`node(kind=)`, `label()` and `link()` do) — the verifier checks them.
```python
a = d.node(s, 1.0, 2.0, 1.8, 0.6, "Order placed", kind="start")
b = d.node(s, 4.0, 2.0, 1.8, 0.8, "Paid?", kind="decision")
d.link(s, a, b, "next")
```

## Recipes

**Text beside a diagram (the most common slide):**
```python
s = d.slide(); d.header(s, "Architecture", "System Overview", 3)
tf = d.textbox(s, 0.9, 2.0, 5.0, 4.5)
d.bullet(tf, "API Gateway fronts all traffic.", first=True)
d.bullet(tf, "Services scale independently.")
card = d.rect(s, 6.25, 1.95, 6.45, 4.75, fill=d.WHITE,
              line=d.CARD_BORDER, shadow=True)   # framed image card
d.img_fit(s, "img/arch.png", 6.35, 2.2, 6.25, 4.2)
```

**Metric tiles:**
```python
x = 0.9
for big, label in [("6","Stages"), ("100%","Tested"), ("<15m","Lead time")]:
    d.rect(s, x, 5.0, 2.78, 1.45, fill=d.NAVY, shadow=True)
    d.run(d.para(d.textbox(s, x, 5.2, 2.78, 0.9, "middle"), True, align="center"),
          big, size=30, color=d.WHITE, bold=True)
    x += 3.0
```

**Table:** `Deck.table()` builds a native, editable table with a themed navy header and
`WHITE`/`PANEL` body banding. It suppresses the built-in table-style banding (whose colors come from
the template theme, not the deck palette) and colors every cell explicitly.
```python
d.table(s, 0.9, 2.0, 6.0, 2.5,
        ["Stage", "Owner", "Status"],
        [["Build", "CI", "Green"], ["Test", "QA", "Green"], ["Ship", "Ops", "Pending"]],
        col_widths=[2.5, 2.0, 1.5], col_align=["left", "center", "right"])
```

**Chart (native, editable):** `Deck.chart()` adds a real PowerPoint chart (data stays editable via
Edit Data) for `bar`, `column`, `line`, `pie`, `area`, `area_stacked`, `doughnut` and `radar`, in
the modern style (palette colours, light gridlines, no border). Each series is a `(name, values)`
pair; `pie` and `doughnut` take exactly one series.
```python
d.chart(s, "column", 7.2, 2.0, 5.0, 3.5,
        ["Q1", "Q2", "Q3", "Q4"],
        [("Revenue", (10, 14, 9, 16)), ("Cost", (6, 7, 8, 9))],
        title="Revenue vs Cost")
```
For chart types python-pptx can't express (scatter, complex layouts), render with Plotly to a PNG
(`reference/engines.md`) and place it with `img_fit()` instead.

## ⚠️ Shadow gotcha (do not regress)

`shadow.inherit=False` already inserts an empty `<a:effectLst/>`. Adding a
**second** `effectLst` yields schema-invalid XML that **PowerPoint refuses to
open** (python-pptx tolerates it, so it saves fine but won't open). `rect(...,
shadow=True)` reuses the existing element — always go through it; never append a
fresh `effectLst`.

## Verifying a deck

python-pptx can save a file PowerPoint can't open, so verify visually:

```pwsh
$pp = New-Object -ComObject PowerPoint.Application
$deck = $pp.Presentations.Open("D:\out\Deck.pptx")
$i = 1; foreach ($sl in $deck.Slides) { $sl.Export("preview\s$i.png","PNG",1600,900); $i++ }
$deck.Close(); $pp.Quit()
```

If `Open` throws *"PowerPoint could not open the file"*, suspect duplicate
`effectLst` (the shadow gotcha) or a stray locked POWERPNT process.
