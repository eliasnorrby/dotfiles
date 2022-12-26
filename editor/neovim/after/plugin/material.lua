vim.g.material_style = 'palenight'

require('material').setup({
  contrast = {
    sidebars = true,
  },
  disable = {
    borders = false,
  },
  styles = {
    comments = { italic = true },
    functions = { bold = true },
  },
  plugins = {
    'gitsigns',
    'hop',
    'nvim-cmp',
    'nvim-tree',
    'telescope',
    'trouble',
    'which-key',
  },
})

vim.cmd('colorscheme material')
