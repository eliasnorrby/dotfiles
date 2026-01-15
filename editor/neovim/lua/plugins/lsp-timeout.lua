---@type LazyPluginSpec
return {
  'hinell/lsp-timeout.nvim',
  dependencies = { 'neovim/nvim-lspconfig' },
  init = function()
    local default_timeout = 1000 * 60 * 5 -- 5 minutes

    vim.g.lspTimeoutConfig = {
      stopTimeout = default_timeout,
      -- Wait 1 second after focusing before starting LSP servers
      startTimeout = 1000,
      -- Suppress start/stop notifications
      silent = true,
    }

    -- Toggle lsp-timeout for this session
    local enabled = true
    vim.keymap.set('n', '<leader>tL', function()
      enabled = not enabled
      if enabled then
        vim.g.lspTimeoutConfig.stopTimeout = default_timeout
      else
        -- Set to 24 hours to effectively disable
        vim.g.lspTimeoutConfig.stopTimeout = 1000 * 60 * 60 * 24
      end
      print('LSP timeout ' .. (enabled and 'enabled' or 'disabled'))
    end, { desc = 'Toggle LSP timeout' })
  end,
}
