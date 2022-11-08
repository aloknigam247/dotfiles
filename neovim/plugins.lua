--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

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

use 'azabiong/vim-highlighter' -- TODO: create context menu

use {
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
    end
}

use {
    'kevinhwang91/nvim-hlslens',
    config = function()
        require('hlslens').setup()
    end
}

use {
    'melkster/modicator.nvim',
    config = function()
        require('modicator').setup()
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

--━━━━━━━━━━━━━━━━━━━❰ Colorscheme ❱━━━━━━━━━━━━━━━━━━━</>
--     -- TODO: https://github.com/lifepillar/vim-colortemplate
--     use 'rktjmp/lush.nvim'
--     use 'tjdevries/colorbuddy.vim'
-- << Light >>
-- use 'EdenEast/nightfox.nvim' -- dayfox dawnfox
-- use 'Mofiqul/adwaita.nvim'
-- use 'NLKNguyen/papercolor-theme'
-- use 'Shatur/neovim-ayu'
-- use 'Th3Whit3Wolf/one-nvim'
-- use 'Th3Whit3Wolf/onebuddy'
-- use 'Tsuzat/NeoSolarized.nvim'
-- use 'atelierbram/Base2Tone-nvim'
-- use 'catppuccin/nvim'
-- use 'jsit/toast.vim'
-- use 'marko-cerovac/material.nvim'
-- use 'mcchrish/zenbones.nvim'
-- use 'olimorris/onedarkpro.nvim'
-- use 'projekt0n/github-nvim-theme'
-- use 'rafamadriz/neon'
-- use 'ray-x/starry.nvim' -- limestone
-- use 'rmehri01/onenord.nvim'
-- use 'rose-pine/neovim'
-- use 'sainnhe/edge'
-- use 'sainnhe/everforest'

--     -- << Dark >>
use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
-- use 'Hoffs/theme-sunset.nvim'
-- use 'LunarVim/darkplus.nvim'
-- use 'Mofiqul/adwaita.nvim'
-- use 'NLKNguyen/papercolor-theme' -- BUG: space · color is not good
-- use 'Shatur/neovim-ayu'
-- use 'Th3Whit3Wolf/one-nvim'
-- use 'Tsuzat/NeoSolarized.nvim'
-- use 'Yazeed1s/oh-lucy.nvim'
-- use 'atelierbram/Base2Tone-nvim'
-- use 'cpea2506/one_monokai.nvim'
-- use 'fenetikm/falcon'
-- use 'glepnir/zephyr-nvim'
-- use 'kaiuri/nvim-juliana'
-- use 'kartikp10/noctis.nvim'
-- use 'kvrohit/mellow.nvim'
-- use 'lmburns/kimbox'
-- use 'luisiacc/gruvbox-baby'
-- use 'marko-cerovac/material.nvim'
-- use 'maxmx03/FluoroMachine.nvim'
-- use 'mcchrish/zenbones.nvim' -- duckbones forestbones kanagawabones neobones nordbones randombones rosebones seoulbones tokyobones vimbones zenburned zenwritten
-- use 'mhartington/oceanic-next'
-- use 'ntk148v/vim-horizon'
-- use 'nxvu699134/vn-night.nvim'
-- use 'olimorris/onedarkpro.nvim'
-- use 'projekt0n/github-nvim-theme'
-- use 'rafalbromirski/vim-aurora'
-- use 'rafamadriz/neon'
-- use 'ray-x/aurora'
-- use 'ray-x/starry.nvim' -- Moonlight Dracula Dracula_blood Monokai Mariana Emerald Middlenight_blue Earlysummer Darksolar Ukraine
-- use 'rebelot/kanagawa.nvim'
-- use 'rmehri01/onenord.nvim'
-- use 'rockyzhang24/arctic.nvim'
-- use 'rose-pine/neovim'
-- use 'sainnhe/edge'
-- use 'sainnhe/everforest'
-- use 'sainnhe/sonokai'
-- use 'sam4llis/nvim-tundra'
-- use 'savq/melange'
-- use 'shaunsingh/moonlight.nvim'
-- use 'sickill/vim-monokai'
-- use 'tanvirtin/monokai.nvim'
-- use 'tiagovla/tokyodark.nvim'
-- use 'titanzero/zephyrium'
-- use 'tjdevries/gruvbuddy.nvim'
-- use 'tomasiser/vim-code-dark'
-- use 'w3barsi/barstrata.nvim'
-- use 'wuelnerdotexe/vim-enfocado'
-- use 'yashguptaz/calvera-dark.nvim'
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
                    -- local kind_symbol = vim.g.cmp_kinds[vim_item.kind]
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
-- <~>

-- -- Debugger:</>
-- -- `````````
-- -- TODO: https://github.com/Weissle/persistent-breakpoints.nvim
-- use 'Pocco81/dap-buddy.nvim'
-- -- TODO: https://github.com/jayp0521/mason-nvim-dap.nvim
-- use 'mfussenegger/nvim-dap'
-- use 'mfussenegger/nvim-dap-python'
-- -- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
-- -- TODO: https://github.com/puremourning/vimspector
-- use 'rcarriga/nvim-dap-ui'
-- -- TODO: https://github.com/sakhnik/nvim-gdb
-- -- TODO: https://github.com/theHamsta/nvim-dap-virtual-text
-- -- TODO: https://github.com/vim-scripts/Conque-GDB
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ Doc Generater ❱━━━━━━━━━━━━━━━━━━━</>
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
    config = function()
        require('pretty-fold').setup {
            fill_char = ' ',
            process_comment_signs = 'delete'
        }
    end
}
--     use {
--         'kevinhwang91/nvim-ufo',
--         'kevinhwang91/promise-async'
--     }
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
            current_line_blame_formatter_opts = {
                relative_time = true
            },
            current_line_blame_formatter = '  <author>  <committer_time>  <summary>`'
        }
    end
}
-- use 'pwntester/octo.nvim' -- Archieved
use 'rhysd/conflict-marker.vim' -- Archieved
-- use 'rhysd/git-messenger.vim' -- Archieved
-- use 'ruifm/gitlinker.nvim' -- Archieved
use 'sindrets/diffview.nvim' -- Archieved
-- use 'tanvirtin/vgit.nvim' -- Archieved
-- https://github.com/akinsho/git-conflict.nvim
-- https://github.com/Almo7aya/openingh.nvim -- NOTE: needs PR for VSO
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Icons      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
use 'kyazdani42/nvim-web-devicons'
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Indentation  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true
        })
    end
}
--     <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Libraries   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use 'MunifTanjim/nui.nvim'
use 'nvim-lua/plenary.nvim'
-- use 'nvim-lua/popup.nvim'
-- <~>

-- ──────────────────── Lint ────────────────────</>
-- use 'mfussenegger/nvim-lint'
-- <~>

--━━━━━━━━━━━━━━━━━━━❰ LSP ❱━━━━━━━━━━━━━━━━━━━</>
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
    -- TODO: create maps using which-key
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
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Quickfix   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use 'folke/trouble.nvim'
use {
    -- TODO: fzf
    'kevinhwang91/nvim-bqf',
    config = function()
        require('bqf').setup({
            auto_resize_height = true,
            preview = {
                border_chars = {'│', '│', '─', ' ', '╭', '╮', '╰', '╯', '█'}
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
    requires = {
        'dcampos/cmp-snippy',
        'honza/vim-snippets'
    }
}
-- TODO: https://github.com/ellisonleao/carbon-now.nvim
-- TODO: https://github.com/hrsh7th/vim-vsnip
-- TODO: https://github.com/norcalli/snippets.nvim
-- TODO: https://github.com/notomo/cmp-neosnippet
-- TODO: https://github.com/quangnguyen30192/cmp-nvim-ultisnips
-- TODO: https://github.com/rafamadriz/friendly-snippets
-- TODO: https://github.com/saadparwaiz1/cmp_luasnip
-- TODO: https://github.com/smjonas/snippet-converter.nvim
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Status Line  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'nvim-lualine/lualine.nvim',
    config = function()
        local navic = require("nvim-navic")
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
                        path = 3,                -- 0: Just the filename
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
        --     tabline = {},
        -- winbar = {
        --     lualine_b = {
        --         { navic.get_location, cond = navic.is_available }
        --     }
        -- },
        -- inactive_winbar = {
        --     lualine_b = {
        --         { navic.get_location, cond = navic.is_available }
        --     }
        -- },
        --     extensions = {}
        }
    end,
}
-- <~>

--     -- Tab Line:</>
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
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Telescope   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'axkirillov/easypick.nvim' -- NOTE: No need now

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
    config = function()
        require('telescope').setup({
            externsions = {
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
-- https://github.com/nikvdp/neomux
-- https://github.com/numToStr/FTerm.nvim
-- https://github.com/oberblastmeister/termwrapper.nvim
-- https://github.com/pianocomposer321/consolation.nvim
-- https://github.com/s1n7ax/nvim-terminal
-- https://github.com/voldikss/vim-floaterm
-- <~>

--     -- Test & Run:</>
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

-- use {
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

-- use 'nvim-treesitter/playground'

use {
    'p00f/nvim-ts-rainbow',
    after = 'nvim-treesitter'
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       TUI      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'gorbit99/codewindow.nvim'
use 'doums/suit.nvim'
-- use 'folke/drop.nvim'
-- use({
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
    'rcarriga/nvim-notify',
    config = function()
        vim.notify = require("notify")
    end
}
-- <~>

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Utilities   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- https://github.com/ElPiloto/significant.nvim -- NOTE: awesome plugin but not usage now
-- https://github.com/NarutoXY/silicon.lua

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

use {
    'gaoDean/autolist.nvim',
    config = function()
        require('autolist').setup()
    end
}

-- use {
--     'glacambre/firenvim',
--     run = function()
--         vim.fn['firenvim#install'](0)
--     end
-- }
-- use 'jbyuki/instant.nvim' -- NOTE: good but no use case now

-- https://github.com/krivahtoo/silicon.nvim

use 'kylechui/nvim-surround'

--     -- TODO: https://github.com/linty-org/readline.nvim

use 'lewis6991/impatient.nvim'

use 'mg979/vim-visual-multi'

use {
    'nacro90/numb.nvim',
    config = function()
        require('numb').setup()
    end
}

-- use 'ojroques/vim-oscyank' -- NOTE: not required now

-- use 'pechorin/any-jump.vim' -- NOTE:does not use LSP 

use 'rickhowe/spotdiff.vim'

use 'simnalamburt/vim-mundo'

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

-- -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ --
-- -- ━━━━━━━━━━━━━━━━━━━❰ Abstract-IDE configs ❱━━━━━━━━━━━━━━━━━━━ --
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
-- Options from AstroNvim
-- {{{
url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Add syntax matching rules for highlighting URLs/URIs
function set_url_match()
  -- delete_url_match()
  vim.fn.matchadd("HighlightURL", url_matcher, 15)
  -- if vim.g.highlighturl_enabled then vim.fn.matchadd("HighlightURL", url_matcher, 15) end
end

--- Toggle URL/URI syntax highlighting rules
function toggle_url_match()
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  set_url_match()
end

-- augroup("highlighturl", { clear = true })
-- cmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
--   desc = "URL Highlighting",
--   group = "highlighturl",
--   pattern = "*",
--   callback = function() set_url_match() end,
-- })

-- maps.n["<leader>u"] = { function() toggle_url_match() end, desc = "Toggle URL Highlights" }
-- }}}


-- vim: fmr=</>,<~>  fdm=marker
