Plug 'itchyny/lightline.vim'

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
function! SetupLightlineColors() abort
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
