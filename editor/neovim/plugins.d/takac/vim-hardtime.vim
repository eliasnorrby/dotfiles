Plug 'takac/vim-hardtime'

let g:hardtime_default_on = 0
let g:hardtime_showmsg = 0
let g:hardtime_maxcount = 2
let g:hardtime_allow_different_key = 1
let g:list_of_insert_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
let g:list_of_disabled_keys = ["<BS>"]

nnoremap <leader>th :HardTimeToggle<CR>
