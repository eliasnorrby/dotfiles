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

local git_spelling_group = vim.api.nvim_create_augroup('GitSpelling', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  callback = function()
    vim.o.spell = true
    vim.o.textwidth = 72
  end,
  group = git_spelling_group,
  pattern = 'gitcommit',
})
