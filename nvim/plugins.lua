ret = require('packer').startup(function()
    -- packer manages itself
    use 'wbthomason/packer.nvim'

    -- Auto Pair:
    -- ``````````
    -- use 'windwp/nvim-autopairs' -- {
        -- TODO: Create custom rule to Expand multiple pairs on enter key, similar to vim-closer, already implemented in its wiki
        -- BUG: braces Indentation is not correct in some situation
        -- TODO: Create rule to not pair " for vim files
    -- }
    use {
        'ZhiyuanLck/smart-pairs',
        -- event = 'InsertEnter',
        config = function()
            require('pairs').setup()
        end
    }
    -- TODO: https://github.com/max-0406/autoclose.nvim
    -- TODO: https://github.com/rstacruz/vim-closer
    -- TODO: https://github.com/steelsojka/pears.nvim
    -- TODO: https://github.com/theHamsta/nvim-treesitter-pairs

    -- Cheatsheet:
    -- ```````````
    -- use 'sudormrfbin/cheatsheet.nvim'

    -- COC:
    -- ````
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

    -- Coloring:
    -- `````````
    use 'RRethy/vim-illuminate' -- {
    --     " BUG: highlight colors are not good
    --     hi def link LspReferenceText WildMenu
    --     hi def link LspReferenceWrite WildMenu
    --     hi def link LspReferenceRead WildMenu
    -- }
    use 'lilydjwg/colorizer'
    use 'machakann/vim-highlightedyank'
    -- use 'azabiong/vim-highlighter' -- NOTE: Good to use
    -- use 'tribela/vim-transparent' -- Make theme transparent
    -- TODO: use 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' } " GO dependency
    -- TODO: use 'xiyaowong/nvim-cursorword'
    -- TODO: use 'yamatsum/nvim-cursorline'
    -- TODO: https://github.com/dominikduda/vim_current_word
    -- TODO: https://github.com/lambdalisue/glyph-palette.vim
    -- TODO: https://github.com/m00qek/baleia.nvim
    -- TODO: https://github.com/norcalli/nvim-colorizer.lua
    -- TODO: https://github.com/norcalli/nvim-terminal.lua
    -- TODO: https://github.com/rktjmp/highlight-current-n.nvim
    -- TODO: https://github.com/t9md/vim-quickhl

    -- Colorscheme:
    -- ````````````
    -- |------------+-------+------|
    -- | Language   | Light | Dark |
    -- |------------+-------+------|
    -- | cpp        |       |      |
    -- | csharp     |       |      |
    -- | json       |       |      |
    -- | markdown   |       |      |
    -- | norg       |       |      |
    -- | powershell |       |      |
    -- | python     |       |      |
    -- | shell      |       |      |
    -- | vim        |       |      |
    -- | yaml       |       |      |
    -- |------------+-------+------|
    -- Current:
    -- << Light >>
    -- use 'ChrisKempson/Tomorrow-Theme'
    -- use 'EdenEast/nightfox.nvim'
    -- use 'NLKNguyen/papercolor-theme'
    -- use 'Th3Whit3Wolf/one-nvim'
    -- use 'Th3Whit3Wolf/onebuddy'
    -- use 'ayu-theme/ayu-vim'
    -- use 'catppuccin/nvim'
    -- use 'jsit/toast.vim'
    -- use 'marko-cerovac/material.nvim'
    -- use 'mcchrish/zenbones.nvim'
    -- use 'olimorris/onedarkpro.nvim'
    -- use 'projekt0n/github-nvim-theme'
    -- use 'rafamadriz/neon'
    -- use 'rmehri01/onenord.nvim'
    -- use 'rose-pine/neovim'
    -- use 'sainnhe/edge'
    -- use 'sainnhe/everforest'

    -- << Dark >>
    use 'EdenEast/nightfox.nvim' -- duskfox, nighfox, nordfox, terafox
    use 'NLKNguyen/papercolor-theme' -- TODO: space · color is not good
    use 'Th3Whit3Wolf/one-nvim'
    use 'ayu-theme/ayu-vim'
    use 'cpea2506/one_monokai.nvim'
    use 'fenetikm/falcon'
    use 'glepnir/zephyr-nvim'
    use 'jsit/toast.vim'
    use 'marko-cerovac/material.nvim'
    use 'mcchrish/zenbones.nvim'
    use 'mhartington/oceanic-next'
    use 'ntk148v/vim-horizon'
    use 'olimorris/onedarkpro.nvim'
    use 'projekt0n/github-nvim-theme'
    use 'rafalbromirski/vim-aurora'
    use 'rafamadriz/neon'
    use 'ray-x/aurora'
    use 'rebelot/kanagawa.nvim'
    use 'rmehri01/onenord.nvim'
    use 'rose-pine/neovim'
    use 'sainnhe/edge'
    use 'sainnhe/everforest'
    use 'sainnhe/sonokai'
    use 'savq/melange'
    use 'shaunsingh/moonlight.nvim'
    use 'sickill/vim-monokai'
    use 'tanvirtin/monokai.nvim'
    use 'tiagovla/tokyodark.nvim'
    use 'titanzero/zephyrium'
    use 'tjdevries/colorbuddy.vim'
    use 'tjdevries/gruvbuddy.nvim'
    use 'tomasiser/vim-code-dark'
    use 'wuelnerdotexe/vim-enfocado'
    use 'yashguptaz/calvera-dark.nvim'
    
    -- use 'dylanaraps/wal.vim'
    -- use 'AlphaTechnolog/pywal.nvim'


    -- Commenting:
    -- ```````````
    use 'gennaro-tedesco/nvim-commaround' -- {
    --  " TODO:
    --  " Fix toggle mapping to VSCode one
    --  " Add filetype for powershell
    -- }
    -- TODO: use 'b3nj5m1n/kommentary'
    -- TODO: use 'numToStr/Comment.nvim'
    -- TODO: use 'terrortylor/nvim-comment'
    -- TODO: use 'winston0410/commented.nvim'
    -- TODO: https://github.com/JoosepAlviste/nvim-ts-context-commentstring
    -- TODO: https://github.com/danymat/neogen
    -- TODO: https://github.com/gennaro-tedesco/nvim-commaround
    -- TODO: https://github.com/s1n7ax/nvim-comment-frame
    -- TODO: https://github.com/tpope/vim-commentary
    -- TODO: https://github.com/tyru/caw.vim
    -- TODO: https://github.com/winston0410/commented.nvim

    -- Completion:
    -- ```````````
    use {
        'hrsh7th/nvim-cmp',
        -- {
        --  " TODO: Commandline
        --  " TODO: Hover doc
        --  " TODO: LSP - explore
        --  " TODO: Menu UI Changes https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
        --  " TODO: Path
        --  " TODO: Snippets
        -- }
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = ({
                { name = 'buffer' },
                { name = 'nvim_lsp' }
            })
        })
        end
    }
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lsp'
    -- use 'hrsh7th/cmp-cmdline' " {
    --   BUG: / completion for buffer is not working
    --   TODO: Completion selection is not working
    -- }
    -- use 'dmitmel/cmp-cmdline-history' " {
    --   TODO: how to select completion
    -- }
    -- TODO: https://github.com/David-Kunz/cmp-npm
    -- TODO: https://github.com/PasiBergman/cmp-nuget
    -- TODO: https://github.com/Shougo/deoplete.nvim
    -- TODO: https://github.com/davidsierradz/cmp-conventionalcommits
    -- TODO: https://github.com/f3fora/cmp-nuspell
    -- TODO: https://github.com/f3fora/cmp-spell
    -- TODO: https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol
    -- TODO: https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
    -- TODO: https://github.com/hrsh7th/cmp-nvim-lua
    -- TODO: https://github.com/hrsh7th/cmp-path
    -- TODO: https://github.com/jameshiew/nvim-magic
    -- TODO: https://github.com/kristijanhusak/vim-dadbod-completion
    -- TODO: https://github.com/lukas-reineke/cmp-rg
    -- TODO: https://github.com/lukas-reineke/cmp-under-comparator
    -- TODO: https://github.com/meetcw/cmp-browser-source
    -- TODO: https://github.com/noib3/nvim-compleet
    -- TODO: https://github.com/nxvu699134/vn-night.nvim
    -- TODO: https://github.com/octaltree/cmp-look
    -- TODO: https://github.com/petertriho/cmp-git
    -- TODO: https://github.com/rambhosale/cmp-bootstrap.nvim
    -- TODO: https://github.com/ray-x/cmp-treesitter
    -- TODO: https://github.com/rcarriga/cmp-dap
    -- TODO: https://github.com/tzachar/cmp-fuzzy-buffer
    -- TODO: https://github.com/tzachar/cmp-fuzzy-path
    -- TODO: https://github.com/tzachar/cmp-tabnine
    -- TODO: https://github.com/uga-rosa/cmp-dictionary
    -- TODO: https://github.com/vappolinario/cmp-clippy
    -- TODO: https://github.com/zbirenbaum/copilot-cmp

    -- Configuration:
    -- ``````````````
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
    -- TODO: https://github.com/crivotz/nv-ide
    -- TODO: https://github.com/cstsunfu/.sea.nvim
    -- TODO: https://github.com/echasnovski/mini.nvim
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
    -- TODO: https://github.com/danymat/neogen
    -- TODO: https://github.com/kkoomen/vim-doge
    -- TODO: https://github.com/nvim-treesitter/nvim-tree-docs

    -- File Explorer:
    -- ``````````````
    use 'nvim-neo-tree/neo-tree.nvim' -- {
    --  BUG: Does not replace netrw
    --  BUG: fuzzy search does not seems to work
    --  good for fit status tree
    --  shows lsp warnings in tree
    --  goord .gitignore support
    -- }
    -- TODO: https://github.com/PhilRunninger/nerdtree-visual-selection
    -- TODO: https://github.com/TimUntersberger/neofs
    -- TODO: https://github.com/Xuyuanp/nerdtree-git-plugin
    -- TODO: https://github.com/Xuyuanp/yanil
    -- TODO: https://github.com/elihunter173/dirbuf.nvim
    -- TODO: https://github.com/is0n/fm-nvim
    -- TODO: https://github.com/kevinhwang91/rnvimr
    -- TODO: https://github.com/kyazdani42/nvim-tree.lua
    -- TODO: https://github.com/ms-jpq/chadtree
    -- TODO: https://github.com/nvim-neo-tree/neo-tree.nvim
    -- TODO: https://github.com/tamago324/lir.nvim
    -- TODO: https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
    -- TODO: https://github.com/vwxyutarooo/nerdtree-devicons-syntax

    -- Focus Mode:
    -- ```````````
    -- use 'Pocco81/TrueZen.nvim'
    use {
        'folke/twilight.nvim',
        config = function()
            require("twilight").setup()
        end
    }
    -- TODO: https://github.com/hoschi/yode-nvim
    -- TODO: https://github.com/junegunn/goyo.vim

    -- Folding:
    -- ````````
    -- TODO: use 'anuvyklack/nvim-keymap-amend'
    -- TODO: use 'anuvyklack/pretty-fold.nvim'
    -- TODO: https://github.com/anuvyklack/pretty-fold.nvim
    -- 
    -- Formatting:
    -- ```````````
    -- use 'mhartington/formatter.nvim'
    -- TODO: https://github.com/sbdchd/neoformat

    -- Git:
    -- ````
    -- {{{
    -- TODO: use 'f-person/git-blame.nvim' " not working, needs review
    -- TODO: use 'lewis6991/gitsigns.nvim' " BUG: Conflicts with todo-comments
    -- TODO: use 'ruifm/gitlinker.nvim' " NOTE: Good plugin worth lazy loading
    -- use 'APZelos/blamer.nvim' " {
    --     let g:blamer_enabled = 1
    --     let g:blamer_delay = 100
    --     let g:blamer_relative_time = 1
    --     let g:blamer_prefix = '  '
    -- }
    use 'mhinz/vim-signify'
    use {
        'TimUntersberger/neogit',
        config = function()
            require('neogit').setup()
        end
    }
    -- use 'sindrets/diffview.nvim'
    -- TODO: https://github.com/hotwatermorning/auto-git-diff
    -- TODO: https://github.com/kdheepak/lazygit.nvim
    -- TODO: https://github.com/ldelossa/gh.nvim
    -- TODO: https://github.com/pwntester/octo.nvim
    -- TODO: https://github.com/rhysd/conflict-marker.vim
    -- TODO: https://github.com/rhysd/git-messenger.vim
    -- TODO: https://github.com/sjl/splice.vim
    -- TODO: https://github.com/tanvirtin/vgit.nvim
    -- TODO: https://github.com/tommcdo/vim-fugitive-blame-ext
    -- TODO: https://github.com/tpope/vim-fugitive
    -- TODO: https://github.com/tveskag/nvim-blame-line
    -- TODO: https://github.com/whiteinge/diffconflicts
    -- }}}

    -- Icons:
    -- ``````
    -- {{{
    use 'kyazdani42/nvim-web-devicons'
    use 'yamatsum/nvim-nonicons'
    -- TODO: https://github.com/kristijanhusak/defx-icons
    -- }}}

    -- Indentation:
    -- ````````````
    -- {{{
    -- use 'glepnir/indent-guides.nvim'
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require("indent_blankline").setup()
        end
    }
    -- }}}

    -- LSP:
    -- ````
    -- {{{
    use 'neovim/nvim-lspconfig' -- {
    --   TODO: Autocompletion
    --   TODO: Code Actions
    --   TODO: Linitng
    --   TODO: use 'filipdutescu/renamer.nvim', { 'branch': 'master' }
    --   TODO: Snippets
    --   TODO: UI Customization
    -- }
    use {
        'williamboman/nvim-lsp-installer',
        config = function()
            require("nvim-lsp-installer").setup()
        end
    }
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
    -- use 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'
    -- use 'RishabhRD/nvim-lsputils' " BUG: problem in popfix
    -- TODO: https://github.com/amrbashir/nvim-docs-view
    -- use 'folke/lsp-colors.nvim'
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
    -- TODO: https://github.com/kosayoda/nvim-lightbulb
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
    -- TODO: https://github.com/onsails/lspkind.nvim
    -- TODO: https://github.com/ray-x/navigator.lua
    -- TODO: https://github.com/rmagatti/goto-preview
    -- TODO: https://github.com/simrat39/symbols-outline.nvim
    -- TODO: https://github.com/smjonas/inc-rename.nvim
    -- TODO: https://github.com/stevearc/aerial.nvim
    -- TODO: https://github.com/tami5/lspsaga.nvim
    -- TODO: https://github.com/weilbith/nvim-code-action-menu
    -- }}}
    -- 
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
    -- 
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
    -- TODO: https://github.com/kshenoy/vim-signature
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
        end
    }
    -- use 'nvim-orgmode/orgmode'
    -- TODO: https://github.com/ranjithshegde/orgWiki.nvim
    -- TODO: https://github.com/lukas-reineke/headlines.nvim
    -- }}}

    -- Project:
    -- ````````
    -- {{{
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
    -- TODO: https://github.com/L3MON4D3/LuaSnip
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
    use {
        'datwaft/bubbly.nvim', -- BUG: error in branch tag
        config = function()
        end
    }
    -- TODO: https://github.com/feline-nvim/feline.nvim
    -- TODO: https://github.com/glepnir/galaxyline.nvim
    -- TODO: https://github.com/itchyny/lightline.vim
    -- TODO: https://github.com/konapun/vacuumline.nvim
    -- TODO: https://github.com/nvim-lualine/lualine.nvim
    -- TODO: https://github.com/ojroques/nvim-hardline
    -- TODO: https://github.com/ojroques/nvim-hardline
    -- TODO: https://github.com/tamton-aquib/staline.nvim
    -- TODO: https://github.com/windwp/windline.nvim
    -- }}}

    -- Syntax:
    -- ```````
    -- {{{
    -- TODO: https://github.com/tbastos/vim-lua " Lua syntax
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
    -- TODO: https://github.com/alvarosevilla95/luatab.nvim
    -- TODO: https://github.com/bagrat/vim-buffet
    -- TODO: https://github.com/kdheepak/tabline.nvim
    -- TODO: https://github.com/mengelbrecht/lightline-bufferline
    -- TODO: https://github.com/noib3/nvim-cokeline
    -- TODO: https://github.com/pacha/vem-tabline
    -- TODO: https://github.com/rafcamlet/tabline-framework.nvim
    -- TODO: https://github.com/romgrk/barbar.nvim

    -- Tables:
    -- ```````
    use 'dhruvasagar/vim-table-mode'
    -- TODO: https://github.com/godlygeek/tabular

    -- Telescope:
    -- ``````````
    -- {{{
    use 'nvim-telescope/telescope.nvim'
    -- TODO: https://github.com/AckslD/nvim-neoclip.lua
    -- TODO: https://github.com/LinArcX/telescope-command-palette.nvim
    -- TODO: https://github.com/axkirillov/easypick.nvim
    -- TODO: https://github.com/camspiers/snap
    -- TODO: https://github.com/crispgm/telescope-heading.nvim
    -- TODO: https://github.com/nvim-telescope/telescope-hop.nvim
    -- TODO: https://github.com/nvim-telescope/telescope-packer.nvim
    -- TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
    -- TODO: https://github.com/voldikss/vim-floaterm
    -- }}}

    -- Terminal:
    -- `````````
    -- {{{
    -- TODO: https://github.com/LoricAndre/OneTerm.nvim
    -- TODO: https://github.com/akinsho/toggleterm.nvim
    -- TODO: https://github.com/jlesquembre/nterm.nvim
    -- TODO: https://github.com/kassio/neoterm
    -- TODO: https://github.com/nikvdp/neomux
    -- TODO: https://github.com/numToStr/FTerm.nvim
    -- TODO: https://github.com/oberblastmeister/termwrapper.nvim
    -- TODO: https://github.com/pianocomposer321/consolation.nvim
    -- TODO: https://github.com/s1n7ax/nvim-terminal
    -- }}}

    -- Todo Marker:
    -- ````````````
    -- {{{
    -- use 'folke/todo-comments.nvim' " {
-- require("todo-comments").setup {}
    --     " BUG: Can not handle multiple todos in same line
    --     " BUG: Makes vim scrolling slow
    -- }
    -- TODO: Quickfix
    -- TODO: Search
    -- TODO: Telescope
    -- TODO: Trouble
    -- }}}

    -- Treesitter:
    -- ```````````
    -- {{{
    use 'nvim-treesitter/nvim-treesitter' -- {
    --     " TODO: Folding
    --     " TODO: Incremental selection
    --     " TODO: Indentation
    --     " TODO: Wiki
    -- }
    -- use 'romgrk/nvim-treesitter-context' -- {
    --     " BUG: Its buggy in windows
    -- }
    use {
        'm-demare/hlargs.nvim', -- NOTE: may not be required
        config = function()
            require('hlargs').setup()
        end
    }
    use 'nvim-treesitter/nvim-treesitter-context' -- {
    --    BUG: Makes scroll slow
    -- }
    -- TODO: https://github.com/RRethy/nvim-treesitter-endwise
    -- TODO: https://github.com/RRethy/nvim-treesitter-textsubjects
    -- TODO: https://github.com/lewis6991/spellsitter.nvim
    -- TODO: https://github.com/mfussenegger/nvim-treehopper
    -- TODO: https://github.com/nvim-treesitter/nvim-treesitter-refactor
    -- TODO: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    -- TODO: https://github.com/nvim-treesitter/playground
    -- use 'p00f/nvim-ts-rainbow' " BUG: not working
    -- }}}

    -- TUI:
    -- ````
    -- {{{
    -- use 'VonHeikemen/fine-cmdline.nvim'
    -- use 'VonHeikemen/searchbox.nvim'
    -- use 'rcarriga/nvim-notify'
    -- TODO: https://github.com/skywind3000/vim-quickui
    -- TODO: https://github.com/stevearc/dressing.nvim
    -- TODO: https://github.com/sunjon/stylish.nvim
    -- }}}

    -- Utilities:
    -- ``````````
    -- {{{
    use 'tversteeg/registers.nvim' -- Displays registers on ^R and " {
    --     let g:registers_window_border = "rounded"
    --     " TODO: Check if height can be reduced
    -- }
    use 'nacro90/numb.nvim' -- Peek number line while jumping
    use 'MunifTanjim/nui.nvim'
    use 'folke/trouble.nvim' -- NOTE: It should go in LSP
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'rktjmp/lush.nvim'

    -- TODO: https://github.com/nvim-neotest/neotest
    -- TODO: https://github.com/Iron-E/nvim-bufmode
    -- TODO: https://github.com/Iron-E/nvim-libmodal
    -- TODO: https://github.com/Iron-E/nvim-tabmode
    -- TODO: https://github.com/Iron-E/vim-libmodal
    -- TODO: https://github.com/NFrid/due.nvim
    -- TODO: https://github.com/NTBBloodbath/rest.nvim
    -- TODO: https://github.com/Pocco81/AbbrevMan.nvim
    -- TODO: https://github.com/RishabhRD/nvim-cheat.sh
    -- TODO: https://github.com/SmiteshP/nvim-gps
    -- TODO: https://github.com/ThemerCorp/themer.lua
    -- TODO: https://github.com/WolfgangMehner/vim-plugins
    -- TODO: https://github.com/ahmedkhalf/project.nvim
    -- TODO: https://github.com/amirrezaask/fuzzy.nvim
    -- TODO: https://github.com/andymass/vim-matchup
    -- TODO: https://github.com/bennypowers/nvim-regexplainer
    -- TODO: https://github.com/bfredl/nvim-luadev
    -- TODO: https://github.com/bignimbus/you-are-here.vim
    -- TODO: https://github.com/booperlv/nvim-gomove
    -- TODO: https://github.com/chipsenkbeil/distant.nvim
    -- TODO: https://github.com/chrisbra/NrrwRgn
    -- TODO: https://github.com/craigemery/vim-autotag
    -- TODO: https://github.com/dbeniamine/cheat.sh-vim
    -- TODO: https://github.com/folke/lua-dev.nvim
    -- TODO: https://github.com/frabjous/knap
    -- TODO: https://github.com/gaborvecsei/cryptoprice.nvim
    -- TODO: https://github.com/gbprod/substitute.nvim
    -- TODO: https://github.com/gbprod/yanky.nvim
    -- TODO: https://github.com/gelguy/wilder.nvim, { 'do': function('UpdateRemotePlugins') }
    -- TODO: https://github.com/gennaro-tedesco/nvim-jqx
    -- TODO: https://github.com/ggandor/leap.nvim
    -- TODO: https://github.com/glacambre/firenvim, { 'do': { _ -> firenvim#install(0) } }
    -- TODO: https://github.com/haringsrob/nvim_context_vt " NOTE: Good but should be off by default
    -- TODO: https://github.com/haya14busa/is.vim
    -- TODO: https://github.com/haya14busa/vim-asterisk
    -- TODO: https://github.com/henriquehbr/nvim-startup.lua " NOTE: startup time analyser
    -- TODO: https://github.com/ibhagwan/fzf-lua
    -- TODO: https://github.com/is0n/jaq-nvim
    -- TODO: https://github.com/jakewvincent/mkdnflow.nvim
    -- TODO: https://github.com/jamestthompson3/nvim-remote-containers
    -- TODO: https://github.com/jbyuki/instant.nvim
    -- TODO: https://github.com/jbyuki/one-small-step-for-vimkind
    -- TODO: https://github.com/jbyuki/venn.nvim
    -- TODO: https://github.com/jubnzv/mdeval.nvim
    -- TODO: https://github.com/junegunn/fzf
    -- TODO: https://github.com/junegunn/vim-easy-align
    -- TODO: https://github.com/junegunn/vim-slash
    -- TODO: https://github.com/kevinhwang91/nvim-hlslens
    -- TODO: https://github.com/klen/nvim-test
    -- TODO: https://github.com/kshenoy/vim-signature
    -- TODO: https://github.com/lifepillar/vim-colortemplate
    -- TODO: https://github.com/liuchengxu/vim-clap
    -- TODO: https://github.com/markonm/traces.vim
    -- TODO: https://github.com/matbme/JABS.nvim
    -- TODO: https://github.com/matveyt/neoclip
    -- TODO: https://github.com/mhinz/vim-galore
    -- TODO: https://github.com/michaelb/sniprun
    -- TODO: https://github.com/milisims/nvim-luaref
    -- TODO: https://github.com/monkoose/matchparen.nvim
    -- TODO: https://github.com/mrjones2014/legendary.nvim
    -- TODO: https://github.com/paretje/nvim-man
    -- TODO: https://github.com/pechorin/any-jump.vim
    -- TODO: https://github.com/phaazon/hop.nvim
    -- TODO: https://github.com/pianocomposer321/yabs.nvim
    -- TODO: https://github.com/rafcamlet/nvim-luapad
    -- TODO: https://github.com/rcarriga/vim-ultest
    -- TODO: https://github.com/renerocksai/telekasten.nvim
    -- TODO: https://github.com/rickhowe/spotdiff.vim
    -- TODO: https://github.com/sheerun/vim-polyglot
    -- TODO: https://github.com/sidebar-nvim/sidebar.nvim
    -- TODO: https://github.com/simnalamburt/vim-mundo
    -- TODO: https://github.com/srstevenson/vim-picker
    -- TODO: https://github.com/stsewd/sphinx.nvim
    -- TODO: https://github.com/mg979/vim-visual-multi
    -- TODO: https://github.com/tjdevries/nlua.nvim
    -- TODO: https://github.com/wbthomason/packer.nvim
    -- TODO: https://github.com/wellle/context.vim
    -- }}}
end
)

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

local on_attach = function(_, bufnr)
  -- vim-illuminate
  require 'illuminate'.on_attach(_)
  require 'virtualtypes'.on_attach(_)

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

-- Auto-Initialize serves
local servers = require'nvim-lsp-installer.servers'.get_installed_server_names()
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- LSP Lines
-- require("lsp_lines").register_lsp_virtual_lines()
-- vim.diagnostic.config({
--   virtual_text = false,
-- })
-- vim.diagnostic.config({ virtual_lines = { prefix = "🔥" } })


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
                    vim = ' vim',
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
return ret
