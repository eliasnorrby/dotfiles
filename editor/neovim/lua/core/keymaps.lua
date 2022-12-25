local u = require('core.utils')

vim.g.mapleader = ' '

-- save & quit
u.map('n', '<leader>fs', vim.cmd.w)
u.map('n', '<leader>q', vim.cmd.q)
u.map('n', '<leader>Q', vim.cmd.qall)
u.map('n', '<leader>x', ':q!<CR>')
u.map('n', '<leader>X', ':qall!<CR>')

-- windows
u.map('n', '<leader>w', '<C-W>')

-- line numbers
u.map('n', '<leader>olr', function()
  vim.wo.number = true
  vim.wo.relativenumber = true
end)
u.map('n', '<leader>oln', function()
  vim.wo.number = true
  vim.wo.relativenumber = false
end)
u.map('n', '<leader>olo', function()
  vim.wo.number = false
  vim.wo.relativenumber = false
end)
