"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" TODO: Fix keymappings for <C-right arrow> <C-left arror> word movements
" TODO: Highlight only overlength chars
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
" Active:
" TODO: https://github.com/equalsraf/neovim-qt
" Tested:
" https://github.com/akiyosi/goneovim " {
    " TODO: config
    " + Supports extra symbols
    " - Struggling with nerdfonts
    " - Slow and Hangy
    " - Left out glyph in UI
    " - Cursor shifts back and forward in insert mode
    " X not good to use
" }

" https://github.com/yatli/fvim " {
    " if exists('g:fvim_loaded')
    "     FVimCursorSmoothMove v:true
    "     FVimCursorSmoothBlink v:true
    "     FVimCustomTitleBar v:true
    "     FVimFontLigature v:true
    "     FVimUIPopupMenu v:false
    "     FVimUIWildMenu v:false
    " endif
    " + Cursor animations are good
    " + Rounded corners
    " + Titile Bar is good
    " - Ligatures not working
    " - Nerd Font support is not good
    " - Slow loading of UI
" }
" https://github.com/Lyude/neovim-gtk " {
    " + Simple nothing special
    " - Not good in different DPI
    " X not good to use
" }

" TODO: https://github.com/hismailbulut/Neoray
" TODO: https://github.com/jeanguyomarch/eovim
" TODO: https://github.com/neovide/neovide
" TODO: https://github.com/rohit-px2/nvui
" TODO: https://github.com/sakhnik/nvim-ui
" TODO: https://github.com/smolck/uivonim
" TODO: https://github.com/vhakulinen/gnvim


" Plugins - Vim-plug
" ``````````````````
call plug#begin()
" Auto Pair:
" ``````````
Plug 'windwp/nvim-autopairs'
" TODO: Create custom rule to Expand multiple pairs on enter key, similar to vim-closer, already implemented in its wiki
" TODO: Create rule to not pair " for vim files
" TODO: https://github.com/ZhiyuanLck/smart-pairs
" TODO: https://github.com/max-0406/autoclose.nvim
" TODO: https://github.com/neoclide/coc-pairs
" TODO: https://github.com/rstacruz/vim-closer
" TODO: https://github.com/steelsojka/pears.nvim
" TODO: https://github.com/theHamsta/nvim-treesitter-pairs
" TODO: vim automatically cursor goes to next line but how we don't know yet, how to do it

" COC:
" ````
" TODO: https://github.com/ms-jpq/coq_nvim
" TODO: https://github.com/neoclide/coc-json
" TODO: https://github.com/neoclide/coc-sources
" TODO: https://github.com/neoclide/coc-yank
" TODO: https://github.com/neoclide/coc.nvim
" TODO: https://github.com/xiyaowong/coc-lightbulb-

" Coloring:
" `````````
" TODO: Plug 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' } " GO dependency
" TODO: https://github.com/azabiong/vim-highlighter
" TODO: https://github.com/lilydjwg/colorizer
" TODO: https://github.com/neoclide/coc-highlight
" TODO: https://github.com/norcalli/nvim-colorizer.lua
" TODO: https://github.com/norcalli/nvim-terminal.lua
" TODO: https://github.com/t9md/vim-quickhl
" Plug 'tribela/vim-transparent' " Make theme transparent

" Colorscheme:
" ````````````
" Current:
" << Light >>
" << Dark >>
Plug 'Yagua/nebulous.nvim'

" Accepted:
" << Light >>
" Plug 'EdenEast/nightfox.nvim'
" Plug 'NLKNguyen/papercolor-theme'
" Plug 'Th3Whit3Wolf/one-nvim'
" Plug 'Th3Whit3Wolf/onebuddy'
" Plug 'ayu-theme/ayu-vim'
" Plug 'jsit/toast.vim'
" Plug 'marko-cerovac/material.nvim'
" Plug 'olimorris/onedarkpro.nvim'
" Plug 'projekt0n/github-nvim-theme'
" Plug 'rmehri01/onenord.nvim'
" Plug 'katawful/kat.nvim'
" Plug 'marko-cerovac/material.nvim'

" << Dark >>
" Plug 'EdenEast/nightfox.nvim'
" Plug 'NLKNguyen/papercolor-theme'
" Plug 'Th3Whit3Wolf/one-nvim'
" Plug 'Th3Whit3Wolf/onebuddy'
" Plug 'ayu-theme/ayu-vim'
" Plug 'glepnir/zephyr-nvim'
" Plug 'jsit/toast.vim'
" Plug 'marko-cerovac/material.nvim'
" Plug 'mhartington/oceanic-next'
" Plug 'olimorris/onedarkpro.nvim'
" Plug 'projekt0n/github-nvim-theme'
" Plug 'ray-x/aurora'
" Plug 'rebelot/kanagawa.nvim'
" Plug 'rmehri01/onenord.nvim'
" Plug 'katawful/kat.nvim'
" Plug 'marko-cerovac/material.nvim'

" TODO: Plug 'cpea2506/one_monokai.nvim'
" TODO: Plug 'dracula/vim'
" TODO: Plug 'dylanaraps/wal.vim'
" TODO: Plug 'fenetikm/falcon'
" TODO: Plug 'ldelossa/vimdark'
" TODO: Plug 'mcchrish/zenbones.nvim'
" TODO: Plug 'mrjones2014/lighthaus.nvim'
" TODO: Plug 'ntk148v/vim-horizon'
" TODO: Plug 'rafalbromirski/vim-aurora'
" TODO: Plug 'rafamadriz/neon'
" TODO: Plug 'sainnhe/edge'
" TODO: Plug 'sainnhe/everforest'
" TODO: Plug 'sainnhe/gruvbox-material'
" TODO: Plug 'sainnhe/sonokai'
" TODO: Plug 'savq/melange'
" TODO: Plug 'shaunsingh/moonlight.nvim'
" TODO: Plug 'sickill/vim-monokai'
" TODO: Plug 'simrat39/symbols-outline.nvim'
" TODO: Plug 'stevearc/aerial.nvim'
" TODO: Plug 'tanvirtin/monokai.nvim'
" TODO: Plug 'tiagovla/tokyodark.nvim'
" TODO: Plug 'titanzero/zephyrium'
" TODO: Plug 'tjdevries/colorbuddy.vim'
" TODO: Plug 'tjdevries/gruvbuddy.nvim'
" TODO: Plug 'tomasiser/vim-code-dark'
" TODO: Plug 'wuelnerdotexe/vim-enfocado'
" TODO: Plug 'yashguptaz/calvera-dark.nvim'

" Plug 'AlphaTechnolog/pywal.nvim'

" Commenting:
" ```````````
Plug 'gennaro-tedesco/nvim-commaround' " {
    " TODO:
    " Fix toggle mapping to VSCode one
    " Add filetype for powershell
" }
" TODO: Plug 'b3nj5m1n/kommentary'
" TODO: Plug 'numToStr/Comment.nvim'
" TODO: Plug 'terrortylor/nvim-comment'
" TODO: Plug 'winston0410/commented.nvim'
" TODO: https://github.com/JoosepAlviste/nvim-ts-context-commentstring
" TODO: https://github.com/tpope/vim-commentary
" TODO: https://github.com/winston0410/commented.nvim

" Completion:
" ```````````
Plug 'hrsh7th/nvim-cmp' " {
    " TODO: Commandline
    " TODO: Hover doc
    " TODO: LSP - explore
    " TODO: Menu UI Changes https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
    " TODO: Path
    " TODO: Snippets
" }
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
" TODO: https://github.com/OmniSharp/omnisharp-vim
" TODO: https://github.com/PasiBergman/cmp-nuget
" TODO: https://github.com/Shougo/deoplete.nvim
" TODO: https://github.com/davidsierradz/cmp-conventionalcommits
" TODO: https://github.com/dmitmel/cmp-cmdline-history
" TODO: https://github.com/f3fora/cmp-nuspell
" TODO: https://github.com/f3fora/cmp-spell
" TODO: https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol
" TODO: https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
" TODO: https://github.com/hrsh7th/cmp-nvim-lua
" TODO: https://github.com/iamcco/coc-vimlsp
" TODO: https://github.com/kristijanhusak/vim-dadbod-completion
" TODO: https://github.com/lukas-reineke/cmp-under-comparator
" TODO: https://github.com/meetcw/cmp-browser-source
" TODO: https://github.com/neoclide/coc-neco
" TODO: https://github.com/noib3/nvim-compleet
" TODO: https://github.com/nxvu699134/vn-night.nvim
" TODO: https://github.com/octaltree/cmp-look
" TODO: https://github.com/rambhosale/cmp-bootstrap.nvim
" TODO: https://github.com/ray-x/cmp-treesitter
" TODO: https://github.com/tzachar/cmp-fuzzy-buffer
" TODO: https://github.com/tzachar/cmp-tabnine
" TODO: https://github.com/uga-rosa/cmp-dictionary
" TODO: https://github.com/vappolinario/cmp-clippy
" TODO: https://github.com/voldikss/coc-browser
" TODO: https://github.com/zbirenbaum/copilot-cmp

" Configuration:
" ``````````````
" {{{
" TODO: https://github.com/AstroNvim/AstroNvim
" TODO: https://github.com/Avimitin/nvim
" TODO: https://github.com/CanKolay3499/CNvim
" TODO: https://github.com/CosmicNvim/CosmicNvim
" TODO: https://github.com/JryChn/ModuleVim
" TODO: https://github.com/LunarVim/LunarVim
" TODO: https://github.com/LunarVim/LunarVim
" TODO: https://github.com/NTBBloodbath/doom-nvim
" TODO: https://github.com/NvChad/NvChad
" TODO: https://github.com/Shadorain/shadovim
" TODO: https://github.com/TeoDev1611/astro.nvim
" TODO: https://github.com/Theory-of-Everything/nii-nvim
" TODO: https://github.com/VapourNvim/VapourNvim
" TODO: https://github.com/artart222/CodeArt
" TODO: https://github.com/askfiy/nvim
" TODO: https://github.com/b0o/nvim-conf
" TODO: https://github.com/crivotz/nv-ide
" TODO: https://github.com/cstsunfu/.sea.nvim
" TODO: https://github.com/echasnovski/mini.nvim
" TODO: https://github.com/jdhao/nvim-config
" TODO: https://github.com/lalitmee/cobalt2.nvim
" TODO: https://github.com/ldelossa/litee-calltree.nvim
" TODO: https://github.com/ldelossa/litee.nvim
" TODO: https://github.com/mnabila/nvimrc
" TODO: https://github.com/nvim-lua/kickstart.nvim
" TODO: https://github.com/nvim-neorg/neorg
" TODO: https://github.com/nvim-orgmode/orgmode
" TODO: https://github.com/optimizacija/neovim-config
" TODO: https://github.com/ray-x/dotfiles
" TODO: https://github.com/ray-x/go.nvim
" TODO: https://github.com/shaeinst/roshnivim
" }}}

" Debugger:
" `````````
" TODO: Plug 'mfussenegger/nvim-dap'
" TODO: https://github.com/Pocco81/DAPInstall.nvim
" TODO: https://github.com/Pocco81/dap-buddy.nvim
" TODO: https://github.com/mfussenegger/nvim-dap-python
" TODO: https://github.com/rcarriga/nvim-dap-ui
" TODO: https://github.com/sakhnik/nvim-gdb
" TODO: https://github.com/theHamsta/nvim-dap-virtual-text

" Doc Generater:
" ``````````````
" TODO: https://github.com/danymat/neogen
" TODO: https://github.com/kkoomen/vim-doge
" TODO: https://github.com/nvim-treesitter/nvim-tree-docs

" File Explorer:
" ``````````````
Plug 'nvim-neo-tree/neo-tree.nvim' " {
    " BUG: Does not replace netrw
    " BUG: fuzzy search does not seems to work
    " good for fit status tree
    " shows lsp warnings in tree
" }
" TODO: https://github.com/PhilRunninger/nerdtree-visual-selection
" TODO: https://github.com/Shougo/defx.nvim
" TODO: https://github.com/Xuyuanp/nerdtree-git-plugin
" TODO: https://github.com/elihunter173/dirbuf.nvim
" TODO: https://github.com/kyazdani42/nvim-tree.lua
" TODO: https://github.com/ms-jpq/chadtree
" TODO: https://github.com/tiagofumo/vim-nerdtree-syntax-highlight

" Folding:
" ````````
" TODO: Plug 'anuvyklack/nvim-keymap-amend'
" TODO: Plug 'anuvyklack/pretty-fold.nvim'

" Formatting:
" ```````````
" TODO: https://github.com/sbdchd/neoformat

" Git:
" ````
Plug 'ruifm/gitlinker.nvim' " NOTE: Good plugin worth lazy loading
" TODO: Plug 'f-person/git-blame.nvim' " not working, needs review
" TODO: Plug 'lewis6991/gitsigns.nvim' " BUG: Conflicts with todo-comments
" TODO: Plug 'ruifm/gitlinker.nvim' " NOTE: Good plugin worth lazy loading
" TODO: https://github.com/APZelos/blamer.nvim
" TODO: https://github.com/TimUntersberger/neogit
" TODO: https://github.com/adelarsq/neovcs.vim
" TODO: https://github.com/hotwatermorning/auto-git-diff
" TODO: https://github.com/kdheepak/lazygit.nvim
" TODO: https://github.com/rhysd/git-messenger.vim
" TODO: https://github.com/sindrets/diffview.nvim
" TODO: https://github.com/sjl/splice.vim
" TODO: https://github.com/tanvirtin/vgit.nvim
" TODO: https://github.com/tommcdo/vim-fugitive-blame-ext
" TODO: https://github.com/tpope/vim-fugitive

" Highlight:
" ``````````
" TODO: https://github.com/rktjmp/highlight-current-n.nvim

" Icons:
" ``````
" TODO: https://github.com/kristijanhusak/defx-icons
" TODO: https://github.com/yamatsum/nvim-nonicons

" LSP:
" ````
Plug 'neovim/nvim-lspconfig' " {
    " TODO: Autocompletion
    " TODO: Code Actions
    " TODO: Linitng
    " TODO: Plug 'filipdutescu/renamer.nvim', { 'branch': 'master' }
    " TODO: Snippets
    " TODO: UI Customization
" }
Plug 'williamboman/nvim-lsp-installer'
Plug 'liuchengxu/vista.vim' " {
    " TODO: explore options
" }
Plug 'ray-x/lsp_signature.nvim' " {
    " TODO: explore options
" }
" TODO: https://github.com/RishabhRD/nvim-lsputils
" TODO: https://github.com/gfanto/fzf-lsp.nvim
" TODO: https://github.com/j-hui/fidget.nvim
" TODO: https://github.com/kwkarlwang/cmp-nvim-insert-text-lsp
" TODO: https://github.com/lukas-reineke/format.nvim
" TODO: https://github.com/nanotee/nvim-lsp-basics
" TODO: https://github.com/nvim-lua/lsp-status.nvim
" TODO: https://github.com/ojroques/nvim-lspfuzzy
" TODO: https://github.com/onsails/diaglist.nvim
" TODO: https://github.com/onsails/lspkind.nvim
" TODO: https://github.com/ray-x/navigator.lua
" TODO: https://github.com/rmagatti/goto-preview
" TODO: https://github.com/tami5/lspsaga.nvim --> https://github.com/glepnir/lspsaga.nvim
" TODO: https://github.com/weilbith/nvim-code-action-menu

" Mapping:
" ````````
" TODO: https://github.com/LionC/nest.nvim
" TODO: https://github.com/b0o/mapx.nvim

" Marks:
" ``````
" TODO: https://github.com/chentau/marks.nvim

" Quickfix:
" `````````
" TODO: https://github.com/stevearc/qf_helper.nvim

" Rooter:
" ```````
" TODO: https://github.com/shaeinst/penvim
" TODO: https://github.com/nyngwang/NeoRoot.lua

" Session Manager:
" ````````````````
" TODO: https://github.com/Shatur/neovim-session-manager
" TODO: https://github.com/olimorris/persisted.nvim
" TODO: https://github.com/rmagatti/auto-session

" Snippets:
" `````````
" TODO: https://github.com/L3MON4D3/LuaSnip
" TODO: https://github.com/dcampos/nvim-snippy
" TODO: https://github.com/ellisonleao/carbon-now.nvim
" TODO: https://github.com/hrsh7th/vim-vsnip
" TODO: https://github.com/neoclide/coc-snippets
" TODO: https://github.com/norcalli/snippets.nvim
" TODO: https://github.com/rafamadriz/friendly-snippets

" Status Line:
" ````````````
Plug 'beauwilliams/statusline.lua' " {
    " BUG: Slowness observed
    " TODO: Explore more
" }
" TODO: https://github.com/NTBBloodbath/galaxyline.nvim
" TODO: https://github.com/akinsho/bufferline.nvim
" TODO: https://github.com/b0o/incline.nvim
" TODO: https://github.com/datwaft/bubbly.nvim
" TODO: https://github.com/feline-nvim/feline.nvim
" TODO: https://github.com/glepnir/galaxyline.nvim
" TODO: https://github.com/itchyny/lightline.vim
" TODO: https://github.com/konapun/vacuumline.nvim
" TODO: https://github.com/noib3/nvim-cokeline
" TODO: https://github.com/nvim-lualine/lualine.nvim
" TODO: https://github.com/ojroques/nvim-hardline
" TODO: https://github.com/ojroques/nvim-hardline
" TODO: https://github.com/tamton-aquib/staline.nvim
" TODO: https://github.com/windwp/windline.nvim

" Syntax:
" ```````
" TODO: https://github.com/tbastos/vim-lua " Lua syntax

" Tab Line:
" `````````
" TODO: https://github.com/alvarosevilla95/luatab.nvim
" TODO: https://github.com/bagrat/vim-buffet
" TODO: https://github.com/crispgm/nvim-tabline
" TODO: https://github.com/kdheepak/tabline.nvim
" TODO: https://github.com/rafcamlet/tabline-framework.nvim
" TODO: https://github.com/romgrk/barbar.nvim

" Telescope:
" ``````````
Plug 'nvim-telescope/telescope.nvim'
" TODO: https://github.com/LinArcX/telescope-command-palette.nvim
" TODO: https://github.com/camspiers/snap
" TODO: https://github.com/nvim-telescope/telescope-hop.nvim
" TODO: https://github.com/nvim-telescope/telescope-packer.nvim
" TODO: https://github.com/nvim-telescope/telescope-vimspector.nvim
" TODO: https://github.com/voldikss/vim-floaterm

" Terminal:
" `````````
" TODO: https://github.com/akinsho/toggleterm.nvim
" TODO: https://github.com/nikvdp/neomux
" TODO: https://github.com/numToStr/FTerm.nvim
" TODO: https://github.com/oberblastmeister/termwrapper.nvim
" TODO: https://github.com/pianocomposer321/consolation.nvim

" Todo:
" `````
" Plug 'folke/todo-comments.nvim' " {
    " BUG: Can not handle multiple todos in same line
    " BUG: Makes vim scrolling slow
" }
" TODO: Quickfix
" TODO: Search
" TODO: Telescope
" TODO: Trouble

" Treesitter:
" ```````````
Plug 'nvim-treesitter/nvim-treesitter' " {
    " TODO: Folding
    " TODO: Incremental selection
    " TODO: Indentation
    " TODO: Wiki
" }
" Plug 'romgrk/nvim-treesitter-context' " {
    " BUG: Its buggy in windows
" }
" TODO: https://github.com/RRethy/nvim-treesitter-endwise
" TODO: https://github.com/RRethy/nvim-treesitter-textsubjects
" TODO: https://github.com/lewis6991/spellsitter.nvim
" TODO: https://github.com/m-demare/hlargs.nvim
" TODO: https://github.com/mfussenegger/nvim-treehopper
" TODO: https://github.com/nvim-treesitter/nvim-treesitter-context
" TODO: https://github.com/nvim-treesitter/nvim-treesitter-refactor
" TODO: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
" TODO: https://github.com/p00f/nvim-ts-rainbow

" TUI:
" ````
" TODO: https://github.com/rcarriga/nvim-notify

" Utilities:
" ``````````
Plug 'tversteeg/registers.nvim' " Displays registers on ^R and \" {
    let g:registers_window_border = "rounded"
    " TODO: Check if height can be reduced
" }
" Plug 'nacro90/numb.nvim' " Peek number line while jumping
Plug 'MunifTanjim/nui.nvim'
Plug 'folke/trouble.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'

" TODO: Plug 'booperlv/nvim-gomove'
" TODO: Plug 'folke/which-key.nvim'
" TODO: Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
" TODO: Plug 'gennaro-tedesco/nvim-peekup'
" TODO: Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" TODO: Plug 'haringsrob/nvim_context_vt' " NOTE: Good but should be off by default
" TODO: Plug 'jbyuki/one-small-step-for-vimkind'
" TODO: Plug 'jbyuki/venn.nvim'
" TODO: Plug 'kevinhwang91/nvim-hlslens'
" TODO: Plug 'rktjmp/lush.nvim'
" TODO: Plug 'wbthomason/packer.nvim'
" TODO: https://github.com/AndrewRadev/switch.vim
" TODO: https://github.com/AndrewRadev/tagalong.vim
" TODO: https://github.com/D0n9X1n/quickrun.vim
" TODO: https://github.com/michaelb/sniprun
" TODO: https://github.com/mrjones2014/legendary.nvim
" TODO: https://github.com/FeiyouG/command_center.nvim
" TODO: https://github.com/Iron-E/nvim-bufmode
" TODO: https://github.com/Iron-E/nvim-libmodal
" TODO: https://github.com/Iron-E/nvim-marktext
" TODO: https://github.com/Iron-E/nvim-tabmode
" TODO: https://github.com/Iron-E/vim-libmodal
" TODO: https://github.com/MattesGroeger/vim-bookmarks
" TODO: https://github.com/NTBBloodbath/rest.nvim
" TODO: https://github.com/Pocco81/AbbrevMan.nvim
" TODO: https://github.com/Pocco81/TrueZen.nvim
" TODO: https://github.com/SmiteshP/nvim-gps
" TODO: https://github.com/TaDaa/vimade
" TODO: https://github.com/ThePrimeagen/harpoon
" TODO: https://github.com/ThemerCorp/themer.lua
" TODO: https://github.com/VonHeikemen/fine-cmdline.nvim
" TODO: https://github.com/VonHeikemen/searchbox.nvim
" TODO: https://github.com/WolfgangMehner/vim-plugins
" TODO: https://github.com/Yilin-Yang/vim-markbar
" TODO: https://github.com/adelarsq/vim-emoji-icon-theme
" TODO: https://github.com/ahmedkhalf/project.nvim
" TODO: https://github.com/bennypowers/nvim-regexplainer
" TODO: https://github.com/bfredl/nvim-luadev
" TODO: https://github.com/bignimbus/you-are-here.vim
" TODO: https://github.com/chrisbra/NrrwRgn
" TODO: https://github.com/coc-extensions/coc-powershell
" TODO: https://github.com/craigemery/vim-autotag
" TODO: https://github.com/danymat/neogen
" TODO: https://github.com/folke/twilight.nvim
" TODO: https://github.com/rafcamlet/nvim-luapad
" TODO: https://github.com/glacambre/firenvim
" TODO: https://github.com/haya14busa/is.vim
" TODO: https://github.com/haya14busa/vim-asterisk
" TODO: https://github.com/hoschi/yode-nvim
" TODO: https://github.com/paretje/nvim-man
" TODO: https://github.com/jpalardy/vim-slime
" TODO: https://github.com/jsfaint/gen_tags.vim
" TODO: https://github.com/junegunn/fzf
" TODO: https://github.com/junegunn/goyo.vim
" TODO: https://github.com/junegunn/vim-easy-align
" TODO: https://github.com/junegunn/vim-peekaboo
" TODO: https://github.com/junegunn/vim-slash
" TODO: https://github.com/kassio/neoterm
" TODO: https://github.com/kosayoda/nvim-lightbulb
" TODO: https://github.com/kshenoy/vim-signature
" TODO: https://github.com/lambdalisue/glyph-palette.vim
" TODO: https://github.com/lambdalisue/nerdfont.vim
" TODO: https://github.com/lifepillar/vim-colortemplate
" TODO: https://github.com/lifepillar/vim-mucomplete
" TODO: https://github.com/liuchengxu/vim-clap
" TODO: https://github.com/machakann/vim-highlightedyank
" TODO: https://github.com/markonm/traces.vim
" TODO: https://github.com/matveyt/neoclip
" TODO: https://github.com/mengelbrecht/lightline-bufferline
" TODO: https://github.com/mhartington/formatter.nvim
" TODO: https://github.com/mhinz/vim-galore
" TODO: https://github.com/mhinz/vim-signify
" TODO: https://github.com/michaelb/sniprun
" TODO: https://github.com/milisims/nvim-luaref
" TODO: https://github.com/monkoose/matchparen.nvim
" TODO: https://github.com/mrjones2014/legendary.nvim
" TODO: https://github.com/narajaon/onestatus
" TODO: https://github.com/nvim-orgmode/orgmode
" TODO: https://github.com/nyngwang/NeoRoot.lua
" TODO: https://github.com/p00f/nvim-ts-rainbow
" TODO: https://github.com/pacha/vem-tabline
" TODO: https://github.com/pechorin/any-jump.vim
" TODO: https://github.com/phaazon/hop.nvim
" TODO: https://github.com/pianocomposer321/yabs.nvim
" TODO: https://github.com/puremourning/vimspector
" TODO: https://github.com/rafcamlet/nvim-luapad
" TODO: https://github.com/renerocksai/telekasten.nvim
" TODO: https://github.com/rhysd/conflict-marker.vim
" TODO: https://github.com/rickhowe/spotdiff.vim
" TODO: https://github.com/rktjmp/lush.nvim
" TODO: https://github.com/romainl/vim-cool
" TODO: https://github.com/sbdchd/neoformat
" TODO: https://github.com/sheerun/vim-polyglot
" TODO: https://github.com/sidebar-nvim/sidebar.nvim
" TODO: https://github.com/sillybun/vim-repl
" TODO: https://github.com/simnalamburt/vim-mundo
" TODO: https://github.com/skywind3000/gutentags_plus
" TODO: https://github.com/skywind3000/vim-quickui
" TODO: https://github.com/srstevenson/vim-picker
" TODO: https://github.com/stevearc/aerial.nvim
" TODO: https://github.com/stevearc/dressing.nvim
" TODO: https://github.com/stsewd/sphinx.nvim
" TODO: https://github.com/sudormrfbin/cheatsheet.nvim
" TODO: https://github.com/sunjon/stylish.nvim
" TODO: https://github.com/svermeulen/vimpeccable
" TODO: https://github.com/terryma/vim-multiple-cursors
" TODO: https://github.com/thaerkh/vim-workspace
" TODO: https://github.com/tjdevries/nlua.nvim
" TODO: https://github.com/dbeniamine/cheat.sh-vim
" TODO: https://github.com/gaborvecsei/cryptoprice.nvim
" TODO: https://github.com/tyru/caw.vim
" TODO: https://github.com/urbainvaes/vim-ripple
" TODO: https://github.com/vim-scripts/Conque-GDB
" TODO: https://github.com/vim-scripts/ShowMarks
" TODO: https://github.com/vscode-neovim/vscode-neovim
" TODO: https://github.com/vwxyutarooo/nerdtree-devicons-syntax
" TODO: https://github.com/wellle/context.vim
" TODO: https://github.com/whiteinge/diffconflicts
" TODO: https://github.com/mfussenegger/nvim-lint
" TODO: https://github.com/jose-elias-alvarez/null-ls.nvim

" Word Highlight:
" ```````````````
Plug 'RRethy/vim-illuminate' " {
    " BUG: highlight colors are not good
    hi def link LspReferenceText WildMenu
    hi def link LspReferenceWrite WildMenu
    hi def link LspReferenceRead WildMenu
" }
" TODO: Plug 'xiyaowong/nvim-cursorword'
" TODO: Plug 'yamatsum/nvim-cursorline'
" TODO: https://github.com/dominikduda/vim_current_word

" Archived:
" TODO: https://github.com/AllenDang/nvim-expand-expr
" TODO: https://github.com/LoricAndre/fzterm.nvim
" TODO: https://github.com/RishabhRD/nvim-cheat.sh
" TODO: https://github.com/amirrezaask/fuzzy.nvim
" TODO: https://github.com/andymass/vim-matchup
" TODO: https://github.com/anuvyklack/pretty-fold.nvim
" TODO: https://github.com/bennypowers/nvim-regexplainer
" TODO: https://github.com/folke/lua-dev.nvim
" TODO: https://github.com/frabjous/knap
" TODO: https://github.com/gaborvecsei/memento.nvim
" TODO: https://github.com/gbprod/substitute.nvim
" TODO: https://github.com/gbprod/yanky.nvim
" TODO: https://github.com/gennaro-tedesco/nvim-jqx
" TODO: https://github.com/ggandor/leap.nvim
" TODO: https://github.com/henriquehbr/nvim-startup.lua " NOTE: startup time analyser
" TODO: https://github.com/ibhagwan/fzf-lua
" TODO: https://github.com/is0n/jaq-nvim
" TODO: https://github.com/jakewvincent/mkdnflow.nvim
" TODO: https://github.com/jameshiew/nvim-magic
" TODO: https://github.com/jamestthompson3/nvim-remote-containers
" TODO: https://github.com/jbyuki/instant.nvim
" TODO: https://github.com/jubnzv/mdeval.nvim
" TODO: https://github.com/jubnzv/virtual-types.nvim
" TODO: https://github.com/kevinhwang91/nvim-bqf
" TODO: https://github.com/kosayoda/nvim-lightbulb
" TODO: https://github.com/lukas-reineke/indent-blankline.nvim
" TODO: https://github.com/matbme/JABS.nvim
" TODO: https://github.com/max397574/better-escape.nvim
" TODO: https://github.com/mcauley-penney/tidy.nvim
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
  -- vim-illuminate
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

-- LSP Signature
require "lsp_signature".setup({})


-- Status Line
-- ```````````
local statusline = require('statusline')
statusline.tabline = false

-- Todo-comments
-- `````````````
-- require("todo-comments").setup {}

-- Treesitter
-- ``````````
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    }
}

require("nebulous").setup { variant = "night" }

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


" UI Options:
" ```````````
" {{{
let g:netrw_banner = 0        " Turn off banner in netrw
set background=light           " Select appropriate colors for dark or light
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
colorscheme nebulous            " Set colorscheme 
" highlight clear CursorLine   " No underline on text when cursorline is on
" highlight clear CursorLineNR " No underline on line numbers when cursorline is on
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

" TODO:Highlight text if it goes out of scope
    " highlight ColorColumn ctermbg=white
    " call matchadd('ColorColumn', '\%8v', 100)
augroup vimrc_autocmds
  autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
  autocmd BufEnter * match OverLength /\%101v/
augroup END

set guifont=VictorMono_NF:h11

" vim: fdm=marker
