"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" Plugins - Vim-plug
" ``````````````````
" {{{
call plug#begin()

Plug 'https://github.com/adelarsq/neoline.vim'

Plug 'akinsho/toggleterm.nvim'

" Colorshemes
    Plug 'rktjmp/lush.nvim'
Plug 'adisen99/codeschool.nvim'

call plug#end()
" }}}

lua << EOF
require("toggleterm").setup{
    direction = 'float'
}
EOF

" codeschool
lua << EOF
require('lush')(require('codeschool').setup({
  plugins = {
    "buftabline",
    "coc",
    "cmp", -- nvim-cmp
    "fzf",
    "gitgutter",
    "gitsigns",
    "lsp",
    "lspsaga",
    "nerdtree",
    "netrw",
    "nvimtree",
    "neogit",
    "packer",
    "signify",
    "startify",
    "syntastic",
    "telescope",
    "treesitter"
  },
  langs = {
    "c",
    "clojure",
    "coffeescript",
    "csharp",
    "css",
    "elixir",
    "golang",
    "haskell",
    "html",
    "java",
    "js",
    "json",
    "jsx",
    "lua",
    "markdown",
    "moonscript",
    "objc",
    "ocaml",
    "purescript",
    "python",
    "ruby",
    "rust",
    "scala",
    "typescript",
    "viml",
    "xml"
  }
}))
EOF


" Variables
" `````````
" {{{
let &titleold             = getcwd() " Set console title to path on vim exit
let c_curly_error         = 1        " Show curly braces error
let c_space_errors        = 1        " Highlight trailing spaces
let g:diff_translations   = 0        " Disables localisations and speeds up syntax highlighting in diff mode
let g:load_doxygen_syntax = 1        " Recognize doxygen comment style
let g:netrw_liststyle     = 3        " Set netrw style as tree
" }}}


" Config Options
" ``````````````
" {{{
set autowrite             " Auto write changes
set clipboard=unnamedplus " Use + clipboard buffer
set foldnestmax=2         " Max fold level
set nobackup              " Do not create backup file
set path+=**              " Look for all files in sub dirs
" }}}


" Editor Settings
" ```````````````
" {{{
set breakindent  " Every wrapped line will continue visually indented
set cpoptions+=Z " When using w! while the 'readonly' option is set,don't reset 'readonly'
set expandtab    " Convert tabs to spaces
set history=1000 " Increase undo limit
set shiftwidth=4 " When shifting, indent using spaces
set tabstop=4    " Indent using spaces
" }}}


" UI Options
" ``````````
" {{{
let g:netrw_banner = 0        " Turn off banner in netrw
set background=dark           " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical split
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
"set lcs=space:·,tab:>-       " Show space as ·, tab as clear spaces
"set list                     " Show special characters
set mouse=a                  " Enable mouse support
set noshowmode               " Don't show INSERT/NOMRAL/VISUAL modes
set number                   " Enable line number
set shortmess=aoOtT          " Short messages
set splitbelow               " Place new window below on :split
set splitright               " Place new window right on :vsplit
set termguicolors            " Enable true colors support
set title                    " Set console title
"set ttymouse=sgr             " Fix mouse support in half screen
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
colorscheme codeschool       " Set colorscheme 
highlight clear CursorLine   " No underline on text when cursorline is on
highlight clear CursorLineNR " No underline on line numbers when cursorline is on
" }}}


" Search Options
" ``````````````
" {{{
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive when query contains an uppercase letter
" }}}

" Filetype Specific Options
" `````````````````````````
" {{{
autocmd BufNewFile,BufRead *.qel set filetype=tcl " Set qel filetype as tcl
autocmd BufNewFile,BufRead *.cyt set filetype=sh  " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.make set filetype=make  " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.v set filetype=verilog  " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.vg set filetype=verilog  " Set cyt filetype as bash
" }}}


" Mappings
" ````````
" {{{
map <C-a> ^
map <C-e> $
" }}}

let g:termdebug_wide = 163
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif " remember file position when closed
autocmd FilterWritePre * if &diff | setlocal wrap< | endif
autocmd VimLeave * let &t_me="\e[0 q" " resets cursor

" vim: fdm=marker
