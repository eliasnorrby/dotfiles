return {
  'phaazon/hop.nvim',
  -- pin due to https://github.com/phaazon/hop.nvim/issues/345
  commit = 'caaccee',
  config = true,
  event = 'VeryLazy',
  init = function()
    local wk = require('which-key')

    wk.register({
      ['gs'] = {
        name = '+hop',
        j = { '<cmd>HopLineAC<cr>', 'HopLineAC' },
        k = { '<cmd>HopLineBC<cr>', 'HopLineBC' },
        w = { '<cmd>HopWord<cr>', 'HopWord' },
        ['<space>'] = { '<cmd>HopWord<cr>', 'HopWord' },
      },
    })
  end,
}
