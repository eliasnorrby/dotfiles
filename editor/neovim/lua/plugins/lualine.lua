return {
  'nvim-lualine/lualine.nvim',
  opts = function()
    local diagnostics_config = require('config.diagnostics')

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn', 'info', 'hint' },
      symbols = {
        error = ' ' .. diagnostics_config.icons.error .. ' ',
        warn = ' ' .. diagnostics_config.icons.warn .. ' ',
        info = ' ' .. diagnostics_config.icons.info .. ' ',
        hint = ' ' .. diagnostics_config.icons.hint .. ' ',
      },
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

    local conform_status = {
      function()
        return '󰉼'
      end,
      color = function()
        return vim.g.disable_autoformat and { fg = '#5B6078' } or { fg = '#A6DA95' }
      end,
    }

    local copilot_status = {
      'copilot',
      show_colors = true,
      symbols = {
        status = {
          hl = {
            -- enabled and sleep are swapped
            -- https://github.com/AndreM222/copilot-lualine/pull/15
            enabled = '#CAD3F5',
            sleep = '#A6DA95',
            disabled = '#5B6078',
            warning = '#EED49F',
            unknown = '#5B6078',
          },
        },
      },
    }

    local kulala_env = {
      function()
        local loaded = require('lazy.core.config').plugins['kulala.nvim']._.loaded
        if not loaded then
          return ''
        end
        local env = require('kulala').get_selected_env()
        if not env or env == '' then
          return ''
        end
        return '󰒋 ' .. env
      end,
      color = { fg = '#939ab7' },
    }

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
        lualine_x = { '%a', diagnostics, kulala_env, copilot_status, conform_status, 'filetype' },
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
