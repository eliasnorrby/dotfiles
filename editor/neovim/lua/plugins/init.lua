return {
  'gpanders/editorconfig.nvim',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'moll/vim-bbye',

  'nvim-lualine/lualine.nvim',
  'lewis6991/gitsigns.nvim',

  { 'kyazdani42/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },

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
  'godlygeek/tabular',

  'mhartington/formatter.nvim',

  'epwalsh/obsidian.nvim',
}
