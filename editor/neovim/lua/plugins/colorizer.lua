return {
  'norcalli/nvim-colorizer.lua',
  event = 'VeryLazy',
  opts = {
    css = { rgb_fn = true }, -- Enable parsing rgb(...) functions in css.
    html = { names = false }, -- Disable parsing "names" in html.
  },
}
