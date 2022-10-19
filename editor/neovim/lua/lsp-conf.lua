local nvim_lsp = require('lspconfig')
local util = require 'lspconfig/util'

local opts = { noremap=true, silent=true }
-- vim.keymap.set('n', '<space>y', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev({ float = { border = "rounded" } }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next({ float = { border = "rounded" } }) end, opts)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<space>,', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'glr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>fF', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_defaults = {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
}

nvim_lsp.util.default_config = vim.tbl_deep_extend(
  'force',
  nvim_lsp.util.default_config,
  lsp_defaults
)

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
  -- We need to override some settings for bashls and tsserver
  -- "bashls",
  -- "tsserver",
  "cssls",
  "html",
  -- "yamlls",
  "dockerls",
  "pyright",
  "jsonls",
  "tailwindcss",
  "terraformls",
  -- "tflint",
  "prismals",
  -- "graphql",
}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {}
end

nvim_lsp.graphql.setup {
  filetypes = {
    "graphql",
    "typescript",
    "typescriptreact",
    "javascriptreact"
  },
  root_dir = util.root_pattern('.graphqlrc.*', '.git'),
}

nvim_lsp.yamlls.setup {
  settings = {
    yaml = {
      schemas = {
        ["http://json-schema.org/draft-07/schema#"] = "/schema.yaml",
        ["./packages/cli/schema.yaml"] = "**/.bemlorc",
      }
    }
  }
}

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(0)},
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end

nvim_lsp.tsserver.setup {
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports"
    }
  }
}

nvim_lsp.bashls.setup {
  cmd_env = {
    -- lsp-config defaults will disable recursive scanning
    GLOB_PATTERN = '**/*@(.sh|.inc|.bash|.command)',
  },
  root_dir = function(fname)
    -- lsp-config will use util.path.dirname, with will be the directory
    -- containing the file - we won't scan anything in parent directories.
    return util.root_pattern('.git')(fname) or util.path.dirname(fname)
  end,
}

nvim_lsp.diagnosticls.setup {
  cmd = {"diagnostic-languageserver", "--stdio"},
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
        args = {"--format", "json", "-"},
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
        args = {"-filename", "script.sh"}
      },
      prettier = {
        command = "prettier",
        args = {"--stdin-filepath", "%filepath"},
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
}

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = true
  }
)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

local signs = { Error = "", Warning = "", Hint = "", Information = " " }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
