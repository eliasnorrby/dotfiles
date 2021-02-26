if has("termguicolors")
  set termguicolors
endif

function! NoTildes() abort
  highlight! EndOfBuffer ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
endfunction

function! TransparentBg() abort
  highlight! Normal ctermbg=NONE guibg=NONE
  highlight! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
endfunction

function! JsxHtmlItalics() abort
  highlight!   jsxAttrib ctermfg=180 guifg=#ffcb6b cterm=italic gui=italic
  highlight!   htmlArg cterm=italic gui=italic
endfunction

function! JsObjectColors() abort
  highlight! def link jsObjectKey Identifier
  highlight! def link jsObjectValue jsObjectProp
endfunction

function! BlueCursorLine() abort
  highlight! CursorLine guibg=#303752
  highlight! CursorColumn guibg=#303752
endfunction

function! PalenightSetup() abort
  set background=dark
  if has('nvim')
    let g:palenight_terminal_italics = 1
  endif
  let g:lightline.colorscheme = 'palenight'
endfunction
augroup PalenightColors
  autocmd!
  autocmd ColorSchemePre palenight call PalenightSetup()
  autocmd ColorScheme palenight call TransparentBg()
  autocmd ColorScheme palenight call NoTildes()
  autocmd ColorScheme palenight call BlueCursorLine()
  if has('nvim')
    autocmd ColorScheme palenight call JsxHtmlItalics()
  endif
  autocmd ColorScheme palenight call JsObjectColors()
augroup END

function! GruvboxSetup() abort
  set background=dark
  let g:gruvbox_contrast_dark = "medium"
  let g:gruvbox_sign_column = "bg0"
  let g:gruvbox_italic = 1
  let g:lightline.colorscheme = 'gruvbox'
endfunction
augroup GruvboxColors
  autocmd!
  autocmd ColorSchemePre gruvbox call GruvboxSetup()
augroup END

function! OnedarkSetup() abort
  let g:lightline.colorscheme = 'onedark'
  let g:onedark_terminal_italics = 1
  let g:onedark_hide_endofbuffer = 1
endfunction
augroup OnedarkColors
  autocmd!
  autocmd ColorSchemePre onedark call OnedarkSetup()
  let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
  autocmd ColorScheme onedark call onedark#set_highlight("Normal", { "fg": s:white })
augroup END

if empty($VIM_COLOR)
  " let s:theme_to_use="gruvbox"
  " let s:theme_to_use="onedark"
  let s:theme_to_use="palenight"
else
  let s:theme_to_use=$VIM_COLOR
endif

execute 'colorscheme' s:theme_to_use

