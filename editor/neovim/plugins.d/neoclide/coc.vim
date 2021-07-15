" Plug 'neoclide/coc.nvim', { 'branch': 'release', 'for': 'typescript,javascript,javascriptreact,typescriptreact,json,yaml,python' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" set cmdheight=2
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

if exists('*complete_info')
  inoremap <expr> <space> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<space>"
endif

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

augroup CocFormatting
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json,javascript setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" " Introduce function text object
" " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fix` command to fix eslint errors
command! -nargs=0 Fix :call CocAction('runCommand', 'eslint.executeAutofix')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

function! CocHighlightCorrections() abort
  " Parentheses in floating windows have weird bgs
  " CAUTION: This only works if the vim theme matches the terminal theme
  " https://github.com/neoclide/coc.nvim/issues/1248
  " highlight! Normal guibg=NONE

  " coc has very dark text highlight
  highlight!   CocHighlightText guibg=#3D4751
endfunction

augroup CocColorCorrections
  autocmd!
  autocmd Colorscheme * call CocHighlightCorrections()
augroup END

function! CocRefresh() abort
  silent CocDisable
  silent CocEnable
endfunction

let g:coc_custom_diagnostics_enabled = 1
function! CocToggleDiagnostic() abort
  let l:new_value = ! coc#util#get_config('diagnostic')['enable']
  call CocSetDiagnostic(l:new_value)
  call CocRefresh()
  call lightline#update()
endfunction

function! CocSetDiagnostic(enabled) abort
  let g:coc_custom_diagnostics_enabled = a:enabled
  " echo 'Coc Diagnostics: ' . (a:enabled ? 'enabled' : 'disabled')
  call coc#config('diagnostic.enable', a:enabled)
  if ! a:enabled && g:coc_custom_diagnostics_ui_enabled
    call CocSetDiagnosticUi(0)
  endif
endfunction

let g:coc_custom_diagnostics_ui_enabled = 0
function! CocToggleDiagnosticUi() abort
  let l:new_value = !g:coc_custom_diagnostics_ui_enabled
  call CocSetDiagnosticUi(l:new_value)
  call CocRefresh()
  call lightline#update()
endfunction

function! CocSetDiagnosticUi(enabled) abort
  let g:coc_custom_diagnostics_ui_enabled = a:enabled
  " echo 'Coc Diagnostics UI: ' . (a:enabled ? 'enabled' : 'disabled')
  call coc#config('diagnostic.virtualText', a:enabled)
  call coc#config('diagnostic.enableSign', a:enabled)
  if a:enabled && ! g:coc_custom_diagnostics_enabled
    call CocSetDiagnostic(1)
  endif
endfunction

nnoremap <silent> <leader>z :call CocRefresh()<cr>

nnoremap <silent> <leader>td :call CocToggleDiagnosticUi()<cr>
nnoremap <silent> <leader>tD :call CocToggleDiagnostic()<cr>
nnoremap <silent> <leader>ld :<C-u>CocList diagnostics<cr>
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

nmap <silent> go :CocList outline<cr>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Formatting
xmap <leader>f  <Plug>(coc-format-selected)
nnoremap <silent> <leader>ff :Format<cr>
nnoremap <silent> <leader>fe :Fix<cr>

nmap <leader>cr <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction)
nmap <leader>cf <Plug>(coc-fix-current)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
" Show commands.
nnoremap <silent> <leader>clc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <leader>clo  :<C-u>CocList outline<cr>
" Search workleader symbols.
nnoremap <silent> <leader>cls  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader>cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>ck  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <leader>lr  :<C-u>CocListResume<CR>

" Snippets:
imap <C-l> <Plug>(coc-snippets-expand)
imap ;e <Plug>(coc-snippets-expand)

let g:coc_snippet_next = ';n'
let g:coc_snippet_prev = ';N'

" Explorer:
nnoremap <silent> <leader>e :CocCommand explorer<CR>

" Git:
nmap [c <Plug>(coc-git-prevchunk)
nmap ]c <Plug>(coc-git-nextchunk)
nmap [C <Plug>(coc-git-prevconflict)
nmap ]C <Plug>(coc-git-nextconflict)
nmap <leader>ghd <Plug>(coc-git-chunkinfo)
nmap <leader>ghi <Plug>(coc-git-commit)

nnoremap <silent> <leader>ghs :CocCommand git.chunkStage<CR>
nnoremap <silent> <leader>ghu :CocCommand git.chunkUndo<CR>

nnoremap <silent> <leader>lb :<C-u>CocList branches<CR>
nnoremap <silent> <leader>li :<C-u>CocList issues<CR>
