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

set fcs=eob:.
