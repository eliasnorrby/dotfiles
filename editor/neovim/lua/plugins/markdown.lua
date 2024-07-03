return {
  'MeanderingProgrammer/markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = 'markdown',
  opts = {
    highlights = {
      heading = {
        backgrounds = {},
      },
      -- code = 'markdownH3',
    },
  },
}
