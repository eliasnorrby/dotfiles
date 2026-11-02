local render_opts = {
  -- Render in every mode but show the cursor line raw outside normal and
  -- command mode, the way 'concealcursor' n works for plain conceal.
  -- Insert mode can be dropped from the list with <leader>tR.
  render_modes = { 'n', 'c', 't', 'i', 'v', 'V', '\22' },
  anti_conceal = { disabled_modes = { 'n', 'c' } },
  win_options = { concealcursor = { rendered = 'nc' } },
  code = {
    language = false,
    border = 'thin',
    sign = false,
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
}

---@type LazySpec
return {
  {
    'tadmccorkle/markdown.nvim',
    name = 'markdown-tools.nvim',
    ft = 'markdown',
    opts = {
      mappings = {
        link_follow = false,
      },
      on_attach = function(bufnr)
        local wk = require('which-key')

        wk.add({
          { '<leader>mt', '<cmd>MDTaskToggle<cr>', desc = 'toggle checkbox', buffer = bufnr },
          -- In a vault <CR> is obsidian.nvim's smart action, which also follows links
          {
            '<CR>',
            '<cmd>MDTaskToggle<cr>',
            desc = 'toggle checkbox',
            buffer = bufnr,
            cond = vim.fs.root(bufnr, '.obsidian') == nil,
          },
          { '<leader>l', group = '+linear' },
          { '<leader>lf', "<cmd>r !wk resolve --offline --format 'fixes: {issue}'<CR>", desc = 'fixes...' },
          { '<leader>ln', 'd/##<CR>ONone.<ESC>O<ESC>jo<ESC>k', desc = 'none' },
        })
      end,
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = render_opts,
    keys = {
      {
        '<leader>tR',
        function()
          local modes = render_opts.render_modes
          local renders = not vim.tbl_contains(modes, 'i')
          if renders then
            table.insert(modes, 'i')
          else
            render_opts.render_modes = vim.tbl_filter(function(mode)
              return mode ~= 'i'
            end, modes)
          end
          -- setup starts over and clears the marks, so draw the open buffers again
          require('render-markdown').setup(render_opts)
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].filetype == 'markdown' and vim.api.nvim_buf_is_loaded(buf) then
              vim.api.nvim_buf_call(buf, function()
                require('render-markdown').buf_enable()
              end)
            end
          end
          vim.notify('Insert mode ' .. (renders and 'renders' or 'shows plain markdown'))
        end,
        ft = 'markdown',
        desc = 'Toggle rendering in insert mode',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
  },
}
