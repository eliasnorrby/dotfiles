return {
  'folke/flash.nvim',
  enabled = true,
  event = 'VeryLazy',
  opts = {},
  keys = {
    -- No 'o' mode: an operator-pending 's' hijacks cs/ds/ys from
    -- nvim-surround when the mapping times out (use 'r' instead).
    {
      's',
      mode = { 'n', 'x' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    -- Normal mode only: visual 'S' belongs to nvim-surround.
    {
      'S',
      mode = { 'n' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Flash Treesitter Search',
    },
  },
}
