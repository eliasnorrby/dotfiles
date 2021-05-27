Plug 'tpope/vim-fugitive'

nnoremap <leader>gg :Git<CR>
nnoremap <leader>gG :Git<CR>:wincmd T<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gc :Git commit -v<CR>
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gB :GBrowse<CR>
xnoremap <leader>gb :GBrowse<CR>
