local u = require('core.utils')

require('nvim-tree').setup({
  disable_netrw = false,
})

u.map('n', '<leader>e', vim.cmd.NvimTreeToggle)
u.map('n', '<leader>fl', vim.cmd.NvimTreeFindFile)
