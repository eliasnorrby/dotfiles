" Why is this here? 
scriptencoding utf-8
set encoding=utf-8

let mapleader=" "
nnoremap <Space> <Nop>

" {{{ Plugins
" ============================================================================ "
" ===                           PLUGINS                            === "
" ============================================================================ "
" Download vimplug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'godlygeek/tabular'
Plug 'wellle/targets.vim'
" Plug 'jiangmiao/auto-pairs'
Plug 'raimondi/delimitmate'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
" Plug 'bling/vim-bufferline'
Plug 'mhinz/vim-signify'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'

" These border on medium 
" Plug 'ajh17/VimCompletesMe'

Plug 'takac/vim-hardtime'

Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'haya14busa/vim-textobj-function-syntax'

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" source ~/.dotfiles/vim/plugins.vim
" source ~/.dotfiles/vim/medium-plugins.vim
" source ~/.dotfiles/vim/overkill-plugins.vim

if has("nvim")
    " nvim plugins
  Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
  Plug 'w0rp/ale'
  Plug 'janko-m/vim-test'
  Plug 'benmills/vimux'
  Plug 'tpope/vim-dispatch'

endif


call plug#end()

" {{{ nvim plugins
if has("nvim")
  " nvim plugin settings
  " {{{ coc.vim
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

  " as suggested in https://github.com/Valloric/YouCompleteMe/issues/232
  imap <expr> <CR> pumvisible() ? "\<c-y>" : "<Plug>delimitMateCR"
  " imap <expr> <CR> pumvisible() ? "\<c-y>" : "\<c-r>"

  augroup Completion
    "Close preview window when completion is done.
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
  augroup END

  " Prettier command
  " command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

  " vmap <leader>p  <Plug>(coc-format-selected)
  " nmap <leader>p  <Plug>(coc-format-selected)

  " Some recommended defaults
  " Better display for messages
  set cmdheight=2

  " Smaller updatetime for CursorHold & CursorHoldI
  set updatetime=300

  " don't give |ins-completion-menu| messages.
  set shortmess+=c

  " Remap keys for gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " What is the preview window even?
  " Use K for show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Remap for rename current word
  nmap <leader>rn <Plug>(coc-rename)
  " }}}
  
  " {{{ ale
  let g:ale_linters = {
      \  'javascript': ['eslint'],
      \  'typescript': ['eslint']
      \}

  " One symbol config...
  let g:ale_sign_error = '✖'
  let g:ale_sign_warning = '⚠'
  " highlight ALEErrorSign ctermbg=NONE ctermfg=red guibg=NONE guifg=#FF3333
  " highlight ALEWarningSign ctermbg=NONE ctermfg=yellow guibg=NONE guifg=#FFCC66
  " highlight link ALEErrorSign    CocErrorSign
  " highlight link ALEWarningSign  CocWarningSign
  " }}}

  " {{{ vim-test

  " make test commands execute using vimux.vim
  let test#strategy = "vimux"

  nnoremap <silent> <Leader>tn :TestNearest<CR>
  nnoremap <silent> <Leader>tf :TestFile<CR>
  nnoremap <silent> <Leader>ts :TestSuite<CR>
  nnoremap <silent> <Leader>tt :TestLast<CR>

  " let test#javascript#jasmine#file_pattern = '\.test\.ts'
  " let test#typescript#jasmine#file_pattern = '\.test\.ts'

  " --- {{{ TypeScript
  let g:test#javascript#jasmine#file_pattern = '\v.*\.test\.(ts|tsx)$'
  function! TypeScriptTransform(cmd) abort
    return substitute(a:cmd, '\v(.*)jasmine', 'JASMINE_CONFIG_PATH=jasmine.json \1jasmine', '')
  endfunction
  let g:test#custom_transformations = {'typescript': function('TypeScriptTransform')}
  let g:test#transformation = 'typescript'
  " --- }}}

  " }}}
  
  " }}}
endif

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" TODO: Remove, I don't use autopairs any more
" auto-pairs interferes with swedish characters
let g:AutoPairsShortcutFastWrap=''
silent! iunmap å
silent! iunmap ä
silent! iunmap ö

" auto-pairs remaps backspace and it's incredibly hard to fix
" let g:AutoPairsMapBS = 1
" IDEA: Modify hartimes mapping of BS to trigger autopairdelete
" exec "inoremap <buffer> <silent> <expr> " . i . " TryKey('" . i . "') ? " . s:RetrieveMapping(i, "i") . " : TooSoon('" . ii . "','i')"
" let g:AutoPairsDelete=''
" iunmap <buffer> <BS>
" inoremap <buffer> <BS> <BS>
" silent! iunmap 
" inoremap  <NOP>
" inoremap  <NOP> 
" inoremap <BS> <NOP>
" inoremap <buffer> <BS> <BS>

" vim-hardtime
let g:hardtime_default_on = 0 
let g:hardtime_showmsg = 0
let g:hardtime_maxcount = 1
let g:hardtime_allow_different_key = 1
let g:list_of_insert_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
let g:list_of_disabled_keys = ["<BS>"]
" set backspace=indent

" vim-prettier
let g:prettier#exec_cmd_path = "/Users/elias.norrby/.nvm/versions/node/v10.15.1/bin/prettier"
let g:prettier#autoformat = 0
augroup Prettier
  autocmd! 
  autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier
augroup END

" Polyglot incorrectly marks js files as jsx :(
let g:jsx_ext_required = 1

" Does this conflict with dispatch?
" To make signify update on Gcommit
" autocmd User Fugitive SignifyRefresh

" }}}

" {{{ Editing options
" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" set colorcolumn=+2
" set colorcolumn=120
" highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

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

set laststatus=2    " for showing lightline
set noshowmode 

set clipboard=unnamed
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

" :set listchars=eol:¬,tab:>·,trail:·,extends:>,precedes:<,space:␣
" set listchars=eol:¬,trail:␣
" set list
set hidden
set signcolumn=yes

" ==== SPACES & TABS ====
set tabstop=8       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent      " enable autoindent
" set smartindent     " enable smart indenting
set shiftwidth=2    " number of spaces to use when indenting
" set smarttab        " smart tabs (beginning of line behavior)
set linebreak       " line wrapping
" filetype plugin indent on " probably on by default

set autoread
" set backspace=indent,eol,start
" is equal to:
" set backspace=2

set smartcase
set ignorecase

" if !has("nvim") 
"   set noesckeys " Make esc register immediately
" endif
" set nocompatible

set ttimeoutlen=10
" This could be used to reduce the timeout for only the esc key
" set ttimeoutlen=250
" augroup InsertTimeout
"   autocmd!
"   autocmd InsertEnter * set timeoutlen=10
"   autocmd InsertLeave * set timeoutlen=250
" augroup END

set foldmethod=marker
set foldlevelstart=20
" set foldcolumn=1
" set foldmarker={{{,}}}

" this is the default
" set complete=.,w,b,u,t,i
" set complete=.,b,u,]
" set wildmode=longest,list:longest

" }}}

" {{{ UI
" ============================================================================ "
" ===                           UI                            === "
" ============================================================================ "

syntax enable " enable syntax processing

augroup WindowSize
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
" set showmatch      " highlight matching [{()}]
" set matchtime=3    " reduce time for showing matching parens

set incsearch      " search as characters are entered
set nohlsearch     " highlight matches


augroup CursorLine
  autocmd!
  autocmd InsertEnter * highlight CursorLine guibg=#2D3B4D
  autocmd InsertLeave * highlight CursorLine guibg=#232834
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
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
    \ 'colorscheme': 'ayucustom',
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
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' },
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
  highlight!   Normal              ctermbg=NONE    guibg=NONE
  highlight!   NonText             ctermbg=NONE    guibg=NONE
  highlight!   LineNr              ctermbg=NONE    guibg=NONE
  highlight!   SignColumn          ctermbg=NONE    guibg=NONE

  " Highlight git change signs
  highlight!   SignifySignAdd                      guibg=NONE   guifg=#99c794
  highlight!   SignifySignDelete                   guibg=NONE   guifg=#ec5f67
  highlight!   SignifySignChange                   guibg=NONE   guifg=#c594c5

  " ALE Signs
  highlight link ALEErrorSign    CocErrorSign
  highlight link ALEWarningSign  CocWarningSign

  " ayu-vim is missing this highlight
  hi! DiffDelete guifg=#f27983 guibg=#272D38
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme * call MyHighlights()
augroup END

" TODO: Sourcing MYVIMRC breaks Ale highlighting
if has("termguicolors")
  set termguicolors     " enable true colors support
  let ayucolor="mirage" " for mirage version of theme
  colorscheme ayu 
  " My Delete suggestion
  " hi! DiffDelete guibg=#f27983 guifg=#212733
  " hi! DiffDelete guifg=#f27983 guibg=#212733
  " WildMenu colors
  " hi! DiffDelete guifg=#212733 guibg=#F07178
  " My Add suggestion
  " hi! DiffAdd guibg=#a6cc70 guifg=#212733
  " hi! DiffAdd guifg=#a6cc70 guifg=#272D38
else
  colorscheme onedark
  hi Normal ctermbg=000
endif


" }}}

" {{{ Keybinds
" ============================================================================ "
" ===                           KEYBINDS                            === "
" ============================================================================ "


" toggle hardtime
nnoremap <Leader><Leader>h :HardTimeToggle<CR>
" open netwr in vertical split
nnoremap <Leader>n :Vexplore<CR>
" turn off search highlight
nnoremap <Leader>, :nohlsearch<CR>
" toggle relative line numbering
nnoremap <silent> <Leader>r :set invrelativenumber<CR>

" Shortcuts for saving and quitting
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>c :bd<CR>
nnoremap <Leader>f za<CR>
" nnoremap <Leader>fo zo<CR>
" nnoremap <Leader>fc za<CR>


" ==== MOVEMENT ====
" move vertically by visual line
nnoremap <silent> j gj
nnoremap <silent> k gk
" nnoremap <CR> G
" nnoremap <CR> o<Esc>

" " split navigation
" nnoremap <Leader>h <C-W>h
" nnoremap <Leader>j <C-W>j
" nnoremap <Leader>k <C-W>k
" nnoremap <Leader>l <C-W>l

" Map fzf commands
nnoremap <C-P> :Files<CR>
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>b :Buffers<CR>

nnoremap <Leader><Leader>r :source $MYVIMRC<CR>
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt

nnoremap <Leader>g `


" }}}
