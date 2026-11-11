-- The desktop theme, as rendered by `theme build` into
-- ~/.config/theme/current/nvim.lua: a flavour, the 26 colour overrides
-- and a few highlight groups. The catppuccin plugin is the highlight
-- engine; this module is the only place that knows about it. `apply()`
-- is also what `theme set` sends to running instances over their socket.

local M = {}

M.path = vim.fn.expand('~/.config/theme/current/nvim.lua')

local fallback = {
  name = 'catppuccin',
  flavour = 'macchiato',
  color_overrides = {},
  custom_highlights = {},
}

function M.load()
  local ok, theme = pcall(dofile, M.path)
  if ok and type(theme) == 'table' then
    return theme
  end
  return fallback
end

function M.apply()
  local theme = M.load()
  require('catppuccin').setup({
    flavour = theme.flavour,
    transparent_background = true,
    float = {
      transparent = true,
      solid = false,
    },
    dim_inactive = {
      enabled = false,
      shade = 'dark',
      percentage = 0.15,
    },
    styles = {
      comments = { 'italic' },
      conditionals = {},
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = { [theme.flavour] = theme.color_overrides },
    custom_highlights = theme.custom_highlights,
    integrations = {
      cmp = true,
      gitsigns = true,
      fidget = true,
      nvimtree = true,
      treesitter = true,
      render_markdown = true,
      mason = true,
      noice = true,
      notify = true,
      telescope = {
        enabled = true,
      },
      lsp_trouble = true,
      which_key = true,
    },
  })
  vim.cmd.colorscheme('catppuccin')
  vim.g.desktop_theme = theme.name
  vim.g.desktop_flavour = theme.flavour
  M.refresh_lualine()
end

-- lualine bakes its colours at setup, so re-run it with the plugin's opts
-- evaluated afresh (they read the engine's palette).
function M.refresh_lualine()
  for _, flavour in ipairs({ 'latte', 'frappe', 'macchiato', 'mocha' }) do
    package.loaded['lualine.themes.catppuccin-' .. flavour] = nil
  end
  local ok, lazy = pcall(require, 'lazy.core.config')
  local spec = ok and lazy.plugins['lualine.nvim'] or nil
  if not spec or not spec._.loaded then
    return
  end
  -- lazy caches evaluated opts on the plugin; drop that so the opts
  -- function runs again and reads the new palette.
  spec._.cache = {}
  local opts = require('lazy.core.plugin').values(spec, 'opts', false)
  require('lualine').setup(opts)
end

return M
