" Make `jj` and `jk` throw you into normal mode
inoremap jj <esc>
inoremap jk <esc>

" ==== COLORS ==== 

syntax enable " enable syntax processing

let g:solarized_termcolors=256 " fix gray background using solarized theme
let g:solarized_termtrans=1 " fix dark background using solarized theme
" colorscheme solarized

colorscheme badwolf

" ==== SPACES & TABS ====

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces

" ==== UI CONFIG ====
set number          " show line numbers
set showcmd         " show command in bottom bar
set showmatch       " highlight matching [{()}]

" ==== SEARCHING ====
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

" turn off search highlight
nnoremap ,<space> :nohlsearch<CR>

