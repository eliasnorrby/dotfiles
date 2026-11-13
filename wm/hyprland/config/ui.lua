local theme = require('config.vars').theme

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border = {
        colors = { 'rgba(' .. theme.border_active .. 'ee)', 'rgba(' .. theme.border_active2 .. 'ee)' },
        angle = 45,
      },
      inactive_border = 'rgba(' .. theme.border_inactive .. 'aa)',
    },

    -- Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
    allow_tearing = false,

    layout = 'dwindle',
  },

  decoration = {
    rounding = theme.radius,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 0.95,

    dim_special = 0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 'rgba(0a0a0bee)',
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 3,

      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true, -- You probably want this
  },

  master = {
    new_status = 'master',
  },
})

-- Default curves and animations, see https://wiki.hypr.land/configuring/core/animations/
hl.curve('easeOutQuint', { type = 'bezier', points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve('easeInOutCubic', { type = 'bezier', points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve('linear', { type = 'bezier', points = { { 0, 0 }, { 1, 1 } } })
hl.curve('almostLinear', { type = 'bezier', points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve('quick', { type = 'bezier', points = { { 0.15, 0 }, { 0.1, 1 } } })

-- stylua: ignore start
hl.animation({ leaf = 'global',        enabled = true, speed = 10,   bezier = 'default' })
hl.animation({ leaf = 'border',        enabled = true, speed = 5.39, bezier = 'easeOutQuint' })
hl.animation({ leaf = 'windows',       enabled = true, speed = 4.79, bezier = 'easeOutQuint' })
hl.animation({ leaf = 'windowsIn',     enabled = true, speed = 4.1,  bezier = 'easeOutQuint', style = 'popin 87%' })
hl.animation({ leaf = 'windowsOut',    enabled = true, speed = 1.49, bezier = 'linear',       style = 'popin 87%' })
hl.animation({ leaf = 'fadeIn',        enabled = true, speed = 1.73, bezier = 'almostLinear' })
hl.animation({ leaf = 'fadeOut',       enabled = true, speed = 1.46, bezier = 'almostLinear' })
hl.animation({ leaf = 'fade',          enabled = true, speed = 3.03, bezier = 'quick' })
hl.animation({ leaf = 'layers',        enabled = true, speed = 3.81, bezier = 'easeOutQuint' })
hl.animation({ leaf = 'layersIn',      enabled = true, speed = 4,    bezier = 'easeOutQuint', style = 'fade' })
hl.animation({ leaf = 'layersOut',     enabled = true, speed = 1.5,  bezier = 'linear',       style = 'fade' })
hl.animation({ leaf = 'fadeLayersIn',  enabled = true, speed = 1.79, bezier = 'almostLinear' })
hl.animation({ leaf = 'fadeLayersOut', enabled = true, speed = 1.39, bezier = 'almostLinear' })
hl.animation({ leaf = 'workspaces',    enabled = true, speed = 1.94, bezier = 'almostLinear', style = 'fade' })
hl.animation({ leaf = 'workspacesIn',  enabled = true, speed = 1.21, bezier = 'almostLinear', style = 'fade' })
hl.animation({ leaf = 'workspacesOut', enabled = true, speed = 1.94, bezier = 'almostLinear', style = 'fade' })
hl.animation({ leaf = 'zoomFactor',    enabled = true, speed = 7,    bezier = 'quick' })
-- stylua: ignore end
