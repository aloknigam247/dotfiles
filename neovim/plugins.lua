--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

ret = require('packer').startup({
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
            threshold = 0.1
        },
        autoremove = true
    },

    function()
    -- Packer:
    -- ```````
    use 'wbthomason/packer.nvim'

    -- Auto Pair:
    -- ``````````
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

    -- Cheatsheet:
    -- ```````````
    -- {{{
    use 'sudormrfbin/cheatsheet.nvim'
    -- }}}

    -- COC:
    -- ````
    -- {{{
    -- TODO: https://github.com/OmniSharp/omnisharp-vim
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
    -- use 'RRethy/vim-illuminate' -- {
        -- BUG: highlight colors are not good
        -- hi def link LspReferenceText WildMenu
        -- hi def link LspReferenceWrite WildMenu
        -- hi def link LspReferenceRead WildMenu
    -- }
    -- use 'lilydjwg/colorizer'
    use 'machakann/vim-highlightedyank'
    use 'azabiong/vim-highlighter' -- NOTE: Good to use
    -- use 'tribela/vim-transparent' -- Make theme transparent
    -- TODO: use 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' } " GO dependency
    --use {
    --    'xiyaowong/nvim-cursorword',
    --    config = function()
    --        require('nvim-cursorline').setup {
    --            cursorline = {
    --                enable = true,
    --                timeout = 1000,
    --                number = false,
    --            },
    --            cursorword = {
    --                enable = true,
    --                min_length = 3,
    --                hl = { underline = true },
    --            }
    --        }
    --    end
    --}
    use 'yamatsum/nvim-cursorline'
    use 'dominikduda/vim_current_word'
    -- use { 'm00qek/baleia.nvim', tag = 'v1.2.0' } -- [archived] termical color support in neovim
    -- use 'norcalli/nvim-terminal.lua' -- [archived] termical color support in neovim
    use 'norcalli/nvim-colorizer.lua'
    use 't9md/vim-quickhl'

    -- Colorscheme:
    -- ````````````
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
    -- use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
    -- use 'Mofiqul/adwaita.nvim'
    -- use 'NLKNguyen/papercolor-theme' -- BUG: space · color is not good
    -- use 'Th3Whit3Wolf/one-nvim'
    -- use 'ayu-theme/ayu-vim'
    -- use 'cpea2506/one_monokai.nvim'
    -- use 'fenetikm/falcon'
    -- use 'glepnir/zephyr-nvim'
    -- use 'kaiuri/nvim-juliana'
    -- use 'lmburns/kimbox'
    -- use 'marko-cerovac/material.nvim'
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
    -- use 'savq/melange'
    -- use 'shaunsingh/moonlight.nvim'
    -- use 'sickill/vim-monokai'
    -- use 'tanvirtin/monokai.nvim'
    -- use 'tiagovla/tokyodark.nvim'
    -- use 'titanzero/zephyrium'
    -- use 'tjdevries/colorbuddy.vim'
    -- use 'tjdevries/gruvbuddy.nvim'
    -- use 'tomasiser/vim-code-dark'
    -- use 'wuelnerdotexe/vim-enfocado'
    -- use 'yashguptaz/calvera-dark.nvim'
    
    -- use 'dylanaraps/wal.vim'
    -- use 'AlphaTechnolog/pywal.nvim'


    -- Commenting:
    -- ```````````
    -- use 'gennaro-tedesco/nvim-commaround' -- {
    --  TODO:
    --  Fix toggle mapping to VSCode one
    --  Add filetype for powershell
    --  BUG: Issue with -[[]]
    -- }
    use 'b3nj5m1n/kommentary' -- NOTE: Fixed --[[]] problem
    -- TODO: use 'numToStr/Comment.nvim'
    -- TODO: use 'terrortylor/nvim-comment'
    -- TODO: use 'winston0410/commented.nvim'
    -- TODO: https://github.com/JoosepAlviste/nvim-ts-context-commentstring
    -- TODO: https://github.com/gennaro-tedesco/nvim-commaround
    -- TODO: https://github.com/s1n7ax/nvim-comment-frame
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
            local lspkind = require('lspkind')
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
                { name = 'buffer' },
                { name = 'dictionary' },
                { name = 'luasnip' },
                -- { name = 'nuspell' },
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
    -- TODO: https://github.com/AstroNvim/AstroNvim
    -- TODO: https://github.com/Avimitin/nvim
    -- TODO: https://github.com/CanKolay3499/CNvim
    -- TODO: https://github.com/CosmicNvim/CosmicNvim
    -- TODO: https://github.com/JryChn/ModuleVim
    -- TODO: https://github.com/LunarVim/LunarVim
    -- TODO: https://github.com/NTBBloodbath/doom-nvim
    -- TODO: https://github.com/NvChad/NvChad
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
    use 'mfussenegger/nvim-dap'
    use 'Pocco81/dap-buddy.nvim'
    use 'mfussenegger/nvim-dap-python'
    use 'rcarriga/nvim-dap-ui'
    -- TODO: https://github.com/puremourning/vimspector
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

    -- File Explorer:
    -- ``````````````
    -- TODO: https://github.com/TimUntersberger/neofs
    -- TODO: https://github.com/elihunter173/dirbuf.nvim
    -- TODO: https://github.com/mrbjarksen/neo-tree-diagnostics.nvim
    use 'ms-jpq/chadtree'
    -- use {
    --     'nvim-neo-tree/neo-tree.nvim',
    --     config = function()
    --         require("neo-tree").setup({
    --             filesystem = {
    --                 hijack_netrw_behavior = "open_default",
    --                 -- "open_current",  
    --                 -- "disabled", 
    --             }
    --         })
    --     end
    --     --  BUG: fuzzy search does not seems to work
    --     --  good for fit status tree
    --     --  shows lsp warnings in tree
    --     --  good .gitignore support
    -- }
    -- TODO: https://github.com/nvim-neo-tree/neo-tree.nvim
    -- TODO: https://github.com/tamago324/lir.nvim

    -- Folding:
    -- ````````
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

    -- Git:
    -- ````
    -- {{{
    -- TODO: use 'f-person/git-blame.nvim' " not working, needs review
    use {
        'lewis6991/gitsigns.nvim', -- BUG: Conflicts with todo-comments
        config = function()
            require('gitsigns').setup()
        end
    }
    use 'ruifm/gitlinker.nvim' -- NOTE: Good plugin worth lazy loading
    use {
        'APZelos/blamer.nvim',
        config = function()
            vim.g.blamer_enabled = 1
            vim.g.blamer_delay = 100
            vim.g.blamer_relative_time = 1
            vim.g.blamer_prefix = '  '
        end
    }
    use 'mhinz/vim-signify'
    use {
        'TimUntersberger/neogit',
        config = function()
            require('neogit').setup()
        end
    }
    -- use 'sindrets/diffview.nvim'
    -- TODO: https://github.com/hotwatermorning/auto-git-diff
    use 'kdheepak/lazygit.nvim'
    -- TODO: https://github.com/ldelossa/gh.nvim
    use {
        'pwntester/octo.nvim',
        config = function()
            require('octo').setup()
        end
    }
    use 'rhysd/conflict-marker.vim'
    use {
        'rhysd/git-messenger.vim'
        -- TODO: explore options
    }
    -- TODO: https://github.com/sjl/splice.vim
    -- TODO: https://github.com/tanvirtin/vgit.nvim
    -- TODO: https://github.com/tommcdo/vim-fugitive-blame-ext
    -- TODO: https://github.com/tpope/vim-fugitive
    -- TODO: https://github.com/whiteinge/diffconflicts
    -- }}}

    -- Icons:
    -- ``````
    -- {{{
    use 'kyazdani42/nvim-web-devicons'
    -- use 'yamatsum/nvim-nonicons'
    -- TODO: https://github.com/kristijanhusak/defx-icons
    -- }}}

    -- Indentation:
    -- ````````````
    -- {{{
    -- use 'glepnir/indent-guides.nvim'
    --[[
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require("indent_blankline").setup()
        end
    }
    ]]
    -- }}}

    -- LSP:
    -- ````
    -- {{{
    use {
        'neovim/nvim-lspconfig' -- {
        --   TODO: diagnostics
        --   TODO: Autocompletion
        --   TODO: Code Actions
        --   TODO: Linitng
        --   TODO: use 'filipdutescu/renamer.nvim', { 'branch': 'master' }
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
    -- TODO: https://github.com/glepnir/lspsaga.nvim
    use {
        'j-hui/fidget.nvim',
        config = function()
            require("fidget").setup()
        end
    }
    -- TODO: https://github.com/jose-elias-alvarez/null-ls.nvim
    use 'jubnzv/virtual-types.nvim'
    use {
        'kosayoda/nvim-lightbulb',
        requires = 'antoinemadec/FixCursorHold.nvim'
    }
    -- TODO: https://github.com/kwkarlwang/cmp-nvim-insert-text-lsp
    -- TODO: https://github.com/ldelossa/litee-bookmarks.nvim
    -- TODO: https://github.com/ldelossa/litee-calltree.nvim
    -- TODO: https://github.com/ldelossa/litee.nvim
    -- TODO: https://github.com/lukas-reineke/format.nvim
    -- TODO: https://github.com/mfussenegger/nvim-lint
    -- TODO: https://github.com/nanotee/nvim-lsp-basics
    -- TODO: https://github.com/nvim-lua/lsp-status.nvim
    -- TODO: https://github.com/ojroques/nvim-lspfuzzy
    -- TODO: https://github.com/onsails/diaglist.nvim
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
    -- TODO: https://github.com/AckslD/nvim-FeMaco.lua
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
    -- use 'MattesGroeger/vim-bookmarks'
    -- TODO: https://github.com/ThePrimeagen/harpoon
    -- TODO: https://github.com/Yilin-Yang/vim-markbar
    use 'kshenoy/vim-signature'
    -- use 'chentoast/marks.nvim'
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
    -- TODO: https://github.com/smolovk/projector.nvim
    -- TODO: https://github.com/thaerkh/vim-workspace
    -- }}}

    -- Quickfix:
    -- `````````
    -- {{{
    -- TODO: https://github.com/kevinhwang91/nvim-bqf
    -- TODO: https://github.com/stevearc/qf_helper.nvim
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
    -- TODO: https://github.com/shaeinst/penvim
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
    -- use 'beauwilliams/statusline.lua' -- {
-- local statusline = require('statusline')
-- statusline.tabline = false
    --     " BUG: Slowness observed
    --     " BUG: no mouse support in tabline
    --     " TODO: Explore more
    -- }
    -- use {
    --     'datwaft/bubbly.nvim', -- BUG: error in branch tag
    --     config = function()
    --     end
    -- }
    -- TODO: https://github.com/itchyny/lightline.vim
    -- TODO: https://github.com/nvim-lualine/lualine.nvim
    -- 'windwp/windline.nvim'
    -- }}}

    -- Tab Line:
    -- `````````
    use {
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
    }
    -- use 'mengelbrecht/lightline-bufferline'

    -- Tables:
    -- ```````
    use {
        'dhruvasagar/vim-table-mode',
        cmd = 'TableModeEnable'
    }
    -- TODO: https://github.com/godlygeek/tabular

    -- Telescope:
    -- ``````````
    -- {{{
    use 'nvim-telescope/telescope.nvim'
    -- TODO: https://github.com/LinArcX/telescope-command-palette.nvim
    -- TODO: https://github.com/axkirillov/easypick.nvim
    -- TODO: https://github.com/camspiers/snap
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
    -- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
    -- }}}

    -- Terminal:
    -- `````````
    -- {{{
    -- TODO: https://github.com/LoricAndre/OneTerm.nvim
    -- TODO: https://github.com/akinsho/toggleterm.nvim
    -- TODO: https://github.com/jlesquembre/nterm.nvim
    -- TODO: https://github.com/kassio/neoterm
    -- TODO: https://github.com/nikvdp/neomux
    -- TODO: https://github.com/nikvdp/neomux
    -- TODO: https://github.com/numToStr/FTerm.nvim
    -- TODO: https://github.com/oberblastmeister/termwrapper.nvim
    -- TODO: https://github.com/pianocomposer321/consolation.nvim
    -- TODO: https://github.com/s1n7ax/nvim-terminal
    -- TODO: https://github.com/voldikss/vim-floaterm
    -- }}}

    -- Test & Run:
    -- `````
    -- TODO: https://github.com/andythigpen/nvim-coverage
    -- TODO: https://github.com/jubnzv/mdeval.nvim
    -- TODO: https://github.com/klen/nvim-test
    -- TODO: https://github.com/michaelb/sniprun
    -- TODO: https://github.com/nvim-neotest/neotest
    -- TODO: https://github.com/pianocomposer321/yabs.nvim
    -- TODO: https://github.com/smzm/hydrovim

    -- Todo Marker:
    -- ````````````
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
        -- BUG: Can not handle multiple todos in same line
        -- BUG: Makes vim scrolling slow
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
    use 'nvim-treesitter/nvim-treesitter-context'
    use 'RRethy/nvim-treesitter-endwise'
    use {
        'lewis6991/spellsitter.nvim',
        config = function()
            require('spellsitter').setup()
        end
    }
    -- use {
    --     'nvim-treesitter/nvim-treesitter-refactor',
    --     config = function()
    --         require'nvim-treesitter.configs'.setup {
    --             refactor = {
    --                 highlight_definitions = {
    --                     enable = true,
    --                     -- Set to false if you have an `updatetime` of ~100.
    --                     clear_on_cursor_move = true,
    --                 },
    --             },
    --         }
    --     end
    -- }
    use 'nvim-treesitter/playground'
    use 'p00f/nvim-ts-rainbow'
    -- }}}

    -- TUI:
    -- ````
    -- {{{
    use 'rcarriga/nvim-notify'
    use 'skywind3000/vim-quickui'
    use 'stevearc/dressing.nvim'
    -- }}}

    -- Utilities:
    -- ``````````
    use '0x100101/lab.nvim'
    use 'AndrewRadev/inline_edit.vim'
    use 'NTBBloodbath/rest.nvim'
    use 'MunifTanjim/nui.nvim'
    use 'tversteeg/registers.nvim' -- Displays registers on ^R and " {
    --     let g:registers_window_border = "rounded"
    --     " TODO: Check if height can be reduced
    -- }
    use 'folke/trouble.nvim' -- NOTE: It should go in LSP
    use 'nacro90/numb.nvim' -- Peek number line while jumping TODO: functionality hidden
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'rktjmp/lush.nvim'

    use 'pocco81/abbrevman.nvim'
    use {
        'RishabhRD/nvim-cheat.sh',
        'RishabhRD/popfix'
    }
    use 'SmiteshP/nvim-navic'
    -- use 'andymass/vim-matchup'
    use 'booperlv/nvim-gomove'
    use 'chipsenkbeil/distant.nvim'
    use 'chrisbra/NrrwRgn'
    use 'doums/suit.nvim'
    use {
        'glacambre/firenvim',
        run = function()
            vim.fn['firenvim#install'](0)
        end 
    }
    -- TODO: https://github.com/haringsrob/nvim_context_vt " NOTE: Good but should be off by default
    -- TODO: https://github.com/is0n/jaq-nvim
    -- TODO: https://github.com/jakewvincent/mkdnflow.nvim
    -- TODO: https://github.com/jamestthompson3/nvim-remote-containers
    -- TODO: https://github.com/jbyuki/instant.nvim
    use 'jbyuki/venn.nvim'
    use 'junegunn/vim-easy-align'
    use 'kevinhwang91/nvim-hlslens'
    use {
        'kevinhwang91/nvim-ufo',
        'kevinhwang91/promise-async'
    }
    -- TODO: https://github.com/lifepillar/vim-colortemplate
    use 'lewis6991/impatient.nvim'
    use 'mg979/vim-visual-multi'
    use 'mrjones2014/legendary.nvim'
    -- use 'ojroques/vim-oscyank'
    use 'paretje/nvim-man'
    use 'pechorin/any-jump.vim'
    use 'rickhowe/spotdiff.vim'
    use 'sidebar-nvim/sidebar.nvim'
    use 'simnalamburt/vim-mundo'
    -- TODO: https://github.com/tpope/vim-surround
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
local lspconfig = require 'lspconfig'

local on_attach = function(client, bufnr)
    -- vim-illuminate
    -- require 'illuminate'.on_attach(_)

    -- require("aerial").on_attach(client, bufnr)
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

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
    function (server_name)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach,
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
highlight! DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
highlight! DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
highlight! DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
highlight! DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]

-- Auto-Initialize serves
-- NOTE: not needed after mason
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

-- vim: fdm=marker
