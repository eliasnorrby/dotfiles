Plug 'tpope/vim-fugitive'

nnoremap <leader>gg :Git<CR>
nnoremap <leader>gG :Git<CR>:wincmd T<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gc :Git commit -v<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gB :Git blame<CR>
xnoremap <leader>gb :GBrowse<CR>

nnoremap <leader>gsc :GBrowse <C-r><C-w><CR>
