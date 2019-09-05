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
set smartcase       " Automatically switch search to case-sensitive when search quesry contains an uppercase letter

"Interface Options
set cursorline      " Highlight the line currently under cursor
set visualbell      " Flash the screen instead of beeping on errors
set mouse=a         " Enable mouse for scrolling and resizing
set title           " Set the window's title, reflecting the file currently being edited

"Miscellaneous Options
set nu              " Enable line number
set noswapfile      " Disable swap file
set autoread        " Auto reload changed file

"Filetype Specific Options
autocmd Filetype make set noexpandtab shiftwidth=4 softtabstop=0 nocin
filetype plugin indent on   " File based indentation
