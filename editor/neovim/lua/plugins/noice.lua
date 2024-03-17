return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    {
      'rcarriga/nvim-notify',
      config = function()
        require('notify').setup({
          background_colour = '#000000',
          top_down = false,
        })
      end,
    },
  },
  opts = {
    lsp = {
      enabled = false,
      progress = {
        enabled = false,
      },
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
    },
    routes = {
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'written',
        },
        opts = { skip = true },
      },
      -- https://github.com/LazyVim/LazyVim/discussions/830
      {
        filter = {
          event = 'notify',
          find = 'No information available',
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = 'msg_show',
          find = 'DB: Query',
        },
        opts = { skip = true },
      },
    },
  },
}
