augroup GitSpelling
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

augroup MarkdownSpelling
  autocmd!
  autocmd Filetype markdown setlocal spell
augroup END

augroup WindowSizeEqual
  autocmd!
  autocmd VimResized * wincmd =
augroup END
