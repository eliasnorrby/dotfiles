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
      ['yp'] = { 'actions.yank_entry', mode = 'n' },
      ['<leader>.'] = {
        function()
          require('telescope.builtin').find_files({
            cwd = require('oil').get_current_dir(),
          })
        end,
        mode = 'n',
        desc = 'Find files in current directory',
        nowait = true,
      },
    },
    use_default_keymaps = false,
    lsp_file_methods = {
      enabled = false,
      timeout_ms = 1000,
      autosave_changes = false,
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
  },
}
