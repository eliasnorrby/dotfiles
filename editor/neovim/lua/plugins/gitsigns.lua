return {
  'lewis6991/gitsigns.nvim',
  opts = function()
    local wk = require('which-key')
    local gitsigns = require('gitsigns')
    return {
      on_attach = function(bufnr)
        wk.add({
          {
            buffer = bufnr,
            { '<leader>h', group = '+gitsigns' },
            { '<leader>hs', gitsigns.stage_hunk, desc = 'Stage hunk' },
            { '<leader>hr', gitsigns.reset_hunk, desc = 'Reset hunk' },
            { '<leader>hS', gitsigns.stage_buffer, desc = 'Stage buffer' },
            { '<leader>hu', gitsigns.undo_stage_buffer, desc = 'Undo stage hunk' },
            { '<leader>hR', gitsigns.reset_buffer, desc = 'Reset buffer' },
            { '<leader>hp', gitsigns.preview_hunk, desc = 'Preview hunk' },
            {
              '<leader>hb',
              function()
                gitsigns.blame_line({ full = true })
              end,
              desc = 'Blame line',
            },
            { '<leader>hd', gitsigns.diffthis, desc = 'Diff this' },
            {
              '<leader>hD',
              function()
                gitsigns.diffthis('~')
              end,
              desc = 'Diff this (word)',
            },
            -- { '<leader>t', group = '+gitsigns' },
            { '<leader>tb', gitsigns.toggle_current_line_blame, desc = 'Toggle blame' },
            { '<leader>td', gitsigns.toggle_deleted, desc = 'Toggle deleted' },
          },
          {
            buffer = bufnr,
            mode = 'v',
            { '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', desc = 'Stage hunk' },
            { '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', desc = 'Reset hunk' },
          },
          {
            buffer = bufnr,
            mode = { 'o', 'x' },
            { 'ih', ':<C-U>Gitsigns select_hunk<CR>', desc = 'inner hunk' },
          },
          {
            buffer = bufnr,
            {
              ']c',
              function()
                if vim.wo.diff then
                  vim.cmd.normal({ ']c', bang = true })
                else
                  gitsigns.nav_hunk('next')
                end
              end,
              desc = 'Next hunk',
            },
            {
              '[c',
              function()
                if vim.wo.diff then
                  vim.cmd.normal({ '[c', bang = true })
                else
                  gitsigns.nav_hunk('prev')
                end
              end,
              desc = 'Previous hunk',
            },
          },
        })
      end,
    }
  end,
}
