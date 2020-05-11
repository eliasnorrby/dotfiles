Plug 'tpope/vim-vinegar'

" absolute width of netrw window
let g:netrw_winsize = -28
" tree-view
let g:netrw_liststyle = 3
" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'
" open file in a new tab
let g:netrw_browse_split = 3

" open netwr in vertical split
nnoremap <leader>n :Vexplore<CR>
