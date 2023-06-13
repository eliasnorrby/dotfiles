return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  init = function()
    local wk = require('which-key')

    wk.register({
      ['<leader>tt'] = { ':TroubleToggle<CR>', 'Toggle Trouble' },
    })
  end
}
