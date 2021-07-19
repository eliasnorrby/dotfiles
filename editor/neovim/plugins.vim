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
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'
runtime plugins.d/ap/vim-css-color.vim
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

" Statusline:
runtime plugins.d/itchyny/lightline.vim
Plug 'itchyny/vim-gitbranch'

" Navigation:
runtime plugins.d/tpope/vim-unimpaired.vim
runtime plugins.d/phaazon/hop.vim
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
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

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

" " Completion:
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

call plug#end()

lua require'hop'.setup()
lua require('gitsigns').setup()
lua require('treesitter-conf')
lua require('lsp-conf')
lua require('compe-conf')

nnoremap <leader>e <cmd>NvimTreeToggle<CR>
