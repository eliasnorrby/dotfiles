Plug 'itchyny/lightline.vim'

" Settings: lightline {{{2
let g:lightline = {
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'relativepath' ],
  \             [ 'modified' ] ],
  \   'right': [ ['lineinfo'],
  \              ['percent'],
  \              ['lint_errors', 'lint_warnings', 'lint_infos', 'lint_ok'],
  \              ['filetype'] ],
  \ },
  \ 'inactive': {
  \   'left': [ ['relativepath'],
  \             ['modified'] ],
  \   'right': [ ['lineinfo'],
  \              ['percent'] ],
  \ },
  \ 'tabline': {
  \   'left': [['tabs']],
  \   'right': []
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
  \ 'component_expand': {
  \   'lint_errors': 'CocLintErr',
  \   'lint_warnings': 'CocLintWarn',
  \   'lint_infos': 'CocLintInfo',
  \   'lint_ok': 'CocLintOK'
  \ },
  \ 'component_type': {
  \   'lint_errors': 'error',
  \   'lint_warnings': 'warning',
  \   'lint_infos': 'warning',
  \   'lint_ok': 'ok'
  \ },
  \ }

function! CocLintCount(type) abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return 0 | endif
  return get(info, a:type, 0)
endfunction

function! CocLintFormat(type, symbol) abort
  let l:num = CocLintCount(a:type)
  if !l:num | return '' | endif
  return a:symbol . l:num
endfunction

function! CocLintErr() abort
  return CocLintFormat('error', ' ')
endfunction

function! CocLintWarn() abort
  return CocLintFormat('warning', ' ')
endfunction

function! CocLintInfo() abort
  return CocLintFormat('information', ' ')
endfunction

function! CocLintOK() abort
  if ! get(g:, 'coc_service_initialized', 0) | return ' ' | endif
  if ! get(g:, 'coc_custom_diagnostics_enabled', 0) | return ' ' | endif
  let l:all_num = CocLintCount('error') + CocLintCount('warning') + CocLintCount('information')
  if l:all_num == 0 | return ' ' | endif
  return ''
endfunction

augroup CocStatus
  autocmd!
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
augroup END

" let g:lightline.subseparator = { 'left': '╏', 'right': '╏' }
let g:lightline.subseparator = { 'left': '┃', 'right': '┃' }
set laststatus=2

function! LightlineModified() abort
  return &modified ? '✚' : ''
endfunction

function! LightlineFileformat() abort
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFileencoding() abort
  return winwidth(0) > 60 ? &fileencoding : ''
endfunction

function! LightlineFiletype() abort
  return winwidth(0) > 50 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineReadonly() abort
  return &readonly ? '' : ''
endfunction

function! LightlineGitbranch() abort
  if winwidth(0) < 65
    return ''
  elseif exists('*gitbranch#name')
    let max_length = 20
    let branch = gitbranch#name()
    let display_branch = strlen(branch) > 20 ? branch[:17].'...' : branch
    return branch !=# '' ? ' '.display_branch : ''
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
