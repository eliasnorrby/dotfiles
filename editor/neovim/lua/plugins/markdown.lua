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
    opts = {
      code = {
        language_border = ' ',
        language_left = '',
        language_right = '',
      },
      overrides = {
        buftype = {
          nofile = {
            render_modes = true,
            sign = { enabled = false },
            code = {
              language_info = false,
              language_name = false,
              language_icon = false,
              disable_background = true,
            },
          },
        },
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
  },
}
