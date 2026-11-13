-- See https://wiki.hypr.land/configuring/core/rules/window-rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = '.*' }, suppress_event = 'maximize' })

-- Fix some dragging issues with XWayland
hl.window_rule({
  match = {
    class = '^$',
    title = '^$',
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.window_rule({ match = { class = 'lxqt-openssh-askpass' }, float = true })

-- Linear PWA: class is a stable hash of Linear's start URL (same on every
-- install). Workspace + HYPER+W rules in apps.lua target this same class.
for _, class in ipairs({
  'ChromePersonal',
  'ChromeWork',
  'slack',
  'notion',
  'md.obsidian.Obsidian',
  'chrome-bgdbmehlmdmddlgneophbcddadgknlpm-Default',
  '1password',
}) do
  hl.window_rule({ match = { class = class }, focus_on_activate = true })
end

hl.window_rule({
  name = 'Google Meet Picture-in-Picture',
  match = { class = 'ChromeWork', title = 'Google Meet' },

  float = true,
  pin = true,
  size = { 400, 400 },
  move = { 'monitor_w-430', 'monitor_h-430' },
})

hl.window_rule({
  name = 'Flameshot Screenshot Tool',
  match = { class = 'flameshot' },

  rounding = 0,
  float = true,
  pin = true,
  animation = 'fade',
  move = { 0, 0 },
})

-- Chrome's floating "x is sharing your screen" pill (has no class)
hl.window_rule({
  name = 'Chrome screen-share pill',
  match = { title = '.+ is sharing (your screen|a window)\\.' },

  move = { 10, 'monitor_h-84' },
})

-- Capture picker (screenshots and recordings)
hl.window_rule({
  name = 'CapturePicker',
  match = { class = 'CapturePicker' },

  opacity = 0.95,
})
