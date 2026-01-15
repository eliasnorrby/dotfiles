---@type LazyPluginSpec
return {
  'hinell/lsp-timeout.nvim',
  dependencies = { 'neovim/nvim-lspconfig' },
  init = function()
    vim.g.lspTimeoutConfig = {
      -- Wait 5 minutes of inactivity before stopping LSP servers
      stopTimeout = 1000 * 60 * 5,
      -- Wait 1 second after focusing before starting LSP servers
      startTimeout = 1000,
      -- Suppress start/stop notifications
      silent = true,
    }
  end,
}
