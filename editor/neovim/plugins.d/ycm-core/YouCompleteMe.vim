Plug 'ycm-core/YouCompleteMe', {
  \ 'on': [],
  \ 'do': './install.py --ts-completer' }

" ALE in quickfix
" YCM in location list
let g:ycm_always_populate_location_list = 1
" trigger completion manually
let g:ycm_auto_trigger = 0
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0

augroup load_ycm
    autocmd!
    autocmd CursorHold *.ts,*.tsx,*.js,*.jsx call plug#load('YouCompleteMe') | autocmd! load_ycm
augroup END

nnoremap <silent> gd :YcmCompleter GoTo<CR>
nnoremap <silent> gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>cr :YcmCompleter RefactorRename<space>
nnoremap <silent> <leader>cf :YcmCompleter FixIt<CR>
nnoremap <silent> <leader>sd :YcmDiags<CR>
nnoremap <silent> ge :YcmShowDetailedDiagnostic<CR>
nnoremap <silent> gh :YcmCompleter GetType<CR>
