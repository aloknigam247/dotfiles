"""
render_diagram.py - render a diagram/chart source file to PNG for insertion into a deck.

One dispatcher over every supported engine so the deck-build step stays uniform:
all it ever does is point img_fit() at a PNG.

    python render_diagram.py <engine> <input> <output.png> [--scale N]

engine: mermaid | d2 | drawio | plotly

  mermaid  input=*.mmd   -> mmdc (+ headless Chrome from the puppeteer cache)
  d2       input=*.d2    -> d2 CLI
  drawio   input=*.drawio-> draw.io desktop CLI (headless export)
  plotly   input=*.py    -> runs the script; it must expose `fig` (a plotly Figure)

Prerequisites are NOT auto-installed - see reference/engines.md. This script only
checks that the required tool is on PATH and fails loudly with the fix if not.

Native PPTX shapes have no render step; build them directly with pptlib.Deck.node().
"""
import argparse
import glob
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.normpath(os.path.join(HERE, "..", "assets"))


def die(msg, fix=None):
    sys.stderr.write("ERROR: " + msg + "\n")
    if fix:
        sys.stderr.write("FIX:   " + fix + "\n")
    sys.exit(1)


def need(tool, fix):
    path = shutil.which(tool)
    if not path:
        die(f"'{tool}' is not on PATH.", fix)
    return path


def find_headless_chrome():
    """Locate the newest chrome-headless-shell puppeteer downloaded, or None."""
    base = os.path.join(os.path.expanduser("~"), ".cache", "puppeteer",
                        "chrome-headless-shell")
    hits = glob.glob(os.path.join(base, "*", "chrome-headless-shell-*",
                                  "chrome-headless-shell*"))
    hits = [h for h in hits if h.endswith((".exe", "shell"))]
    return sorted(hits)[-1] if hits else None


def render_mermaid(src, out, scale):
    mmdc = need("mmdc", "npm install -g @mermaid-js/mermaid-cli")
    theme = os.path.join(ASSETS, "mermaid-theme.json")
    cmd = [mmdc, "-i", src, "-o", out, "-b", "transparent", "-s", str(scale)]
    if os.path.exists(theme):
        cmd += ["-c", theme]
    chrome = find_headless_chrome()
    tmp = None
    if chrome:
        # Pin mmdc to the cached browser; mmdc's bundled puppeteer-core often
        # expects a different Chrome build and otherwise errors "Could not find Chrome".
        fd, tmp = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w") as f:
            f.write('{"executablePath": %s, "args": ["--no-sandbox"]}'
                    % _json_str(chrome))
        cmd += ["-p", tmp]
    try:
        run(cmd)
    finally:
        if tmp and os.path.exists(tmp):
            os.remove(tmp)


def render_d2(src, out, scale):
    d2 = need("d2", "scoop install d2   (or: winget install Terrastruct.d2)")
    # D2 renders PNG natively; --pad keeps a small transparent margin.
    run([d2, f"--scale={scale}", "--pad=20", src, out])


def render_drawio(src, out, scale):
    exe = shutil.which("drawio") or shutil.which("draw.io")
    if not exe:
        die("'drawio' is not on PATH.",
            "winget install JGraph.Draw  (then reopen the shell)")
    run([exe, "--export", "--format", "png", "--scale", str(scale),
         "--transparent", "--output", out, src])


def render_plotly(src, out, scale):
    # The script must define a module-level `fig`. We exec it then export with kaleido.
    try:
        import plotly.io as pio  # noqa: F401
    except ImportError:
        die("plotly is not installed.", "pip install plotly kaleido")
    ns = {"__name__": "__diagram__", "__file__": os.path.abspath(src)}
    with open(src, "r", encoding="utf-8") as f:
        code = f.read()
    exec(compile(code, src, "exec"), ns)
    fig = ns.get("fig")
    if fig is None:
        die(f"{src} did not define a module-level `fig` (a plotly Figure).")
    try:
        fig.write_image(out, scale=scale)
    except Exception as e:  # kaleido missing or failed
        die(f"plotly export failed: {e}", "pip install kaleido")


def _json_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def run(cmd):
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout)
        sys.stderr.write(res.stderr)
        die(f"render command failed ({res.returncode}): {' '.join(cmd)}")


ENGINES = {"mermaid": render_mermaid, "d2": render_d2,
           "drawio": render_drawio, "plotly": render_plotly}


def main():
    ap = argparse.ArgumentParser(description="Render a diagram source to PNG.")
    ap.add_argument("engine", choices=sorted(ENGINES))
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--scale", type=float, default=3,
                    help="Render scale / DPI multiplier (default 3 for crisp slides).")
    a = ap.parse_args()
    if not os.path.exists(a.input):
        die(f"input not found: {a.input}")
    os.makedirs(os.path.dirname(os.path.abspath(a.output)), exist_ok=True)
    ENGINES[a.engine](a.input, a.output, a.scale)
    if not os.path.exists(a.output):
        die("render reported success but produced no output file.")
    print(f"OK  {a.engine}  ->  {a.output}")


if __name__ == "__main__":
    main()
