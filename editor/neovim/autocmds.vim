augroup GitSpelling
  autocmd!
  autocmd Filetype gitcommit setlocal spell textwidth=72
augroup END

augroup WindowSizeEqual
  autocmd!
  autocmd VimResized * wincmd =
augroup END


