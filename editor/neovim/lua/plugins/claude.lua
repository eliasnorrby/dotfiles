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
      },
    },
  },
}
