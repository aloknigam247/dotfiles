--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

-- TODO: Speedup
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configurations ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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

vim.cmd[[autocmd User PackerCompileDone lua vim.notify("PackerCompile Done", vim.log.levels.INFO)]]

require('packer').startup({
config = {
    auto_clean = true,
    auto_reload_compiled = false,
    -- PERF: [ABSTRACT IDE] Move to lua dir so impatient.nvim can cache it
    -- compile_path = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua',
    display = {
        -- open_fn = require('packer.util').float
        open_fn = function()
            local result, win, buf = require('packer.util').float {
                border = border_shape
            }
            vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')
            return result, win, buf
        end
    },
    ensure_dependencies = true,
    git = {
        clone_timeout = 600, -- Timeout, in seconds, for git clones
    },
    log = {
        -- level = 'debug'
    },
    profile = {
        enable = true,
        threshold = 0.0001
    },
    -- autoremove = true
},
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Packer     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
function(use)
use 'wbthomason/packer.nvim'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Aligns     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
    use {
        'dhruvasagar/vim-table-mode',
        cmd = 'TableModeEnable'
    }

-- use 'junegunn/vim-easy-align'
-- use 'godlygeek/tabular'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Auto Pairs   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
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
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Coloring    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/David-Kunz/markid
use {
    'RRethy/vim-illuminate',
    config = function()
        -- TODO: fix colors
        -- TODO: use bacl ground colors
        vim.cmd[[
           hi IlluminatedWordText guibg = underline
           hi IlluminatedWordRead guibg = #A5BE00 guifg = #000000
           hi IlluminatedWordWrite guibg = #1F7A8C gui = italic
           hi LspReferenceText guibg = #679436
           hi LspReferenceWrite guibg = #A5BE00
           hi LspReferenceRead guibg = #427AA1
       ]]
    end
}

use 'azabiong/vim-highlighter' -- TODO: create context menu

use {
    'folke/lsp-colors.nvim',
    event = "LspAttach"
}

use {
    -- TODO: show todo comments in statusline
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
    end,
    event = "BufRead"
}

use {
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
}

use {
    'melkster/modicator.nvim',
    after = 'lualine.nvim',
    config = function()
        -- TODO: on click functions for sections
        local modicator = require('modicator')
        local modes = {
            ['R'] = vim.api.nvim_get_hl_by_name('lualine_a_replace', true).background,
            ['S'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['V'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
            ['c'] = vim.api.nvim_get_hl_by_name('lualine_a_command', true).background,
            ['i'] = vim.api.nvim_get_hl_by_name('lualine_a_insert', true).background,
            ['n'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['s'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['v'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
        }
        modicator.setup({
            line_numbers = true,
            cursorline = true,
            highlights = {
                modes = modes
            }
        })

        modicator.set_highlight(modes['n'])
    end
}

use {
    'norcalli/nvim-colorizer.lua',
    cmd = "ColorizerToggle",
    config = function()
        require('colorizer').setup()
    end
}

use {
    't9md/vim-quickhl',
    config = function()
        vim.cmd[[
            nmap <Leader>w <Plug>(quickhl-manual-this)
            xmap <Leader>w <Plug>(quickhl-manual-this)
            nmap <Leader>W <Plug>(quickhl-manual-reset)
            xmap <Leader>W <Plug>(quickhl-manual-reset)
        ]]
    end,
    keys = {'<Leader>w', "<Leader>W"}
}

use {
    'tribela/vim-transparent',
    cmd = 'TransparentToggle'
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Colorscheme   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- local function hex_to_rgb(hex)
--   return HEX_DIGITS[string.sub(hex, 1, 1)] * 16 + HEX_DIGITS[string.sub(hex, 2, 2)],
--     HEX_DIGITS[string.sub(hex, 3, 3)] * 16 + HEX_DIGITS[string.sub(hex, 4, 4)],
--     HEX_DIGITS[string.sub(hex, 5, 5)] * 16 + HEX_DIGITS[string.sub(hex, 6, 6)]
-- end

-- local function rgb_to_hex(r, g, b)
--   return bit.tohex(bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b), 6)
-- end

-- local function darken(hex, pct)
--   pct = 1 - pct
--   local r, g, b = hex_to_rgb(string.sub(hex, 2))
--   r = math.floor(r * pct)
--   g = math.floor(g * pct)
--   b = math.floor(b * pct)
--   return string.format("#%s", rgb_to_hex(r, g, b))
-- end
--       local darkerbg = darken(M.colors.base00, 0.1)
--       local darkercursorline = darken(M.colors.base01, 0.1)
--       local darkerstatusline = darken(M.colors.base02, 0.1)

-- TODO: lazyload
-- https://github.com/lifepillar/vim-colortemplate
-- https://github.com/folke/styler.nvim
use 'rktjmp/lush.nvim' -- zenbones
use 'tjdevries/colorbuddy.vim' -- onebuddy gruvbuddy
-- << Light >>
use 'EdenEast/nightfox.nvim' -- dayfox dawnfox
use 'Mofiqul/adwaita.nvim'
use 'NLKNguyen/papercolor-theme'
use 'Shatur/neovim-ayu'
use 'Th3Whit3Wolf/one-nvim'
use 'Th3Whit3Wolf/onebuddy'
use 'Tsuzat/NeoSolarized.nvim'
use 'atelierbram/Base2Tone-nvim'
use 'catppuccin/nvim'
use 'jsit/toast.vim'
use 'marko-cerovac/material.nvim'
use 'mcchrish/zenbones.nvim'
use 'olimorris/onedarkpro.nvim'
use 'projekt0n/github-nvim-theme'
use 'rafamadriz/neon'
-- TODO: use 'ray-x/starry.nvim' -- limestone
use 'rmehri01/onenord.nvim'
use 'rose-pine/neovim'
use 'sainnhe/edge'
use 'sainnhe/everforest'

--     -- << Dark >>
use 'Domeee/mosel.nvim'
use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
use 'LunarVim/darkplus.nvim'
use 'Mofiqul/adwaita.nvim'
use 'NLKNguyen/papercolor-theme'
use 'Shatur/neovim-ayu'
use 'Th3Whit3Wolf/one-nvim'
use 'Th3Whit3Wolf/onebuddy'
use 'Tsuzat/NeoSolarized.nvim'
use 'Yazeed1s/oh-lucy.nvim'
use 'atelierbram/Base2Tone-nvim'
use 'catppuccin/nvim'
use 'cpea2506/one_monokai.nvim'
use 'fenetikm/falcon'
use 'glepnir/zephyr-nvim'
use 'kaiuri/nvim-juliana'
use 'kartikp10/noctis.nvim'
use 'kvrohit/mellow.nvim'
use 'lmburns/kimbox'
use 'luisiacc/gruvbox-baby'
use 'iandwelker/rose-pine-vim'
use 'marko-cerovac/material.nvim'
use 'maxmx03/FluoroMachine.nvim'
use 'metalelf0/jellybeans-nvim'
use 'mcchrish/zenbones.nvim' -- duckbones forestbones kanagawabones neobones nordbones randombones rosebones seoulbones tokyobones vimbones zenburned zenwritten
use 'mhartington/oceanic-next'
use 'ntk148v/vim-horizon'
use 'nxvu699134/vn-night.nvim'
use 'olimorris/onedarkpro.nvim'
use 'projekt0n/github-nvim-theme'
use 'rafamadriz/neon'
use 'ray-x/aurora'
-- TODO: use 'ray-x/starry.nvim' -- Moonlight Dracula Dracula_blood Monokai Mariana Emerald Middlenight_blue Earlysummer Darksolar Ukraine
use 'rebelot/kanagawa.nvim'
use 'rmehri01/onenord.nvim'
use 'rockyzhang24/arctic.nvim'
use 'rose-pine/neovim'
use 'sainnhe/edge'
use 'sainnhe/everforest'
use 'sainnhe/sonokai'
use 'sam4llis/nvim-tundra'
use 'savq/melange'
use 'shaunsingh/moonlight.nvim'
-- TODO: use 'sickill/vim-monokai'
-- TODO: use 'tanvirtin/monokai.nvim'
use 'tiagovla/tokyodark.nvim'
use 'titanzero/zephyrium'
use 'theniceboy/nvim-deus'
use 'tjdevries/gruvbuddy.nvim'
use 'tomasiser/vim-code-dark'
use 'w3barsi/barstrata.nvim'
use 'wuelnerdotexe/vim-enfocado'
use 'yashguptaz/calvera-dark.nvim'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Comments    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'b3nj5m1n/kommentary',
    config = function()
        require('kommentary.config').configure_language("default", {
            prefer_single_line_comments = true,
        })
        vim.api.nvim_set_keymap("n", "<C-t>", "<Plug>kommentary_line_default", {})
        vim.api.nvim_set_keymap("v", "<C-t>", "<Plug>kommentary_visual_default", {})
    end,
    keys = { "<C-t>" },
    setup = function()
        vim.g.kommentary_create_default_mappings = false
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Completion   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: lazyload other pluggins too
use {
    'hrsh7th/nvim-cmp',
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    {
                        name = 'cmdline',
                    },
                    {
                        name = 'cmdline_history',
                        max_item_count = 15
                    }
                }
            }),
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            }),
            experimental = {
                ghost_text = true
            },
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    if entry.source.name == "nvim_lsp" then
                        vim_item.menu = '{' .. entry.source.source.client.name .. '}'
                    elseif entry.source.name == "cmdline" then
                        vim_item.menu = "(options)"
                        vim_item.kind = "Options"
                    elseif entry.source.name == "cmdline_history" then
                        vim_item.menu = "(history)"
                        vim_item.kind = "History"
                    else
                        vim_item.menu = '[' .. entry.source.name .. ']'
                    end
                    local kind_symbol = vim.g.cmp_kinds[vim_item.kind]
                    vim_item.kind = kind_symbol and kind_symbol .. vim_item.kind or vim_item.kind

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
                    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end
            },
            sources = ({
                {
                    name = 'buffer',
                    option = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end
                    }
                },
                { name = 'custom' },
                { name = 'nvim_lsp' },
                { name = 'path' },
                { name = 'snippy' },
                { name = 'spell' }
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        -- TODO: Custom source test
        -- local source = {}

        -- ---Return whether this source is available in the current context or not (optional).
        -- ---@return boolean
        -- function source:is_available()
        --     return true
        -- end

        -- ---Return the debug name of this source (optional).
        -- ---@return string
        -- function source:get_debug_name()
        --     return 'debug name'
        -- end

        -- ---Return the keyword pattern for triggering completion (optional).
        -- ---If this is ommited, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
        -- ---@return string
        -- function source:get_keyword_pattern()
        --     return [[\k\+]]
        -- end

        -- ---Return trigger characters for triggering completion (optional).
        -- function source:get_trigger_characters()
        --     return { '@' }
        -- end

        -- ---Invoke completion (required).
        -- ---@param params cmp.SourceCompletionApiParams
        -- ---@param callback fun(response: lsp.CompletionResponse|nil)
        -- function source:complete(params, callback)
        --     callback({
        --         { label = 'Text', kind = 1 },
        --         { label = 'Method', kind = 2 },
        --         { label = 'Function', kind = 3 },
        --         { label = 'Constructor', kind = 4 },
        --         { label = 'Field', kind = 5 },
        --         { label = 'Variable', kind = 6 },
        --         { label = 'Class', kind = 7 },
        --         { label = 'Interface', kind = 8 },
        --         { label = 'Module', kind = 9 },
        --         { label = 'Property', kind = 10 },
        --         { label = 'Unit', kind = 11 },
        --         { label = 'Value', kind = 12 },
        --         { label = 'Enum', kind = 13 },
        --         { label = 'Keyword', kind = 14 },
        --         { label = 'Snippet', kind = 15 },
        --         { label = 'Color', kind = 16 },
        --         { label = 'File', kind = 17 },
        --         { label = 'Reference', kind = 18 },
        --         { label = 'Folder', kind = 19 },
        --         { label = 'EnumMember', kind = 20 },
        --         { label = 'Constant', kind = 21 },
        --         { label = 'Struct', kind = 22 },
        --         { label = 'Event', kind = 23 },
        --         { label = 'Operator', kind = 24 },
        --         { label = 'TypeParameter', kind = 25 },
        --     })
        -- end
        -- -- vim.cmd[[
        -- --     CmpDocumentation guifg=#1d344f guibg=#dbdbdb
        -- --     CmpDocumentationBorder guifg=#ced5de guibg=#dbdbdb
        -- --     CmpItemAbbr guifg=#1d344f
        -- --     CmpItemAbbrDeprecated cterm=strikethrough gui=strikethrough guifg=#2e537d
        -- --     CmpItemAbbrMatch guifg=#485e7d
        -- --     CmpItemAbbrMatchFuzzy guifg=#485e7d
        -- --     CmpItemKindClass links to Type
        -- --     CmpItemKindConstant links to TSConstant
        -- --     CmpItemKindConstructor links to Function
        -- --     CmpItemKindDefault guifg=#485e7d
        -- --     CmpItemKindEnum links to Constant
        -- --     CmpItemKindEnumMember links to TSField
        -- --     CmpItemKindEvent links to Constant
        -- --     CmpItemKindField links to TSField
        -- --     CmpItemKindFunction links to Function
        -- --     CmpItemKindInterface links to Constant
        -- --     CmpItemKindKeyword links to Identifier
        -- --     CmpItemKindMethod links to Function
        -- --     CmpItemKindModule links to TSNamespace
        -- --     CmpItemKindOperator links to Operator
        -- --     CmpItemKindProperty links to TSProperty
        -- --     CmpItemKindReference links to Keyword
        -- --     CmpItemKindSnippet guifg=#233f5e
        -- --     CmpItemKindStruct links to Type
        -- --     CmpItemKindTypeParameter links to TSField
        -- --     CmpItemKindUnit links to Constant
        -- --     CmpItemKindValue links to Keyword
        -- --     CmpItemKindVariable links to TSVariable
        -- --     CmpItemMenu links to Comment
        -- -- ]]

        -- ---Resolve completion item (optional). This is called right before the completion is about to be 
        -- --displayed.
        -- ---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
        -- ---@param completion_item lsp.CompletionItem
        -- ---@param callback fun(completion_item: lsp.CompletionItem|nil)
        -- function source:resolve(completion_item, callback)
        --     callback(completion_item)
        -- end

        -- ---Executed after the item was selected.
        -- ---@param completion_item lsp.CompletionItem
        -- ---@param callback fun(completion_item: lsp.CompletionItem|nil)
        -- function source:execute(completion_item, callback)
        --     callback(completion_item)
        -- end

        -- function source:new()
        --     return setmetatable({}, {__index = source})
        -- end
        -- ---Register your source to nvim-cmp.
        -- require('cmp').register_source('custom', source.new())
    end,
    event = "InsertEnter",
    module = "cmp"
}
use { 'dmitmel/cmp-cmdline-history', after = "nvim-cmp" }
use { 'hrsh7th/cmp-buffer', after = "nvim-cmp" }
use { 'hrsh7th/cmp-cmdline', after = "nvim-cmp" }
use { 'hrsh7th/cmp-nvim-lsp', after = "nvim-cmp" }
use { 'hrsh7th/cmp-path', after = "nvim-cmp" }
use { 'f3fora/cmp-spell', after = "nvim-cmp" }
-- https://github.com/jameshiew/nvim-magic
-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/lukas-reineke/cmp-rg
-- https://github.com/lukas-reineke/cmp-under-comparator
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configuration  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: https://github.com/cankolay3499/cnvim
-- TODO: https://github.com/CosmicNvim/CosmicNvim
-- TODO: https://github.com/JryChn/ModuleVim
-- TODO: https://github.com/LunarVim/LunarVim
-- TODO: https://github.com/NTBBloodbath/doom-nvim
-- TODO: https://github.com/NvChad/NvChad
-- TODO: https://github.com/OmniSharp/omnisharp-vim
-- TODO: https://github.com/Shadorain/shadovim
-- TODO: https://github.com/TeoDev1611/astro.nvim
-- TODO: https://github.com/Theory-of-Everything/nii-nvim
-- TODO: https://github.com/Ultra-Code/awesome-neovim
-- TODO: https://github.com/VapourNvim/VapourNvim
-- TODO: https://github.com/alpha2phi/neovim-for-beginner
-- TODO: https://github.com/artart222/CodeArt
-- TODO: https://github.com/askfiy/nvim
-- TODO: https://github.com/b0o/nvim-conf
-- TODO: https://github.com/craftzdog/dotfiles-public
-- TODO: https://github.com/crivotz/nv-ide
-- TODO: https://github.com/cstsunfu/.sea.nvim
-- TODO: https://github.com/echasnovski/mini.nvim
-- TODO: https://github.com/glepnir/nvim
-- TODO: https://github.com/jdhao/nvim-config
-- TODO: https://github.com/lalitmee/cobalt2.nvim
-- TODO: https://github.com/mnabila/nvimrc
-- TODO: https://github.com/nvim-lua/kickstart.nvim
-- TODO: https://github.com/nvoid-lua/nvoid
-- TODO: https://github.com/optimizacija/neovim-config
-- TODO: https://github.com/ray-x/dotfiles
-- TODO: https://github.com/ray-x/go.nvim
-- TODO: https://github.com/shaeinst/roshnivim
-- TODO: https://github.com/shaunsingh/nyoom.nvim
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Debugger    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: Abstract-IDE dap configs
-- --------------------------
-- -- telescope-dap.nvim
-- pcall(require'telescope'.load_extension, 'dap')
-- --------------------------
--
--
-- --------------------------
-- -- nvim-dap-ui
-- require("dapui").setup({
-- 	icons = {expanded = "▾", collapsed = "▸"},
-- 	-- Expand lines larger than the window
-- 	-- Requires >= 0.7
-- 	expand_lines = vim.fn.has("nvim-0.7"),
-- 	sidebar = {
-- 		-- You can change the order of elements in the sidebar
-- 		elements = {
-- 			-- Provide as ID strings or tables with "id" and "size" keys
-- 			{
-- 				id = "scopes",
-- 				size = 0.25, -- Can be float or integer > 1
-- 			},
-- 			{id = "breakpoints", size = 0.25},
-- 			{id = "stacks", size = 0.25},
-- 			{id = "watches", size = 00.25},
-- 		},
-- 		size = 40,
-- 		position = "left", -- Can be "left", "right", "top", "bottom"
-- 	},
-- 	tray = {
-- 		elements = {"repl", "console"},
-- 		size = 10,
-- 		position = "bottom", -- Can be "left", "right", "top", "bottom"
-- 	},
-- 	floating = {
-- 		max_height = nil, -- These can be integers or a float between 0 and 1.
-- 		max_width = nil, -- Floats will be treated as percentage of your screen.
-- 		border = "single", -- Border style. Can be "single", "double" or "rounded"
-- 		mappings = {close = {"q", "<Esc>"}},
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
-- require("nvim-dap-virtual-text").setup {
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
-- TODO: https://github.com/PatschD/zippy.nvim
-- TODO: https://github.com/Weissle/persistent-breakpoints.nvim
-- TODO: https://github.com/jayp0521/mason-nvim-dap.nvim
-- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
-- TODO: https://github.com/puremourning/vimspector
-- TODO: https://github.com/sakhnik/nvim-gdb
-- TODO: https://github.com/theHamsta/nvim-dap-virtual-text
-- TODO: https://github.com/tpope/vim-scriptease
-- TODO: https://github.com/vim-scripts/Conque-GDB
-- TODO: use 'Pocco81/dap-buddy.nvim'
-- TODO: use 'mfussenegger/nvim-dap'
-- TODO: use 'mfussenegger/nvim-dap-python'
-- TODO: use 'rcarriga/nvim-dap-ui'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Doc Generater  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    "danymat/neogen",
    after = 'nvim-treesitter',
    cmd = 'Neogen',
    config = function()
        require('neogen').setup {}
    end
}
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ File Explorer  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'mrbjarksen/neo-tree-diagnostics.nvim',
    after = 'neo-tree.nvim',
    module = 'neo-tree.sources.diagnostics' -- if wanting to lazyload
}

use {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    config = function()
        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        require('neo-tree').setup({
            default_component_configs = {
                git_status = {
                    symbols = {
                        -- Change type
                        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        deleted   = "",-- this can only be used in the git_status source
                        renamed   = "",-- this can only be used in the git_status source
                        -- Status type
                        untracked = "",
                        ignored   = "",
                        unstaged  = "",
                        staged    = "",
                        conflict  = "",
                    }
                },
                icon = {
                    folder_closed = '',
                    folder_open = '',
                    folder_empty = '',
                    default = ''
                },
                indent = {
                    last_indent_marker = '╰'
                }
            },
            diagnostics = {
              autopreview = true, -- Whether to automatically enable preview mode
              autopreview_config = {}, -- Config table to pass to autopreview (for example `{ use_float = true }`)
              autopreview_event = "neo_tree_buffer_enter", -- The event to enable autopreview upon (for example `"neo_tree_window_after_open"`)
              bind_to_cwd = true,
              diag_sort_function = "severity", -- "severity" means diagnostic items are sorted by severity in addition to their positions.
                                               -- "position" means diagnostic items are sorted strictly by their positions.
                                               -- May also be a function.
              follow_behavior = { -- Behavior when `follow_current_file` is true
                always_focus_file = true, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
                expand_followed = true, -- Ensure the node of the followed file is expanded
                collapse_others = true, -- Ensure other nodes are collapsed
              },
            },
            filesystem = {
                follow_current_file = true,
                hijack_netrw_behavior = 'open_current'
            },
            popup_border_style = "rounded",
            sources = {
                "diagnostics",
                "filesystem"
            }
        })
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Folding     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'anuvyklack/pretty-fold.nvim',
    cond = function()
        return vim.o.foldmethod == "marker"
    end,
    config = function()
        require('pretty-fold').setup {
            fill_char = ' ',
            process_comment_signs = 'delete'
        }
    end
}

use {
    'kevinhwang91/nvim-ufo',
    cond = function()
        return vim.o.foldmethod ~= "marker"
    end,
    config = function()
        vim.o.foldcolumn = '1' -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        require('ufo').setup({
            provider_selector = function(bufnr, filetype, buftype)
                return {'treesitter', 'indent'}
            end
        })
    end
}

-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Formatting   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'sbdchd/neoformat',
    cmd = "Neoformat"
}
-- TODO: use 'joechrisellis/lsp-format-modifications.nvim'
-- <~>

--     -- FZF:</>
--     -- ````
--     -- TODO: https://github.com/ibhagwan/fzf-lua
--     -- TODO: https://github.com/junegunn/fzf
--     -- TODO: https://github.com/junegunn/fzf.vim
--     -- TODO: https://github.com/ojroques/nvim-lspfuzzy
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      Git       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'hotwatermorning/auto-git-diff' -- Archieved
-- use 'ldelossa/gh.nvim' -- Archieved
use {
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup {
            signs = {
                add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
                change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
                delete       = {hl = 'GitSignsDelete', text = '', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
            },
            current_line_blame_formatter_opts = {
                relative_time = true
            },
            current_line_blame_formatter = '  <author>  <committer_time>  <summary>`'
        }
    end
}
-- TODO: use 'rhysd/conflict-marker.vim' -- Archieved

use {
    'rhysd/git-messenger.vim',
    cmd = "GitMessenger"
}

use 'ruifm/gitlinker.nvim'
-- TODO: use 'sindrets/diffview.nvim' -- Archieved
-- TODO: -- use 'tanvirtin/vgit.nvim' -- Archieved
-- TODO: -- https://github.com/akinsho/git-conflict.nvim
-- TODO: -- https://github.com/Almo7aya/openingh.nvim -- NOTE: needs PR for VSO
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Icons      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'DaikyXendo/nvim-material-icon'
}

use {
    'kyazdani42/nvim-web-devicons',
    after = "nvim-material-icon",
    config = function()
        require'nvim-web-devicons'.setup({
            override = require('nvim-material-icon').get_icons()
        })
    end
    -- module = "nvim-web-devicons"
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Indentation  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true
        })
    end,
    event = "BufRead"
}
--     <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Libraries   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use 'MunifTanjim/nui.nvim'
use 'kevinhwang91/promise-async'
use 'nvim-lua/plenary.nvim'
-- use 'nvim-lua/popup.nvim'
-- <~>

-- ──────────────────── Lint ────────────────────</>
-- TODO: lint setup
-- use 'mfussenegger/nvim-lint'
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ LSP ❱━━━━━━━━━━━━━━━━━━━</>
-- TODO: Load lsp for Mason lsp installed languages
-- TODO: https://github.com/gfanto/fzf-lsp.nvim
use {
    'Kasama/nvim-custom-diagnostic-highlight',
    config = function()
        require('nvim-custom-diagnostic-highlight').setup {}
    end
}

use {
    'SmiteshP/nvim-navic',
    config = function()
        require('nvim-navic').setup {
            icons = vim.g.cmp_kinds,
            highlight = false,
            separator = "  ",
            depth_limit = 0,
            depth_limit_indicator = "..",
            safe_output = true
        }
    end
}

use {
    'liuchengxu/vista.vim',
    config = function()
        vim.cmd[[
        let g:vista_default_executive = 'nvim_lsp'
        let g:vista_icon_indent = ["╰─ ", "├─ "]
        let g:vista#renderer#icons = {
            \   "constant": "",
            \   "class": "",
            \   "function": "",
            \   "variable": "",
            \  }
        ]]
    end,
    cmd = 'Vista'
}

use 'neovim/nvim-lspconfig' -- TODO: require('mason-registry').get_installed_package_names()

use {
    'williamboman/mason.nvim',
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded"
            }
        })
    end
}

use {
    'williamboman/mason-lspconfig.nvim',
    config = function()
        local lspconfig = require('lspconfig')
        local mason_lspconfig = require('mason-lspconfig')
        mason_lspconfig.setup()
        -- vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]
        local opts = { noremap=true, silent=true }
        -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        -- TODO:
        -- -- Setup diagnostic icons and signs
        -- vim.diagnostic.config({
        --     virtual_text = {
        --         prefix = "",
        --         spacing = 4,
        --         format = function(diagnostic)
        --             local icons = {
        --                 ERROR = " ",
        --                 WARN = " ",
        --                 HINT = " ",
        --                 INFO = " ",
        --             }
        --             return string.format(
        --             "%s %s",
        --             icons[vim.diagnostic.severity[diagnostic.severity]],
        --             diagnostic.message
        --             )
        --         end,
        --     },
        --     signs = true,
        --     underline = true,
        --     -- update diagnostic in insert mode will be annoying when the output is too verbose
        --     update_in_insert = false,
        -- })
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

        -- vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
        -- vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

        local on_attach = function(client, bufnr)
            local navic = require('nvim-navic')
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wl', function()
            --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
            -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
            vim.cmd[[
            aunmenu PopUp
            nnoremenu PopUp.Declaration\ (gD) <Cmd>lua vim.lsp.buf.declaration()<CR>
            nnoremenu PopUp.Definition\ (gd) <Cmd>lua vim.lsp.buf.definition()<CR>
            nnoremenu PopUp.Implementation\ (gi) <Cmd>lua vim.lsp.buf.implementation()<CR>
            nnoremenu PopUp.References\ (gr) <Cmd>lua vim.lsp.buf.references()<CR>
            nnoremenu PopUp.Hover\ (\\h) <Cmd>lua vim.lsp.buf.hover()<CR>
            nnoremenu PopUp.Rename\ (\\rn) <Cmd>lua vim.lsp.buf.rename()<CR>
            nnoremenu PopUp.Type\ Definition\ (gt) <Cmd>lua vim.lsp.buf.type_definition()<CR>
            ]]

            navic.attach(client, bufnr)
        end

        -- LSP settings (for overriding per client)
        local handlers =  {
            ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border_shape}),
            -- ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border_shape}), -- disable in favour of Noice
        }

        -- Add additional capabilities supported by nvim-cmp
        -- TODO:
        -- -- Gets a new ClientCapabilities object describing the LSP client
        -- -- capabilities.
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities.textDocument.completion.completionItem = {
        --     documentationFormat = {
        --         "markdown",
        --         "plaintext",
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
        --             "documentation",
        --             "detail",
        --             "additionalTextEdits",
        --         },
        --     },
        -- }
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        mason_lspconfig.setup_handlers {
            function (server_name)
                if server_name == "powershell_es" then
                    lspconfig.powershell_es.setup {
                        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach
                    }
                elseif server_name == "omnisharp" then
                    lspconfig.omnisharp.setup {
                        cmd = { "dotnet", "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp/OmniSharp.dll"},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == "omnisharp_mono" then
                    lspconfig.omnisharp_mono.setup {
                        cmd = { "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp-mono/OmniSharp.exe"},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == "sumneko_lua" then
                    lspconfig.sumneko_lua.setup {
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" }
                                },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true)
                                }
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
    end
}

use {
    'ray-x/lsp_signature.nvim',
    config = function()
        require "lsp_signature".setup({
            hint_enable = false,
            noice = false
        })
    end
}

--     TODO: lsp_lines
--     -- use {
--     --     'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
--     --     as = 'lsp_lines',
--     --     config = function()
--     --         require("lsp_lines").setup()
--     --         --require("lsp_lines").register_lsp_virtual_lines()
--     --         vim.diagnostic.config({
--     --             virtual_text = false,
--     --         })
--     --         vim.diagnostic.config({ virtual_lines = { prefix = "🔥" } })
--     --     end
--     -- }

use {
    -- BUG: references windows is very slow
    'RishabhRD/nvim-lsputils',
    config = function()
        -- vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
        -- vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler -- using nvim-bqf
        -- vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
        -- vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
        -- vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
        -- vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
        -- vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
        -- vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
    end,
    event = 'LspAttach'
}
use {
    'RishabhRD/popfix'
}

--     TODO: use {
--         "amrbashir/nvim-docs-view",
--         -- cmd = { "DocsViewToggle" },
--         config = function()
--             require("docs-view").setup {
--                 position = "right",
--                 width = 60,
--             }
--         end
--     }
--     -- TODO: https://github.com/gfanto/fzf-lsp.nvim

-- -- TODO:
-- -- lspsaga
-- --
-- config.lspsaga_config = function()
--   local enable_winbar = require("editor.utils").vhas("nvim-0.8.0")
--   local saga = require("lspsaga")
--   local themes = require("lspsaga.lspkind")
--   themes[12][2] = " "

--   -- use custom config
--   saga.init_lsp_saga({
--     -- when cursor in saga window you config these to move
--     move_in_saga = { prev = "k", next = "j" },
--     diagnostic_header = { " ", " ", " ", " " },
--     scroll_in_preview = {
--       scroll_down = "<C-d>",
--       scroll_up = "<C-u>",
--     },
--     code_action_icon = "ﯦ ",
--     -- same as nvim-lightbulb but async
--     code_action_lightbulb = {
--       sign = false,
--       virtual_text = true,
--     },
--     finder_icons = {
--       def = "  ",
--       ref = "  ",
--       link = "  ",
--     },
--     finder_action_keys = {
--       open = "<CR>",
--       vsplit = "s",
--       split = "i",
--       tabe = "t",
--       quit = "q",
--       scroll_down = "<C-f>",
--       scroll_up = "<C-b>", -- quit can be a table
--     },
--     -- show symbols in winbar must be neovim 0.8.0,
--     -- close it until neovim 0.8.0 become stable
--     symbol_in_winbar = {
--       in_custom = false,
--       enable = enable_winbar,
--       separator = "  ",
--       show_file = true,
--       click_support = false,
--     },
--   })

--   -- set lightbulb as comment like
--   vim.api.nvim_set_hl(0, "LspSagaLightBulb", { fg = "#E8C266" })
-- end

--     TODO: use({
--         "glepnir/lspsaga.nvim",
--         branch = "main",
--         config = function()
--             local saga = require("lspsaga")
-- 
--             saga.init_lsp_saga({
--                 -- your configuration
--             })
--         end,
--     })

use {
    'j-hui/fidget.nvim',
    config = function()
        require("fidget").setup()
    end
}

--     TODO: use {
--         'jose-elias-alvarez/null-ls.nvim',
--         config = function()
--             require("null-ls").setup({
--                 sources = {
--                     require("null-ls").builtins.formatting.stylua,
--                     require("null-ls").builtins.diagnostics.eslint,
--                     require("null-ls").builtins.completion.spell,
--                 },
--             })
--         end
--     } ]]
--     TODO: use 'jubnzv/virtual-types.nvim'
--     TODO: use {
--         'kosayoda/nvim-lightbulb',
--         requires = 'antoinemadec/FixCursorHold.nvim'
--     }
--     TODO:L use 'Decodetalkers/csharpls-extended-lsp.nvim'
--     TODO: use 'Hoffs/omnisharp-extended-lsp.nvim'
--     TODO: use {
--         'andrewferrier/textobj-diagnostic.nvim',
--         config = function()
--             require("textobj-diagnostic").setup()
--         end
--     }
--     -- TODO: https://github.com/anuvyklack/hydra.nvim
--    TODO:  use 'filipdutescu/renamer.nvim'
--    TODO:  -- use 'jayp0521/mason-null-ls.nvim'
--    TODO:  use 'kwkarlwang/cmp-nvim-insert-text-lsp'
--    TODO:  use 'ldelossa/litee-bookmarks.nvim'
--    TODO:  use 'ldelossa/litee-calltree.nvim'
--    TODO:  use 'ldelossa/litee.nvim'
--    TODO:  use 'lukas-reineke/format.nvim'
--    TODO:  use 'nanotee/nvim-lsp-basics'
--    TODO:  use 'nvim-lua/lsp-status.nvim'
--     -- TODO: https://github.com/ojroques/nvim-lspfuzzy
--    TODO: use 'onsails/diaglist.nvim'
--    TODO: use 'p00f/clangd_extensions.nvim'
--    TODO: use 'razzmatazz/csharp-language-server'
--     -- TODO: https://github.com/ray-x/navigator.lua
--    TODO: use {
--         'rmagatti/goto-preview',
--         config = function()
--             require('goto-preview').setup {}
--         end
--     }
--    TODO: use {
--         'simrat39/symbols-outline.nvim',
--         config = function()
--             require("symbols-outline").setup()
--         end
--     }
--    TODO: --[[ use {
--        "smjonas/inc-rename.nvim",
--        config = function()
--            require("inc_rename").setup()
--        end,
--     } ]] -- NOTE: needs neovim v0.8
--   TODO:  use {
--         'stevearc/aerial.nvim',
--         config = function()
--             require('aerial').setup({})
--         end
--     }
--   TODO:  use 'tami5/lspsaga.nvim'
--   TODO:  use 'weilbith/nvim-code-action-menu'
-- <~>

--     -- Lua:</>
--     -- ````
--     -- TODO: https://github.com/jbyuki/one-small-step-for-vimkind
--     -- TODO: https://github.com/milisims/nvim-luaref
--     -- TODO: https://github.com/nanotee/nvim-lua-guide
--     -- TODO: https://github.com/rafcamlet/nvim-luapad
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Mapping     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'folke/which-key.nvim',
    config = function()
        require("which-key").setup({
            plugins = {
                registers = false
            },
            -- popup_mappings = {
            --     scroll_down = '<c-d>', -- binding to scroll down inside the popup
            --     scroll_up = '<c-u>', -- binding to scroll up inside the popup
            -- },
            window = {
                border = "single"
            }
        })
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Markdown    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO lazyload
use 'davidgranstrom/nvim-markdown-preview'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Marks      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
use {
    'MattesGroeger/vim-bookmarks',
    config = function()
        vim.cmd[[
        let g:bookmark_no_default_key_mappings = 1
        nmap bm <Plug>BookmarkToggle
        nmap ba <Plug>BookmarkShowAll
        ]]
    end
}

--     -- TODO: https://github.com/ThePrimeagen/harpoon --> plenary
use 'kshenoy/vim-signature'
--     -- use 'chentoast/marks.nvim'
--     use 'crusj/bookmarks.nvim'
-- <~>

--     -- OrgMode:</>
--     -- ````````
--     -- {{{
--     -- TODO: https://github.com/TravonteD/org-capture-filetype
--     -- TODO: https://github.com/akinsho/org-bullets.nvim
--     TODO: use {
--         'nvim-neorg/neorg',
--         config = function()
--             require('nvim-treesitter.configs').setup {
--                 highlight = {
--                     enable = true,
--                     additional_vim_regex_highlighting = false
--                 }
--             }
--             require('neorg').setup {
--                 ["core.norg.concealer"] = {
--                     config = { -- Note that this table is optional and doesn't need to be provided
--                     -- Configuration here
--                 }
--             }
--             }
--         end
--     }
--     TODO: -- use 'nvim-orgmode/orgmode'
--     -- TODO: https://github.com/ranjithshegde/orgWiki.nvim
--     TODO: use {
--         'lukas-reineke/headlines.nvim',
--         config = function()
--             require('headlines').setup()
--         end,
--     }
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Quickfix   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use 'folke/trouble.nvim'
use {
    -- TODO: fzf
    'kevinhwang91/nvim-bqf',
    after = "nvim-lspconfig",
    config = function()
        require('bqf').setup({
            auto_resize_height = true,
            preview = {
                border_chars = {'│', '│', '─', '─', '╭', '╮', '╰', '╯', '█'}
            }
        })
    end,
    ft = 'qf'
}
-- <~>

--     -- Rooter:</>
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Sessions   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
  'rmagatti/auto-session',
  config = function()
    vim.g.auto_session_suppress_dirs = { "C:\\Users\\aloknigam" }
    require("auto-session").setup({})
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end
  --   TODO: icons for session
  --   if vim.g.persisting then
  --     return "  |"
  -- elseif vim.g.persisting == false then
  --     return "  |"
  -- end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Snippets   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'dcampos/nvim-snippy',
    config = function()
        require('snippy').setup({
            mappings = {
                is = {
                    ['<Tab>'] = 'expand_or_advance',
                    ['<S-Tab>'] = 'previous',
                }
            }
        })
    end,
    requires = { -- BUG: fix this
        'dcampos/cmp-snippy',
        'honza/vim-snippets'
    }
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

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Status Line  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: make clickable items
-- TODO: Compete setup
use {
    'nvim-lualine/lualine.nvim',
    config = function()
        -- local navic = require("nvim-navic")
        require('lualine').setup {
            options = {
        --         icons_enabled = true,
        --         theme = 'auto',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
        --         disabled_filetypes = {
        --             statusline = {},
        --             winbar = {},
        --         },
        --         ignore_focus = {},
        --         always_divide_middle = true,
        --         globalstatus = false,
        --         refresh = {
        --             statusline = 1000,
        --             tabline = 1000,
        --             winbar = 1000,
        --         }
            },
            sections = {
        --         lualine_a = {'mode'},
        --         lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {
                    {
                        'filename',
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = false,   -- Display new file status (new file means no write after created)
                        path = 0,                -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory

                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        -- for other components. (terrible name, any suggestions?)
                        symbols = {
                            modified = '[+]',      -- Text to show when the file is modified.
                            readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]',     -- Text to show for new created file before first writting
                        }
                    }
                },
        --         lualine_x = {'encoding', 'fileformat', 'filetype'},
        --         lualine_y = {'progress'},
        --         lualine_z = {'location'}
            },
        --     inactive_sections = {
        --         lualine_a = {},
        --         lualine_b = {},
        --         lualine_c = {'filename'},
        --         lualine_x = {'location'},
        --         lualine_y = {},
        --         lualine_z = {}
        --     },
        -- tabline = {
        --     lualine_a = {'filename'},
        -- },
        -- winbar = {
        --     lualine_b = {
        --         { navic.get_location, cond = navic.is_available }
        --     }
        -- },
        inactive_winbar = {
            lualine_a = {'filename'},
        --     lualine_b = {
        --         { navic.get_location, cond = navic.is_available }
        --     }
        },
        --     extensions = {}
        }
    end,
}
-- <~>

--     -- Tab Line:</>
--     -- `````````
--     TODO:  use {
--         'akinsho/bufferline.nvim',
--         config = function()
--             require("bufferline").setup {
--                 options = {
--                     mode = "tabs",
--                     diagnostics = "nvim_lsp",
--                     separator_style = "thick",
--                     always_show_bufferline = false
--                 }
--             }
--         end
--     }
--    TODO:   -- use 'mengelbrecht/lightline-bufferline'
--  TODO: use {
--     'nanozuki/tabby.nvim',
--     config = function()
--         require('tabby').setup()
--     end
-- }
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Telescope   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
--  TODO: use 'axkirillov/easypick.nvim' -- NOTE: No need now
--  TODO: https://github.com/adoyle-h/ad-telescope-extensions.nvim
--  TODO: https://github.com/princejoogie/dir-telescope.nvim
-- TODO: https://github.com/kelly-lin/telescope-ag
-- TODO: tele configs
-- return function()
--   local ok, telescope = pcall(require, "telescope")
--   if not ok then
--     return
--   end

--   telescope.setup({
--     defaults = {
--       vimgrep_arguments = {
--         "rg",
--         "--color=never",
--         "--no-heading",
--         "--with-filename",
--         "--line-number",
--         "--column",
--         "--smart-case",
--       },
--       prompt_prefix = "  ",
--       selection_caret = "  ",
--       entry_prefix = "  ",
--       initial_mode = "insert",
--       selection_strategy = "reset",
--       sorting_strategy = "descending",
--       layout_strategy = "flex",
--       layout_config = {
--         horizontal = {
--           prompt_position = "top",
--           preview_width = 0.55,
--         },
--         vertical = {
--           mirror = false,
--         },
--         width = 0.87,
--         height = 0.80,
--         preview_cutoff = 120,
--       },
--       file_sorter = require("telescope.sorters").get_fuzzy_file,
--       file_ignore_patterns = {},
--       generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
--       path_display = { "absolute" },
--       winblend = 0,
--       border = {},
--       borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
--       color_devicons = true,
--       use_less = true,
--       set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
--       file_previewer = require("telescope.previewers").vim_buffer_cat.new,
--       grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
--       qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
--       -- Developer configurations: Not meant for general override
--       buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
--     },
--     extensions = {
--       fzf = {
--         fuzzy = true, -- false will only do exact matching
--         override_generic_sorter = false, -- override the generic sorter
--         override_file_sorter = true, -- override the file sorter
--         case_mode = "smart_case", -- or "ignore_case" or "respect_case"
--         -- the default case_mode is "smart_case"
--       },
--     },
--   })
-- end
use {
    'crispgm/telescope-heading.nvim',
    after = 'telescope.nvim',
    config = function()
        require('telescope').load_extension('heading')
    end,
    ft = { 'markdown' }
}

use {
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    config = function()
        require('telescope').setup({
            extensions = {
                heading = {
                    treesitter = true
                }
            }
        })
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Terminal    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    "akinsho/toggleterm.nvim",
    cmd = 'ToggleTerm',
    config = function()
        require("toggleterm").setup()
    end,
    tag = '*'
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

-- Test & Run:</>
-- TODO: https://github.com/EthanJWright/vs-tasks.nvim
-- TODO: https://github.com/andythigpen/nvim-coverage
-- TODO: https://github.com/is0n/jaq-nvim
-- TODO: https://github.com/jubnzv/mdeval.nvim
-- TODO: https://github.com/klen/nvim-test
-- TODO: https://github.com/michaelb/sniprun
-- TODO: https://github.com/nvim-neotest/neotest
-- TODO: https://github.com/pianocomposer321/yabs.nvim
-- TODO: https://github.com/smzm/hydrovim
-- TODO: https://github.com/stevearc/overseer.nvim
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Treesitter   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        local ignore_install = { "help", "yaml" }
        require('nvim-treesitter.configs').setup {
            auto_install = true,
            endwise = {
                enable = true,
            },
            ignore_install = ignore_install,
            highlight = {
                enable = true,
                disable = ignore_install
            },
            rainbow = {
                enable = true,
                -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
                -- colors = {}, -- table of hex strings
                -- termcolors = {} -- table of colour name strings
            }
        }
    end
}

--  TODO: use {
--     'haringsrob/nvim_context_vt',
--     after = 'nvim-treesitter'
-- }

use {
    'm-demare/hlargs.nvim',
    after = 'nvim-treesitter',
    config = function()
        require('hlargs').setup()
    end
}

use {
    'nvim-treesitter/nvim-treesitter-context',
    after = 'nvim-treesitter',
    cmd = 'TSContextToggle',
    config = function()
        require('treesitter-context').setup {
            separator = '━',
            patterns = {
                lua = {
                    'field'
                }
            }
        }
    end
}

use {
    'RRethy/nvim-treesitter-endwise',
    after = 'nvim-treesitter',
    config = function()
        require('nvim-treesitter.configs').setup {
            endwise = {
                enable = true,
            },
        }
    end,
    ft = 'lua'
}

--    TODO:   use {
--         'nvim-treesitter/nvim-treesitter-refactor',
--         config = function()
--             require'nvim-treesitter.configs'.setup {
--                 refactor = {
--                     highlight_definitions = {
--                         enable = true,
--                         -- Set to false if you have an `updatetime` of ~100.
--                         clear_on_cursor_move = true,
--                     },
--                 },
--             }
--         end
--     }

use {
    'nvim-treesitter/playground',
    after = 'nvim-treesitter',
    cmd = 'TSHighlightCapturesUnderCursor'
}

use {
    'p00f/nvim-ts-rainbow',
    after = 'nvim-treesitter'
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       TUI      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'petertriho/nvim-scrollbar',
    config = function()
        require("scrollbar").setup()
    end
}

-- TODO:  https://github.com/lewis6991/satellite.nvim
-- TODO:  https://github.com/ziontee113/neo-minimap

use 'gorbit99/codewindow.nvim' -- TODO: net setup

use 'doums/suit.nvim'

use {
    -- TODO: enable and disable commands
    'folke/drop.nvim',
    config = function()
        require('drop').setup({
            theme = "leaves"
        })
        vim.api.nvim_create_autocmd(
            "CursorHold", {
                pattern = "*",
                callback = function()
                    require('drop').show()
                end
            }
        )
        vim.api.nvim_create_autocmd(
            { "CursorMoved", "CursorMovedI" },
            {
                pattern = "*",
                callback = function()
                    require('drop').hide()
                end
            }
        )
    end
}

-- TODO:  use({
--   'folke/noice.nvim',
--   config = function()
--     require("noice").setup()
--   end,
--   requires = {
--     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
--     "MunifTanjim/nui.nvim",
--     -- OPTIONAL:
--     --   `nvim-notify` is only needed, if you want to use the notification view.
--     --   If not available, we use `mini` as the fallback
--     "rcarriga/nvim-notify",
--     }
-- })

use {
    "nvim-zh/colorful-winsep.nvim",
    config = function ()
        require("colorful-winsep").setup({
            -- highlight for Window separator
            -- highlight = {
            --     guibg = "#16161E",
            --     guifg = "#1F3442",
            -- },
            -- timer refresh rate
            interval = 30,
            -- This plugin will not be activated for filetype in the following table.
            no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest", "NvimTree" },
            -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
            symbols = { "─", "│", "╭", "╮", "╰", "╯" },
            close_event = function()
                -- Executed after closing the window separator
            end,
            create_event = function()
                -- Executed after creating the window separator
            end,
        })
    end
}

use {
    'rcarriga/nvim-notify',
    config = function()
        local notify = require('notify')
        notify.setup({
            minimum_width = 0,
            render = 'minimal',
            stages = 'slide'
        })
        vim.notify = notify
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Utilities   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: https://github.com/cbochs/portal.nvim
-- TODO: https://github.com/AckslD/nvim-trevJ.lua
-- TODO: https://github.com/kwkarlwang/bufjump.nvim
-- TODO: https://github.com/echasnovski/mini.nvim

use {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- https://github.com/ElPiloto/significant.nvim -- NOTE: awesome plugin but not usage now

use {
    'andrewferrier/debugprint.nvim',
    config = function()
        local debugprint = require('debugprint')
        debugprint.setup({
            create_keymaps = false,
            create_commands = false
        })
        vim.keymap.set("n", "<Leader>dd", function()
            debugprint.deleteprints()
        end)
        vim.keymap.set("n", "<Leader>dp", function()
            debugprint.debugprint()
        end)
        vim.keymap.set("n", "<Leader>dP", function()
            debugprint.debugprint({ above = true })
        end)
        vim.keymap.set("n", "<Leader>dv", function()
            debugprint.debugprint({ variable = true })
        end)
        vim.keymap.set("n", "<Leader>dV", function()
            debugprint.debugprint({ above = true, variable = true })
        end)
        vim.keymap.set("v", "<Leader>dv", function()
            debugprint.debugprint({ variable = true })
        end)
        vim.keymap.set("v", "<Leader>dV", function()
            debugprint.debugprint({ above = true, variable = true })
        end)
    end,
    keys = { "<Leader>dp", "<Leader>dP", "<Leader>dv", "<Leader>dV", }
}

use 'chipsenkbeil/distant.nvim'

use {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
}

-- TODO:  use {
--     'glacambre/firenvim',
--     run = function()
--         vim.fn['firenvim#install'](0)
--     end
-- }

-- use 'jbyuki/instant.nvim' -- NOTE: good but no use case now

use 'kylechui/nvim-surround'

use 'lewis6991/impatient.nvim'

use 'mg979/vim-visual-multi'

use {
    'nacro90/numb.nvim',
    config = function()
        require('numb').setup()
    end
}

use {
    -- Lua copy https://github.com/ojroques/nvim-osc52
    'ojroques/vim-oscyank',
    cond = function()
        -- Check if connection is ssh
        return os.getenv("SSH_CLIENT") ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif]]
    end
}

use 'rickhowe/spotdiff.vim'

use {
    'tversteeg/registers.nvim',
    config = function()
        require("registers").setup({
            show = '*+"',
            show_empty = false,
            register_user_command = false,
            symbols = {
                tab = '»'
            },
            window = {
                border = 'rounded'
            }
        })
    end
}
end
})
-- <~>
-- vim: fmr=</>,<~>  fdm=marker
