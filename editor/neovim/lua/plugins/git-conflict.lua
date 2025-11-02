return {
  'akinsho/git-conflict.nvim',
  version = '*',
  config = function()
    require('git-conflict').setup({
      default_mappings = true,
      default_command = true,
      disable_diagnostics = false, -- show diagnostics for conflicts
      list_opener = 'copen', -- command to open conflict list
      highlights = {
        incoming = 'DiffAdd',
        current = 'DiffText',
      },
      debug = false,
    })

    local wk = require('which-key')
    wk.add({
      { '[x', desc = 'Previous conflict' },
      { ']x', desc = 'Next conflict' },
      { 'c', group = '+conflict'},
      { 'co', desc = 'Choose ours (current)'},
      { 'ct', desc = 'Choose theirs (incoming)'},
      { 'cb', desc = 'Choose both'},
      { 'c0', desc = 'Choose none'},
    })
  end,
}
