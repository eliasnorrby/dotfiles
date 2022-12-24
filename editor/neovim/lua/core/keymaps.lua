local u = require('core.utils')

vim.g.mapleader = ' '

u.map('n', '<leader>q', ':q<CR>')
u.map('n', '<leader>s', vim.cmd.w)

u.map('n', '<leader>w', '<C-W>')
