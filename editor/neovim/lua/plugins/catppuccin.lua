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
          pink = '#bdc0c5',
          mauve = '#bdc0c5',
          red = '#d8573c',
          maroon = '#d8573c',
          peach = '#ffcfa3',
          yellow = '#ffcfa3',
          green = '#f5b35e',
          teal = '#bdc0c5',
          sky = '#bdc0c5',
          sapphire = '#f6f6f4',
          blue = '#f6f6f4',
          lavender = '#f6f6f4',
          text = '#e4e4e2',
          subtext1 = '#bdc0c5',
          subtext0 = '#a6a9ae',
          overlay2 = '#8c9097',
          overlay1 = '#6c7077',
          overlay0 = '#52565d',
          surface2 = '#393d44',
          surface1 = '#2b2e34',
          surface0 = '#222529',
          base = '#191c21',
          mantle = '#14161a',
          crust = '#0f1115',
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
          -- carborange: the current match and the cursor line carry the accent
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
