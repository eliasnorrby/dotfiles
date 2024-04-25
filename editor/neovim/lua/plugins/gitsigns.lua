return {
  'lewis6991/gitsigns.nvim',
  config = function()
    local wk = require('which-key')
    require('gitsigns').setup({
      on_attach = function(bufnr)
        -- local function map(mode, lhs, rhs, opts)
        --   opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
        --   vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        -- end

        wk.register({
          h = {
            name = '+gitsigns',
            s = { '<cmd>Gitsigns stage_hunk<CR>', 'Stage Hunk' },
            r = { '<cmd>Gitsigns reset_hunk<CR>', 'Reset Hunk' },
            S = { '<cmd>Gitsigns stage_buffer<CR>', 'Stage Buffer' },
            u = { '<cmd>Gitsigns undo_stage_hunk<CR>', 'Undo Stage Hunk' },
            R = { '<cmd>Gitsigns reset_buffer<CR>', 'Reset Buffer' },
            p = { '<cmd>Gitsigns preview_hunk<CR>', 'Preview Hunk' },
            b = {
              '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
              'Blame Line',
            },
            d = { '<cmd>Gitsigns diffthis<CR>', 'Diff This' },
            D = {
              '<cmd>lua require"gitsigns".diffthis("~")<CR>',
              'Diff This (Word)',
            },
          },
          t = {
            b = {
              '<cmd>Gitsigns toggle_current_line_blame<CR>',
              'Toggle Blame',
            },
            d = { '<cmd>Gitsigns toggle_deleted<CR>', 'Toggle Deleted' },
          },
        }, { prefix = '<leader>', buffer = bufnr })

        wk.register({
          ['[c'] = {
            "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'",
            'Previous Hunk',
          },
          [']c'] = {
            "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'",
            'Next Hunk',
          },
        }, { buffer = bufnr, expr = true })

        wk.register({
          h = {
            s = { '<cmd>Gitsigns stage_hunk<CR>', 'Stage Hunk' },
            r = { '<cmd>Gitsigns reset_hunk<CR>', 'Reset Hunk' },
          },
        }, { prefix = '<leader>', buffer = bufnr, mode = 'v' })

        wk.register({
          ['ih'] = { ':<C-U>Gitsigns select_hunk<CR>', 'inner hunk' },
        }, { mode = 'o', buffer = bufnr })
        wk.register({
          ['ih'] = { ':<C-U>Gitsigns select_hunk<CR>', 'inner hunk' },
        }, { mode = 'x', buffer = bufnr })
      end,
    })
  end,
}
