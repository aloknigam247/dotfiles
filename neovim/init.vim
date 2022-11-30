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
-- require('impatient')
-- require('pepperfish')
-- profiler = newProfiler()
-- profiler:start()

--vim.api.nvim_create_autocmd('VimLeave', {callback = function()
--    profiler:stop()
--    local outfile = io.open( "profile.txt", "w+" )
--    profiler:report( outfile )
--    outfile:close()
--end})
vim.notify = function(msg, level, opt)
    require('notify') -- lazy loads nvim-notify and set vim.notify = notify
    vim.notify(msg, level, opt)
end

function ColoRand()
    local colos = {
        { 'OceanicNext',                'dark',  '_' },
        { 'PaperColor',                 'dark',  '_' },
        { 'PaperColor',                 'light', '_' },
        { 'adwaita',                    'dark',  '_' },
        { 'adwaita',                    'light', '_' },
        { 'aurora',                     'dark',  '_' },
        { 'ayu-dark',                   'dark',  '_' },
        { 'ayu-light',                  'dark',  '_' },
        { 'ayu-mirage',                 'dark',  '_' },
        { 'barstrata',                  'dark',  '_' },
        { 'base2tone_cave_dark',        'dark',  '_' },
        { 'base2tone_cave_light',       'dark',  '_' },
        { 'base2tone_desert_dark',      'dark',  '_' },
        { 'base2tone_desert_light',     'dark',  '_' },
        { 'base2tone_drawbridge_dark',  'dark',  '_' },
        { 'base2tone_drawbridge_light', 'dark',  '_' },
        { 'base2tone_earth_dark',       'dark',  '_' },
        { 'base2tone_earth_light',      'dark',  '_' },
        { 'base2tone_evening_dark',     'dark',  '_' },
        { 'base2tone_evening_light',    'dark',  '_' },
        { 'base2tone_field_dark',       'dark',  '_' },
        { 'base2tone_field_light',      'dark',  '_' },
        { 'base2tone_forest_dark',      'dark',  '_' },
        { 'base2tone_forest_light',     'dark',  '_' },
        { 'base2tone_garden_dark',      'dark',  '_' },
        { 'base2tone_garden_light',     'dark',  '_' },
        { 'base2tone_heath_dark',       'dark',  '_' },
        { 'base2tone_heath_light',      'dark',  '_' },
        { 'base2tone_lake_dark',        'dark',  '_' },
        { 'base2tone_lake_light',       'dark',  '_' },
        { 'base2tone_lavender_dark',    'dark',  '_' },
        { 'base2tone_lavender_light',   'dark',  '_' },
        { 'base2tone_mall_dark',        'dark',  '_' },
        { 'base2tone_mall_light',       'dark',  '_' },
        { 'base2tone_meadow_dark',      'dark',  '_' },
        { 'base2tone_meadow_light',     'dark',  '_' },
        { 'base2tone_morning_dark',     'dark',  '_' },
        { 'base2tone_morning_light',    'dark',  '_' },
        { 'base2tone_motel_dark',       'dark',  '_' },
        { 'base2tone_motel_light',      'dark',  '_' },
        { 'base2tone_pool_dark',        'dark',  '_' },
        { 'base2tone_pool_light',       'dark',  '_' },
        { 'base2tone_porch_dark',       'dark',  '_' },
        { 'base2tone_porch_light',      'dark',  '_' },
        { 'base2tone_sea_dark',         'dark',  '_' },
        { 'base2tone_sea_light',        'dark',  '_' },
        { 'base2tone_space_dark',       'dark',  '_' },
        { 'base2tone_space_light',      'dark',  '_' },
        { 'base2tone_suburb_dark',      'dark',  '_' },
        { 'base2tone_suburb_light',     'dark',  '_' },
        { 'blue',                       'dark',  '_' },
        { 'calvera',                    'dark',  '_' },
        { 'carbonfox',                  'dark',  '_' },
        { 'catppuccin-frappe',          'dark',  '_' },
        { 'catppuccin-latte',           'dark',  '_' },
        { 'catppuccin-macchiato',       'dark',  '_' },
        { 'catppuccin-mocha',           'dark',  '_' },
        { 'codedark',                   'dark',  '_' },
        { 'darkblue',                   'dark',  '_' },
        { 'darker',                     'dark',  '_' },
        { 'darkplus',                   'dark',  '_' },
        { 'darksolar',                  'dark',  '_' },
        { 'dawnfox',                    'dark',  '_' },
        { 'dayfox',                     'dark',  '_' },
        { 'deepocean',                  'dark',  '_' },
        { 'delek',                      'light', '_' },
        { 'desert',                     'dark',  '_' },
        { 'deus',                       'dark',  '_' },
        { 'dracula',                    'dark',  '_' },
        { 'dracula_blood',              'dark',  '_' },
        { 'duskfox',                    'dark',  '_' },
        { 'earlysummer',                'dark',  '_' },
        { 'edge',                       'dark',  '_' },
        { 'edge',                       'light', '_' },
        { 'elflord',                    'dark',  '_' },
        { 'emerald',                    'dark',  '_' },
        { 'enfocado',                   'dark',  '_' },
        { 'enfocado',                   'light', '_' },
        { 'evening',                    'dark',  '_' },
        { 'everforest',                 'dark',  '_' },
        { 'everforest',                 'light', '_' },
        { 'falcon',                     'dark',  '_' },
        { 'fluoromachine',              'dark',  '_' },
        { 'github_dark',                'dark',  '_' },
        { 'github_light',               'dark',  '_' },
        { 'gruvbox-baby',               'dark',  '_' },
        { 'gruvbuddy',                  'dark',  '_' },
        { 'gruvbuddy',                  'light', '_' },
        { 'habamax',                    'dark',  '_' },
        { 'horizon',                    'dark',  '_' },
        { 'industry',                   'dark',  '_' },
        { 'jellybeans-nvim',            'dark',  '_' },
        { 'juliana',                    'dark',  '_' },
        { 'kanagawa',                   'dark',  '_' },
        { 'kimbox',                     'dark',  '_' },
        { 'koehler',                    'dark',  '_' },
        { 'limestone',                  'dark',  '_' },
        { 'lunaperche',                 'dark',  '_' },
        { 'mariana',                    'dark',  '_' },
        { 'material',                   'dark',  '_' },
        { 'material',                   'dark',  '_',   precmd = function() vim.g.material_style = 'darker' end },
        { 'material',                   'dark',  '_',   precmd = function() vim.g.material_style = 'deep ocean' end },
        { 'material',                   'dark',  '_',   precmd = function() vim.g.material_style = 'lighter' end },
        { 'material',                   'dark',  '_',   precmd = function() vim.g.material_style = 'oceanic' end },
        { 'material',                   'dark',  '_',   precmd = function() vim.g.material_style = 'palenight' end },
        { 'melange',                    'dark',  '_' },
        { 'melange',                    'light', '_' },
        { 'mellow',                     'dark',  '_' },
        { 'middlenight_blue',           'dark',  '_' },
        { 'monokai',                    'dark',  '_' },
        { 'monokai_pro',                'dark',  '_' },
        { 'moonlight',                  'dark',  '_' },
        { 'morning',                    'light', '_' },
        { 'mosel',                      'dark',  '_' },
        { 'murphy',                     'dark',  '_' },
        { 'neon',                       'dark',  '_',   precmd = function() vim.g.neon_style = 'dark' end },
        { 'neon',                       'dark',  '_',   precmd = function() vim.g.neon_style = 'default' end },
        { 'neon',                       'dark',  '_',   precmd = function() vim.g.neon_style = 'doom' end },
        { 'neon',                       'light', '_',   precmd = function() vim.g.neon_style = 'light' end },
        { 'nightfox',                   'dark',  '_' },
        { 'nordfox',                    'dark',  '_' },
        { 'oceanic',                    'dark',  '_' },
        { 'oh-lucy',                    'dark',  '_' },
        { 'oh-lucy-evening',            'dark',  '_' },
        { 'one-nvim',                   'dark',  '_' },
        { 'one_monokai',                'dark',  '_' },
        { 'onebuddy',                   'dark',  '_' },
        { 'onebuddy',                   'light', '_' },
        { 'onedarkpro',                 'dark',  '_' },
        { 'onedarkpro',                 'dark',  '_',   precmd = function() require('onedarkpro').setup({dark_theme = 'onedark_dark'}) end },
        { 'onedarkpro',                 'light', '_' },
        { 'onenord',                    'dark',  '_' },
        { 'onenord',                    'light', '_' },
        { 'pablo',                      'dark',  '_' },
        { 'palenight',                  'dark',  '_' },
        { 'peachpuff',                  'dark',  '_' },
        { 'quiet',                      'dark',  '_' },
        { 'ron',                        'dark',  '_' },
        { 'rose-pine',                  'dark',  '_' },
        { 'rose-pine',                  'dark',  '_',   precmd = function() require('rose-pine').setup({dark_variant = 'main'}) end },
        { 'rose-pine',                  'dark',  '_',   precmd = function() require('rose-pine').setup({dark_variant = 'moon'}) end },
        { 'shine',                      'light', '_' },
        { 'slate',                      'dark',  '_' },
        { 'sonokai',                    'dark',  '_',   precmd = function() vim.g.sonokai_style = 'andromeda' end },
        { 'sonokai',                    'dark',  '_',   precmd = function() vim.g.sonokai_style = 'atlantis' end },
        { 'sonokai',                    'dark',  '_',   precmd = function() vim.g.sonokai_style = 'default' end },
        { 'sonokai',                    'dark',  '_',   precmd = function() vim.g.sonokai_style = 'maia' end },
        { 'sonokai',                    'dark',  '_',   precmd = function() vim.g.sonokai_style = 'shusia' end },
        { 'terafox',                    'dark',  '_' },
        { 'toast',                      'dark',  '_' },
        { 'toast',                      'light', '_' },
        { 'tokyodark',                  'dark',  '_' },
        { 'tokyonight-day',             'light', '_' },
        { 'tokyonight-moon',            'dark',  '_' },
        { 'tokyonight-night',           'dark',  '_' },
        { 'tokyonight-storm',           'dark',  '_' },
        { 'torte',                      'dark',  '_' },
        { 'tundra',                     'dark',  '_' },
        { 'ukraine',                    'dark',  '_' },
        { 'vn-night',                   'dark',  '_' },
        { 'zellner',                    'light', '_' },
        { 'zenburned',                  'dark',  '_' },
        { 'zenwritten',                 'dark',  '_' },
        { 'zephyr',                     'dark',  '_' },
        { 'zephyrium',                  'dark',  '_' },
    }
    math.randomseed(os.time())
    local ind = math.random(1, table.getn(colos))
    ind = 1
    local selection = colos[ind]
    local scheme = selection[1]
    local bg = selection[2]
    local module = selection[3]
    local precmd = selection.precmd
    -- print("scheme:", scheme, "bg:", bg, "module:", module, "precmd:", precmd)
    vim.o.background = bg
    if (precmd) then
        precmd()
    end
    if (module ~= '_') then
        require(module)
    end
    vim.cmd.colorscheme(scheme)
    vim.cmd[[highlight clear CursorLine]]
end

vim.api.nvim_create_user_command('ColoRand', ColoRand, { nargs = 0 })
-- vim.api.nvim_create_autocmd('UIEnter', {callback = ColoRand})

vim.g.cmp_kinds = {
    Array         = ' ',
    Boolean       = ' ',
    Class         = ' ',
    Color         = ' ',
    Constant      = ' ',
    Constructor   = ' ',
    Enum          = ' ',
    EnumMember    = ' ',
    Event         = ' ',
    Field         = ' ',
    File          = ' ',
    Folder        = ' ',
    Function      = ' ',
    History       = ' ',
    Interface     = ' ',
    Key           = ' ',
    Keyword       = ' ',
    Method        = ' ',
    Module        = ' ',
    Namespace     = ' ',
    Null          = ' ',
    Number        = ' ',
    Object        = ' ',
    Operator      = ' ',
    Options       = ' ',
    Package       = ' ',
    Property      = ' ',
    Reference     = ' ',
    Snippet       = ' ',
    String        = ' ',
    Struct        = ' ',
    Text          = ' ',
    TypeParameter = ' ',
    Unit          = ' ',
    Value         = ' ',
    Variable      = ' '
}
EOF

autocmd BufRead plugins.lua lua require('plugins')
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Variables     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let b:did_ftplugin              = 1
let g:loaded_2html_plugin       = 1
" let g:loaded_clipboard_provider = 1
let g:loaded_gzip               = 1
let g:loaded_logiPat            = 1
let g:loaded_man                = 1
let g:loaded_matchit            = 1
let g:loaded_matchparen         = 1
let g:loaded_netrw              = 1
let g:loaded_netrwPlugin        = 1
let g:loaded_remote_plugins     = 1
let g:loaded_rrhelper           = 1
let g:loaded_shada_plugin       = 1
let g:loaded_spellfile_plugin   = 1
let g:loaded_tarPlugin          = 1
let g:loaded_tutor_mode_plugin  = 1
let g:loaded_zipPlugin          = 1

let &titleold = getcwd()           " Set console title to path on vim exit
let c_curly_error = 1              " Show curly braces error
let c_space_errors = 1             " Highlight trailing spaces
let g:markdown_folding = 1         " Enable markdown folding
let g:python_recommended_style = 0 " Disable inbuilt python tabs settings
let g:diff_translations = 0        " Disables localisations and speeds up syntax highlighting in diff mode
let g:load_doxygen_syntax = 1      " Recognize doxygen comment style
let g:netrw_liststyle = 3          " Set netrw style as tree
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
set updatetime=2000                   " CursorHold time
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
set foldmethod=marker        " Set fold method to marker
set laststatus=3             " Disable global statusline
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

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Mappings     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
" map("i", "<C-a>", "<Home>")
" map("i", "<C-e>", "<End>")
" map("i", "<C-b>", "<ESC>bi")
" map("i", "<C-f>", "<ESC>wa")
" map("i", "<C-n>", "<ESC>ja")
" map("i", "<C-p>", "<ESC>ka")
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
let g:neovide_transparency=0.95
" let g:neovide_underline_automatic_scaling = v:true
set guifont=VictorMono_NF:h13
map <F11> :execute "let g:neovide_fullscreen = xor(g:neovide_fullscreen, v:true)"<CR>
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
highlight ConflictMarkerBegin guibg=#2f7366
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guibg=#2f628e
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81

lua << EOF
vim.diagnostic.config({
    float = {
        source = true
    },
    severity_sort = true,
    virtual_text = {
        prefix = ' ',
        source = true
    }
})

url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

vim.fn.matchadd("HighlightURL", url_matcher, 15)
EOF
highlight HighlightURL gui=underline cterm=underline

" vim: fdm=marker
