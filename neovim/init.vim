" THOUGHT: Should merge init.vim and init.lua ?
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Variables     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let &titleold = getcwd()           " Set console title to path on vim exit
let c_curly_error = 1              " Show curly braces error
let c_space_errors = 1             " Highlight trailing spaces
" let g:markdown_folding = 1         " Enable markdown folding
" let g:python_recommended_style = 0 " Disable inbuilt python tabs settings
" let g:diff_translations = 0        " Disables localisations and speeds up syntax highlighting in diff mode
" let g:load_doxygen_syntax = 1      " Recognize doxygen comment style
" let g:netrw_liststyle = 3          " Set netrw style as tree
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
" set bomb                              " Keep the BOM file marker
set breakindent                       " Every wrapped line will continue visually indented
set completeopt=menu,menuone,noselect " For nvim-cmp
set cpoptions+=Z                      " When using w! while the 'readonly' option is set, don't reset 'readonly'
set expandtab                         " Convert tabs to spaces
set formatoptions=/1cjlnor            " Set auto formating options 'fo-table'
set history=1000                      " Increase undo limit
set linebreak                         " Break wrapped line at 'breakat'
set nofixendofline                    " Do not change end of line
set noswapfile                        " Disable swap files
set nowritebackup                     " Disable intermediate backup file
set scrolloff=3                       " Set scrolloff to 3
set shiftwidth=4                      " When shifting, indent using spaces
" set spell                             " Enable spell check
set splitkeep=screen                  " Keep screen orientation same while splitting
set tabstop=4                         " Indent using spaces
set textwidth=80                     " Set text width to 100 " FIX: What should be its value
set wrap                              " Enable wrap
set updatetime=500                    " CursorHold time
set wrapmargin=0                      " Disable wrap margin
" setglobal bomb                        " Keep the BOM file marker
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   UI Settings    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let g:netrw_banner = 0       " Turn off banner in netrw
let g:vimsyn_embed = 'lpr'   " embededded script highlight
" set background=light         " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set cmdheight=0              " Hide command line
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set inccommand=split         " Show effects of command in preview windows
set fillchars=fold:\         " No dot characters in fold
" set foldmethod=marker        " Set fold method to marker
set laststatus=3             " Disable global statusline
set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=lead:·,trail:•,multispace:·,tab:˜˜,nbsp:⦸,extends:»,precedes:«
set list                     " Show special characters
set mouse=a                  " Enable mouse support
set noshowmode               " Don't show INSERT/NOMRAL/VISUAL modes
set number                   " Enable line number
set pumblend=10              " pseudo-transparency effect for popup-menu
set shortmess=FIWmno         " Short messages
set signcolumn=auto:9        " Set max size of signcolumn
set splitbelow               " Place new window below on :split
set splitright               " Place new window right on :vsplit
set termguicolors            " Enable true colors support
set title                    " Set console title
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
set wildignore="*.exe"       " Files to ignore in wildmenu
set wildignorecase           " Ignore case
set wildmenu                 " Enable wild menu
set winblend=10              " pseudo-transparency effect for float window
sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Search Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive when query contains an uppercase letter
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Mappings     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
" FIX: mapping from https://github.com/chrisgrieser/nvim-spider
imap <C-Left> <C-\><C-O>B
imap <C-Right> <C-\><C-O>E<C-\><C-O>a
map <C-Left> B
map <C-Right> E
" usefull mapping
" gq format lines
" gw format lines with cursor remains at same place
" vip select paragraph
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       GUI        ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
if exists("g:neovide")
    " let g:neovide_cursor_animation_length=0.13
    let g:neovide_cursor_animation_length=0
    " let g:neovide_cursor_trail_size = 0.8
    " let g:neovide_cursor_vfx_mode = "railgun"
    " let g:neovide_cursor_vfx_particle_density = 15.0
    " let g:neovide_cursor_vfx_particle_lifetime=5
    " let g:neovide_floating_blur_amount_x = 2.0
    " let g:neovide_floating_blur_amount_y = 10.0
    let g:neovide_fullscreen = v:false
    " let g:neovide_refresh_rate = 120
    let g:neovide_remember_window_size = v:false
    let g:neovide_scroll_animation_length = 0.0
    let g:neovide_transparency=1
    " let g:neovide_underline_automatic_scaling = v:true
    lua << EOF
        Font_size = 15
        vim.o.guifont = 'VictorMono_NF:h' .. Font_size
        vim.keymap.set('n', '<C-ScrollWheelUp>', function() Font_size = Font_size + 1; vim.o.guifont = 'VictorMono_NF:h' .. Font_size end)
        vim.keymap.set('n', '<C-ScrollWheelDown>', function() Font_size = Font_size - 1; vim.o.guifont = 'VictorMono_NF:h' .. Font_size end)
EOF
    map <F11> :execute "let g:neovide_fullscreen = xor(g:neovide_fullscreen, v:true)"<CR>
endif
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
" TODO: Fix cursor shape on vim exit in zsh
    autocmd!
    autocmd VimLeave * set guicursor=a:ver20 " sets cursor to vertical bar
augroup END

" highlight ColorColumn ctermbg=white
" call matchadd('ColorColumn', '\%80v', 100)
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%80v/
" augroup END

" let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
let &shell = 'pwsh'
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
highlight ConflictMarkerBegin guibg=#2f7366
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guibg=#2f628e
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81

highlight HighlightURL gui=underline cterm=underline
lua require('init')

" NOTE: important format options
" / = do not insert comment on 'o' and 'O' when o is included and line does not start with comment
" 1 = don't break a line a after 1 letter word, try to break before it
" c = do auto wrapping at textwidth on comment only
" j = join comments without commentstring
" l = do not break line if lenght is more than textwidth when insert
" n = keep list indentations
" o = insert comment on 'o' and 'O'
" p = don't break line blindly at .
" r = insert comment on enter
" t = do auto wrapping at textwidth
" }}}
