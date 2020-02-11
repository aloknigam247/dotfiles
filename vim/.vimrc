"Indentation Options
set autoindent      " New line inherit the indentation of previous lines
set cindent         " C-style indentation"
set expandtab       " Convert tabs to spaces
set shiftwidth=4    " When shifting, indent using spaces
set tabstop=4       " Indent using spaces

"Search Options
set hlsearch        " Enable search highlighting
set ignorecase      " Ignore case when searching
set incsearch       " Incremental search that shows partial matches
set smartcase       " Switch search to case-sensitive when query contains an uppercase letter

"Interface Options
set cursorline      " Highlight the line currently under cursor
set visualbell      " Flash the screen instead of beeping on errors
set mouse=a         " Enable mouse for scrolling and resizing
set title           " Set the window's title, reflecting the file currently being edited

"UI Options
colo PaperColor     " Set UI color theme
"set lines=30        " Set default height in terms of lines
"set columns=104     " Set default width in terms of columns

" Highlight text boundary for character length greater than 100
highlight ColorColumn ctermbg=black
call matchadd('ColorColumn', '\%101v', 200)

"IndentLine Plugin Options
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_leadingSpaceChar = '·'
let g:indentLine_leadingSpaceEnabled = 1

"Miscellaneous Options
set nu              " Enable line number
set noswapfile      " Disable swap file
set autoread        " Auto reload changed file

"Filetype Specific Options
autocmd BufNewFile,BufRead *.cyt set syntax=sh " Set cyt filetype as bash
autocmd Filetype make set noexpandtab shiftwidth=4 softtabstop=0 nocin
filetype plugin indent on   " File based indentation
