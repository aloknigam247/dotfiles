﻿"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Plugins      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
" call plug#begin()
" call plug#end()
" lua require('plugins')
autocmd FileType lua lua require('plugins')
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Variables     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let &titleold             = getcwd() " Set console title to path on vim exit
let c_curly_error         = 1        " Show curly braces error
" let c_space_errors      = 1        " Highlight trailing spaces
let g:diff_translations   = 0        " Disables localisations and speeds up syntax highlighting in diff mode
let g:load_doxygen_syntax = 1        " Recognize doxygen comment style
let g:netrw_liststyle     = 3        " Set netrw style as tree
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Config Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set autowrite             " Auto write changes
set clipboard=unnamedplus " Use + clipboard buffer
set foldnestmax=2         " Max fold level
set nobackup              " Do not create backup file
set path+=**              " Look for all files in sub dirs
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Editor Settings  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set bomb                              " Keep the BOM file marker
set breakindent                       " Every wrapped line will continue visually indented
set completeopt=menu,menuone,noselect " For nvim-cmp
set cpoptions+=Z                      " When using w! while the 'readonly' option is set, don't reset 'readonly'
set expandtab                         " Convert tabs to spaces
" set formatoptions=tcroqwanvbl1jp      " Set auto formating options 'fo-table'
set history=1000                      " Increase undo limit
set linebreak                         " Break wrapped line at 'breakat'
set nofixendofline                    " Do not change end of line
set noswapfile                        " Disable swap files
set nowritebackup                     " Disable intermediate backup file
set shiftwidth=4                      " When shifting, indent using spaces
set tabstop=4                         " Indent using spaces
set textwidth=100                     " Set text width to 100
set wrap                              " Enable wrap
set wrapmargin=0                      " Disable wrap margin
setglobal bomb                        " Keep the BOM file marker
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   UI Settings    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let g:netrw_banner = 0       " Turn off banner in netrw
let g:vimsyn_embed = 'lpr'   " embededded script highlight
set background=light         " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set cmdheight=0              " Hide command line
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set inccommand=split         " Show effects of command in preview windows
set fillchars=fold:\         " No dot characters in fold
set laststatus=2             " Disable global statusline
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=lead:·,trail:•,multispace:·,tab:»\ ,nbsp:⦸,extends:»,precedes:«
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
"set ttymouse=sgr            " Fix mouse support in half screen
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
set wildignore="*.exe"       " Files to ignore in wildmenu
set wildignorecase           " Ignore case
set wildmenu                 " Enable wild menu
set winblend=10              " pseudo-transparency effect for float window
colorscheme dayfox           " Set colorscheme
"hi NonText guifg=grey70 guibg=#e4e4e4
highlight clear CursorLine   " No underline on text when cursorline is on
" highlight clear CursorLineNR " No underline on line numbers when cursorline is on
sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Search Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive when query contains an uppercase letter
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Filetype Options ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
autocmd BufNewFile,BufRead *.qel set filetype=tcl       " Set qel filetype as tcl
autocmd BufNewFile,BufRead *.cyt set filetype=sh        " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.make set filetype=make     " Set make filetype as Makefile
autocmd BufNewFile,BufRead *.v set filetype=verilog     " Set .v filetype as bash
autocmd BufNewFile,BufRead *.vg set filetype=verilog    " Set cyt filetype as bash

" Filetype functions
function! FT_settings(scheme)
    execute "colorscheme " .. a:scheme
    hi NonText guifg=grey70 guibg=#e4e4e4
    highlight clear CursorLine
    highlight clear CursorLineNR
endfunction

" Filetype autocommands
"autocmd FileType lua call FT_settings("morning")

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
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Mappings     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       GUI        ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set guifont=VictorMono_NF:h13
let g:neovide_cursor_vfx_mode = "pixiedust"
let g:neovide_cursor_vfx_particle_lifetime=2
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 2.0
let g:neovide_remember_window_size = v:true
let g:neovide_transparency=0.95
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       MISC       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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


" highlight ColorColumn ctermbg=white
" call matchadd('ColorColumn', '\%101v', 100)
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%101v/
" augroup END

let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
set shellquote= shellxquote=


let g:startuptime_event_width = 0

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
function! SynT()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
lua << EOF
-- Blink on yank
-- au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true}
vim.api.nvim_create_autocmd(
	"TextYankPost",
	{
		desc = "highlight text on yank",
		pattern = "*",
		group = group,
		callback = function()
			vim.highlight.on_yank {
				higroup="ColorColumn", timeout=300, on_visual=true
			}
		end,
	}
)
EOF
" }}}

" vim: fdm=marker
