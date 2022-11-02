--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

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

require('packer').startup({
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configurations ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
config = {
    auto_clean = true,
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

function(use)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Packer     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use 'wbthomason/packer.nvim'
-- filetype ?
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Auto Pairs   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
     'windwp/nvim-autopairs',
--     after ??
    config = function()
        local npairs = require("nvim-autopairs")
        local Rule   = require("nvim-autopairs.rule")
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
use {
    'RRethy/vim-illuminate',
    config = function()
       vim.cmd[[
           hi IlluminatedWordText guibg = #59656F guifg = #FFFFFF
           hi IlluminatedWordRead guibg = #F26419
           hi IlluminatedWordWrite guibg = #1F7A8C
           hi LspReferenceText guibg = #679436
           hi LspReferenceWrite guibg = #A5BE00
           hi LspReferenceRead guibg = #427AA1
       ]]
    end
}
use 'azabiong/vim-highlighter' -- Archieved
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
    'tribela/vim-transparent',   -- Archieved
    cmd = 'TransparentEnable'
}
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ Colorscheme ❱━━━━━━━━━━━━━━━━━━━</>
--     use 'tjdevries/colorbuddy.vim'
-- << Light >>
-- use 'EdenEast/nightfox.nvim' -- dayfox dawnfox
--     use 'Mofiqul/adwaita.nvim'
--     use 'NLKNguyen/papercolor-theme'
--     use 'Th3Whit3Wolf/one-nvim'
--     use 'Th3Whit3Wolf/onebuddy'
--     use 'ayu-theme/ayu-vim'
--     use 'catppuccin/nvim'
--     use 'jsit/toast.vim'
--     use 'marko-cerovac/material.nvim'
--     use 'mcchrish/zenbones.nvim'
--     use 'olimorris/onedarkpro.nvim'
--     use 'projekt0n/github-nvim-theme'
--     use 'rafamadriz/neon'
--     use 'rmehri01/onenord.nvim'
--     use 'rose-pine/neovim'
--     use 'sainnhe/edge'
--     use 'sainnhe/everforest'
-- 
--     -- << Dark >>
use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
--     use 'Mofiqul/adwaita.nvim'
--     use 'NLKNguyen/papercolor-theme' -- BUG: space · color is not good
--     use 'Th3Whit3Wolf/one-nvim'
--     use 'ayu-theme/ayu-vim'
--     use 'cpea2506/one_monokai.nvim'
--     use 'fenetikm/falcon'
--     use 'glepnir/zephyr-nvim'
--     use 'kaiuri/nvim-juliana'
--     use 'kartikp10/noctis.nvim'
--     use 'lmburns/kimbox'
--     use 'marko-cerovac/material.nvim'
--     use 'maxmx03/FluoroMachine.nvim'
--     use 'mcchrish/zenbones.nvim' -- duckbones forestbones kanagawabones neobones nordbones randombones rosebones seoulbones tokyobones vimbones zenburned zenwritten
--     use 'mhartington/oceanic-next'
--     use 'ntk148v/vim-horizon'
--     use 'nxvu699134/vn-night.nvim'
--     use 'olimorris/onedarkpro.nvim'
--     use 'projekt0n/github-nvim-theme'
--     use 'rafalbromirski/vim-aurora'
--     use 'rafamadriz/neon'
--     use 'ray-x/aurora'
--     use 'ray-x/starry.nvim' -- Moonlight Dracula Dracula_blood Monokai Mariana Emerald Middlenight_blue Earlysummer Darksolar Ukraine
--     use 'rebelot/kanagawa.nvim'
--     use 'rmehri01/onenord.nvim'
--     use 'rockyzhang24/arctic.nvim'
--     use 'rose-pine/neovim'
--     use 'sainnhe/edge'
--     use 'sainnhe/everforest'
--     use 'sainnhe/sonokai'
--     use 'sam4llis/nvim-tundra'
--     use 'savq/melange'
--     use 'shaunsingh/moonlight.nvim'
--     use 'sickill/vim-monokai'
--     use 'tanvirtin/monokai.nvim'
--     use 'tiagovla/tokyodark.nvim'
--     use 'titanzero/zephyrium'
--     use 'tjdevries/gruvbuddy.nvim'
--     use 'tomasiser/vim-code-dark'
--     use 'wuelnerdotexe/vim-enfocado'
--     use 'yashguptaz/calvera-dark.nvim'
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
use {
    'hrsh7th/nvim-cmp',
    config = function()
        local cmp = require('cmp')
        local snippy = require("snippy")
        cmp.setup({
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    {
                        name = 'cmdline',
                        -- max_item_count = 10
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
                    { name = 'buffer' },
                    -- { name = 'nvim_lsp_document_symbol' }
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

                    local cmp_kinds = {
                        Class = ' ',
                        Color = ' ',
                        Constant = ' ',
                        Constructor = ' ',
                        Enum = ' ',
                        EnumMember = ' ',
                        Event = ' ',
                        Field = ' ',
                        File = ' ',
                        Folder = ' ',
                        Function = ' ',
                        History = ' ',
                        Interface = ' ',
                        Keyword = ' ',
                        Method = ' ',
                        Module = ' ',
                        Operator = ' ',
                        Options = ' ',
                        Property = ' ',
                        Reference = ' ',
                        Snippet = ' ',
                        Struct = ' ',
                        Text = ' ',
                        TypeParameter = ' ',
                        Unit = ' ',
                        Value = ' ',
                        Variable = ' ',
                    }
                    local kind_symbol = cmp_kinds[vim_item.kind]
                    vim_item.kind = kind_symbol and kind_symbol .. vim_item.kind or vim_item.kind

                    return vim_item
                end
            },
            mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
                -- ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- Scroll the documentation window if visible
                -- ['<C-f>'] = cmp.mapping.scroll_docs(4), -- Scroll the documentation window if visible
                -- ['<C-Space>'] = cmp.mapping.complete(),
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
--                 { name = 'nvim_insert_text_lsp' },
                { name = 'nvim_lsp' },
--                 { name = 'nvim_lsp_signature_help' },
                -- { name = 'nvim_lua' },
                { name = 'path' },
                { name = 'snippy' },
                { name = 'spell' }
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        -- -- Custom source test
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
    end
}
    use 'dmitmel/cmp-cmdline-history'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-nvim-lsp'
--     use 'hrsh7th/cmp-nvim-lsp-document-symbol'
--     use 'hrsh7th/cmp-nvim-lsp-signature-help'
    -- use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-path'
    use 'f3fora/cmp-spell'
--     -- TODO: https://github.com/jameshiew/nvim-magic
--     -- TODO: https://github.com/kristijanhusak/vim-dadbod-completion
--     -- TODO: https://github.com/lukas-reineke/cmp-rg
--     -- TODO: https://github.com/lukas-reineke/cmp-under-comparator
--     -- TODO: https://github.com/rcarriga/cmp-dap
--     -- TODO: https://github.com/tzachar/cmp-fuzzy-buffer
--     -- TODO: https://github.com/tzachar/cmp-fuzzy-path
--     -- TODO: https://github.com/zbirenbaum/copilot-cmp
-- <~>

-- Configuration:</>
-- ``````````````
-- {{{
-- TODO: https://github.com/Avimitin/nvim
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
-- TODO: https://github.com/vi-tality/neovitality
-- }}}

--     -- Debugger:
--     -- `````````
--     -- TODO: https://github.com/Weissle/persistent-breakpoints.nvim
--     use 'Pocco81/dap-buddy.nvim'
--     -- TODO: https://github.com/jayp0521/mason-nvim-dap.nvim
--     use 'mfussenegger/nvim-dap'
--     use 'mfussenegger/nvim-dap-python'
--     -- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
--     -- TODO: https://github.com/puremourning/vimspector
--     use 'rcarriga/nvim-dap-ui'
--     -- TODO: https://github.com/sakhnik/nvim-gdb
--     -- TODO: https://github.com/theHamsta/nvim-dap-virtual-text
--     -- TODO: https://github.com/vim-scripts/Conque-GDB
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ Doc Generater ❱━━━━━━━━━━━━━━━━━━━</>
-- use {
--     "danymat/neogen",
--     config = function()
--         require('neogen').setup {}
--     end
-- }
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs<~>

--     -- ──────────────────── File Explorer ────────────────────</>
--     -- {{{
--     use {
--         'elihunter173/dirbuf.nvim',
--         cmd = 'Dirbuf'
--     }
--     use {
--         "mrbjarksen/neo-tree-diagnostics.nvim",
--         requires = "nvim-neo-tree/neo-tree.nvim",
--         module = "neo-tree.sources.diagnostics", -- if wanting to lazyload
--     }
-- use {
--     'nvim-neo-tree/neo-tree.nvim',
--     config = function()
--         require("neo-tree").setup({
--             filesystem = {
--                 hijack_netrw_behavior = "open_current"
--             }
--         })
--     end,
--     -- cmd = "Neotree"
-- }
--     -- }}}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Folding     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'anuvyklack/pretty-fold.nvim',
    config = function()
        require('pretty-fold').setup {
            fill_char = ' ',
            process_comment_signs = 'delete'
        }
    end
}
-- <~>

--     -- Formatting:</>
--     -- ```````````
--     -- use 'mhartington/formatter.nvim'
--     -- TODO: https://github.com/sbdchd/neoformat
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
                delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn', show_count = true},
                topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn', show_count = true},
                changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn', show_count = true},
            },
            -- show_deleted = true,
            -- count_chars = {
            --     [1]   = ' ',
            --     [2]   = ' ',
            --     [3]   = ' ',
            --     [4]   = ' ',
            --     [5]   = ' ',
            --     [6]   = ' ',
            --     [7]   = ' ',
            --     [8]   = ' ',
            --     [9]   = ' ',
            --     ['+'] = ' ',
            -- },
            current_line_blame_formatter_opts = {
                relative_time = true
            },
            current_line_blame_formatter = '  <author>  <committer_time>  <summary>`'
        }
    end
}
-- use 'pwntester/octo.nvim' -- Archieved
-- use 'rhysd/conflict-marker.vim' -- Archieved
-- use 'rhysd/git-messenger.vim' -- Archieved
-- use 'ruifm/gitlinker.nvim' -- Archieved
-- use 'sindrets/diffview.nvim' -- Archieved
-- use 'tanvirtin/vgit.nvim' -- Archieved
-- use 'whiteinge/diffconflicts' -- Archieved
-- https://github.com/akinsho/git-conflict.nvim
-- <~>

--     -- ──────────────────── Icons ────────────────────</>
--     -- {{{
--     use 'kyazdani42/nvim-web-devicons'
--     -- }}}
-- <~>

--     -- ──────────────────── Indentation ────────────────────</>
--     -- {{{
--     use {
--         'lukas-reineke/indent-blankline.nvim',
--         config = function()
--             require("indent_blankline").setup({
--                 --[[ show_current_context = true,
--                 show_current_context_start = true, ]]
--             })
--         end
--     }
--     -- }}}<~>

-- ──────────────────── Lint ────────────────────</>
-- use 'mfussenegger/nvim-lint'
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ LSP ❱━━━━━━━━━━━━━━━━━━━
use {
    'Kasama/nvim-custom-diagnostic-highlight',
    config = function()
        require('nvim-custom-diagnostic-highlight').setup {}
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

use 'neovim/nvim-lspconfig'

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

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(_, bufnr)
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
        end
        -- LSP settings (for overriding per client)
        local handlers =  {
            ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border_shape}),
            ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border_shape}),
        }
        -- Add additional capabilities supported by nvim-cmp
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        local capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
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
        vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
        vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
        vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
        vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
        vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
        vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
        vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
        vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
    end,
    event = 'LspAttach'
}
use {
    'RishabhRD/popfix'
}

--     use {
--         "amrbashir/nvim-docs-view",
--         -- cmd = { "DocsViewToggle" },
--         config = function()
--             require("docs-view").setup {
--                 position = "right",
--                 width = 60,
--             }
--         end
--     }
--     use 'folke/lsp-colors.nvim'
--     -- TODO: https://github.com/gfanto/fzf-lsp.nvim
--     use({
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
--     --[[ use {
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
--     use 'jubnzv/virtual-types.nvim'
--     use {
--         'kosayoda/nvim-lightbulb',
--         requires = 'antoinemadec/FixCursorHold.nvim'
--     }
--     use 'Decodetalkers/csharpls-extended-lsp.nvim'
--     use 'Hoffs/omnisharp-extended-lsp.nvim'
--     use {
--         'andrewferrier/textobj-diagnostic.nvim',
--         config = function()
--             require("textobj-diagnostic").setup()
--         end
--     }
--     -- TODO: https://github.com/anuvyklack/hydra.nvim
--     use 'filipdutescu/renamer.nvim'
--     -- use 'jayp0521/mason-null-ls.nvim'
--     use 'kwkarlwang/cmp-nvim-insert-text-lsp'
--     use 'ldelossa/litee-bookmarks.nvim'
--     use 'ldelossa/litee-calltree.nvim'
--     use 'ldelossa/litee.nvim'
--     use 'lukas-reineke/format.nvim'
--     use 'nanotee/nvim-lsp-basics'
--     use 'nvim-lua/lsp-status.nvim'
--     -- TODO: https://github.com/ojroques/nvim-lspfuzzy
--     use 'onsails/diaglist.nvim'
--     use 'p00f/clangd_extensions.nvim'
--     use 'razzmatazz/csharp-language-server'
--     use {
--         'onsails/lspkind.nvim'
--     }
--     -- TODO: https://github.com/ray-x/navigator.lua
--     use {
--         'rmagatti/goto-preview',
--         config = function()
--             require('goto-preview').setup {}
--         end
--     }
--     use {
--         'simrat39/symbols-outline.nvim',
--         config = function()
--             require("symbols-outline").setup()
--         end
--     }
--     --[[ use {
--        "smjonas/inc-rename.nvim",
--        config = function()
--            require("inc_rename").setup()
--        end,
--     } ]] -- NOTE: needs neovim v0.8
--     use {
--         'stevearc/aerial.nvim',
--         config = function()
--             require('aerial').setup({})
--         end
--     }
--     use 'tami5/lspsaga.nvim'
--     use 'weilbith/nvim-code-action-menu'
--     -- }}}

--     -- Lua:
--     -- ````
--     -- TODO: https://github.com/jbyuki/one-small-step-for-vimkind
--     -- TODO: https://github.com/milisims/nvim-luaref
--     -- TODO: https://github.com/nanotee/nvim-lua-guide
--     -- TODO: https://github.com/rafcamlet/nvim-luapad

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Mapping     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'folke/which-key.nvim',
    -- TODO: create maps using which-key
    config = function()
        require("which-key").setup({
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

---- Markdown:
---- `````````
--use {
--    'AckslD/nvim-FeMaco.lua',
--    config = 'require("femaco").setup()',
--}
use 'davidgranstrom/nvim-markdown-preview'

-- Marks:
--     -- ``````
--     -- {{{
--     -- Guide:
--     -- https://vim.fandom.com/wiki/Using_marks
--     -- |----------------+---------------------------------------------------------------|
--     -- | Command        | Description                                                   |
--     -- |----------------+---------------------------------------------------------------|
--     -- | ''             | jump back (to line in current buffer where jumped from)       |
--     -- | 'a             | jump to line of mark a (first non-blank character in line)    |
--     -- | :delmarks a    | delete mark a                                                 |
--     -- | :delmarks a-d  | delete marks a, b, c, d                                       |
--     -- | :delmarks aA   | delete marks a, A                                             |
--     -- | :delmarks abxy | delete marks a, b, x, y                                       |
--     -- | :delmarks!     | delete all lowercase marks for the current buffer (a-z)       |
--     -- | :marks         | list all the current marks                                    |
--     -- | :marks aB      | list marks a, B                                               |
--     -- | ['             | jump to previous line with a lowercase mark                   |
--     -- | [`             | jump to previous lowercase mark                               |
--     -- | ]'             | jump to next line with a lowercase mark                       |
--     -- | ]`             | jump to next lowercase mark                                   |
--     -- | `"             | jump to position where last exited current buffer             |
--     -- | `.             | jump to position where last change occurred in current buffer |
--     -- | `0             | jump to position in last file edited (when exited Vim)        |
--     -- | `1             | like `0 but the previous file (also `2 etc)                   |
--     -- | `< or `>       | jump to beginning/end of last visual selection                |
--     -- | `[ or `]       | jump to beginning/end of previously changed or yanked text    |
--     -- | ``             | jump back (to position in current buffer where jumped from)   |
--     -- | `a             | jump to position (line and column) of mark a                  |
--     -- | c'a            | change text from current line to line of mark a               |
--     -- | d'a            | delete from current line to line of mark a                    |
--     -- | d`a            | delete from current cursor position to position of mark a     |
--     -- | ma             | set mark a at current cursor location                         |
--     -- | y`a            | yank text to unnamed buffer from cursor to position of mark a |
--     -- |----------------+---------------------------------------------------------------|
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
--     -- }}}
-- 
--     -- OrgMode:
--     -- ````````
--     -- {{{
--     -- TODO: https://github.com/TravonteD/org-capture-filetype
--     -- TODO: https://github.com/akinsho/org-bullets.nvim
--     use {
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
--     -- use 'nvim-orgmode/orgmode'
--     -- TODO: https://github.com/ranjithshegde/orgWiki.nvim
--     use {
--         'lukas-reineke/headlines.nvim',
--         config = function()
--             require('headlines').setup()
--         end,
--     }
--     -- }}}
-- 
--     -- Project:
--     -- ````````
--     -- TODO: https://github.com/ahmedkhalf/project.nvim --> treesitter

--     -- Quickfix:
--     -- {{{
--     use 'kevinhwang91/nvim-bqf'
--     use {
--         'stevearc/qf_helper.nvim',
--         config = function()
--             require'qf_helper'.setup()
--         end
--     }
--     -- }}}

--     -- Rooter:
--     -- ```````
-- 
--     -- Session Manager:
--     -- ````````````````
--     -- TODO: https://github.com/Shatur/neovim-session-manager --> plenary
--     -- TODO: https://github.com/jedrzejboczar/possession.nvim --> plenary
--     -- TODO: https://github.com/olimorris/persisted.nvim --> telescope
use {
  'rmagatti/auto-session',
  config = function()
    require("auto-session").setup({})
    vim.g.auto_session_suppress_dirs = { "~/" }
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end
}
--     -- TODO: https://github.com/thaerkh/vim-workspace

--     -- Snippets:
--     -- `````````
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
    requires = {
        'dcampos/cmp-snippy',
        'honza/vim-snippets'
    }
}
--     -- TODO: https://github.com/ellisonleao/carbon-now.nvim
--     -- TODO: https://github.com/hrsh7th/vim-vsnip
--     -- TODO: https://github.com/norcalli/snippets.nvim
--     -- TODO: https://github.com/notomo/cmp-neosnippet
--     -- TODO: https://github.com/quangnguyen30192/cmp-nvim-ultisnips
--     -- TODO: https://github.com/rafamadriz/friendly-snippets
--     -- TODO: https://github.com/saadparwaiz1/cmp_luasnip
--     -- TODO: https://github.com/smjonas/snippet-converter.nvim

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Status Line  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
-- vim.g.bubbly_symbols = {
--     default = 'PANIC!',
-- 
--     path = {
--         readonly = '',
--         unmodifiable = '',
--         modified = '+',
--     },
--     signify = {
--         added = '+%s', -- requires 1 '%s'
--         modified = '~%s', -- requires 1 '%s'
--         removed = '-%s', -- requires 1 '%s'
--     },
--     gitsigns = {
--         added = '+%s', -- requires 1 '%s'
--         modified = '~%s', -- requires 1 '%s'
--         removed = '-%s', -- requires 1 '%s'
--     },
--     coc = {
--         error = ' %s', -- requires 1 '%s'
--         warning = ' %s', -- requires 1 '%s'
--     },
--     builtinlsp = {
--         diagnostic_count = {
--             error = ' %s', -- requires 1 '%s'
--             warning = ' %s', --requires 1 '%s'
--         },
--     },
--     branch = ' %s', -- requires 1 '%s'
--     total_buffer_number = '﬘ %s', --requires 1 '%d'
--     lsp_status = {
--         diagnostics = {
--             error = ' %d',
--             warning = ' %d',
--             hint = ' %d',
--             info = ' %d',
--         },
--     },
-- }
-- 
-- vim.g.bubbly_tags = {
--     mode = {
--         normal = 'NORMAL',
--         insert = 'INSERT',
--         visual = 'VISUAL',
--         visualblock = 'VISUAL-B',
--         command = 'COMMAND',
--         terminal = 'TERMINAL',
--         replace = 'REPLACE',
--         default = 'UNKOWN',
--     },
--     paste = 'PASTE',
--     filetype = {
--         conf = ' config',
--         config = ' config',
--         css = ' css',
--         diff = '繁 diff',
--         dockerfile = ' docker',
--         email = ' mail',
--         gitconfig = ' git config',
--         html = ' html',
--         javascript = ' javascript',
--         javascriptreact = ' javascript',
--         json = ' json',
--         less = ' less',
--         lua = ' lua',
--         mail = ' mail',
--         make = ' make',
--         markdown = ' markdown',
--         noft = '<none>',
--         norg = '🦄 norg',
--         php = ' php',
--         plain = ' text',
--         plaintext = ' text',
--         ps1 = ' powershell',
--         python = ' python',
--         sass = ' sass',
--         scss = ' scss',
--         text = ' text',
--         typescript = ' typescript',
--         typescriptreact = ' typescript',
--         vim = ' vim',
--         xml = '謹 xml',
--     },
-- }
    'nvim-lualine/lualine.nvim',
    config = function()
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
        --     sections = {
        --         lualine_a = {'mode'},
        --         lualine_b = {'branch', 'diff', 'diagnostics'},
        --         lualine_c = {'filename'},
        --         lualine_x = {'encoding', 'fileformat', 'filetype'},
        --         lualine_y = {'progress'},
        --         lualine_z = {'location'}
        --     },
        --     inactive_sections = {
        --         lualine_a = {},
        --         lualine_b = {},
        --         lualine_c = {'filename'},
        --         lualine_x = {'location'},
        --         lualine_y = {},
        --         lualine_z = {}
        --     },
        --     tabline = {},
        --     winbar = {},
        --     inactive_winbar = {},
        --     extensions = {}
        }
    end,
    -- requires = { 'kyazdani42/nvim-web-devicons', opt = true }
}
-- <~>

--     -- Tab Line:
--     -- `````````
--     -- TODO: https://github.com/B4mbus/nvim-headband
--     --[[ use {
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
--     } ]]
--     -- use 'mengelbrecht/lightline-bufferline'
--     use 'nanozuki/tabby.nvim'
-- 
--     -- ──────────────────── Tables ────────────────────
--     -- {{{
--     use {
--         'dhruvasagar/vim-table-mode',
--         cmd = 'TableModeEnable'
--     }
--     use 'godlygeek/tabular'
--     -- }}}
-- 
--     -- ──────────────────── Telescope ────────────────────
--     -- {{{
--     use 'nvim-telescope/telescope.nvim'
--     use {
--         'LinArcX/telescope-command-palette.nvim',
--         config = function()
--             require('telescope').load_extension('command_palette')
--         end
--     }
--     use 'axkirillov/easypick.nvim'
--     use 'camspiers/snap'
--     use {
--         'crispgm/telescope-heading.nvim',
--         config = function()
--             require('telescope').load_extension('heading')
--         end
--     }
--     use {
--         'nvim-telescope/telescope-packer.nvim',
--         config = function()
--             require("telescope").load_extension('packer')
--         end
--     }
--     --[[ use {
--         'ptethng/telescope-makefile',
--         config = function()
--             require'telescope'.load_extension('make')
--         end
--     } ]]
--     -- TODO: https://github.com/nvim-telescope/telescope-file-browser.nvim
--     -- TODO: https://github.com/rmagatti/session-lens
--     -- }}}
-- 
--     -- Terminal:
--     -- `````````
--     -- {{{
--     use {
--         "akinsho/toggleterm.nvim",
--         tag = '*',
--         config = function()
--             require("toggleterm").setup()
--         end
--     }
--     -- TODO: https://github.com/elijahdanko/ttymux.nvim
--     -- TODO: https://github.com/jlesquembre/nterm.nvim
--     -- TODO: https://github.com/kassio/neoterm
--     -- TODO: https://github.com/nikvdp/neomux
--     -- TODO: https://github.com/numToStr/FTerm.nvim
--     -- TODO: https://github.com/oberblastmeister/termwrapper.nvim
--     -- TODO: https://github.com/pianocomposer321/consolation.nvim
--     -- TODO: https://github.com/s1n7ax/nvim-terminal
--     -- TODO: https://github.com/voldikss/vim-floaterm
--     -- }}}
-- 
--     -- Test & Run:
--     -- `````
--     -- TODO: https://github.com/EthanJWright/vs-tasks.nvim
--     -- TODO: https://github.com/andythigpen/nvim-coverage
--     -- TODO: https://github.com/is0n/jaq-nvim
--     -- TODO: https://github.com/jubnzv/mdeval.nvim
--     -- TODO: https://github.com/klen/nvim-test
--     -- TODO: https://github.com/michaelb/sniprun
--     -- TODO: https://github.com/nvim-neotest/neotest
--     -- TODO: https://github.com/pianocomposer321/yabs.nvim
--     -- TODO: https://github.com/smzm/hydrovim
--     -- TODO: https://github.com/stevearc/overseer.nvim
-- 
-- 
--     -- ──────────────────── Todo Marker ────────────────────
--     -- {{{
--      use {
--          'folke/todo-comments.nvim',
--          config = function()
--              require("todo-comments").setup({
--                  keywords = {
--                      THOUGHT = { icon = "🤔", color = "info"}
--                  }
--              })
--          end
--         -- TODO: Quickfix
--         -- TODO: Search
--         -- TODO: Telescope
--         -- TODO: Trouble
--      }
--     -- }}}
-- 
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Treesitter   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        require('nvim-treesitter.configs').setup {
            auto_install = true,
            -- endwise = {
            --     enable = true,
            -- },
            ignore_install = { "help", "yaml" },
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
--     use {
--         'm-demare/hlargs.nvim', -- NOTE: may not be required
--         config = function()
--             require('hlargs').setup()
--         end
--     }
--     -- use 'nvim-treesitter/nvim-treesitter-context' -- FIXME: conflicts with context.vim
--     use {
--         'RRethy/nvim-treesitter-endwise',
--         config = function()
--             require('nvim-treesitter.configs').setup {
--                 endwise = {
--                     enable = true,
--                 },
--             }
--         end
--     }
--     use {
--         'lewis6991/spellsitter.nvim',
--         config = function()
--             require('spellsitter').setup()
--         end
--     }
--     use {
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
--     use 'nvim-treesitter/playground'

use 'p00f/nvim-ts-rainbow'
--     -- }}}
-- 
--     -- ──────────────────── TUI ────────────────────
--     -- {{{
--     -- TODO: https://github.com/folke/noice.nvim
--     use 'rcarriga/nvim-notify'
--     use 'skywind3000/vim-quickui'
--     use 'stevearc/dressing.nvim'
--     use {
--         "vigoux/notifier.nvim",
--         config = function()
--             require'notifier'.setup {
--                 -- You configuration here
--             }
--         end
--     }
--     -- }}}
-- 
--     -- Utilities:
--     -- ``````````
--     use '0x100101/lab.nvim'
--     -- TODO: https://github.com/Almo7aya/openingh.nvim
--     use 'AndrewRadev/inline_edit.vim'
--     -- TODO: https://github.com/ElPiloto/significant.nvim
--     use 'NTBBloodbath/rest.nvim'
--     use 'MunifTanjim/nui.nvim'
--     use {
--         'RishabhRD/nvim-cheat.sh',
--         'RishabhRD/popfix'
--     }
--     use 'SmiteshP/nvim-navic'
--     use 'ThePrimeagen/refactoring.nvim'
--     use {
--         'andrewferrier/debugprint.nvim',
--         config = function()
--             require("debugprint").setup()
--         end
--     }
--     use 'andymass/vim-matchup'
--     use 'booperlv/nvim-gomove'
--     use 'chipsenkbeil/distant.nvim'
--     use 'chrisbra/NrrwRgn'
--     use 'cuducos/yaml.nvim'
--     use 'doums/suit.nvim'
       use {
           'dstein64/vim-startuptime',
           cmd = "StartupTime"
       }
--     use 'esensar/nvim-dev-container'
--     use 'folke/trouble.nvim'
--     use {
--         'gaoDean/autolist.nvim',
--         config = function()
--             require('autolist').setup()
--         end
--     }
--     use {
--         'gen740/SmoothCursor.nvim',
--         config = function()
--             require('smoothcursor').setup({
--                 autostart = true,
--                 cursor = "",             -- cursor shape (need nerd font)
--                 intervals = 35,           -- tick interval
--                 linehl = nil,             -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
--                 type = "default",         -- define cursor movement calculate function, "default" or "exp" (exponential).
--                 fancy = {
--                     enable = true,       -- enable fancy mode
--                     head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
--                     body = {
--                         { cursor = "", texthl = "SmoothCursorRed" },
--                         { cursor = "", texthl = "SmoothCursorOrange" },
--                         { cursor = "●", texthl = "SmoothCursorYellow" },
--                         { cursor = "●", texthl = "SmoothCursorGreen" },
--                         { cursor = "•", texthl = "SmoothCursorAqua" },
--                         { cursor = ".", texthl = "SmoothCursorBlue" },
--                         { cursor = ".", texthl = "SmoothCursorPurple" },
--                     },
--                     tail = { cursor = nil, texthl = "SmoothCursor" }
--                 },
--                 priority = 10,           -- set marker priority
--                 speed = 25,               -- max is 100 to stick to your current position
--                 texthl = "SmoothCursor",  -- highlight group, default is { bg = nil, fg = "#FFD400" }
--                 threshold = 3,
--                 timeout = 3000,
--             })
--         end
--     }
--     use {
--         'glacambre/firenvim',
--         run = function()
--             vim.fn['firenvim#install'](0)
--         end
--     }
--     use 'haringsrob/nvim_context_vt'
--     use 'jamestthompson3/nvim-remote-containers'
--     use 'jbyuki/instant.nvim'
--     use 'jbyuki/venn.nvim'
--     use 'junegunn/vim-easy-align'
--     use 'kevinhwang91/nvim-hlslens'
--     use {
--         'kevinhwang91/nvim-ufo',
--         'kevinhwang91/promise-async'
--     }
--     use 'krady21/compiler-explorer.nvim'
--     use 'kylechui/nvim-surround'
--     -- TODO: https://github.com/lifepillar/vim-colortemplate
--     use 'linty-org/key-menu.nvim'
--     -- TODO: https://github.com/linty-org/readline.nvim
--     use 'lewis6991/impatient.nvim' -- PERF: It should be first plugin to take effect init.vim
--     use 'mg979/vim-visual-multi'
--     use 'miversen33/import.nvim'
--     use 'mrjones2014/legendary.nvim'
--     use {
--         'nacro90/numb.nvim',
--         config = function()
--             require('numb').setup()
--         end
--     }
--     use 'nathom/filetype.nvim' -- PERF: just after impatient for perf improvement
--     use 'nvim-lua/plenary.nvim'
--     use 'nvim-lua/popup.nvim'
--     use 'ojroques/vim-oscyank'
--     use 'p00f/godbolt.nvim'
--     use 'paretje/nvim-man'
--     use 'pechorin/any-jump.vim'
--     use {
--         'phaazon/mind.nvim',
--         branch = 'v2.2',
--         config = function()
--             require'mind'.setup()
--         end
--     }
--     use 'pocco81/abbrevman.nvim'
--     -- TODO: https://github.com/ranelpadon/python-copy-reference.vim
--     use 'rickhowe/spotdiff.vim'
--     use 'rktjmp/lush.nvim'
--     use 'sidebar-nvim/sidebar.nvim'
--     use 'simnalamburt/vim-mundo'
--     use 'sindrets/winshift.nvim'
--     use 'tpope/vim-surround'
--     use {
--         'tversteeg/registers.nvim',
--         config = function()
--             vim.cmd[[let g:registers_window_border = "rounded"]]
--         end
--     }
--     use 'wellle/context.vim'
end
})
-- 
-- -- DAP
-- -- ```
-- --local dap = require('dap')
-- --dap.adapters.python = {
-- --    type = 'executable';
-- --    command = 'C:\\Users\\aloknigam\\AppData\\Local\\Programs\\Python\\Python310\\python.exe';
-- --}
-- --dap.configurations.python = {
-- --    {
-- --        type = 'python';
-- --        request = 'launch';
-- --        name = "Launch file";
-- --        program = "${file}";
-- --        pythonPath = 'C:\\Users\\aloknigam\\AppData\\Local\\Programs\\Python\\Python310\\python.exe';
-- --    }
-- --}
-- 
-- -- require('dap-python').setup('C:\\Users\\aloknigam\\learn\\python\\.virtualenvs\\debugpy\\Scripts\\python')
-- -- require('dap').set_log_level('TRACE')
-- 
-- -- LSP
-- -- ```
-- local on_attach = function(client, bufnr)
--     -- vim-illuminate
--     -- require 'illuminate'.on_attach(_)
-- 
--     -- require("aerial").on_attach(client, bufnr)
--     require'virtualtypes'.on_attach()
--     require("nvim-navic").attach(client, bufnr)
--     local opts = { buffer = bufnr }
--     vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
--     vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
--     vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
--     vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
--     vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
--     vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
--     vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
--     vim.keymap.set('n', '<leader>wl', function()
--         vim.inspect(vim.lsp.buf.list_workspace_folders())
--     end, opts)
--     vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
--     vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
--     vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
--     vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
--     vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
-- end
-- 
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- local capabilities = function()
--     require('cmp_nvim_insert_text_lsp').update_capabilities(capabilities)
--     require('cmp_nvim_lsp').update_capabilities(capabilities)
-- end
-- 
-- require("mason-lspconfig").setup()
-- require("mason-lspconfig").setup_handlers {
--     function (server_name)
--         require("lspconfig")[server_name].setup {
--             on_attach = on_attach,
--             capabilities = capabilities
--         }
--     end
-- }
-- 
-- -- Show source in diagnostics
-- vim.diagnostic.config({
--     virtual_text = {
--         source = "always",  -- Or "if_many"
--     },
--     float = {
--         source = "always",  -- Or "if_many"
--     },
-- })
-- 
-- -- Change diagnostic symbols in the sign column (gutter)
-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
-- for type, icon in pairs(signs) do
--     local hl = "DiagnosticSign" .. type
--     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
-- 
-- -- Highlight line number instead of having icons in sign column
-- vim.cmd [[
-- highlight! DiagnosticLineNrError guibg=#E94B3C guifg=#2D2926 gui=bold
-- highlight! DiagnosticLineNrWarn guibg=#D6ED17 guifg=#606060 gui=bold
-- highlight! DiagnosticLineNrInfo guibg=#FEE715 guifg=#101820 gui=bold
-- highlight! DiagnosticLineNrHint guibg=#9CC3D5 guifg=#0063B2 gui=bold
-- 
-- sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
-- sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
-- sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
-- sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
-- ]]
-- 
-- -- Auto-Initialize serves
-- -- NOTE: not needed after mason
-- -- local lspconfig = require 'lspconfig'
-- 
-- --local servers = require'nvim-lsp-installer.servers'.get_installed_server_names()
-- --for _, lsp in ipairs(servers) do
-- --    print(lsp)
-- --    lspconfig[lsp].setup {
-- --        on_attach = on_attach,
-- --        capabilities = capabilities,
-- --    }
-- --end
-- 
-- -- require('fine-cmdline').setup({
-- --     popup = {
-- --         win_options = {
-- --             winhighlight = "Normal:Normal,FloatBorder:SpecialChar"
-- --         }
-- --     }
-- -- })
-- -- vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
-- 
-- 
-- --[[
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ Abstract-IDE configs ❱━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- {{{
-- -- Set completeopt to have a better completion experience
-- vim.o.completeopt = 'menuone,noselect'
-- 
-- local import_cmp, cmp = pcall(require, 'cmp')
-- if not import_cmp then return end
-- 
-- local import_luasnip, luasnip = pcall(require, 'luasnip')
-- if not import_luasnip then return end
-- 
-- 
-- cmp.setup({
-- 
-- 	-- -- Disabling completion in certain contexts, such as comments
-- 	-- enabled = function()
-- 	-- 	-- disable completion in comments
-- 	-- 	local context = require 'cmp.config.context'
-- 	-- 	-- keep command mode completion enabled when cursor is in a comment
-- 	-- 	if vim.api.nvim_get_mode().mode == 'c' then
-- 	-- 		return true
-- 	-- 	else
-- 	-- 		return not context.in_treesitter_capture("comment")
-- 	-- 			and not context.in_syntax_group("Comment")
-- 	-- 	end
-- 	-- end,
-- 
-- 	completion = {
-- 		-- completeopt = 'menu,menuone,noinsert',
-- 	},
-- 
-- 	snippet = {
-- 		expand = function(args) luasnip.lsp_expand(args.body) end,
-- 	},
-- 
-- 	formatting = {
-- 
-- 		format = function(entry, vim_item)
-- 			-- fancy icons and a name of kind
-- 			local import_lspkind, lspkind = pcall(require, "lspkind")
-- 			if import_lspkind then
-- 				vim_item.kind = lspkind.presets.default[vim_item.kind]
-- 			end
-- 
-- 			-- limit completion width
-- 			local ELLIPSIS_CHAR = '…'
-- 			local MAX_LABEL_WIDTH = 35
-- 			local label = vim_item.abbr
-- 			local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
-- 			if truncated_label ~= label then
-- 				vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
-- 			end
-- 
-- 			-- set a name for each source
-- 			vim_item.menu = ({
-- 				buffer = "[Buff]",
-- 				nvim_lsp = "[LSP]",
-- 				luasnip = "[LuaSnip]",
-- 				nvim_lua = "[Lua]",
-- 				latex_symbols = "[Latex]",
-- 			})[entry.source.name]
-- 			return vim_item
-- 		end,
-- 	},
-- 
-- 	sources = {
-- 		{name = 'nvim_lsp'},
-- 		{name = 'nvim_lsp_signature_help' },
-- 		{name = 'nvim_lua'},
-- 		{name = 'path'},
-- 		{name = 'luasnip'},
-- 		{name = 'buffer', keyword_length = 1},
-- 		-- {name = 'calc'},
-- 	},
-- 
-- 	window = {
-- 		documentation = {
-- 			border = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
-- 		},
-- 		completion = {
-- 			border = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
-- 		}
-- 	},
-- 
-- 	experimental = {
-- 		-- ghost_text = true,
-- 	},
-- 
-- })
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end configs ❱━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ configs ❱━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
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
-- --------------------------
-- 
-- 
-- --------------------------
-- -- nvim-dap
-- 
-- 
-- 
-- -- end nvim-dap
-- --------------------------
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end configs ❱━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ Mappings ❱━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- -- Use an on_attach function to only map the following keys
-- -- after the language server attaches to the current buffer
-- -- ───────────────────────────────────────────────── --
-- local on_attach = function(client, bufnr)
-- 
-- 	local function buf_set_keymap(...) api.nvim_buf_set_keymap(bufnr, ...) end
-- 	local function buf_set_option(...) api.nvim_buf_set_option(bufnr, ...) end
-- 
-- 	---------------------
-- 	-- Avoiding LSP formatting conflicts
-- 	-- ref: https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
-- 	-- 2nd red: https://github.com/neovim/nvim-lspconfig/issues/1891#issuecomment-1157964108
-- 	-- nevim 0.8.x
-- 	client.server_capabilities.documentFormattingProvider = false
-- 	client.server_capabilities.documentRangeFormattingProvider = false
-- 	-- nevim 0.7.x
-- 	client.resolved_capabilities.document_formatting = false
-- 	client.resolved_capabilities.document_range_formatting = false
-- 	--------------------------
-- 
-- 	-- Enable completion triggered by <c-x><c-o>
-- 	buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
-- 
-- 	-- Mappings.
-- 	local options = {noremap = true, silent = true}
-- 
-- 	-- See `:help vim.lsp.*` for documentation on any of the below functions
-- 	-- ───────────────────────────────────────────────── --
-- 	buf_set_keymap('n', '<Space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', options)
-- 	buf_set_keymap('n', '<Space>q', '<cmd>lua vim.diagnostic.set_loclist({})<CR>', options)
-- 	buf_set_keymap('n', '<Space>n', '<cmd>lua vim.diagnostic.goto_next()<CR>', options)
-- 	buf_set_keymap('n', '<Space>b', '<cmd>lua vim.diagnostic.goto_prev()<CR>', options)
-- 
-- 	buf_set_keymap('n', '<Space>d', '<Cmd>lua vim.lsp.buf.definition()<CR>', options)
-- 	buf_set_keymap('n', '<Space>D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', options)
-- 	buf_set_keymap('n', '<Space>T', '<cmd>lua vim.lsp.buf.type_definition()<CR>', options)
-- 	buf_set_keymap('n', '<Space>i', '<cmd>lua vim.lsp.buf.implementation()<CR>', options)
-- 	buf_set_keymap('n', '<Space>s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', options)
-- 	buf_set_keymap('n', '<Space>h', '<Cmd>lua vim.lsp.buf.hover()<CR>', options)
-- 	buf_set_keymap('n', 'K',        '<Cmd>lua vim.lsp.buf.hover()<CR>', options)
-- 	-- using 'filipdutescu/renamer.nvim' for rename
-- 	-- buf_set_keymap('n', '<space>rn',	'<cmd>lua vim.lsp.buf.rename()<CR>', opts)
-- 	buf_set_keymap('n', '<Space>r', '<cmd>Telescope lsp_references<CR>', options)
-- 	buf_set_keymap("n", "<Space>f", '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', options)
-- 
-- 	buf_set_keymap('n', '<Space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>',       options)
-- 	buf_set_keymap('x', '<Space>a', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', options)
-- 
-- 	-- buf_set_keymap('n', '<leader>wa',   '<cmd>lua vim.lsp.buf.add_workleader_folder()<CR>',          opts)
-- 	-- buf_set_keymap('n', '<leader>wr',   '<cmd>lua vim.lsp.buf.remove_workleader_folder()<CR>',       opts)
-- 	-- buf_set_keymap('n', '<leader>wl',   '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workleader_folders()))<CR>', opts)
-- end
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end Mappings ❱━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- 
-- 
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ configs ❱━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- local function setup_lsp_config()
-- 
-- 	-- options for lsp diagnostic
-- 	-- ───────────────────────────────────────────────── --
-- 	vim.diagnostic.config({
-- 		float = {
-- 			border = "rounded",
-- 			focusable = true,
-- 			style = "minimal",
-- 			source = "always",
-- 			header = "",
-- 			prefix = "",
-- 		},
-- 	})
-- 
-- 	handlers["textDocument/publishDiagnostics"] = lsp.with(
-- 		lsp.diagnostic.on_publish_diagnostics,
-- 		{
-- 			underline = true,
-- 			signs = true,
-- 			update_in_insert = true,
-- 			virtual_text = {
-- 				true,
-- 				spacing = 6,
-- 				-- severity_limit='Error'  -- Only show virtual text on error
-- 			},
-- 		}
-- 	)
-- 
-- 	handlers["textDocument/hover"] = lsp.with(handlers.hover, {border = "rounded"})
-- 	handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, {border = "rounded"})
-- 
-- 	-- show diagnostic on float window(like auto complete)
-- 	-- vim.api.nvim_command [[ autocmd CursorHold  *.lua,*.sh,*.bash,*.dart,*.py,*.cpp,*.c,js lua vim.lsp.diagnostic.show_line_diagnostics() ]]
-- 
-- 	-- set LSP diagnostic symbols/signs
-- 	-- ─────────────────────────────────────────────────--
-- -- 	api.nvim_command [[ sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl= ]]
-- -- 	api.nvim_command [[ sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl= ]]
-- -- 	api.nvim_command [[ sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl= ]]
-- -- 	api.nvim_command [[ sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl= ]]
-- -- 
-- -- 	api.nvim_command [[ hi DiagnosticUnderlineError cterm=underline gui=underline guisp=#840000 ]]
-- -- 	api.nvim_command [[ hi DiagnosticUnderlineHint cterm=underline  gui=underline guisp=#07454b ]]
-- -- 	api.nvim_command [[ hi DiagnosticUnderlineWarn cterm=underline  gui=underline guisp=#2f2905 ]]
-- -- 	api.nvim_command [[ hi DiagnosticUnderlineInfo cterm=underline  gui=underline guisp=#265478 ]]
-- 
-- 	-- Auto-format files prior to saving them
-- 	-- vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)]]
-- 
-- 	--[[
-- 	" to change colors, it's better to define in color scheme
-- 	" highlight LspDiagnosticsUnderlineError         guifg=#EB4917 gui=undercurl
-- 	" highlight LspDiagnosticsUnderlineWarning       guifg=#EBA217 gui=undercurl
-- 	" highlight LspDiagnosticsUnderlineInformation   guifg=#17D6EB gui=undercurl
-- 	" highlight LspDiagnosticsUnderlineHint          guifg=#17EB7A gui=undercurl
-- 	--]]
--     --[[
-- end
-- 
-- 
-- -- ───────────────────────────────────────────────── --
-- -- setup LSPs
-- -- ───────────────────────────────────────────────── --
-- local function setup_lsp(mason_lspconfig)
-- 
-- 	local tbl_deep_extend = vim.tbl_deep_extend
-- 	local capabilities = lsp.protocol.make_client_capabilities()
-- 	local lsp_options = {
-- 		on_attach = on_attach,
-- 		flags = {
-- 			debounce_text_changes = 150,
-- 		},
-- 		capabilities = capabilities
-- 	}
-- 	local import_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
-- 	if import_cmp_lsp then
-- 		lsp_options.capabilities = (cmp_lsp).update_capabilities(capabilities)
-- 	end
-- 
-- 	-- for Flutter and Dart
-- 	-- don't put this on setup_handlers to set it because dart LSP is installed and maintained by akinsho/flutter-tools.nvim
-- 	lspconfig["dartls"].setup(lsp_options)
-- 
-- 	mason_lspconfig.setup_handlers({
-- 
-- 		function (server_name)
-- 			require("lspconfig")[server_name].setup(lsp_options)
-- 		end,
-- 
-- 		["clangd"] = function ()
-- 			lspconfig.clangd.setup(
-- 				tbl_deep_extend(
-- 					"force", lsp_options,
-- 					{ capabilities = { offsetEncoding = { "utf-16" } } }
-- 				)
-- 			)
-- 		end,
-- 		["html"] = function ()
-- 			lspconfig.html.setup(
-- 				tbl_deep_extend(
-- 					"force", lsp_options,
-- 					{ filetypes = {"html", "htmldjango"} }
-- 				)
-- 			)
-- 		end,
-- 		["cssls"] = function ()
-- 			lspconfig.cssls.setup(
-- 				tbl_deep_extend(
-- 					"force", lsp_options,
-- 					{
-- 						capabilities = {
-- 							textDocument = { completion= { completionItem = { snippetSupport = true } } }
-- 						},
-- 					}
-- 				)
-- 			)
-- 		end,
-- 		["sumneko_lua"] = function ()
-- 			lspconfig.sumneko_lua.setup(
-- 				tbl_deep_extend(
-- 					"force", lsp_options,
-- 					{
-- 						settings = {
-- 							Lua = {
-- 								diagnostics = {
-- 									-- Get the language server to recognize the 'vim', 'use' global
-- 									globals = {'vim', 'use', 'require'},
-- 								},
-- 								workspace = {
-- 									-- Make the server aware of Neovim runtime files
-- 									library = api.nvim_get_runtime_file("", true),
-- 								},
-- 								-- Do not send telemetry data containing a randomized but unique identifier
-- 								telemetry = {enable = false},
-- 							},
-- 						}
-- 					}
-- 				)
-- 			)
-- 		end,
-- 	})
-- end
-- 
-- -- make sure `lspconfig` is not loaded after `mason-lspconfig`.
-- -- Also, make sure not to set up any servers via `lspconfig` _before_ calling `mason-lspconfig`'s setup function.
-- 
-- 
-- 	-- require("mason-lspconfig").setup_handlers({
-- local import_mlspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
-- if not import_mlspconfig then return end
-- 
-- -- import nvim-lsp-installer configs
-- local import_mconfig, mconfig = pcall(require, "plugins.mason_nvim")
-- if not import_mconfig then return end
-- 
-- mason.setup(mconfig.setup) -- setup mason
-- setup_lsp_config() -- setup lsp configs (mainly UI)
-- setup_lsp(mason_lspconfig) -- setup lsp (like pyright, ccls ...)
-- 
-- -- ───────────────────────────────────────────────── --
-- -- end LSP setup
-- -- ───────────────────────────────────────────────── --
-- 
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end configs ❱━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ configs ❱━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- local imported_surround, surround = pcall(require, 'nvim-surround')
-- if not imported_surround then return end
-- 
-- 
-- surround.setup({
-- 	keymaps = { -- vim-surround style keymaps
-- 		visual = "S",
-- 		delete = "ds",
-- 		change = "cs",
-- 		insert = "<C-g>s",
--                 -- insert_line = "<C-g>S",
--                 -- normal = "ys",
--                 -- normal_cur = "yss",
--                 -- normal_line = "yS",
--                 -- normal_cur_line = "ySS",
--                 -- visual_line = "gS",
-- 	},
-- 	surrounds = {
--                 ["("] = { add = { "( ", " )" }, },
--                 [")"] = { add = { "(", ")" }, },
--                 ["{"] = { add = { "{ ", " }" }, },
--                 ["}"] = { add = { "{", "}" }, },
--                 ["<"] = { add = { "< ", " >" }, },
--                 [">"] = { add = { "<", ">" }, },
--                 ["["] = { add = { "[ ", " ]" }, },
--                 ["]"] = { add = { "[", "]" }, },
--                 ["'"] = { add = { "'", "'" }, },
--                 ['"'] = { add = { '"', '"' }, },
--                 ["`"] = { add = { "`", "`" }, },
-- 	},
--         aliases = {
--                 ["a"] = ">", -- Single character aliases apply everywhere
--                 ["b"] = ")",
--                 ["B"] = "}",
--                 ["r"] = "]",
--                 -- Table aliases only apply for changes/deletions
--                 ["q"] = { '"', "'", "`" }, -- Any quote character
--                 ["s"] = { ")", "]", "}", ">", "'", '"', "`" }, -- Any surrounding delimiter
--         },
-- 	highlight= { -- Highlight before inserting/changing surrounds
-- 		duration = 0,
-- 	},
--         move_cursor = "begin",
-- })
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ configs ❱━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- -- safely import telescope
-- local telescope_imported_ok, telescope = pcall(require, 'telescope')
-- if not telescope_imported_ok then return end
-- 
-- telescope.setup {
-- 
-- 	defaults = {
-- 		vimgrep_arguments = {
-- 			'rg',
-- 			'--color=never',
-- 			'--no-heading',
-- 			'--with-filename',
-- 			'--line-number',
-- 			'--column',
-- 			'--smart-case',
-- 		},
-- 
-- 		initial_mode = "insert",
-- 		selection_strategy = "reset",
-- 		sorting_strategy = "ascending",
-- 		layout_strategy = "horizontal",
-- 		layout_config = {
-- 			horizontal = {
-- 				mirror = false,
-- 				prompt_position = "top",
-- 				preview_width = 0.4,
-- 			},
-- 			vertical = { mirror = false, },
-- 			width = 0.8,
-- 			height = 0.9,
--             preview_cutoff = 80,
-- 		},
-- 		file_ignore_patterns = {
-- 			"__pycache__/", "__pycache__/*",
-- 
-- 			"build/",       "gradle/",  "node_modules/", "node_modules/*",
-- 			"smalljre_*/*", "target/",  "vendor/*","venv/",
-- 
-- 			".dart_tool/",  ".git/",   ".github/", ".gradle/",      ".idea/",        ".vscode/",
-- 
-- 			"%.sqlite3",    "%.ipynb", "%.lock",   "%.pdb",
-- 			"%.dll",        "%.class", "%.exe",    "%.cache", "%.pdf",  "%.dylib",
-- 			"%.jar",        "%.docx",  "%.met",    "%.burp",  "%.mp4",  "%.mkv", "%.rar",
-- 			"%.zip",        "%.7z",    "%.tar",    "%.bz2",   "%.epub", "%.flac","%.tar.gz",
-- 		},
-- 
-- 		file_sorter = require'telescope.sorters'.get_fuzzy_file,
-- 		generic_sorter = require'telescope.sorters'.get_generic_fuzzy_sorter,
-- 		file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
-- 		grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
-- 		qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
-- 
-- 		prompt_prefix = "🔎︎ ",
-- 		selection_caret = "➤ ",
-- 		entry_prefix = "  ",
-- 		winblend = 0,
-- 		border = {},
-- 		borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
-- 		color_devicons = true,
-- 		use_less = true,
-- 		set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
-- 		path_display = {'truncate'}, -- How file paths are displayed ()
-- 
-- 		preview = {
-- 			msg_bg_fillchar = " ",
-- 			treesitter = false,
-- 		},
-- 
-- 		live_grep = {
-- 			preview = {
-- 				treesitter = false
-- 			}
-- 		},
-- 
-- 		-- Developer configurations: Not meant for general override
-- 		buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
-- 	},
-- 
-- 	extensions = {
-- 
-- 		fzf = {
-- 			fuzzy = true, -- false will only do exact matching
-- 			override_generic_sorter = true, -- override the generic sorter
-- 			override_file_sorter = true, -- override the file sorter
-- 			case_mode = "smart_case", -- or "ignore_case" or "respect_case". the default case_mode is "smart_case"
-- 		},
-- 
-- 		media_files = {
-- 			-- filetypes whitelist
-- 			filetypes = {"png", "jpg", "mp4", "webm", "pdf"},
-- 			find_cmd = "fd" -- find command (defaults to `fd`)
-- 		},
-- 
-- 		file_browser = {
-- 			theme = "ivy",
-- 			-- disables netrw and use telescope-file-browser in its place
-- 			hijack_netrw = true,
-- 		},
-- 
-- 		["ui-select"] = {
-- 			require("telescope.themes").get_dropdown {
-- 				winblend = 15,
-- 				layout_config = {
-- 					prompt_position = "top",
-- 					width = 64,
-- 					height = 15,
-- 				},
-- 				border = {},
-- 				previewer = false,
-- 				shorten_path = false,
-- 			},
-- 		}
-- 
-- 	},
-- 
-- }
-- -- To get telescope-extension loaded and working with telescope,
-- -- you need to call load_extension, somewhere after setup function:
-- require('telescope').load_extension('fzf')
-- require("telescope").load_extension('file_browser')
-- require('telescope').load_extension('media_files')
-- require("telescope").load_extension("ui-select")
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end configs ❱━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- 
-- 
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ Mappings ❱━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- 
-- local keymap = vim.api.nvim_set_keymap
-- local options = { silent = true, noremap = true }
-- 
-- --      --> Launch Telescope without any argument
-- keymap('n', "tt",   "<cmd>lua require('telescope.builtin').builtin() <CR>", options)
-- 
-- --      --> Lists available Commands
-- keymap('n', "tc",   "<cmd>lua require('telescope.builtin').commands() <CR>", options)
-- 
-- --      --> Lists available help tags and opens a new window with the relevant help info on
-- keymap('n', "th",   "<cmd>lua require('telescope.builtin').help_tags() <CR>", options)
-- 
-- --       --> show all availabe MAPPING
-- keymap('n', "tm", "<cmd>lua require('telescope.builtin').keymaps() <CR>", options)
-- 
-- --       --> show buffers/opened files
-- keymap('n', "<C-b>", "<cmd>lua require('telescope.builtin').buffers() <CR>", options)
-- keymap('n', "tb",  "<cmd>lua require('telescope.builtin').buffers() <CR>", options)
-- 
-- --       --> show and grep current buffer
-- keymap('n', "tw", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find() <CR>", options)
-- keymap('n', "tg", "<cmd>lua require('telescope.builtin').live_grep() <CR>", options)
-- 
-- --       --> Find Files
-- -- NOTE1: to get project root's directory, extra plugin (github.com/ygm2/rooter.nvim) is used.
-- -- any config related to project root is in seperate config file (lua/plugin_confs/rooter_nvim.lua)
-- -- to change settings related to working directory, refer to rooter_nvim.lua config file
-- 
-- -- Find files from current file's project
-- keymap('n', "<C-p>", ":Telescope find_files <cr>", options)
-- keymap('n', "tp",    ":Telescope find_files <cr>", options)
-- -- show all files from current working directory
-- keymap('n', "<C-f>", "<cmd>lua require('telescope.builtin').find_files( { cwd = vim.fn.expand('%:p:h') }) <CR>", options)
-- keymap('n', "tf",    "<cmd>lua require('telescope.builtin').find_files( { cwd = vim.fn.expand('%:p:h') }) <CR>", options)
-- 
-- --       --> show symbols (@nvim-telescope/telescope-symbols.nvim)
-- keymap('n', "ts", "<cmd>lua require('telescope.builtin').symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} } <CR>", options)
-- 
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━❰ end Mappings ❱━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- }}}
-- ]]
-- 
-- --[[
-- -- Options from AstroNvim
-- -- {{{
-- astronvim.url_matcher =
--   "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"
-- 
-- --- Add syntax matching rules for highlighting URLs/URIs
-- function astronvim.set_url_match()
--   astronvim.delete_url_match()
--   if vim.g.highlighturl_enabled then vim.fn.matchadd("HighlightURL", astronvim.url_matcher, 15) end
-- end
-- 
-- --- Toggle URL/URI syntax highlighting rules
-- function astronvim.toggle_url_match()
--   vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
--   astronvim.set_url_match()
-- end
-- 
-- augroup("highlighturl", { clear = true })
-- cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
--   desc = "URL Highlighting",
--   group = "highlighturl",
--   pattern = "*",
--   callback = function() astronvim.set_url_match() end,
-- })
-- 
-- maps.n["<leader>u"] = { function() astronvim.toggle_url_match() end, desc = "Toggle URL Highlights" }
-- -- }}}
-- --]]
-- 
-- vim.g.bubbly_inactive_color = { background = 'lightgrey', foreground = 'foreground' }
-- 
-- --[[ require("lspconfig").powershell_es.setup({
--         bundle_path = vim.fn.stdpath("data") .. "\\mason\\packages\\powershell-editor-services\\",
--         cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\Start-EditorServices.ps1"}
--     }) ]]


-- vim: fmr=</>,<~>  fdm=marker
