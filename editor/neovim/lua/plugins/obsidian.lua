return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended for stable releases
  lazy = true,
  event = {
    'BufReadPre ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
    'BufNewFile ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
  },
  ---@module 'obsidian'
  ----@type obsidian.config.ClientOpts
  opts = {
    legacy_commands = false, -- use modern command syntax
    note_id_func = function(title)
      local date = os.date('%Y-%m-%d')
      if title then
        return date .. ' ' .. title
      else
        return date
      end
    end,
    completion = {
      blink = true,
    },
    frontmatter = {
      enabled = false,
    },
    open = {
      func = function(uri)
        -- TODO: adjust for non-macOS systems
        vim.ui.open(uri, { cmd = { 'open', '-a', '/Applications/Obsidian.app' } })
      end,
    },
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
      { '<leader><leader>', '<cmd>Obsidian quick_switch<cr>', desc = 'Quick switch' },
      { '<leader>oo', '<cmd>Obsidian open<cr>', desc = 'Open in Obsidian app' },
      { '<leader>os', '<cmd>Obsidian search<cr>', desc = 'Search notes' },
      { '<leader>ob', '<cmd>Obsidian backlinks<cr>', desc = 'Backlinks' },
      { '<leader>oL', '<cmd>Obsidian links<cr>', desc = 'Links in buffer' },
      { '<leader>oC', '<cmd>Obsidian toc<cr>', desc = 'Table of contents' },

      -- Note operations
      { '<leader>on', '<cmd>Obsidian new<cr>', desc = 'New note' },
      { '<leader>or', '<cmd>Obsidian rename<cr>', desc = 'Rename note' },

      -- Linking (visual mode)
      { '<leader>ol', '<cmd>Obsidian link<cr>', desc = 'Link to note', mode = 'v' },
      { '<leader>oN', '<cmd>Obsidian link_new<cr>', desc = 'Link to new note', mode = 'v' },
      { '<leader>oe', '<cmd>Obsidian extract_note<cr>', desc = 'Extract to note', mode = 'v' },

      -- Daily notes
      { '<leader>ot', '<cmd>Obsidian today<cr>', desc = 'Today' },
      { '<leader>oy', '<cmd>Obsidian yesterday<cr>', desc = 'Yesterday' },
      { '<leader>om', '<cmd>Obsidian tomorrow<cr>', desc = 'Tomorrow' },
      { '<leader>od', '<cmd>Obsidian dailies<cr>', desc = 'Browse dailies' },

      -- Templates & workspace
      { '<leader>oT', '<cmd>Obsidian template<cr>', desc = 'Insert template' },
      { '<leader>oF', '<cmd>Obsidian new_from_template<cr>', desc = 'New from template' },
      { '<leader>ow', '<cmd>Obsidian workspace<cr>', desc = 'Switch workspace' },
      { '<leader>op', '<cmd>Obsidian paste_img<cr>', desc = 'Paste image' },

      -- Tags
      { '<leader>og', '<cmd>Obsidian tags<cr>', desc = 'Search tags' },
    })
  end,
}
