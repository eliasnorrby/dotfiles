local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn', 'info', 'hint' },
  symbols = { error = ' ', warn = ' ', hint = '󰌶 ', info = ' ' },
}

local custom_palenight = require('lualine.themes.catppuccin')
local default_fg = custom_palenight.normal.c.fg

custom_palenight.normal.c.bg = 'NONE'
custom_palenight.inactive.a.bg = 'NONE'
custom_palenight.inactive.a.fg = default_fg
custom_palenight.inactive.b.bg = 'NONE'
custom_palenight.inactive.b.fg = default_fg
custom_palenight.inactive.c.bg = 'NONE'
custom_palenight.inactive.c.fg = default_fg

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = custom_palenight,
    component_separators = { '┃', '┃' },
    section_separators = '',
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {},
    lualine_c = { 'filename' },
    -- lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = { '%a', diagnostics, 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
})
