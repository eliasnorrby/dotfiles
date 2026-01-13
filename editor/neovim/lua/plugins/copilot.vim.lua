---@type LazyPluginSpec
return {
  'github/copilot.vim',
  enabled = true,
  lazy = true,
  cmd = 'Copilot',
  event = 'InsertEnter',
  init = function()
    -- Disable default tab mapping
    vim.g.copilot_no_tab_map = true

    -- Enable for yaml and markdown (disabled by default in copilot.vim)
    vim.g.copilot_filetypes = {
      yaml = true,
      markdown = true,
      typescriptreact = false,
    }

    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ap', group = '+copilot' },
    })
  end,
  config = function()
    local function is_visible()
      local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()
      return suggestion.text ~= nil and suggestion.text ~= ''
    end

    -- Accept with ;
    vim.keymap.set('i', ';', function()
      if is_visible() then
        local accept = vim.fn['copilot#Accept']('')
        if accept ~= '' then
          vim.api.nvim_feedkeys(accept, 'n', true)
        end
      else
        vim.api.nvim_feedkeys(';', 'n', false)
      end
    end, { silent = true })

    -- Accept word with TAB
    vim.keymap.set('i', '<TAB>', function()
      if is_visible() then
        local accept = vim.fn['copilot#AcceptWord']('')
        if accept ~= '' then
          vim.api.nvim_feedkeys(accept, 'n', true)
        end
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<TAB>', true, false, true), 'n', false)
      end
    end, { silent = true })

    -- Dismiss with <C-f>
    vim.keymap.set('i', '<C-f>', '<Plug>(copilot-dismiss)', { silent = true })

    -- Next suggestion with <C-n>
    vim.keymap.set('i', '<C-n>', '<Plug>(copilot-next)', { silent = true })

    -- Dismiss when blink.cmp menu opens
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuOpen',
      callback = function()
        vim.b.copilot_enabled = false
        vim.fn['copilot#Dismiss']()
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuClose',
      callback = function()
        vim.b.copilot_enabled = true
      end,
    })
  end,
  keys = {
    {
      '<leader>apt',
      function()
        if vim.g.copilot_enabled == false then
          vim.g.copilot_enabled = true
          vim.notify('Copilot enabled', vim.log.levels.INFO)
        else
          vim.g.copilot_enabled = false
          vim.notify('Copilot disabled', vim.log.levels.INFO)
        end
      end,
      desc = 'Toggle Copilot',
    },
    {
      '<leader>ape',
      '<cmd>Copilot enable<cr>',
      desc = 'Enable Copilot',
    },
    {
      '<leader>apd',
      '<cmd>Copilot disable<cr>',
      desc = 'Disable Copilot',
    },
  },
}
