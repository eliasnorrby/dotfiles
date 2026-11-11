-- The highlight engine. Which colours it draws with is the desktop theme's
-- business: see core/theme.lua, which reads ~/.config/theme/current/nvim.lua.
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('core.theme').apply()
  end,
}
