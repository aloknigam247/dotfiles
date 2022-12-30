"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" syntax off
" au BufRead * echo "BufRead"
" au BufEnter * echo "BufEnter"
" au BufReadPost * echo "BufReadPost"
" au BufWinEnter * echo "BufWinEnter"
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Plugins      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
" autocmd BufRead plugins.lua lua require('plugins')
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Variables     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
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
set updatetime=500                    " CursorHold time
set wrapmargin=0                      " Disable wrap margin
setglobal bomb                        " Keep the BOM file marker
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Filetype     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" autocmd BufNewFile,BufRead *.csproj set filetype=csproj
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
set foldmethod=marker        " Set fold method to marker
set laststatus=3             " Disable global statusline
" set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=lead:·,trail:•,multispace:·,tab:»\ ,nbsp:⦸,extends:»,precedes:«
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
    let g:neovide_transparency=0.95
    " let g:neovide_underline_automatic_scaling = v:true
    set guifont=VictorMono_NF:h13
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
    autocmd!
    autocmd VimLeave * set guicursor=a:ver20 " sets cursor to vertical bar
augroup END


" highlight ColorColumn ctermbg=white
" call matchadd('ColorColumn', '\%101v', 100)
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%101v/
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
local fname = vim.fn.expand('%')
local lazyfile = "lazyplugins.lua"
-- if fname:sub(-#lazyfile) ==  lazyfile then
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
      })
    end
    vim.opt.runtimepath:prepend(lazypath)
    require('init')
    ColoRand()
    vim.cmd([[ let g:loaded_clipboard_provider = 1 ]])
        vim.api.nvim_create_autocmd('User', { pattern='VeryLazy', callback = function()
        vim.cmd([[
        unlet g:loaded_clipboard_provider
        runtime autoload/provider/clipboard.vim
        ]])
    end})
-- else
--     require('impatient')
--     vim.api.nvim_create_autocmd('VIMEnter', {callback = ColoRand})
-- end

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

sleeper = {
    timer = vim.loop.new_timer(),
    last = 1,
    sleeps = {
        { start = function() require('drop').setup({theme = "leaves"}); require('drop').show(); end, stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "snow"}); require('drop').show(); end,   stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "stars"}); require('drop').show(); end,  stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "xmas"}); require('drop').show(); end,   stop = function() require('drop').hide() end },
        { start = function() require('duck').hatch('🐌') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🐤') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('👻') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🤖') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🦜') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('zone.styles.epilepsy').start({stage = "aura"}) end,            stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.epilepsy').start({stage = "ictal"}) end,           stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.treadmill').start({}) end,                         stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.vanish').start({}) end,                            stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
    }
}

function resetSleeper()
    sleeper.timer:stop()
    sleeper.sleeps[sleeper.last].stop()

    sleeper.timer:start(300000, 0, vim.schedule_wrap(function()
        sleeper.sleeps[sleeper.last].start()
        local new_sleeps = (sleeper.last) % table.getn(sleeper.sleeps) + 1
        sleeper.last = new_sleeps
    end
    ))
end

vim.api.nvim_create_autocmd({'CursorHold'} , {callback = resetSleeper})
vim.api.nvim_create_autocmd({'CursorMoved', "CursorMovedI"} , {callback = function() sleeper.sleeps[sleeper.last].stop() end})

url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

vim.fn.matchadd("HighlightURL", url_matcher, 1)
EOF
highlight HighlightURL gui=underline cterm=underline
