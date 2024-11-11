---@type LazyPluginSpec
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  lazy = true,
  keys = {
    {
      '-',
      '<CMD>Oil<CR>',
      desc = 'Open Oil',
      silent = true,
    },
  },
  cmd = {
    'Oil',
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
