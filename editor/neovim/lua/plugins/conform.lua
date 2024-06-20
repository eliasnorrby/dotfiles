return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  opts = {
    formatters_by_ft = {
      json = { 'prettier' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      yaml = { 'prettier' },
      toml = { 'prettier' },
      markdown = { 'prettier' },
      graphql = { 'prettier' },

      lua = { 'stylua' },
      python = { 'black' },
      sh = { 'shfmt' },
      sql = { 'pg_format' },
      terraform = { 'terraform_fmt' },
      xml = { 'xmllint' },
    },
    format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
