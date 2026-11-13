-- Shared by the other modules: programs, modifiers and the current theme.

local vars = {
  terminal = 'kitty',
  menu = 'rofi -show drun',

  mainMod = 'SUPER', -- Sets "Windows" key as main modifier
  hyper = 'SUPER + SHIFT + CTRL + ALT',

  -- Rendered by `theme build` (base/theme); `theme set` swaps the link.
  theme = dofile(os.getenv('HOME') .. '/.config/theme/current/hyprland.lua'),
}

-- Both opacities (active, inactive) of a window rule, at one value
function vars.opacity(value)
  return value .. ' ' .. value
end

return vars
