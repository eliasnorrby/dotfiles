Plug 'editorconfig/editorconfig-vim'

let g:EditorConfig_exclude_patterns = ['fugitive://.*']

nnoremap <leader>te :EditorConfigDisable<CR>
nnoremap <leader>tE :EditorConfigEnable<CR>
