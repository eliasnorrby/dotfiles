-----------------------------------------------------------
-- General
-----------------------------------------------------------

vim.opt.shortmess:append("sI")

vim.opt.path:append("**")

vim.o.clipboard = 'unnamedplus'

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true

vim.o.tabstop = 8
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.linebreak = true

vim.o.splitbelow = true
vim.o.splitright = true
vim.o.scrolloff = 5
vim.o.showcmd = false
vim.o.ruler = false
vim.o.signcolumn = 'yes'

-----------------------------------------------------------
-- UI
-----------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.hlsearch = false
vim.o.showmode = false
