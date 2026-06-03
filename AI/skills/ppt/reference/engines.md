# Diagram & Chart Engines

Every engine renders source → **PNG**, which the deck step inserts with
`Deck.img_fit()`. Pick the engine that fits the picture you need.

| Engine | Best for | Source file | Renders to PNG via |
|---|---|---|---|
| **Mermaid** | flowcharts, sequence, gantt, ER | `*.mmd` | `mmdc` + headless Chrome |
| **D2** | clean modern node graphs, containers | `*.d2` | `d2` CLI (native) |
| **draw.io** | hand-drawn / pre-existing diagrams | `*.drawio` | draw.io desktop CLI |
| **Plotly** | data charts: bar, line, pie, scatter | `*.py` (defines `fig`) | `plotly` + `kaleido` |
| **Native PPTX** | editable boxes & arrows, no deps | — (build inline) | `pptlib.Deck.node()` |

Render anything except native shapes with the dispatcher:

```pwsh
python scripts/render_diagram.py mermaid in.mmd img/arch.png --scale 3
python scripts/render_diagram.py d2      in.d2  img/graph.png
python scripts/render_diagram.py drawio  in.drawio img/legacy.png
python scripts/render_diagram.py plotly  chart.py  img/sales.png
```

## Prerequisites (install once — NOT auto-installed)

This skill assumes its tools are already present. In this dotfiles repo they are
declared in `AI/setup.ps1` and installed by `autosetup.ps1`. Manual sources:

| Tool | Source / registry | Install command | Verify |
|---|---|---|---|
| `python-pptx` (+ Pillow, lxml) | PyPI | `pip install python-pptx` | `python -c "import pptx"` |
| `mmdc` | npm registry | `npm install -g @mermaid-js/mermaid-cli` | `mmdc --version` |
| headless Chrome (for mmdc) | Chrome-for-Testing CDN, cached in `~/.cache/puppeteer` | `npx puppeteer browsers install chrome-headless-shell` | folder exists |
| `d2` | scoop `main` bucket · winget `Terrastruct.d2` · GitHub releases | `scoop install d2` | `d2 --version` |
| draw.io desktop | winget `JGraph.Draw` · GitHub `jgraph/drawio-desktop` releases | `winget install JGraph.Draw` | `drawio --help` |
| `plotly` + `kaleido` | PyPI | `pip install plotly kaleido` | `python -c "import plotly,kaleido"` |

> **Verified live:** only the **Mermaid** path has been run end-to-end in this
> environment. The D2, draw.io, and Plotly commands follow each tool's standard
> CLI but were not executed here — confirm them on first real use.

## Engine notes

### Mermaid
- `mmdc` cannot render alone; it drives a headless Chrome that **puppeteer**
  downloads out-of-band into `~/.cache/puppeteer`. Without it you get
  *"Could not find Chrome"*. `render_diagram.py` auto-discovers that browser and
  pins `mmdc` to it via a temp `-p` config, so no hardcoded version path is needed.
- Theme lives in `assets/mermaid-theme.json` (slate + sky blue to match the deck).
- Use `-s/--scale 3` for crisp slides; transparent background blends into cards.

### D2
- Renders PNG natively (no browser). `--scale` and `--pad` control size/margin.
- Great when you want a cleaner look than Mermaid for boxes-and-arrows topologies.

### draw.io
- Uses the desktop app in headless export mode (`--export`). On a server with no
  display you may need to prefix with a virtual framebuffer; on Windows desktop it
  works directly. Good for diagrams a human already drew in draw.io.

### Plotly
- The dispatcher `exec`s your `*.py` and expects a module-level **`fig`**
  (a `plotly.graph_objects.Figure`). It exports via `kaleido`.
- Style the figure to match the deck (navy text, teal/blue series) for cohesion.

### Native PPTX shapes
- No external tool. Build editable diagrams directly:
  ```python
  d = Deck(); s = d.slide()
  a = d.node(s, 1, 2, 2.4, 1, "API Gateway")
  b = d.node(s, 5, 2, 2.4, 1, "Order Service")
  d.connector(s, 3.4, 2.5, 5.0, 2.5)
  ```
- Best when the audience must edit the diagram afterwards inside PowerPoint.
