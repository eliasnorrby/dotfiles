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

" windows
nnoremap <silent> <leader>w <C-W>

" folding
nnoremap <silent> <leader>fa za<CR>
nnoremap <silent> <leader>fo zo<CR>
nnoremap <silent> <leader>fc zc<CR>
nnoremap <silent> <leader>fO zR<CR>
nnoremap <silent> <leader>fC zM<CR>

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
