return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'macchiato', -- latte, frappe, macchiato, mocha
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
          TabLineSel = { fg = colors.yellow, bg = colors.mantle },
          TabLine = { bg = colors.mantle },
        }
      end,
    })
    vim.cmd([[colorscheme catppuccin]])
  end,
}
