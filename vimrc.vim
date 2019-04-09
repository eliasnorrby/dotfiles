" Make `jj` and `jk` throw you into normal mode
" inoremap jj <esc>
" inoremap jk <esc>
"
" ==== EXPERIMENTING ===
" :set listchars=eol:¬,tab:>·,trail:·,extends:>,precedes:<,space:␣
set listchars=eol:¬,trail:␣
set list
set hidden
set signcolumn=yes

" Make background transparent for many things
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
hi! LineNr ctermfg=NONE guibg=NONE
" hi! SignColumn ctermfg=NONE guibg=NONE
hi! SignColumn ctermbg=NONE guibg=NONE

" Make background color transparent for git changes
hi! SignifySignAdd guibg=NONE
hi! SignifySignDelete guibg=NONE
hi! SignifySignChange guibg=NONE

" Highlight git change signs
hi! SignifySignAdd guifg=#99c794
hi! SignifySignDelete guifg=#ec5f67
hi! SignifySignChange guifg=#c594c5

" ==== COLORS ==== 
syntax enable " enable syntax processing

" colorscheme badwolf

" ==== BACKUPS ETC ====
set backup                       " enable backups
set undofile                     " for storing undos
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
" set hlsearch        " highlight matches
set nohlsearch        " highlight matches

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
if !has("nvim") 
  set noesckeys " Make esc register immediately
endif
let mapleader=" "
nnoremap <Space> <Nop>

" turn off search highlight
nnoremap <Leader>, :nohlsearch<CR>
" toggle relative line numbering
nnoremap <Leader>r :set invrelativenumber<CR>

" Shortcuts for saving and quitting
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>

" ==== MOVEMENT ====
" move vertically by visual line
nnoremap j gj
nnoremap k gk
nnoremap <CR> G
nnoremap <Leader>n :NERDTreeToggle<CR>

" split navigation
nnoremap <Leader>h <C-W>h
nnoremap <Leader>j <C-W>j
nnoremap <Leader>k <C-W>k
nnoremap <Leader>l <C-W>l

" Open new split panes bottom or right
set splitbelow
set splitright

" ==== PLUGINS ====
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Common plugins
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'sheerun/vim-polyglot'
" Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
" Plug 'takac/vim-hardtime'
Plug 'jiangmiao/auto-pairs'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-signify'

" Nvim plugins
if has("nvim")
  Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
  Plug 'ryanoasis/vim-devicons'
  " ------- First crazy mod
  " Plug 'w0rp/ale'
  " Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  " Plug 'pangloss/vim-javascript'
  " Plug 'mxw/vim-jsx'
  " Plug 'autozimu/LanguageClient-neovim', {
  "   \ 'branch': 'next',
  "   \ 'do': 'bash install.sh',
  "   \ }
endif 

call plug#end()

" Common plugin settings
let g:hardtime_default_on = 1

" Map fzf commands
nnoremap <C-P> :Files<CR>

" auto-pairs interferes with swedish characters
let g:AutoPairsShortcutFastWrap=''
silent! iunmap å
silent! iunmap ä
silent! iunmap ö

" Nvim plugin settings
if has("nvim")

  " === Coc.nvim === "
  " use <tab> for trigger completion and navigate to next complete item
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

  "Close preview window when completion is done.
  autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

  " Prettier command
  command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

  vmap <leader>p  <Plug>(coc-format-selected)
  nmap <leader>p  <Plug>(coc-format-selected)

  " Polyglot incorrectly marks js files as jsx :(
  let g:jsx_ext_required = 1


  " ------- First crazy mod
  " let g:LanguageClient_autoStart = 1
  " " let g:ale_javascript_eslint_use_global = 1
  " let g:ale_linters = {
  " \  'javascript': ['eslint'],
  " \}

  " One symbol config...
  " let g:ale_sign_error = '✘'
  " let g:ale_sign_warning = '⚠'
  " highlight ALEErrorSign ctermbg=NONE ctermfg=red
  " highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

  " " Another...
  " " Use a slightly slimmer error pointer
  " let g:ale_sign_error = '✖'
  " " hi ALEErrorSign guifg=#DF8C8C
  " highlight ALEErrorSign ctermbg=NONE ctermfg=red
  " let g:ale_sign_warning = '⚠'
  " hi ALEWarningSign guifg=#F2C38F

  " let g:ale_fixers = {
  " \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  " \   'javascript': ['eslint'],
  " \}

  " " Set this variable to 1 to fix files when you save them.
  " let g:ale_fix_on_save = 1

  " let g:deoplete#enable_at_startup = 1

  " " deoplete tab-complete
  " inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

  " let g:LanguageClient_serverCommands = {
  "     \ 'javascript': ['~/.nvm/versions/node/v10.15.1/bin/javascript-typescript-stdio'],
  "     \ 'javascript.jsx': ['~/.nvm/versions/node/v10.15.1/bin/javascript-typescript-stdio']
  "     \ }

  " " let g:LanguageClient_serverCommands = {
  " "     \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
  " "     \ 'python': ['/usr/local/bin/pyls'],
  " "     \ }
  " nnoremap <F5> :call LanguageClient_contextMenu()<CR>
  " " Or map each action separately
  " nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  " nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
  " nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
endif 

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
  " Uncomment this line to have vim blend with iterm bg when using the
  " default onedark colorscheme (contrasts with lightline)
  " hi Normal ctermbg=008
  hi Normal ctermbg=000
endif


  " ------ Post plugin experimenting
  " Make background transparent for many things
  hi! Normal ctermbg=NONE guibg=NONE
  hi! NonText ctermbg=NONE guibg=NONE
  hi! LineNr ctermfg=NONE guibg=NONE
  " hi! SignColumn ctermfg=NONE guibg=NONE
  hi! SignColumn ctermbg=NONE guibg=NONE

  " Make background color transparent for git changes
  hi! SignifySignAdd guibg=NONE
  hi! SignifySignDelete guibg=NONE
  hi! SignifySignChange guibg=NONE

  " Highlight git change signs
  hi! SignifySignAdd guifg=#99c794
  hi! SignifySignDelete guifg=#ec5f67
  hi! SignifySignChange guifg=#c594c5
