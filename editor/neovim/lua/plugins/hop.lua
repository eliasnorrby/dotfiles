return {
  'phaazon/hop.nvim',
  -- pin due to https://github.com/phaazon/hop.nvim/issues/345
  commit = 'caaccee',
  config = true,
  event = 'VeryLazy',
  init = function()
    local u = require('core.utils')

    u.map('n', 'gsj', vim.cmd.HopLineAC)
    u.map('n', 'gsk', vim.cmd.HopLineBC)
    u.map('n', 'gsw', vim.cmd.HopWord)
    u.map('n', 'gs<space>', vim.cmd.HopWord)
  end,
}
