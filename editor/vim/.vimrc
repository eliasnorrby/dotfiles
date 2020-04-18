"         ___                                  __         
"   ___  / (_)___ __________  ____  __________/ /_  __  __
"  / _ \/ / / __ `/ ___/ __ \/ __ \/ ___/ ___/ __ \/ / / /
" /  __/ / / /_/ (__  ) / / / /_/ / /  / /  / /_/ / /_/ / 
" \___/_/_/\__,_/____/_/ /_/\____/_/  /_/  /_.___/\__, /  
"                                                /____/   
" Filename:   .vimrc
" Github:     https://github.com/eliasnorrby/dotfiles
" Maintainer: Elias Norrby
                     
set encoding=utf-8
scriptencoding utf-8

let mapleader=" "
nnoremap <Space> <Nop>

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
endif

" Plugins {{{ 

" ============================================================================ "
" ===                           PLUGINS                                    === "
" ============================================================================ "

" Download vimplug if not already installed
if empty(glob($VIM_DIR.'/autoload/plug.vim'))
  silent !curl -sfLo $VIM_DIR/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin($XDG_DATA_HOME.'/vim/plugged')

" Editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'raimondi/delimitmate'

" Ui
Plug 'tpope/vim-vinegar'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'mhinz/vim-signify'

" Navigation
Plug 'tpope/vim-unimpaired'
Plug 'easymotion/vim-easymotion'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Text objects
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'haya14busa/vim-textobj-function-syntax'

" Filetypes and syntax
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'

" Fuzzy finder
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" Tmux integration
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'

" Colorschemes
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'

" Miscellaneous
Plug 'takac/vim-hardtime'

" Formatting
" post install (yarn install | npm install) then load plugin only for editing supported files
" Plug 'prettier/vim-prettier', {
"   \ 'do': 'npm install',
"   \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

" map /  <Plug>(incsearch-forward)
" map ?  <Plug>(incsearch-backward)
" map g/ <Plug>(incsearch-stay)

map gs <Plug>(easymotion-prefix)

" {{{ tmux-navigator settings
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1
" }}}

" {{{ vim-hardtime settings
let g:hardtime_default_on = 0 
let g:hardtime_showmsg = 0
let g:hardtime_maxcount = 1
let g:hardtime_allow_different_key = 1
let g:list_of_insert_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
let g:list_of_disabled_keys = ["<BS>"]
" }}}

" {{{ vim-prettier settings 
" let g:prettier#autoformat = 0
" augroup PrettierAutoformat
"   autocmd! 
"   autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html PrettierAsync
" augroup END
" }}}

" {{{ vim-polyglot settings
" Polyglot incorrectly marks js files as jsx :(
let g:jsx_ext_required = 1
" }}}

" {{{ vim-signify settings
" Does this conflict with dispatch?
" To make signify update on Gcommit
" autocmd User Fugitive SignifyRefresh
let g:signify_sign_change = '~'
" }}}

" {{{ delimitmate settings

let delimitMate_expand_cr=1

" }}}

" }}}

" {{{ Editing options
" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

augroup GitSpelling
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

" Open new split panes bottom or right
set splitbelow
set splitright

" ==== SCROLLING ====
set so=5
nnoremap <C-E> <C-E><C-E><C-E>
nnoremap <C-Y> <C-Y><C-Y><C-Y>

set hidden

set clipboard=unnamed

" ==== BACKUPS ETC ====
set backup                       " enable backups
set undofile                     " for storing undos
" set noswapfile                 " disable swapfiles
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
set tabstop=8       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent      " enable autoindent
set shiftwidth=2    " number of spaces to use when indenting
set linebreak       " line wrapping
" filetype plugin indent on " probably on by default

set autoread
set backspace=indent,eol,start
" is equal to:
" set backspace=2

" search ignores case unless an uppercase letter is used
set smartcase
set ignorecase

set ttimeoutlen=10
" This could be used to reduce the timeout for only the esc key
" set ttimeoutlen=250
" augroup InsertTimeout
"   autocmd!
"   autocmd InsertEnter * set timeoutlen=10
"   autocmd InsertLeave * set timeoutlen=250
" augroup END

" }}}

" {{{ UI

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" let s:theme_to_use="ayu"
" let s:theme_to_use="gruvbox"
let s:theme_to_use="palenight"

syntax enable " enable syntax processing

augroup WindowSizeEqual
  autocmd!
  autocmd VimResized * wincmd =
augroup END

augroup FiletypeCorrections
  autocmd!
  autocmd BufReadPost,BufNewFile *.test.ts set  syntax=jasmine
  autocmd BufReadPost,BufNewFile tsconfig.json set filetype=jsonc 
augroup END

" ==== UI Elements ====
set number         " show line numbers
set relativenumber " show relative line numbers
set showcmd        " show command in bottom bar

set incsearch      " search as characters are entered
set nohlsearch     " highlight matches

set laststatus=2   " for showing lightline
set noshowmode 

set signcolumn=yes

augroup CursorLineOnInsert
  if s:theme_to_use == "ayu"
    autocmd!
    autocmd InsertEnter * highlight CursorLine ctermbg=237 guibg=#2D3B4D
    autocmd InsertLeave * highlight CursorLine ctermbg=0 guibg=#232834
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
  endif
augroup END

" ==== netwr ====
" absolute width of netrw window
let g:netrw_winsize = -28

" tree-view
let g:netrw_liststyle = 3

" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" open file in a new tab
let g:netrw_browse_split = 3

" {{{ Lightline

" ==== Lightline ====
if has("termguicolors")
  let g:lightline = {
    \ 'colorscheme': 'palenight',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename' ],
    \             [ 'modified' ] ],
    \   'right': [ ['lineinfo'], 
    \              ['percent'], 
    \              ['fileformat', 'fileencoding', 'filetype'] ],
    \ },
    \ 'inactive': {
    \   'left': [ ['filename'], 
    \             ['modified'] ],
    \   'right': [ ['lineinfo'], 
    \              ['percent'] ],
    \ },
    \ 'component': {
    \   'lineinfo': '%3l:%-2v',
    \ },
    \ 'component_function': {
    \   'readonly': 'LightlineReadonly',
    \   'gitbranch': 'LightlineGitbranch',
    \   'fileformat': 'LightlineFileformat',
    \   'fileencoding': 'LightlineFileencoding',
    \   'filetype': 'LightlineFiletype',
    \   'cocstatus': 'coc#status',
    \   'currentfunction': 'CocCurrentFunction'
    \ },
    \ }
    " \ 'separator': { 'left': '', 'right': '' },
    " \ 'subseparator': { 'left': '', 'right': '' },
    " \ }
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

function! LightlineFileformat()
  return winwidth(0) > 90 ? &fileformat : '' 
endfunction

function! LightlineFileencoding ()
  return winwidth(0) > 80 ? &fileencoding : ''
endfunction

function! LightlineFiletype ()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction

function! LightlineGitbranch()
  if winwidth(0) < 65
    return ''
  elseif exists('*gitbranch#name')
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

" }}}


function! MyHighlights() abort
  " Make background transparent for many things
  " highlight!   Normal              ctermbg=NONE    guibg=NONE
  " highlight!   NonText             ctermbg=NONE    guibg=NONE
  highlight!   LineNr              ctermbg=NONE    guibg=NONE
  highlight!   SignColumn          ctermbg=NONE    guibg=NONE

  " Highlight git change signs
  highlight!   SignifySignAdd                      guibg=NONE   guifg=#99C794
  highlight!   SignifySignDelete                   guibg=NONE   guifg=#EC5F67
  highlight!   SignifySignChange                   guibg=NONE   guifg=#C594C5

  " ALE Signs
  " for some reason these are cleared on re-sourcing vimrc
  highlight!   CocErrorSign       ctermfg=9                     guifg=#FF0000
  highlight!   CocWarningSign     ctermfg=130                   guifg=#FF922B
  highlight!   link ALEErrorSign    CocErrorSign
  highlight!   link ALEWarningSign  CocWarningSign

  if s:theme_to_use == "ayu"
    " ayu-vim is missing this highlight
    highlight!   DiffDelete                      guibg=#272D38 guifg=#F27983

    " coc has very dark text highlight
    highlight!   CocHighlightText guibg=#2D3B4D

    highlight! BufTabLineCurrent guifg=#212733 guibg=#FFAE57 
    highlight! BufTabLineActive  guifg=#212733 guibg=#FFD57F 
    highlight! BufTabLineHidden  guifg=#D9D7CE guibg=#343F4C
    highlight! BufTabLineFill    guifg=NONE guibg=NONE
  endif
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme * call MyHighlights()
augroup END

" TODO: Sourcing MYVIMRC breaks coc highlighting
if has("termguicolors")
  if s:theme_to_use == "ayu"
    set termguicolors     " enable true colors support
    let ayucolor="mirage" " for mirage version of theme
    silent! colorscheme ayu 
  endif

  " {{{ Ayu color reference
  " palette for reference
  " let s:palette.bg        = {'dark': #0F1419,  'light': #FAFAFA,  'mirage': #212733}
  " let s:palette.comment   = {'dark': #5C6773,  'light': #ABB0B6,  'mirage': #5C6773}
  " let s:palette.markup    = {'dark': #F07178,  'light': #F07178,  'mirage': #F07178}
  " let s:palette.constant  = {'dark': #FFEE99,  'light': #A37ACC,  'mirage': #D4BFFF}
  " let s:palette.operator  = {'dark': #E7C547,  'light': #E7C547,  'mirage': #80D4FF}
  " let s:palette.tag       = {'dark': #36A3D9,  'light': #36A3D9,  'mirage': #5CCFE6}
  " let s:palette.regexp    = {'dark': #95E6CB,  'light': #4CBF99,  'mirage': #95E6CB}
  " let s:palette.string    = {'dark': #B8CC52,  'light': #86B300,  'mirage': #BBE67E}
  " let s:palette.function  = {'dark': #FFB454,  'light': #F29718,  'mirage': #FFD57F}
  " let s:palette.special   = {'dark': #E6B673,  'light': #E6B673,  'mirage': #FFC44C}
  " let s:palette.keyword   = {'dark': #FF7733,  'light': #FF7733,  'mirage': #FFAE57}

  " let s:palette.error     = {'dark': #FF3333,  'light': #FF3333,  'mirage': #FF3333}
  " let s:palette.accent    = {'dark': #F29718,  'light': #FF6A00,  'mirage': #FFCC66}
  " let s:palette.panel     = {'dark': #14191F,  'light': #FFFFFF,  'mirage': #272D38}
  " let s:palette.guide     = {'dark': #2D3640,  'light': #D9D8D7,  'mirage': #3D4751}
  " let s:palette.line      = {'dark': #151A1E,  'light': #F3F3F3,  'mirage': #242B38}
  " let s:palette.selection = {'dark': #253340,  'light': #F0EEE4,  'mirage': #343F4C}
  " let s:palette.fg        = {'dark': #E6E1CF,  'light': #5C6773,  'mirage': #D9D7CE}
  " let s:palette.fg_idle   = {'dark': #3E4B59,  'light': #828C99,  'mirage': #607080}

  " My Delete suggestion
  " hi! DiffDelete guibg=#f27983 guifg=#212733
  " hi! DiffDelete guifg=#f27983 guibg=#212733
  " WildMenu colors
  " hi! DiffDelete guifg=#212733 guibg=#F07178
  " My Add suggestion
  " hi! DiffAdd guibg=#a6cc70 guifg=#212733
  " hi! DiffAdd guifg=#a6cc70 guifg=#272D38
  " }}}

  if s:theme_to_use == "palenight"
    set termguicolors
    set background=dark
    silent! colorscheme palenight
  endif

  if s:theme_to_use == "gruvbox"
    set termguicolors
    set background=dark
    let g:gruvbox_contrast_dark = "medium"
    silent! colorscheme gruvbox
  endif

else
  silent! colorscheme onedark
  hi Normal ctermbg=000
endif


" }}}

" {{{ Keybinds
" ============================================================================ "
" ===                           KEYBINDS                            === "
" ============================================================================ "

" toggle hardtime
" nnoremap <Leader><Leader>h :HardTimeToggle<CR>
" open netwr in vertical split
nnoremap <Leader>n :Vexplore<CR>
" turn off search highlight
" nnoremap <Leader><Leader>, :nohlsearch<CR>
" toggle relative line numbering
" nnoremap <silent> <Leader>r :set invrelativenumber<CR>
nnoremap <silent> <Leader>tl :set invrelativenumber<CR>

" Shortcuts for saving and quitting
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>bk :bd<CR>
nnoremap <Leader>z za<CR>
" nnoremap <Leader>fo zo<CR>
" nnoremap <Leader>fc za<CR>


" ==== MOVEMENT ====
" move vertically by visual line
nnoremap <silent> j gj
nnoremap <silent> k gk
" nnoremap <CR> G
" nnoremap <CR> o<Esc>

" Map fzf commands
nnoremap <C-P> :Files<CR>
nnoremap <Leader><Leader> :Files<CR>
nnoremap <Leader>. :Files<CR>
nnoremap <Leader>bb :Buffers<CR>
nnoremap <Leader>, :Buffers<CR>
nnoremap <leader>h :Helptags<CR>
nnoremap <leader>/b :BLines<CR>
nnoremap <leader>/d :Lines<CR>

" nnoremap <leader>,m :Marks<CR>
" nnoremap <leader>,sh :History/<CR>
" nnoremap <leader>,ch :History:<CR>

nnoremap <leader>sr :SignifyRefresh<CR>

nnoremap <Leader><Leader>r :source $MYVIMRC<CR>

" vim-fugitive mappings
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gw :Gwrite<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gb :Gbrowse<CR>
vnoremap <Leader>gb :Gbrowse<CR>

" }}}

" experimentating

set path+=**
set wildignore+=**/node_modules/**
set wildmenu

set synmaxcol=128
syntax sync minlines=256

set diffopt=internal,algorithm:patience
set lazyredraw

" vim:foldmethod=marker:foldlevel=0
