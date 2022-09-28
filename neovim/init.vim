"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" {{{
" TODO: blink on yank
" au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true} " Highlight on yank
" TODO: http://blog.ezyang.com/2010/03/vim-textwidth/
" Options from abstract ide
" opt.listchars = {
" 	nbsp = '⦸', -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
" 	extends = '»', -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
" 	precedes = '«', -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
" 	tab = '  ', -- '▷─' WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + BOX DRAWINGS HEAVY TRIPLE DASH HORIZONTAL (U+2505, UTF-8: E2 94 85)
" 	trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
" 	space = ' ',
" }
" opt.fillchars = {
" 	diff = '∙', -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
" 	eob = ' ', -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
" 	fold = '·', -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
" 	vert = '│', -- window border when window splits vertically ─ ┴ ┬ ┤ ├ ┼
" }
" 
" opt.scrolloff = 1 -- when scrolling, keep cursor 1 lines away from screen border
" opt.shiftround = true
" opt.inccommand = 'split' -- live preview of :s results
" opt.shell = 'zsh' -- shell to use for `!`, `:!`, `system()` etc.
" opt.wildignore = vim.opt.wildignore + '*.o,*.rej,*.so' -- patterns to ignore during file-navigation
" 
" api.nvim_create_autocmd(
" 	"TextYankPost",
" 	{
"         desc = "highlight text on yank",
"         pattern = "*",
" 		group = group,
"         callback = function()
" 			vim.highlight.on_yank {
" 				higroup="Search", timeout=150, on_visual=true
" 			}
"         end,
" 	}
" )
" }}}

" Plugins:
" ````````
call plug#begin()
call plug#end()

lua require('plugins')
" augroup packer_user_config
"     autocmd!
"     autocmd BufWritePost plugins.lua source <afile> | PackerSync
" augroup end

" Light
autocmd FileType lua colorscheme morning | highlight clear CursorLine | highlight clear CursorLineNR | set list!

" Dark
" autocmd FileType cpp colorscheme zephyr | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType cs colorscheme nightfox | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType gitcommit colorscheme falcon | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType json colorscheme papercolor | highlight clear CursorLine | highlight clear CursorLineNR | set list!
" " autocmd FileType lua colorscheme one_monokai | highlight clear CursorLine | highlight clear CursorLineNR | set list!
" autocmd FileType lua colorscheme onedarkpro | highlight clear CursorLine | highlight clear CursorLineNR | set list!
" autocmd FileType markdown colorscheme edge | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType make colorscheme one-nvim | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType norg colorscheme one-nvim | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType ps1 colorscheme ayu | highlight clear CursorLine | highlight clear CursorLineNR
" " autocmd FileType python colorscheme one-nvim | highlight clear CursorLine | highlight clear CursorLineNR
" " autocmd FileType python colorscheme zephyr | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType python colorscheme monokai_soda | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType sh colorscheme zephyr | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType vim colorscheme one_monokai | highlight clear CursorLine | highlight clear CursorLineNR
" autocmd FileType xml colorscheme ayu | highlight clear CursorLine | highlight clear CursorLineNR

lua << EOF
--require('neo-tree').setup{filesystem {hijack_netrw_behavior = "open_current"}}
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
set bomb                              " Keep the BOM file marker
set breakindent                       " Every wrapped line will continue visually indented
set completeopt=menu,menuone,noselect " for nvim-cmp
set cpoptions+=Z                      " When using w! while the 'readonly' option is set, don't reset 'readonly'
set expandtab                         " Convert tabs to spaces
set formatoptions=tcroqwanvbl1jp      " Set auto formating options 'fo-table'
set history=1000                      " Increase undo limit
set linebreak                         " Break wrapped line at 'breakat'
set noswapfile                        " Disable swap files
set nowritebackup                     " Disable intermediate backup file
set shiftwidth=4                      " When shifting, indent using spaces
set tabstop=4                         " Indent using spaces
set textwidth=100                     " Set text width to 100
set wrap                              " Enable wrap
set wrapmargin=0                      " Disable wrap margin
setglobal bomb                        " Keep the BOM file marker
" }}}


" UI Options:
" ```````````
" {{{
let g:netrw_banner = 0       " Turn off banner in netrw
let g:vimsyn_embed = 'lpr'   " embededded script highlight
set background=light          " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set laststatus=3             " Global statusline
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
" set lcs=lead:·,trail:·,multispace:·,tab:<->   " Show space as ·, tab as clear spaces
set lcs=tab:<->               " Show space as ·, tab as clear spaces
set list                     " Show special characters
set mouse=a                  " Enable mouse support
set noshowmode               " Don't show INSERT/NOMRAL/VISUAL modes
set number                   " Enable line number
set pumblend=10              " pseudo-transparency effect for popup-menu
set shortmess=aoOtT          " Short messages
set signcolumn=auto:9        " Set max size of signcolumn
set splitbelow               " Place new window below on :split
set splitright               " Place new window right on :vsplit
set termguicolors            " Enable true colors support
set title                    " Set console title
"set ttymouse=sgr             " Fix mouse support in half screen
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
set winblend=10              " pseudo-transparency effect for float window
colorscheme morning       " Set colorscheme
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
imap <C-Left> <C-\><C-O>B
imap <C-Right> <C-\><C-O>E<C-\><C-O>l
imap <C-a> <C-\><C-O>^
imap <C-e> <C-\><C-O>$
map <C-Left> B
map <C-Right> E
map <C-a> ^
map <C-e> $
" usefull mapping
" gq format lines
" gw format lines with cursor remains at same place
" vip select paragraph
" }}}

" {{{
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

" highlight ColorColumn ctermbg=white
" call matchadd('ColorColumn', '\%8v', 100)
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%101v/
" augroup END
" }}}

hi def IlluminatedWordText gui=underline
hi def IlluminatedWordRead gui=underline
hi def IlluminatedWordWrite gui=underline
hi def link LspReferenceText WildMenu
hi def link LspReferenceWrite WildMenu
hi def link LspReferenceRead WildMenu

" UI Client:
" ``````````
set guifont=VictorMono_NF:h13
let g:neovide_cursor_vfx_mode = "pixiedust"
let g:neovide_cursor_vfx_particle_lifetime=2
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 2.0
let g:neovide_remember_window_size = v:true
let g:neovide_transparency=0.95

" vim: fdm=marker
