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

" ==== SPACES & TABS ====

set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent      " enable autoindent
set shiftwidth=2    " number of spaces to use when indenting

" ==== UI CONFIG ====
set number          " show line numbers
set showcmd         " show command in bottom bar
set showmatch       " highlight matching [{()}]

" ==== SEARCHING ====
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

" turn off search highlight
nnoremap ,<space> :nohlsearch<CR>

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

