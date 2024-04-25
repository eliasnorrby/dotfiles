return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    disable_netrw = false,
    renderer = {
      root_folder_label = false,
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
