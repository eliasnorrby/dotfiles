return {
  'nanozuki/tabby.nvim',
  event = 'VimEnter',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local wk = require('which-key')

    local theme = {
      fill = 'TabLineFill',
      head = 'TabLine',
      current_tab = 'TabLineSel',
      tab = 'TabLine',
      win = 'TabLine',
      tail = 'TabLine',
    }

    local tab_name_fallback = function()
      return ''
    end

    require('tabby').setup({
      line = function(line)
        return {
          {
            { '   ', hl = theme.tab },
            line.sep(' ', theme.tab, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            local sep = tab.is_current() and ' ┃ ' or ' ┋ '
            return {
              ' ',
              tab.number(),
              tab.name() ~= '' and sep or '',
              tab.name(),
              ' ',
              line.sep(' ', hl, theme.fill),
              hl = hl,
            }
          end),
        }
      end,
      option = {
        tab_name = {
          name_fallback = tab_name_fallback,
        },
      },
    })

    wk.add({
      '<leader>rt',
      function()
        local current_tab = require('tabby.module.api').get_current_tab()
        local current_name = require('tabby.feature.tab_name').get(current_tab, {
          name_fallback = tab_name_fallback,
        })
        local name = vim.fn.input('Rename tab to: ', current_name)
        require('tabby').tab_rename(name)
      end,
      desc = 'Rename tab',
    })
  end,
}
