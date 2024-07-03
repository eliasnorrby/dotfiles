return {
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
}
