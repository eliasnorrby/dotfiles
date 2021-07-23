" Experimenting: {{{1
" ============================================================================ "
" ===                         EXPERIMENTING                                === "
" ============================================================================ "
set path+=**
set wildignore+=**/node_modules/**
set wildmenu

" Performance optimizations:
set diffopt=internal,algorithm:patience
set lazyredraw
" set synmaxcol=128
" syntax sync minlines=256

" Stuff I wanna use:
" - ,, for emmet
" - ,<cr> for opening tags
" - C-Wo for 'only-ing' a window
" ]b [b for buffers
" ]l [l for locations (ycm diagnostics)
" ]q [q for quickfix
" zj zk for next/previous fold
" @: to replay previous command
" q: to use command window

" Trying to use tabs for projects
nnoremap <silent> <leader><tab>. :Windows<CR>
nnoremap <silent> <leader><tab>N :tabnew<CR>

nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt

nnoremap <silent> <leader><tab>cd :lcd %:p:h<CR>

" https://stackoverflow.com/a/9464929/4776907
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

set fcs=eob:.


command! -nargs=0 XMLFormat :%!xmllint --encode UTF-8 --format -

" ============================================================================ "
" ===                         NAVIGATION                                   === "
" ============================================================================ "

function! UnifiedNavigation(direction)
  let nr = winnr()
  exec 'wincmd ' . a:direction
  if nr == winnr()
    let cmd = 'navigate ' . tr(a:direction, 'hjkl', 'ldur') . ' 1'
    call system(cmd)
  endif
endfunction

nnoremap <silent> <c-h> :call UnifiedNavigation('h')<cr>
nnoremap <silent> <c-j> :call UnifiedNavigation('j')<cr>
nnoremap <silent> <c-k> :call UnifiedNavigation('k')<cr>
nnoremap <silent> <c-l> :call UnifiedNavigation('l')<cr>

" ============================================================================ "
" ===                            TABLINE                                   === "
" ============================================================================ "

set showtabline=1  " 1 to show tabline only when more than one tab is present
set tabline=%!MyTabLine()  " custom tab pages line
function! MyTabLine() " acclamation to avoid conflict
  let s = '' " complete tabline goes here
  " loop through each tab page
  for t in range(tabpagenr('$'))
    " set highlight
    if t + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " set the tab page number (for mouse clicks)
    let s .= '%' . (t + 1) . 'T'
    let s .= ' '
    " set page number string
    let s .= t + 1 . ' '
    " get buffer names and statuses
    let n = ''      "temp string for buffer names while we loop and check buftype
    let m = 0       " &modified counter
    let bc = len(tabpagebuflist(t + 1))     "counter to avoid last ' '
    " loop through each buffer in a tab
    for b in tabpagebuflist(t + 1)
      " buffer types: quickfix gets a [Q], help gets [H]{base fname}
      " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
      if getbufvar( b, "&buftype" ) == 'help'
        let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
      elseif getbufvar( b, "&buftype" ) == 'quickfix'
        let n .= '[Q]'
      else
        let n .= pathshorten(bufname(b))
      endif
      " check and ++ tab's &modified count
      if getbufvar( b, "&modified" )
        let m += 1
      endif
      " no final ' ' added...formatting looks better done later
      if bc > 1
        let n .= ' '
      endif
      let bc -= 1
    endfor
    " add modified label [n+] where n pages in tab are modified
    if m > 0
      let s .= '[' . m . '+]'
    endif
    " select the highlighting for the buffer names
    " my default highlighting only underlines the active tab
    " buffer names.
    if t + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " add buffer names
    if n == ''
      let s.= '[New]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space to buffer list
    let s .= ' '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  " right-align the label to close the current tab page
  " if tabpagenr('$') > 1
  "   let s .= '%=%#TabLineFill#%999Xclose'
  " endif
  return s
endfunction
