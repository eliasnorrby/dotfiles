---@type LazyPluginSpec
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ['g?'] = { 'actions.show_help', mode = 'n' },
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
      ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
      ['<C-t>'] = { 'actions.select', opts = { tab = true } },
      ['<C-p>'] = 'actions.preview',
      ['-'] = { 'actions.parent', mode = 'n' },
      ['_'] = { 'actions.open_cwd', mode = 'n' },
      ['gs'] = { 'actions.change_sort', mode = 'n' },
      ['gx'] = 'actions.open_external',
      ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
      ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
    },
    use_default_keymaps = false,
    lsp_file_methods = {
      enabled = true,
      timeout_ms = 5000,
      autosave_changes = true,
    },
  },
  lazy = true,
  keys = {
    {
      '-',
      '<CMD>Oil<CR>',
      desc = 'Open Oil',
      silent = true,
    },
  },
  cmd = {
    'Oil',
  },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'benomahony/oil-git.nvim',
  },
}
