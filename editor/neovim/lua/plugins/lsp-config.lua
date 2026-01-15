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
      opts = {
        notification = {
          window = {
            winblend = 0,
          },
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
    local servers = {
      'bashls',
      -- rely on lsp bundled with copilot.lua
      -- 'copilot',
      'cssls',
      'diagnosticls',
      'dockerls',
      'emmet_language_server',
      'gopls',
      'graphql',
      'html',
      'hyprls',
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

    require('mason-lspconfig').setup({
      ensure_installed = servers,
      automatic_enable = true,
    })

    local diagnostics_config = require('config.diagnostics')

    vim.lsp.enable('kulula_ls')

    vim.lsp.set_log_level('OFF')

    -- need to enable here for sidekick's nes to work
    vim.lsp.enable('copilot')

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
          [vim.diagnostic.severity.ERROR] = diagnostics_config.icons.error,
          [vim.diagnostic.severity.WARN] = diagnostics_config.icons.warn,
          [vim.diagnostic.severity.HINT] = diagnostics_config.icons.hint,
          [vim.diagnostic.severity.INFO] = diagnostics_config.icons.info,
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

    -- local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
    vim.lsp.config('*', {
      flags = {
        debounce_text_changes = 150,
      },
      -- capabilities = capabilities,
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

        -- Register TypeScript-specific commands
        if client.name == 'ts_ls' then
          vim.api.nvim_buf_create_user_command(bufnr, 'OrganizeImports', function()
            local params = {
              command = '_typescript.organizeImports',
              arguments = { vim.api.nvim_buf_get_name(0) },
            }
            client.request('workspace/executeCommand', params, nil, bufnr)
          end, { desc = 'Organize Imports' })
        end
      end,
    })
  end,
}
