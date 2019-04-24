" Why is this here? 
scriptencoding utf-8
set encoding=utf-8

let mapleader=" "
nnoremap <Space> <Nop>

" {{{ Plugins
" ============================================================================ "
" ===                           PLUGINS                                    === "
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
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fugitive'
" vim-endwise seems to interefere with coc/delimitmate mapping
" Plug 'tpope/vim-endwise'
Plug 'junegunn/gv.vim'
Plug 'godlygeek/tabular'
Plug 'wellle/targets.vim'
Plug 'raimondi/delimitmate'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'mhinz/vim-signify'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'junegunn/seoul256.vim'

Plug 'takac/vim-hardtime'
Plug 'ap/vim-buftabline'
Plug 'easymotion/vim-easymotion'
Plug 'edkolev/tmuxline.vim'
" Plug 'haya14busa/incsearch.vim'

" This is very situational and seems to slow down rendering, enable on demand.
" Seems like neovim does this by default
" Plug 'ap/vim-css-color'

Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'haya14busa/vim-textobj-function-syntax'
Plug 'junegunn/goyo.vim'

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

if has("nvim")
  " nvim plugins
  Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
  Plug 'w0rp/ale'
  " not technically requiring nvim 
  Plug 'janko-m/vim-test'
  Plug 'benmills/vimux'
  Plug 'tpope/vim-dispatch'
endif

call plug#end()

" map /  <Plug>(incsearch-forward)
" map ?  <Plug>(incsearch-backward)
" map g/ <Plug>(incsearch-stay)

let g:tmuxline_powerline_separators = 0

map \ <Plug>(easymotion-prefix)

" {{{ nvim plugin settings
if has("nvim")
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

  " use <cr> to accept completion
  " as suggested in https://github.com/Valloric/YouCompleteMe/issues/232
  imap <expr> <CR> pumvisible() ? "\<c-y>" : "<Plug>delimitMateCR"
  " imap <expr> <CR> pumvisible() ? "\<c-y>" : "\<c-r>"

  augroup CocCompletionAutoClose
    "Close preview window when completion is done.
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
  augroup END

  " Prettier command
  " Maybe I will switch to running Prettier and eslint in coc
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

  " TODO: Remap these after installing vim-unimpaired
  " Use `[e` and `]e` to navigate diagnostics
  " nmap <silent> [e <Plug>(coc-diagnostic-prev)
  " nmap <silent> ]e <Plug>(coc-diagnostic-next)

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
  " let test#strategy = "dispatch"

  nnoremap <silent> <Leader>tn :TestNearest<CR>
  nnoremap <silent> <Leader>tf :TestFile<CR>
  nnoremap <silent> <Leader>ts :TestSuite<CR>
  nnoremap <silent> <Leader>tt :TestLast<CR>

  nnoremap <silent> <leader>toe :call EnableTestOnSave()<CR>
  nnoremap <silent> <leader>tod :call DisableTestOnSave()<CR>

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
" let g:prettier#exec_cmd_path = "/Users/elias.norrby/.nvm/versions/node/v10.15.1/bin/prettier"
let g:prettier#autoformat = 0
augroup PrettierAutoformat
  autocmd! 
  autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
augroup END

" Polyglot incorrectly marks js files as jsx :(
let g:jsx_ext_required = 1

" Does this conflict with dispatch?
" To make signify update on Gcommit
" autocmd User Fugitive SignifyRefresh

" vim-buftabline
let g:buftabline_show = 1
let g:buftabline_numbers = 2
let g:buftabline_indicators = 1

" go to tabs based on their ordinal number
nmap <leader>1 <Plug>BufTabLine.Go(1)
nmap <leader>2 <Plug>BufTabLine.Go(2)
nmap <leader>3 <Plug>BufTabLine.Go(3)
nmap <leader>4 <Plug>BufTabLine.Go(4)
nmap <leader>5 <Plug>BufTabLine.Go(5)
nmap <leader>6 <Plug>BufTabLine.Go(6)
nmap <leader>7 <Plug>BufTabLine.Go(7)
nmap <leader>8 <Plug>BufTabLine.Go(8)
nmap <leader>9 <Plug>BufTabLine.Go(9)
nmap <leader>0 <Plug>BufTabLine.Go(10)

" vim-css-color
nmap <leader><leader>c :call css_color#toggle()<cr>

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

" let s:theme_to_use="ayu"
let s:theme_to_use="gruvbox"
" let s:theme_to_use="seoul256"

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
" set showmatch      " highlight matching [{()}]
" set matchtime=3    " reduce time for showing matching parens

set incsearch      " search as characters are entered
set nohlsearch     " highlight matches


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
    \ 'colorscheme': 'gruvbox',
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

  " ayu-vim is missing this highlight
  highlight!   DiffDelete                      guibg=#272D38 guifg=#F27983


  if s:theme_to_use == "ayu"
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
    colorscheme ayu 
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

  if s:theme_to_use == "gruvbox"
    set termguicolors
    set background=dark
    let g:gruvbox_contrast_dark = "medium"
    colorscheme gruvbox
  endif

  if s:theme_to_use == "seoul256"
    let g:seoul256_background = 235
    colorscheme seoul256
  endif
else
  colorscheme onedark
  hi Normal ctermbg=000
endif


" }}}

" {{{ Keybinds
" ============================================================================ "
" ===                           KEYBINDS                            === "
" ============================================================================ "

function! EnableTestOnSave() abort
  augroup TestOnSave
    autocmd! * <buffer>
    autocmd BufWrite <buffer> :TestLast
  augroup END
  echom "Run last test on save: enabled"
endfunction

function! DisableTestOnSave() abort
  augroup TestOnSave
    autocmd! * <buffer>
  augroup END
  echom "Run last test on save: disabled"
endfunction

" toggle hardtime
nnoremap <Leader><Leader>h :HardTimeToggle<CR>
" open netwr in vertical split
nnoremap <Leader>n :Vexplore<CR>
" turn off search highlight
nnoremap <Leader><Leader>, :nohlsearch<CR>
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
nnoremap <leader>h :Helptags<CR>
nnoremap <leader>/ :BLines<CR>
nnoremap <leader>? :Lines<CR>

nnoremap <leader>,m :Marks<CR>
nnoremap <leader>,sh :History/<CR>
nnoremap <leader>,ch :History:<CR>

nnoremap <Leader><Leader>r :source $MYVIMRC<CR>

nnoremap <Leader>g `


" }}}
