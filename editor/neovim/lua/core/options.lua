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

-- Disable builtin plugins
local disabled_built_ins = {
   "2html_plugin",
   "getscript",
   "getscriptPlugin",
   "gzip",
   "logipat",
   "netrw",
   "netrwPlugin",
   "netrwSettings",
   "netrwFileHandlers",
   "matchit",
   "tar",
   "tarPlugin",
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
   "tutor",
   "rplugin",
   "synmenu",
   "optwin",
   "compiler",
   "bugreport",
   "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
   g["loaded_" .. plugin] = 1
end
