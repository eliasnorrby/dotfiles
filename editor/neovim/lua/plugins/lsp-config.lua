return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
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
          'lazy.nvim',
          { path = '~/.config/hammerspoon/Spoons/EmmyLua.spoon/annotations', words = { 'hs%.' } },
        },
      },
    },
  },
  config = function()
    local nvim_lsp = require('lspconfig')

    vim.lsp.set_log_level('OFF')

    local on_attach = function(_, bufnr)
      local wk = require('which-key')

      wk.add({
        {
          buffer = bufnr,
          { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename' },
          { '<leader>,', vim.lsp.buf.code_action, desc = 'Code action' },
          { '<leader>sd', require('telescope.builtin').lsp_document_symbols, desc = 'Document Symbols' },
          { '<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, desc = 'Workspace Symbols' },
        },
      })

      wk.add({
        {
          buffer = bufnr,
          { 'gd', require('telescope.builtin').lsp_definitions, desc = 'Goto Definition' },
          { 'gr', require('telescope.builtin').lsp_references, desc = 'Goto References' },
          { 'gI', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
        },
      })

      wk.add({
        {
          buffer = bufnr,
          { '<leader>lr', '<cmd>LspRestart<cr>', desc = 'Restart LSP' },
        },
      })

      -- See `:help K` for why this keymap
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
    end

    local handlers = {
      ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = true,
      }),
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
      ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
    }

    local lsp_defaults = {
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
      handlers = handlers,
    }

    nvim_lsp.util.default_config = vim.tbl_deep_extend('force', nvim_lsp.util.default_config, lsp_defaults)

    local servers = {
      bashls = {
        cmd_env = {
          -- lsp-config defaults will disable recursive scanning
          GLOB_PATTERN = '**/*@(.sh|.inc|.bash|.command)',
        },
        root_dir = function(fname)
          -- lsp-config will use util.path.dirname, with will be the directory
          -- containing the file - we won't scan anything in parent directories.
          return nvim_lsp.util.root_pattern('.git')(fname) or nvim_lsp.util.path.dirname(fname)
        end,
      },
      cssls = {},
      diagnosticls = {
        cmd = { 'diagnostic-languageserver', '--stdio' },
        filetypes = {
          'lua',
          'sh',
          'markdown',
          'json',
          'json5',
          'yaml',
          'toml',
          'dockerfile',
        },
        init_options = {
          linters = {
            shellcheck = {
              command = 'shellcheck',
              debounce = 100,
              args = { '--format', 'json', '-' },
              sourceName = 'shellcheck',
              parseJson = {
                line = 'line',
                column = 'column',
                endLine = 'endLine',
                endColumn = 'endColumn',
                message = '${message} [${code}]',
                security = 'level',
              },
              securities = {
                error = 'error',
                warning = 'warning',
                info = 'info',
                style = 'hint',
              },
            },
            hadolint = {
              command = 'hadolint',
              debounce = 100,
              args = { '--format', 'json', '-' },
              sourceName = 'Dockerfile',
              parseJson = {
                sourceName = 'file',
                line = 'line',
                column = 'column',
                message = '${message} [${code}]',
                security = 'level',
              },
              securities = {
                error = 'error',
                warning = 'warning',
                info = 'info',
                style = 'hint',
              },
            },
          },
          filetypes = {
            sh = 'shellcheck',
            dockerfile = 'hadolint',
          },
          formatters = {
            shfmt = {
              command = 'shfmt',
              args = { '-filename', 'script.sh' },
            },
            prettier = {
              command = 'prettier',
              args = { '--stdin-filepath', '%filepath' },
            },
          },
          formatFiletypes = {
            sh = 'shfmt',
            json = 'prettier',
            yaml = 'prettier',
            toml = 'prettier',
            markdown = 'prettier',
            lua = 'prettier',
          },
        },
      },
      dockerls = {},
      gopls = {},
      phpactor = {},
      graphql = {
        filetypes = {
          'graphql',
          'typescript',
          'typescriptreact',
          'javascriptreact',
        },
        root_dir = nvim_lsp.util.root_pattern('.graphqlrc.*', '.git'),
      },
      html = {},
      jsonls = {},
      prismals = {},
      pyright = {},
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      tailwindcss = {},
      terraformls = {},
      ts_ls = {
        commands = {
          OrganizeImports = {
            function()
              vim.lsp.buf.execute_command({
                command = '_typescript.organizeImports',
                arguments = { vim.api.nvim_buf_get_name(0) },
                title = '',
              })
            end,
            description = 'Organize Imports',
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ['http://json-schema.org/draft-07/schema#'] = '/schema.yaml',
              ['./packages/cli/schema.yaml'] = '**/.bemlorc',
            },
          },
        },
      },
      marksman = {},
      rust_analyzer = {},
    }

    -- Setup mason so it can manage external tooling
    require('mason').setup({
      ui = {
        border = 'rounded',
      },
    })

    -- Ensure the servers above are installed
    local mason_lspconfig = require('mason-lspconfig')

    mason_lspconfig.setup({
      ensure_installed = vim.tbl_keys(servers),
    })

    mason_lspconfig.setup_handlers({
      function(server_name)
        require('lspconfig')[server_name].setup(servers[server_name])
      end,
    })

    -- Turn on lsp status information
    require('fidget').setup()
  end,
  init = function()
    vim.diagnostic.config({
      float = { border = 'rounded' },
    })

    local signs = { Error = '', Warn = '', Hint = '󰌶', Info = ' ' }

    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    local wk = require('which-key')
    wk.add({
      { '[d', vim.diagnostic.goto_prev, desc = 'Previous Diagnostic' },
      { ']d', vim.diagnostic.goto_next, desc = 'Next Diagnostic' },
      { '<leader>do', vim.diagnostic.open_float, desc = 'Open Diagnostic' },
    })
  end,
}
