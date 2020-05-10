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
nnoremap <space> <nop>

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  " set fcs=eob:\
  set inccommand=nosplit
endif

" Plugins: {{{1
" ============================================================================ "
" ===                           PLUGINS                                    === "
" ============================================================================ "

" Download vimplug if not already installed
" if empty(glob($VIM_DIR.'/autoload/plug.vim'))
"   silent !curl -sfLo $VIM_DIR/autoload/plug.vim --create-dirs
"     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif

call plug#begin($XDG_DATA_HOME.'/vim/plugged')

" Editing:
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'raimondi/delimitmate'
Plug 'mattn/emmet-vim'

Plug 'tommcdo/vim-exchange'
Plug 'machakann/vim-highlightedyank'
Plug 'junegunn/vim-easy-align'

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
Plug 'ap/vim-css-color'

" Navigation:
Plug 'tpope/vim-unimpaired'
Plug 'easymotion/vim-easymotion'
Plug 'unblevable/quick-scope'

" Git:
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Text_objects:
Plug 'wellle/targets.vim'

" Filetypes_and_syntax:
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'

" Fuzzy_finder:
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" Tmux_integration:
" Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'

" Colorschemes:
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'

" Miscellaneous:
Plug 'tpope/vim-dispatch'
Plug 'takac/vim-hardtime'

" Formatting:
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" Linting:
Plug 'dense-analysis/ale'

" Completion:
Plug 'ycm-core/YouCompleteMe', {
  \ 'on': [],
  \ 'do': './install.py --ts-completer' }

call plug#end()

" Settings: vim-highlightedyank {{{2
let g:highlightedyank_highlight_duration = 100

" Settings: vim-unimpaired {{{2
xmap K [egv
xmap J ]egv

" Setings: easymotion {{{2
map gs <Plug>(easymotion-prefix)
map gs<space> <Plug>(easymotion-sn)

" Settings: tmux-navigator {{{2
" let g:tmux_navigator_disable_when_zoomed = 1

" Settings: vim-hardtime {{{2
let g:hardtime_default_on = 0
let g:hardtime_showmsg = 0
let g:hardtime_maxcount = 2
let g:hardtime_allow_different_key = 1
let g:list_of_insert_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
let g:list_of_disabled_keys = ["<BS>"]

nnoremap <leader>th :HardTimeToggle<CR>

" Settings: vim-prettier {{{2
let g:prettier#autoformat = 0
nnoremap <leader>ff :PrettierAsync<CR>
" Format certain files on save
" augroup PrettierAutoformat
"   autocmd!
"   autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html PrettierAsync
" augroup END

" Settings: vim-polyglot {{{2
" let g:jsx_ext_required = 1
let g:vim_markdown_frontmatter = 1
augroup FiletypeCorrections
  autocmd!
  autocmd BufReadPost,BufNewFile tsconfig.json set filetype=jsonc
augroup END

" Settings: vim-css-color {{{2
nnoremap <silent> <leader>tc :call css_color#toggle()<CR>

" Settings: vim-signify {{{2
let g:signify_sign_change = '~'
let g:signify_disable_by_default = 1

nnoremap <silent> <leader>tsh :SignifyToggleHighlight<CR>
nnoremap <silent> <leader>tS :SignifyToggle<CR>
nnoremap <silent> <leader>sr :SignifyRefresh<CR>

" Settings: delimitmate {{{2
let delimitMate_expand_cr=1

" Settings: emmet-vim {{{2
let g:user_emmet_mode='inv'
let g:user_emmet_leader_key=','
" Effortlessly indents new block elements, but breaks wrapping
" let g:user_emmet_settings = {
" \ 'html' : {
" \     'indent_blockelement' : 1,
" \   }
" \ }
inoremap ,; <CR><C-o>==<C-o>O

" Settings: fzf-vim {{{2
" let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }

if has('nvim') && !exists('g:fzf_layout')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0
    \| autocmd BufLeave <buffer> set laststatus=2
endif

" Show a preview window during file selection
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader><leader> :Files<CR>
nnoremap <silent> <leader>. :Files %:p:h<CR>
nnoremap <silent> <leader>P :Files! %:p:h<CR>
nnoremap <silent> <leader>bb :Buffers<CR>
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>
nnoremap <silent> <leader>, :Buffers<CR>
nnoremap <silent> <leader>h :Helptags<CR>
nnoremap <silent> <leader>/b :BLines<CR>
nnoremap <silent> <leader>/d :Lines<CR>
nnoremap <silent> <leader>// :Rg<CR>

nnoremap <leader>;m :Marks<CR>
nnoremap <leader>;sh :History/<CR>
nnoremap <leader>;ch :History:<CR>


" Settings: ALE {{{2
let g:ale_fixers = {
      \ 'javascript': ['eslint'],
      \ 'typescript': ['eslint'],
      \ 'javascriptreact': ['eslint'],
      \ 'typescriptreact': ['eslint'],
      \ }

" ALE even does completion?
" let g:ale_completion_enabled = 1
" let g:ale_completion_tsserver_autoimport = 1

" ALE in quickfix
" YCM in location list
let g:ale_set_quickfix=1

let g:ale_show_gui=0
let g:ale_set_signs=g:ale_show_gui
let g:ale_set_highlights=g:ale_show_gui
function! ToggleALEGui() abort
  if g:ale_show_gui
    let g:ale_show_gui=0
    echo 'Hiding ALE ui'
  else
    let g:ale_show_gui=1
    echo 'Showing ALE ui'
  endif
  exec 'ALEDisable'
  let g:ale_set_signs=g:ale_show_gui
  let g:ale_set_highlights=g:ale_show_gui
  exec 'ALEEnable'
endfunction

nnoremap <silent> <leader>td :call ToggleALEGui()<CR>
nnoremap <silent> <leader>tA :ALEToggle<CR>
" nnoremap <silent> <leader>cf :ALEFix<CR>

" Settings: YouCompleteMe {{{2
" ALE in quickfix
" YCM in location list
let g:ycm_always_populate_location_list = 1
" trigger completion manually
let g:ycm_auto_trigger = 0
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0

augroup load_ycm
    autocmd!
    autocmd CursorHold *.ts,*.tsx,*.js,*.jsx call plug#load('YouCompleteMe') | autocmd! load_ycm
augroup END

nnoremap <silent> gd :YcmCompleter GoTo<CR>
nnoremap <silent> gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>cr :YcmCompleter RefactorRename<space>
nnoremap <silent> <leader>cf :YcmCompleter FixIt<CR>
nnoremap <silent> <leader>sd :YcmDiags<CR>
nnoremap <silent> ge :YcmShowDetailedDiagnostic<CR>
nnoremap <silent> gh :YcmCompleter GetType<CR>

" Settings: UltiSnips {{{2
let g:UltiSnipsExpandTrigger=";s"
let g:UltiSnipsJumpForwardTrigger=";n"
let g:UltiSnipsJumpBackwardTrigger=";N"

" Settings: editorconfig {{{2
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Settings: quick-scope {{{2
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" Settings: vim-fugitive {{{2
nnoremap <leader>gg :Git<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gc :Git commit -v<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :GBrowse<CR>
xnoremap <leader>gb :GBrowse<CR>

" Settings: lightline {{{2
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
  \   'modified': 'LightlineModified',
  \ },
  \ 'tab_component_function': {
  \   'filename': 'LightlineTabname'
  \ },
  \ }

" let g:lightline.separator = { 'left': '', 'right': '' }
" let g:lightline.subseparator = { 'left': '', 'right': '' }
" let g:lightline.subseparator = { 'left': '｜', 'right': '｜' }
let g:lightline.subseparator = { 'left': '╏', 'right': '╏' }
set laststatus=2

function! LightlineModified() abort
  return &modified ? '✚' : ''
endfunction

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

" autocmd VimEnter * call SetupLightlineColors()
function SetupLightlineColors() abort
  " transparent background in statusbar
  let l:palette = lightline#palette()

  let l:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
  let l:palette.insert.middle = l:palette.normal.middle
  let l:palette.visual.middle = l:palette.normal.middle
  let l:palette.inactive.middle = l:palette.normal.middle
  let l:palette.tabline.middle = l:palette.normal.middle

  call lightline#colorscheme()
endfunction

function! LightlineReload() abort
  call lightline#init()
  call lightline#colorscheme()

  call SetupLightlineColors()

  call lightline#update()
endfunction

augroup LightlineRefresh
  autocmd!
  autocmd ColorScheme * call LightlineReload()
augroup END


" Searching: {{{1
set nohlsearch
set incsearch
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
nnoremap <leader>/p :silent grep<space>

" Editing_options: {{{1
" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "
set hidden
set updatetime=300
set clipboard=unnamed
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

augroup GitSpelling
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

" UI: {{{1
" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

syntax enable " enable syntax processing

augroup WindowSizeEqual
  autocmd!
  autocmd VimResized * wincmd =
augroup END

set splitbelow splitright
set scrolloff=5
set showcmd
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

if has("termguicolors")
  set termguicolors
endif

function! NoTildes() abort
  highlight! EndOfBuffer ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
endfunction

function! TransparentBg() abort
  highlight! Normal ctermbg=NONE guibg=NONE
  highlight! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
endfunction

function! JsxHtmlItalics() abort
  highlight!   jsxAttrib ctermfg=180 guifg=#ffcb6b cterm=italic gui=italic
  highlight!   htmlArg cterm=italic gui=italic
endfunction

function! JsObjectColors() abort
  highlight! def link jsObjectKey Identifier
  highlight! def link jsObjectValue jsObjectProp
endfunction

function! PalenightSetup() abort
  set background=dark
  if has('nvim')
    let g:palenight_terminal_italics = 1
  endif
  let g:lightline.colorscheme = 'palenight'
endfunction
augroup PalenightColors
  autocmd!
  autocmd ColorSchemePre palenight call PalenightSetup()
  autocmd ColorScheme palenight call TransparentBg()
  autocmd ColorScheme palenight call NoTildes()
  if has('nvim')
    autocmd ColorScheme palenight call JsxHtmlItalics()
  endif
  autocmd ColorScheme palenight call JsObjectColors()
augroup END

function! GruvboxSetup() abort
  set background=dark
  let g:gruvbox_contrast_dark = "medium"
  let g:gruvbox_sign_column = "bg0"
  let g:gruvbox_italic = 1
  let g:lightline.colorscheme = 'gruvbox'
endfunction
augroup GruvboxColors
  autocmd!
  autocmd ColorSchemePre gruvbox call GruvboxSetup()
augroup END

if empty($VIM_COLOR)
  " let s:theme_to_use="gruvbox"
  let s:theme_to_use="palenight"
else
  let s:theme_to_use=$VIM_COLOR
endif

execute 'colorscheme' s:theme_to_use


" Keybinds: {{{1
" ============================================================================ "
" ===                           KEYBINDS                                   === "
" ============================================================================ "
" For toggles: <leader>t...
" toggle relative line numbering
nnoremap <silent> <leader>tl :set invrelativenumber<CR>
" toggle all line numbering
nnoremap <silent> <leader>tL :set invrelativenumber invnumber<CR>

xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

nnoremap Q <nop>

" scroll faster
nnoremap <C-E> <C-E><C-E><C-E>
nnoremap <C-Y> <C-Y><C-Y><C-Y>

" open netwr in vertical split
nnoremap <leader>n :Vexplore<CR>

" Shortcuts for saving and quitting
nnoremap <silent> <leader>q :q<CR>
" nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>fs :w<CR>
nnoremap <silent> <leader>Q :q!<CR>
nnoremap <silent> <leader>bk :bd<CR>

nnoremap <silent> <leader>w <C-W>

" folding
nnoremap <silent> <leader>fa za<CR>
nnoremap <silent> <leader>fo zo<CR>
nnoremap <silent> <leader>fc zc<CR>
nnoremap <silent> <leader>fO zR<CR>
nnoremap <silent> <leader>fC zM<CR>

" ==== MOVEMENT ====
" move vertically by visual line
nnoremap <silent> j gj
nnoremap <silent> k gk

nnoremap <silent> <leader>vr :source $MYVIMRC<CR>
nnoremap <silent> <leader>ve :execute "tabedit" resolve($MYVIMRC) <bar> :lcd $DOTFILES<CR>
" nnoremap <leader>ve :tabedit $MYVIMRC <bar>
"       \ :execute "lcd" fnamemodify($MYVIMRC, ":p:h")<CR>

nnoremap <silent> <leader>lo :lopen<CR>
nnoremap <silent> <leader>lc :lclose<CR>
nnoremap <silent> <leader>co :copen<CR>
nnoremap <silent> <leader>cc :cclose<CR>
nnoremap <silent> <leader>LL :ll<CR>
nnoremap <silent> <leader>CC :cc<CR>


" Experimenting: {{{1
" ============================================================================ "
" ===                         EXPERIMENTING                                === "
" ============================================================================ "
set path+=**
set wildignore+=**/node_modules/**
set wildmenu

" Performance optimizations:
set diffopt=internal,algorithm:patience
set lazyredraw
" set synmaxcol=128
" syntax sync minlines=256

" Stuff I wanna use:
" - ,, for emmet
" - ,<cr> for opening tags
" - C-Wo for 'only-ing' a window
" ]b [b for buffers
" ]l [l for locations (ycm diagnostics)
" ]q [q for quickfix
" zj zk for next/previous fold
" @: to replay previous command
" q: to use command window

" Trying to use tabs for projects
nnoremap <silent> <leader><tab>. :Windows<CR>
nnoremap <silent> <leader><tab>N :tabnew<CR>

nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt

nnoremap <silent> <leader><tab>cd :lcd %:p:h<CR>

" https://stackoverflow.com/a/9464929/4776907
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" vim:foldmethod=marker:foldlevel=20
