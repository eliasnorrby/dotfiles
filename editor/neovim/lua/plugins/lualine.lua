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

    local custom_theme = require('lualine.themes.catppuccin-' .. (vim.g.desktop_flavour or 'macchiato'))
    local palette = require('catppuccin.palettes').get_palette()
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
        return vim.g.disable_autoformat and { fg = palette.surface2 } or { fg = palette.green }
      end,
    }

    -- For zbirenbaum/copilot.lua with AndreM222/copilot-lualine
    local copilot_lua_status = {
      'copilot',
      show_colors = true,
      cond = function()
        return package.loaded['copilot'] ~= nil
      end,
      symbols = {
        status = {
          hl = {
            enabled = palette.green,
            sleep = palette.text,
            disabled = palette.surface2,
            warning = palette.yellow,
            unknown = palette.surface2,
          },
        },
      },
    }

    -- For github/copilot.vim
    local copilot_vim_status = {
      function()
        return ''
      end,
      cond = function()
        return vim.g.loaded_copilot ~= nil
      end,
      color = function()
        local colors = {
          enabled = palette.green,
          disabled = palette.surface2,
          warning = palette.yellow,
        }

        if vim.g.copilot_enabled == false or vim.b.copilot_enabled == false then
          return { fg = colors.disabled }
        end

        local ok, enabled = pcall(vim.fn['copilot#Enabled'])
        if ok and enabled == 1 then
          return { fg = colors.enabled }
        else
          return { fg = colors.warning }
        end
      end,
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
      color = { fg = palette.overlay2 },
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
        lualine_b = { { 'filename', path = 0 } },
        lualine_c = {},
        lualine_x = {
          '%a',
          diagnostics,
          kulala_env,
          copilot_lua_status,
          copilot_vim_status,
          conform_status,
          'filetype',
        },
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
        lualine_x = { diagnostics, 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
    }
  end,
}
