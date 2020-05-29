Plug 'sheerun/vim-polyglot'

" let g:jsx_ext_required = 1
let g:vim_markdown_frontmatter = 1

augroup FiletypeCorrections
  autocmd!
  autocmd BufReadPost,BufNewFile tsconfig.json set filetype=jsonc
augroup END
