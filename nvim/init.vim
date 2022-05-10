"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" TODO: Fix keymappings for <C-right arrow> <C-left arror> word movements
" TODO: Highlight only overlength chars
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%74v.*/
" augroup END
" TODO: blink on yank
" au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true} " Highlight on yank
" TODO: set linebreak
" TODO: key mapping gq
" TODO: key mapping vip
" TODO: http://blog.ezyang.com/2010/03/vim-textwidth/
" TODO: set fo formatting options
" t	Auto-wrap text using textwidth
" c	Auto-wrap comments using textwidth, inserting the current comment leader automatically.
" r	Automatically insert the current comment leader after hitting <Enter> in Insert mode.
" o	Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.  In case comment is unwanted in a specific place use CTRL-U to quickly delete it.
" q	Allow formatting of comments with "gq". Note that formatting will not change blank lines or lines containing only the comment leader.  A new paragraph starts after such a line, or when the comment leader changes.
" w	Trailing white space indicates a paragraph continues in the next line. A line that ends in a non-white character ends a paragraph.
" a	Automatic formatting of paragraphs.  Every time text is inserted or deleted the paragraph will be reformatted.  See |auto-format|. When the 'c' flag is present this only happens for recognized comments.
" n	When formatting text, recognize numbered lists.  This actually uses the 'formatlistpat' option, thus any kind of list can be used. The indent of the text after the number is used for the next line.  The default is to find a number, optionally followed by '.', ':', ')', ']' or '}'.  Note that 'autoindent' must be set too.  Doesn't work well together with "2".
"	Example: >
"		1. the first item
"		   wraps
"		2. the second item
" 2	When formatting text, use the indent of the second line of a paragraph for the rest of the paragraph, instead of the indent of the first line. This supports paragraphs in which the first line has a different indent than the rest.  Note that 'autoindent' must be set too.
" Example: >
"			first line of a paragraph
"		second line of the same paragraph
"		third line.
"<	This also works inside comments, ignoring the comment leader.
" v	Vi-compatible auto-wrapping in insert mode: Only break a line at a blank that you have entered during the current insert command.  (Note: this is not 100% Vi compatible.  Vi has some "unexpected features" or bugs in this area.  It uses the screen column instead of the line column.)
" b	Like 'v', but only auto-wrap if you enter a blank at or before the wrap margin.  If the line was longer than 'textwidth' when you started the insert, or you do not enter a blank in the insert before reaching 'textwidth', Vim does not perform auto-wrapping.
" l	Long lines are not broken in insert mode: When a line was longer than 'textwidth' when the insert command started, Vim does not automatically format it.
" 1	Don't break a line after a one-letter word.  It's broken before it instead (if possible).
" j	Where it makes sense, remove a comment leader when joining lines.  For
"	example, joining:
"		int i;   // the index ~
"		         // in the list ~
"	Becomes:
"		int i;   // the index in the list
" p	Don't break lines at single spaces that follow periods.  This is intended to complement 'joinspaces' and |cpo-J|, for prose with sentences separated by two spaces.  For example, with 'textwidth' set to 28:
"		Surely you're joking, Mr. Feynman!
"	Becomes:
"		Surely you're joking,
"		Mr. Feynman!
"	Instead of:
"		Surely you're joking, Mr.
"		Feynman!
" With 't' and 'c' you can specify when Vim performs auto-wrapping:
" value	action	~
  ""	no automatic formatting (you can use "gq" for manual formatting)
  "t"	automatic formatting of text, but not comments
  "c"	automatic formatting for comments, but not text (good for C code)
  "tc"	automatic formatting for text and comments
" 

" UI Client:
" ``````````
" TODO:
" https://github.com/yatli/fvim
" https://github.com/vhakulinen/gnvim
" https://github.com/rohit-px2/nvui
" https://github.com/equalsraf/neovim-qt
" https://github.com/vhakulinen/gnvim
" https://github.com/akiyosi/goneovim
" https://github.com/smolck/uivonim
" https://github.com/jeanguyomarch/eovim/
" https://github.com/RMichelsen/Nvy
" https://github.com/Lyude/neovim-gtk
" https://github.com/neovide/neovide
" https://github.com/smolck/uivonim


" Plugins - Vim-plug
" ``````````````````
call plug#begin()
" Auto Pair:
" ``````````
Plug 'windwp/nvim-autopairs'
" TODO:
" Create rule to not pair " for vim files
" Create custom rule to Expand multiple pairs on enter key, similar to vim-closer, already implemented in its wiki
" vim automatically cursor goes to next line but how we don't know yet, how to
" do it
" https://github.com/ZhiyuanLck/smart-pairs
" https://github.com/max-0406/autoclose.nvim
" https://github.com/steelsojka/pears.nvim

" Coloring:
" ````````````
" TODO:
" 
" https://github.com/norcalli/nvim-colorizer.lua
" https://github.com/norcalli/nvim-terminal.lua

" Colorscheme:
" ````````````
" Current:
" << Light >>
" << Dark >>
Plug 'luisiacc/gruvbox-baby'

" Accepted:
" << Light >>
" Plug 'Th3Whit3Wolf/one-nvim'
" Plug 'Th3Whit3Wolf/onebuddy'
" Plug 'NLKNguyen/papercolor-theme'
" Plug 'ayu-theme/ayu-vim'
" << Dark >>
" Plug 'olimorris/onedarkpro.nvim'
" Plug 'Th3Whit3Wolf/one-nvim'
" Plug 'Th3Whit3Wolf/onebuddy'
" Plug 'NLKNguyen/papercolor-theme'
" Plug 'ayu-theme/ayu-vim'
" Plug 'glepnir/zephyr-nvim'

" TODO: To review
" Plug 'ChristianChiarulli/nvcode-color-schemes.vim' ->> treesitter
" Plug 'EdenEast/nightfox.nvim' ->> treesitter
" Plug 'marko-cerovac/material.nvim'
" Plug 'mhartington/oceanic-next'
" Plug 'nekonako/xresources-nvim'
" Plug 'olimorris/onedarkpro.nvim' " check light
" Plug 'projekt0n/github-nvim-theme'
" Plug 'ray-x/aurora'
" Plug 'rebelot/kanagawa.nvim'
" Plug 'rktjmp/lush.nvim'
" Plug 'rmehri01/onenord.nvim'
" Plug 'sainnhe/edge'
" Plug 'sainnhe/everforest'
" Plug 'sainnhe/gruvbox-material'
" Plug 'sainnhe/sonokai'
" Plug 'savq/melange'
" Plug 'shaunsingh/moonlight.nvim'
" Plug 'simrat39/symbols-outline.nvim' ->> LSP
" Plug 'stevearc/aerial.nvim'  ->> LSP
" Plug 'tanvirtin/monokai.nvim'
" Plug 'tiagovla/tokyodark.nvim'
" Plug 'titanzero/zephyrium'
" Plug 'tjdevries/colorbuddy.vim'
" Plug 'tjdevries/gruvbuddy.nvim'
" Plug 'tomasiser/vim-code-dark'
" Plug 'yashguptaz/calvera-dark.nvim'
" https://github.com/Mangeshrex/uwu.vim
" https://github.com/PHSix/nvim-hybrid
" https://github.com/cpea2506/one_monokai.nvim
" https://github.com/dracula/vim
" https://github.com/fenetikm/falcon
" https://github.com/kvrohit/rasmus.nvim
" https://github.com/ldelossa/vimdark
" https://github.com/mcchrish/zenbones.nvim
" https://github.com/rafamadriz/neon

" Commenting:
" ```````````
Plug 'gennaro-tedesco/nvim-commaround'
    " TODO:
    " Fix toggle mapping to VSCode one
    " Add filetype for powershell
" TODO:
" Plug 'b3nj5m1n/kommentary'
" Plug 'numToStr/Comment.nvim'
" Plug 'terrortylor/nvim-comment'
" Plug 'winston0410/commented.nvim'
" https://github.com/JoosepAlviste/nvim-ts-context-commentstring

" Completion:
" ```````````
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'

" TODO:
" LSP - explore
" Snippets
" Commandline
" Path
" https://github.com/PasiBergman/cmp-nuget " For Nuget
" https://github.com/tzachar/cmp-fuzzy-buffer
" https://github.com/octaltree/cmp-look
" https://github.com/uga-rosa/cmp-dictionary
" Menu UI Changes https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
" https://github.com/noib3/nvim-compleet

" Configuration:
" ``````````````
" TODO: Explore
" https://github.com/AstroNvim/AstroNvim
" https://github.com/CanKolay3499/CNvim
" https://github.com/CosmicNvim/CosmicNvim
" https://github.com/JryChn/ModuleVim
" https://github.com/LunarVim/LunarVim
" https://github.com/NTBBloodbath/doom-nvim
" https://github.com/NvChad/NvChad
" https://github.com/Theory-of-Everything/nii-nvim
" https://github.com/VapourNvim/VapourNvim
" https://github.com/askfiy/nvim
" https://github.com/echasnovski/mini.nvim
" https://github.com/lalitmee/cobalt2.nvim
" https://github.com/ldelossa/litee.nvim
" https://github.com/nvim-lua/kickstart.nvim
" https://github.com/nvim-neorg/neorg
" https://github.com/nvim-orgmode/orgmode
" https://github.com/ray-x/go.nvim
" https://github.com/shaeinst/roshnivim

" DAP:
" ````
" TODO:
" https://github.com/rcarriga/nvim-dap-ui

" File Explorer:
" ``````````````
" TODO: Explore
" https://github.com/tamago324/lir.nvim
" https://github.com/nvim-neo-tree/neo-tree.nvim

" Folding:
" ````````
" TODO: Explore
" Plug 'anuvyklack/pretty-fold.nvim'
" Plug 'anuvyklack/nvim-keymap-amend'

" Icons:
" ``````
" TODO:
" https://github.com/yamatsum/nvim-nonicons

" LSP:
" ````
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
" TODO:
" Autocompletion
" Code Actions
" Linitng
" Snippets
" UI Customization
" https://github.com/tami5/lspsaga.nvim --> https://github.com/glepnir/lspsaga.nvim
" https://github.com/RishabhRD/nvim-lsputils
" https://github.com/j-hui/fidget.nvim
" https://github.com/jose-elias-alvarez/null-ls.nvim
" https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils
" https://github.com/junnplus/nvim-lsp-setup
" https://github.com/kdheepak/lazygit.nvim
" https://github.com/liuchengxu/vista.vim
" https://github.com/lukas-reineke/format.nvim
" https://github.com/lukas-reineke/lsp-format.nvim
" https://github.com/nanotee/nvim-lsp-basics
" https://github.com/nvim-lua/lsp-status.nvim
" https://github.com/ojroques/nvim-lspfuzzy
" https://github.com/onsails/diaglist.nvim
" https://github.com/onsails/lspkind.nvim
" https://github.com/ray-x/lsp_signature.nvim
" https://github.com/ray-x/navigator.lua
" https://github.com/weilbith/nvim-code-action-menu

" Session Manager:
" ````````````````
" TODO:
" https://github.com/olimorris/persisted.nvim
" https://github.com/rmagatti/auto-session

" Snippets:
" `````````
" TODO:
" https://github.com/L3MON4D3/LuaSnip
" https://github.com/dcampos/nvim-snippy
" https://github.com/ellisonleao/carbon-now.nvim
" https://github.com/hrsh7th/vim-vsnip
" https://github.com/norcalli/snippets.nvim
" https://github.com/rafamadriz/friendly-snippets

" Status Line:
" ````````````
Plug 'beauwilliams/statusline.lua' " Slowness observed
    " TODO: Explore Statusline
" TODO:
" https://github.com/nvim-lualine/lualine.nvim
" Plug 'windwp/windline.nvim'
" https://github.com/NTBBloodbath/galaxyline.nvim
" https://github.com/b0o/incline.nvim
" https://github.com/datwaft/bubbly.nvim
" https://github.com/feline-nvim/feline.nvim
" https://github.com/itchyny/lightline.vim
" https://github.com/konapun/vacuumline.nvim
" https://github.com/noib3/nvim-cokeline
" https://github.com/ojroques/nvim-hardline

" Tab Line:
" `````````
" TODO:
" https://github.com/crispgm/nvim-tabline
" https://github.com/kdheepak/tabline.nvim
" https://github.com/rafcamlet/tabline-framework.nvim
" https://github.com/romgrk/barbar.nvim

" Telescope:
" ``````````
" TODO: Explore Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
" https://github.com/LinArcX/telescope-command-palette.nvim

" Terminal:
" `````````
" TODO:
"
" https://github.com/nikvdp/neomux
" https://github.com/numToStr/FTerm.nvim
" https://github.com/oberblastmeister/termwrapper.nvim
" https://github.com/pianocomposer321/consolation.nvim

" Todo:
" `````
Plug 'folke/todo-comments.nvim'
" TODO:
" Search
" Quickfix
" Telescope

" Treesitter:
" ```````````
Plug 'nvim-treesitter/nvim-treesitter'
" TODO:
" Incremental selection
" Indentation
" Folding
" Wiki
" https://github.com/RRethy/nvim-treesitter-textsubjects
" https://github.com/lewis6991/spellsitter.nvim
" https://github.com/m-demare/hlargs.nvim
" https://github.com/nvim-treesitter/nvim-treesitter-textobjects

" Utilities:
" ``````````
" TODO:
" https://github.com/p00f/nvim-ts-rainbow
" https://github.com/phaazon/hop.nvim
" https://github.com/pianocomposer321/yabs.nvim
" https://github.com/rktjmp/lush.nvim
" https://github.com/stevearc/dressing.nvim


" Word Highlight:
" ```````````````
Plug 'RRethy/vim-illuminate'
" BUG: highlight colors are not good
hi def link LspReferenceText WildMenu
hi def link LspReferenceWrite WildMenu
hi def link LspReferenceRead WildMenu
" TODO:
" Plug 'xiyaowong/nvim-cursorword'
" Plug 'yamatsum/nvim-cursorline'


" Archived:
" Plug 'booperlv/nvim-gomove'
" Plug 'f-person/git-blame.nvim' " not working, needs review
" Plug 'filipdutescu/renamer.nvim', { 'branch': 'master' }
" Plug 'folke/trouble.nvim'
" Plug 'jbyuki/venn.nvim'
" Plug 'kevinhwang91/nvim-hlslens'
" Plug 'folke/which-key.nvim'
" Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
" Plug 'gennaro-tedesco/nvim-peekup'
" Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" Plug 'haringsrob/nvim_context_vt' " NOTE: Good but should be off by default
" Plug 'wbthomason/packer.nvim'
" Plug 'ruifm/gitlinker.nvim' " NOTE: Good plugin worth lazy loading
" Plug 'kyazdani42/nvim-web-devicons'
" Plug 'mfussenegger/nvim-dap'
" Plug 'jbyuki/one-small-step-for-vimkind'
" Plug 'lewis6991/gitsigns.nvim' " BUG: Conflicts with todo-comments
" https://github.com/FeiyouG/command_center.nvim
" https://github.com/LionC/nest.nvim
" https://github.com/MordechaiHadad/nvim-papadark
" https://github.com/MunifTanjim/nui.nvim
" https://github.com/Pocco81/AbbrevMan.nvim
" https://github.com/Pocco81/AutoSave.nvim
" https://github.com/Pocco81/DAPInstall.nvim
" https://github.com/Pocco81/HighStr.nvim
" https://github.com/Pocco81/dap-buddy.nvim
" https://github.com/Shatur/neovim-session-manager
" https://github.com/SmiteshP/nvim-gps
" https://github.com/ThePrimeagen/harpoon
" https://github.com/ThemerCorp/themer.lua
" https://github.com/TimUntersberger/neogit
" https://github.com/aserowy/tmux.nvim
" https://github.com/b0o/mapx.nvim
" https://github.com/bennypowers/nvim-regexplainer
" https://github.com/camspiers/snap
" https://github.com/chentau/marks.nvim
" https://github.com/elihunter173/dirbuf.nvim
" https://github.com/folke/lua-dev.nvim
" https://github.com/frabjous/knap
" https://github.com/gaborvecsei/cryptoprice.nvim
" https://github.com/gaborvecsei/memento.nvim
" https://github.com/gbprod/substitute.nvim
" https://github.com/gbprod/yanky.nvim
" https://github.com/gennaro-tedesco/nvim-jqx
" https://github.com/gfanto/fzf-lsp.nvim
" https://github.com/ggandor/leap.nvim
" https://github.com/henriquehbr/nvim-startup.lua " NOTE: startup time analyser
" https://github.com/ibhagwan/fzf-lua
" https://github.com/is0n/jaq-nvim
" https://github.com/jakewvincent/mkdnflow.nvim
" https://github.com/jameshiew/nvim-magic
" https://github.com/jamestthompson3/nvim-remote-containers
" https://github.com/jbyuki/instant.nvim
" https://github.com/jubnzv/mdeval.nvim
" https://github.com/jubnzv/virtual-types.nvim
" https://github.com/kevinhwang91/nvim-bqf
" https://github.com/kosayoda/nvim-lightbulb
" https://github.com/kyazdani42/nvim-tree.lua
" https://github.com/rcarriga/nvim-notify
" https://github.com/lukas-reineke/indent-blankline.nvim
" https://github.com/matbme/JABS.nvim
" https://github.com/max397574/better-escape.nvim
" https://github.com/mcauley-penney/tidy.nvim
" https://github.com/mfussenegger/nvim-lint
" https://github.com/mfussenegger/nvim-treehopper
" https://github.com/michaelb/sniprun
" https://github.com/milisims/nvim-luaref
" https://github.com/mrjones2014/legendary.nvim
" https://github.com/mrjones2014/smart-splits.nvim
" https://github.com/ms-jpq/chadtree
" https://github.com/ms-jpq/coq_nvim
" https://github.com/nacro90/numb.nvim
" https://github.com/nanotee/nvim-lua-guide
" https://github.com/nvim-lua/plenary.nvim
" https://github.com/nvim-pack/nvim-spectre
" https://github.com/nyngwang/NeoRoot.lua
" https://github.com/rafcamlet/nvim-luapad
" https://github.com/renerocksai/telekasten.nvim
" https://github.com/rktjmp/highlight-current-n.nvim
" https://github.com/rmagatti/goto-preview
" https://github.com/romgrk/nvim-treesitter-context
" https://github.com/sakhnik/nvim-gdb
" https://github.com/sbdchd/neoformat
" https://github.com/shaeinst/penvim
" https://github.com/sindrets/diffview.nvim
" https://github.com/stevearc/qf_helper.nvim
" https://github.com/sudormrfbin/cheatsheet.nvim
" https://github.com/svermeulen/vimpeccable
" https://github.com/tanvirtin/vgit.nvim
" https://github.com/tjdevries/colorbuddy.nvim
" https://github.com/tjdevries/nlua.nvim
" https://github.com/tversteeg/registers.nvim
" https://github.com/vijaymarupudi/nvim-fzf
" https://github.com/ziontee113/syntax-tree-surfer
call plug#end()

" LUA Section:
" ````````````
lua << EOLUA
-- Auto Pair
-- `````````
require('nvim-autopairs').setup({})

-- Completion
-- ``````````
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

-- LSP
-- ```
local lspconfig = require 'lspconfig'
require("nvim-lsp-installer").setup {}

local on_attach = function(_, bufnr)
  require 'illuminate'.on_attach(_)
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
-- Status Line
-- ```````````
local statusline = require('statusline')
statusline.tabline = false

-- Todo-comments
-- `````````````
require("todo-comments").setup {
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  }
}

-- Treesitter
-- ``````````
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    }
}


--require('aerial').setup({})
--local dap = require"dap"
--dap.configurations.lua = { 
--  { 
--    type = 'nlua', 
--    request = 'attach',
--    name = "Attach to running Neovim instance",
--    host = function()
--      local value = vim.fn.input('Host [127.0.0.1]: ')
--      if value ~= "" then
--        return value
--      end
--      return '127.0.0.1'
--    end,
--    port = function()
--      local val = tonumber(vim.fn.input('Port: '))
--      assert(val, "Please provide a port number")
--      return val
--    end,
--  }
--}
--
--dap.adapters.nlua = function(callback, config)
--  callback({ type = 'server', host = config.host, port = config.port })
--end
--
--
--require"gitlinker".setup()
--

--
---- ensure that packer is installed
--local vim = vim
--local execute = vim.api.nvim_command
--local fn = vim.fn
--local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
--if fn.empty(fn.glob(install_path)) > 0 then
--    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
--    execute 'packadd packer.nvim'
--end
--vim.cmd('packadd packer.nvim')
--local packer = require'packer'
--local util = require'packer.util'
--packer.init({
--  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
--})
----- startup and add configure plugins
--packer.startup(function()
--  local use = use
--  -- add you plugins here like:
--  end
--)
---- Shade
---- Illuminate
----  require'lspconfig'.gopls.setup {
----    on_attach = function(client)
----      -- [[ other on_attach code ]]
----      require 'illuminate'.on_attach(client)
----    end,
----  }
---- aplha-nvim
--require("alpha").setup(require'alpha.themes.startify'.config)
--
---- focus.nvim
---- require("focus").setup()
--
---- windline
--require('wlsample.airline_anim')
--require('gitsigns').setup()
--
EOLUA


" Variables:
" ``````````
" {{{
let &titleold             = getcwd() " Set console title to path on vim exit
let c_curly_error         = 1        " Show curly braces error
let c_space_errors        = 1        " Highlight trailing spaces
let g:diff_translations   = 0        " Disables localisations and speeds up syntax highlighting in diff mode
let g:load_doxygen_syntax = 1        " Recognize doxygen comment style
let g:netrw_liststyle     = 3        " Set netrw style as tree
" }}}


" Config Options:
" ```````````````
" {{{
set autowrite             " Auto write changes
set clipboard=unnamedplus " Use + clipboard buffer
set foldnestmax=2         " Max fold level
set nobackup              " Do not create backup file
set path+=**              " Look for all files in sub dirs
" }}}


" Editor Settings:
" ````````````````
" {{{
set breakindent                       " Every wrapped line will continue visually indented
set completeopt=menu,menuone,noselect " for nvim-cmp
set cpoptions+=Z                      " When using w! while the 'readonly' option is set, don't reset 'readonly'
set expandtab                         " Convert tabs to spaces
set history=1000                      " Increase undo limit
set noswapfile                        " Disable swap files
set shiftwidth=4                      " When shifting, indent using spaces
set tabstop=4                         " Indent using spaces
" }}}

let g:aquarium_style="light" " TODO: remove

" UI Options:
" ```````````
" {{{
let g:netrw_banner = 0        " Turn off banner in netrw
set background=dark           " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=tab:>-               " Show space as ·, tab as clear spaces
set list                     " Show special characters
set mouse=a                  " Enable mouse support
set noshowmode               " Don't show INSERT/NOMRAL/VISUAL modes
set number                   " Enable line number
set pumblend=0               " pseudo-transparency for popup-menu
set shortmess=aoOtT          " Short messages
set splitbelow               " Place new window below on :split
set splitright               " Place new window right on :vsplit
set termguicolors            " Enable true colors support
set title                    " Set console title
"set ttymouse=sgr             " Fix mouse support in half screen
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
" set winblend " TODO:
colorscheme gruvbox-baby         " Set colorscheme 
highlight clear CursorLine   " No underline on text when cursorline is on
highlight clear CursorLineNR " No underline on line numbers when cursorline is on
" }}}


" Search Options:
" ```````````````
" {{{
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive when query contains an uppercase letter
" }}}

" Filetype Specific Options:
" ``````````````````````````
" {{{
autocmd BufNewFile,BufRead *.qel set filetype=tcl       " Set qel filetype as tcl
autocmd BufNewFile,BufRead *.cyt set filetype=sh        " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.make set filetype=make     " Set make filetype as Makefile
autocmd BufNewFile,BufRead *.v set filetype=verilog     " Set .v filetype as bash
autocmd BufNewFile,BufRead *.vg set filetype=verilog    " Set cyt filetype as bash
" }}}


" Mappings:
" `````````
" {{{
map <C-a> ^
map <C-e> $
map <C-Right> E
map <C-Left> B
imap <C-a> <C-\><C-O>^
imap <C-e> <C-\><C-O>$
imap <C-Right> <C-\><C-O>E
imap <C-Left> <C-\><C-O>B
" }}}

let g:termdebug_wide = 163
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif " remember file position when closed
autocmd FilterWritePre * if &diff | setlocal wrap< | endif
autocmd VimLeave * let &t_me="\e[0 q" " resets cursor


" Make cursor _ for visual modes
set guicursor=n-c-sm:block,i-ci-ve:ver25,r-cr-o-v:hor20
" Temporary solution to neovim cursor not reset 
augroup RestoreCursorShapeOnExit
    autocmd!
    autocmd VimLeave * set guicursor=a:ver20 " sets cursor to vertical bar
augroup END

" au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true} " Highlight on yank

" Workaround for vim-illuminate
augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi link illuminatedWord MatchParen
augroup END
" vim: fdm=marker
