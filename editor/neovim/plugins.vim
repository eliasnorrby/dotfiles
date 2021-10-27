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
Plug 'dstein64/vim-startuptime'

" Editing:
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
runtime plugins.d/godlygeek/tabular.vim
Plug 'pedrohdz/vim-yaml-folds'
" runtime plugins.d/mattn/emmet-vim.vim
Plug 'windwp/nvim-autopairs'
runtime plugins.d/machakann/vim-highlightedyank.vim

" Config:
runtime plugins.d/editorconfig/editorconfig-vim.vim

" Ui:
runtime plugins.d/tpope/vim-vinegar.vim
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'felipec/vim-sanegx'
Plug 'npxbr/glow.nvim'
Plug 'gcmt/taboo.vim'
let g:taboo_tab_format = " %N %f%m "
let g:taboo_renamed_tab_format = " %N [%l]%m "

" Statusline:
Plug 'hoob3rt/lualine.nvim'

" Navigation:
runtime plugins.d/tpope/vim-unimpaired.vim
runtime plugins.d/phaazon/hop.vim
runtime plugins.d/unblevable/quick-scope.vim

" Git:
runtime plugins.d/tpope/vim-fugitive.vim
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim', { 'on': 'GV' }
Plug 'rhysd/git-messenger.vim'
Plug 'wincent/vcs-jump'

" Text_objects:
Plug 'wellle/targets.vim'

" Filetypes_and_syntax:
runtime plugins.d/sheerun/vim-polyglot.vim
Plug 'neoclide/jsonc.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Fuzzy_finder:
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
runtime plugins.d/junegunn/fzf.vim

" Colorschemes:
Plug 'drewtempelmeyer/palenight.vim'
Plug 'RRethy/nvim-base16'
Plug 'marko-cerovac/material.nvim'

" Miscellaneous:
runtime plugins.d/takac/vim-hardtime.vim
runtime plugins.d/moll/vim-bbye.vim

" LSP:
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim'
Plug 'folke/trouble.nvim'

" Formatting:
Plug 'mhartington/formatter.nvim'

call plug#end()

lua <<EOF
require('toggle_lsp_diagnostics').init({
    underline = true, virtual_text     = false,
    signs     = true, update_in_insert = true
})
require('hop').setup()
require('gitsigns').setup()
require('trouble').setup()
require('colorizer').setup()
require('treesitter-conf')
require('lsp-conf')
require('compe-conf')
require('formatter-conf')
require('telescope-conf')
require('lualine-conf')

require('nvim-autopairs').setup()
require('nvim-autopairs.completion.compe').setup({
  map_cr = true,
  map_complete = false
})
require('nvim-tree').setup({
  disable_netrw = false
})
EOF

" TODO: put this somewhere else
nmap <leader>tdv <Plug>(toggle-lsp-diag-vtext)
nmap <leader>tdi <Plug>(toggle-lsp-diag-update_in_insert)
nmap <leader>tdd <Plug>(toggle-lsp-diag)

nnoremap <leader>e <cmd>NvimTreeToggle<CR>
nnoremap <leader>fl <cmd>NvimTreeFindFile<CR>

nnoremap <silent> <leader>fF :Format<CR>

nnoremap <leader>tt <cmd>TroubleToggle<cr>

" nnoremap <leader><leader> <cmd>Telescope find_files<cr>
" nnoremap <leader>// <cmd>Telescope live_grep<cr>
" nnoremap <leader>/b <cmd>Telescope current_buffer_fuzzy_find<cr>
" nnoremap <leader>bb <cmd>Telescope buffers<cr>
" nnoremap <leader>;k <cmd>Telescope keymaps<cr>
" nnoremap <leader>;m <cmd>Telescope marks<cr>
" nnoremap <leader>;c <cmd>Telescope commands<cr>

nnoremap <leader>p <cmd>Glow<cr>
