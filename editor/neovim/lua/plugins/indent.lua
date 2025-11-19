return {
  'saghen/blink.indent',
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  opts = {
    static = {
      enabled = false,
      char = '┊',
    },
    scope = {
      char = '│',
      highlights = { 'BlinkIndent' },
    },
  },
  init = function()
    local indent = require('blink.indent')
    local wk = require('which-key')
    wk.add({
      {
        '<leader>ti',
        function()
          indent.enable(not indent.is_enabled())
        end,
        desc = 'Toggle indent guides',
      },
    })
  end,
}
