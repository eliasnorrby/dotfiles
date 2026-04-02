local function use_oxfmt(bufnr)
  return vim.fs.find('.oxfmtrc.json', {
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
    upward = true,
  })[1] ~= nil
end

local function prettier_or_oxfmt(bufnr)
  return use_oxfmt(bufnr) and { 'oxfmt' } or { 'prettier' }
end

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
    {
      '<leader>tf',
      '<cmd>ConformAutoFormatToggle<cr>',
      mode = 'n',
      desc = 'Toggle autoformat-on-save',
    },
  },
  opts = {
    formatters_by_ft = {
      json = prettier_or_oxfmt,
      jsonc = prettier_or_oxfmt,
      javascript = prettier_or_oxfmt,
      javascriptreact = prettier_or_oxfmt,
      typescript = prettier_or_oxfmt,
      typescriptreact = prettier_or_oxfmt,
      yaml = prettier_or_oxfmt,
      toml = { 'taplo' },
      markdown = prettier_or_oxfmt,
      graphql = prettier_or_oxfmt,
      rust = { 'rustfmt', lsp_format = 'fallback' },
      lua = { 'stylua' },
      python = { 'black' },
      sh = { 'shfmt' },
      sql = { 'pg_format' },
      terraform = { 'terraform_fmt' },
      xml = { 'xmllint' },
    },
    format_on_save = function()
      -- Disable with a global variable
      if vim.g.disable_autoformat then
        return
      end
      return { timeout_ms = 1000, lsp_format = 'fallback' }
    end,
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.api.nvim_create_user_command('ConformAutoFormatToggle', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      print('Autoformat-on-save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
    end, {
      desc = 'Toggle autoformat-on-save',
    })
  end,
}
