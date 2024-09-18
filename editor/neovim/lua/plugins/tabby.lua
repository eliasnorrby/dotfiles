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
          name_fallback = function()
            return ''
          end,
        },
      },
    })

    wk.add({
      '<leader>tr',
      function()
        local name = vim.fn.input('Rename tab to: ')
        if name ~= '' then
          require('tabby').tab_rename(name)
        end
      end,
      desc = 'Rename tab',
    })
  end,
}
