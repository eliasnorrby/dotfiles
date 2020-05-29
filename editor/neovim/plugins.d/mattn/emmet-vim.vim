Plug 'mattn/emmet-vim'

let g:user_emmet_mode='inv'
let g:user_emmet_leader_key=','
" Effortlessly indents new block elements, but breaks wrapping
" let g:user_emmet_settings = {
" \ 'html' : {
" \     'indent_blockelement' : 1,
" \   }
" \ }

inoremap ,; <CR><C-o>==<C-o>O
