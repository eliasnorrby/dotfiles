Plug 'SirVer/ultisnips', { 'on': [] }

let g:UltiSnipsExpandTrigger=";;"
let g:UltiSnipsJumpForwardTrigger=";n"
let g:UltiSnipsJumpBackwardTrigger=";N"

function! LoadUltiSnips()
  call plug#load('ultisnips')
  echo 'UltiSnips loaded!'
endfunction

imap <silent> ;; <esc>:call LoadUltiSnips()<CR>a;;
