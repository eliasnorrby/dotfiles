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
      -- ts_ls is started on demand, see with_ts_ls below
      automatic_enable = { exclude = { 'ts_ls' } },
    })

    local diagnostics_config = require('config.diagnostics')

    vim.lsp.enable('kulula_ls')

    vim.lsp.log.set_level('OFF')

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

    -- tsserver holds several GB per nvim instance in a large monorepo, and
    -- most sessions never ask it anything. Instead of enabling it up front,
    -- it starts on entering insert mode or on the first LSP action in a
    -- TypeScript buffer, and the action runs once it has attached.
    -- :TsLsToggle stops it and keeps insert mode from starting it again.
    local ts_filetypes = vim.lsp.config.ts_ls.filetypes
    local ts_pending = vim.api.nvim_create_augroup('UserTsLsPending', { clear = true })

    local function ts_ls_attached(bufnr)
      return #vim.lsp.get_clients({ bufnr = bufnr, name = 'ts_ls' }) > 0
    end

    local function start_ts_ls(bufnr, on_attach)
      if vim.b[bufnr].ts_ls_starting then
        vim.notify('ts_ls is still starting')
        return
      end
      vim.b[bufnr].ts_ls_starting = true
      local id = vim.api.nvim_create_autocmd('LspAttach', {
        group = ts_pending,
        buffer = bufnr,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'ts_ls' then
            return
          end
          vim.b[bufnr].ts_ls_starting = nil
          if on_attach then
            vim.schedule(function()
              if vim.api.nvim_get_current_buf() == bufnr then
                on_attach()
              end
            end)
          end
          return true
        end,
      })
      -- A buffer outside any TypeScript project never gets a client
      vim.defer_fn(function()
        if vim.b[bufnr].ts_ls_starting and not ts_ls_attached(bufnr) then
          vim.b[bufnr].ts_ls_starting = nil
          pcall(vim.api.nvim_del_autocmd, id)
          vim.notify('ts_ls did not attach', vim.log.levels.WARN)
        end
      end, 15000)
      vim.notify('Starting ts_ls')
      vim.lsp.enable('ts_ls')
    end

    local function with_ts_ls(fn)
      return function()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.tbl_contains(ts_filetypes, vim.bo[bufnr].filetype) or ts_ls_attached(bufnr) then
          return fn()
        end
        start_ts_ls(bufnr, fn)
      end
    end

    vim.api.nvim_create_user_command('TsLsToggle', function()
      if vim.lsp.is_enabled('ts_ls') then
        vim.g.ts_ls_off = true
        vim.api.nvim_clear_autocmds({ group = ts_pending })
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          vim.b[bufnr].ts_ls_starting = nil
        end
        vim.lsp.enable('ts_ls', false)
        vim.notify('Stopped ts_ls')
      else
        vim.g.ts_ls_off = nil
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.tbl_contains(ts_filetypes, vim.bo[bufnr].filetype) then
          start_ts_ls(bufnr)
        else
          vim.lsp.enable('ts_ls')
          vim.notify('Enabled ts_ls')
        end
      end
    end, { desc = 'Start or stop ts_ls' })

    local set_lsp_keymaps = function(_, bufnr)
      local wk = require('which-key')
      local telescope = require('telescope.builtin')

      wk.add({
        {
          buffer = bufnr,
          { '<leader>rn', with_ts_ls(vim.lsp.buf.rename), desc = 'Rename' },
          { '<leader>,', with_ts_ls(vim.lsp.buf.code_action), desc = 'Code action' },
          { '<leader>sd', with_ts_ls(telescope.lsp_document_symbols), desc = 'Document Symbols' },
          { '<leader>sw', with_ts_ls(telescope.lsp_dynamic_workspace_symbols), desc = 'Workspace Symbols' },
          { 'gd', with_ts_ls(telescope.lsp_definitions), desc = 'Goto Definition' },
          { 'gr', with_ts_ls(telescope.lsp_references), desc = 'Goto References' },
          { 'gI', with_ts_ls(vim.lsp.buf.implementation), desc = 'Goto Implementation' },
          { '<leader>lr', '<cmd>LspRestart<cr>', desc = 'Restart LSP' },
          { '<leader>li', '<cmd>LspInfo<cr>', desc = 'LSP info' },
          { '<leader>lt', '<cmd>TsLsToggle<cr>', desc = 'Toggle ts_ls' },
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

      vim.keymap.set('n', 'K', with_ts_ls(vim.lsp.buf.hover), { buffer = bufnr, desc = 'Hover Documentation' })
    end

    -- local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
    vim.lsp.config('*', {
      flags = {
        debounce_text_changes = 150,
      },
      -- capabilities = capabilities,
    })

    -- Plugin-free LSP restart. Collects servers from enabled configs matching
    -- the buffer's filetype, not just active clients, so it also revives
    -- servers whose client died (e.g. tsserver OOM crash).
    vim.api.nvim_create_user_command('LspRestart', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo[bufnr].filetype
      local names = {}
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        names[client.name] = true
      end
      for name in pairs(vim.lsp._enabled_configs) do
        local config = vim.lsp.config[name]
        local filetypes = config and config.filetypes
        if filetypes and vim.tbl_contains(filetypes, ft) then
          names[name] = true
        end
      end
      for name in pairs(names) do
        vim.lsp.enable(name, false)
      end
      vim.defer_fn(function()
        for name in pairs(names) do
          vim.lsp.enable(name)
        end
        vim.notify('Restarted LSP: ' .. table.concat(vim.tbl_keys(names), ', '))
      end, 500)
    end, { desc = 'Restart LSP servers for current buffer' })

    local lsp_group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true })
    -- A TypeScript buffer needs the keymaps before any client attaches, since
    -- they are what starts ts_ls
    vim.api.nvim_create_autocmd('FileType', {
      group = lsp_group,
      pattern = ts_filetypes,
      callback = function(args)
        set_lsp_keymaps(nil, args.buf)
      end,
    })
    vim.api.nvim_create_autocmd('InsertEnter', {
      group = lsp_group,
      callback = function(args)
        local bufnr = args.buf
        if
          vim.g.ts_ls_off
          or vim.b[bufnr].ts_ls_starting
          or not vim.tbl_contains(ts_filetypes, vim.bo[bufnr].filetype)
          or ts_ls_attached(bufnr)
        then
          return
        end
        start_ts_ls(bufnr)
      end,
    })
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
