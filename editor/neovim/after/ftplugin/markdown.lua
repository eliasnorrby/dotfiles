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

vim.keymap.set('n', '<leader>tr', toggle_read_mode, { noremap = true, silent = true })
