return {
  'zbirenbaum/copilot.lua',
  lazy = true,
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = false,
      },
    },
  },
  keys = {
    {
      '<leader>tc',
      function()
        require('copilot.suggestion').toggle_auto_trigger()
      end,
      desc = 'Toggle Copilot',
    },
  },
  init = function()
    vim.keymap.set('i', ';', function()
      if require('copilot.suggestion').is_visible() then
        require('copilot.suggestion').accept()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(';', true, false, true), 'n', false)
      end
    end)

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuOpen',
      callback = function()
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuClose',
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })
  end,
}
