# review.nvim

A Neovim plugin that displays code review comments inline as diagnostics, with a chat-style panel for replies and accept/reject workflow.

The plugin is **provider-agnostic**: it doesn't fetch comments itself. Instead, you register one or more providers (file-based JSON, GitHub PR, Azure DevOps PR, AI agent, etc.) that supply comments and persist actions.

## Features

- **Inline display** via `vim.diagnostic` — severity-colored signs, range backgrounds for status
- **Floating panel** — opens on demand at cursor; shows comment body, chat thread, reply input, accept/reject
- **File tree sidebar** (Snacks picker) — lists reviewed files with `pending/total` badge
- **Navigation** — `]c` / `[c` jump between comments
- **Status toggle** — accept/reject; press the same key again to revert to pending
- **Reply** — type a response in the panel, `<C-s>` posts it via the provider

## Installation

The plugin is loaded from `D:/dotfiles/neovim/review`. The directory `lua/review` is symlinked into Neovim's runtime:

```
D:/apps/nvim/lua/review -> D:/dotfiles/neovim/review/lua/review
```

Once a proper `lazy.nvim` spec is added, this is replaced by:

```lua
{
    dir = "D:/dotfiles/neovim/review",
    main = "review",
    dependencies = { "folke/snacks.nvim" },
    opts = {
        providers = {
            require("review.providers.file").new({ path = "review.json" }),
        },
    },
}
```

## Setup

```lua
require("review").setup({
    providers = {
        require("review.providers.file").new({ path = "review.json" }),
        -- add other providers here
    },
    keymaps = true,    -- default true; set false to opt-out
    auto_render = true, -- default true; renders on BufEnter
    highlights = {     -- override any default highlight
        ReviewBgPending = { bg = "#1a3045" },
    },
})
```

## Commands

```
:Review load [provider]   -- load comments from one provider, or all
:Review tree              -- toggle file tree sidebar
:Review panel             -- open panel for comment at cursor
:Review reply             -- focus reply input for comment at cursor
:Review accept            -- accept comment at cursor
:Review reject            -- reject comment at cursor
:Review next | prev       -- navigation
:Review clear             -- clear all state and rendering
```

## Default Keymaps (in reviewed buffers)

| Key | Action |
|-----|--------|
| `]c` | Next comment |
| `[c` | Previous comment |
| `<leader>rc` | Open panel for comment at cursor |
| `<leader>rt` | Open file tree |
| `<leader>ra` | Toggle accept |
| `<leader>rx` | Toggle reject |
| `<leader>rr` | Reply (opens panel + insert mode) |

Inside the panel:

| Key | Action |
|-----|--------|
| `a` | Toggle accept |
| `x` | Toggle reject |
| `r` | Focus reply input |
| `<C-s>` | Submit reply (works in normal and insert mode) |
| `]c` / `[c` | Next/prev comment in panel |
| `<Esc>` / `q` | Close panel |

## Provider Contract

```lua
---@class Provider
---@field name string                                              -- unique handle
---@field label? string                                            -- display name
---@field load fun(): Comment[]                                    -- required
---@field save? fun(comments: Comment[])                           -- bulk persist
---@field reply? fun(comment_id: string, body: string): Message?   -- post a reply
---@field set_status? fun(comment_id: string, status: string): boolean
```

When a provider lacks an optional method (e.g., `reply`), the corresponding UI action shows a clear notification.

### Writing a Provider

```lua
-- my-ai-provider.lua
local M = {}

function M.new(opts)
    return {
        name = "ai",
        label = "AI Reviews",
        load = function()
            -- call your API; return Comment[]
        end,
        reply = function(id, body)
            -- forward to AI; return the AI's response Message
            return { id = uid(), author = "AI", timestamp = now(), body = ai_response }
        end,
        set_status = function(id, status)
            -- log/persist; return true on success
        end,
    }
end

return M
```

See `lua/review/providers/file.lua` for a reference implementation.

## File Provider

`require("review.providers.file").new({ path = "review.json", author = "you" })`

Reads a JSON array (see [REVIEW_FORMAT.md](REVIEW_FORMAT.md)) and writes back on every reply / status change. The JSON is pretty-printed with sorted keys for clean diffs.

## Architecture

```
┌─────────────────────────┐
│ User (cursor in buffer) │
└──────────┬──────────────┘
           │ ]c / <leader>cc / a / x / <C-s>
           ▼
┌─────────────────────────┐    ┌──────────────┐
│  init.lua  (commands +  │───►│  state.lua   │
│  keymaps + dispatch)    │    │  (in-memory) │
└──────────┬──────────────┘    └──────┬───────┘
           │                          │
   ┌───────┴────────┐                 │ on event
   ▼                ▼                 ▼
┌─────────┐  ┌──────────┐    ┌──────────────┐
│ panel   │  │  nav     │    │  diagnostics │
│ (float) │  │ (jumps)  │    │  + bg hl     │
└────┬────┘  └──────────┘    └──────────────┘
     │ provider.call("reply", ...)
     ▼
┌──────────┐
│ provider │ ──► file.lua / your-ai-provider.lua / github / azure
└──────────┘
```

`state.lua` is the single source of truth in memory. Providers are the source of truth on disk / over the network. The plugin shuttles between them.

## Testing

A development harness lives in `tests/` — see `D:/dotfiles/neovim/TEST_HARNESS.md` for the general pattern.

Run all scenarios:

```powershell
cd D:\dotfiles
foreach ($s in "smoke","panel","reply","status_toggle","navigation") {
    python neovim\review\tests\scenarios\$s.py
}
```
