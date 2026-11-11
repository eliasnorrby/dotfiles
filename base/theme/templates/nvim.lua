-- {{meta.title}}, rendered by `theme build`. Do not edit; edit the palette.
-- Loaded by editor/neovim/lua/core/theme.lua, which feeds it to the
-- catppuccin plugin: the plugin is the highlight engine, this is the colour.
return {
  name = '{{meta.name}}',
  flavour = '{{meta.flavour}}',
  color_overrides = {
    rosewater = '{{rosewater}}',
    flamingo = '{{flamingo}}',
    pink = '{{pink}}',
    mauve = '{{mauve}}',
    red = '{{red}}',
    maroon = '{{maroon}}',
    peach = '{{peach}}',
    yellow = '{{yellow}}',
    green = '{{green}}',
    teal = '{{teal}}',
    sky = '{{sky}}',
    sapphire = '{{sapphire}}',
    blue = '{{blue}}',
    lavender = '{{lavender}}',
    text = '{{text}}',
    subtext1 = '{{subtext1}}',
    subtext0 = '{{subtext0}}',
    overlay2 = '{{overlay2}}',
    overlay1 = '{{overlay1}}',
    overlay0 = '{{overlay0}}',
    surface2 = '{{surface2}}',
    surface1 = '{{surface1}}',
    surface0 = '{{surface0}}',
    base = '{{base}}',
    mantle = '{{mantle}}',
    crust = '{{crust}}',
  },
  -- The few groups the engine gets wrong for this palette: the current
  -- match and the cursor line carry the accent.
  custom_highlights = {
    TabLineSel = { fg = '{{accent}}', bg = '{{mantle}}' },
    TabLine = { bg = '{{mantle}}' },
    CurSearch = { bg = '{{accent}}', fg = '{{accent_fg}}' },
    IncSearch = { bg = '{{accent}}', fg = '{{accent_fg}}' },
    CursorLineNr = { fg = '{{accent}}' },
    MatchParen = { fg = '{{accent}}', bg = '{{surface1}}', bold = true },
  },
}
