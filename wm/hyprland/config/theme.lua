-- The cover theme_transition puts over the screen while a theme switch runs
-- underneath (base/theme/transition.sh): a float at the origin, mapped
-- without animation and invisible, no decoration. The script makes it
-- fullscreen through the dispatcher (the rule form does not take on this
-- version) and only then turns it opaque. Lives in the config rather than
-- being set at runtime, because the switch itself reloads hyprland and a
-- runtime rule would not survive.
hl.window_rule({
  name = 'ThemeCover',
  match = { class = 'ThemeCover' },

  float = true,
  size = { 'monitor_w', 'monitor_h' },
  move = { 0, 0 },
  no_anim = true,
  no_blur = true,
  no_shadow = true,
  no_dim = true,
  border_size = 0,
  -- Refuses focus at map, including from the pointer resting on it; the
  -- script lifts this when it is ready to focus and fullscreen the cover.
  no_focus = true,
  -- Mapped invisible: the client's first frame comes at its own size, and
  -- the script turns it opaque only once it is fullscreen.
  opacity = '0 0',
  -- Its close is the fade: a fullscreen window ignores opacity changes, so
  -- the cover goes with the windowsOut animation, in place, no popin.
  animation = 'fade',
})
