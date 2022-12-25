-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local window_size_equal = vim.api.nvim_create_augroup('WindowSizeEqual', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    vim.cmd.wincmd('=')
  end,
  group = window_size_equal,
  pattern = '*',
})
