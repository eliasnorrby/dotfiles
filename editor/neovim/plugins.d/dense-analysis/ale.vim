Plug 'dense-analysis/ale'

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
