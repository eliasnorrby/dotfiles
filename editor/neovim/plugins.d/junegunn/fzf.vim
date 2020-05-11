Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }

if has('nvim') && !exists('g:fzf_layout')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0
    \| autocmd BufLeave <buffer> set laststatus=2
endif

" Show a preview window during file selection
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader><leader> :Files<CR>
nnoremap <silent> <leader>. :Files %:p:h<CR>
nnoremap <silent> <leader>P :Files! %:p:h<CR>
nnoremap <silent> <leader>bb :Buffers<CR>
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>
nnoremap <silent> <leader>, :Buffers<CR>
nnoremap <silent> <leader>h :Helptags<CR>
nnoremap <silent> <leader>/b :BLines<CR>
nnoremap <silent> <leader>/d :Lines<CR>
nnoremap <silent> <leader>// :Rg<CR>

nnoremap <leader>;m :Marks<CR>
nnoremap <leader>;sh :History/<CR>
nnoremap <leader>;ch :History:<CR>
