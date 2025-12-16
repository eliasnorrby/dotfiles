vim.opt_local.list = true

vim.keymap.set('n', 'gf', function()
  if require('obsidian').util.cursor_on_markdown_link() then
    return '<cmd>ObsidianFollowLink<CR>'
  else
    return 'gf'
  end
end, { noremap = false, expr = true })

local toggle_read_mode = function()
  local is_in_read_mode = not vim.opt_local.modifiable:get()
  if is_in_read_mode then
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ''
    vim.opt_local.list = true
    vim.opt_local.modifiable = true
  else
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'nc'
    vim.opt_local.list = false
    vim.opt_local.modifiable = false
  end
end

vim.keymap.set('n', '<leader>tr', toggle_read_mode, { noremap = true, silent = true, desc = 'Toggle read mode' })

vim.keymap.set('x', '<leader>`', function()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  vim.api.nvim_buf_set_lines(0, start_line, start_line, false, { '```' })
  vim.api.nvim_buf_set_lines(0, end_line + 1, end_line + 1, false, { '```' })
end, { noremap = true, silent = true, desc = 'Wrap in code block' })
