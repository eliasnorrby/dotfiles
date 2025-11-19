return {
  'epwalsh/obsidian.nvim',
  lazy = true,
  event = {
    'BufReadPre ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
    'BufNewFile ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
  },
  ---@module 'obsidian'
  ----@type obsidian.config.ClientOpts
  opts = {
    disable_frontmatter = true,
    open_app_foreground = true,
    workspaces = {
      {
        name = 'personal',
        path = '~/vaults/personal',
      },
      {
        name = 'bemlo',
        path = '~/vaults/bemlo',
      },
    },
    daily_notes = {
      folder = 'dailies',
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      default_tags = { 'daily-notes' },
      template = nil,
    },
    ui = {
      enable = false,
    },
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      -- vim.fn.jobstart({"open", url})  -- Mac OS
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
      vim.ui.open(url) -- need Neovim 0.10.0+
    end,
    mappings = {
      ['<cr>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    templates = {
      folder = '_templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)
    local wk = require('which-key')
    wk.add({
      { '<leader>o', group = 'obsidian' },
      -- Quick access
      { '<leader><leader>', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick switch' },
      { '<leader>oo', '<cmd>ObsidianOpen<cr>', desc = 'Open in Obsidian app' },
      { '<leader>os', '<cmd>ObsidianSearch<cr>', desc = 'Search notes' },
      { '<leader>ob', '<cmd>ObsidianBacklinks<cr>', desc = 'Backlinks' },
      { '<leader>oL', '<cmd>ObsidianLinks<cr>', desc = 'Links in buffer' },
      { '<leader>oC', '<cmd>ObsidianTOC<cr>', desc = 'Table of contents' },

      -- Note operations
      { '<leader>on', '<cmd>ObsidianNew<cr>', desc = 'New note' },
      { '<leader>or', '<cmd>ObsidianRename<cr>', desc = 'Rename note' },

      -- Linking (visual mode)
      { '<leader>ol', '<cmd>ObsidianLink<cr>', desc = 'Link to note', mode = 'v' },
      { '<leader>oN', '<cmd>ObsidianLinkNew<cr>', desc = 'Link to new note', mode = 'v' },
      { '<leader>oe', '<cmd>ObsidianExtractNote<cr>', desc = 'Extract to note', mode = 'v' },

      -- Daily notes
      { '<leader>ot', '<cmd>ObsidianToday<cr>', desc = 'Today' },
      { '<leader>oy', '<cmd>ObsidianYesterday<cr>', desc = 'Yesterday' },
      { '<leader>om', '<cmd>ObsidianTomorrow<cr>', desc = 'Tomorrow' },
      { '<leader>od', '<cmd>ObsidianDailies<cr>', desc = 'Browse dailies' },

      -- Templates & workspace
      { '<leader>oT', '<cmd>ObsidianTemplate<cr>', desc = 'Insert template' },
      { '<leader>oF', '<cmd>ObsidianNewFromTemplate<cr>', desc = 'New from template' },
      { '<leader>ow', '<cmd>ObsidianWorkspace<cr>', desc = 'Switch workspace' },
      { '<leader>op', '<cmd>ObsidianPasteImg<cr>', desc = 'Paste image' },

      -- Tags
      { '<leader>og', '<cmd>ObsidianTags<cr>', desc = 'Search tags' },
    })
  end,
}
