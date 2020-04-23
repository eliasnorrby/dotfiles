" Everything I ever did to make the Ayu theme work properly

Plug 'ayu-theme/ayu-vim'

" let s:theme_to_use="ayu"

augroup CursorLineOnInsert
  if s:theme_to_use == "ayu"
    autocmd!
    autocmd InsertEnter * highlight CursorLine ctermbg=237 guibg=#2D3B4D
    autocmd InsertLeave * highlight CursorLine ctermbg=0 guibg=#232834
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
  endif
augroup END


function! MyHighlights() abort
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

if has("termguicolors")
  if s:theme_to_use == "ayu"
    set termguicolors     " enable true colors support
    let ayucolor="mirage" " for mirage version of theme
    silent! colorscheme ayu 
  endif
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
