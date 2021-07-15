syntax enable " enable syntax processing

set nohlsearch
set incsearch
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set inccommand=split

set cursorline

set hidden
set updatetime=300
set clipboard=unnamedplus
set smartcase ignorecase
set ttimeoutlen=10

set noswapfile
set nobackup
set undofile undodir=~/.vimtmp/undo//
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif

set tabstop=8 softtabstop=2 expandtab shiftwidth=2 autoindent
set linebreak

set autoread
set backspace=indent,eol,start " set backspace=2

set splitbelow splitright
set scrolloff=999
set showcmd
set noshowmode
set noruler
set signcolumn=yes

set foldlevel=100
