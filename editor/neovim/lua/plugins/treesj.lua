---@type LazyPluginSpec
return {
  'Wansmer/treesj',
  keys = { {
    '<space>m',
    '<cmd>TSJToggle<cr>',
    desc = 'Toggle code split/join',
  } },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    use_default_keymaps = false,
  },
}
