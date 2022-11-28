vim.cmd([[
function! UnifiedNavigation(direction)
  let nr = winnr()
  exec 'wincmd ' . a:direction
  if nr == winnr()
    let cmd = 'navigate ' . tr(a:direction, 'hjkl', 'ldur') . ' 1'
    call system(cmd)
  endif
endfunction

nnoremap <silent> <c-h> :call UnifiedNavigation('h')<cr>
nnoremap <silent> <c-j> :call UnifiedNavigation('j')<cr>
nnoremap <silent> <c-k> :call UnifiedNavigation('k')<cr>
nnoremap <silent> <c-l> :call UnifiedNavigation('l')<cr>
]])
