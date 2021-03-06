" ============================================================================ "
" ===                           PLUGINS                                    === "
" ============================================================================ "

" Download vimplug if not already installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

" Plugins requiring configuration get their own file in plugins.d

" Editing:
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'godlygeek/tabular'
Plug 'pedrohdz/vim-yaml-folds'
" runtime plugins.d/mattn/emmet-vim.vim
runtime plugins.d/raimondi/delimitmate.vim
Plug 'AndrewRadev/splitjoin.vim'

Plug 'tommcdo/vim-exchange'
runtime plugins.d/machakann/vim-highlightedyank.vim
Plug 'junegunn/vim-easy-align'

" Config:
runtime plugins.d/editorconfig/editorconfig-vim.vim

" Snippets:
" runtime plugins.d/sirver/ultisnips.vim
Plug 'honza/vim-snippets'

" Ui:
runtime plugins.d/tpope/vim-vinegar.vim
" runtime plugins.d/mhinz/vim-signify.vim
runtime plugins.d/ap/vim-css-color.vim

" Statusline:
runtime plugins.d/itchyny/lightline.vim
Plug 'itchyny/vim-gitbranch'

" Navigation:
runtime plugins.d/tpope/vim-unimpaired.vim
if has('nvim-0.5')
  runtime plugins.d/phaazon/hop.vim
else
  runtime plugins.d/easymotion/vim-easymotion.vim
endif
runtime plugins.d/unblevable/quick-scope.vim

" Git:
runtime plugins.d/tpope/vim-fugitive.vim
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'
Plug 'rhysd/git-messenger.vim'
runtime plugins.d/stsewd/fzf-checkout.vim

" Text_objects:
Plug 'wellle/targets.vim'

" Filetypes_and_syntax:
runtime plugins.d/sheerun/vim-polyglot.vim
Plug 'neoclide/jsonc.vim'

" Fuzzy_finder:
runtime plugins.d/junegunn/fzf.vim

" " Tmux_integration:
if system('_os') == 'macos'
  Plug 'christoomey/vim-tmux-navigator'
endif
runtime plugins.d/benmills/vimux.vim

" Colorschemes:
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'joshdick/onedark.vim'

" " Miscellaneous:
Plug 'tpope/vim-dispatch'
runtime plugins.d/takac/vim-hardtime.vim
runtime plugins.d/moll/vim-bbye.vim

" " Formatting:
" Plug 'prettier/vim-prettier', {
"   \ 'do': 'npm install',
"   \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" " Linting:
" runtime plugins.d/dense-analysis/ale.vim

" " Completion:
" runtime plugins.d/ycm-core/YouCompleteMe.vim
runtime plugins.d/neoclide/coc.vim

" " Wiki:
runtime plugins.d/vimwiki/vimwiki.vim
runtime plugins.d/junegunn/goyo.vim

call plug#end()

if has('nvim-0.5')
  lua require'hop'.setup {}
endif

" " Settings: tmux-navigator {{{2
" let g:tmux_navigator_disable_when_zoomed = 1

" " Settings: vim-prettier {{{2
" let g:prettier#autoformat = 0
" nnoremap <leader>ff :PrettierAsync<CR>
" " Format certain files on save
" " augroup PrettierAutoformat
" "   autocmd!
" "   autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html PrettierAsync
" " augroup END
