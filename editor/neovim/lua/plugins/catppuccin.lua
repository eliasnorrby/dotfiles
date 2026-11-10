return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'macchiato', -- latte, frappe, macchiato, mocha
      -- carborange: carbon greys, one orange, a coal for errors. Keyed by
      -- the catppuccin names so every integration follows along.
      color_overrides = {
        macchiato = {
          rosewater = '#ffe9d6',
          flamingo = '#ffe9d6',
          pink = '#bfc1c5',
          mauve = '#bfc1c5',
          red = '#d8573c',
          maroon = '#d8573c',
          peach = '#ffcfa3',
          yellow = '#ffcfa3',
          green = '#ffa759',
          teal = '#bfc1c5',
          sky = '#bfc1c5',
          sapphire = '#f6f6f4',
          blue = '#f6f6f4',
          lavender = '#f6f6f4',
          text = '#e4e4e2',
          subtext1 = '#bfc1c5',
          subtext0 = '#a8abaf',
          overlay2 = '#8e9196',
          overlay1 = '#6e7177',
          overlay0 = '#54575d',
          surface2 = '#3b3e44',
          surface1 = '#2d3035',
          surface0 = '#24262b',
          base = '#1b1d21',
          mantle = '#16181b',
          crust = '#111215',
        },
      },
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      dim_inactive = {
        enabled = false,
        shade = 'dark',
        percentage = 0.15,
      },
      styles = {
        comments = { 'italic' },
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        fidget = true,
        nvimtree = true,
        treesitter = true,
        render_markdown = true,
        mason = true,
        noice = true,
        notify = true,
        telescope = {
          enabled = true,
        },
        lsp_trouble = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          TabLineSel = { fg = colors.green, bg = colors.mantle },
          TabLine = { bg = colors.mantle },
          -- carborange: selections and matches sink the orange into the
          -- ground instead of borrowing a cool hue
          Visual = { bg = '#3f3126' },
          Search = { bg = '#3f3126', fg = colors.text },
          CurSearch = { bg = colors.green, fg = colors.base },
          IncSearch = { bg = colors.green, fg = colors.base },
          CursorLineNr = { fg = colors.green },
          MatchParen = { fg = colors.green, bg = colors.surface1, bold = true },
        }
      end,
    })
    vim.cmd([[colorscheme catppuccin]])
  end,
}
