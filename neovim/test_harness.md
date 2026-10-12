# Neovim Plugin Test Harness

A guide to building a Python-based development harness for Neovim plugins that lets you drive a headless Neovim instance, query state, and verify behavior without writing a full test suite.

## When to Use This

Use a harness when:

- You're developing a plugin and want to verify changes before asking a human to test
- Manual reproduction in a live editor is slow (reload plugin, open files, hit keys, check state)
- You need to check things that are hard to see visually (extmark positions, highlight group assignments, diagnostic severities, window configs)

Skip it when:

- The feature is purely visual (font rendering, exact pixel layout) — you need a real terminal
- The plugin has few interactive behaviors (a small formatter, a simple colorizer)

This harness is a **development aid**, not a test suite. It's intended to be run during active development, not in CI.

## Prerequisites

- Python 3.8+ (Windows: install from python.org or use scoop)
- `pip install pynvim`
- Neovim 0.10+ on PATH (for `vim.diagnostic.config` per-namespace support)

Verify:

```powershell
python --version
python -c "import pynvim; print(pynvim.__version__)"
nvim --version | Select-Object -First 1
```

## Architecture

```
┌─────────────────────┐           msgpack-rpc             ┌─────────────────┐
│  harness.py         │ ←───────────────────────────────→ │  nvim --embed   │
│  (pynvim client)    │                                   │  --headless     │
│                     │                                   │                 │
│  .cmd(":edit foo")  │                                   │  runs plugin,   │
│  .exec_lua(...)     │                                   │  loads init,    │
│  .keys("]r")        │                                   │  processes RPC  │
│  .diagnostics()     │                                   │                 │
└─────────────────────┘                                   └─────────────────┘
```

- `nvim --embed --headless` starts Neovim with no UI but with stdin/stdout as an RPC channel
- `pynvim.attach("child", argv=[...])` spawns nvim as a subprocess and connects over that channel
- Every nvim API call (`nvim.api.*`, `nvim.exec_lua`, `nvim.command`) is a synchronous RPC request

No UI events are captured by default — state queries only. To capture rendered output (borders, grid cells, highlight IDs per cell) you additionally call `nvim.ui_attach(cols, rows, ...)` and subscribe to `redraw` notifications. That's more complex; state queries cover 90% of what you need.

## Directory Layout

```
<plugin-root>/
  lua/<plugin>/           -- plugin source
    init.lua
    ...
  tests/
    minimal_init.lua      -- minimal nvim config for tests
    harness.py            -- test driver
```

## Building the Pieces

### 1. `minimal_init.lua`

The goal: load your plugin + its dependencies + nothing else. Starting a full user config in headless mode is slow and introduces unpredictable side effects.

```lua
-- tests/minimal_init.lua
local plugin_root = "D:/path/to/your/plugin"
local lazy_root = "D:/apps/nvim-data/lazy"  -- or vim.fn.stdpath("data") .. "/lazy"

-- Add plugin deps to rtp
vim.opt.rtp:append(lazy_root .. "/dep1.nvim")
vim.opt.rtp:append(lazy_root .. "/dep2.nvim")

-- Make your plugin require-able
-- If your plugin is at <plugin_root>/<module>/init.lua and you want `require("<module>")`,
-- the parent directory (plugin_root) must be on the module search path.
package.path = package.path
    .. ";" .. plugin_root .. "/?.lua"
    .. ";" .. plugin_root .. "/?/init.lua"

-- Setup deps (minimal configuration)
require("dep1").setup({})

-- Optional: mark test mode for the plugin to adjust behavior
_G.PLUGIN_TEST = true
```

**Why not use the user's normal config?** It loads 100+ plugins, takes several seconds, and many plugins behave differently in headless mode (ones that hook `VimEnter`, set up UIs, etc.). A minimal init gives you a deterministic starting state in ~100ms.

### 2. `harness.py` — Core Driver

The driver is a Python class that wraps pynvim with convenience methods. The skeleton:

```python
import sys
from pathlib import Path
import pynvim

# Windows console defaults to cp1252 -- force UTF-8 for nerd fonts / box-drawing chars
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parent.parent
MINIMAL_INIT = ROOT / "tests" / "minimal_init.lua"


class Harness:
    def __init__(self):
        self.nvim: pynvim.Nvim = None  # type: ignore

    def start(self):
        args = ["nvim", "--embed", "--headless", "-n", "-u", str(MINIMAL_INIT)]
        self.nvim = pynvim.attach("child", argv=args)
        return self

    def close(self):
        if self.nvim:
            try:
                self.nvim.command("qall!")
            except Exception:
                pass
            self.nvim.close()
            self.nvim = None

    # --- Input ---
    def cmd(self, c):
        self.nvim.command(c)

    def exec_lua(self, code):
        return self.nvim.exec_lua(code)

    def wait(self, ms=50):
        """Let nvim process pending events. Needed after feedkeys/async ops."""
        self.exec_lua(f"vim.wait({ms})")

    # --- State ---
    def current_buf(self):
        return self.nvim.api.get_current_buf().number

    def cursor(self):
        return tuple(self.nvim.api.win_get_cursor(0))

    def windows(self):
        result = []
        for w in self.nvim.api.list_wins():
            cfg = self.nvim.api.win_get_config(w)
            result.append({
                "win": w.number,
                "buf": self.nvim.api.win_get_buf(w).number,
                "relative": cfg.get("relative", ""),
                "width": cfg.get("width"),
                "height": cfg.get("height"),
                "title": cfg.get("title"),
            })
        return result

    def diagnostics(self, bufnr=None, ns_name="my_plugin"):
        if bufnr is None:
            bufnr = self.current_buf()
        return self.exec_lua(f'''
            local ns = vim.api.nvim_get_namespaces()["{ns_name}"]
            if not ns then return {{}} end
            return vim.diagnostic.get({bufnr}, {{ namespace = ns }})
        ''')

    def hl(self, name):
        return self.exec_lua(
            f'return vim.api.nvim_get_hl(0, {{ name = "{name}", link = false }})'
        )


def run():
    h = Harness().start()
    try:
        # your checks here
        print("plugin loaded:", h.exec_lua('return pcall(require, "my_plugin")'))
    finally:
        h.close()


if __name__ == "__main__":
    run()
```

## Key Patterns

### Querying State

Prefer state queries over visual inspection. They're fast, deterministic, and don't require a UI.

```python
# Is the plugin's module loaded?
h.exec_lua('return package.loaded["my_plugin"] ~= nil')

# What keymaps are set on current buffer?
h.exec_lua('''
    local result = {}
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        result[#result + 1] = m.lhs
    end
    return result
''')

# What extmarks exist in a given namespace?
h.exec_lua('''
    local ns = vim.api.nvim_get_namespaces().my_plugin
    return vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })
''')

# Is this window a floating window? What's its title?
cfg = h.nvim.api.win_get_config(win)
cfg["relative"]  # "" = regular split, "editor"/"win"/"cursor" = float
cfg["title"]     # list of [text, highlight] chunks

# Are the plugin's highlight groups defined with the expected colors?
h.hl("MyPluginBorder")  # {'fg': 0x89b4fa}
```

### Sending Input

**Gotcha:** `nvim.feedkeys(keys, "nx")` does NOT reliably trigger buffer-local Lua keymap callbacks in headless mode. The keys are queued but the Lua callback may not fire before your next state query.

**Workaround — invoke keymap callbacks directly:**

```python
# Find the buffer-local keymap for a given lhs and call its callback
h.exec_lua('''
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        if m.lhs == "A" and m.callback then
            m.callback()
            return true
        end
    end
    return false
''')
```

This bypasses the key-processing pipeline entirely and calls the function that the keymap was bound to. It's more deterministic for testing.

For key sequences that affect cursor position or text (like `jj` or `dd`), `nvim.input()` works fine — those are handled by nvim's native code, not Lua callbacks.

```python
h.nvim.input("jj")    # cursor moves down twice
h.wait(50)
h.cursor()            # verify new position
```

### Preventing Side Effects

Plugins often do things during setup that are noisy for tests (open pickers, show notifications, install autocmds globally). Patch them out after loading the plugin:

```python
# Turn off the plugin's picker (so tests don't deal with its windows)
h.exec_lua('require("my_plugin.picker").open = function() end')

# Silence notifications
h.exec_lua('vim.notify = function() end')
```

This is cleaner than adding test-mode checks to the plugin itself.

### Resolving Paths

Plugins that use relative file paths need the cwd set correctly. Do this immediately after `start()`:

```python
from pathlib import Path
h.nvim.command(f"cd {Path('D:/some/project').as_posix()}")
```

Use `as_posix()` — Vim's `:cd` handles forward slashes on Windows; backslashes need escaping.

### Handling Unicode Output

On Windows, the default console encoding is cp1252. Nerd Font icons and box-drawing characters (╭─╯ etc.) will fail to print. Fix at the top of `harness.py`:

```python
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
```

If that still produces `UnicodeEncodeError`, set `PYTHONIOENCODING=utf-8` in your environment.

### Shutdown Warnings

On Windows with Python 3.14+, you'll see benign warnings at shutdown:

```
ValueError: I/O operation on closed pipe
Exception ignored while calling deallocator <function _ProactorBasePipeTransport.__del__>
```

These come from asyncio not cleaning up the subprocess pipe gracefully. Safe to ignore. If they clutter output, filter them:

```powershell
python tests/harness.py 2>&1 | Where-Object { $_ -notmatch "unclosed|proactor_events|I/O operation" }
```

Or in bash:

```bash
python tests/harness.py 2>&1 | grep -vE "unclosed|proactor_events|I/O operation"
```

## Writing Scenarios

Structure each scenario as a linear sequence of **setup → action → assert**. Don't write a full test framework; just use `assert` and print progress.

```python
def scenario_keymap_toggle():
    h = Harness().start()
    try:
        # setup
        h.exec_lua('require("my_plugin")')
        h.cmd("edit some_file.txt")

        # action
        h.exec_lua('''
            for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
                if m.lhs == "A" and m.callback then m.callback(); return end
            end
        ''')
        h.wait(50)

        # assert
        state = h.exec_lua('return require("my_plugin").get_state()')
        assert state.status == "accepted", f"expected accepted, got {state.status}"
        print("[OK] A toggles accepted")
    finally:
        h.close()
```

Use `assert` with a descriptive message. On failure, dump the state:

```python
try:
    ...
except AssertionError as e:
    print(f"FAIL: {e}")
    print(f"cursor: {h.cursor()}")
    print(f"windows: {h.windows()}")
    raise
```

## Limitations

- **No grid capture.** You see window configs, buffer contents, and highlight definitions, but not the final rendered grid. Border rendering, z-index conflicts, and clipping are not verifiable without `ui_attach`.
- **No screenshot.** Font rendering, terminal colors, ligatures — none of it is accessible.
- **Timing sensitivity.** Async operations (autocmds firing, jobs completing) may need `h.wait()` to settle.
- **Some commands differ in headless mode.** Plugins that hook `VimEnter` or `UIEnter` may not run. Test your plugin's entry points explicitly.

## When You Need Grid Capture

If you need to verify rendered output (border chars, exact colors per cell), extend the harness with `ui_attach`:

```python
nvim.ui_attach(cols, rows, {
    "rgb": True,
    "ext_linegrid": True,
    "ext_multigrid": True,
})

# Subscribe to redraw notifications
def handle_notification(name, args):
    if name == "redraw":
        for event in args:
            kind = event[0]
            for call in event[1:]:
                # hl_attr_define: (id, rgb_attr, cterm_attr, info)
                # grid_line: (grid, row, col, cells, wrap)
                # win_float_pos: (grid, win, anchor, anchor_grid, row, col, focusable, zindex)
                ...
```

Reconstruct the grid in a 2D array, build a string representation with highlight annotations, and snapshot it. This is significantly more code (~200 lines) and is worth it only when state queries fundamentally can't answer the question.

## Debugging the Harness Itself

If something isn't working:

1. **Is nvim starting?** `print(h.exec_lua("return vim.version()"))` — if this returns, the RPC works.
2. **Is the plugin loading?** `print(h.exec_lua('return pcall(require, "my_plugin")'))` — returns `True` if no errors.
3. **What's the error?** `print(h.exec_lua('return pcall(function() error("test") end)'))` — second return value is the error message.
4. **What's in a buffer?** `print(h.exec_lua("return vim.api.nvim_buf_get_lines(0, 0, -1, false)"))`.
5. **What namespaces exist?** `print(h.exec_lua("return vim.api.nvim_get_namespaces()"))`.

When in doubt, call `h.exec_lua(...)` with whatever ad-hoc Lua you'd run in `:lua=` in a real Neovim session. The RPC is transparent.

## Minimal Checklist for a New Plugin

1. Create `tests/minimal_init.lua` — list the plugin's deps and expose the plugin on `package.path`
2. Create `tests/harness.py` — copy the skeleton, adjust `ROOT`/paths
3. Run `python tests/harness.py` — verify nvim starts and the plugin loads
4. Add scenarios one at a time — setup, action (invoke keymap callback or run Lua), assert state
5. When adding a feature, extend the harness scenario for it before reporting the feature done
