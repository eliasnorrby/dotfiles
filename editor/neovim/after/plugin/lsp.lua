local nvim_lsp = require('lspconfig')

local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>sd', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

vim.diagnostic.config({
  float = { border = "rounded" }
})

local handlers = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      underline = true,
      virtual_text = false,
      signs = true,
      update_in_insert = true,
    }
  ),
  -- ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
}

local lsp_defaults = {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
  handlers = handlers
}

nvim_lsp.util.default_config = vim.tbl_deep_extend(
  'force',
  nvim_lsp.util.default_config,
  lsp_defaults
)

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
    cmd = { "diagnostic-languageserver", "--stdio" },
    filetypes = {
      "lua",
      "sh",
      "markdown",
      "json",
      "yaml",
      "toml"
    },
    init_options = {
      linters = {
        shellcheck = {
          command = "shellcheck",
          debounce = 100,
          args = { "--format", "json", "-" },
          sourceName = "shellcheck",
          parseJson = {
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${code}]",
            security = "level"
          },
          securities = {
            error = "error",
            warning = "warning",
            info = "info",
            style = "hint"
          }
        }
      },
      filetypes = {
        sh = "shellcheck"
      },
      formatters = {
        shfmt = {
          command = "shfmt",
          args = { "-filename", "script.sh" }
        },
        prettier = {
          command = "prettier",
          args = { "--stdin-filepath", "%filepath" },
        }
      },
      formatFiletypes = {
        sh = "shfmt",
        json = "prettier",
        yaml = "prettier",
        toml = "prettier",
        markdown = "prettier",
        lua = "prettier"
      }
    }
  },
  dockerls = {},
  gopls = {},
  graphql = {
    filetypes = {
      "graphql",
      "typescript",
      "typescriptreact",
      "javascriptreact"
    },
    root_dir = nvim_lsp.util.root_pattern('.graphqlrc.*', '.git'),
  },
  html = {},
  jsonls = {},
  prismals = {},
  pyright = {},
  sumneko_lua = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
  tailwindcss = {},
  terraformls = {},
  tsserver = {
    commands = {
      OrganizeImports = {
        function()
          vim.lsp.buf.execute_command({
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = ""
          })
        end,
        description = "Organize Imports"
      }
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["http://json-schema.org/draft-07/schema#"] = "/schema.yaml",
          ["./packages/cli/schema.yaml"] = "**/.bemlorc",
        }
      }
    }
  }
}

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup(servers[server_name])
  end,
}

-- Turn on lsp status information
require('fidget').setup()

local signs = { Error = "", Warn = "", Hint = "", Info = " " }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float)
