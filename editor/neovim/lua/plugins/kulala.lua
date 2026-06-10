---@type LazyPluginSpec
return {
  'mistweaverco/kulala.nvim',
  tag = 'v5.3.4',
  ft = { 'http', 'rest' },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = '<leader>h',
    kulala_keymaps_prefix = '',
  },
  keys = {
    {
      ']r',
      function()
        require('kulala').jump_next()
      end,
      desc = 'Next request',
    },
    {
      '[r',
      function()
        require('kulala').jump_prev()
      end,
      desc = 'Previous request',
    },
  },
}
