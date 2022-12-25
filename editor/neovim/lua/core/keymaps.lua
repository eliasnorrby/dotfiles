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

-- other
u.map('x', 'K', ":move '<-2<CR>gv=gv")
u.map('x', 'J', ":move '>+1<CR>gv=gv")

u.map('n', 'Q', '<nop>')
u.map('n', '-', '<nop>')

u.map('n', '<C-E>', '3<C-E>')
u.map('n', '<C-Y>', '3<C-Y>')

u.map('n', 'j', 'gj')
u.map('n', 'k', 'gk')

u.map('n', '<leader>co', vim.cmd.copen)
u.map('n', '<leader>cc', vim.cmd.cclose)

-- for heredoc formatting
u.map('x', '<leader>ft', ':s/^  /	/<cr>')

-- temporary
u.map('n', '<leader>so', vim.cmd.source)

