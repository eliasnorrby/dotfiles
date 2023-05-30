local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Note: must be set before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

return require('lazy').setup({
  'wbthomason/packer.nvim',

  'gpanders/editorconfig.nvim',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'moll/vim-bbye',

  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
  },
  -- pin due to https://github.com/phaazon/hop.nvim/issues/345
  { 'phaazon/hop.nvim', commit = 'caaccee' },

  'nvim-lualine/lualine.nvim',
  'lewis6991/gitsigns.nvim',

  { 'kyazdani42/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'akinsho/bufferline.nvim', version = '*', dependencies = 'nvim-tree/nvim-web-devicons' },

  'marko-cerovac/material.nvim',
  { 'catppuccin/nvim', name = 'catppuccin' },

  { 'tpope/vim-fugitive', dependencies = { 'tpope/vim-rhubarb' } },
  {
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = { 'tpope/vim-fugitive' },
  },
  'rhysd/git-messenger.vim',

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  {
    'kylechui/nvim-surround',
    version = '*',
    config = function()
      require('nvim-surround').setup()
    end,
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({})
    end,
  },
  'godlygeek/tabular',

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  'github/copilot.vim',

  'mhartington/formatter.nvim',

  'epwalsh/obsidian.nvim',
})
