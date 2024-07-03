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

  {
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = { 'tpope/vim-fugitive' },
  },

  {
    'kylechui/nvim-surround',
    version = '*',
    config = true,
  },
  { 'numToStr/Comment.nvim', config = true },
  'godlygeek/tabular',
}
