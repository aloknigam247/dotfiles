--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
    Folder        = ' ',
    Function      = ' ',
    History       = ' ',
    Interface     = ' ',
    Key           = ' ',
    Keyword       = ' ',
    Method        = ' ',
    Module        = ' ',
    Namespace     = 'ﬥ ',
    Null          = ' ',
    Number        = ' ',
    Object        = ' ',
    Operator      = ' ',
    Options       = ' ',
    Package       = ' ',
    Property      = ' ',
    Reference     = ' ',
    Snippet       = ' ',
    String        = ' ',
    Struct        = ' ',
    Text          = ' ',
    TypeParameter = ' ',
    Unit          = ' ',
    Value         = ' ',
    Variable      = ' '
}

vim.g.loaded_clipboard_provider = 1

-- Lua Globals
LazyConfig = {
    root = vim.fn.stdpath('data') .. '/lazy', -- directory where plugins will be installed
    defaults = {
        lazy = true, -- should plugins be lazy-loaded?
        version = nil,
    },
    lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json', -- lockfile generated after running update.
    concurrency = nil, ---@type number limit the maximum amount of concurrent tasks
    git = {
        log = { '--since=3 days ago' }, -- show commits from the last 3 days
        timeout = 12000, -- kill processes that take more than 2 minutes
        url_format = 'https://github.com/%s.git',
    },
    dev = {
        path = '~/projects',
        patterns = {}, -- For example {'folke'}
    },
    install = {
        missing = true,
        colorscheme = { },
    },
    ui = {
        size = { width = 0.8, height = 0.8 },
        border = 'rounded',
        icons = {
            cmd        = ' ',
            config     = '',
            event      = '',
            ft         = ' ',
            init       = ' ',
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
        throttle = 20, -- how frequently should the ui process render events
        custom_keys = {},
    },
    diff = {
        cmd = 'git',
    },
    checker = {
        enabled = false,
        concurrency = nil, ---@type number? set to 1 to check for updates very slowly
        notify = true, -- get a notification when new updates are found
        frequency = 3600, -- check for updates every hour
    },
    change_detection = {
        enabled = true,
        notify = true, -- get a notification when changes are found
    },
    performance = {
        cache = {
            enabled = true,
            path = vim.fn.stdpath('state') .. '/lazy/cache',
            -- Once one of the following events triggers, caching will be disabled.
            -- To cache all modules, set this to `{}`, but that is not recommended.
            -- The default is to disable on:
            --  * VimEnter: not useful to cache anything else beyond startup
            --  * BufReadPre: this will be triggered early when opening a file from the command line directly
            disable_events = { },
            ttl = 3600 * 24 * 5, -- keep unused modules for up to 5 days
        },
        reset_packpath = true, -- reset the package path to improve startup time
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
            paths = {}, -- add any custom paths here that you want to indluce in the rtp
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
                'zipPlugin',
            },
        },
    },
    readme = {
        root = vim.fn.stdpath('state') .. '/lazy/readme',
        files = { 'README.md' },
        skip_if_doc_exists = true,
    },
}

Plugins = {}

-- Lua Locals
local border_shape = {
    { '╭', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╮', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '╯', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╰', 'FloatBorder' },
    { '│', 'FloatBorder' },
}

local icons = {
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
            { fg = '#F1D302' }, -- TODO: not good in light bg
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

-- Auto Commands
-- -------------
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

vim.fn.matchadd('HighlightURL', url_matcher, 1) -- TODO: url matcher highlight not working
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
}

-- use 'echasnovski/mini.align'

AddPlugin {
    -- TODO: learn
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
AddPlugin {
    -- TODO: hlargs priority overrides vim-illuminate
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

-- TODO: Use
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
            DOCME = { icon = '', color = 'docs' },
            FEAT  = { icon = '󱩑', color = 'feat' },
            FIX   = { icon = '󰃤', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
            HACK  = { icon = '', color = 'hint' },
            NOTE  = { icon = '', color = 'info', alt = { 'INFO', 'THOUGHT' } },
            PERF  = { icon = '', color = 'perf', alt = { 'OPTIMIZE', 'PERFORMANCE', 'REFACTOR' } },
            TEST  = { icon = '', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
            TODO  = { icon = '', color = 'todo' },
            WARN  = { icon = '', color = 'warn', alt = { 'WARNING' } },
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
    'norcalli/nvim-colorizer.lua',
    cmd = 'ColorizerToggle',
    config = true
}

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
        for i,v in pairs(ColorPalette()) do
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
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: FIx colorscheme for not having cmp match chars hl
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

function FixVisual()
    local bg
    if (vim.o.background ==  'dark') then
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, 50)
    else
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, -20)
    end
    vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
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

AddPlugin { 'atelierbram/Base2Tone-nvim',       event = 'User base2tone'                                               }
AddPlugin { 'maxmx03/FluoroMachine.nvim',       event = 'User fluoromachine'                                           }
AddPlugin { 'Tsuzat/NeoSolarized.nvim',         event = 'User NeoSolarized'                                            }
AddPlugin { 'Mofiqul/adwaita.nvim',             event = 'User adwaita'                                                 }
AddPlugin { 'ray-x/aurora',                     event = 'User aurora'                                                  }
AddPlugin { 'w3barsi/barstrata.nvim',           event = 'User barstrata'                                               }
AddPlugin { 'uloco/bluloco.nvim',               event = 'User bluloco',     dependencies = 'rktjmp/lush.nvim'          }
AddPlugin { 'yashguptaz/calvera-dark.nvim',     event = 'User calvera'                                                 }
AddPlugin { 'lalitmee/cobalt2.nvim',            event = 'User cobalt2',     dependencies = 'tjdevries/colorbuddy.nvim' }
AddPlugin { 'igorgue/danger',                   event = 'User danger'                                                  }
AddPlugin { 'LunarVim/darkplus.nvim',           event = 'User darkplus'                                                }
AddPlugin { 'muchzill4/doubletrouble',          event = 'User doubletrouble'                                           }
AddPlugin { 'maxmx03/dracula.nvim',             event = 'User dracula'                                                 }
AddPlugin { 'sainnhe/edge',                     event = 'User edge'                                                    }
AddPlugin { 'sainnhe/everforest',               event = 'User everforest'                                              }
AddPlugin { 'fenetikm/falcon',                  event = 'User falcon'                                                  }
AddPlugin { 'projekt0n/github-nvim-theme',      event = 'User github'                                                  }
AddPlugin { 'luisiacc/gruvbox-baby',            event = 'User gruvbox-baby'                                            }
AddPlugin { 'ellisonleao/gruvbox.nvim',         event = 'User gruvbox'                                                 }
AddPlugin { 'rebelot/kanagawa.nvim',            event = 'User kanagawa'                                                }
AddPlugin { 'lmburns/kimbox',                   event = 'User kimbox'                                                  }
AddPlugin { 'marko-cerovac/material.nvim',      event = 'User material'                                                }
AddPlugin { 'savq/melange',                     event = 'User melange'                                                 }
AddPlugin { 'kvrohit/mellow.nvim',              event = 'User mellow'                                                  }
AddPlugin { 'shaunsingh/moonlight.nvim',        event = 'User moonlight'                                               }
AddPlugin { 'Domeee/mosel.nvim',                event = 'User mosel'                                                   }
AddPlugin { 'rafamadriz/neon',                  event = 'User neon'                                                    }
AddPlugin { 'rose-pine/neovim',                 event = 'User rose-pine'                                               }
AddPlugin { 'Shatur/neovim-ayu',                event = 'User ayu'                                                     }
AddPlugin { 'EdenEast/nightfox.nvim',           event = 'User nightfox'                                                }
AddPlugin { 'talha-akram/noctis.nvim',          event = 'User noctis'                                                  }
AddPlugin { 'gbprod/nord.nvim',                 event = 'User nord'                                                    }
AddPlugin { 'AlexvZyl/nordic.nvim',             event = 'User nordic'                                                  }
AddPlugin { 'catppuccin/nvim',                  event = 'User catppuccin'                                              }
AddPlugin { 'RRethy/nvim-base16',               event = 'User base16'                                                  }
AddPlugin { 'theniceboy/nvim-deus',             event = 'User deus'                                                    }
AddPlugin { 'Iron-E/nvim-highlite',             event = 'User highlite'                                                }
AddPlugin { 'kaiuri/nvim-juliana',              event = 'User juliana'                                                 }
AddPlugin { 'sam4llis/nvim-tundra',             event = 'User tundra'                                                  }
AddPlugin { 'mhartington/oceanic-next',         event = 'User OceanicNext'                                             }
AddPlugin { 'Yazeed1s/oh-lucy.nvim',            event = 'User oh-lucy'                                                 }
AddPlugin { 'Th3Whit3Wolf/one-nvim',            event = 'User one-nvim'                                                }
AddPlugin { 'cpea2506/one_monokai.nvim',        event = 'User one_monokai'                                             }
AddPlugin { 'olimorris/onedarkpro.nvim',        event = 'User onedarkpro'                                              }
AddPlugin { 'rmehri01/onenord.nvim',            event = 'User onenord'                                                 }
AddPlugin { 'nyoom-engineering/oxocarbon.nvim', event = 'User oxocarbon'                                               }
AddPlugin { 'JoosepAlviste/palenightfall.nvim', event = 'User palenightfall'                                           }
AddPlugin { 'NLKNguyen/papercolor-theme',       event = 'User PaperColor'                                              }
AddPlugin { 'Scysta/pink-panic.nvim',           event = 'User pink-panic',  dependencies = 'rktjmp/lush.nvim'          }
AddPlugin { 'olivercederborg/poimandres.nvim',  event = 'User poimandres'                                              }
AddPlugin { 'lewpoly/sherbet.nvim',             event = 'User sherbet'                                                 }
AddPlugin { 'sainnhe/sonokai',                  event = 'User sonokai'                                                 }
AddPlugin { 'ray-x/starry.nvim',                event = 'User starry'                                                  }
AddPlugin { 'kvrohit/substrata.nvim',           event = 'User substrata'                                               }
AddPlugin { 'jsit/toast.vim',                   event = 'User toast'                                                   }
AddPlugin { 'tiagovla/tokyodark.nvim',          event = 'User tokyodark'                                               }
AddPlugin { 'folke/tokyonight.nvim',            event = 'User tokyonight'                                              }
AddPlugin { 'tomasiser/vim-code-dark',          event = 'User codedark'                                                }
AddPlugin { 'wuelnerdotexe/vim-enfocado',       event = 'User enfocado'                                                }
AddPlugin { 'ntk148v/vim-horizon',              event = 'User horizon'                                                 }
AddPlugin { 'sickill/vim-monokai',              event = 'User vim-monokai'                                             }
AddPlugin { 'bluz71/vim-moonfly-colors',        event = 'User moonfly'                                                 }
AddPlugin { 'bluz71/vim-nightfly-colors',       event = 'User nightfly'                                                }
AddPlugin { 'nxvu699134/vn-night.nvim',         event = 'User vn-night'                                                }
AddPlugin { 'Mofiqul/vscode.nvim',              event = 'User vscode'                                                  }
AddPlugin { 'mcchrish/zenbones.nvim',           event = 'User zenbones',    dependencies = 'rktjmp/lush.nvim'          }
AddPlugin { 'glepnir/zephyr-nvim',              event = 'User zephyr'                                                  }
AddPlugin { 'titanzero/zephyrium',              event = 'User zephyrium'                                               }

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
Light { 'base2tone_drawbridge_light', 'base2tone'    }
Light { 'base2tone_field_light',      'base2tone'    }
Dark  { 'base2tone_forest_dark',      'base2tone'    }
Light { 'base2tone_forest_light',     'base2tone'    }
Light { 'base2tone_heath_light',      'base2tone'    }
Dark  { 'base2tone_lake_dark',        'base2tone'    }
Light { 'base2tone_lake_light',       'base2tone'    }
Light { 'base2tone_lavender_light',   'base2tone'    }
Light { 'base2tone_mall_light',       'base2tone'    }
Dark  { 'base2tone_meadow_dark',      'base2tone'    }
Light { 'base2tone_meadow_light',     'base2tone'    }
Dark  { 'base2tone_morning_dark',     'base2tone'    }
Dark  { 'base2tone_sea_dark',         'base2tone'    }
Light { 'base2tone_sea_light',        'base2tone'    }
Dark  { 'base2tone_space_dark',       'base2tone'    }
Dark  { 'base2tone_suburb_dark',      'base2tone'    }
Dark  { 'bluloco-dark',               '_'            }
Light { 'bluloco-light',               '_'           }
Dark  { 'calvera',                    '_'            }
Dark  { 'carbonfox',                  'nightfox'     }
Dark  { 'catppuccin-frappe',          'catppuccin'   }
Light { 'catppuccin-latte',           'catppuccin'   }
Dark  { 'catppuccin-macchiato',       'catppuccin'   }
Dark  { 'catppuccin-mocha',           'catppuccin'   }
-- Dark  { 'cobalt2',                    '_',           post = function() require('colorbuddy').colorscheme('cobalt2') end } -- FIX: fix and enable
Dark  { 'codedark',                   '_'            }
Dark  { 'danger_dark',                'danger'       }
Light { 'danger_light',               'danger'       }
Dark  { 'darker',                     '_'            }
Dark  { 'darkplus',                   '_'            }
Dark  { 'darksolar',                  'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'dawnfox',                    'nightfox'                                                                                                           }
Dark  { 'dayfox',                     'nightfox'                                                                                                           }
Dark  { 'deepocean',                  'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Light { 'delek',                      '_'                                                                                                                  }
Dark  { 'deus',                       '_',           post = FixVisual                                                                                      }
Dark  { 'doubletrouble',              '_'                                                                                                                  }
Dark  { 'dracula',                    '_'                                                                                                                  }
Dark  { 'dracula',                    'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'dracula_blood',              'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'duskfox',                    'nightfox'                                                                                                           }
Dark  { 'earlysummer',                'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'edge',                       '_'                                                                                                                  }
Light { 'edge',                       '_'                                                                                                                  }
Dark  { 'emerald',                    'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'enfocado',                   '_'            }
Light { 'enfocado',                   '_'            }
Dark  { 'everforest',                 '_'            }
Light { 'everforest',                 '_'            }
Dark  { 'falcon',                     '_'            }
Dark  { 'fluoromachine',              '_',           post = FixIndentBlankline }
Dark  { 'forestbones',                'zenbones'     }
Dark  { 'github_dark',                'github'       }
Light { 'github_light',               'github'       }
Dark  { 'gruvbox',                    '_'            }
Light { 'gruvbox',                    '_'            }
Dark  { 'gruvbox',                    '_',           pre  = SeniorMarsTheme    }
Dark  { 'gruvbox-baby',               '_'            }
Dark  { 'habamax',                    '_',           }
Dark  { 'highlite',                   '_'            }
Dark  { 'horizon',                    '_'            }
Dark  { 'juliana',                    '_'            }
Dark  { 'kanagawa',                   '_'            }
Dark  { 'kimbox',                     '_',           post = FixVisual                                                                                      }
Light { 'limestone',                  'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end } -- TODO: fix method highlight
Dark  { 'lunaperche',                 '_'                                                                                                                  }
Dark  { 'mariana',                    'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'darker'     end                                              }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'deep ocean' end                                              }
Light { 'material',                   '_',           pre = function() vim.g.material_style = 'lighter'    end                                              } -- TODO: fix Visual bg
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'oceanic'    end                                              }
Dark  { 'material',                   '_',           pre = function() vim.g.material_style = 'palenight'  end, post = function() FixLineNr('#757da4') end  }
Dark  { 'material',                   'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'melange',                    '_'            }
Light { 'melange',                    '_'            }
Dark  { 'mellow',                     '_'            }
Dark  { 'middlenight_blue',           'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'monokai',                    'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'monokai',                    'vim-monokai'  }
Dark  { 'moonfly',                    '_'            }
Dark  { 'moonlight',                  '_'            }
Dark  { 'moonlight',                  'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'mosel',                      '_'            }
Dark  { 'neobones',                   'zenbones'     }
Light { 'neobones',                   'zenbones'     }
Dark  { 'neon',                       '_',           pre = function() vim.g.neon_style = 'dark'    end, post = FixVisual }
Dark  { 'neon',                       '_',           pre = function() vim.g.neon_style = 'default' end, post = FixVisual }
Dark  { 'neon',                       '_',           pre = function() vim.g.neon_style = 'doom'    end, post = FixVisual }
Light { 'neon',                       '_',           pre = function() vim.g.neon_style = 'light'   end, post = function() FixVisual() FixDiagnosticInfo() end }
Dark  { 'nightfly',                   '_'            }
Dark  { 'nightfox',                   'nightfox'     }
Dark  { 'noctis_azureus',             'noctis'       }
Light { 'noctis_hibernus',            'noctis'       }
Light { 'noctis_lilac',               'noctis'       }
Light { 'noctis_lux',                 'noctis'       }
Dark  { 'noctis_minimus',             'noctis'       }
Dark  { 'noctis_sereno',              'noctis'       }
Dark  { 'noctis_uva',                 'noctis'       }
Dark  { 'noctis_viola',               'noctis'       }
Dark  { 'nord',                       '_'            }
Dark  { 'nordbones',                  'zenbones'     }
Dark  { 'nordfox',                    'nightfox'     }
Dark  { 'nordic',                     '_'            }
Dark  { 'oceanic',                    'starry',      pre = function() require('starry').setup({custom_highlights = { LineNr = { underline = false }}}) end }
Dark  { 'oh-lucy',                    '_'            }
Dark  { 'oh-lucy-evening',            'oh-lucy'      }
Dark  { 'one-nvim',                   '_'            }
Dark  { 'one_monokai',                '_'            }
Dark  { 'onedark',                    'onedarkpro'   }
Dark  { 'onedark_dark',               'onedarkpro'   }
Dark  { 'onedark_vivid',              'onedarkpro'   }
Light { 'onelight',                   '_'            }
Dark  { 'onenord',                    '_'            }
Light { 'onenord',                    '_'            }
Dark  { 'oxocarbon',                  '_'            }
Light { 'oxocarbon',                  '_'            }
Dark  { 'palenight',                  '_'            }
Dark  { 'palenightfall',              '_'            }
Dark  { 'peachpuff',                  '_'            }
Light { 'pink-panic',                 '_'            }
Dark  { 'poimandres',                 '_',           pre = function() require('poimandres').setup() end }
Dark  { 'rose-pine',                  '_'            }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'main'}) end }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'moon'}) end }
Dark  { 'rosebones',                  'zenbones'     }
Light { 'rosebones',                  'zenbones'     }
Light { 'seoulbones',                 'zenbones'     }
Dark  { 'sherbet',                    '_'            }
Light { 'shine',                      '_'            }
Dark  { 'slate',                      '_'           ,post = FixNontext                                      }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'andromeda' end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'atlantis'  end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'default'   end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'maia'      end }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'shusia'    end }
Dark  { 'substrata',                  '_'            }
Dark  { 'terafox',                    'nightfox'     }
Dark  { 'toast',                      '_'            }
Light { 'toast',                      '_'            }
Dark  { 'tokyobones',                 'zenbones'     }
Light { 'tokyobones',                 'zenbones'     }
Dark  { 'tokyodark',                  '_'            }
Light { 'tokyonight-day',             'tokyonight'   }
Dark  { 'tokyonight-moon',            'tokyonight'   }
Dark  { 'tokyonight-night',           'tokyonight'   }
Dark  { 'tokyonight-storm',           'tokyonight'   }
Dark  { 'tundra',                     '_',           pre = function() require('nvim-tundra').setup() end                                                     }
Dark  { 'vn-night',                   '_'            }
Dark  { 'vscode',                     '_'            }
Light { 'vscode',                     '_'            }
Light { 'zellner',                    '_'            }
Dark  { 'zenburned',                  'zenbones'     }
Dark  { 'zenwritten',                 'zenbones'     }
Light { 'zenwritten',                 'zenbones'     }
Dark  { 'zephyr',                     '_'            }
Dark  { 'zephyrium',                  '_'            }

function ColoRand(ind)
    math.randomseed(os.time())
    ind = ind or math.random(1, #colos)
    local selection = colos[ind]
    local scheme = selection[1]
    local bg = selection.bg
    local module = selection[2]
    local precmd = selection.pre
    local postcmd = selection.post
    vim.g.ColoRand = ind .. ':' .. scheme .. ':' .. bg .. ':' .. module
    -- vim.notify("Colorscheme " .. ind .. ':' .. scheme .. ':' .. bg .. ':' .. module)
    vim.o.background = bg
    vim.api.nvim_exec_autocmds('User', {pattern = module == '_' and scheme or module}) -- Load colorscheme
    if (precmd) then
        precmd()
    end
    vim.cmd.colorscheme(scheme)
    vim.cmd[[highlight clear CursorLine]]
    if (postcmd) then
        postcmd()
    end
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
    -- TODO: slow completion
    -- TODO: cmd-cmdline for windows
    -- TODO: cmp-path for windows
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
            -- TODO: how about <TAB> for complete common chars and arrow+enter to select completion
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
                            return vim.api.nvim_list_bufs() -- TODO: disable for buffers > 1000 lines
                        end
                    }
                },
                { name = 'fuzzy_buffer' },
                { name = 'neorg' },
                { name = 'nerdfont' },
                { name = 'nvim_lsp' }, -- TODO: increase priority
                { name = 'path' },
                { name = 'snippy' },
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        local bg_mode = vim.o.background
        for key, value in pairs(kind_hl) do
            vim.api.nvim_set_hl(0, 'CmpItemKind' .. key, value[bg_mode])
        end
    end,
    dependencies = {
        'chrisgrieser/cmp-nerdfont',
        'dcampos/cmp-snippy',
        'dcampos/nvim-snippy',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        { 'tzachar/cmp-fuzzy-buffer', dependencies = {'tzachar/fuzzy.nvim', dependencies = { 'romgrk/fzy-lua-native', build = 'make' }} },
    }, -- TODO: check if lazy
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
-- use {
--     'jbyuki/one-small-step-for-vimkind',
--     config = function()
--         local dap = require'dap'
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
--     end
-- }
-- https://github.com/nvim-telescope/telescope-vimspector.nvim
-- https://github.com/puremourning/vimspector
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'Pocco81/dap-buddy.nvim'
-- use {
--     'mfussenegger/nvim-dap',
--     config = function()
--         vim.cmd[[
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
--     end
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
    -- TODO: lazy load
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
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
                    error   = icons.diagnostic.error,
                    hint    = icons.diagnostic.hint,
                    info    = icons.diagnostic.info,
                    warning = icons.diagnostic.warn,
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
            hijack_cursor = false,
            hijack_directories = {
                auto_open = true,
                enable = true,
            },
            hijack_netrw = true,
            hijack_unnamed_buffer_when_opening = true,
            ignore_buffer_on_setup = false,
            ignore_ft_on_setup = {},
            live_filter = {
                always_show_folders = true,
                prefix = '[FILTER]: ',
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
            notify = { threshold = vim.log.levels.INFO },
            on_attach = 'disable',
            open_on_setup = false,
            open_on_setup_file = false,
            prefer_startup_root = false,
            reload_on_bufenter = false,
            remove_keymaps = false,
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
                        item   = '│',
                        none   = ' ',
                    },
                    inline_arrows = true,
                },
                indent_width = 2,
                root_folder_label = ':~:s?$?/..?',
                icons = {
                    git_placement = 'after',
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
                            deleted   = '',
                            ignored   = '',
                            renamed   = '➜',
                            staged    = '',
                            unmerged  = '',
                            unstaged  = '',
                            untracked = '★', -- TODO: better icons
                        },
                        -- TODO: icons
                        symlink = '',
                    },
                    padding = ' ',
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
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
            update_focused_file = {
                debounce_delay = 15,
                enable = true,
                ignore_list = {},
                update_root = true,
            },
            view = {
                adaptive_size = false,
                centralize_selection = false,
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
                    list = {}, -- user mappings go here
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
-- {
--     'nvim-neo-tree/neo-tree.nvim',
--     cmd = 'Neotree',
--     module = false,
--     config = function()
--         vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
--         require('neo-tree').setup({
--             default_component_configs = {
--                 git_status = {
--                     symbols = {
--                         -- Change type
--                         added     = '', -- or '✚', but this is redundant info if you use git_status_colors on the name
--                         modified  = '', -- or '', but this is redundant info if you use git_status_colors on the name
--                         deleted   = '',-- this can only be used in the git_status source
--                         renamed   = '',-- this can only be used in the git_status source
--                         -- Status type
--                         untracked = '',
--                         ignored   = '',
--                         unstaged  = '',
--                         staged    = '',
--                         conflict  = '',
--                     }
--                 },
--                 icon = {
--                     folder_closed = '',
--                     folder_open = '',
--                     folder_empty = '',
--                     default = ''
--                 },
--                 indent = {
--                     last_indent_marker = '╰'
--                 }
--             },
--             diagnostics = {
--               autopreview = true, -- Whether to automatically enable preview mode
--               autopreview_config = {}, -- Config table to pass to autopreview (for example `{ use_float = true }`)
--               autopreview_event = 'neo_tree_buffer_enter', -- The event to enable autopreview upon (for example `'neo_tree_window_after_open'`)
--               bind_to_cwd = true,
--               diag_sort_function = 'severity', -- 'severity' means diagnostic items are sorted by severity in addition to their positions.
--                                                -- 'position' means diagnostic items are sorted strictly by their positions.
--                                                -- May also be a function.
--               follow_behavior = { -- Behavior when `follow_current_file` is true
--                 always_focus_file = true, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
--                 expand_followed = true, -- Ensure the node of the followed file is expanded
--                 collapse_others = true, -- Ensure other nodes are collapsed
--               },
--             },
--             filesystem = {
--                 follow_current_file = true,
--                 hijack_netrw_behavior = 'open_current'
--             },
--             popup_border_style = 'rounded',
--             sources = {
--                 'diagnostics',
--                 'filesystem'
--             }
--         })
--     end,
--     dependencies = { 'MunifTanjim/nui.nvim', 'mrbjarksen/neo-tree-diagnostics.nvim', 'nvim-lua/plenary.nvim' }
-- },
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Folding     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: work on it
AddPlugin {
    'anuvyklack/pretty-fold.nvim',
    -- cond = function()
    --     return vim.o.foldmethod == 'marker'
    -- end,
    config = function()
        require('pretty-fold').setup()
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
    -- lazy = false
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
-- TODO: https://github.com/gfanto/fzf-lsp.nvim
-- TODO: https://github.com/ibhagwan/fzf-lua
-- TODO: https://github.com/ojroques/nvim-lspfuzzy
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Git       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/akinsho/git-conflict.nvim
-- https://github.com/cynix/vim-mergetool
-- use 'hotwatermorning/auto-git-diff'
-- use 'ldelossa/gh.nvim'
AddPlugin {
    -- TODO: global icons for git signs
    'lewis6991/gitsigns.nvim',
    cmd = 'Gitsigns',
    opts = {
        signs = {
            add          = { hl = 'GitSignsAdd'   , text = '┃', numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'    },
            change       = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            delete       = { hl = 'GitSignsDelete', text = '', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        },
        current_line_blame_formatter_opts = {
            relative_time = true
        },
        current_line_blame_formatter = '  <author>  <committer_time>  <summary>',
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
        diff_opts = {
            internal = true
        },
        preview_config = {
            border = 'rounded'
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
            -- TODO: fix icon for Makefile
            -- TODO: better c++ icons
            ['c++'] = { color = '#F34B7D', cterm_color = '204', icon = '', name = 'CPlusPlus' },
            cc      = { color = '#F34B7D', cterm_color = '204', icon = '', name = 'CPlusPlus' },
            cp      = { color = '#F34B7D', cterm_color = '204', icon = '', name = 'Cp'        },
            cpp     = { color = '#F34B7D', cterm_color = '204', icon = '', name = 'Cpp'       },
            cs      = { color = '#596706', cterm_color = '58',  icon = '', name = 'Cs'        },
            csproj  = { color = '#854CC7', cterm_color = '98',  icon = '', name = 'Csproj'    },
            csv     = { color = '#89E051', cterm_color = '113', icon = '', name = 'Csv'       },
            md      = { color = '#42A5F5', cterm_color = '75',  icon = '', name = 'Md'        },
            mdx     = { color = '#519ABA', cterm_color = '67',  icon = '', name = 'Mdx'       },
            norg    = { color = '#40916C', cterm_color = '48',  icon = '', name = 'Neorg'     },
            ps1     = { color = '#4D5A5E', cterm_color = '240', icon = '', name = 'PromptPs1' },
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
AddPlugin {
    -- TODO: does not work when indent space is 2 in file, shiftwidth is the option
    -- TODO: delay in autocmd to speed up scrolling
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
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      LSP       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'Decodetalkers/csharpls-extended-lsp.nvim'
-- use 'Hoffs/omnisharp-extended-lsp.nvim'
-- https://github.com/lvimuser/lsp-inlayhints.nvim
-- https://github.com/DNLHC/glance.nvim

-- TODO: resolve with Lspsaga
-- TODO: use treesitter statusline if LSP not available
AddPlugin {
    -- TODO: https://github.com/utilyre/barbecue.nvim
    'SmiteshP/nvim-navic',
    enabled = false,
    event = 'LspAttach',
    opts = {
        depth_limit = 0,
        depth_limit_indicator = '..',
        highlight = true,
        icons = vim.g.cmp_kinds,
        safe_output = true,
        separator = '  ',
    },
}

-- TODO: Resolve usage
AddPlugin {
    'liuchengxu/vista.vim',
    config = function()
        vim.cmd[[
            let g:vista_default_executive = 'nvim_lsp'
            let g:vista_icon_indent = ['╰─ ', '├─ ']
            ' TODO: use global icons
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
            -- local navic = require('nvim-navic')
            -- Mappings.
            require("nvim-navbuddy").attach(client, bufnr)
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
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

            -- TODO: better popup management
            vim.cmd[[
                aunmenu PopUp
            ]]

            -- TODO: group function
            function PopupMenuAdd(title, action)
                title = title:gsub(' ', '\\ ')
                vim.cmd.nnoremenu('PopUp.' .. title .. ' ' .. action)
            end

            PopupMenuAdd('Declaration            gD',  '<Cmd>lua vim.lsp.buf.declaration()<CR>')
            PopupMenuAdd('Definition            F12',  '<Cmd>lua vim.lsp.buf.definition()<CR>')
            PopupMenuAdd('Hover                  \\h', '<Cmd>Lspsaga hover_doc<CR>')
            PopupMenuAdd('Implementation         gi',  '<Cmd>lua vim.lsp.buf.implementation()<CR>')
            PopupMenuAdd('LSP Finder',                 '<Cmd>Lspsaga lsp_finder<CR>')
            PopupMenuAdd('References      Shift F12',  '<Cmd>lua vim.lsp.buf.references()<CR>')
            PopupMenuAdd('Rename                 F2',  '<Cmd>Lspsaga rename<CR>')
            PopupMenuAdd('Type Definition        gt',  '<Cmd>lua vim.lsp.buf.type_definition()<CR>')

            -- navic.attach(client, bufnr) -- TODO: use this
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
                    lspconfig.powershell_es.setup {
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
                elseif server_name == 'omnisharp' then
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
    keys = { '<F12>', '<S-F12>' }
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

AddPlugin {
    -- TODO: <M-F12> mapping for lsp_finder
    'glepnir/lspsaga.nvim',
    branch = 'main',
    cmd = 'Lspsaga',
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
            split = '<C-x>',
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
            split = '<C-x>',
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
            code_action = '💡',
            diagnostic = '🐞', -- TODO: use global icon
            incoming = ' ',
            outgoing = ' ',
            hover = ' ',
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

-- AddPlugin { 'p00f/clangd_extensions.nvim' } -- NOTE: not much usefull until inline virtual text
-- is supported

-- use 'razzmatazz/csharp-language-server'

-- TODO: resolve usage
AddPlugin {
    'ray-x/navigator.lua',
    event = 'LspAttach'
}

-- TODO: resolve usage
AddPlugin {
    'rmagatti/goto-preview',
    config = true,
    event = 'LspAttach'
}

-- TODO: resolve usage
AddPlugin {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    config = true
}

-- TODO: resolve usage
AddPlugin {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    config = true
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
AddPlugin {
    'davidgranstrom/nvim-markdown-preview',
    cmd = 'MarkdownPreview'
}
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
    -- TODO: check if vim.input is possible for annotate message
    -- TODO: Silence bookmark addition/removal
    -- TODO: location of bookmark files
    'MattesGroeger/vim-bookmarks',
    config = function()
        vim.cmd[[
            let g:bookmark_annotation_sign = ''
            let g:bookmark_display_annotation = 1
            let g:bookmark_highlight_lines = 1
            let g:bookmark_location_list = 1
            let g:bookmark_no_default_key_mappings = 1
            let g:bookmark_save_per_working_dir = 1
            let g:bookmark_sign = '' " TODO: paper clip or someother icon
            nmap ba <Plug>BookmarkAnnotate
            nmap bm <Plug>BookmarkToggle
            nmap bn <Plug>BookmarkNext
            nmap bp <Plug>BookmarkPrev
            nmap bs <Plug>BookmarkShowAll
        ]]
    end,
    keys = { 'ba', 'bm', 'bn', 'bp', 'bs'},
}

-- https://github.com/ThePrimeagen/harpoon --> plenary
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
-- use {
--      'lukas-reineke/headlines.nvim',
--      config = function()
--          require('headlines').setup()
--      end,
--  }
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
            open_split = { '<c-x>' }, -- open buffer in new split
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
            error = icons.diagnostic.error,
            warning = icons.diagnostic.warn,
            hint = icons.diagnostic.hint,
            information = icons.diagnostic.info,
            other = icons.diagnostic.other
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
    -- | split       | open the item in vertical split                          | <C-x>   |
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Screen Saver  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin { 'tamton-aquib/duck.nvim' }

Sleeper = {
    timer = vim.loop.new_timer(),
    last = 1,
    sleeps = {
        { start = function() require('duck').hatch('🐌') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🐤') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('👻') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🤖') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🦜') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
    }
}

function ResetSleeper()
    Sleeper.timer:stop()
    Sleeper.sleeps[Sleeper.last].stop()

    Sleeper.timer:start(300000, 0, vim.schedule_wrap(function()
        Sleeper.last = math.random(1, #Sleeper.sleeps)
        Sleeper.sleeps[Sleeper.last].start()
    end
    ))
end

vim.api.nvim_create_autocmd({'CursorHold'} , {callback = ResetSleeper})
vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'} , {callback = function() Sleeper.sleeps[Sleeper.last].stop() end})
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Sessions    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- TODO: Add capabilities to save and load custom settings like lsp/git... using hooks
    'rmagatti/auto-session',
    cmd = 'SaveSession',
    config = function()
        vim.g.auto_session_suppress_dirs = { 'C:\\Users\\aloknigam', '~' }
        require('auto-session').setup({
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Status Line  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- https://github.com/rebelot/heirline.nvim
    'nvim-lualine/lualine.nvim',
    config = function()
        Icon_index = 0
        local function LspIcon()
            local anim = {'䷀', '䷪',  '䷍', '䷈', '䷉', '䷌', '䷫'}
            Icon_index = (Icon_index) % #anim + 1
            return anim[Icon_index]
        end
        -- local navic = require('nvim-navic')
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = 'auto',
                -- component_separators = { left = '', right = ''},
                -- section_separators = { left = '', right = ''},
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
        --         disabled_filetypes = {
        --             statusline = {},
        --             winbar = {},
        --         },
        --         ignore_focus = {},
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
                        color = { gui = 'bold,italic' },
                        fmt = function(str)
                            return str:sub(1,1)
                        end
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
                        'diff',
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
                        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
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
                        newfile_status = false,   -- Display new file status (new file means no write after created)
                        on_click = function()
                            vim.cmd('NvimTreeToggle')
                        end,
                        path = 0,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = '●',      -- Text to show when the file is modified.
                            readonly = '',      -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]',     -- Text to show for new created file before first writting
                        }
                    }
                },
                lualine_x = {
                    -- TODO: add showcmd
                    -- https://github.com/nvim-lualine/lualine.nvim/issues/949
                    {
                        LspIcon,
                        cond = function()
                            return #vim.lsp.get_active_clients({bufnr = 0}) ~= 0
                        end,
                        on_click = function()
                            vim.cmd('LspInfo')
                        end,
                        separator = ''
                    },
                    { 'g:session_icon', separator = '' },
                    'fileformat',
                    'encoding'
                },
                lualine_y = {
                    {
                        'progress',
                        on_click = function ()
                            local satellite = require('satellite')
                            if satellite.enabled then
                                vim.cmd('SatelliteDisable')
                                satellite.enabled = false
                            else
                                vim.cmd('SatelliteEnable')
                                satellite.enabled = true
                            end
                        end
                    }
                },
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            -- tabline = {
            --     lualine_a = {'filename'},
            -- },
            winbar = {
                lualine_a = {
                    {
                        'filename',
                        -- TODO: Fix it, how about using multiple statusbars only ?
                        -- TODO: exclude filetypes
                        -- cond = function()
                        --     return vim.fn.winnr('$') > 2 -- TODO: triggers on completion
                        -- end
                    }
                },
            --     lualine_b = {
            --         { navic.get_location, cond = navic.is_available },
            --         -- { function () return require('lspsaga.symbolwinbar').get_symbol_node() end}
            --     }
            },
            inactive_winbar = {
                lualine_a = {
                    {
                        'filename',
                        -- TODO: Fix it
                        -- cond = function()
                        --     return vim.fn.winnr('$') > 2
                        -- end
                    }
                },
            --     lualine_b = {
            --         { navic.get_location, cond = navic.is_available }
            --     }
            },
            extensions = { 'nvim-tree', 'quickfix', 'symbols-outline', 'toggleterm' }
        }
    end,
    event = 'CursorHold'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
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
    -- TODO: padded dropdown menu
    -- TODO: https://github.com/nvim-telescope/telescope-fzf-native.nvim
    -- TODO: https://github.com/nvim-telescope/telescope-fzy-native.nvim
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
                        ['<C-x>']      = actions.select_horizontal,
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
                        ['<C-x>']      = actions.select_horizontal,
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
AddPlugin {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = true
}
-- https://github.com/elijahdanko/ttymux.nvim
-- https://github.com/jlesquembre/nterm.nvim
-- https://github.com/kassio/neoterm
-- https://github.com/nat-418/termitary.nvim
-- https://github.com/nikvdp/neomux
-- https://github.com/numToStr/FTerm.nvim
-- https://github.com/oberblastmeister/termwrapper.nvim
-- https://github.com/pianocomposer321/consolation.nvim
-- https://github.com/s1n7ax/nvim-terminal
-- https://github.com/voldikss/vim-floaterm
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
    -- TODO: explore indent
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
    -- TODO: add underline to all params
    'm-demare/hlargs.nvim',
    config = function(opts)
        require('hlargs').setup({
            use_colorpalette = true,
            colorpalette = ColorPalette(),
            paint_catch_blocks = {
                declarations = true,
                usages = true
            },
            extras = {
                named_parameters = true,
            },
            excluded_argnames = {
                declarations = {
                    python = { 'self', 'cls' },
                    lua = { 'self' }
                },
                usages = {
                    python = { 'self', 'cls' },
                    lua = { 'self' }
                }
            }
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      TUI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- TODO: cmdline
    -- TODO: messages
    -- TODO: popupmenu
    -- TODO: redirect
    -- TODO: commands
    -- TODO: notify
    -- TODO: lsp
    -- TODO: markdown
    -- TODO: smart_move
    -- TODO: showmode in lualine
    -- TODO: @recording messages from messages
    -- TODO: cmdline and popup together
    -- TODO: classic commandline
    -- TODO: hide written messages
    -- TODO: clean cmdline_popup
    -- TODO: classic bottom cmdline for search
    -- TODO: hide search in virtual text
    -- TODO: lsp progress
    -- TODO: notify-send
    -- TODO: health checks
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
                    cmdline = { pattern = '^:', icon = '', lang = 'vim' },
                    search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
                    search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
                    filter = { pattern = '^:%s*!', icon = '$', lang = 'powershell' },
                    lua = { pattern = '^:%s*lua%s+', icon = '', lang = 'lua' },
                    help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
                    input = {}, -- Used by input()
                    -- lua = false, -- to disable a format, set to `false`
                },
            },
            messages = {
                -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                -- This is a current Neovim limitation.
                enabled = false, -- enables the Noice messages UI
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
                checker = true, -- Disable if you don't want health checks to run
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
            views = {}, ---@see section on views
            routes = {}, --- @see section on routes
            status = {}, --- @see section on statusline components
            format = {}, --- @see section on formatting
        })
    end,
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    enabled = false,
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
vim.notify = function(msg, level, opt)
    require('notify') -- lazy loads nvim-notify and set vim.notify = notify
    vim.notify(msg, level, opt)
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Utilities    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: use 'AckslD/nvim-trevJ.lua'
-- TODO: https://github.com/wellle/targets.vim

AddPlugin {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- https://github.com/EtiamNullam/deferred-clipboard.nvim

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
        create_commands = false
    },
    keys = {
        { '<Leader>dP', function() return require('debugprint').debugprint({ above = true }) end,                           expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true,          variable = true }) end, expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true,          variable = true }) end, expr = true, mode = 'v' },
        { '<Leader>dd', function() return require('debugprint').deleteprints() end,                                                      mode = 'n' },
        { '<Leader>dp', function() return require('debugprint').debugprint() end,                                           expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,                        expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,                        expr = true, mode = 'v' },
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

-- https://github.com/emileferreira/nvim-strict
-- https://github.com/folke/neoconf.nvim
-- use 'jbyuki/instant.nvim'
-- https://github.com/jghauser/mkdir.nvim

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
    -- Lua copy https://github.com/ojroques/nvim-osc52
    -- FIXME: not working
    'ojroques/vim-oscyank',
    cond = function()
        -- Check if connection is ssh
        return vim.env.SSH_CLIENT ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif]]
    end,
    lazy = false
}

AddPlugin {
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
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

-- TODO: use command sequence to change background of terminal to nvim background
-- AddPlugin {
--     'typicode/bg.nvim',
--     lazy = false
-- }

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

-- TODO: https://github.com/AndrewRadev/splitjoin.vim
-- TODO: https://github.com/Bekaboo/deadcolumn.nvim
-- TODO: https://github.com/Bryley/neoai.nvim
-- TODO: https://github.com/CKolkey/ts-node-action
-- TODO: https://github.com/HiPhish/nvim-ts-rainbow2
-- TODO: https://github.com/JellyApple102/easyread.nvim
-- TODO: https://github.com/Jxstxs/conceal.nvim
-- TODO: https://github.com/LeonHeidelbach/trailblazer.nvim
-- TODO: https://github.com/NTBBloodbath/sweetie.nvim
-- TODO: https://github.com/aaronhallaert/advanced-git-search.nvim
-- TODO: https://github.com/askfiy/visual_studio_code
-- TODO: https://github.com/astaos/nvim-ultivisual
-- TODO: https://github.com/axlebedev/vim-footprints
-- TODO: https://github.com/cbochs/portal.nvim
-- TODO: https://github.com/chrisgrieser/nvim-alt-substitute
-- TODO: https://github.com/doums/dmap.nvim
-- TODO: https://github.com/dundargoc/fakedonalds.nvim
-- TODO: https://github.com/echasnovski/mini.bracketed
-- TODO: https://github.com/echasnovski/mini.splitjoin
-- TODO: https://github.com/ecthelionvi/NeoColumn.nvim
-- TODO: https://github.com/gbprod/yanky.nvim
-- TODO: https://github.com/james1236/backseat.nvim
-- TODO: https://github.com/lalitmee/browse.nvim
-- TODO: https://github.com/loctvl842/monokai-pro.nvim
-- TODO: https://github.com/lukas-reineke/virt-column.nvim
-- TODO: https://github.com/luukvbaal/statuscol.nvim
-- TODO: https://github.com/m4xshen/smartcolumn.nvim
-- TODO: https://github.com/madox2/vim-ai
-- TODO: https://github.com/nosduco/remote-sshfs.nvim
-- TODO: https://github.com/nvim-telescope/telescope-dap.nvim
-- TODO: https://github.com/roobert/node-type.nvim
-- TODO: https://github.com/roobert/surround-ui.nvim
-- TODO: https://github.com/sickill/vim-pasta
-- TODO: https://github.com/simrat39/desktop-notify.nvim
-- TODO: https://github.com/tamton-aquib/flirt.nvim
-- TODO: https://github.com/tummetott/reticle.nvim
-- TODO: https://github.com/tzachar/local-highlight.nvim
-- TODO: https://github.com/willothy/flatten.nvim
-- TODO: https://github.com/xiyaowong/virtcolumn.nvim
-- TODO: https://github.com/ziontee113/SelectEase
-- TODO: AddPlugin { 'SmiteshP/nvim-navbuddy', lazy = false }

require('lazy').setup(Plugins, LazyConfig)
ColoRand()
vim.opt.runtimepath:append('C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\lazy\\nvim-treesitter\\parser')

-- <~>
-- TODO: context aware popup, using autocmd and position clicked
-- TODO: Doc to read change.txt
-- TODO: Doc to read insert.txt
-- TODO: location list/quickfix
-- TODO: marks
-- TODO: motion.txt
-- TODO: per file configurations
-- TODO: auto wrap file if longest line is 200 chars long, use a defer function
-- TODO: indentation is not identifible
-- TODO: NeovideRegisterRightClick
-- vim: fmr=</>,<~> fdm=marker
