-----------------------------------------------------------
-- General
-----------------------------------------------------------

vim.opt.shortmess:append('sI')

vim.opt.path:append('**')

vim.opt.iskeyword:remove('_')

vim.o.clipboard = 'unnamedplus'

-- Route the clipboard through the dotfiles helpers instead of letting nvim
-- choose a provider from the environment. Left to itself it picks wl-copy
-- whenever WAYLAND_DISPLAY happens to be set, which says where this pane was
-- created, not which machine's screen is showing it. See shell/clipboard.
vim.g.clipboard = {
  name = 'dotfiles',
  copy = { ['+'] = 'copy_cmd', ['*'] = 'copy_cmd' },
  paste = { ['+'] = 'paste_cmd', ['*'] = 'paste_cmd' },
  cache_enabled = 0,
}

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

vim.o.ignorecase = true
vim.o.smartcase = true

-----------------------------------------------------------
-- UI
-----------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.hlsearch = false
vim.o.showmode = false
vim.o.fcs = 'eob: '
vim.o.winborder = 'rounded'
