" For toggles: <leader>t...
" toggle relative line numbering
nnoremap <silent> <leader>tl :set invrelativenumber<CR>
" toggle all line numbering
nnoremap <silent> <leader>tL :set invrelativenumber invnumber<CR>

nnoremap <leader>/pp :silent grep<space>
nnoremap <leader>/pw :silent grep! <C-R><C-W> <bar> cwindow<CR>
xnoremap <leader>/pw y:silent grep! <C-R>" <bar> cwindow<CR>

xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

nnoremap Q <nop>

" scroll faster
nnoremap <C-E> <C-E><C-E><C-E>
nnoremap <C-Y> <C-Y><C-Y><C-Y>

" saving & quitting
nnoremap <silent> <leader>q :q<CR>
nnoremap <silent> <leader>fs :w<CR>
nnoremap <silent> <leader>Q :q!<CR>
nnoremap <silent> <leader>X :qall!<CR>

" windows
nnoremap <silent> <leader>w <C-W>
" Zoom / Restore window.
function! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <leader>wf :ZoomToggle<CR>

" folding
nnoremap <silent> <leader>z zf
nnoremap <silent> <leader>fa za
nnoremap <silent> <leader>fo zo
nnoremap <silent> <leader>fc zc
nnoremap <silent> <leader>fO zR
nnoremap <silent> <leader>fC zM

nnoremap <silent> <Plug>FoldBraceBlock $zf%
      \:call repeat#set("\<Plug>FoldBraceBlock", v:count)<cr>
nmap <silent> <leader>fb <Plug>FoldBraceBlock

" move vertically by visual line
nnoremap <silent> j gj
nnoremap <silent> k gk

nnoremap <silent> <leader>vr :source $MYVIMRC<CR>
nnoremap <silent> <leader>ve :execute "tabedit" resolve($MYVIMRC) <bar> :lcd $DOTFILES/editor/neovim<CR>
nnoremap <silent> <leader>de :tabnew <bar> :lcd $DOTFILES<CR>

" location & quickfix lists
nnoremap <silent> <leader>lo :lopen<CR>
nnoremap <silent> <leader>lc :lclose<CR>
nnoremap <silent> <leader>co :copen<CR>
nnoremap <silent> <leader>cc :cclose<CR>
nnoremap <silent> <leader>LL :ll<CR>
nnoremap <silent> <leader>CC :cc<CR>

xnoremap <silent> <leader>x d<C-W><C-W>Gp<C-W><C-W>

" diff two buffers
function! ToggleDiff()
  if (&diff == 0)
    windo diffthis
  else
    windo diffoff
  endif
endfunction

nnoremap <silent> <leader>wd :call ToggleDiff()<CR>

" toggle scrollbind
function! ToggleScrollbind()
  if (&scrollbind == 0)
    windo set scrollbind
  else
    windo set noscrollbind
  endif
endfunction

nnoremap <silent> <leader>tb :call ToggleScrollbind()<CR>

nnoremap <silent> <leader>fz 1z=
nnoremap <silent> <Plug>FixNextSpelling ]s1z=
      \:call repeat#set("\<Plug>FixNextSpelling", v:count)<cr>
nmap <silent> <leader>fZ <Plug>FixNextSpelling

xnoremap <silent> <leader>ft :s/^  /	/<cr>

nnoremap - <Nop>
