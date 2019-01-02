" Make `jj` and `jk` throw you into normal mode
inoremap jj <esc>
inoremap jk <esc>

" ==== COLORS ==== 

syntax enable " enable syntax processing

" fix gray background using solarized theme
" set background=dark
" let g:solarized_termcolors=256 
" let g:solarized_termtrans=1 
" colorscheme solarized

colorscheme badwolf

" ==== BACKUPS ETC ====
set backup                        " enable backups
" set noswapfaile                 " disbale swapfiles
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif

set undofile        " for storing undos
set showmode        " shows mode (INSERT)
set title           " sets window title based on file name
set linebreak       " line wrapping

" ==== SPACES & TABS ====
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent      " enable autoindent
set smartindent     " enable smart indenting
set shiftwidth=2    " number of spaces to use when indenting
set smarttab        " smart tabs (beginning of line behavior)

" ==== UI CONFIG ====
set number          " show line numbers
set relativenumber  " show relative line numbers
set showcmd         " show command in bottom bar
set showmatch       " highlight matching [{()}]
set matchtime=3     " reduce time for showing matching parens
set ruler           " always show 'line,column' in bottom right

" ==== SEARCHING ====
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

let mapleader=" "
nnoremap <Space> <Nop>

" turn off search highlight
nnoremap <Leader>, :nohlsearch<CR>
" toggle relative line numbering
nnoremap <Leader>r :set relativenumber<CR>
nnoremap <Leader>R :set norelativenumber<CR>

" ==== MOVEMENT ====
" move vertically by visual line
nnoremap j gj
nnoremap k gk

" move to beginning/end of line
nnoremap B ^
nnoremap E $

" $ and ^ don't do anything
nnoremap $ <nop>
nnoremap ^ <nop>

" Test
noremap <Leader>w <Plug>(easymotion-w)

