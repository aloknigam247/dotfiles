"""Development harness for review.nvim.

Drives a headless Neovim instance loaded with the plugin and provides helpers
to query state. See D:/dotfiles/neovim/TEST_HARNESS.md for the general pattern.
"""
import sys
from pathlib import Path

import pynvim

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")  # type: ignore
    sys.stderr.reconfigure(encoding="utf-8")  # type: ignore

ROOT = Path(__file__).resolve().parent.parent
DOTFILES = Path("D:/dotfiles")
MINIMAL_INIT = ROOT / "tests" / "minimal_init.lua"
FIXTURE = ROOT / "tests" / "fixtures" / "sample_comments.json"


class Harness:
    def __init__(self):
        self.nvim: pynvim.Nvim = None  # type: ignore

    def start(self):
        args = ["nvim", "--embed", "--headless", "-n", "-u", str(MINIMAL_INIT)]
        self.nvim = pynvim.attach("child", argv=args)
        # cwd = dotfiles root so review.json's "neovim/review/..." paths resolve
        self.nvim.command(f"cd {DOTFILES.as_posix()}")
        return self

    def close(self):
        if self.nvim:
            try:
                self.nvim.command("qall!")
            except Exception:
                pass
            try:
                self.nvim.close()
            except Exception:
                pass
            self.nvim = None  # type: ignore

    # --- input ---
    def cmd(self, c):
        self.nvim.command(c)

    def exec_lua(self, code):
        return self.nvim.exec_lua(code)

    def lua(self, expr):
        return self.nvim.exec_lua(f"return ({expr})")

    def wait(self, ms=50):
        self.exec_lua(f"vim.wait({ms})")

    # --- state ---
    def current_buf(self):
        return self.nvim.api.get_current_buf().handle

    def current_win(self):
        return self.nvim.api.get_current_win().handle

    def cursor(self):
        return tuple(self.nvim.api.win_get_cursor(0))

    def buf_name(self, bufnr=0):
        if bufnr == 0:
            bufnr = self.current_buf()
        return self.nvim.api.buf_get_name(bufnr)

    def buf_lines(self, bufnr=0):
        if bufnr == 0:
            bufnr = self.current_buf()
        return list(self.nvim.api.buf_get_lines(bufnr, 0, -1, False))

    def windows(self):
        result = []
        for w in self.nvim.api.list_wins():
            cfg = self.nvim.api.win_get_config(w)
            buf = self.nvim.api.win_get_buf(w)
            result.append({
                "win": w.handle,
                "buf": buf.handle,
                "relative": cfg.get("relative", ""),
                "width": cfg.get("width"),
                "height": cfg.get("height"),
                "title": cfg.get("title"),
            })
        return result

    def floats(self):
        return [w for w in self.windows() if w["relative"]]

    def diagnostics(self, bufnr=None):
        if bufnr is None:
            bufnr = self.current_buf()
        return self.exec_lua(f'''
            local ns = vim.api.nvim_get_namespaces().review_diag
            if not ns then return {{}} end
            local diags = vim.diagnostic.get({bufnr}, {{ namespace = ns }})
            local out = {{}}
            for _, d in ipairs(diags) do
                out[#out + 1] = {{
                    lnum = d.lnum, col = d.col,
                    end_lnum = d.end_lnum, end_col = d.end_col,
                    severity = d.severity, message = d.message,
                    user_data = d.user_data,
                }}
            end
            return out
        ''')

    def bg_extmarks(self, bufnr=None):
        if bufnr is None:
            bufnr = self.current_buf()
        return self.exec_lua(f'''
            local ns = vim.api.nvim_get_namespaces().review_bg
            if not ns then return {{}} end
            return vim.api.nvim_buf_get_extmarks({bufnr}, ns, 0, -1, {{ details = true }})
        ''')

    def hl(self, name):
        return self.exec_lua(
            f'return vim.api.nvim_get_hl(0, {{ name = "{name}", link = false }})'
        )

    def title_text(self, win_cfg):
        title = win_cfg.get("title")
        if not title:
            return ""
        if isinstance(title, str):
            return title
        return "".join(c[0] if isinstance(c, list) else str(c) for c in title)

    def invoke_keymap(self, lhs, mode="n", buf=0):
        """Invoke a buffer-local keymap callback directly (avoids feedkeys flakiness)."""
        return self.exec_lua(f'''
            for _, m in ipairs(vim.api.nvim_buf_get_keymap({buf}, "{mode}")) do
                if m.lhs == "{lhs}" and m.callback then
                    m.callback()
                    return true
                end
            end
            return false
        ''')

    def setup_review(self, fixture_path=None):
        """Initialize the plugin with the file provider pointed at the given fixture."""
        path = (fixture_path or FIXTURE).as_posix()
        self.exec_lua(f'''
            local review = require("review")
            local file_provider = require("review.providers.file")
            review.setup({{
                providers = {{ file_provider.new({{ path = "{path}" }}) }},
            }})
        ''')

    def find_buf_by_name(self, needle):
        return self.exec_lua(f'''
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_get_name(b):find("{needle}") then return b end
            end
            return nil
        ''')

    def dump(self, label=""):
        print(f"\n=== {label} ===")
        print(f"cursor: {self.cursor()}  buf: {self.current_buf()}  name: {Path(self.buf_name()).name}")
        wins = self.windows()
        floats = [w for w in wins if w["relative"]]
        print(f"windows: {len(wins)} (floats: {len(floats)})")
        for w in floats:
            t = self.title_text(w)
            print(f"  float win={w['win']} buf={w['buf']} {w['width']}x{w['height']} title={t!r}")
        diags = self.diagnostics()
        print(f"diagnostics: {len(diags)}")
        for d in diags[:5]:
            sev = {1: "ERROR", 2: "WARN", 3: "INFO", 4: "HINT"}.get(d["severity"], "?")
            msg = (d["message"] or "")[:60].replace("\n", " ")
            print(f"  line {d['lnum']+1} [{sev}] {msg}")
