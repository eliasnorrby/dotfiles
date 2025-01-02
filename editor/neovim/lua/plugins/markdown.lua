---@type LazySpec
return {
  {
    'tadmccorkle/markdown.nvim',
    name = 'markdown-tools.nvim',
    ft = 'markdown',
    opts = {
      on_attach = function(bufnr)
        local wk = require('which-key')

        wk.add({
          { '<leader>mt', '<cmd>MDTaskToggle<cr>', desc = 'toggle checkbox', buffer = bufnr },
          { '<CR>', '<cmd>MDTaskToggle<cr>', desc = 'toggle checkbox', buffer = bufnr },
        })
      end,
    },
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
  },
}
