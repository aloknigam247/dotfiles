# pptlib API & Layout Cookbook

`scripts/pptlib.py` wraps python-pptx for themed **16:9** decks. Import it and
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
card_border, subtle, font, mono`. Each color key is also exposed as an uppercase
`RGBColor` attribute (e.g. `d.NAVY`, `d.ACCENT`) for use in `fill=`/`color=`.

## Core methods

| Method | Purpose |
|---|---|
| `slide()` | add a blank slide |
| `header(s, kicker, title, num)` | standard slide chrome: bg, accent bar, title, footer |
| `footer(s, num, label)` | footer strip only |
| `rect(s, x, y, w, h, fill=, line=, shape=, shadow=)` | a shape; `shadow=True` is safe (see note) |
| `node(s, x, y, w, h, text, ...)` | labelled rounded box for native diagrams |
| `connector(s, x1, y1, x2, y2, color=, width=)` | straight connector line |
| `textbox(s, x, y, w, h, anchor=)` | returns a text frame |
| `para(tf, first=, align=, space_before=, space_after=)` | add a paragraph |
| `run(p, text, size=, color=, bold=, italic=, mono=)` | add a styled run |
| `bullet(tf, text, level=, glyph=, gcolor=, ...)` | a bulleted paragraph |
| `img_fit(s, path, bx, by, bw, bh, align=, valign=)` | insert image scaled to fit a box, aspect-preserved |
| `save(path)` | write the .pptx |

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

**Table:** use `s.shapes.add_table(...)` then color header row `d.NAVY` and
alternate body rows `d.WHITE`/`d.PANEL`; set `tblPr` `firstRow`/`bandRow` to `0`
to suppress the default banding.

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
