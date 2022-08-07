"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" {{{
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
" }}}

" Plugins:
" ````````
call plug#begin()
Plug 'windwp/windline.nvim'
Plug 'rstacruz/vim-closer'
Plug 'wbthomason/packer.nvim'
call plug#end()

lua require('plugins')
" augroup packer_user_config
"     autocmd!
"     autocmd BufWritePost plugins.lua source <afile> | PackerSync
" augroup end
autocmd FileType json colorscheme papercolor | highlight clear CursorLine | highlight clear CursorLineNR | set list!
autocmd FileType lua colorscheme papercolor | highlight clear CursorLine | highlight clear CursorLineNR | set list!
autocmd FileType norg colorscheme one-nvim | highlight clear CursorLine | highlight clear CursorLineNR
autocmd FileType ps1 colorscheme ayu | highlight clear CursorLine | highlight clear CursorLineNR
autocmd FileType python colorscheme one-nvim | highlight clear CursorLine | highlight clear CursorLineNR
autocmd FileType vim colorscheme zephyr | highlight clear CursorLine | highlight clear CursorLineNR

lua << EOF
require('wlsample.bubble')
EOF

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
set background=dark          " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=space:·,tab:>-       " Show space as ·, tab as clear spaces
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
" }}}
colorscheme nightfox       " Set colorscheme
highlight clear CursorLine   " No underline on text when cursorline is on
highlight clear CursorLineNR " No underline on line numbers when cursorline is on


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

" {{{
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
" }}}


" UI Client:
" ``````````
set guifont=VictorMono_NF:h13
let g:neovide_cursor_vfx_mode = "pixiedust"
let g:neovide_cursor_vfx_particle_lifetime=2
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 2.0
let g:neovide_remember_window_size = v:true
" let g:neovide_transparency=0.9

" vim: fdm=marker
