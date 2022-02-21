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
Plug 'wbthomason/packer.nvim'
Plug 'RRethy/vim-illuminate'

" Glow markdown preview
" Plug 'ellisonleao/glow.nvim'

Plug 'karb94/neoscroll.nvim'

Plug 'glepnir/indent-guides.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

" Plug 'terrortylor/nvim-comment'
" Plug 'winston0410/commented.nvim'
" Plug 'yamatsum/nvim-cursorline'
" Plug 'xiyaowong/nvim-cursorword'

" wilder
  function! UpdateRemotePlugins(...)
    " Needed to refresh runtime files
    let &rtp=&rtp
    UpdateRemotePlugins
  endfunction

Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }

Plug 'beauwilliams/focus.nvim'

" alternative to vim-commentary
Plug 'b3nj5m1n/kommentary'

" Plug 'beauwilliams/statusline.lua'
Plug 'windwp/windline.nvim'

" Plug 'anuvyklack/pretty-fold.nvim'

" Colorshemes
" Plug 'EdenEast/nightfox.nvim'
"    Plug 'rktjmp/lush.nvim'
" Plug 'adisen99/codeschool.nvim'
" Plug 'yashguptaz/calvera-dark.nvim'
" let g:calvera_italic_comments = 1
" let g:calvera_italic_keywords = 1
" let g:calvera_italic_functions = 1
" let g:calvera_contrast = 1
"  Plug 'tjdevries/colorbuddy.vim'
"Plug 'bkegley/gloombuddy'
"Plug 'nvim-treesitter/nvim-treesitter'
"Plug 'glepnir/zephyr-nvim'
Plug 'shaunsingh/nord.nvim'

    Plug 'kyazdani42/nvim-web-devicons'
Plug 'goolord/alpha-nvim'
" Plug 'startup-nvim/startup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'
call plug#end()
" }}}

"wilder config
call wilder#setup({'modes': [':', '/', '?']})
call wilder#set_option('renderer', wilder#popupmenu_renderer({
      \ 'highlighter': wilder#basic_highlighter(),
      \ }))

" plugins.lua content in init.vim
lua << EOLUA
require('neoscroll').setup()

require('indent_guides').setup({
  even_colors = { fg ='#DCED31',bg='#0CCE6B' };
  odd_colors = {fg='#0CCE6B',bg='#DCED31'};
})
-- ensure that packer is installed
local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
    execute 'packadd packer.nvim'
end
vim.cmd('packadd packer.nvim')
local packer = require'packer'
local util = require'packer.util'
packer.init({
  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})
--- startup and add configure plugins
packer.startup(function()
  local use = use
  -- add you plugins here like:
  end
)
-- Shade
-- Illuminate
--  require'lspconfig'.gopls.setup {
--    on_attach = function(client)
--      -- [[ other on_attach code ]]
--      require 'illuminate'.on_attach(client)
--    end,
--  }
-- aplha-nvim
require("alpha").setup(require'alpha.themes.startify'.config)

-- focus.nvim
require("focus").setup()

-- windline
require('wlsample.airline_anim')
require('gitsigns').setup()
EOLUA


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
colorscheme nord         " Set colorscheme 
" highlight clear CursorLine   " No underline on text when cursorline is on
" highlight clear CursorLineNR " No underline on line numbers when cursorline is on
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
autocmd BufNewFile,BufRead *.qel set filetype=tcl       " Set qel filetype as tcl
autocmd BufNewFile,BufRead *.cyt set filetype=sh        " Set cyt filetype as bash
autocmd BufNewFile,BufRead *.make set filetype=make     " Set make filetype as Makefile
autocmd BufNewFile,BufRead *.v set filetype=verilog     " Set .v filetype as bash
autocmd BufNewFile,BufRead *.vg set filetype=verilog    " Set cyt filetype as bash
" }}}


" Mappings
" ````````
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

" vim: fdm=marker
