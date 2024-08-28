return {
  'tpope/vim-fugitive',
  dependencies = { 'tpope/vim-rhubarb' },
  cmd = { 'GBrowse' },
  keys = {
    {
      '<leader>gg',
      vim.cmd.Git,
      desc = 'Git status',
    },
    {
      'o',
      ":'<,'>GBrowse<CR>",
      desc = 'Open on GitHub',
      mode = 'v',
      silent = true,
    },
    {
      'O',
      ":'<,'>GBrowse!<CR>",
      desc = 'Copy permalink',
      mode = 'v',
      silent = true,
    },
  },
}
