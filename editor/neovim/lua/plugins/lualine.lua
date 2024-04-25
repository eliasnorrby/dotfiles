return {
  'nvim-lualine/lualine.nvim',
  opts = function()
    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn', 'info', 'hint' },
      symbols = { error = ' ', warn = ' ', hint = '󰌶 ', info = ' ' },
    }

    local custom_theme = require('lualine.themes.catppuccin')
    local default_fg = custom_theme.normal.c.fg

    custom_theme.normal.c.bg = 'NONE'
    custom_theme.inactive.a.bg = 'NONE'
    custom_theme.inactive.a.fg = default_fg
    custom_theme.inactive.b.bg = 'NONE'
    custom_theme.inactive.b.fg = default_fg
    custom_theme.inactive.c.bg = 'NONE'
    custom_theme.inactive.c.fg = default_fg

    return {
      options = {
        icons_enabled = true,
        theme = custom_theme,
        component_separators = {}, --{ left = '', right = ''},
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'NvimTree' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_x = { '%a', diagnostics, 'filetype' },
        lualine_y = { 'selectioncount', 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
    }
  end,
}
