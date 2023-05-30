return {
  'github/copilot.vim',
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.api.nvim_set_keymap('i', ';', 'copilot#Accept(";")', { silent = true, expr = true })
  end,
}
