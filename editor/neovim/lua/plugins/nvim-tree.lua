---@type LazyPluginSpec
return {
  'nvim-tree/nvim-tree.lua',
  enabled = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    disable_netrw = false,
    renderer = {
      root_folder_label = false,
    },
    view = {
      side = 'right',
      width = 50,
    },
  },
  keys = {
    {
      '<leader>e',
      vim.cmd.NvimTreeToggle,
      desc = 'Toggle NvimTree',
    },
    {
      '<leader>fl',
      vim.cmd.NvimTreeFindFile,
      desc = 'Find file in NvimTree',
    },
  },
}
