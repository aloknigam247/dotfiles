--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

-- local ret = require('packer').startup({
require('packer').startup({
    config = {
        auto_clean = true,
        display = {
            open_fn = require('packer.util').float
        },
        -- log = {
        --     level = 'debug'
        -- },
        profile = {
            enable = true,
            threshold = 0.0001
        },
        -- autoremove = true
    },

    function(use)
    -- Packer:
    -- ```````
    use 'wbthomason/packer.nvim'

    -- ──────────────────── Auto Pair ────────────────────
    -- {{{
    use {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require("nvim-autopairs").setup()
        end
        -- TODO: Create custom rule to Expand multiple pairs on enter key, similar to vim-closer, already implemented in its wiki
        -- BUG: braces Indentation is not correct in some situation, powershell
        -- TODO: Create rule to not pair " for vim files
    }
    -- }}}

    -- ──────────────────── Cheatsheet ────────────────────
    -- {{{
    use {
        'sudormrfbin/cheatsheet.nvim',
        cmd = 'Cheatsheet',
        requires = {
            {'nvim-telescope/telescope.nvim'},
            {'nvim-lua/popup.nvim'},
            {'nvim-lua/plenary.nvim'},
        }
    }
    -- }}}

    -- COC:
    -- ````
    -- {{{
    -- TODO: https://github.com/coc-extensions/coc-powershell
    -- TODO: https://github.com/iamcco/coc-vimlsp
    -- TODO: https://github.com/ms-jpq/coq_nvim
    -- TODO: https://github.com/neoclide/coc-highlight
    -- TODO: https://github.com/neoclide/coc-json
    -- TODO: https://github.com/neoclide/coc-neco
    -- TODO: https://github.com/neoclide/coc-pairs
    -- TODO: https://github.com/neoclide/coc-snippets
    -- TODO: https://github.com/neoclide/coc-sources
    -- TODO: https://github.com/neoclide/coc-yank
    -- TODO: https://github.com/neoclide/coc.nvim
    -- TODO: https://github.com/voldikss/coc-browser
    -- TODO: https://github.com/xiyaowong/coc-lightbulb-
    -- }}}

    -- Coloring:
    -- `````````
    -- {{{
    use {
        'RRethy/vim-illuminate',
        config = function()
        vim.cmd[[
        hi def IlluminatedWordText gui=underline
        hi def IlluminatedWordRead gui=underline
        hi def IlluminatedWordWrite gui=underline
        hi def link LspReferenceText WildMenu
        hi def link LspReferenceWrite WildMenu
        hi def link LspReferenceRead WildMenu
        ]]
        end
        -- FIXME: highlight colors are not good
    }
    use 'azabiong/vim-highlighter' -- NOTE: Good to use
    use 'machakann/vim-highlightedyank'
    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end
    }
    use {
        't9md/vim-quickhl',
        config = function()
            vim.cmd[[
            nmap <Space>m <Plug>(quickhl-manual-this)
            xmap <Space>m <Plug>(quickhl-manual-this)
            nmap <Space>M <Plug>(quickhl-manual-reset)
            xmap <Space>M <Plug>(quickhl-manual-reset)
            ]]
        end
    }
    use {
        'tribela/vim-transparent',
        cmd = 'TransparentEnable'
    }
    -- }}}

    -- Colorscheme:
    -- ````````````
    -- {{{
    use 'tjdevries/colorbuddy.vim'
    -- Current:
    -- << Light >>
    use 'EdenEast/nightfox.nvim' -- dayfox dawnfox
    use 'Mofiqul/adwaita.nvim'
    use 'NLKNguyen/papercolor-theme'
    use 'Th3Whit3Wolf/one-nvim'
    use 'Th3Whit3Wolf/onebuddy'
    use 'ayu-theme/ayu-vim'
    use 'catppuccin/nvim'
    use 'jsit/toast.vim'
    use 'marko-cerovac/material.nvim'
    use 'mcchrish/zenbones.nvim'
    use 'olimorris/onedarkpro.nvim'
    use 'projekt0n/github-nvim-theme'
    use 'rafamadriz/neon'
    use 'rmehri01/onenord.nvim'
    use 'rose-pine/neovim'
    use 'sainnhe/edge'
    use 'sainnhe/everforest'

    -- << Dark >>
    use 'Almo7aya/neogruvbox.nvim'
    use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
    use 'Mofiqul/adwaita.nvim'
    use 'NLKNguyen/papercolor-theme' -- BUG: space · color is not good
    use 'Th3Whit3Wolf/one-nvim'
    use 'ayu-theme/ayu-vim'
    use 'cpea2506/one_monokai.nvim'
    use 'fenetikm/falcon'
    use 'glepnir/zephyr-nvim'
    use 'kaiuri/nvim-juliana'
    use 'lmburns/kimbox'
    use 'marko-cerovac/material.nvim'
    use 'maxmx03/FluoroMachine.nvim'
    use 'mcchrish/zenbones.nvim' -- duckbones forestbones kanagawabones neobones nordbones randombones rosebones seoulbones tokyobones vimbones zenburned zenwritten
    use 'mhartington/oceanic-next'
    use 'ntk148v/vim-horizon'
    use 'nxvu699134/vn-night.nvim'
    use 'olimorris/onedarkpro.nvim'
    use 'projekt0n/github-nvim-theme'
    use 'rafalbromirski/vim-aurora'
    use 'rafamadriz/neon'
    use 'ray-x/aurora'
    use 'ray-x/starry.nvim' -- Moonlight Dracula Dracula_blood Monokai Mariana Emerald Middlenight_blue Earlysummer Darksolar Ukraine
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
    use 'sickill/vim-monokai'
    use 'tanvirtin/monokai.nvim'
    use 'tiagovla/tokyodark.nvim'
    use 'titanzero/zephyrium'
    use 'tjdevries/gruvbuddy.nvim'
    use 'tomasiser/vim-code-dark'
    use 'wuelnerdotexe/vim-enfocado'
    use 'yashguptaz/calvera-dark.nvim'

    -- use 'dylanaraps/wal.vim'
    -- use 'AlphaTechnolog/pywal.nvim'
    -- }}}

    -- Commenting:
    -- ```````````
    use 'b3nj5m1n/kommentary' -- NOTE: Fixed --[[]] problem
    -- TODO: use 'numToStr/Comment.nvim'
    -- TODO: https://github.com/s1n7ax/nvim-comment-frame
    -- TODO: use 'terrortylor/nvim-comment'
    -- TODO: https://github.com/tpope/vim-commentary
    -- TODO: https://github.com/tyru/caw.vim
    -- TODO: https://github.com/winston0410/commented.nvim

    -- Completion:
    -- ```````````
    use {
        'hrsh7th/nvim-cmp',
        --  TODO: Hover doc
        --  TODO: LSP - explore
        --  TODO: Snippets
        config = function()
            local cmp = require('cmp')
            -- local lspkind = require('lspkind')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'cmdline' },
                    { name = 'cmdline_history' }
                }
            }),
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' },
                    { name = 'nvim_lsp_document_symbol' }
                }
            }),
            formatting = {
                format = function(entry, vim_item)
                    if entry.source.name == "buffer" then
                        vim_item.menu = "[Buffer]"
                    elseif entry.source.name == "nvim_lsp" then
                        vim_item.menu = '{' .. entry.source.source.client.name .. '}'
                    else
                        vim_item.menu = '[' .. entry.source.name .. ']'
                    end

                    return vim_item
                end
                --[[
                format = lspkind.cmp_format({
                    mode = 'symbol_text', -- show only symbol annotations
                    menu = ({
                        buffer = "[Buffer]",
                        nvim_lsp = "[LSP]",
                        luasnip = "[LuaSnip]",
                        nvim_lua = "[Lua]",
                        latex_symbols = "[Latex]",
                    })
                })]]
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end
            },
            sources = ({
                -- { name = 'nuspell' },
                { name = 'buffer' },
                { name = 'dictionary' },
                { name = 'luasnip' },
                { name = 'nvim_insert_text_lsp' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'nvim_lua' },
                { name = 'path' },
                { name = 'spell' }
            })
        })
        end
    }
    use 'dmitmel/cmp-cmdline-history'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lsp-document-symbol'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-path'
    use 'uga-rosa/cmp-dictionary'
    -- use {
    --     'f3fora/cmp-nuspell',
    --     rocks = { 'lua-nuspell' }
    -- }
    use 'f3fora/cmp-spell'
    -- TODO: https://github.com/jameshiew/nvim-magic
    -- TODO: https://github.com/kristijanhusak/vim-dadbod-completion
    -- TODO: https://github.com/lukas-reineke/cmp-rg
    -- TODO: https://github.com/lukas-reineke/cmp-under-comparator
    -- TODO: https://github.com/rcarriga/cmp-dap
    -- TODO: https://github.com/tzachar/cmp-fuzzy-buffer
    -- TODO: https://github.com/tzachar/cmp-fuzzy-path
    -- TODO: https://github.com/zbirenbaum/copilot-cmp

    -- Configuration:
    -- ``````````````
    -- {{{
    -- TODO: https://github.com/Abstract-IDE/Abstract
    -- TODO: https://github.com/AstroNvim/AstroNvim
    -- TODO: https://github.com/Avimitin/nvim
    -- TODO: https://github.com/CanKolay3499/CNvim
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

    -- Debugger:
    -- `````````
    -- TODO: https://github.com/Weissle/persistent-breakpoints.nvim
    use 'Pocco81/dap-buddy.nvim'
    use 'mfussenegger/nvim-dap'
    use 'mfussenegger/nvim-dap-python'
    -- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
    -- TODO: https://github.com/puremourning/vimspector
    use 'rcarriga/nvim-dap-ui'
    -- TODO: https://github.com/sakhnik/nvim-gdb
    -- TODO: https://github.com/theHamsta/nvim-dap-virtual-text
    -- TODO: https://github.com/vim-scripts/Conque-GDB

    -- Doc Generater:
    -- ``````````````
    use {
        "danymat/neogen",
        config = function()
            require('neogen').setup {}
        end
    }
    -- TODO: https://github.com/kkoomen/vim-doge
    -- TODO: https://github.com/nvim-treesitter/nvim-tree-docs

    -- ──────────────────── File Explorer ────────────────────
    -- {{{
    use {
        'elihunter173/dirbuf.nvim',
        cmd = 'Dirbuf'
    }
    use {
        "mrbjarksen/neo-tree-diagnostics.nvim",
        requires = "nvim-neo-tree/neo-tree.nvim",
        module = "neo-tree.sources.diagnostics", -- if wanting to lazyload
    }
    use {
        'nvim-neo-tree/neo-tree.nvim',
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    hijack_netrw_behavior = "open_current"
                }
            })
        end,
        -- cmd = "Neotree"
    }
    -- }}}

    -- ──────────────────── Folding ────────────────────
    -- {{{
    use {
        'anuvyklack/pretty-fold.nvim',
        config = function()
            require('pretty-fold').setup()
        end
    }
    use 'anuvyklack/keymap-amend.nvim'
    use {
        'anuvyklack/fold-preview.nvim',
        requires = 'anuvyklack/keymap-amend.nvim',
        config = function()
            require('fold-preview').setup()
        end
    }
    --}}}

    -- Formatting:
    -- ```````````
    -- use 'mhartington/formatter.nvim'
    -- TODO: https://github.com/sbdchd/neoformat

    -- FZF:
    -- ````
    -- TODO: https://github.com/ibhagwan/fzf-lua
    -- TODO: https://github.com/junegunn/fzf
    -- TODO: https://github.com/junegunn/fzf.vim
    -- TODO: https://github.com/ojroques/nvim-lspfuzzy

    -- ──────────────────── Git ────────────────────
    -- {{{
    use {
        'APZelos/blamer.nvim',
        cmd = 'BlamerToggle',
        config = function()
            vim.g.blamer_delay = 100
            vim.g.blamer_relative_time = 1
            vim.g.blamer_prefix = '  '
        end
    }
    use {
        'TimUntersberger/neogit',
        cmd = 'Neogit',
        config = function()
            require('neogit').setup()
        end
    }
    -- TODO: https://github.com/hotwatermorning/auto-git-diff
    use 'ldelossa/gh.nvim'
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }
    use {
        'pwntester/octo.nvim',
        cmd = 'Octo',
        config = function()
            require('octo').setup()
        end
    }
    use 'rhysd/conflict-marker.vim'
    use {
        'rhysd/git-messenger.vim',
        cmd = 'GitMessenger'
    }
    use {
        'ruifm/gitlinker.nvim',
        config = function()
            require('gitlinker').setup()
        end
    }
    use {
        'sindrets/diffview.nvim',
        cmd = 'DiffviewOpen',
        requires = 'nvim-lua/plenary.nvim'
    }
    use {
        'tanvirtin/vgit.nvim',
        requires = 'nvim-lua/plenary.nvim'
    }
    use {
        'whiteinge/diffconflicts',
        cmd = 'DiffConflicts'
    }
    -- }}}

    -- ──────────────────── Icons ────────────────────
    -- {{{
    use 'kyazdani42/nvim-web-devicons'
    -- }}}

    -- ──────────────────── Indentation ────────────────────
    -- {{{
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require("indent_blankline").setup({
                --[[ show_current_context = true,
                show_current_context_start = true, ]]
            })
        end
    }
    -- }}}

    -- Lint:
    -- `````
    -- TODO: https://github.com/mfussenegger/nvim-lint

    -- LSP:
    -- ````
    -- {{{
    use {
        'Kasama/nvim-custom-diagnostic-highlight',
        config = function()
            require('nvim-custom-diagnostic-highlight').setup {}
        end
    }
    use {
        'neovim/nvim-lspconfig' -- {
        --   TODO: diagnostics
        --   TODO: Autocompletion
        --   TODO: Code Actions
        --   TODO: Linitng
        --   TODO: Snippets
        --   TODO: UI Customization
    }
    --use {
    --    'williamboman/nvim-lsp-installer',
    --    config = function()
    --        require("nvim-lsp-installer").setup()
    --    end
    --} -- replaced by mason.nvim
    use { "williamboman/mason.nvim" }
    use { "williamboman/mason-lspconfig.nvim" }
    use 'liuchengxu/vista.vim' -- {
    --     " TODO: explore options
    -- }
    use {
        'ray-x/lsp_signature.nvim',
        config = function()
            require "lsp_signature".setup()
        end
        -- {
        --     " TODO: explore options
        -- }
    }
    -- use {
    --     'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    --     as = 'lsp_lines',
    --     config = function()
    --         require("lsp_lines").setup()
    --         --require("lsp_lines").register_lsp_virtual_lines()
    --         vim.diagnostic.config({
    --             virtual_text = false,
    --         })
    --         vim.diagnostic.config({ virtual_lines = { prefix = "🔥" } })
    --     end
    -- }
    -- use 'RishabhRD/nvim-lsputils' " BUG: problem in popfix
    use {
        "amrbashir/nvim-docs-view",
        -- cmd = { "DocsViewToggle" },
        config = function()
            require("docs-view").setup {
                position = "right",
                width = 60,
            }
        end
    }
    use 'folke/lsp-colors.nvim'
    -- TODO: https://github.com/gfanto/fzf-lsp.nvim
    use({
        "glepnir/lspsaga.nvim",
        branch = "main",
        config = function()
            local saga = require("lspsaga")

            saga.init_lsp_saga({
                -- your configuration
            })
        end,
    })
    use {
        'j-hui/fidget.nvim',
        config = function()
            require("fidget").setup()
        end
    }
    use {
        'jose-elias-alvarez/null-ls.nvim',
        config = function()
            require("null-ls").setup({
                sources = {
                    require("null-ls").builtins.formatting.stylua,
                    require("null-ls").builtins.diagnostics.eslint,
                    require("null-ls").builtins.completion.spell,
                },
            })
        end
    }
    use 'jubnzv/virtual-types.nvim'
    use {
        'kosayoda/nvim-lightbulb',
        requires = 'antoinemadec/FixCursorHold.nvim'
    }
    use 'Decodetalkers/csharpls-extended-lsp.nvim'
    use 'Hoffs/omnisharp-extended-lsp.nvim'
    use {
        'andrewferrier/textobj-diagnostic.nvim',
        config = function()
            require("textobj-diagnostic").setup()
        end
    }
    -- TODO: https://github.com/anuvyklack/hydra.nvim
    use 'filipdutescu/renamer.nvim'
    use 'jayp0521/mason-null-ls.nvim'
    use 'kwkarlwang/cmp-nvim-insert-text-lsp'
    use 'ldelossa/litee-bookmarks.nvim'
    use 'ldelossa/litee-calltree.nvim'
    use 'ldelossa/litee.nvim'
    use 'lukas-reineke/format.nvim'
    use 'nanotee/nvim-lsp-basics'
    use 'nvim-lua/lsp-status.nvim'
    -- TODO: https://github.com/ojroques/nvim-lspfuzzy
    use 'onsails/diaglist.nvim'
    use 'p00f/clangd_extensions.nvim'
    use 'razzmatazz/csharp-language-server'
    use {
        'onsails/lspkind.nvim'
    }
    -- TODO: https://github.com/ray-x/navigator.lua
    use {
        'rmagatti/goto-preview',
        config = function()
            require('goto-preview').setup {}
        end
    }
    use {
        'simrat39/symbols-outline.nvim',
        config = function()
            require("symbols-outline").setup()
        end
    }
    --use {
    --    "smjonas/inc-rename.nvim",
    --    config = function()
    --        require("inc_rename").setup()
    --    end,
    --}
    -- use {
    --     'stevearc/aerial.nvim',
    --     config = function()
    --         require('aerial').setup({})
    --     end
    -- }
    use 'tami5/lspsaga.nvim'
    -- TODO: https://github.com/weilbith/nvim-code-action-menu
    -- }}}

    -- Lua:
    -- ````
    -- TODO: https://github.com/bfredl/nvim-luadev
    -- TODO: https://github.com/folke/lua-dev.nvim
    -- TODO: https://github.com/jbyuki/one-small-step-for-vimkind
    -- TODO: https://github.com/milisims/nvim-luaref
    -- TODO: https://github.com/nanotee/nvim-lua-guide
    -- TODO: https://github.com/rafcamlet/nvim-luapad
    -- TODO: https://github.com/tjdevries/nlua.nvim

    -- Mapping:
    -- ````````
    -- {{{
    use {
        'folke/which-key.nvim',
        config = function()
            require("which-key").setup()
        end
    }
    -- TODO: https://github.com/FeiyouG/command_center.nvim
    -- TODO: https://github.com/LionC/nest.nvim
    -- TODO: https://github.com/b0o/mapx.nvim
    -- TODO: https://github.com/svermeulen/vimpeccable
    -- }}}

    -- Markdown:
    -- `````````
    use {
        'AckslD/nvim-FeMaco.lua',
        config = 'require("femaco").setup()',
    }
    -- TODO: https://github.com/frabjous/knap
    use 'davidgranstrom/nvim-markdown-preview'

    -- Marks:
    -- ``````
    -- {{{
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
    use 'MattesGroeger/vim-bookmarks'
    -- TODO: https://github.com/ThePrimeagen/harpoon
    -- TODO: https://github.com/Yilin-Yang/vim-markbar
    use 'kshenoy/vim-signature'
    -- use 'chentoast/marks.nvim'
    -- TODO: https://github.com/crusj/bookmarks.nvim
    -- }}}

    -- OrgMode:
    -- ````````
    -- {{{
    -- TODO: https://github.com/TravonteD/org-capture-filetype
    -- TODO: https://github.com/akinsho/org-bullets.nvim
    use {
        'nvim-neorg/neorg',
        config = function()
            require('nvim-treesitter.configs').setup {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                }
            }
            require('neorg').setup {
                ["core.norg.concealer"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                    -- Configuration here
                }
            }
            }
        end
    }
    -- use 'nvim-orgmode/orgmode'
    -- TODO: https://github.com/ranjithshegde/orgWiki.nvim
    -- TODO: https://github.com/lukas-reineke/headlines.nvim
    -- }}}

    -- Project:
    -- ````````
    -- {{{
    -- TODO: https://github.com/ahmedkhalf/project.nvim
    -- TODO: https://github.com/charludo/projectmgr.nvim
    -- TODO: https://github.com/rmagatti/auto-session
    -- TODO: https://github.com/romainchapou/confiture.nvim
    -- TODO: https://github.com/smolovk/projector.nvim
    -- TODO: https://github.com/thaerkh/vim-workspace
    -- }}}

    -- Quickfix:
    -- `````````
    -- {{{
    use 'kevinhwang91/nvim-bqf'
    use {
        'stevearc/qf_helper.nvim',
        config = function()
            require'qf_helper'.setup()
        end
    }
    -- }}}

    -- REPL:
    -- `````
    -- {{{
    -- TODO: https://github.com/jpalardy/vim-slime
    -- TODO: https://github.com/sillybun/vim-repl
    -- TODO: https://github.com/urbainvaes/vim-ripple
    -- }}}

    -- Rooter:
    -- ```````
    -- {{{
    -- TODO: https://github.com/nyngwang/NeoRoot.lua
    -- }}}

    -- Session Manager:
    -- ````````````````
    -- {{{
    -- TODO: https://github.com/Shatur/neovim-session-manager
    -- TODO: https://github.com/olimorris/persisted.nvim
    -- TODO: https://github.com/rmagatti/auto-session
    -- TODO: https://github.com/jedrzejboczar/possession.nvim
    -- }}}

    -- Snippets:
    -- `````````
    -- {{{
    use {
        'L3MON4D3/LuaSnip',
    }
    use {
        'saadparwaiz1/cmp_luasnip'
    }
    -- TODO: https://github.com/dcampos/nvim-snippy
    -- TODO: https://github.com/ellisonleao/carbon-now.nvim
    -- TODO: https://github.com/hrsh7th/vim-vsnip
    -- TODO: https://github.com/norcalli/snippets.nvim
    -- TODO: https://github.com/quangnguyen30192/cmp-nvim-ultisnips
    -- TODO: https://github.com/rafamadriz/friendly-snippets
    -- TODO: https://github.com/saadparwaiz1/cmp_luasnip
    -- TODO: https://github.com/smjonas/snippet-converter.nvim
    -- }}}

    -- Status Line:
    -- ````````````
    -- {{{
    -- use {
    --     'datwaft/bubbly.nvim', -- BUG: error in branch tag
    --     config = function()
    --     end
    -- }
    -- TODO: https://github.com/itchyny/lightline.vim
    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup()
        end,
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    -- TODO: https://github.com/rebelot/heirline.nvim
    -- }}}

    -- Tab Line:
    -- `````````
    --[[ use {
        'akinsho/bufferline.nvim',
        config = function()
            require("bufferline").setup {
                options = {
                    mode = "tabs",
                    diagnostics = "nvim_lsp",
                    separator_style = "thick",
                    always_show_bufferline = false
                }
            }
        end
    } ]]
    -- use 'mengelbrecht/lightline-bufferline'
    use 'nanozuki/tabby.nvim'

    -- ──────────────────── Tables ────────────────────
    -- {{{
    use {
        'dhruvasagar/vim-table-mode',
        cmd = 'TableModeEnable'
    }
    use 'godlygeek/tabular'
    -- }}}

    -- ──────────────────── Telescope ────────────────────
    -- {{{
    use 'nvim-telescope/telescope.nvim'
    use {
        'LinArcX/telescope-command-palette.nvim',
        config = function()
            require('telescope').load_extension('command_palette')
        end
    }
    use 'axkirillov/easypick.nvim'
    use 'camspiers/snap'
    use {
        'crispgm/telescope-heading.nvim',
        config = function()
            require('telescope').load_extension('heading')
        end
    }
    use {
        'nvim-telescope/telescope-packer.nvim',
        config = function()
            require("telescope").load_extension('packer')
        end
    }
    --[[ use {
        'ptethng/telescope-makefile',
        config = function()
            require'telescope'.load_extension('make')
        end
    } ]]
    -- }}}

    -- Terminal:
    -- `````````
    -- {{{
    use {
        "akinsho/toggleterm.nvim",
        tag = '*',
        config = function()
            require("toggleterm").setup()
        end
    }
    -- TODO: https://github.com/jlesquembre/nterm.nvim
    -- TODO: https://github.com/kassio/neoterm
    -- TODO: https://github.com/nikvdp/neomux
    -- TODO: https://github.com/numToStr/FTerm.nvim
    -- TODO: https://github.com/oberblastmeister/termwrapper.nvim
    -- TODO: https://github.com/pianocomposer321/consolation.nvim
    -- TODO: https://github.com/s1n7ax/nvim-terminal
    -- TODO: https://github.com/voldikss/vim-floaterm
    -- }}}

    -- Test & Run:
    -- `````
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


    -- ──────────────────── Todo Marker ────────────────────
    -- {{{
     use {
         'folke/todo-comments.nvim',
         config = function()
             require("todo-comments").setup({
                 keywords = {
                     THOUGHT = { icon = "🤔", color = "info"}
                 }
             })
         end
        -- TODO: Quickfix
        -- TODO: Search
        -- TODO: Telescope
        -- TODO: Trouble
     }
    -- }}}

    -- Treesitter:
    -- ```````````
    -- {{{
    use {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require('nvim-treesitter.configs').setup {
                auto_install = true,
                endwise = {
                    enable = true,
                },
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
    use {
        'm-demare/hlargs.nvim', -- NOTE: may not be required
        config = function()
            require('hlargs').setup()
        end
    }
    -- use 'nvim-treesitter/nvim-treesitter-context' -- FIXME: conflicts with context.vim
    use {
        'RRethy/nvim-treesitter-endwise',
        config = function()
            require('nvim-treesitter.configs').setup {
                endwise = {
                    enable = true,
                },
            }
        end
    }
    use {
        'lewis6991/spellsitter.nvim',
        config = function()
            require('spellsitter').setup()
        end
    }
    use {
        'nvim-treesitter/nvim-treesitter-refactor',
        config = function()
            require'nvim-treesitter.configs'.setup {
                refactor = {
                    highlight_definitions = {
                        enable = true,
                        -- Set to false if you have an `updatetime` of ~100.
                        clear_on_cursor_move = true,
                    },
                },
            }
        end
    }
    use 'nvim-treesitter/playground'
    use 'p00f/nvim-ts-rainbow'
    -- }}}

    -- ──────────────────── TUI ────────────────────
    -- {{{
    use 'rcarriga/nvim-notify'
    use 'skywind3000/vim-quickui'
    use 'stevearc/dressing.nvim'
    use {
        "vigoux/notifier.nvim",
        config = function()
            require'notifier'.setup {
                -- You configuration here
            }
        end
    }
    -- }}}

    -- Utilities:
    -- ``````````
    use '0x100101/lab.nvim'
    use 'AndrewRadev/inline_edit.vim'
    use 'NTBBloodbath/rest.nvim'
    use 'MunifTanjim/nui.nvim'
    use {
        'RishabhRD/nvim-cheat.sh',
        'RishabhRD/popfix'
    }
    use 'SmiteshP/nvim-navic'
    use 'ThePrimeagen/refactoring.nvim'
    use {
        'andrewferrier/debugprint.nvim',
        config = function()
            require("debugprint").setup()
        end
    }
    use 'andymass/vim-matchup'
    use 'booperlv/nvim-gomove'
    use 'chipsenkbeil/distant.nvim'
    use 'chrisbra/NrrwRgn'
    use 'cuducos/yaml.nvim'
    use 'doums/suit.nvim'
    use 'esensar/nvim-dev-container'
    use 'folke/trouble.nvim'
    use {
        'gaoDean/autolist.nvim',
        config = function()
            require('autolist').setup()
        end
    }
    use {
        'gen740/SmoothCursor.nvim',
        config = function()
            require('smoothcursor').setup({
                autostart = true,
                cursor = "",             -- cursor shape (need nerd font)
                intervals = 35,           -- tick interval
                linehl = nil,             -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
                type = "default",         -- define cursor movement calculate function, "default" or "exp" (exponential).
                fancy = {
                    enable = true,       -- enable fancy mode
                    head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
                    body = {
                        { cursor = "", texthl = "SmoothCursorRed" },
                        { cursor = "", texthl = "SmoothCursorOrange" },
                        { cursor = "●", texthl = "SmoothCursorYellow" },
                        { cursor = "●", texthl = "SmoothCursorGreen" },
                        { cursor = "•", texthl = "SmoothCursorAqua" },
                        { cursor = ".", texthl = "SmoothCursorBlue" },
                        { cursor = ".", texthl = "SmoothCursorPurple" },
                    },
                    tail = { cursor = nil, texthl = "SmoothCursor" }
                },
                priority = 10,           -- set marker priority
                speed = 25,               -- max is 100 to stick to your current position
                texthl = "SmoothCursor",  -- highlight group, default is { bg = nil, fg = "#FFD400" }
                threshold = 3,
                timeout = 3000,
            })
        end
    }
    use {
        'glacambre/firenvim',
        run = function()
            vim.fn['firenvim#install'](0)
        end
    }
    use 'haringsrob/nvim_context_vt'
    use 'jamestthompson3/nvim-remote-containers'
    use 'jbyuki/instant.nvim'
    use 'jbyuki/venn.nvim'
    use 'junegunn/vim-easy-align'
    use 'kevinhwang91/nvim-hlslens'
    use {
        'kevinhwang91/nvim-ufo',
        'kevinhwang91/promise-async'
    }
    use 'krady21/compiler-explorer.nvim'
    use 'kylechui/nvim-surround'
    -- TODO: https://github.com/lifepillar/vim-colortemplate
    use 'linty-org/key-menu.nvim'
    -- TODO: https://github.com/linty-org/readline.nvim
    use 'lewis6991/impatient.nvim'
    use 'mg979/vim-visual-multi'
    use 'miversen33/import.nvim'
    use 'mrjones2014/legendary.nvim'
    use {
        'nacro90/numb.nvim',
        config = function()
            require('numb').setup()
        end
    }
    use 'ojroques/vim-oscyank'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'p00f/godbolt.nvim'
    use 'paretje/nvim-man'
    use 'pechorin/any-jump.vim'
    use {
        'phaazon/mind.nvim',
        branch = 'v2.2',
        config = function()
            require'mind'.setup()
        end
    }
    use 'pocco81/abbrevman.nvim'
    use 'rickhowe/spotdiff.vim'
    use 'rktjmp/lush.nvim'
    use 'sidebar-nvim/sidebar.nvim'
    use 'simnalamburt/vim-mundo'
    use 'sindrets/winshift.nvim'
    use 'tpope/vim-surround'
    use {
        'tversteeg/registers.nvim',
        config = function()
            vim.cmd[[let g:registers_window_border = "rounded"]]
        end
    }
    use 'wellle/context.vim'
end
})

-- DAP
-- ```
--local dap = require('dap')
--dap.adapters.python = {
--    type = 'executable';
--    command = 'C:\\Users\\aloknigam\\AppData\\Local\\Programs\\Python\\Python310\\python.exe';
--}
--dap.configurations.python = {
--    {
--        type = 'python';
--        request = 'launch';
--        name = "Launch file";
--        program = "${file}";
--        pythonPath = 'C:\\Users\\aloknigam\\AppData\\Local\\Programs\\Python\\Python310\\python.exe';
--    }
--}

-- require('dap-python').setup('C:\\Users\\aloknigam\\learn\\python\\.virtualenvs\\debugpy\\Scripts\\python')
-- require('dap').set_log_level('TRACE')

-- LSP
-- ```
local on_attach = function(client, bufnr)
    -- vim-illuminate
    -- require 'illuminate'.on_attach(_)

    -- require("aerial").on_attach(client, bufnr)
    require'virtualtypes'.on_attach()
    require("nvim-navic").attach(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
        vim.inspect(vim.lsp.buf.list_workspace_folders())
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_insert_text_lsp').update_capabilities(capabilities)

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
    function (server_name)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities
        }
    end
}

-- Show source in diagnostics
vim.diagnostic.config({
    virtual_text = {
        source = "always",  -- Or "if_many"
    },
    float = {
        source = "always",  -- Or "if_many"
    },
})

-- Change diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Highlight line number instead of having icons in sign column
vim.cmd [[
highlight! DiagnosticLineNrError guibg=#E94B3C guifg=#2D2926 gui=bold
highlight! DiagnosticLineNrWarn guibg=#D6ED17 guifg=#606060 gui=bold
highlight! DiagnosticLineNrInfo guibg=#FEE715 guifg=#101820 gui=bold
highlight! DiagnosticLineNrHint guibg=#9CC3D5 guifg=#0063B2 gui=bold

sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]

-- Auto-Initialize serves
-- NOTE: not needed after mason
-- local lspconfig = require 'lspconfig'

--local servers = require'nvim-lsp-installer.servers'.get_installed_server_names()
--for _, lsp in ipairs(servers) do
--    print(lsp)
--    lspconfig[lsp].setup {
--        on_attach = on_attach,
--        capabilities = capabilities,
--    }
--end

-- require('fine-cmdline').setup({
--     popup = {
--         win_options = {
--             winhighlight = "Normal:Normal,FloatBorder:SpecialChar"
--         }
--     }
-- })
-- vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
vim.g.bubbly_palette = {
    background = "#34343c",
    foreground = "#c5cdd9",
    black = "#3e4249",
    red = "#ec7279",
    green = "#a0c980",
    yellow = "#deb974",
    blue = "#6cb6eb",
    purple = "#d38aea",
    cyan = "#5dbbc1",
    white = "#c5cdd9",
    lightgrey = "#57595e",
    darkgrey = "#404247"
}

vim.g.bubbly_statusline = {
    'mode',
    'truncate',
    'path',
    --  'branch', -- creates a $null file
    'signify',
    'gitsigns',
    'divisor',
    'filetype',
    'progress'
}

vim.g.bubbly_symbols = {
    default = 'PANIC!',

    path = {
        readonly = '',
        unmodifiable = '',
        modified = '+',
    },
    signify = {
        added = '+%s', -- requires 1 '%s'
        modified = '~%s', -- requires 1 '%s'
        removed = '-%s', -- requires 1 '%s'
    },
    gitsigns = {
        added = '+%s', -- requires 1 '%s'
        modified = '~%s', -- requires 1 '%s'
        removed = '-%s', -- requires 1 '%s'
    },
    coc = {
        error = ' %s', -- requires 1 '%s'
        warning = ' %s', -- requires 1 '%s'
    },
    builtinlsp = {
        diagnostic_count = {
            error = ' %s', -- requires 1 '%s'
            warning = ' %s', --requires 1 '%s'
        },
    },
    branch = ' %s', -- requires 1 '%s'
    total_buffer_number = '﬘ %s', --requires 1 '%d'
    lsp_status = {
        diagnostics = {
            error = ' %d',
            warning = ' %d',
            hint = ' %d',
            info = ' %d',
        },
    },
}

vim.g.bubbly_tags = {
    default = 'HELP ME PLEASE!',

    mode = {
        normal = 'NORMAL',
        insert = 'INSERT',
        visual = 'VISUAL',
        visualblock = 'VISUAL-B',
        command = 'COMMAND',
        terminal = 'TERMINAL',
        replace = 'REPLACE',
        default = 'UNKOWN',
    },
    paste = 'PASTE',
    filetype = {
        conf = ' config',
        config = ' config',
        css = ' css',
        diff = '繁 diff',
        dockerfile = ' docker',
        email = ' mail',
        gitconfig = ' git config',
        html = ' html',
        javascript = ' javascript',
        javascriptreact = ' javascript',
        json = ' json',
        less = ' less',
        lua = ' lua',
        mail = ' mail',
        make = ' make',
        markdown = ' markdown',
        noft = '<none>',
        norg = '🦄 norg',
        php = ' php',
        plain = ' text',
        plaintext = ' text',
        ps1 = ' powershell',
        python = ' python',
        sass = ' sass',
        scss = ' scss',
        text = ' text',
        typescript = ' typescript',
        typescriptreact = ' typescript',
        vim = ' vim',
        xml = '謹 xml',
    },
}

vim.g.bubbly_colors = {
    default = 'red',

    mode = {
        normal = 'green', -- uses by default 'background' as the foreground color.
        insert = 'blue',
        visual = 'red',
        visualblock = 'red',
        command = 'red',
        terminal = 'blue',
        replace = 'yellow',
        default = 'white'
    },
    path = {
        readonly = { background = 'lightgrey', foreground = 'foreground' },
        unmodifiable = { background = 'darkgrey', foreground = 'foreground' },
        path = 'white',
        modified = { background = 'lightgrey', foreground = 'foreground' },
    },
    branch = 'purple',
    signify = {
        added = 'green',
        modified = 'blue',
        removed = 'red',
    },
    gitsigns = {
        added = 'green',
        modified = 'blue',
        removed = 'red',
    },
    paste = 'red',
    coc = {
        error = 'red',
        warning = 'yellow',
        status = { background = 'lightgrey', foreground = 'foreground' },
    },
    builtinlsp = {
        diagnostic_count = {
            error = 'red',
            warning = 'yellow',
        },
        current_function = 'purple',
    },
    filetype = 'blue',
    progress = {
        rowandcol = { background = 'lightgrey', foreground = 'foreground' },
        percentage = { background = 'darkgrey', foreground = 'foreground' },
    },
    tabline = {
        active = 'blue',
        inactive = 'white',
        close = 'darkgrey',
    },
    total_buffer_number = 'cyan',
    lsp_status = {
        messages = 'white',
        diagnostics = {
            error = 'red',
            warning = 'yellow',
            hint = 'white',
            info = 'blue',
        },
    },
}

vim.g.bubbly_inactive_color = { background = 'lightgrey', foreground = 'foreground' }

--[[ require("lspconfig").powershell_es.setup({
        bundle_path = vim.fn.stdpath("data") .. "\\mason\\packages\\powershell-editor-services\\",
        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\Start-EditorServices.ps1"}
    }) ]]
-- vim: fdm=marker
