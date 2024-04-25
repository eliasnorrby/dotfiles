return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  keys = {
    {
      '<leader>tt',
      vim.cmd.TroubleToggle,
      desc = 'Toggle Trouble',
    },
  },
}
