return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    {
      'mason-org/mason.nvim',
      opts = {
        ui = {
          border = 'rounded',
        },
      },
    },
    'neovim/nvim-lspconfig',
    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      tag = 'legacy',
      opts = {
        window = {
          blend = 0,
        },
      },
    },
    -- Additional lua configuration, makes nvim stuff amazing
    {
      'folke/lazydev.nvim',
      ft = 'lua', -- only load on lua files
      opts = {
        library = {
          'nvim-cmp/lua/cmp/types',
          'lazy.nvim',
          { path = '~/.config/hammerspoon/Spoons/EmmyLua.spoon/annotations', words = { 'hs%.' } },
        },
      },
    },
  },
  config = function()
    vim.lsp.set_log_level('OFF')

    vim.diagnostic.config({
      float = { border = 'rounded' },
      signs = {
        numhl = {
          [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
          [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
          [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
          [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
        text = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.HINT] = '󰌶',
          [vim.diagnostic.severity.INFO] = ' ',
        },
      },
    })

    local set_lsp_keymaps = function(_, bufnr)
      local wk = require('which-key')

      wk.add({
        {
          buffer = bufnr,
          { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename' },
          { '<leader>,', vim.lsp.buf.code_action, desc = 'Code action' },
          { '<leader>sd', require('telescope.builtin').lsp_document_symbols, desc = 'Document Symbols' },
          { '<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, desc = 'Workspace Symbols' },
          { 'gd', require('telescope.builtin').lsp_definitions, desc = 'Goto Definition' },
          { 'gr', require('telescope.builtin').lsp_references, desc = 'Goto References' },
          { 'gI', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
          { '<leader>lr', '<cmd>LspRestart<cr>', desc = 'Restart LSP' },
          { '<leader>li', '<cmd>LspInfo<cr>', desc = 'LSP info' },
          {
            '[d',
            function()
              vim.diagnostic.jump({ count = -1, float = true })
            end,
            desc = 'Previous Diagnostic',
          },
          {
            ']d',
            function()
              vim.diagnostic.jump({ count = 1, float = true })
            end,
            desc = 'Next Diagnostic',
          },
          { '<leader>do', vim.diagnostic.open_float, desc = 'Open Diagnostic' },
        },
      })

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
    end

    local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
    vim.lsp.config('*', {
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = capabilities,
    })

    local lsp_group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true })
    vim.api.nvim_create_autocmd('LspAttach', {
      group = lsp_group,
      desc = 'Set buffer-local keymaps and options after an LSP client attaches',
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        set_lsp_keymaps(client, bufnr)
      end,
    })

    local servers = {
      'bashls',
      'cssls',
      'diagnosticls',
      'dockerls',
      'gopls',
      'graphql',
      'html',
      'jsonls',
      'lua_ls',
      'marksman',
      'phpactor',
      'prismals',
      'pyright',
      'rust_analyzer',
      'tailwindcss',
      'terraformls',
      'ts_ls',
      'yamlls',
    }

    vim.lsp.enable(servers)

    -- Turn on lsp status information
    require('fidget').setup()
  end,
}
