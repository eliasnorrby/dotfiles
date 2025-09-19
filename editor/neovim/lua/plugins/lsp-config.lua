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
    local nvim_lsp = require('lspconfig')

    vim.lsp.set_log_level('OFF')

    local set_lsp_keymaps = function(_, bufnr)
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
              ['http://json-schema.org/draft-07/schema#'] = 'schema.{yml,yaml}',
              ['./packages/cli/schema.yaml'] = '**/.bemlorc',
              ['/Users/elias/dev/which-cmd/schema.yml'] = '**/commands.yml',
            },
          },
        },
      },
      marksman = {},
      rust_analyzer = {},
    }

    for server_name, config in pairs(servers) do
      vim.lsp.config(server_name, config)
    end

    vim.lsp.enable(vim.tbl_keys(servers))

    -- Turn on lsp status information
    require('fidget').setup()
  end,
  init = function()
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

    local wk = require('which-key')
    wk.add({
      { '[d', vim.diagnostic.goto_prev, desc = 'Previous Diagnostic' },
      { ']d', vim.diagnostic.goto_next, desc = 'Next Diagnostic' },
      { '<leader>do', vim.diagnostic.open_float, desc = 'Open Diagnostic' },
    })
  end,
}
