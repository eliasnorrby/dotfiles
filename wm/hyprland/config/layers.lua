-- See https://wiki.hypr.land/configuring/core/rules/layer-rules/

hl.layer_rule({
  name = 'Rofi Blur',
  match = { namespace = 'rofi' },
  blur = true,
  ignore_alpha = 0,
})

-- wl-kbptr's overlay (kbptr, keyboard/wl_kbptr) goes without the layers'
-- fade-out, so it is gone the moment a target is picked. Not the fade-in:
-- Hyprland 0.57 ignores no_anim when a layer opens (see ui.lua's layersIn).
-- "selection" is a generic namespace: slurp uses it too, which is fine.
hl.layer_rule({
  name = 'Pointer overlay',
  match = { namespace = 'selection' },
  no_anim = true,
})
