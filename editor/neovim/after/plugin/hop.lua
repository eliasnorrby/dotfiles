local u = require('core.utils')
local hop = require('hop')

require('hop').setup()

u.map('n', 'gsj', vim.cmd.HopLineAC)
u.map('n', 'gsk', vim.cmd.HopLineBC)
u.map('n', 'gsw', vim.cmd.HopWord)
u.map('n', 'gs<space>', vim.cmd.HopWord)
