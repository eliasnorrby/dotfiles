local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn', 'info', 'hint' },
}

local custom_palenight = require('lualine.themes.palenight')
local default_fg = custom_palenight.normal.c.fg

custom_palenight.normal.c.bg = 'NONE'
custom_palenight.inactive.a.bg = 'NONE'
custom_palenight.inactive.a.fg = default_fg
custom_palenight.inactive.b.bg = 'NONE'
custom_palenight.inactive.b.fg = default_fg
custom_palenight.inactive.c.bg = 'NONE'
custom_palenight.inactive.c.fg = default_fg

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = custom_palenight,
    component_separators = { '┃', '┃' },
    section_separators = '',
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { 'filename' },
    -- lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = { '%a', diagnostics, 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_z = {
      {
        'tabs',
        fmt = function(name, context)
          -- workaround for lualine having hardcoded showtabline = 2
          if (vim.go.showtabline ~= 2 and vim.fn.tabpagenr('$') > 0)  then
            vim.go.showtabline = 2
          end
          if (vim.go.showtabline == 2 and vim.fn.tabpagenr('$') < 2) then
            vim.go.showtabline = 1
          end
          -- Show + if buffer is modified in tab
          local buflist = vim.fn.tabpagebuflist(context.tabnr)
          local winnr = vim.fn.tabpagewinnr(context.tabnr)
          local bufnr = buflist[winnr]
          local mod = vim.fn.getbufvar(bufnr, '&mod')

          return name .. (mod == 1 and ' +' or '')
        end
      }
    }
  },
  extensions = { 'fugitive', 'nvim-tree', 'quickfix' }
}
