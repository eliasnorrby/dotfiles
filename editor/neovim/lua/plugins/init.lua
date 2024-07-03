return {
  'gpanders/editorconfig.nvim',
  'tpope/vim-abolish',
  {
    'moll/vim-bbye',
    keys = {
      {
        '<leader>bk',
        vim.cmd.Bdelete,
        desc = 'Delete buffer',
      },
      {
        '<leader>bK',
        ':Bdelete!<CR>',
        desc = 'Delete buffer (!)',
      },
    },
  },

  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  {
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = { 'tpope/vim-fugitive' },
  },
  'rhysd/git-messenger.vim',

  {
    'kylechui/nvim-surround',
    version = '*',
    config = true,
  },
  { 'numToStr/Comment.nvim', config = true },
  'godlygeek/tabular',
}
