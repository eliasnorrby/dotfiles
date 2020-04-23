"         ___                                  __          "
"   ___  / (_)___ __________  ____  __________/ /_  __  __ "
"  / _ \/ / / __ `/ ___/ __ \/ __ \/ ___/ ___/ __ \/ / / / "
" /  __/ / / /_/ (__  ) / / / /_/ / /  / /  / /_/ / /_/ /  "
" \___/_/_/\__,_/____/_/ /_/\____/_/  /_/  /_.___/\__, /   "
"                                                /____/    "
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

" Plugins: {{{

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

" Editing:
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'raimondi/delimitmate'
Plug 'mattn/emmet-vim'

" Config:
Plug 'editorconfig/editorconfig-vim'

" Snippets:
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Ui:
Plug 'tpope/vim-vinegar'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'mhinz/vim-signify'

" Navigation:
Plug 'tpope/vim-unimpaired'
Plug 'easymotion/vim-easymotion'

" Git:
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Text_objects:
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'whatyouhide/vim-textobj-xmlattr'
Plug 'haya14busa/vim-textobj-function-syntax'

" Filetypes_and_syntax:
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'

" Fuzzy_finder:
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" Tmux_integration:
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'

" Colorschemes:
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'

" Miscellaneous:
Plug 'takac/vim-hardtime'

" Formatting:
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" Completion:
" Plug 'ycm-core/YouCompleteMe' , { 'for': 'typescript' }
" Plug 'ycm-core/YouCompleteMe'
Plug 'ycm-core/YouCompleteMe', {
  \ 'on': [],
  \ 'do': './install.py --ts-completer' }

augroup load_ycm
    autocmd!
    autocmd CursorHold * call plug#load('YouCompleteMe') | autocmd! load_ycm
augroup END

call plug#end()

" Setings: easymotion {{{
map gs <Plug>(easymotion-prefix)
map gs<Space> <Plug>(easymotion-sn)
" }}}

" Settings: tmux-navigator {{{
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1
" }}}

" Settings: vim-hardtime {{{
let g:hardtime_default_on = 0
let g:hardtime_showmsg = 0
let g:hardtime_maxcount = 1
let g:hardtime_allow_different_key = 1
let g:list_of_insert_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
let g:list_of_disabled_keys = ["<BS>"]
" }}}

" Settings: vim-prettier {{{
let g:prettier#autoformat = 0
nnoremap <leader>ff :PrettierAsync<CR>
" Format certain files on save
" augroup PrettierAutoformat
"   autocmd!
"   autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html PrettierAsync
" augroup END
" }}}

" Settings: vim-polyglot {{{
" Polyglot incorrectly marks js files as jsx :(
let g:jsx_ext_required = 1
" }}}

" Settings: vim-signify {{{
" Does this conflict with dispatch?
" To make signify update on Gcommit
" autocmd User Fugitive SignifyRefresh
let g:signify_sign_change = '~'
" }}}

" Settings: delimitmate {{{
let delimitMate_expand_cr=1
" }}}

" Settings: emmet-vim {{{
let g:user_emmet_mode='inv'
let g:user_emmet_leader_key=','
" let g:user_emmet_settings = {
" \ 'html' : {
" \     'indent_blockelement' : 1,
" \   }
" \ }
inoremap ,<CR> <CR><C-o>==<C-o>O
" }}}

" Settings: fzf-vim {{{
" Show a preview window during file selection
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
" }}}

" Settings: YouCompleteMe {{{
nnoremap <silent> gd :YcmCompleter GoTo<CR>
nnoremap <silent> gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>cr :YcmCompleter RefactorRename<space>
nnoremap <silent> <leader>cf :YcmCompleter FixIt<CR>
let g:ycm_always_populate_location_list = 1
" }}}

" Settings: UltiSnips {{{
" let g:UltiSnipsExpandTrigger="<c-s>"
" let g:UltiSnipsJumpForwardTrigger="<c-f>"
" let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsExpandTrigger=";s"
let g:UltiSnipsJumpForwardTrigger=";n"
let g:UltiSnipsJumpBackwardTrigger=";N"
" }}}

" Settings: editorconfig {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
" }}}

" }}}

" Editing_options: {{{
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

set updatetime=500

set clipboard=unnamed

" ==== BACKUPS ETC ====
set backup                       " enable backups
set undofile                     " for storing undos
set noswapfile                 " disable swapfiles
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

" UI: {{{

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

" ==== netwr ====
" absolute width of netrw window
let g:netrw_winsize = -28

" tree-view
let g:netrw_liststyle = 3

"  sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" open file in a new tab
let g:netrw_browse_split = 3

" Lightline: {{{

let g:lightline = {
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
  \ },
  \ 'tab_component_function': {
  \   'filename': 'LightlineTabname'
  \ },
  \ }
  " \ 'separator': { 'left': '', 'right': '' },
  " \ 'subseparator': { 'left': '', 'right': '' },
  " \ }

function! LightlineFileformat() abort
  return winwidth(0) > 90 ? &fileformat : ''
endfunction

function! LightlineFileencoding() abort
  return winwidth(0) > 80 ? &fileencoding : ''
endfunction

function! LightlineFiletype() abort
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineReadonly() abort
  return &readonly ? '' : ''
endfunction

function! LightlineGitbranch() abort
  if winwidth(0) < 65
    return ''
  elseif exists('*gitbranch#name')
    let branch = gitbranch#name()
    return branch !=# '' ? ' '.branch : ''
  endif
  return ''
endfunction

function! LightlineTabname(n) abort
  return fnamemodify(getcwd(tabpagewinnr(a:n), a:n), ':t')
endfunction

" function! LightlineFugitive()
"   if exists('*fugitive#head')
"     let branch = fugitive#head()
"     return branch !=# '' ? ''.branch : ''
"   endif
"   return ''
" endfunction

" }}}


if has("termguicolors")
  set termguicolors
endif

if s:theme_to_use == "ayu"
  function! AyuCorrections() abort
    " Ayu fixes
    highlight!   LineNr              ctermbg=NONE    guibg=NONE
    highlight!   SignColumn          ctermbg=NONE    guibg=NONE
    highlight!   SignifySignAdd                      guibg=NONE   guifg=#99C794
    highlight!   SignifySignDelete                   guibg=NONE   guifg=#EC5F67
    highlight!   SignifySignChange                   guibg=NONE   guifg=#C594C5
  endfunction

  augroup AyuColors
    autocmd!
    autocmd ColorScheme ayu call AyuCorrections()
  augroup END

  let ayucolor="mirage" " for mirage version of theme
  let g:lightline.colorscheme = 'ayu'
  silent! colorscheme ayu
endif

if s:theme_to_use == "palenight"
  function! JsxHtmlItalics() abort
    highlight!   jsxAttrib ctermfg=180 guifg=#ffcb6b cterm=italic gui=italic
    highlight!   htmlArg cterm=italic gui=italic
  endfunction

  augroup PalenightColors
    autocmd!
    autocmd ColorScheme palenight call JsxHtmlItalics()
  augroup END

  set background=dark
  let g:palenight_terminal_italics=1
  let g:lightline.colorscheme = 'palenight'
  silent! colorscheme palenight
endif

if s:theme_to_use == "gruvbox"
  set background=dark
  let g:gruvbox_contrast_dark = "medium"
  let g:lightline.colorscheme = 'gruvbox'
  silent! colorscheme gruvbox
endif

" }}}

" Keybinds: {{{
" ============================================================================ "
" ===                           KEYBINDS                                   === "
" ============================================================================ "

" toggle hardtime
nnoremap <leader>th :HardTimeToggle<CR>
" open netwr in vertical split
nnoremap <leader>n :Vexplore<CR>
" toggle relative line numbering
nnoremap <silent> <leader>tl :set invrelativenumber<CR>
" toggle all line numbering
nnoremap <silent> <leader>tL :set invrelativenumber invnumber<CR>

" Shortcuts for saving and quitting
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>Q :q!<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>bk :bd<CR>
nnoremap <leader>z za<CR>
" nnoremap <leader>fo zo<CR>
" nnoremap <leader>fc za<CR>


" ==== MOVEMENT ====
" move vertically by visual line
nnoremap <silent> j gj
nnoremap <silent> k gk
" nnoremap <CR> G
" nnoremap <CR> o<Esc>

" Map fzf commands
nnoremap <C-P> :Files<CR>
nnoremap <leader><leader> :Files<CR>
nnoremap <leader>. :Files %:p:h<CR>
nnoremap <leader>bb :Buffers<CR>
nnoremap <leader>, :Buffers<CR>
nnoremap <leader>h :Helptags<CR>
nnoremap <leader>/b :BLines<CR>
nnoremap <leader>/d :Lines<CR>

" nnoremap <leader>,m :Marks<CR>
" nnoremap <leader>,sh :History/<CR>
" nnoremap <leader>,ch :History:<CR>

nnoremap <leader>sr :SignifyRefresh<CR>

nnoremap <leader>vr :source $MYVIMRC<CR>
nnoremap <leader>ve :tabedit $MYVIMRC <bar> :lcd $DOTFILES<CR>
" nnoremap <leader>ve :tabedit $MYVIMRC <bar>
"       \ :execute "lcd" fnamemodify($MYVIMRC, ":p:h")<CR>
nnoremap <leader>vo :tabedit $MYVIMRC<CR>

" vim-fugitive mappings
"
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :GBrowse<CR>
xnoremap <leader>gb :GBrowse<CR>

" }}}

" experimentating

set path+=**
set wildignore+=**/node_modules/**
set wildmenu

set synmaxcol=128
syntax sync minlines=256

" Performance optimizations:
set diffopt=internal,algorithm:patience
set lazyredraw

" Stuff I wanna use:
" - ,, for emmet
" - ,<cr> for opening tags
" - C-Wo for 'only-ing' a window
" ]b [b for buffers
" ]l [l from locations (ycm diagnostics)

" Trying to use tabs for projects
nnoremap <silent> <leader><tab>. :Windows<CR>
nnoremap <silent> <leader><tab>N :tabnew<CR>

nnoremap <silent> <leader><tab>1 1gt
nnoremap <silent> <leader><tab>2 2gt
nnoremap <silent> <leader><tab>3 3gt
nnoremap <silent> <leader><tab>4 4gt
nnoremap <silent> <leader><tab>5 5gt
nnoremap <silent> <leader><tab>6 6gt

nnoremap <silent> <leader><tab>cd :lcd %:p:h<CR>

" vim:foldmethod=marker:foldlevel=0
