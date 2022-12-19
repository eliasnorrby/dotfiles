local u = require('core/utils')

require('nvim-tree').setup({
  disable_netrw = false
})

u.map('n', '<leader>e', ':NvimTreeToggle<CR>')
