local u = require('core.utils')

-- save & quit
u.map('n', '<leader>fs', vim.cmd.w)
u.map('n', '<leader>q', vim.cmd.q)
u.map('n', '<leader>Q', vim.cmd.qall)
u.map('n', '<leader>x', ':q!<CR>')
u.map('n', '<leader>X', ':qall!<CR>')
u.map('n', '<leader>R', ':%bd!<CR>')

-- windows
u.map('n', '<leader>w', '<C-W>')

-- tabs
local tabmap = function()
  for i = 1, 5, 1 do
    u.map('n', '<leader>' .. i, i .. 'gt')
  end
end
tabmap()

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

u.map('x', '<leader>s', ":'<,'>!sort<CR>")

-- for heredoc formatting
u.map('x', '<leader>ft', ':s/^  /	/<cr>')

-- temporary
u.map('n', '<leader>so', vim.cmd.source)
u.map('n', '<leader>lf', ':r !linear_issue_number fix<CR>')

u.map('n', '<leader>ln', 'd/##<CR>ONone.<ESC>O<ESC>jo<ESC>k')

u.map('n', '<leader>/w', ':silent Telescope grep_string<CR>')
