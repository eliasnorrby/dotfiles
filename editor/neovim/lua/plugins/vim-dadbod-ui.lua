return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1
    vim.g.db_ui_win_position = 'right'

    vim.cmd([[
      augroup SQLSetup
        autocmd!
        autocmd FileType sql,mysql,plsql lua vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', '<Plug>(DBUI_ExecuteQuery)', {})
        autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
      augroup END
    ]])
  end,
}
