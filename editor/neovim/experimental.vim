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

nnoremap <silent> <leader>hl :call SynStack()<CR>

set fcs=eob:.


command! -nargs=0 XMLFormat :%!xmllint --encode UTF-8 --format -

" ============================================================================ "
" ===                         NAVIGATION                                   === "
" ============================================================================ "

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

" ============================================================================ "
" ===                            TABLINE                                   === "
" ============================================================================ "

set showtabline=1  " 1 to show tabline only when more than one tab is present

" ============================================================================ "
" ===                            BASE64                                    === "
" ============================================================================ "

nnoremap <silent> <leader>64 :echo system('base64 --decode', expand('<cWORD>'))<cr>

xnoremap <silent> <leader>64 c<c-r>=system('base64 --wrap 0', @")<cr><esc>
xnoremap <silent> <leader>d64 c<c-r>=system('base64 --decode', @")<cr><esc>
