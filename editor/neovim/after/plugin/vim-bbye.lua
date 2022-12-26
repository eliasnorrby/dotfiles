local u = require('core.utils')

u.map('n', '<leader>bk', vim.cmd.Bdelete)
u.map('n', '<leader>bK', ':Bdelete!<CR>')
