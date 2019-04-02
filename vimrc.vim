" Make `jj` and `jk` throw you into normal mode
inoremap jj <esc>
inoremap jk <esc>

nnoremap <F2> :setlocal commentstring=#\ %s<CR>

" ==== COLORS ==== 
syntax enable " enable syntax processing

" fix gray background using solarized theme
" set background=dark
" let g:solarized_termcolors=256 
" let g:solarized_termtrans=1 
" colorscheme solarized

" colorscheme badwolf

" ==== BACKUPS ETC ====
set backup                        " enable backups
set undofile        " for storing undos
" set noswapfile                 " disbale swapfiles
set undodir=~/.vimtmp/undo//     " undo files
set backupdir=~/.vimtmp/backup// " backups
set directory=~/.vimtmp/swap//   " swap files
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

" ==== SPACES & TABS ====
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent      " enable autoindent
set smartindent     " enable smart indenting
set shiftwidth=2    " number of spaces to use when indenting
set smarttab        " smart tabs (beginning of line behavior)
set linebreak       " line wrapping

" ==== UI CONFIG ====
set number          " show line numbers
set relativenumber  " show relative line numbers
set showcmd         " show command in bottom bar
set showmatch       " highlight matching [{()}]
set matchtime=3     " reduce time for showing matching parens
" set ruler           " always show 'line,column' in bottom right
set laststatus=2    " for showing lightline
" set showmode        " shows mode (INSERT)
set noshowmode 
" set title           " sets window title based on file name

" ==== COPYING ====
set clipboard=unnamed

" ==== SEARCHING ====
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

" ==== SCROLLING ====
set so=5
nnoremap <C-E> <C-E><C-E><C-E>
nnoremap <C-Y> <C-Y><C-Y><C-Y>

" function SmoothScroll(up)
"     if a:up
"         let scrollaction=""
"     else
"         let scrollaction=""
"     endif
"     exec "normal " . scrollaction
"     redraw
"     let counter=1
"     while counter<&scroll
"         let counter+=1
"         sleep 5m
"         redraw
"         exec "normal " . scrollaction
"         exec "normal " . scrollaction
"     endwhile
" endfunction

" nnoremap <C-U> :call SmoothScroll(1)<Enter>
" nnoremap <C-D> :call SmoothScroll(0)<Enter>
" inoremap <C-U> <Esc>:call SmoothScroll(1)<Enter>i
" inoremap <C-D> <Esc>:call SmoothScroll(0)<Enter>i

" ==== KEYBINDS ====
set esckeys
let mapleader=" "
nnoremap <Space> <Nop>

" turn off search highlight
nnoremap <Leader>, :nohlsearch<CR>
" toggle relative line numbering
nnoremap <Leader>r :set invrelativenumber<CR>

" ==== MOVEMENT ====
" move vertically by visual line
nnoremap j gj
nnoremap k gk
nnoremap <CR> G

" ==== PLUGINS ====
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
call plug#end()


if has("termguicolors")
  let g:lightline = {
    \ 'colorscheme': 'ayucustom',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component': {
    \   'lineinfo': '%3l:%-2v',
    \ },
    \ 'component_function': {
    \   'readonly': 'LightlineReadonly',
    \   'gitbranch': 'LightlineGitbranch'
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
    \ }
else
  let g:lightline = {
    \ 'colorscheme': 'onedark',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component': {
    \   'lineinfo': '%3l:%-2v',
    \ },
    \ 'component_function': {
    \   'readonly': 'LightlineReadonly',
    \   'gitbranch': 'LightlineGitbranch'
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
    \ }
endif

function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction

function! LightlineGitbranch()
  if exists('*gitbranch#name')
    let branch = gitbranch#name()
    return branch !=# '' ? ''.branch : ''
  endif
  return ''
endfunction

" function! LightlineFugitive()
"   if exists('*fugitive#head')
"     let branch = fugitive#head()
"     return branch !=# '' ? ''.branch : ''
"   endif
"   return ''
" endfunction

if has("termguicolors")
  set termguicolors     " enable true colors support
  " let ayucolor="light"  " for light version of theme
  let ayucolor="mirage" " for mirage version of theme
  " let ayucolor="dark"   " for dark version of theme
  colorscheme ayu 
else
  colorscheme onedark
endif

" Uncomment this line to have vim blend with iterm bg when using the 
" default onedark colorscheme (contrasts with lightline)
" hi Normal ctermbg=008

