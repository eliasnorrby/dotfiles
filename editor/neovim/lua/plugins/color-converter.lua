return {
  'NTBBloodbath/color-converter.nvim',
  event = 'VeryLazy',
  opts = {
    lowercase_hex = true,
    rgb_pattern = 'rgb([r], [g], [b])',
    rgba_pattern = 'rgb([r], [g], [b], [a])',
  },
  keys = {
    {
      ']w',
      function()
        require('color-converter').cycle()
      end,
      desc = 'Cycle color format',
    },
  },
}
