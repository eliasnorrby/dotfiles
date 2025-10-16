---@type LazyPluginSpec
return {
  'zbirenbaum/copilot.lua',
  lazy = true,
  cmd = 'Copilot',
  event = 'InsertEnter',
  dependencies = {
    'copilotlsp-nvim/copilot-lsp',
  },
  opts = {
    suggestion = {
      auto_trigger = true,
      trigger_on_accept = false,
      keymap = {
        accept = false,
        next = '<C-n>',
      },
    },
    filetypes = {
      yaml = true,
    },
    -- nes = {
    --   enabled = true,
    --   keymap = {
    --     accept = '<C-y>',
    --     next = false,
    --     prev = false,
    --     dismiss = '<C-f>',
    --   },
    -- },
  },
  keys = {
    {
      '<leader>apt',
      function()
        require('copilot.suggestion').toggle_auto_trigger()
      end,
      desc = 'Toggle Copilot',
    },
    {
      '<leader>ape',
      '<cmd>Copilot enable<cr>',
      desc = 'Enable Copilot suggestion',
    },
    {
      '<leader>apd',
      '<cmd>Copilot disable<cr>',
      desc = 'Disable Copilot suggestion',
    },
    {
      '<C-f>',
      function()
        require('copilot.suggestion').dismiss()
      end,
      mode = 'i',
    },
  },
  init = function()
    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ap', group = '+copilot' },
    })

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
        require('copilot.suggestion').dismiss()
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuClose',
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })

    -- disable by default in react
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'typescriptreact',
      callback = function()
        require('copilot.suggestion').toggle_auto_trigger()
      end,
    })
  end,
}
