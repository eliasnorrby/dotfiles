require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
    disable = { 'yaml' },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = ".",
      node_decremental = ",",
      scope_incremental = "grc",
    },
  },
}
