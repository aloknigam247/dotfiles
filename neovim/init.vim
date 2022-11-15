"
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
lua << EOF
require('impatient')
vim.notify = require('notify')
function ColoRand()
    local colos = {
        { 'NeoSolarized', function() require('NeoSolarized').setup({ transparent = false }); vim.o.background = 'dark' end },
        { 'NeoSolarized', function() require('NeoSolarized').setup({ transparent = false }); vim.o.background = 'light' end },
        { 'OceanicNext' },
        { 'PaperColor', function() vim.o.background = 'dark' end },
        { 'PaperColor', function() vim.o.background = 'light' end },
        { 'adwaita', function() vim.o.background = 'dark' end },
        { 'adwaita', function() vim.o.background = 'light' end },
        { 'arctic' },
        { 'aurora' },
        { 'ayu-dark' },
        { 'ayu-light' },
        { 'ayu-mirage' },
        { 'barstrata' },
        { 'base2tone_cave_dark' },
        { 'base2tone_cave_light' },
        { 'base2tone_desert_dark' },
        { 'base2tone_desert_light' },
        { 'base2tone_drawbridge_dark' },
        { 'base2tone_drawbridge_light' },
        { 'base2tone_earth_dark' },
        { 'base2tone_earth_light' },
        { 'base2tone_evening_dark' },
        { 'base2tone_evening_light' },
        { 'base2tone_field_dark' },
        { 'base2tone_field_light' },
        { 'base2tone_forest_dark' },
        { 'base2tone_forest_light' },
        { 'base2tone_garden_dark' },
        { 'base2tone_garden_light' },
        { 'base2tone_heath_dark' },
        { 'base2tone_heath_light' },
        { 'base2tone_lake_dark' },
        { 'base2tone_lake_light' },
        { 'base2tone_lavender_dark' },
        { 'base2tone_lavender_light' },
        { 'base2tone_mall_dark' },
        { 'base2tone_mall_light' },
        { 'base2tone_meadow_dark' },
        { 'base2tone_meadow_light' },
        { 'base2tone_morning_dark' },
        { 'base2tone_morning_light' },
        { 'base2tone_motel_dark' },
        { 'base2tone_motel_light' },
        { 'base2tone_pool_dark' },
        { 'base2tone_pool_light' },
        { 'base2tone_porch_dark' },
        { 'base2tone_porch_light' },
        { 'base2tone_sea_dark' },
        { 'base2tone_sea_light' },
        { 'base2tone_space_dark' },
        { 'base2tone_space_light' },
        { 'base2tone_suburb_dark' },
        { 'base2tone_suburb_light' },
        { 'blue' },
        { 'calvera' },
        { 'carbonfox' },
        { 'catppuccin-frappe' },
        { 'catppuccin-latte' },
        { 'catppuccin-macchiato' },
        { 'catppuccin-mocha' },
        { 'codedark' },
        { 'darkblue' },
        { 'darkplus' },
        { 'dawnfox' },
        { 'dayfox' },
        { 'delek' },
        { 'desert' },
        { 'deus' },
        { 'duckbones' },
        { 'duskfox' },
        { 'edge', function() vim.g.background = 'dark' end },
        { 'edge', function() vim.g.background = 'light' end },
        { 'elflord' },
        { 'enfocado', function() vim.g.background = 'dark' end },
        { 'enfocado', function() vim.g.background = 'light' end },
        { 'evening' },
        { 'everforest', function() vim.g.background = 'dark' end },
        { 'everforest', function() vim.g.background = 'light' end },
        { 'falcon' },
        { 'fluoromachine' },
        { 'forestbones' },
        { 'github_dark' },
        { 'github_light' },
        { 'gruvbox-baby' },
        { 'gruvbuddy', function() vim.g.background = 'dark'  end },
        { 'gruvbuddy', function() vim.g.background = 'light'  end },
        { 'habamax' },
        { 'horizon' },
        { 'industry' },
        { 'jellybeans-nvim' },
        { 'juliana' },
        { 'kanagawa' },
        { 'kanagawabones' },
        { 'kimbox' },
        { 'koehler' },
        { 'lunaperche' },
        { 'material', function() vim.g.material_style = 'darker' end },
        { 'material', function() vim.g.material_style = 'deep ocean' end },
        { 'material', function() vim.g.material_style = 'lighter' end },
        { 'material', function() vim.g.material_style = 'oceanic' end },
        { 'material', function() vim.g.material_style = 'palenight' end },
        { 'melange', function() vim.g.background = 'dark' end },
        { 'melange', function() vim.g.background = 'light' end },
        { 'mellow' },
        { 'moonlight' },
        { 'morning' },
        { 'mosel' },
        { 'murphy' },
        { 'neobones' },
        { 'neon', function() vim.g.neon_style = 'dark' end },
        { 'neon', function() vim.g.neon_style = 'default' end },
        { 'neon', function() vim.g.neon_style = 'doom' end },
        { 'neon', function() vim.g.neon_style = 'light' end },
        { 'nightfox' },
        { 'noctis' },
        { 'nordbones' },
        { 'nordfox' },
        { 'oh-lucy' },
        { 'oh-lucy-evening' },
        { 'one-nvim' },
        { 'one_monokai' },
        { 'onebuddy', function() vim.g.background = 'dark' end },
        { 'onebuddy', function() vim.g.background = 'light' end },
        { 'onedarkpro', function() vim.g.background = 'dark' end },
        { 'onedarkpro', function() vim.g.background = 'dark'; require('onedarkpro').setup({dark_theme = 'onedark_dark'}) end },
        { 'onedarkpro', function() vim.g.background = 'light' end },
        { 'onenord', function() vim.g.background = 'dark' end },
        { 'onenord', function() vim.g.background = 'light' end },
        { 'pablo' },
        { 'peachpuff' },
        { 'quiet' },
        { 'randombones' },
        { 'ron' },
        { 'rose-pine' },
        { 'rose-pine', function() require('rose-pine').setup({dark_variant = 'main'}) end },
        { 'rose-pine', function() require('rose-pine').setup({dark_variant = 'moon'}) end },
        { 'rose-pine-dark' },
        { 'rose-pine-light' },
        { 'rosebones' },
        { 'seoulbones' },
        { 'shine' },
        { 'slate' },
        { 'sonokai', function() vim.g.sonokai_style = 'andromeda' end },
        { 'sonokai', function() vim.g.sonokai_style = 'atlantis' end },
        { 'sonokai', function() vim.g.sonokai_style = 'default' end },
        { 'sonokai', function() vim.g.sonokai_style = 'maia' end },
        { 'sonokai', function() vim.g.sonokai_style = 'shusia' end },
        { 'terafox' },
        { 'toast', function() vim.g.background = 'dark' end },
        { 'toast', function() vim.g.background = 'light' end },
        { 'tokyobones' },
        { 'tokyodark' },
        { 'torte' },
        { 'tundra' },
        { 'vimbones' },
        { 'vn-night' },
        { 'zellner' },
        { 'zenburned' },
        { 'zenwritten' },
        { 'zephyr' },
        { 'zephyrium' },
    }
    math.randomseed(os.time())
    local ind = math.random(0, table.getn(colos))
    local selection = colos[ind]
    local scheme = selection[1]
    local precmd = selection[2]
    if (precmd) then
        precmd()
    end
    vim.cmd.colorscheme(scheme)
    vim.notify("Colorscheme: " .. scheme, vim.log.levels.INFO, { minimum_width = 0, render = 'minimal' })
end

vim.api.nvim_create_user_command('ColoRand', ColoRand, { nargs = 0 })

vim.g.cmp_kinds = {
    Array = ' ',
    Boolean = ' ',
    Class = ' ',
    Color = ' ',
    Constant = ' ',
    Constructor = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = ' ',
    History = ' ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = ' ',
    Module = ' ',
    Namespace = ' ',
    Null = ' ',
    Number = ' ',
    Object = ' ',
    Operator = ' ',
    Options = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = ' ',
    String = ' ',
    Struct = ' ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = ' '
}
EOF

autocmd BufRead plugins.lua lua require('plugins')
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
set laststatus=3             " Disable global statusline
" set lazyredraw               " Don't redraw screen on macros, registers and other commands.
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
ColoRand
"hi NonText guifg=grey70 guibg=#e4e4e4
" highlight clear CursorLine   " No underline on text when cursorline is on
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
imap <C-Right> <C-\><C-O>E<C-\><C-O>a
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
let g:neovide_cursor_animation_length=0.13
let g:neovide_cursor_trail_size = 0.8
let g:neovide_cursor_vfx_mode = "railgun"
let g:neovide_cursor_vfx_particle_density = 15.0
let g:neovide_cursor_vfx_particle_lifetime=5
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 10.0
let g:neovide_fullscreen = v:false
let g:neovide_refresh_rate = 60
let g:neovide_remember_window_size = v:true
let g:neovide_scroll_animation_length = 0.0
let g:neovide_transparency=0.95
let g:neovide_underline_automatic_scaling = v:true
set guifont=VictorMono_NF:h13
map <F11> :execute "let g:neovide_fullscreen = xor(g:neovide_fullscreen, v:true)"<CR>
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       MIS       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
highlight ConflictMarkerBegin guibg=#2f7366
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guibg=#2f628e
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
" vim: fdm=marker
