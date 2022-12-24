-----------------------------------------------------------
-- General
-----------------------------------------------------------

local g = vim.g       -- Global variables
local opt = vim.opt   -- Set options (global/buffer/windows-scoped)

opt.shortmess:append "sI"

opt.path:append("**")

opt.clipboard = 'unnamedplus'

opt.swapfile = false
opt.backup = false

opt.tabstop = 8
opt.softtabstop = 2
opt.expandtab = true
opt.shiftwidth = 2
opt.autoindent = true
opt.linebreak = true

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 5
opt.showcmd = false
opt.ruler = false
opt.signcolumn = 'yes'

-----------------------------------------------------------
-- UI
-----------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.hlsearch = false

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
opt.shortmess:append "sI"
