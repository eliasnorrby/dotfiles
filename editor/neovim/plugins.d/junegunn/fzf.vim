" Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }

if has('nvim') && !exists('g:fzf_layout')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0
    \| autocmd BufLeave <buffer> set laststatus=2
endif

if has('nvim') || has('gui_running')
  let $FZF_DEFAULT_OPTS .= ' --inline-info'
endif

" Stuff from junegunn's dotfiles
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'TabLine'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" All files
command! -nargs=? -complete=dir AF
  \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \   'source': 'fd --type f --hidden --follow --exclude .git --exclude node_modules --no-ignore . '.expand(<q-args>)
  \ })))

" Show a preview window during file selection
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let options = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  if a:fullscreen
    let options = fzf#vim#with_preview(options)
  endif
  call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

let $FZF_DEFAULT_OPTS .= ' --bind ctrl-a:select-all'

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
