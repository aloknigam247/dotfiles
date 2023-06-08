--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
--TODO: order plugins
--DOCME: docs for some sections
-- Variables
-- ---------

-- Vim Globals
vim.g.cmp_kinds = {
    Array         = ' ',
    Boolean       = ' ',
    Class         = ' ',
    Color         = ' ',
    Constant      = ' ',
    Constructor   = ' ',
    Enum          = ' ',
    EnumMember    = ' ',
    Event         = ' ',
    Field         = ' ',
    File          = ' ',
    Folder        = '󰷏 ',
    Function      = ' ',
    History       = ' ',
    Interface     = ' ',
    Key           = ' ',
    Keyword       = ' ',
    Method        = ' ',
    Module        = ' ',
    Namespace     = 'ﬥ ',
    Null          = ' ',
    Number        = ' ',
    Object        = ' ',
    Operator      = ' ',
    Options       = ' ',
    Package       = ' ',
    Property      = ' ',
    Reference     = ' ',
    Snippet       = ' ',
    String        = ' ',
    Struct        = ' ',
    Text          = '󱄽 ',
    TypeParameter = ' ',
    Unit          = ' ',
    Value         = ' ',
    Variable      = ' '
}

vim.g.loaded_clipboard_provider = 1

-- Lua Globals
--vim.highlight.priorities
HlPriority = { -- TODO: Understand highlight priority
    hlargs = 10000,
    url = 1
}

SignOrder = {} -- TODO:

LazyConfig = {
    root = vim.fn.stdpath('data') .. '/lazy', -- directory where plugins will be installed
    defaults = {
        lazy = true, -- should plugins be lazy-loaded?
        version = nil,
        -- default `cond` you can use to globally disable a lot of plugins
        -- when running inside vscode for example
        cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
        -- version = '*', -- enable this to try installing the latest stable versions of plugins
    },
    -- leave nil when passing the spec as the first argument to setup()
    spec = nil, ---@type LazySpec
    lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json', -- lockfile generated after running update.
    concurrency = nil, ---@type number limit the maximum amount of concurrent tasks
    git = {
        -- defaults for the `Lazy log` command
        log = { '-10' }, -- show the last 10 commits
        timeout = 12000, -- kill processes that take more than 2 minutes
        url_format = 'https://github.com/%s.git',
        -- lazy.nvim requires git >=2.19.0. If you really want to use lazy with an older version,
        -- then set the below to false. This should work, but is NOT supported and will
        -- increase downloads a lot.
        filter = false,
    },
    dev = {
        -- directory where you store your local plugin projects
        path = '~/projects',
        ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
        patterns = {}, -- For example {'folke'}
        fallback = false, -- Fallback to git when local plugin doesn't exist
    },
    install = {
        -- install missing plugins on startup. This doesn't increase startup time.
        missing = true,
        -- try to load one of these colorschemes when starting an installation during startup
        colorscheme = { },
    },
    ui = {
        -- a number <1 is a percentage., >1 is a fixed size
        size = { width = 0.8, height = 0.8 },
        wrap = true, -- wrap the lines in the ui
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = 'rounded',
        title = nil, ---@type string only works when border is not 'none'
        title_pos = 'center', ---@type 'center' | 'left' | 'right'
        icons = {
            cmd        = ' ',
            config     = '',
            event      = '',
            ft         = ' ',
            init       = ' ',
            import     = '󰋺 ',
            keys       = ' ',
            lazy       = ' ',
            list       = { '●', '', '', '' },
            loaded     = '',
            not_loaded = '',
            plugin     = ' ',
            runtime    = ' ',
            source     = ' ',
            start      = '',
            task       = ' ',
        },
        -- leave nil, to automatically select a browser depending on your OS.
        -- If you want to use a specific browser, you can define it here
        browser = nil, ---@type string?
        throttle = 20, -- how frequently should the ui process render events
        custom_keys = {
            -- you can define custom key maps here.
            -- To disable one of the defaults, set it to false

            -- open lazygit log
            ['<localleader>l'] = function(plugin)
                require('lazy.util').float_term({ 'lazygit', 'log' }, {
                    cwd = plugin.dir,
                })
            end,

            -- open a terminal for the plugin dir
            ['<localleader>t'] = function(plugin)
                require('lazy.util').float_term(nil, {
                    cwd = plugin.dir,
                })
            end,
        },
    },
    diff = {
        -- diff command <d> can be one of:
        -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
        --   so you can have a different command for diff <d>
        -- * git: will run git diff and open a buffer with filetype git
        -- * terminal_git: will open a pseudo terminal with git diff
        -- * diffview.nvim: will open Diffview to show the diff
        cmd = 'git',
    },
    checker = {
        -- automatically check for plugin updates
        enabled = false,
        concurrency = nil, ---@type number? set to 1 to check for updates very slowly
        notify = true, -- get a notification when new updates are found
        frequency = 3600, -- check for updates every hour
    },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = true,
        notify = true, -- get a notification when changes are found
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true, -- reset the package path to improve startup time
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
            ---@type string[]
            paths = {}, -- add any custom paths here that you want to includes in the rtp
            ---@type string[] list any plugins you want to disable here
            disabled_plugins = {
                'gzip',
                -- 'health',
                'man',
                -- 'matchit',
                -- 'matchparen',
                -- 'netrwPlugin',
                'spellfile',
                'tarPlugin',
                'tohtml',
                'tutor',
                -- 'zipPlugin',
            },
        },
    },
    -- lazy can generate helptags from the headings in markdown readme files,
    -- so :help works even for plugins that don't have vim docs.
    -- when the readme opens with :help it will be correctly displayed as markdown
    readme = {
        enabled = true,
        root = vim.fn.stdpath('state') .. '/lazy/readme',
        files = { 'README.md', 'lua/**/README.md' },
        -- only generate markdown helptags for plugins that dont have docs
        skip_if_doc_exists = true,
    },
    state = vim.fn.stdpath('state') .. '/lazy/state.json', -- state info for checker and other things
}

Plugins = {}

-- Lua Locals
-- local border_shape = {
--     { '╭', 'FloatBorder' },
--     { '─', 'FloatBorder' },
--     { '╮', 'FloatBorder' },
--     { '│', 'FloatBorder' },
--     { '╯', 'FloatBorder' },
--     { '─', 'FloatBorder' },
--     { '╰', 'FloatBorder' },
--     { '│', 'FloatBorder' },
-- }

Icons = {
    diagnostic = {
        error = '',
        hint  = '',
        info  = '',
        other = '﫠',
        warn  = '',
    }
}

local kind_hl = {
    Array         = { icon  = ' ' , dark = { fg = '#F42272' }, light = { fg = '#0B6E4F' } },
    Boolean       = { icon  = ' ' , dark = { fg = '#B8B8F3' }, light = { fg = '#69140E' } },
    Class         = { icon  = ' ' , dark = { fg = '#519872' }, light = { fg = '#1D3557' } },
    Color         = { icon  = ' ' , dark = { fg = '#A4B494' }, light = { fg = '#FA9F42' } },
    Constant      = { icon  = ' ' , dark = { fg = '#C5E063' }, light = { fg = '#744FC6' } },
    Constructor   = { icon  = ' ' , dark = { fg = '#4AAD52' }, light = { fg = '#755C1B' } },
    Enum          = { icon  = ' ' , dark = { fg = '#E3B5A4' }, light = { fg = '#A167A5' } },
    EnumMember    = { icon  = ' ' , dark = { fg = '#AF2BBF' }, light = { fg = '#B80C09' } },
    Event         = { icon  = ' ' , dark = { fg = '#6C91BF' }, light = { fg = '#53A548' } },
    Field         = { icon  = ' ' , dark = { fg = '#5BC8AF' }, light = { fg = '#E2DC12' } },
    File          = { icon  = ' ' , dark = { fg = '#EF8354' }, light = { fg = '#486499' } },
    Folder        = { icon  = ' ' , dark = { fg = '#BFC0C0' }, light = { fg = '#A74482' } },
    Function      = { icon  = ' ' , dark = { fg = '#E56399' }, light = { fg = '#228CDB' } },
    History       = { icon  = ' ' , dark = { fg = '#C2F8CB' }, light = { fg = '#85CB33' } },
    Interface     = { icon  = ' ' , dark = { fg = '#8367C7' }, light = { fg = '#537A5A' } },
    Key           = { icon  = ' ' , dark = { fg = '#D1AC00' }, light = { fg = '#645DD7' } },
    Keyword       = { icon  = ' ' , dark = { fg = '#20A4F3' }, light = { fg = '#E36414' } },
    Method        = { icon  = ' ' , dark = { fg = '#D7D9D7' }, light = { fg = '#197278' } },
    Module        = { icon  = ' ' , dark = { fg = '#F2FF49' }, light = { fg = '#EC368D' } },
    Namespace     = { icon  = 'ﬥ ' , dark = { fg = '#FF4242' }, light = { fg = '#2F9C95' } },
    Null          = { icon  = ' ' , dark = { fg = '#C1CFDA' }, light = { fg = '#56666B' } },
    Number        = { icon  = ' ' , dark = { fg = '#FB62F6' }, light = { fg = '#A5BE00' } },
    Object        = { icon  = ' ' , dark = { fg = '#F18F01' }, light = { fg = '#80A1C1' } },
    Operator      = { icon  = ' ' , dark = { fg = '#048BA8' }, light = { fg = '#F1DB4B' } },
    Options       = { icon  = ' ' , dark = { fg = '#99C24D' }, light = { fg = '#2292A4' } },
    Package       = { icon  = ' ' , dark = { fg = '#AFA2FF' }, light = { fg = '#B98EA7' } },
    Property      = { icon  = ' ' , dark = { fg = '#CED097' }, light = { fg = '#3777FF' } },
    Reference     = { icon  = ' ' , dark = { fg = '#1B2CC1' }, light = { fg = '#18A999' } },
    Snippet       = { icon  = ' ' , dark = { fg = '#7692FF' }, light = { fg = '#BF0D4B' } },
    String        = { icon  = ' ' , dark = { fg = '#FEEA00' }, light = { fg = '#D5573B' } },
    Struct        = { icon  = ' ' , dark = { fg = '#D81159' }, light = { fg = '#75485E' } },
    Text          = { icon  = ' ' , dark = { fg = '#0496FF' }, light = { fg = '#5762D5' } },
    TypeParameter = { icon  = ' ' , dark = { fg = '#FFFFFC' }, light = { fg = '#5D2E8C' } },
    Unit          = { icon  = ' ' , dark = { fg = '#C97B84' }, light = { fg = '#FF6666' } },
    Value         = { icon  = ' ' , dark = { fg = '#C6DDF0' }, light = { fg = '#2EC4B6' } },
    Variable      = { icon  = ' ' , dark = { fg = '#B7ADCF' }, light = { fg = '#548687' } }
}

local url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

-- Functions
-- ---------
function AddPlugin(opts)
    table.insert(Plugins, opts)
end

function ColorPalette()
    if vim.o.background == 'light' then
        return {
            { fg = '#00A6ED' },
            { fg = '#037171' },
            { fg = '#2100F5' },
            { fg = '#235789' },
            { fg = '#247BA0' },
            { fg = '#30B0A1' },
            { fg = '#5D536B' },
            { fg = '#61210F' },
            { fg = '#689784' },
            { fg = '#7E5CA3' },
            { fg = '#7FB800' },
            { fg = '#806443' },
            { fg = '#81A35C' },
            { fg = '#9C7C1C' },
            { fg = '#A42CD6' },
            { fg = '#CE2D4F' },
            { fg = '#735290' },
            { fg = '#F4743B' },
            { fg = '#F6511D' },
            { fg = '#FFB400' },
        }
    else
        return {
            { fg = '#4056F4' },
            { fg = '#5FAD56' },
            { fg = '#97CC04' },
            { fg = '#98fc03' },
            { fg = '#BDBEA9' },
            { fg = '#CE6D8B' },
            { fg = '#D4C2FC' },
            { fg = '#DDA15E' },
            { fg = '#E6E6E6' },
            { fg = '#E9D758' },
            { fg = '#F45D01' },
            { fg = '#F78154' },
            { fg = '#FFD447' },
            { fg = '#c0dbf5' },
            { fg = '#c0f5c8' },
            { fg = '#c0f5f1' },
            { fg = '#ccc0f5' },
            { fg = '#dff5c0' },
            { fg = '#f2c0f5' },
            { fg = '#f5eac0' },
        }
    end
end

function LightenDarkenColor(col, amt)
    local num = tonumber(col, 16)
    local r = bit.rshift(num, 16) + amt
    local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
    local g = bit.band(num, 0x0000FF) + amt
    local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))
    return string.format("#%X", newColor)
end

function PopupAction()
end

function PopupMenuAdd(title, action)
    title = title:gsub(' ', '\\ ')
    vim.cmd.nnoremenu('PopUp.' .. title .. ' ' .. action)
end

-- Auto Commands
-- -------------
vim.api.nvim_create_autocmd(
    'BufReadPost', {
        pattern = '*',
        desc = 'Disable wrap for file with long lines',
        callback = function()
            for _, line in ipairs(vim.fn.getbufline(vim.api.nvim_get_current_buf(), 1, '$')) do
                local line_length = #line
                if line_length > 150 then
                    vim.opt_local.wrap = false
                    break
                end
            end
        end
    }
)

vim.api.nvim_create_autocmd(
    'BufWritePre', {
        pattern = '*',
        desc = 'Create directory if it does not exists',
        callback = function()
            local filedir = vim.fn.expand('%:p:h')
            if vim.fn.isdirectory(filedir) == 0 then
                vim.fn.mkdir(filedir, 'p')
            end
        end
    }
)

vim.api.nvim_create_autocmd(
    'PopupMenuAdd', {
        pattern = '*',
        desc = 'Create popup menu based on context',
        callback = PopupAction
    }
)

vim.api.nvim_create_autocmd(
    'TextYankPost', {
        pattern = '*',
        desc = 'Highlight text on yank',
        callback = function()
            vim.highlight.on_yank { higroup="Search", timeout=300 }
        end
    }
)

vim.api.nvim_create_autocmd(
    'User', {
        pattern='VeryLazy',
        desc = 'Lazy load clipboard provider',
        callback = function()
            vim.cmd([[
                unlet g:loaded_clipboard_provider
                runtime autoload/provider/clipboard.vim
            ]])
        end
    }
)

-- Misc
-- ----
vim.diagnostic.config({
    float = {
        source = true
    },
    severity_sort = true,
    virtual_text = {
        prefix = ' ',
        source = true
    }
})

vim.fn.matchadd('HighlightURL', url_matcher, HlPriority.url)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
}

-- FEAT: use 'echasnovski/mini.align'

AddPlugin {
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- https://github.com/m4xshen/autoclose.nvim
    'windwp/nvim-autopairs',
    config = function()
        local pair = require('nvim-autopairs')
        local Rule = require('nvim-autopairs.rule')
        local cond = require('nvim-autopairs.conds')

        pair.setup({
            enable_check_bracket_line = false -- Don't add pairs if close pair is in the same line
        })
        pair.add_rules {
            -- function() | end pair for lua
            Rule('function() ', ' end', { 'lua' }),
            -- #include <|> pair for c and cpp
            Rule('#include <', '>', { 'c', 'cpp' }),
            -- Add spaces in pair after parentheses
            -- (|) --> space --> ( | )
            -- ( | ) --> ) --> ( )| BUG: not working
            -- FIX: a | b backspace removes both spaces -> a|b
            Rule(' ', ' ')
            :with_pair(function (opts)
                local pair_set = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({ '()', '[]', '{}' }, pair_set)
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
        -- Insert `()` after select function or method item
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )
    end,
    event = 'InsertEnter'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Coloring    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/echasnovski/mini.hipatterns THOUGHT: use for links ?
AddPlugin {
    -- https://github.com/FluxxField/bionic-reading.nvim
    'JellyApple102/easyread.nvim',
    cmd = 'EasyreadToggle',
    opts = {
        hlValues = {
            ['1'] = 1,
            ['2'] = 1,
            ['3'] = 2,
            ['4'] = 2,
            ['fallback'] = 0.4
        },
        hlgroupOptions = { link = 'Bold' },
        fileTypes = {},
        saccadeInterval = 0,
        saccadeReset = false,
        updateWhileInsert = true
    }
}

AddPlugin {
    'Pocco81/high-str.nvim',
    cmd = 'HSHighlight'
}

AddPlugin {
    -- BUG: hlargs priority overrides vim-illuminate
    'RRethy/vim-illuminate',
    config = function()
        require('illuminate').configure({
            providers = {
                'lsp',
                'treesitter',
                'regex'
            }
        })
        local bg
        if (vim.o.background == "dark" and not vim.g.ColoRand:find('pink-panic', 0, true)) then
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
            bg = LightenDarkenColor(string.format("%X", bg), 40)
        else
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
            bg = LightenDarkenColor(string.format("%X", bg), -40)
        end
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = bg })
        vim.cmd[[
           hi IlluminatedWordRead  guibg = #8AC926 guifg = #FFFFFF gui = bold
           hi IlluminatedWordWrite guibg = #FF595E guifg = #FFFFFF gui = italic
       ]]
    end,
    event = 'CursorHold'
}

-- FEAT: Use
-- AddPlugin {
--     'azabiong/vim-highlighter',
--     -- cmd = 'Hi',
--     config = function()
--     end,
--     lazy = false
--     -- keys = { '<Leader>g' }
-- }

AddPlugin {
    'folke/lsp-colors.nvim',
    event = 'LspAttach'
}

AddPlugin {
    'folke/todo-comments.nvim',
    opts = {
        colors = {
            default = { 'Identifier', '#7C3AED' },
            docs    = { 'Function', '#440381' },
            error   = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
            feat    = { 'Type', '#274C77' },
            hint    = { 'DiagnosticHint', '#10B981' },
            info    = { 'DiagnosticInfo', '#2563EB' },
            perf    = { 'String', '#C2F970' },
            test    = { 'Identifier', '#DDD92A' },
            todo    = { 'Keyword', '#1B998B' },
            warn    = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' }
        },
        keywords = {
            DOCME  = { icon = '', color = 'docs' },
            FEAT   = { icon = '󱩑', color = 'feat' },
            FIX    = { icon = '', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
            HACK   = { icon = '', color = 'hint' },
            NOTE   = { icon = '', color = 'info', alt = { 'INFO', 'THOUGHT' } },
            PERF   = { icon = '', color = 'perf', alt = { 'OPTIMIZE', 'PERFORMANCE' } },
            RECODE = { icon = '', color = 'info', alt = { 'REFACTOR' } },
            TEST   = { icon = '', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
            TODO   = { icon = '󰸞', color = 'todo' },
            WARN   = { icon = '!', color = 'warn', alt = { 'WARNING' } },
        },
        merge_keywords = false
    },
    keys = {
        { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
        { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' }
    }
}

AddPlugin {
    'kevinhwang91/nvim-hlslens',
    config = true,
    keys = { 'n', 'N', '*', '#', 'g*', 'g#' }
}

AddPlugin {
    'brenoprata10/nvim-highlight-colors',
    init = function()
        vim.api.nvim_create_user_command(
            'ColorToggle',
            function()
                require("nvim-highlight-colors").toggle()
            end,
            { nargs = 0 }
        )
    end,
    opts = {
        render = 'foreground'
    }
}
-- AddPlugin {
--     'NvChad/nvim-colorizer.lua',
--     cmd = 'ColorizerToggle',
--     config = true
-- }

-- BUG: not working for 2 windows
AddPlugin {
    'nvim-zh/colorful-winsep.nvim',
    opts = {
        symbols = { '─', '│', '╭', '╮', '╰', '╯' },
    },
    event = 'WinNew'
}

AddPlugin {
    't9md/vim-quickhl',
    config = function()
        local colors = {}
        for _,v in pairs(ColorPalette()) do
            local hi = "gui=italic,bold,underline guifg=#000000 guibg=" .. v.fg
            table.insert(colors, hi)
        end
        vim.g.quickhl_manual_colors = colors
    end,
    keys = {
        { '<Leader>w', '<Plug>(quickhl-manual-this-whole-word)', mode = 'n' },
        { '<Leader>w', '<Plug>(quickhl-manual-this)',            mode = 'x' },
        { '<Leader>W', '<Plug>(quickhl-manual-reset)',           mode = 'n' },
        { '<Leader>W', '<Plug>(quickhl-manual-reset)',           mode = 'x' }
    }
}

-- 'uga-rosa/ccc.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
function FixDiagnosticInfo()
    if (vim.o.background == 'light') then
        vim.cmd('hi clear DiagnosticInfo')
        vim.cmd('hi link DiagnosticInfo DiagnosticInformation')
    end
end

function FixIndentBlankline()
    for _, color in pairs({
        'IndentBlanklineChar',
        'IndentBlanklineContextChar',
        'IndentBlanklineContextSpaceChar',
        'IndentBlanklineSpaceChar',
    }) do
        local hl = vim.api.nvim_get_hl_by_name(color, true)
        hl.background = nil
        hl.nocombine = false
        vim.api.nvim_set_hl(0, color, hl)
    end
end

function FixLineNr(fg)
    vim.api.nvim_set_hl(0, 'LineNr', { fg = fg })
end

function FixNontext()
    local bg
    if (vim.o.background == 'dark') then
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, 60)
    else
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, -20)
    end
    vim.api.nvim_set_hl(0, 'NonText', { fg = bg })
    vim.api.nvim_set_hl(0, 'IndentBlanklineSpaceChar', { fg = bg })
end

function FixStarry(char, context_char)
    require('starry').setup({
        custom_highlights = {
            IndentBlanklineChar = { fg = char },
            IndentBlanklineContextChar = { fg = context_char },
            LineNr = { underline = false },
        },
    })
end

function FixVisual(bg)
    if bg == nil then
        if (vim.o.background ==  'dark') then
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
            bg = string.format('%X', bg)
            bg = LightenDarkenColor(bg, 50)
        else
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
            bg = string.format('%X', bg)
            bg = LightenDarkenColor(bg, -20)
        end
    end
    vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
end

function FixZellner()
    vim.defer_fn(
        function()
            vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#5F875F' })
            vim.api.nvim_set_hl(0, 'DiffChange', { fg = '#5F87AF' })
            vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#AF5FAF' })
            vim.api.nvim_set_hl(0, 'lualine_b_branch_normal', { bg = '#E5E5E5', fg = '#4A4A4A' })
            vim.api.nvim_set_hl(0, 'lualine_b_normal', { bg = '#E5E5E5', fg = '#4A4A4A' })
        end,
        3000
    )
end

-- https://github.com/SeniorMars/dotfiles/blob/master/.config/nvim/init.lua
function SeniorMarsTheme()
    require('gruvbox').setup({
        overrides = {
            CocCodeLens                = { fg = '#878787' },
            CocInlayHint               = { fg = '#87afaf' },
            CocWarningFloat            = { fg = '#dfaf87' },
            Comment                    = { fg = '#fe8019', italic = true },
            ContextVt                  = { fg = '#878787' },
            CursorLineNr               = { fg = '#fabd2f', bg = '#0E1018' },
            Define                     = { link = 'GruvboxPurple' },
            DiagnosticVirtualTextWarn  = { fg = '#dfaf87' },
            DiffAdd                    = { bold = true, reverse = false, fg = '', bg = '#2a4333' },
            DiffChange                 = { bold = true, reverse = false, fg = '', bg = '#333841' },
            DiffDelete                 = { bold = true, reverse = false, fg = '#442d30', bg = '#442d30' },
            DiffText                   = { bold = true, reverse = false, fg = '', bg = '#213352' },
            FoldColumn                 = { fg = '#fe8019', bg = '#0E1018' },
            Folded                     = { italic = true, fg = '#fe8019', bg = '#3c3836' },
            GruvboxAquaSign            = { fg = '#8EC07C', bg = '#0E1018' },
            GruvboxBlueSign            = { fg = '#83a598', bg = '#0E1018' },
            GruvboxGreenSign           = { fg = '#b8bb26', bg = '#0E1018' },
            GruvboxOrangeSign          = { fg = '#dfaf87', bg = '#0E1018' },
            GruvboxRedSign             = { fg = '#fb4934', bg = '#0E1018' },
            Macro                      = { link = 'GruvboxPurple' },
            Normal                     = { bg = '#0E1018' },
            SignColumn                 = { bg = '' },
            StatusLine                 = { bg = '#ffffff', fg = '#0E1018' },
            StatusLineNC               = { bg = '#3c3836', fg = '#0E1018' },
            VertSplit                  = { bg = '#0E1018' },
            WilderAccent               = { fg = '#f4468f', bg = '#0E1018' },
            WilderMenu                 = { fg = '#ebdbb2', bg = '#0E1018' },
            ['@constant.builtin']      = { link = 'GruvboxPurple' },
            ['@storageclass.lifetime'] = { link = 'GruvboxAqua' },
            ['@text.note']             = { link = 'TODO' },
        }
    })
end

-- https://github.com/lifepillar/vim-colortemplate
local colos = {}

local function Dark(opts)
    opts.bg = 'dark'
    table.insert(colos, opts)
end

local function Light(opts)
    opts.bg = 'light'
    table.insert(colos, opts)
end

AddPlugin { 'atelierbram/Base2Tone-nvim',       event = 'User base2tone'                                           }
AddPlugin { 'maxmx03/FluoroMachine.nvim',       event = 'User fluoromachine'                                       }
AddPlugin { 'Tsuzat/NeoSolarized.nvim',         event = 'User NeoSolarized'                                        }
AddPlugin { 'Mofiqul/adwaita.nvim',             event = 'User adwaita'                                             }
AddPlugin { 'ray-x/aurora',                     event = 'User aurora'                                              }
AddPlugin { 'w3barsi/barstrata.nvim',           event = 'User barstrata'                                           }
AddPlugin { 'uloco/bluloco.nvim',               event = 'User bluloco', dependencies = 'rktjmp/lush.nvim'          }
AddPlugin { 'lalitmee/cobalt2.nvim',            event = 'User cobalt2', dependencies = 'tjdevries/colorbuddy.nvim' }
AddPlugin { 'igorgue/danger',                   event = 'User danger'                                              }
AddPlugin { 'LunarVim/darkplus.nvim',           event = 'User darkplus'                                            }
AddPlugin { 'decaycs/decay.nvim',               event = 'User decay'                                               }
AddPlugin { 'muchzill4/doubletrouble',          event = 'User doubletrouble'                                       }
AddPlugin { 'sainnhe/edge',                     event = 'User edge'                                                }
AddPlugin { 'sainnhe/everforest',               event = 'User everforest'                                          }
AddPlugin { 'dundargoc/fakedonalds.nvim',       event = 'User fakedonalds'                                         }
AddPlugin { 'fenetikm/falcon',                  event = 'User falcon'                                              }
AddPlugin { 'felipeagc/fleet-theme-nvim',       event = 'User fleet'                                               }
AddPlugin { 'projekt0n/github-nvim-theme',      event = 'User github'                                              }
AddPlugin { 'luisiacc/gruvbox-baby',            event = 'User gruvbox-baby'                                        }
AddPlugin { 'ellisonleao/gruvbox.nvim',         event = 'User gruvbox'                                             }
AddPlugin { 'rebelot/kanagawa.nvim',            event = 'User kanagawa'                                            }
AddPlugin { 'lmburns/kimbox',                   event = 'User kimbox'                                              }
AddPlugin { 'marko-cerovac/material.nvim',      event = 'User material'                                            }
AddPlugin { 'savq/melange',                     event = 'User melange'                                             }
AddPlugin { 'loctvl842/monokai-pro.nvim',       event = 'User monokai-pro'                                         }
AddPlugin { 'shaunsingh/moonlight.nvim',        event = 'User moonlight'                                           }
AddPlugin { 'rafamadriz/neon',                  event = 'User neon'                                                }
AddPlugin { 'rose-pine/neovim',                 event = 'User rose-pine'                                           }
AddPlugin { 'Shatur/neovim-ayu',                event = 'User ayu'                                                 }
AddPlugin { 'EdenEast/nightfox.nvim',           event = 'User nightfox'                                            }
AddPlugin { 'talha-akram/noctis.nvim',          event = 'User noctis'                                              }
AddPlugin { 'gbprod/nord.nvim',                 event = 'User nord'                                                }
AddPlugin { 'AlexvZyl/nordic.nvim',             event = 'User nordic'                                              }
AddPlugin { 'catppuccin/nvim',                  event = 'User catppuccin'                                          }
AddPlugin { 'RRethy/nvim-base16',               event = 'User base16'                                              }
AddPlugin { 'theniceboy/nvim-deus',             event = 'User deus'                                                }
AddPlugin { 'kaiuri/nvim-juliana',              event = 'User juliana'                                             }
AddPlugin { 'sam4llis/nvim-tundra',             event = 'User tundra'                                              }
AddPlugin { 'mhartington/oceanic-next',         event = 'User OceanicNext'                                         }
AddPlugin { 'Yazeed1s/oh-lucy.nvim',            event = 'User oh-lucy'                                             }
AddPlugin { 'Th3Whit3Wolf/one-nvim',            event = 'User one-nvim'                                            }
AddPlugin { 'cpea2506/one_monokai.nvim',        event = 'User one_monokai'                                         }
AddPlugin { 'olimorris/onedarkpro.nvim',        event = 'User onedarkpro'                                          }
AddPlugin { 'rmehri01/onenord.nvim',            event = 'User onenord'                                             }
AddPlugin { 'nyoom-engineering/oxocarbon.nvim', event = 'User oxocarbon'                                           }
AddPlugin { 'JoosepAlviste/palenightfall.nvim', event = 'User palenightfall'                                       }
AddPlugin { 'NLKNguyen/papercolor-theme',       event = 'User PaperColor'                                          }
AddPlugin { 'Scysta/pink-panic.nvim',           event = 'User pink-panic', dependencies = 'rktjmp/lush.nvim'       }
AddPlugin { 'lewpoly/sherbet.nvim',             event = 'User sherbet'                                             }
AddPlugin { 'sainnhe/sonokai',                  event = 'User sonokai'                                             }
AddPlugin { 'pineapplegiant/spaceduck',         event = 'User spaceduck',                                          }
AddPlugin { 'ray-x/starry.nvim',                event = 'User starry'                                              }
AddPlugin { 'kvrohit/substrata.nvim',           event = 'User substrata'                                           }
AddPlugin { 'NTBBloodbath/sweetie.nvim',        event = 'User sweetie'                                             }
AddPlugin { 'jsit/toast.vim',                   event = 'User toast'                                               }
AddPlugin { 'tiagovla/tokyodark.nvim',          event = 'User tokyodark'                                           }
AddPlugin { 'folke/tokyonight.nvim',            event = 'User tokyonight'                                          }
AddPlugin { 'askfiy/visual_studio_code',        event = 'User visual_studio_code'                                  }
AddPlugin { 'embark-theme/vim',                 event = 'User embark'                                              }
AddPlugin { 'tomasiser/vim-code-dark',          event = 'User codedark'                                            }
AddPlugin { 'wuelnerdotexe/vim-enfocado',       event = 'User enfocado'                                            }
AddPlugin { 'ntk148v/vim-horizon',              event = 'User horizon'                                             }
AddPlugin { 'sickill/vim-monokai',              event = 'User vim-monokai'                                         }
AddPlugin { 'bluz71/vim-moonfly-colors',        event = 'User moonfly'                                             }
AddPlugin { 'bluz71/vim-nightfly-colors',       event = 'User nightfly'                                            }
AddPlugin { 'nxvu699134/vn-night.nvim',         event = 'User vn-night'                                            }
AddPlugin { 'Mofiqul/vscode.nvim',              event = 'User vscode'                                              }
AddPlugin { 'mcchrish/zenbones.nvim',           event = 'User zenbones', dependencies = 'rktjmp/lush.nvim'         }
AddPlugin { 'glepnir/zephyr-nvim',              event = 'User zephyr'                                              }
AddPlugin { 'titanzero/zephyrium',              event = 'User zephyrium'                                           }

Dark  { 'NeoSolarized',               '_'            }
Light { 'NeoSolarized',               '_'            }
Dark  { 'OceanicNext',                '_'            }
Dark  { 'PaperColor',                 '_',           post = FixNontext }
Light { 'PaperColor',                 '_',           post = FixNontext }
Dark  { 'adwaita',                    '_'            }
Light { 'adwaita',                    '_'            }
Dark  { 'aurora',                     '_'            }
Dark  { 'ayu-dark',                   'ayu'          }
Light { 'ayu-light',                  'ayu'          }
Dark  { 'ayu-mirage',                 'ayu'          }
Dark  { 'barstrata',                  '_'            }
Dark  { 'base2tone_lake_dark',        'base2tone'    }
Light { 'base2tone_mall_light',       'base2tone'    }
Dark  { 'base2tone_space_dark',       'base2tone'    }
Dark  { 'bluloco-dark',               '_'            }
Light { 'bluloco-light',              '_'            }
Dark  { 'carbonfox',                  'nightfox'     }
Dark  { 'catppuccin-frappe',          'catppuccin'   }
Light { 'catppuccin-latte',           'catppuccin'   }
Dark  { 'catppuccin-macchiato',       'catppuccin'   }
Dark  { 'catppuccin-mocha',           'catppuccin'   }
Dark  { 'cobalt2',                    '_',           post = function() require('colorbuddy').colorscheme('cobalt2') end }
Dark  { 'codedark',                   '_'            }
Light { 'danger_light',               'danger'       }
Dark  { 'dark-decay',                 'decay'        }
Dark  { 'darkplus',                   '_'            }
Dark  { 'darksolar',                  'starry',      pre = function() FixStarry('#691f48', '#922b64') end }
Dark  { 'dawnfox',                    'nightfox'                                                          }
Dark  { 'dayfox',                     'nightfox'                                                          }
Dark  { 'decay',                      '_'                                                                 }
Light { 'decay',                      '_'                                                                 }
Dark  { 'decayce',                    'decay'                                                             }
Dark  { 'deepocean',                  'starry',      pre = function() FixStarry('#392a48', '#5f4778') end }
Light { 'delek',                      '_'                                                                 }
Dark  { 'deus',                       '_',           post = FixVisual                                     }
Dark  { 'doubletrouble',              '_'                                                                 }
Dark  { 'dracula_blood',              'starry',      pre = function() FixStarry('#322738', '#54415e') end }
Dark  { 'duskfox',                    'nightfox'                                                          }
Dark  { 'earlysummer',                'starry',      pre = function() FixStarry('#3f2b4c', '#694980') end }
Dark  { 'edge',                       '_'                                                                 }
Light { 'edge',                       '_'                                                                 }
Dark  { 'embark',                     '_'                                                                 }
Dark  { 'emerald',                    'starry',      pre = function() FixStarry('#1a391d', '#2c5f31') end }
Dark  { 'enfocado',                   '_'                                      }
Light { 'enfocado',                   '_'                                      }
Dark  { 'everforest',                 '_'                                      }
Light { 'everforest',                 '_'                                      }
Dark  { 'fakedonalds',                '_'                                      }
Dark  { 'falcon',                     '_'                                      }
Dark  { 'fleet',                      '_'                                      }
Dark  { 'fluoromachine',              '_',           post = FixIndentBlankline }
Dark  { 'forestbones',                'zenbones'                               }
Dark  { 'github_dark',                'github'                                 }
Light { 'github_light',               'github'                                 }
Dark  { 'gruvbox',                    '_'                                      }
Light { 'gruvbox',                    '_'                                      }
Dark  { 'gruvbox',                    '_',           pre  = SeniorMarsTheme    }
Dark  { 'gruvbox-baby',               '_'                                      }
Dark  { 'habamax',                    '_',                                     }
Dark  { 'horizon',                    '_'                                      }
Dark  { 'juliana',                    '_',           post = function() FixLineNr('#999999') end                                                               }
Dark  { 'kanagawa',                   '_'                                                                                                                     }
Dark  { 'kimbox',                     '_',           post = FixVisual                                                                                         }
Light { 'limestone',                  'starry',      pre = function() FixStarry('#223216', '#395425') end                                                     }
Dark  { 'lunaperche',                 '_'                                                                                                                     }
Dark  { 'mariana',                    'starry',      pre = function() FixStarry('#414346', '#6c6f75') end                                                     }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'darker'     end                                                 }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'deep ocean' end                                                 }
Light { 'material',                   '_',           pre = function() vim.g.material_style = 'lighter'    end, post = function() FixVisual('#CCEAE7') end     }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'oceanic'    end                                                 }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'palenight'  end, post = function() FixLineNr('#757DA4') end     }
Dark  { 'material',                   'starry',      pre = function() FixStarry('#35393b', '#585f63') end                                                     }
Dark  { 'melange',                    '_'                                                                                                                     }
Light { 'melange',                    '_'                                                                                                                     }
Dark  { 'monokai',                    'starry',      pre = function() FixStarry('#483a1f', '#786233') end                                                     }
Dark  { 'monokai',                    'vim-monokai'                                                                                                           }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'classic'})   end                                }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'machine'})   end                                }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'octagon'})   end                                }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'pro'})       end, post = FixVisual              }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'ristretto'}) end                                }
Dark  { 'monokai-pro',                '_',           pre = function() require('monokai-pro').setup({filter = 'spectrum'})  end                                }
Dark  { 'moonfly',                    '_'                                                                                                                     }
Dark  { 'moonlight',                  '_'                                                                                                                     }
Dark  { 'moonlight',                  'starry',      pre = function() FixStarry('#363149', '#5a527a') end                                                     }
Light { 'neobones',                   'zenbones'                                                                                                              }
Dark  { 'neon',                       '_',           pre = function() vim.g.neon_style = 'default' end, post = FixVisual                                      }
Dark  { 'neon',                       '_',           pre = function() vim.g.neon_style = 'doom'    end, post = FixVisual                                      }
Light { 'neon',                       '_',           pre = function() vim.g.neon_style = 'light'   end, post = function() FixVisual() FixDiagnosticInfo() end }
Dark  { 'nightfly',                   '_'            }
Dark  { 'nightfox',                   'nightfox'     }
Dark  { 'noctis_azureus',             'noctis'       }
Light { 'noctis_hibernus',            'noctis'       }
Light { 'noctis_lilac',               'noctis'       }
Light { 'noctis_lux',                 'noctis'       } -- BUG: problem with navic
Dark  { 'noctis_minimus',             'noctis'       }
Dark  { 'noctis_sereno',              'noctis'       }
Dark  { 'nord',                       '_'            }
Dark  { 'nordbones',                  'zenbones'     }
Dark  { 'nordfox',                    'nightfox'     }
Dark  { 'nordic',                     '_'            }
Dark  { 'oceanic',                    'starry',      pre = function() FixStarry('#3f2f4c', '#694e7f') end }
Dark  { 'oh-lucy-evening',            'oh-lucy'      }
Dark  { 'one-nvim',                   '_'            }
Dark  { 'one_monokai',                '_'            }
Dark  { 'onedark',                    'onedarkpro'   }
Dark  { 'onedark_vivid',              'onedarkpro'   }
Light { 'onelight',                   '_'            }
Dark  { 'onenord',                    '_'            }
Light { 'onenord',                    '_'            }
Dark  { 'oxocarbon',                  '_'            }
Light { 'oxocarbon',                  '_'            }
Dark  { 'palenight',                  'starry',      pre = function() FixStarry('#3c2c46', '#644975') end }
Dark  { 'palenightfall',              '_'            }
Light { 'pink-panic',                 '_'            }
Dark  { 'rose-pine',                  '_'            }
Light { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'dawn'}) end }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'main'}) end }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'moon'}) end }
Dark  { 'rosebones',                  'zenbones'     }
Light { 'rosebones',                  'zenbones'     }
Dark  { 'sherbet',                    '_'            }
Light { 'shine',                      '_',           post = FixNontext                                      }
Dark  { 'slate',                      '_',           post = FixNontext                                      }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'andromeda' end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'atlantis'  end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'default'   end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'maia'      end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'shusia'    end }
Dark  { 'spaceduck',                  '_'                                                                   }
Dark  { 'substrata',                  '_'                                                                   }
Dark  { 'sweetie',                    '_'                                                                   }
Light { 'sweetie',                    '_'                                                                   }
Dark  { 'terafox',                    'nightfox'                                                            }
Dark  { 'toast',                      '_'                                                                   }
Light { 'toast',                      '_'                                                                   }
Light { 'tokyobones',                 'zenbones'                                                            }
Dark  { 'tokyodark',                  '_'                                                                   }
Light { 'tokyonight-day',             'tokyonight'                                                          }
Dark  { 'tokyonight-moon',            'tokyonight'                                                          }
Dark  { 'tokyonight-night',           'tokyonight'                                                          }
Dark  { 'tokyonight-storm',           'tokyonight'                                                          }
Dark  { 'tundra',                     '_',           pre = function() require('nvim-tundra').setup() end    }
Dark  { 'visual_studio_code_dark',    'visual_studio_code'                                                  }
Light { 'visual_studio_code_light',   'visual_studio_code'                                                  }
Dark  { 'vn-night',                   '_',           post = function() FixLineNr('#505275') end             }
Dark  { 'vscode',                     '_'                                                                   }
Light { 'vscode',                     '_'                                                                   }
Light { 'zellner',                    '_',           post = FixZellner                                      } -- BUG: sometimes does not work
Dark  { 'zenburned',                  'zenbones'                                                            }
Light { 'zenwritten',                 'zenbones'                                                            }
Dark  { 'zephyr',                     '_'                                                                   }
Dark  { 'zephyrium',                  '_'                                                                   }

function ColoRand(ind)
    math.randomseed(os.time())
    ind = ind or math.random(1, #colos)
    local selection = colos[ind]
    local scheme = selection[1]
    local bg = selection.bg
    local module = selection[2]
    local precmd = selection.pre
    local postcmd = selection.post
    vim.o.background = bg
    local start_time = os.clock()
    vim.api.nvim_exec_autocmds('User', {pattern = module == '_' and scheme or module}) -- Load colorscheme
    if (precmd) then
        precmd()
    end
    vim.cmd.colorscheme(scheme)
    vim.cmd[[highlight clear CursorLine]]
    if (postcmd) then
        postcmd()
    end
    vim.g.ColoRand = ind .. ':' .. scheme .. ':' .. bg .. ':' .. module .. ':' .. os.clock() - start_time
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup({
            ignore = '^$',
            extra = { eol = 'gce' },
        })

        require('Comment.ft').set('ps1', {'# %s', '<# %s #>'})
        require('Comment.ft').set('python', {'# %s', '""" %s """'})
    end,
    keys = {
        { 'gc', mode = { 'n', 'v' } },
        { 'gb', mode = { 'n', 'v' } },
        'gcc', 'gbc', 'gcO', 'gco', 'gce'
    }
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Completion   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- FIX: slow completion
    -- FEAT: cmp-path for windows
    'hrsh7th/nvim-cmp',
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'cmdline' },
                    { name = 'path' },
                }
            }),
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            }),
            completion = {
                keyword_length = 2
            },
            experimental = {
                ghost_text = true
            },
            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(entry, vim_item)
                    if entry.source.name == 'nvim_lsp' then
                        vim_item.menu = '{' .. entry.source.source.client.name .. '}'
                    elseif entry.source.name == 'cmdline' then
                        vim_item.kind = 'Options'
                    elseif entry.source.name == 'cmdline_history' then
                        vim_item.kind = 'History'
                    else
                        vim_item.menu = '[' .. entry.source.name .. ']'
                    end
                    local kind_symbol = vim.g.cmp_kinds[vim_item.kind]
                    vim_item.kind = kind_symbol or vim_item.kind

                    return vim_item
                end
            },
            mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
                ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Scroll the documentation window if visible
                ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Scroll the documentation window if visible
                ['<C-e>'] = cmp.mapping.abort(),
                ['<TAB>'] = cmp.mapping.confirm({ select = true }),
            }),
            snippet = {
                expand = function(args)
                    -- vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
                    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
                end
            },
            sources = ({
                {
                    name = 'buffer',
                    option = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs() -- BUG: disable for buffers > 1000 lines
                        end
                    },
                    priority = 1
                },
                -- { name = 'fuzzy_buffer' },
                { name = 'neorg' },
                { name = 'nerdfont' },
                { name = 'nvim_lsp', priority = 2 },
                { name = 'path' },
                { name = 'snippy', priority = 3 },
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        for key, value in pairs(kind_hl) do
            vim.api.nvim_set_hl(0, 'CmpItemKind' .. key, value[vim.o.background])
        end
        vim.cmd([[
            hi CmpItemAbbrDeprecated gui = strikethrough
            hi CmpItemAbbrMatch gui = bold
            hi CmpItemAbbrMatchFuzzy gui = underline
        ]])
    end,
    dependencies = {
        'chrisgrieser/cmp-nerdfont',
        'dcampos/cmp-snippy',
        'dcampos/nvim-snippy',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        -- { 'tzachar/cmp-fuzzy-buffer', dependencies = {'tzachar/fuzzy.nvim', dependencies = { 'romgrk/fzy-lua-native', build = 'make' }} }, -- FIX: fzy-lua-native make is not working
    }, -- PERF: check if lazy
    event = 'CmdlineEnter',
}

-- https://github.com/jameshiew/nvim-magic
-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/lukas-reineke/cmp-rg
-- https://github.com/lukas-reineke/cmp-under-comparator
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Debugger    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO:
-- Abstract-IDE dap configs
-- --------------------------
-- -- telescope-dap.nvim
-- pcall(require'telescope'.load_extension, 'dap')
-- --------------------------
--
--
-- --------------------------
-- -- nvim-dap-ui
-- require('dapui').setup({
-- 	icons = {expanded = '▾', collapsed = '▸'},
-- 	-- Expand lines larger than the window
-- 	-- Requires >= 0.7
-- 	expand_lines = vim.fn.has('nvim-0.7'),
-- 	sidebar = {
-- 		-- You can change the order of elements in the sidebar
-- 		elements = {
-- 			-- Provide as ID strings or tables with 'id' and 'size' keys
-- 			{
-- 				id = 'scopes',
-- 				size = 0.25, -- Can be float or integer > 1
-- 			},
-- 			{id = 'breakpoints', size = 0.25},
-- 			{id = 'stacks', size = 0.25},
-- 			{id = 'watches', size = 00.25},
-- 		},
-- 		size = 40,
-- 		position = 'left', -- Can be 'left', 'right', 'top', 'bottom'
-- 	},
-- 	tray = {
-- 		elements = {'repl', 'console'},
-- 		size = 10,
-- 		position = 'bottom', -- Can be 'left', 'right', 'top', 'bottom'
-- 	},
-- 	floating = {
-- 		max_height = nil, -- These can be integers or a float between 0 and 1.
-- 		max_width = nil, -- Floats will be treated as percentage of your screen.
-- 		border = 'single', -- Border style. Can be 'single', 'double' or 'rounded'
-- 		mappings = {close = {'q', '<Esc>'}},
-- 	},
-- 	windows = {indent = 1},
-- 	render = {
-- 		max_type_length = nil, -- Can be integer or nil.
-- 	},
-- })
-- 
-- -- end nvim-dap-ui
-- --------------------------
-- 
-- --------------------------
-- -- nvim-dap-virtual-text
-- require('nvim-dap-virtual-text').setup {
-- 	enabled = true, -- enable this plugin (the default)
-- 	enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
-- 	highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
-- 	highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
-- 	show_stop_reason = true, -- show stop reason when stopped for exceptions
-- 	commented = false, -- prefix virtual text with comment string
-- 	only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
-- 	all_references = false, -- show virtual text on all all references of the variable (not only definitions)
-- 	filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
-- 	-- experimental features:
-- 	virt_text_pos = 'eol', -- position of virtual text, see `:h nvim_buf_set_extmark()`
-- 	all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
-- 	virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
-- 	virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
-- 	-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
-- }
-- -- end nvim-dap-virtual-text
-- -- end nvim-dap
-- https://github.com/PatschD/zippy.nvim
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/jay-babu/mason-nvim-dap.nvim
-- AddPlugin {
--     'jbyuki/one-small-step-for-vimkind',
--     config = function()
--         local dap = require('dap')
--         dap.configurations.lua = {
--             {
--                 type = 'nlua',
--                 request = 'attach',
--                 name = 'Attach to running Neovim instance',
--             }
--         }

--         dap.adapters.nlua = function(callback, config)
--             callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
--         end
--     end,
--     lazy = true
-- }
-- https://github.com/nvim-telescope/telescope-vimspector.nvim
-- https://github.com/puremourning/vimspector
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'Pocco81/dap-buddy.nvim'
-- AddPlugin {
--     -- TODO: List down topics to work on
--     'mfussenegger/nvim-dap',
--     config = function()
--         vim.api.nvim_set_keymap('n', '<F9>', [[:lua require("dap").toggle_breakpoint()<CR>]], { noremap = true })
--         vim.api.nvim_set_keymap('n', '<F5>', [[:lua require("dap").continue()<CR>]], { noremap = true })
--         vim.api.nvim_set_keymap('n', '<F10>', [[:lua require("dap").step_over()<CR>]], { noremap = true })
--         vim.api.nvim_set_keymap('n', '<F11>', [[:lua require("dap").step_into()<CR>]], { noremap = true })
--         vim.api.nvim_set_keymap('n', '<F12>', [[:lua require("dap.ui.widgets").hover()<CR>]], { noremap = true })
--         vim.api.nvim_set_keymap('n', '<F5>', [[:lua require("osv").launch({port = 8086})<CR>]], { noremap = true })
--         --[[ vim.cmd[[
--             nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
--             nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
--             nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
--             nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
--             nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
--             nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
--             nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
--             nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
--             nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
--         ]]
--     end,
--     lazy = true
-- }
-- use 'mfussenegger/nvim-dap-python'
-- use 'rcarriga/nvim-dap-ui'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Doc Generater  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'danymat/neogen',
    cmd = 'Neogen',
    config = true
}
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ File Explorer  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- TODO: review config help
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    -- BUG: lazy load directory case
    opts = {
        actions = {
            change_dir = {
                enable = true,
                global = false,
                restrict_above_cwd = false,
            },
            expand_all = {
                exclude = { '.git' },
                max_folder_discovery = 300,
            },
            file_popup = {
                open_win_config = {
                    border = 'rounded',
                    col = 1,
                    relative = 'cursor',
                    row = 1,
                    style = 'minimal',
                },
            },
            open_file = {
                quit_on_open = false,
                resize_window = true,
                window_picker = {
                    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
                    enable = true,
                    exclude = {
                        buftype = { 'nofile', 'terminal', 'help' },
                        filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
                    },
                    picker = 'default',
                },
            },
            remove_file = { close_window = true },
            use_system_clipboard = true,
        },
        auto_reload_on_write = true,
        diagnostics = {
            debounce_delay = 50,
            enable = true,
            icons = {
                error   = Icons.diagnostic.error,
                hint    = Icons.diagnostic.hint,
                info    = Icons.diagnostic.info,
                warning = Icons.diagnostic.warn,
            },
            severity = {
                min = vim.diagnostic.severity.HINT,
                max = vim.diagnostic.severity.ERROR,
            },
            show_on_dirs = true,
            show_on_open_dirs = false,
        },
        disable_netrw = true,
        filesystem_watchers = {
            enable = true,
            debounce_delay = 50,
            ignore_dirs = {},
        },
        filters = {
            dotfiles = false,
            git_clean = false,
            no_buffer = false,
            custom = {},
            exclude = {},
        },
        git = {
            enable = true,
            ignore = true,
            show_on_dirs = true,
            show_on_open_dirs = true,
            timeout = 400,
        },
        hijack_cursor = true,
        hijack_directories = {
            auto_open = true,
            enable = true,
        },
        hijack_netrw = true,
        hijack_unnamed_buffer_when_opening = false,
        live_filter = {
            always_show_folders = true,
            prefix = '󰈲 ',
        },
        log = {
            enable = false,
            truncate = false,
            types = {
                all         = false,
                config      = false,
                copy_paste  = false,
                dev         = false,
                diagnostics = false,
                git         = false,
                profile     = false,
                watcher     = false,
            },
        },
        modified = {
            enable = true,
            show_on_dirs = true,
            show_on_open_dirs = true
        },
        notify = { threshold = vim.log.levels.INFO },
        on_attach = 'disable',
        prefer_startup_root = false,
        reload_on_bufenter = false,
        renderer = {
            add_trailing = true,
            full_name = true,
            group_empty = false,
            highlight_git = true,
            highlight_opened_files = 'all',
            highlight_modified = 'all',
            indent_markers = {
                enable = true,
                icons = {
                    bottom = '─',
                    corner = '╰',
                    edge   = '│',
                    item   = '├',
                    none   = ' ',
                },
                inline_arrows = true,
            },
            indent_width = 2,
            root_folder_label = ':~:s?$?/..?',
            icons = {
                git_placement = 'signcolumn',
                glyphs = {
                    bookmark = '',
                    default  = '',
                    folder = {
                        arrow_closed = '',
                        arrow_open   = '',
                        default      = '',
                        empty        = '',
                        empty_open   = '',
                        open         = '',
                        symlink      = '',
                        symlink_open = '',
                    },
                    git = {
                        deleted   = '󰧧',
                        ignored   = '',
                        renamed   = '➜',
                        staged    = '', -- FIX: icon
                        unmerged  = '',
                        unstaged  = '', -- FIX: icon
                        untracked = '',
                    },
                    symlink = '󱅷',
                },
                modified_placement = 'after',
                padding = ' ',
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                    modified = true
                },
                symlink_arrow = ' 壟 ',
                webdev_colors = true,
            },
            special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md' },
            symlink_destination = true,
        },
        respect_buf_cwd = false,
        root_dirs = {},
        select_prompts = false,
        sort_by = 'name',
        sync_root_with_cwd = true,
        system_open = {
            cmd = '',
            args = {},
        },
        tab = {
            sync = {
                close = false,
                ignore = {},
                open = false,
            },
        },
        trash = {
            cmd = 'gio trash',
            require_confirm = true,
        },
        ui = {
            confirm = {
                remove = true,
                trash = true
            }
        },
        update_focused_file = {
            debounce_delay = 15,
            enable = true,
            ignore_list = {},
            update_root = true,
        },
        view = {
            adaptive_size = false,
            centralize_selection = false,
            cursorline = false,
            float = {
                enable = false,
                open_win_config = {
                    border = 'rounded',
                    col = 1,
                    height = 30,
                    relative = 'editor',
                    row = 1,
                    width = 30,
                },
                quit_on_focus_loss = true,
            },
            hide_root_folder = false,
            mappings = {
                custom_only = false,
                list = {
                    { key = '<C-s>', action = 'split'}
                },
            },
            number = false,
            preserve_window_proportions = false,
            relativenumber = false,
            side = 'left',
            signcolumn = 'yes',
            width = 30,
        },
    }
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  File Options  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- autocmd BufNewFile,BufRead *.csproj set filetype=csproj
ActionsMap = {
    -- ['vim'] = function ()
    --     print('I am vim')
    -- end
}
vim.api.nvim_create_autocmd(
    'FileType', {
        pattern = '*',
        desc = 'Run custom actions per filetype',
        callback = function()
            local actions = ActionsMap[vim.o.filetype]
            if actions then
                actions()
            end
        end
    }
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Folding     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: work on it
AddPlugin {
    'anuvyklack/pretty-fold.nvim',
    -- cond = function()
    --     return vim.o.foldmethod == 'marker'
    -- end,
    config = function()
        require('pretty-fold').setup({
            sections = {
                left = {
                    'content',
                },
                right = {
                    ' ', 'number_of_folded_lines', ': ', 'percentage', ' ',
                    function(config) return config.fill_char:rep(3) end
                }
            },
            fill_char = '󰧟',

            remove_fold_markers = true,

            -- Keep the indentation of the content of the fold string.
            keep_indentation = true,

            -- Possible values:
            -- "delete" : Delete all comment signs from the fold string.
            -- "spaces" : Replace all comment signs with equal number of spaces.
            -- false    : Do nothing with comment signs.
            process_comment_signs = 'spaces',

            -- Comment signs additional to the value of `&commentstring` option.
            comment_signs = {},

            -- List of patterns that will be removed from content foldtext section.
            stop_words = {
                '@brief%s*', -- (for C++) Remove '@brief' and all spaces after.
            },

            add_close_pattern = true, -- true, 'last_line' or false

            matchup_patterns = {
                {  '{', '}' },
                { '%(', ')' }, -- % to escape lua pattern char
                { '%[', ']' }, -- % to escape lua pattern char
            },

            ft_ignore = { 'neorg' },
        })
    end,
    lazy = false
}

-- TODO: work on it
AddPlugin {
    'kevinhwang91/nvim-ufo',
    -- cond = function()
    --     return vim.o.foldmethod ~= 'marker'
    -- end,
    config = function()
        vim.o.foldcolumn = '1' -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        require('ufo').setup({
            provider_selector = function(_, _, _)
                return {'treesitter', 'indent'}
            end
        })
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    end,
    dependencies = 'kevinhwang91/promise-async',
    enabled = false,
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Formatting   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'sbdchd/neoformat',
    cmd = 'Neoformat'
}
-- use 'joechrisellis/lsp-format-modifications.nvim'
-- use 'lukas-reineke/format.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      FZF       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/gfanto/fzf-lsp.nvim
AddPlugin { -- BUG: not working
    'ojroques/nvim-lspfuzzy',
    config = true,
    dependencies = {
        'junegunn/fzf',
        'junegunn/fzf.vim'
    }
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Git       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- TODO: fix this plugin
    'aaronhallaert/advanced-git-search.nvim',
    config = function()
        -- optional: setup telescope before loading the extension
        require('telescope').setup{
            -- move this to the place where you call the telescope setup function
            extensions = {
                advanced_git_search = {
                    -- fugitive or diffview
                    diff_plugin = 'diffview',
                    -- customize git in previewer
                    -- e.g. flags such as { '--no-pager' }, or { '-c', 'delta.side-by-side=false' }
                    git_flags = {},
                    -- customize git diff in previewer
                    -- e.g. flags such as { '--raw' }
                    git_diff_flags = {},
                    -- Show builtin git pickers when executing 'show_custom_functions' or :AdvancedGitSearch
                    show_builtin_git_pickers = true,
                }
            }
        }

        require('telescope').load_extension('advanced_git_search')
    end
}
-- https://github.com/akinsho/git-conflict.nvim
-- https://github.com/cynix/vim-mergetool
-- use 'hotwatermorning/auto-git-diff'
-- use 'ldelossa/gh.nvim'
AddPlugin {
    'lewis6991/gitsigns.nvim',
    cmd = 'Gitsigns',
    opts = {
        attach_to_untracked = true,
        count_chars = {
            [1]   = '',
            [2]   = '2',
            [3]   = '3',
            [4]   = '4',
            [5]   = '5',
            [6]   = '6',
            [7]   = '7',
            [8]   = '8',
            [9]   = '9',
            ['+'] = '',
        },
        current_line_blame_formatter = ' 󰀄 <author> 󰔟 <committer_time:%R>  <summary>',
        diff_opts = {
            internal = true
        },
        on_attach = function (bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, {expr=true})

            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, {expr=true})
        end,
        preview_config = {
            border = 'rounded'
        },
        signs = {
            add          = { hl = 'GitSignsAdd'   ,       text = '┃', numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'   , show_count = false },
            change       = { hl = 'GitSignsChange',       text = '󰇝', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
            delete       = { hl = 'GitSignsDelete',       text = '', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = true  },
            topdelete    = { hl = 'GitSignsDelete',       text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
            changedelete = { hl = 'GitSignsChangedelete', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
        },
        trouble = false
    },
    keys = { '[c', ']c' }
}

AddPlugin {
    'rhysd/git-messenger.vim',
    config = function()
        vim.g.git_messenger_floating_win_opts = { ['border'] = 'rounded' }
        -- vim.g.git_messenger_include_diff = 'current'
        vim.g.git_messenger_max_popup_height = 20
        vim.g.git_messenger_max_popup_width = 80
        vim.g.git_messenger_popup_content_margins = false
    end,
    cmd = "GitMessenger"
}

AddPlugin {
    'sindrets/diffview.nvim',
    cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Icons      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'DaikyXendo/nvim-material-icon',
    opts = {
        override = {
            ['c++']  = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
            cc       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
            cp       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cp'        },
            cpp      = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cpp'       },
            cs       = { color = '#596706', cterm_color = '58',  icon = '', name = 'Cs'        },
            csproj   = { color = '#854CC7', cterm_color = '98',  icon = '', name = 'Csproj'    },
            csv      = { color = '#89E051', cterm_color = '113', icon = '', name = 'Csv'       },
            makefile = { color = '#6d8086', cterm_color = '66',  icon = '', name = 'Makefile'  },
            md       = { color = '#42A5F5', cterm_color = '75',  icon = '', name = 'Md'        },
            mdx      = { color = '#519ABA', cterm_color = '67',  icon = '', name = 'Mdx'       },
            norg     = { color = '#40916C', cterm_color = '48',  icon = '', name = 'Neorg'     },
            ps1      = { color = '#4D5A5E', cterm_color = '240', icon = '', name = 'PromptPs1' },
            yaml     = { color = '#f44336', cterm_color = '203', icon = '󰙅', name = 'Yaml'      },
        }
    }
}

AddPlugin {
    'kyazdani42/nvim-web-devicons',
    config = function()
        require('nvim-web-devicons').setup({
            override = require('nvim-material-icon').get_icons()
        })
        require("nvim-web-devicons").set_default_icon('', '#6d8086', 66)
    end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Indentation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FIX: indentation for public:/private:... for c++
AddPlugin {
    -- FIX: does not work when indent space is 2 in file, shiftwidth is the option
    -- PERF: delay in autocmd to speed up scrolling
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require("indent_blankline").setup {
            bufname_exclude = {},
            buftype_exclude = { 'nofile', 'prompt', 'quickfix', 'terminal' },
            char = '│',
            char_blankline = '│', -- '┆'
            char_priority = 1,
            context_char = '║', -- '┃'
            context_char_blankline = '║', -- '┇'
            context_start_priority = 1,
            filetype_exclude = { 'NvimTree', 'checkhealth', 'help', 'lspinfo', 'man', 'norg' },
            show_current_context = true,
            show_current_context_start = true,
        }
        -- vim.cmd.IndentBlanklineRefresh()
    end,
    event = 'CursorHold'
}
-- AddPlugin { -- TODO:
--     'shellRaining/hlchunk.nvim',
--     event = 'CursorHold',
--     opts = {
--         chunk = {
--             enable = true,
--             use_treesitter = true,
--             chars = {
--                 horizontal_line = "─",
--                 vertical_line = "│",
--                 left_top = "╭",
--                 left_bottom = "╰",
--                 right_arrow = ">",
--             },
--             style = {
--                 { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("IndentBlanklineContextChar")), "fg", "gui") }
--             },
--         },

--         indent = {
--             enable = true,
--             use_treesitter = false,
--             chars = {
--                 "│",
--             },
--             style = {
--                 { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("IndentBlanklineChar")), "fg", "gui") }
--             },
--         },

--         line_num = {
--             enable = true,
--             use_treesitter = false,
--             style = "#806d9c",
--         },

--         blank = {
--             enable = true,
--             chars = {
--                 "․",
--             },
--             style = {
--                 vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
--             },
--         },
--     }
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      LSP       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: use 'Decodetalkers/csharpls-extended-lsp.nvim'
-- TODO: use 'Hoffs/omnisharp-extended-lsp.nvim'
-- TODO: https://github.com/DNLHC/glance.nvim
-- TODO: https://github.com/antosha417/nvim-lsp-file-operations
-- TODO: resolve navic with Lspsaga symbols

AddPlugin {
    'SmiteshP/nvim-navbuddy',
    opts = {
        lsp = {
            auto_attach = true
        }
    },
    lazy = false
}

AddPlugin {
    -- TODO: https://github.com/utilyre/barbecue.nvim
    'SmiteshP/nvim-navic',
    config = function()
        require('nvim-navic').setup({
            click = true,
            depth_limit = 0,
            depth_limit_indicator = '',
            highlight = true,
            icons = vim.g.cmp_kinds,
            safe_output = true,
            separator = '  '
        })
        for key, value in pairs(kind_hl) do
            vim.api.nvim_set_hl(0, 'NavicIcons' .. key, value[vim.o.background])
        end
    end
}

AddPlugin {
    'VidocqH/lsp-lens.nvim',
    event = 'LspAttach',
    opts = {
        enable = true,
        include_declaration = true,      -- Reference include declaration
        sections = {                      -- Enable / Disable specific request
            definition = true,
            references = true,
            implementation = true,
        },
        ignore_filetype = {
        },
    }
}

-- TODO: Resolve usage
AddPlugin {
    'liuchengxu/vista.vim',
    config = function()
        vim.cmd[[
            let g:vista_default_executive = 'nvim_lsp'
            let g:vista_icon_indent = ['╰─ ', '├─ ']
            " TODO: use global icons
            let g:vista#renderer#icons = {
                \   'constant': '',
                \   'class': '',
                \   'function': '',
                \   'variable': '',
                \  }
        ]]
    end,
    cmd = 'Vista'
}

AddPlugin {
    'lvimuser/lsp-inlayhints.nvim',
    branch = 'anticonceal',
    event = 'LspAttach',
    config = true
}

AddPlugin {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
        ui = {
            border = 'rounded'
        }
    }
}


AddPlugin {
    'williamboman/mason-lspconfig.nvim',
    cmd = 'LspToggle',
    config = function()
        -- Toggle LSP
        vim.api.nvim_create_user_command(
            'LspToggle',
            function()
                if #vim.lsp.get_active_clients({bufnr = 0}) == 0 then
                    vim.cmd('LspStart')
                else
                    vim.cmd('LspStop') -- create key maps to toggle again
                end
            end,
            { nargs = 0 }
        )

        local mason_lspconfig = require('mason-lspconfig')
        mason_lspconfig.setup()
        -- vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]
        local opts = { noremap=true, silent=true }
        -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        local on_attach = function(client, bufnr)
            local navic = require('nvim-navic')
            local navbuddy = require("nvim-navbuddy")
            -- Mappings.
            -- require("nvim-navbuddy").attach(client, bufnr)
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            require("lsp-inlayhints").on_attach(client, bufnr)
            vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<F2>', '<cmd>Lspsaga rename<CR>', bufopts)
            vim.keymap.set('n', '<S-F12>', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<leader>h', '<cmd>Lspsaga hover_doc<CR>', bufopts)
            vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', bufopts)
            vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', bufopts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wl', function()
            --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, bufopts)
            -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

            vim.cmd[[
                aunmenu PopUp
            ]]

            -- FEAT: better popup management
            PopupMenuAdd('Declaration            gD',  '<Cmd>lua vim.lsp.buf.declaration()<CR>')
            PopupMenuAdd('Definition            F12',  '<Cmd>lua vim.lsp.buf.definition()<CR>')
            PopupMenuAdd('Hover                  \\h', '<Cmd>Lspsaga hover_doc<CR>')
            PopupMenuAdd('Implementation         gi',  '<Cmd>lua vim.lsp.buf.implementation()<CR>')
            PopupMenuAdd('LSP Finder',                 '<Cmd>Lspsaga lsp_finder<CR>')
            PopupMenuAdd('References      Shift F12',  '<Cmd>lua vim.lsp.buf.references()<CR>')
            PopupMenuAdd('Rename                 F2',  '<Cmd>Lspsaga rename<CR>')
            PopupMenuAdd('Type Definition        gt',  '<Cmd>lua vim.lsp.buf.type_definition()<CR>')

            navbuddy.attach(client, bufnr)
            navic.attach(client, bufnr)
        end

        -- LSP settings (for overriding per client)
        local handlers =  {
            -- ['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border_shape}),
            -- ['textDocument/signatureHelp'] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border_shape}), -- disable in favour of Noice
            ['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
            ['textDocument/signatureHelp'] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded'}), -- disable in favour of Noice
        }

        -- TODO: resolve these comments
        -- Add additional capabilities supported by nvim-cmp
        -- -- Gets a new ClientCapabilities object describing the LSP client
        -- -- capabilities.
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities.textDocument.completion.completionItem = {
        --     documentationFormat = {
        --         'markdown',
        --         'plaintext',
        --     },
        --     snippetSupport = true,
        --     preselectSupport = true,
        --     insertReplaceSupport = true,
        --     labelDetailsSupport = true,
        --     deprecatedSupport = true,
        --     commitCharactersSupport = true,
        --     tagSupport = {
        --         valueSet = { 1 },
        --     },
        --     resolveSupport = {
        --         properties = {
        --             'documentation',
        --             'detail',
        --             'additionalTextEdits',
        --         },
        --     },
        -- }
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        mason_lspconfig.setup_handlers {
            function (server_name)
                local lspconfig = require('lspconfig')
                if server_name == 'powershell_es' then
                    lspconfig.powershell_es.setup { -- FIX: fix powershell
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services" -LogPath "./powershell_es.log" -SessionDetailsPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal'},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices" -LogPath "./powershell_es.log" -SessionDetailsPath "./powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal -EnableConsoleRepl'},
                        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "Import-Module 'C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\PowerShellEditorServices.psd1'; Start-EditorServices -HostName 'Visual Studio Code Host' -HostProfileId 'Microsoft.VSCode' -HostVersion '2022.12.1' -AdditionalModules @('PowerShellEditorServices.VSCode') -BundledModulesPath 'c:\\Users\\aloknigam\\.vscode\\extensions\\ms-vscode.powershell-2022.12.1\\modules' -EnableConsoleRepl -LogLevel 'Normal' -LogPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\logs\\1671314645-cea5c434-0147-4205-b2be-5907f5a8b7de1671314642966\\EditorServices.log' -SessionDetailsPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\sessions\\PSES-VSCode-39524-314832.json' -FeatureFlags @() -Stdio"},
                        -- bundle_path = 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services',
                        capabilities = capabilities,
                        root_dir = function() return vim.fn.getcwd() end,
                        handlers = handlers,
                        on_attach = on_attach
                    }
                elseif server_name == 'omnisharp' then -- FIX: Fix omnisharp for substrate
                    lspconfig.omnisharp.setup {
                        cmd = { 'dotnet', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp/OmniSharp.dll'},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == 'omnisharp_mono' then
                    lspconfig.omnisharp_mono.setup {
                        cmd = { 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp-mono/OmniSharp.exe'},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == 'lua_ls' then
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { 'bit', 'vim' }
                                },
                                -- workspace = {
                                --     library = vim.api.nvim_get_runtime_file('', true)
                                -- }
                            }
                        }
                    }
                else
                    lspconfig[server_name].setup {
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach
                    }
                end
            end
        }
        vim.cmd.LspStart()
    end,
    dependencies = { 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
    keys = { '<F12>' }
}

AddPlugin {
    'ray-x/lsp_signature.nvim',
    config = function()
        require 'lsp_signature'.setup({
            hint_enable = false,
            noice = false
        })
    end,
    event = 'LspAttach'
}

-- FEAT: https://github.com/jinzhongjia/LspUI.nvim
AddPlugin {
    -- TODO: <M-F12> mapping for lsp_finder
    'glepnir/lspsaga.nvim',
    branch = 'main',
    cmd = 'Lspsaga',
    keys = {
        { '<M-F12>', "<cmd>Lspsaga lsp_finder<cr>", desc = "Open Lsp Finder" }
    },
    opts = {
        beacon = {
            enable = true,
            frequency = 7,
        },
        code_action = {
            num_shortcut = true,
            show_server_name = true,
            keys = {
                -- string | table type
                quit = 'q',
                exec = '<CR>',
            },
        },
        definition = {
            edit = 'o',
            vsplit = '<C-v>',
            split = '<C-s>',
            tabe = '<C-t>',
            quit = 'q',
        },
        diagnostic = {
            show_code_action = true,
            show_source = true,
            jump_num_shortcut = true,
            --1 is max
            max_width = 0.7,
            custom_fix = nil,
            custom_msg = nil,
            text_hl_follow = false,
            keys = {
                exec_action = 'o',
                quit = 'q',
                go_action = 'g'
            },
        },
        finder = {
            open = {'o', '<CR>'},
            vsplit = '<C-v>',
            split = '<C-s>',
            tabe = '<C-t>',
            quit = {'q', '<ESC>'},
        },
        lightbulb = {
            enable = true,
            enable_in_insert = true,
            sign = true,
            sign_priority = 40,
            virtual_text = true,
        },
        outline = {
            win_position = 'right',
            win_with = '',
            win_width = 30,
            show_detail = true,
            auto_preview = true,
            auto_refresh = true,
            auto_close = true,
            custom_sort = nil,
            keys = {
                jump = 'o',
                expand_collapse = 'u',
                quit = 'q',
            },
        },
        preview = {
            lines_above = 0,
            lines_below = 10,
        },
        rename = {
            quit = '<C-c>',
            exec = '<CR>',
            mark = 'x',
            confirm = '<CR>',
            in_select = true,
        },
        request_timeout = 2000,
        scroll_preview = {
            scroll_down = '<C-n>',
            scroll_up = '<C-p>',
        },
        symbol_in_winbar = {
            enable = false,
            separator = ' ',
            hide_keyword = true,
            show_file = true,
            folder_level = 2,
            respect_root = false,
            color_mode = true,
        },
        ui = {
            -- Currently, only the round theme exists
            theme = 'round',
            -- This option only works in Neovim 0.9
            title = true,
            -- Border type can be single, double, rounded, solid, shadow.
            border = 'rounded',
            winblend = 20,
            expand = '',
            collapse = '',
            preview = ' ',
            code_action = '',
            diagnostic = '',
            incoming = ' ',
            outgoing = ' ',
            hover = ' ',
            kind = {}, -- TODO: custom kinds from globals
        }
    }
}

AddPlugin {
    'j-hui/fidget.nvim',
    opts = {
        text = {
            done = '陼',
            spinner = 'arc'
        }
    },
    event = 'LspAttach'
}

AddPlugin {
    'jayp0521/mason-null-ls.nvim',
    config = function ()
        local mnls = require('mason-null-ls')
        mnls.setup({
            automatic_setup = true,
            handlers = {}
        })
    end,
    dependencies = { 'jose-elias-alvarez/null-ls.nvim', config = true },
    -- event = 'LspAttach'
}

AddPlugin { 'p00f/clangd_extensions.nvim' }

-- use 'razzmatazz/csharp-language-server'

-- TODO: resolve usage
AddPlugin {
    'ray-x/navigator.lua',
    event = 'LspAttach'
}

-- TODO: resolve usage
AddPlugin {
    'rmagatti/goto-preview',
    event = 'LspAttach', -- PERF: Reverse dependency
    opts = {
        -- TODO: review config
        width = 120; -- Width of the floating window
        height = 15; -- Height of the floating window
        border = {"󱦵", "─" ,"╮", "│", "╯", "─", "╰", "│"}; -- Border characters of the floating window
        default_mappings = false; -- Bind default mappings
        debug = false; -- Print debug information
        opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
        resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
        post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
        -- references = { -- Configure the telescope UI for slowing the references cycling window.
        --     telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
        -- };
        -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
        focus_on_open = true; -- Focus the floating window when opening it.
        dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
        force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
        bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
        stack_floating_preview_windows = true, -- Whether to nest floating windows
        preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
    }
}

AddPlugin {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    opts = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = { -- These keymaps can be a string or a table for multiple keys
            close = {"<Esc>", "q"},
            goto_location = "<Cr>",
            focus_location = "o",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a",
            fold = "h",
            unfold = "l",
            fold_all = "W",
            unfold_all = "E",
            fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = { -- TODO: global icons
            File = { icon = "", hl = "@text.uri" },
            Module = { icon = "", hl = "@namespace" },
            Namespace = { icon = "", hl = "@namespace" },
            Package = { icon = "", hl = "@namespace" },
            Class = { icon = "𝓒", hl = "@type" },
            Method = { icon = "ƒ", hl = "@method" },
            Property = { icon = "", hl = "@method" },
            Field = { icon = "", hl = "@field" },
            Constructor = { icon = "", hl = "@constructor" },
            Enum = { icon = "ℰ", hl = "@type" },
            Interface = { icon = "ﰮ", hl = "@type" },
            Function = { icon = "", hl = "@function" },
            Variable = { icon = "", hl = "@constant" },
            Constant = { icon = "", hl = "@constant" },
            String = { icon = "𝓐", hl = "@string" },
            Number = { icon = "#", hl = "@number" },
            Boolean = { icon = "⊨", hl = "@boolean" },
            Array = { icon = "", hl = "@constant" },
            Object = { icon = "⦿", hl = "@type" },
            Key = { icon = "🔐", hl = "@type" },
            Null = { icon = "NULL", hl = "@type" },
            EnumMember = { icon = "", hl = "@field" },
            Struct = { icon = "𝓢", hl = "@type" },
            Event = { icon = "🗲", hl = "@type" },
            Operator = { icon = "+", hl = "@operator" },
            TypeParameter = { icon = "𝙏", hl = "@parameter" },
            Component = { icon = "", hl = "@function" },
            Fragment = { icon = "", hl = "@constant" },
        }
    }
}

AddPlugin {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    opts = {
        cmd_name = "IncRename", -- the name of the command
        hl_group = "Substitute", -- the highlight group used for highlighting the identifier's new name
        preview_empty_name = false, -- whether an empty new name should be previewed; if false the command preview will be cancelled instead
        show_message = true, -- whether to display a `Renamed m instances in n files` message after a rename operation
        input_buffer_type = 'dressing', -- the type of the external input buffer to use (the only supported value is currently "dressing")
        post_hook = nil, -- callback to run after renaming, receives the result table (from LSP handler) as an argument
    }
}

-- TODO: resolve usage
AddPlugin {
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    config = true
}

-- AddPlugin {
--     'weilbith/nvim-code-action-menu',
--     config = function ()
--         vim.g.code_action_menu_window_border = 'rounded'
--     end,
--     cmd = 'CodeActionMenu'
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Markdown    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/iamcco/markdown-preview.nvim
AddPlugin {
    'toppair/peek.nvim',
    build = 'deno task --quiet build:fast',
    cmd = 'PeekOpen',
    config = function()
        require('peek').setup({
            theme = vim.o.background
        })
        vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
        vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end
}

-- TODO: set highlight
-- TODO: set config
AddPlugin {
    'yaocccc/nvim-hl-mdcodeblock.lua',
    opts = {
        minumum_len = 50
    },
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = true
}

vim.cmd[[ hi MDCodeBlock guibg =#FFFFFF ]]
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Marks      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Guide:
-- https://vim.fandom.com/wiki/Using_marks
-- |----------------+---------------------------------------------------------------|
-- | Command        | Description                                                   |
-- |----------------+---------------------------------------------------------------|
-- | ''             | jump back (to line in current buffer where jumped from)       |
-- | 'a             | jump to line of mark a (first non-blank character in line)    |
-- | :delmarks a    | delete mark a                                                 |
-- | :delmarks a-d  | delete marks a, b, c, d                                       |
-- | :delmarks aA   | delete marks a, A                                             |
-- | :delmarks abxy | delete marks a, b, x, y                                       |
-- | :delmarks!     | delete all lowercase marks for the current buffer (a-z)       |
-- | :marks         | list all the current marks                                    |
-- | :marks aB      | list marks a, B                                               |
-- | ['             | jump to previous line with a lowercase mark                   |
-- | [`             | jump to previous lowercase mark                               |
-- | ]'             | jump to next line with a lowercase mark                       |
-- | ]`             | jump to next lowercase mark                                   |
-- | `"             | jump to position where last exited current buffer             |
-- | `.             | jump to position where last change occurred in current buffer |
-- | `0             | jump to position in last file edited (when exited Vim)        |
-- | `1             | like `0 but the previous file (also `2 etc)                   |
-- | `< or `>       | jump to beginning/end of last visual selection                |
-- | `[ or `]       | jump to beginning/end of previously changed or yanked text    |
-- | ``             | jump back (to position in current buffer where jumped from)   |
-- | `a             | jump to position (line and column) of mark a                  |
-- | c'a            | change text from current line to line of mark a               |
-- | d'a            | delete from current line to line of mark a                    |
-- | d`a            | delete from current cursor position to position of mark a     |
-- | ma             | set mark a at current cursor location                         |
-- | y`a            | yank text to unnamed buffer from cursor to position of mark a |
-- |----------------+---------------------------------------------------------------|
AddPlugin {
    -- TODO: Silence bookmark addition/removal
    -- TODO: location of bookmark files
    'MattesGroeger/vim-bookmarks',
    config = function()
        vim.cmd[[
            let g:bookmark_annotation_sign = ''
            let g:bookmark_display_annotation = 1
            let g:bookmark_highlight_lines = 1
            let g:bookmark_location_list = 1
            let g:bookmark_no_default_key_mappings = 1
            let g:bookmark_save_per_working_dir = 1
            let g:bookmark_sign = ''
            nmap ba <Plug>BookmarkAnnotate
            nmap bm <Plug>BookmarkToggle
            nmap bn <Plug>BookmarkNext
            nmap bp <Plug>BookmarkPrev
            nmap bs <Plug>BookmarkShowAll
        ]]
    end,
    keys = { 'ba', 'bm', 'bn', 'bp', 'bs'},
}

-- FEAT: https://github.com/ThePrimeagen/harpoon
-- FEAT: https://github.com/cbochs/grapple.nvim
AddPlugin {
    'kshenoy/vim-signature',
    cmd = 'SignatureToggle'
}
-- use 'chentoast/marks.nvim'
-- use 'crusj/bookmarks.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Orgmode     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/TravonteD/org-capture-filetype
-- https://github.com/akinsho/org-bullets.nvim

AddPlugin {
    'nvim-neorg/neorg',
    config = function()
        require('neorg').setup {
            load = {
                ['core.highlights']              = {},
                ['core.integrations.treesitter'] = { config = { install_parsers = false } },
                ['core.neorgcmd']                = {},
                ['core.norg.completion']         = { config = { engine = 'nvim-cmp' } },
                ['core.norg.concealer']          = {},
                ['core.norg.esupports.hop']      = {},
                ['core.norg.esupports.indent']   = {},
                ['core.norg.qol.toc']            = {},
                ['core.norg.qol.todo_items']     = {},
                ['core.syntax']                  = {},
                ['core.defaults'] = {},
            }
        }
        vim.cmd [[
            au InsertEnter *.norg :Neorg toggle-concealer
            au InsertLeave *.norg :Neorg toggle-concealer
        ]]
    end,
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    ft = "norg"
}

-- use 'nvim-orgmode/orgmode'
-- https://github.com/ranjithshegde/orgWiki.nvim
AddPlugin { -- TODO: use me
    'lukas-reineke/headlines.nvim',
    config = function() -- Specifies code to run after this plugin is loaded
        --require("md-bullets").setup {
        --symbols = {"", "", "✸", "✿", ""}
        ------ or a function that receives the defaults and returns a list
        ----symbols = function(default_list)
            ----table.insert(default_list, "♥")
            ----return default_list
            ----end
            --}
        require("headlines").setup {
            markdown = {
                headline_highlights = { "Headline1", "Headline2" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                fat_headlines = true,
                fat_headline_upper_string = "..",
                fat_headline_lower_string = "━",
            },
            rmd = {
                headline_highlights = { "Headline1", "Headline2" },
                codeblock_sign = "CodeBlock",
                dash_highlight = "Dash",
                fat_headlines = true,
            },
            vimwiki = {
                headline_highlights = { "Headline1", "Headline2" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                fat_headlines = true,
            },
            org = {
                headline_highlights = { "Headline1", "Headline2" },
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                fat_headlines = true,
            },
        }
    end,
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = 'markdown',
    enabled = false --  TODO: enable
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Quickfix    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
    opts = {
        position = 'bottom', -- position of the list can be: bottom, top, left, right
        height = 10, -- height of the trouble list when position is top or bottom
        width = 50, -- width of the list when position is left or right
        icons = true, -- use devicons for filenames
        mode = 'document_diagnostics', -- 'workspace_diagnostics', 'document_diagnostics', 'quickfix', 'lsp_references', 'loclist'
        fold_open = '', -- icon used for open folds
        fold_closed = '', -- icon used for closed folds
        group = true, -- group results by file
        padding = false, -- add an extra new line on top of the list
        action_keys = { -- key mappings for actions in the trouble list
            -- map to {} to remove a mapping, for example:
            -- close = {},
            close = 'q', -- close the list
            cancel = '<esc>', -- cancel the preview and get back to your last window / buffer / cursor
            refresh = 'r', -- manually refresh
            jump = {'<cr>', '<tab>'}, -- jump to the diagnostic or open / close folds
            open_split = { '<c-s>' }, -- open buffer in new split
            open_vsplit = { '<c-v>' }, -- open buffer in new vsplit
            open_tab = { '<c-t>' }, -- open buffer in new tab
            jump_close = {'o'}, -- jump to the diagnostic and close the list
            toggle_mode = 'm', -- toggle between 'workspace' and 'document' diagnostics mode
            toggle_preview = 'P', -- toggle auto_preview
            hover = 'K', -- opens a small popup with the full multiline message
            preview = 'p', -- preview the diagnostic location
            close_folds = {'zM', 'zm'}, -- close all folds
            open_folds = {'zR', 'zr'}, -- open all folds
            toggle_fold = {'zA', 'za'}, -- toggle fold of current file
            previous = 'k', -- previous item
            next = 'j' -- next item
        },
        indent_lines = true, -- add an indent guide below the fold icons
        auto_open = false, -- automatically open the list when you have diagnostics
        auto_close = false, -- automatically close the list when you have no diagnostics
        auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false, -- automatically fold a file trouble list at creation
        auto_jump = { 'lsp_definitions' }, -- for the given modes, automatically jump if there is only a single result
        signs = {
            -- icons / text used for a diagnostic
            error = Icons.diagnostic.error,
            warning = Icons.diagnostic.warn,
            hint = Icons.diagnostic.hint,
            information = Icons.diagnostic.info,
            other = Icons.diagnostic.other
        },
        use_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
    }
}

    -- |-------------+----------------------------------------------------------+---------|
    -- | Function    | Action                                                   | Def Key |
    -- |-------------+----------------------------------------------------------+---------|
    -- | open        | open the item under the cursor in quickfix window        | <CR>    |
    -- | openc       | open the item, and close quickfix window                 | o       |
    -- | drop        | use drop to open the item, and close quickfix window     | O       |
    -- | tabdrop     | use tab drop to open the item, and close quickfix window |         |
    -- | tab         | open the item in a new tab                               | t       |
    -- | tabb        | open the item in a new tab, but stay at quickfix window  | T       |
    -- | tabc        | open the item in a new tab, and close quickfix window    | <C-t>   |
    -- | split       | open the item in vertical split                          | <C-s>   |
    -- | vsplit      | open the item in horizontal split                        | <C-v>   |
    -- | prevfile    | go to previous file under the cursor in quickfix window  | <C-p>   |
    -- | nextfile    | go to next file under the cursor in quickfix window      | <C-n>   |
    -- | prevhist    | go to previous quickfix list in quickfix window          | <       |
    -- | nexthist    | go to next quickfix list in quickfix window              | >       |
    -- | lastleave   | go to last leaving position in quickfix window           | '"      |
    -- | stoggleup   | toggle sign and move cursor up                           | <S-Tab> |
    -- | stoggledown | toggle sign and move cursor down                         | <Tab>   |
    -- | stogglevm   | toggle multiple signs in visual mode                     | <Tab>   |
    -- | stogglebuf  | toggle signs for same buffers under the cursor           | '<Tab>  |
    -- | sclear      | clear the signs in current quickfix list                 | z<Tab>  |
    -- | pscrollup   | scroll up half-page in preview window                    | <C-b>   |
    -- | pscrolldown | scroll down half-page in preview window                  | <C-f>   |
    -- | pscrollorig | scroll back to original position in preview window       | zo      |
    -- | ptogglemode | toggle preview window between normal and max size        | zp      |
    -- | ptoggleitem | toggle preview for an item of quickfix list              | p       |
    -- | ptoggleauto | toggle auto preview when cursor moved                    | P       |
    -- | filter      | create new list for signed items                         | zn      |
    -- | filterr     | create new list for non-signed items                     | zN      |
    -- | fzffilter   | enter fzf mode                                           | zf      |
    -- |-------------+----------------------------------------------------------+---------|
AddPlugin {
    'kevinhwang91/nvim-bqf',
    config = function()
        require('bqf').setup {
            auto_resize_height = true,
            preview = {
                border_chars = {'│', '│', '─', '─', '╭', '╮', '╰', '╯', '█'}
            },
            filter = {
                fzf = {
                    action_for = {
                        ['ctrl-t'] = {
                            description = [[Press ctrl-t to open up the item in a new tab]],
                            default = 'tabedit'
                        },
                        ['ctrl-v'] = {
                            description = [[Press ctrl-v to open up the item in a new vertical split]],
                            default = 'vsplit'
                        },
                        ['ctrl-s'] = {
                            description = [[Press ctrl-x to open up the item in a new horizontal split]],
                            default = 'split'
                        },
                        ['ctrl-q'] = {
                            description = [[Press ctrl-q to toggle sign for the selected items]],
                            default = 'signtoggle'
                        },
                        ['ctrl-c'] = {
                            description = [[Press ctrl-c to close quickfix window and abort fzf]],
                            default = 'closeall'
                        }
                    },
                    extra_opts = {
                        description = 'Extra options for fzf',
                        default = {'--bind', 'ctrl-o:toggle-all'}
                    }
                }
            }
        }
        vim.cmd('packadd cfilter')
    end,
    dependencies = 'junegunn/fzf',
    ft = 'qf'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Rooter     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Command would be better for on demand
vim.api.nvim_create_autocmd('BufRead', { pattern = '*', callback = function()
    local filepath = vim.fn.bufname('%')
    if filepath:sub(1, 1) ~= '/' and filepath:sub(2, 2) ~= ':' then
        if filepath:sub(1, 2) == '.\\' or filepath:sub(1, 2) == './' then
            filepath = filepath:sub(3)
        end
        filepath = vim.fn.getcwd() .. '/' .. filepath
    end
    local root = vim.fs.find({".git"}, {path = filepath, upward = true, limit = 1})
    root = vim.fs.dirname(root[1])
    if root then
        local cwd = vim.fn.getcwd()
        vim.cmd.lc(root)
        vim.cmd.lc(cwd)
    end
end
})
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Sessions    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- BUG: DeleteSession called twice gives error
    -- TODO: Add capabilities to save and load custom settings like lsp/git... using hooks
    -- BUG: Fix path shown in notifications
    'rmagatti/auto-session',
    cmd = 'SessionSave',
    config = function()
        vim.g.auto_session_suppress_dirs = { 'C:\\Users\\aloknigam', '~' }
        require('auto-session').setup({
            -- log_level = 'debug',
            post_delete_cmds = {
                "let g:auto_session_enabled = v:false",
                "unlet g:session_icon"
            },
            post_restore_cmds = {
                "let g:session_icon = ''"
            },
            post_save_cmds = {
                "let g:session_icon = ''"
            }
        })
        vim.o.sessionoptions = 'blank,buffers,curdir,help,tabpages,winsize,winpos,terminal'
    end,
    init = function()
        if vim.fn.filereadable(vim.fn.stdpath 'data' .. '\\sessions\\' .. vim.fn.getcwd():gsub('\\', '%%'):gsub(':', '++') .. '.vim') == 1 then
            require('auto-session')
        end
    end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Snippets    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- TODO: lazy load for filetype needed
    'dcampos/nvim-snippy',
    opts = {
        mappings = {
            is = {
                ['<Tab>'] = 'expand_or_advance',
                ['<S-Tab>'] = 'previous',
            }
        }
    },
    dependencies = 'honza/vim-snippets',
}
-- https://github.com/ellisonleao/carbon-now.nvim
-- https://github.com/hrsh7th/vim-vsnip
-- https://github.com/norcalli/snippets.nvim
-- https://github.com/notomo/cmp-neosnippet
-- https://github.com/quangnguyen30192/cmp-nvim-ultisnips
-- https://github.com/rafamadriz/friendly-snippets
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/smjonas/snippet-converter.nvim
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Status Line   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- PERF: check for performance
-- REFACTOR: remove unwanted comments
AddPlugin {
    'nvim-lualine/lualine.nvim',
    config = function()
        Icon_index = 0
        local function LspIcon()
            -- local anim = {'䷀', '䷪',  '䷍', '䷈', '䷉', '䷌', '䷫'}
            local anim = {''}
            Icon_index = (Icon_index) % #anim + 1
            return anim[Icon_index]
        end
        local function NavicLocal()
            if #vim.lsp.get_active_clients({bufnr = 0}) > 0 then
                local navic = require('nvim-navic') -- PERF: is require slow
                return navic.get_location()
            end
            return ""
        end
        function CountWin()
            local tabpage = vim.api.nvim_get_current_tabpage()
            local win_list = vim.api.nvim_tabpage_list_wins(tabpage)
            local named_window = 0
            local visited_window = {}
            local isValidBuf = function(bufnr, buf_name)
                if buf_name == "" then
                    return false
                end

                local ignore_filetype = { 'NvimTree' }
                local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                for _,v in pairs(ignore_filetype) do
                    if v == filetype then
                        return false
                    end
                end

                return true
            end

            for _, win in ipairs(win_list) do
                local bufnr = vim.api.nvim_win_get_buf(win)
                local buf_name = vim.api.nvim_buf_get_name(bufnr)
                if isValidBuf(bufnr, buf_name) then
                    if not visited_window[buf_name] then
                        visited_window[buf_name] = true
                        named_window = named_window + 1
                    end
                end
            end

            return named_window
        end
        vim.o.showcmdloc = 'statusline'
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = '⏽', right = ''},
                section_separators = { left = '', right = ''},
        --         disabled_filetypes = {
        --             statusline = {},
        --             winbar = {},
        --         },
                ignore_focus = { 'NvimTree' },
        --         always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                }
            },
            sections = {
                lualine_a = {
                    {
                        'mode',
                        color = { gui = 'bold' },
                        fmt = function(str)
                            return str:sub(1,1)
                        end,
                        padding = { left = 0, right = 0 },
                        separator = { left = '', right = '' }
                    }
                },
                lualine_b = {
                    {
                        'branch',
                        color = { gui = 'bold' },
                        icon = {'', color = {fg = '#F14C28'}},
                        on_click = function()
                            vim.cmd('Telescope git_branches')
                        end
                    },
                    {
                        'diff', -- TODO: change icons to global
                        on_click = function()
                            vim.cmd('Telescope git_status') -- BUG: fix the cwd issue
                        end
                    },
                    {
                        'diagnostics',
                        on_click = function()
                            vim.cmd('TroubleToggle')
                        end,
                        sources = { 'nvim_diagnostic' },
                        symbols = {
                            error = Icons.diagnostic.error .. ' ',
                            warn  = Icons.diagnostic.warn .. ' ',
                            info  = Icons.diagnostic.info .. ' ',
                            hint  = Icons.diagnostic.hint .. ' ',
                        },
                    }
                },
                lualine_c = {
                    {
                        'filetype',
                        icon_only = true,
                        padding = { left = 1, right = 0 },
                        separator = ''
                    },
                    {
                        'filename',
                        color = { gui = 'italic' },
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        on_click = function()
                            vim.cmd('NvimTreeToggle')
                        end,
                        path = 0,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = '', -- Text to show when the file is modified.
                            readonly = '', -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = '', -- Text to show for unnamed buffers.
                            newfile  = '', -- Text to show for new created file before first writting
                        }
                    }
                },
                lualine_x = {
                    {
                        'hostname',
                        color = { fg = '#119DA4', gui = 'bold' },
                        cond = function()
                            return vim.env.SSH_CLIENT ~= nil
                        end,
                        fmt = function(str)
                            local alias = {
                                ['ALOKNIGAM-IDC'] = "devbox"
                            }
                            return alias[str] or str
                        end,
                        icon = { '', color = { fg = '#3066BE' }},
                    },
                    {
                        'searchcount',
                        color = { fg = '#23CE6B', gui = 'bold' },
                        fmt = function(str)
                            return string.sub(str, 2, -2)
                        end,
                        icon = {'󰱽', color = {fg = '#EAC435'}},
                        separator = ''
                    },
                    {
                        'selectioncount',
                        color = { fg = '#BA2C73' },
                        icon = { '', color = { fg = '#963484' }},
                        separator = ''
                    },
                    {
                        'encoding', -- THOUGHT: show when not utf-8 or format it to comppress name
                        color = { fg = string.format("#%X", vim.api.nvim_get_hl_by_name('String', true).foreground), gui ='bold' },
                        fmt = function(str)
                            if vim.o.bomb then
                                str = str .. '-bom'
                            end
                            return str
                        end
                    }
                },
                lualine_y = {
                    {
                        'g:session_icon',
                        padding = { left = 1, right = 1 },
                        separator = ''
                    },
                    {
                        LspIcon,
                        cond = function()
                            return #vim.lsp.get_active_clients({bufnr = 0}) ~= 0
                        end,
                        on_click = function()
                            vim.cmd('LspInfo')
                        end,
                        padding = { left = 1, right = 0 },
                        separator = ''
                    },
                    {
                        function()
                            if vim.o.wrap then
                                return '󰖶'
                            else
                                return '󰯟'
                            end
                        end,
                        on_click = function()
                            vim.cmd('set wrap!')
                        end,
                        padding = { left = 1, right = 0 },
                        separator = ''
                    },
                    {
                        'fileformat',
                        padding = { left = 1, right = 2 },
                    },
                },
                lualine_z = {
                    {
                        'location',
                        fmt = function(str)
                            return str:gsub("^%s+", ""):gsub("%s+", "")
                        end,
                        icon = {'󰍒', align = 'right'},
                        on_click = function ()
                            local satellite = require('satellite')
                            if satellite.enabled then
                                vim.cmd('SatelliteDisable')
                                satellite.enabled = false
                            else
                                vim.cmd('SatelliteEnable')
                                satellite.enabled = true
                            end
                        end,
                        padding = { left = 0, right = 0 },
                        separator = { left = '', right = '' }
                    }
                }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            winbar = {
                lualine_a = {
                    {
                        'filename',
                        color = { gui = 'italic' },
                        cond = function () return CountWin() > 1 end,
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        path = 0,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = '', -- Text to show when the file is modified.
                            readonly = '', -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = '', -- Text to show for unnamed buffers.
                            newfile  = '', -- Text to show for new created file before first writting
                        }
                    }
                },
                lualine_c = {
                    { NavicLocal } -- FIX: temporary fix, find solution for it
                }
            },
            inactive_winbar = {
                lualine_a = {
                    {
                        'filename',
                        color = { gui = 'italic' },
                        cond = function () return CountWin() > 1 end,
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        path = 3,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = '', -- Text to show when the file is modified.
                            readonly = '', -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = '', -- Text to show for unnamed buffers.
                            newfile  = '', -- Text to show for new created file before first writting
                        }
                    }
                },
            },
            extensions = {
                'aerial',
                'lazy',
                'nvim-tree',
                'quickfix',
                'symbols-outline',
                'toggleterm',
                'trouble',
            }
        }
    end,
    event = 'CursorHold'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- FIX: [No Name] for empty file, use same as lualine, use name_formatter
    'akinsho/bufferline.nvim',
    config = function()
        local sym_map = { -- TODO use global icons
            ['error']   = ' ',
            ['hint']    = ' ',
            ['info']    = ' ',
            ['warning'] = ' ',
        }
        require('bufferline').setup {
            options = {
                always_show_bufferline = false,
                diagnostics = 'nvim_lsp',
                middle_mouse_command = 'bdelete! %d',
                mode = 'tabs',
                right_mouse_command = nil,
                separator_style = 'thick',
                diagnostics_indicator = function(_, _, diagnostics_dict, context)
                    if context.buffer:current() then
                        return ''
                    end
                    local res = ''
                    for k, v in pairs(diagnostics_dict) do
                        res = res .. sym_map[k] .. v .. ' '
                    end
                    return res
                end,
                indicator = {
                    style = 'underline'
                }
            }
        }
    end,
    event = 'TabNew'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Telescope   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'crispgm/telescope-heading.nvim',
    config = function()
        require('telescope').load_extension('heading')
    end,
    ft = 'markdown'
}

AddPlugin {
    -- TODO: padded dropdown menu https://github.com/nvim-telescope/telescope.nvim/wiki/Gallery#padded-dropdown-menu-in-norcallis-blue
    -- FEAT: https://github.com/nvim-telescope/telescope-fzf-native.nvim
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
        local actions = require 'telescope.actions'
        local telescope = require('telescope')
        telescope.setup({
            defaults = {
                dynamic_preview_title = true,
                entry_prefix = '   ',
                file_ignore_patterns = {},
                file_sorter = require('telescope.sorters').get_fuzzy_file,
                generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
                initial_mode = 'insert',
                multi_icon = ' ',
                prompt_prefix = '  ',
                selection_caret = ' ',
                timeout = 2000,
                windblend = 0,
                mappings = {
                    i = {
                        ['<C-d>']      = false,
                        ['<C-t>']      = actions.select_tab,
                        ['<C-u>']      = false,
                        ['<C-v>']      = actions.select_vertical,
                        ['<C-s>']      = actions.select_horizontal,
                        ['<PageDown>'] = actions.preview_scrolling_down,
                        ['<PageUp>']   = actions.preview_scrolling_up,
                        ['<S-Tab>']    = false,
                        ['<Tab>']      = actions.toggle_selection
                    },
                    n = {
                        ['<C-d>']      = false,
                        ['<C-t>']      = actions.select_tab,
                        ['<C-u>']      = false,
                        ['<C-v>']      = actions.select_vertical,
                        ['<C-s>']      = actions.select_horizontal,
                        ['<PageDown>'] = actions.preview_scrolling_down,
                        ['<PageUp>']   = actions.preview_scrolling_up,
                        ['<S-Tab>']    = false,
                        ['<Tab>']      = actions.toggle_selection
                    }
                },
            },
            extensions = {
                heading = {
                    treesitter = true
                },
                undo = {
                    side_by_side = true
                }
            },
        })
        telescope.load_extension('undo')
        telescope.load_extension('vim_bookmarks')
        vim.cmd[[autocmd User TelescopePreviewerLoaded setlocal nu]]
    end,
    dependencies = {
        'debugloop/telescope-undo.nvim',
        'nvim-lua/plenary.nvim',
        {'tom-anders/telescope-vim-bookmarks.nvim', dependencies = 'MattesGroeger/vim-bookmarks'}
    }
}

AddPlugin {
    'princejoogie/dir-telescope.nvim',
    cmd = { 'FileInDirectory', 'GrepInDirectory' },
    opts = {
        hidden = true,
        respect_gitignore = true,
    },
    dependencies = 'nvim-telescope/telescope.nvim',
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Terminal    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/voldikss/vim-floaterm

AddPlugin {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Tests      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/andythigpen/nvim-coverage
-- https://github.com/klen/nvim-test
-- https://github.com/nvim-neotest/neotest
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Treesitter   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'Wansmer/treesj',
    cmd = 'TSJToggle',
    opts = {
        max_join_length = 10000
    }
}

AddPlugin {
    -- TODO: explore incremental_selection
    'nvim-treesitter/nvim-treesitter',
    config = function()
        require('nvim-treesitter.configs').setup {
            auto_install = true,
            endwise = {
                enable = true,
            },
            highlight = {
                additional_vim_regex_highlighting = false,
                disable = { 'help', 'yaml' },
                enable = true
            },
            ignore_install = { 'help', 'norg', 'norg_meta', 'yaml' },
            rainbow = {
                enable = true,
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
            }
        }
    end,
    dependencies = { 'mrjones2014/nvim-ts-rainbow', { 'm-demare/hlargs.nvim' } },
    event = 'User VeryLazy',
}

AddPlugin {
    -- https://github.com/David-Kunz/markid
    'm-demare/hlargs.nvim',
    config = function()
        -- local colors = {}
        -- for _,v in pairs(ColorPalette()) do
        --     local hi = {}
        --     hi.fg = v.fg
        --     hi.underline = true
        --     table.insert(colors, hi)
        -- end
        require('hlargs').setup({
            colorpalette = ColorPalette(),
            excluded_argnames = {
                declarations = {
                    python = { 'self', 'cls' },
                    lua = { 'self' }
                },
                usages = {
                    python = { 'self', 'cls' },
                    lua = { 'self' }
                }
            },
            extras = {
                named_parameters = true,
            },
            hl_priority = HlPriority.hlargs,
            paint_catch_blocks = {
                declarations = true,
                usages = true
            },
            use_colorpalette = true,
        })
    end
}

AddPlugin {
    'nvim-treesitter/nvim-treesitter-context',
    cmd = 'TSContextEnable',
    opts = {
        enable = true,
        separator = '━',
        patterns = {
            lua = {
                'field'
            }
        }
    }
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━       UI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- FIX: checkhealth
    -- TODO: popupmenu
    -- TODO: lsp
    -- TODO: showmode in lualine
    -- TODO: @recording messages from messages https://www.reddit.com/r/neovim/comments/138ahlo/recording_a_macro_with_set_cmdheight0/
    -- TODO: cmdline and popup together
    -- TODO: classic bottom cmdline for search https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#use-a-classic-bottom-cmdline-for-search
    -- TODO: lsp progress
    'folke/noice.nvim',
    cond = function() return not vim.g.neovide end,
    config = function()
        vim.o.lazyredraw = false
        require('noice').setup({
            cmdline = {
                enabled = true, -- enables the Noice cmdline UI
                view = 'cmdline_popup', -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
                opts = {}, -- global options for the cmdline. See section on views
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = { pattern = '^:', icon = '', lang = 'vim', title = ''},
                    search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex', view = 'cmdline' , title = ''},
                    search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' , title = ''},
                    filter = { pattern = '^:%s*!', icon = '$', lang = 'powershell' , title = ''},
                    lua = { pattern = '^:%s*lua%s+', icon = '', lang = 'lua' , title = ''},
                    lua_print = { pattern = '^:%s*lua=%s+', icon = '󰇼', lang = 'lua' , title = ''},
                    help = { pattern = '^:%s*he?l?p?%s+', icon = '' , title = ''},
                    input = {}, -- Used by input()
                    -- lua = false, -- to disable a format, set to `false`
                },
            },
            messages = {
                -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                -- This is a current Neovim limitation.
                enabled = true, -- enables the Noice messages UI
                view = 'notify', -- default view for messages
                view_error = 'notify', -- view for errors
                view_warn = 'notify', -- view for warnings
                view_history = 'messages', -- view for :messages
                view_search = 'virtualtext', -- view for search count messages. Set to `false` to disable
            },
            popupmenu = {
                enabled = true, -- enables the Noice popupmenu UI
                backend = 'cmp', -- backend to use to show regular cmdline completions
                -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
                kind_icons = {}, -- set to `false` to disable icons
            },
            -- default options for require('noice').redirect
            -- see the section on Command Redirection
            redirect = {
                view = 'popup',
                filter = { event = 'msg_show' },
            },
            -- You can add any custom commands below that will be available with `:Noice command`
            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
                    view = 'split',
                    opts = { enter = true, format = 'details' },
                    filter = {
                        any = {
                            { event = 'notify' },
                            { error = true },
                            { warning = true },
                            { event = 'msg_show', kind = { '' } },
                            { event = 'lsp', kind = 'message' },
                        },
                    },
                },
                -- :Noice last
                last = {
                    view = 'popup',
                    opts = { enter = true, format = 'details' },
                    filter = {
                        any = {
                            { event = 'notify' },
                            { error = true },
                            { warning = true },
                            { event = 'msg_show', kind = { '' } },
                            { event = 'lsp', kind = 'message' },
                        },
                    },
                    filter_opts = { count = 1 },
                },
                -- :Noice errors
                errors = {
                    -- options for the message history that you get with `:Noice`
                    view = 'popup',
                    opts = { enter = true, format = 'details' },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always 'notify' and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = true,
                view = 'notify',
            },
            lsp = {
                progress = {
                    enabled = true,
                    -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                    -- See the section on formatting for more details on how to customize.
                    format = 'lsp_progress',
                    format_done = 'lsp_progress_done',
                    throttle = 1000 / 30, -- frequency to update lsp progress message
                    view = 'mini',
                },
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
                    -- override the lsp markdown formatter with Noice
                    ['vim.lsp.util.stylize_markdown'] = false,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ['cmp.entry.get_documentation'] = false,
                },
                hover = {
                    enabled = true,
                    view = nil, -- when nil, use defaults from documentation
                    opts = {}, -- merged with defaults from documentation
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    opts = {}, -- merged with defaults from documentation
                },
                message = {
                    -- Messages shown by lsp servers
                    enabled = true,
                    view = 'notify',
                    opts = {},
                },
                -- defaults for hover and signature help
                documentation = {
                    view = 'hover',
                    opts = {
                        lang = 'markdown',
                        replace = true,
                        render = 'plain',
                        format = { '{message}' },
                        win_options = { concealcursor = 'n', conceallevel = 3 },
                    },
                },
            },
            markdown = {
                hover = {
                    ['|(%S-)|'] = vim.cmd.help, -- vim help links
                    ['%[.-%]%((%S-)%)'] = require('noice.util').open, -- markdown links
                },
                highlights = {
                    ['|%S-|'] = '@text.reference',
                    ['@%S+'] = '@parameter',
                    ['^%s*(Parameters:)'] = '@text.title',
                    ['^%s*(Return:)'] = '@text.title',
                    ['^%s*(See also:)'] = '@text.title',
                    ['{%S-}'] = '@parameter',
                },
            },
            health = {
                checker = false, -- Disable if you don't want health checks to run
            },
            smart_move = {
                -- noice tries to move out of the way of existing floating windows.
                enabled = true, -- you can disable this behaviour here
                -- add any filetypes here, that shouldn't trigger smart move.
                excluded_filetypes = { 'cmp_menu', 'cmp_docs', 'notify' },
            },
            presets = {
                -- you can enable a preset by setting it to true, or a table that will override the preset config
                -- you can also add custom presets that you can enable/disable with enabled=true
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = false, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false, -- add a border to hover docs and signature help
            },
            throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
            views = {
                -- cmdline_popup = {
                --     border = {
                --         style = "none",
                --         padding = { 0, 0 },
                --     },
                --     filter_options = {},
                --     win_options = {
                --         winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                --     },
                -- },
            }, ---@see section on views
            routes = {{
                view = "notify",
                filter = { event = "msg_showmode" },
            }},
            status = {}, --- @see section on statusline components
            format = {}, --- @see section on formatting
        })
    end,
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    enabled = true,
    lazy = false
}

AddPlugin {
    'rcarriga/nvim-notify',
    config = function()
        local notify = require('notify')
        notify.setup({
            background_colour = vim.api.nvim_get_hl_by_name('Normal', true).background and 'Normal' or '#000000',
            minimum_width = 0,
            render = 'minimal',
            stages = 'slide'
        })
        vim.notify = notify
    end,
}

AddPlugin {
    'stevearc/dressing.nvim', -- PERF: load like notify
    lazy = false
}

AddPlugin {
    -- TODO: change animation speed
    'tamton-aquib/flirt.nvim',
    opts = {
        override_open = true, -- experimental
        close_command = 'Q',
        default_move_mappings = false,
        default_resize_mappings = true,
        default_mouse_mappings = false,  -- FIX: Drag floats with mouse
        exclude_fts = { 'notify', 'cmp_menu', 'NvimSeparator', 'lspsagafinder' },
        custom_filter = function(buffer, _)
            return vim.bo[buffer].filetype == 'cmp_menu' -- avoids animation
        end
    },
    lazy = false
}

vim.notify = function(msg, level, opt)
    require('notify') -- lazy loads nvim-notify and set vim.notify = notify
    vim.notify(msg, level, opt)
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Utilities    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO relocalte utility plugins when done
-- FEAT: use 'AckslD/nvim-trevJ.lua'
-- FEAT: https://github.com/wellle/targets.vim
AddPlugin { -- PERF: Very slow on large files
    'AckslD/muren.nvim',
    config = true
}

AddPlugin {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- TODO: https://github.com/EtiamNullam/deferred-clipboard.nvim

AddPlugin {
    'LiadOz/nvim-dap-repl-highlights',
    config = true
}

AddPlugin {
    'Pocco81/true-zen.nvim',
    cmd = { 'TZAtaraxis', 'TZMinimalist', 'TZNarrow', 'TZFocus' }
}

-- https://github.com/TheSafdarAwan/find-extender.nvim

AddPlugin {
    -- https://github.com/rareitems/printer.nvim
    'andrewferrier/debugprint.nvim',
    opts = {
        create_keymaps = false,
        create_commands = false,
        filetypes = {
            ["python"] = {
                left = 'print(f"',
                right = '")',
                mid_var = "{",
                right_var = '}")',
            }
        }
    },
    keys = {
        { '<Leader>dP', function() return require('debugprint').debugprint({ above = true }) end,                  expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true, variable = true }) end, expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true, variable = true }) end, expr = true, mode = 'v' },
        { '<Leader>dd', function() return require('debugprint').deleteprints() end,                                             mode = 'n' },
        { '<Leader>dp', function() return require('debugprint').debugprint() end,                                  expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,               expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,               expr = true, mode = 'v' },
    }
}

-- use 'cbochs/portal.nvim'

-- use 'chipsenkbeil/distant.nvim'

AddPlugin {
    'chrisbra/csv.vim',
    config = function()
        vim.g.csv_default_delim = ','
    end,
    ft = 'csv'
}

AddPlugin {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
}

AddPlugin {
    'folke/neodev.nvim',
    event = 'LspAttach',
    opts = {
        library = {
            enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
            -- these settings will be used for your Neovim config directory
            runtime = true, -- runtime path
            types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
            plugins = true, -- installed opt or start plugins in packpath
            -- you can also specify the list of plugins to make available as a workspace library
            -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
        },
        setup_jsonls = false, -- configures jsonls to provide completion for project specific .luarc.json files
        -- for your Neovim config directory, the config.library settings will be used as is
        -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
        -- for any other directory, config.library.enabled will be set to false
        override = function(root_dir, options) end,
        -- With lspconfig, Neodev will automatically setup your lua-language-server
        -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
        -- in your lsp start options
        lspconfig = true,
        -- much faster, but needs a recent built of lua-language-server
        -- needs lua-language-server >= 3.6.0
        pathStrict = true,
    }
}

-- TODO: https://github.com/emileferreira/nvim-strict
-- TODO: https://github.com/folke/neoconf.nvim
-- TODO: use 'jbyuki/instant.nvim'

-- TODO: OPTIMIZE and enable
AddPlugin {
    'gbprod/yanky.nvim',
    opts = {
        ring = {
            history_length = 100,
            storage = "memory",
            sync_with_numbered_registers = true,
            cancel_event = "update",
        },
        system_clipboard = {
            sync_with_ring = false,
        }
    },
    lazy = true
}

AddPlugin {
    'kwkarlwang/bufjump.nvim',
    opts = {
        on_success = function()
            vim.cmd([[execute "normal! g`\"zz"]])
        end
    },
    keys = {
        { '<C-S-I>', function() require('bufjump').forward() end },
        { '<C-S-O>', function() require('bufjump').backward() end }
    }
}

AddPlugin {
    'lewis6991/satellite.nvim',
    cmd = 'SatelliteEnable',
    config = function()
        require('satellite').setup({ winblend = vim.o.winblend })
        vim.cmd('hi link ScrollView lualine_a_normal')
    end
}

AddPlugin { -- FIX: resolve usage
    'luukvbaal/statuscol.nvim',
    config = true
}

-- AddPlugin { 'kylechui/nvim-surround' }

AddPlugin {
    'mg979/vim-visual-multi',
    config = function()
        vim.cmd[[
            nmap <C-LeftMouse> <Plug>(VM-Mouse-Cursor)
            nmap <C-RightMouse> <Plug>(VM-Mouse-Word)
        ]]
    end,
    keys = { '<C-LeftMouse>', '<C-RightMouse>', '<C-Up>', '<C-Down>', '<C-N>' }
}

-- https://github.com/nat-418/scamp.nvim

AddPlugin {
    'nacro90/numb.nvim',
    cond = function()
        return vim.api.nvim_get_mode().mode == 'c'
    end,
    config = true,
    event = 'CmdlineEnter',
}

AddPlugin {
    'nat-418/boole.nvim',
    opts = {
        mappings = {
            increment = '<C-a>',
            decrement = '<C-x>'
        },
        -- User defined loops
        additions = {
        },
        allow_caps_additions = {
        }
    },
    keys = { '<C-a>', '<C-x>' }
}

AddPlugin {
    -- Lua copy https://github.com/ojroques/nvim-osc52
    'ojroques/vim-oscyank',
    cond = function()
        -- Check if connection is ssh
        return vim.env.SSH_CLIENT ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif]]
    end,
    lazy = false
}

AddPlugin {
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
}

AddPlugin {
    'sickill/vim-pasta',
    lazy = false -- PERF: lazy load
}

AddPlugin {
    'shortcuts/no-neck-pain.nvim',
    cmd = 'NoNeckPain'
}

AddPlugin {
    'tummetott/reticle.nvim',
    config = true
}

AddPlugin {
    'tversteeg/registers.nvim',
    opts = {
        register_user_command = false,
        show = "*+\"-/_=0123456789abcdefghijklmnopqrstuvwxyz",
        show_empty = false,
        symbols = { tab = '»' },
        trim_whitespace = false,
        window = { border = 'rounded' }
    },
    keys = {
        { '"',     mode = 'n' },
        { '"',     mode = 'v' },
        { '<C-R>', mode = 'i' }
    }
}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)
-- AI Archieve
-- https://github.com/hrsh7th/cmp-copilot
-- https://github.com/madox2/vim-ai
-- https://github.com/zbirenbaum/copilot-cmp
-- https://github.com/zbirenbaum/copilot.lua

-- BUG: Powershell indent issue
-- FEAT: Use of Copilot
-- FEAT: https://github.com/AndrewRadev/linediff.vim
-- FEAT: https://github.com/AndrewRadev/splitjoin.vim
-- FEAT: https://github.com/Bryley/neoai.nvim
-- FEAT: https://github.com/CKolkey/ts-node-action
-- FEAT: https://github.com/Danielhp95/tmpclone-nvim
-- FEAT: https://github.com/LeonHeidelbach/trailblazer.nvim
-- FEAT: https://github.com/RutaTang/compter.nvim
-- FEAT: https://github.com/Weissle/persistent-breakpoints.nvim
-- FEAT: https://github.com/XXiaoA/ns-textobject.nvim
-- FEAT: https://github.com/aaditeynair/conduct.nvim
-- FEAT: https://github.com/andythigpen/nvim-coverage
-- FEAT: https://github.com/cbochs/portal.nvim
-- FEAT: https://github.com/chrisgrieser/nvim-spider
-- FEAT: https://github.com/desdic/agrolens.nvim
-- FEAT: https://github.com/doums/dmap.nvim
-- FEAT: https://github.com/echasnovski/mini.bracketed
-- FEAT: https://github.com/echasnovski/mini.nvim
-- FEAT: https://github.com/echasnovski/mini.splitjoin
-- FEAT: https://github.com/ecthelionvi/NeoComposer.nvim
-- FEAT: https://github.com/ekickx/clipboard-image.nvim
-- FEAT: https://github.com/glacambre/firenvim
-- FEAT: https://github.com/imNel/monorepo.nvim
-- FEAT: https://github.com/isaksamsten/better-virtual-text.nvim
-- FEAT: https://github.com/james1236/backseat.nvim
-- FEAT: https://github.com/kndndrj/nvim-dbee
-- FEAT: https://github.com/nguyenvukhang/nvim-toggler
-- FEAT: https://github.com/niuiic/cp-image.nvim
-- FEAT: https://github.com/nosduco/remote-sshfs.nvim
-- FEAT: https://github.com/nvim-telescope/telescope-dap.nvim
-- FEAT: https://github.com/ofirgall/goto-breakpoints.nvim
-- FEAT: https://github.com/roobert/surround-ui.nvim
-- FEAT: https://github.com/snelling-a/better-folds.nvim
-- FEAT: https://github.com/tenxsoydev/karen-yank.nvim
-- FEAT: https://github.com/utilyre/sentiment.nvim
-- PERF: profiling for auto commands
-- PERF: startuptime
-- TODO: change.txt
-- TODO: context aware popup, using autocmd and position clicked, create
-- TODO: indentation is not identifible when 2
-- TODO: insert.txt
-- TODO: jumplist
-- TODO: location list
-- TODO: marks
-- TODO: motion.txt
-- TODO: quickfix
-- TODO: vsplit or split file opener like find command

require('lazy').setup(Plugins, LazyConfig)
ColoRand()
vim.opt.runtimepath:append('C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\lazy\\nvim-treesitter\\parser')
-- <~>
-- vim: fmr=</>,<~> fdm=marker
