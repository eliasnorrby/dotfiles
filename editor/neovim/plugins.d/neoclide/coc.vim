" Plug 'neoclide/coc.nvim', { 'branch': 'release', 'for': 'typescript,javascript,javascriptreact,typescriptreact,json,yaml,python' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

set cmdheight=2
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

" Should match the diagnostic.enabled setting in coc-settings for the best
" results
let g:coc_custom_diagnostics_enabled = 0
function! CocToggleDiagnosticUi() abort
  let l:new_value = g:coc_custom_diagnostics_enabled == 0 ? v:true : v:false
  echo 'Coc Diagnostics: ' . (l:new_value == 0 ? 'disabled' : 'enabled')
  call coc#config('diagnostic.enable', l:new_value)
  call CocRefresh()
  let g:coc_custom_diagnostics_enabled = l:new_value
endfunction

nnoremap <silent> <leader>z :call CocRefresh()<cr>

nnoremap <silent> <leader>td :call CocToggleDiagnosticUi()<cr>
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
imap ;; <Plug>(coc-snippets-expand)

let g:coc_snippet_next = ';n'
let g:coc_snippet_prev = ';N'

" Explorer:
nnoremap <silent> <leader>e :CocCommand explorer<CR>
