---@type LazyPluginSpec
return {
  'greggh/claude-code.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    window = {
      position = 'float',
      float = {
        width = '95%',
        height = '95%',
        border = 'double',
      },
    },
    keymaps = {
      toggle = {
        normal = '<C-p>',
        terminal = '<C-p>',
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
      { '<leader>acr', '<cmd>ClaudeCodeResume<cr>', desc = 'Claude Code: Resume' },
    })
    vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' })
    vim.api.nvim_set_keymap('t', '<C-q>', '<esc>', { noremap = true, silent = true, desc = 'Esc' })
  end,
}
