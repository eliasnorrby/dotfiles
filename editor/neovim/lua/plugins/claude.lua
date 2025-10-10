---@type LazyPluginSpec
return {
  'greggh/claude-code.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    keymaps = {
      toggle = {
        normal = '<leader>;',
        terminal = '<C-r>',
        variants = {
          continue = '<leader>acC',
          verbose = '<leader>acV',
        },
      },
      scrolling = true,
    },
  },
  init = function()
    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ac', desc = '+claude' },
      { '<leader>acc', '<cmd>ClaudeCode<cr>', desc = 'Claude Code: Open' },
    })
  end,
}
