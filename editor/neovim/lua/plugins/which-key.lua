return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
  opts = {
    icons = {
      separator = '•',
    },
    win = {
      border = 'rounded',
    },
    triggers = {
      { '<auto>', mode = 'nixsotc' },
      { 'r', mode = 'n' },
      { 'c', mode = 'n' },
    },
  },
}
