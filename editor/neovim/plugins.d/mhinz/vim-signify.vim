Plug 'mhinz/vim-signify'

let g:signify_sign_change = '~'
let g:signify_disable_by_default = 1

nnoremap <silent> <leader>tsh :SignifyToggleHighlight<CR>
nnoremap <silent> <leader>tS :SignifyToggle<CR>
nnoremap <silent> <leader>sr :SignifyRefresh<CR>
