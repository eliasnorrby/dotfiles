local u = require('core.utils')

require('nvim-tree').setup({
  disable_netrw = false,
  renderer = {
    root_folder_label = false,
  },
})

u.map('n', '<leader>e', vim.cmd.NvimTreeToggle)
u.map('n', '<leader>fl', vim.cmd.NvimTreeFindFile)
