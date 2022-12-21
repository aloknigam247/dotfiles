--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]
-- TODO: format on paste
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
LazyConfig = {
  root = vim.fn.stdpath("data") .. "/lazy", -- directory where plugins will be installed
  defaults = {
    lazy = true, -- should plugins be lazy-loaded?
    version = nil,
  },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after running update.
  concurrency = nil, ---@type number limit the maximum amount of concurrent tasks
  git = {
    log = { "--since=3 days ago" }, -- show commits from the last 3 days
    timeout = 120, -- kill processes that take more than 2 minutes
    url_format = "https://github.com/%s.git",
  },
  dev = {
    path = "~/projects",
    patterns = {}, -- For example {"folke"}
  },
  install = {
    missing = true,
    colorscheme = { },
  },
  ui = {
    border = "rounded",
    icons = {
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      keys = " ",
      plugin = " ",
      runtime = " ",
      source = " ",
      start = "",
      task = " ",
    },
    throttle = 20, -- how frequently should the ui process render events
  },
  checker = {
    enabled = true,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = true, -- get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
  },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("state") .. "/lazy/cache",
      -- Once one of the following events triggers, caching will be disabled.
      -- To cache all modules, set this to `{}`, but that is not recommended.
      -- The default is to disable on:
      --  * VimEnter: not useful to cache anything else beyond startup
      --  * BufReadPre: this will be triggered early when opening a file from the command line directly
      disable_events = { },
    },
    reset_packpath = false, -- reset the package path to improve startup time -- TODO: set to true
    rtp = {
      reset = false, -- reset the runtime path to $VIMRUNTIME and your config directory -- TODO: set to true
      disabled_plugins = {
        -- "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        -- "tarPlugin",
        -- "tohtml",
        -- "tutor",
        -- "zipPlugin",
      },
    },
  },
  -- lazy can generate helptags from the headings in markdown readme files,
  -- so :help works even for plugins that don't have vim docs.
  -- when the readme opens with :help it will be correctly displayed as markdown
  readme = {
    root = vim.fn.stdpath("state") .. "/lazy/readme",
    files = { "README.md" },
    -- only generate markdown helptags for plugins that dont have docs
    skip_if_doc_exists = true,
  },
}
-- <~>

-- setup ➡️ init
-- requires ➡️ dependencies
-- as ➡️ name
-- opt ➡️ lazy
-- run ➡️ build
-- lock ➡️ pin
-- module is auto-loaded. No need to specify


Plugins = {
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
},

-- use 'echasnovski/mini.align',

{
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign'
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'windwp/nvim-autopairs',
    config = function()
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require'nvim-autopairs.conds'

        npairs.setup({
            enable_check_bracket_line = false -- Don't add pairs if close pair is in the same line
        })
        npairs.add_rules {
            -- #include <> pair for c and cpp
            Rule("#include <", ">", { "c", "cpp" }),
            -- Disable " rule for vim
            Rule('"', '"')
            :with_pair(cond.not_filetypes({"vim"})),
            -- Add spaces in pair after parentheses
            -- (|) --> space --> ( | )
            -- ( | ) --> ) --> ( )|
            Rule(' ', ' ')
            :with_pair(function (opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({ '()', '[]', '{}' }, pair)
            end),
            Rule('( ', ' )')
            :with_pair(function() return false end)
            :with_move(function(opts)
                return opts.prev_char:match('.%)') ~= nil
            end)
            :use_key(')'),
            Rule('{ ', ' }')
            :with_pair(function() return false end)
            :with_move(function(opts)
                return opts.prev_char:match('.%}') ~= nil
            end)
            :use_key('}'),
            Rule('[ ', ' ]')
            :with_pair(function() return false end)
            :with_move(function(opts)
                return opts.prev_char:match('.%]') ~= nil
            end)
            :use_key(']'),
            -- Auto add space on =
            Rule('=', '')
            :with_pair(cond.not_inside_quote())
            :with_pair(function(opts)
                local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
                if last_char:match('[%w%=%s]') then
                    return true
                end
                return false
            end)
            :replace_endpair(function(opts)
                local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
                local next_char = opts.line:sub(opts.col, opts.col)
                next_char = next_char == ' ' and '' or ' '
                if prev_2char:match('%w$') then
                    return '<bs> =' .. next_char
                end
                if prev_2char:match('%=$') then
                    return next_char
                end
                if prev_2char:match('=') then
                    return '<bs><bs>=' .. next_char
                end
                return ''
            end)
            :set_end_pair_length(0)
            :with_move(cond.none())
            :with_del(cond.none())
        }
        -- Insert `(` after select function or method item
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
        )
    end,
    event = 'InsertEnter',
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Coloring    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- {
--     'David-Kunz/markid',
--     -- after = 'nvim-treesitter'
--     config = function()
--         local m = require'markid'
--         require'nvim-treesitter.configs'.setup {
--             markid = {
--                 enable = true,
--                 colors = m.colors.medium,
--                 queries = m.queries,
--                 is_supported = function(lang)
--                     local queries = configs.get_module("markid").queries
--                     return pcall(vim.treesitter.parse_query, lang, queries[lang] or queries['default'])
--                 end
--             }
--         }
--     end
-- },

{
    'RRethy/vim-illuminate',
    after = 'nvim-treesitter',
    config = function()
        require('illuminate').configure({
            providers =  {
                -- 'lsp',
                'treesitter',
                'regex'
            }
        })
        function LightenDarkenColor(col, amt)
            local num = tonumber(col, 16)
            local r = bit.rshift(num, 16) + amt
            local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
            local g = bit.band(num, 0x0000FF) + amt
            local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))
            return string.format("#%X", newColor)
        end

        local bg = vim.api.nvim_get_hl_by_name('Normal', true).background
        bg = string.format("%X", tostring(bg))
        -- print(bg)
        if (vim.o.background ==  "dark") then
            bg = LightenDarkenColor(bg, 40)
        else
            bg = LightenDarkenColor(bg, -40)
        end
        -- print(bg)
        vim.api.nvim_set_hl(0, "IlluminatedWordText", {
            bg = bg,
            -- underline = true
        })
        vim.cmd[[
           " hi IlluminatedWordText guibg = underline
           hi IlluminatedWordRead guibg = #A5BE00 guifg = #000000
           hi IlluminatedWordWrite guibg = #1F7A8C gui = italic
           hi LspReferenceText guibg = #679436
           hi LspReferenceWrite guibg = #A5BE00
           hi LspReferenceRead guibg = #427AA1
       ]]
    end,
    event = 'CursorMoved'
},

-- use 'azabiong/vim-highlighter'

{
    'folke/lsp-colors.nvim',
    event = "LspAttach"
},

-- -- https://github.com/folke/paint.nvim

{
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
    end,
    event = "CursorHold"
},

{
    'kevinhwang91/nvim-hlslens',
    config = function()
        require('hlslens').setup()
    end,
    keys = {
        { "n", "n" },
        { "n", "N" },
        { "n", "*" },
        { "n", "#" },
        { "n", "g*" },
        { "n", "g#" },
    }
},

-- {
--     'melkster/modicator.nvim',
--     after = 'lualine.nvim',
--     config = function()
--         local modicator = require('modicator')
--         local modes = {
--             ['R'] = vim.api.nvim_get_hl_by_name('lualine_a_replace', true).background,
--             ['S'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
--             ['V'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
--             ['c'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
--             ['i'] = vim.api.nvim_get_hl_by_name('lualine_a_insert', true).background,
--             ['n'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
--             ['s'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
--             ['v'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
--         }
--         if vim.fn.hlexists('lualine_a_command') ~= 0 then
--             modes['c'] = vim.api.nvim_get_hl_by_name('lualine_a_command', true).background
--         end
--         modicator.setup({
--             line_numbers = true,
--             cursorline = true,
--             highlights = {
--                 modes = modes
--             }
--         })
-- 
--         modicator.set_highlight(modes['n'])
--     end,
--     lock = true
-- },
-- 
-- {
--     'norcalli/nvim-colorizer.lua',
--     cmd = "ColorizerToggle",
--     config = function()
--     require('colorizer').setup()
--     end
-- },
-- 
-- {
--     't9md/vim-quickhl',
--     config = function()
--         vim.cmd[[
--             nmap <Leader>w <Plug>(quickhl-manual-this)
--             xmap <Leader>w <Plug>(quickhl-manual-this)
--             nmap <Leader>W <Plug>(quickhl-manual-reset)
--             xmap <Leader>W <Plug>(quickhl-manual-reset)
--         ]]
--     end,
--     keys = {'<Leader>w', "<Leader>W"}
-- },
-- 
-- {
--     -- https://github.com/xiyaowong/nvim-transparent
--     'tribela/vim-transparent',
--     cmd = 'TransparentToggle'
-- },
-- <~>
}

require("lazy").setup(Plugins, LazyConfig)
-- vim: fmr=</>,<~>
