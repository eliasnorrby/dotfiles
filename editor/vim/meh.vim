" Stuff I've worked on I'm not really happy with

" Linting:
" Plug 'dense-analysis/ale'

" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" " Attempts at toggling diagnostics...
" " let g:ycm_filter_diagnostics = '{}'
" let g:ycm_filter_diagnostics = {
"       \ "*": {
"       \    "regex": ["NOMATCH"],
"       \  }
"       \}

" Meh: Need to restart server
" function! ToggleDiagnostics()
"   if g:ycm_filter_diagnostics == {}
"     " Requires restarting the language server
"     " let g:ycm_enable_diagnostic_signs = 0
"     " let g:ycm_enable_diagnostic_highlighting = 0

"     let g:ycm_filter_diagnostics = {
"           \ "*": {
"           \    "regex": ["NOMATCH"],
"           \  }
"           \}
"     echo 'Diagnostics disabled'
"   else
"     " let g:ycm_enable_diagnostic_signs = 1
"     " let g:ycm_enable_diagnostic_highlighting = 1

"     let g:ycm_filter_diagnostics = {}
"     echo 'Diagnostics enabled'
"   endif
" endfunction

" Meh: Need to restart server
" function! ToggleAutoTrigger()
"     if g:ycm_auto_trigger
"         let g:ycm_auto_trigger = 0
"     else
"         let g:ycm_auto_trigger = 1
"     endif
" endfunction

" nnoremap <leader>td :call ToggleDiagnostics()<CR>
" nnoremap <leader>td :ALEToggle<CR>
" nnoremap <leader>ta :call ToggleAutoTrigger()<CR>

" " Settings: coc {{{
" " Some servers have issues with backup files, see #649.
" set nobackup
" set nowritebackup

" " Give more space for displaying messages.
" set cmdheight=2

" " Don't pass messages to |ins-completion-menu|.
" set shortmess+=c

" " Use tab for trigger completion with characters ahead and navigate.
" " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" " other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" " Use <c-space> to trigger completion.
" inoremap <silent><expr> <c-space> coc#refresh()

" " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" " position. Coc only does snippet and additional edit on confirm.
" " if exists('*complete_info')
" "   inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
" " else
" "   imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" " endif

" " Use `[g` and `]g` to navigate diagnostics
" nmap <silent> [g <Plug>(coc-diagnostic-prev)
" nmap <silent> ]g <Plug>(coc-diagnostic-next)

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" " nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" " Use K to show documentation in preview window.
" nnoremap <silent> K :call <SID>show_documentation()<CR>

" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   else
"     call CocAction('doHover')
"   endif
" endfunction

" " Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

" " Symbol renaming.
" nmap <leader>cr <Plug>(coc-rename)

" " " Formatting selected code.
" " xmap <leader>f  <Plug>(coc-format-selected)
" " nmap <leader>f  <Plug>(coc-format-selected)

" " augroup mygroup
" "   autocmd!
" "   " Setup formatexpr specified filetype(s).
" "   autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
" "   " Update signature help on jump placeholder.
" "   autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
" " augroup end

" " " Applying codeAction to the selected region.
" " " Example: `<leader>aap` for current paragraph
" " xmap <leader>a  <Plug>(coc-codeaction-selected)
" " nmap <leader>a  <Plug>(coc-codeaction-selected)

" " Remap keys for applying codeAction to the current line.
" nmap <leader>ac  <Plug>(coc-codeaction)
" " Apply AutoFix to problem on the current line.
" nmap <leader>cf  <Plug>(coc-fix-current)

" " " Introduce function text object
" " " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
" " xmap if <Plug>(coc-funcobj-i)
" " xmap af <Plug>(coc-funcobj-a)
" " omap if <Plug>(coc-funcobj-i)
" " omap af <Plug>(coc-funcobj-a)

" " Use <TAB> for selections ranges.
" " NOTE: Requires 'textDocument/selectionRange' support from the language server.
" " coc-tsserver, coc-python are the examples of servers that support it.
" nmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <TAB> <Plug>(coc-range-select)

" " Add `:Format` command to format current buffer.
" command! -nargs=0 Format :call CocAction('format')

" " Add `:Fold` command to fold current buffer.
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" " Add `:OR` command for organize imports of the current buffer.
" command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" " " Add (Neo)Vim's native statusline support.
" " " NOTE: Please see `:h coc-status` for integrations with external plugins that
" " " provide custom statusline: lightline.vim, vim-airline.
" " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" " Mappings using CoCList:
" " Show all diagnostics.
" nnoremap <silent> <leader>ca  :<C-u>CocList diagnostics<cr>
" " Manage extensions.
" nnoremap <silent> <leader>ce  :<C-u>CocList extensions<cr>
" " Show commands.
" nnoremap <silent> <leader>cc  :<C-u>CocList commands<cr>
" " Find symbol of current document.
" nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
" " Search workleader symbols.
" nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>
" " Do default action for next item.
" nnoremap <silent> <leader>cj  :<C-u>CocNext<CR>
" " Do default action for previous item.
" nnoremap <silent> <leader>ck  :<C-u>CocPrev<CR>
" " Resume latest coc list.
" nnoremap <silent> <leader>cp  :<C-u>CocListResume<CR>

" function! CocHighlightCorrections() abort
"   " Parentheses in floating windows have weird bgs
"   " CAUTION: This only works if the vim theme matches the terminal theme
"   " https://github.com/neoclide/coc.nvim/issues/1248
"   highlight! Normal guibg=NONE
" endfunction

" augroup CocColorCorrections
"   autocmd!
"   autocmd Colorscheme * call CocHighlightCorrections()
" augroup END

" }}}

function! AyuCorrections() abort
  " Ayu fixes
  highlight!   LineNr              ctermbg=NONE    guibg=NONE
  highlight!   SignColumn          ctermbg=NONE    guibg=NONE
  highlight!   SignifySignAdd                      guibg=NONE   guifg=#99C794
  highlight!   SignifySignDelete                   guibg=NONE   guifg=#EC5F67
  highlight!   SignifySignChange                   guibg=NONE   guifg=#C594C5
endfunction

function! AyuSetup() abort
  let g:ayucolor="mirage" " for mirage version of theme
  let g:lightline.colorscheme = 'ayu'
endfunction

augroup AyuColors
  autocmd!
  autocmd ColorSchemePre ayu call AyuSetup()
  autocmd ColorScheme ayu call AyuCorrections()
augroup END

" if s:theme_to_use == "ayu"
"   silent! colorscheme ayu
" endif
" if s:theme_to_use == "palenight"
"   silent! colorscheme palenight
" endif
" if s:theme_to_use == "gruvbox"
"   silent! colorscheme gruvbox
" endif

Plug 'ayu-theme/ayu-vim'
