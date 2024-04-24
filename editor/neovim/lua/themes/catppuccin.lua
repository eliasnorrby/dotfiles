require('catppuccin').setup({
  flavour = 'macchiato', -- latte, frappe, macchiato, mocha
  transparent_background = true,
  show_end_of_buffer = false,
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
    nvimtree = true,
    treesitter = true,
    markdown = true,
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
      TabLineSel = { fg = colors.yellow },
    }
  end,
})

vim.cmd('colorscheme catppuccin')
