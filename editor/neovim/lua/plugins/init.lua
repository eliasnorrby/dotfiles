return {
  'gpanders/editorconfig.nvim',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'moll/vim-bbye',

  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  'marko-cerovac/material.nvim',
  { 'catppuccin/nvim', name = 'catppuccin' },

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
  { 'numToStr/Comment.nvim', config = true },
  'godlygeek/tabular',

  'epwalsh/obsidian.nvim',
}
