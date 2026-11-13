-- See https://wiki.hypr.land/configuring/core/rules/layer-rules/

hl.layer_rule({
  name = 'Rofi Blur',
  match = { namespace = 'rofi' },
  blur = true,
  ignore_alpha = 0,
})
