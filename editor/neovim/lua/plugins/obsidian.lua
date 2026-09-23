return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended for stable releases
  lazy = true,
  event = {
    'BufReadPre ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
    'BufNewFile ' .. vim.fn.expand('~') .. '/vaults/*/*.md',
  },
  cmd = {
    'Obsidian',
  },
  ---@module 'obsidian'
  ----@type obsidian.config.ClientOpts
  opts = {
    legacy_commands = false, -- use modern command syntax
    -- New notes are jots: standalone, timestamped entries dropped in the
    -- vault's inbox rather than wherever the current buffer happens to live.
    -- The time keeps two untitled jots on the same day from colliding.
    notes_subdir = 'inbox',
    new_notes_location = 'notes_subdir',
    note_id_func = function(title)
      local stamp = os.date('%Y-%m-%d %H%M')
      if title and title ~= '' then
        return stamp .. ' ' .. title
      else
        return stamp
      end
    end,
    frontmatter = {
      enabled = false,
    },
    open = {
      func = function(uri)
        if vim.fn.has('mac') == 1 then
          vim.ui.open(uri, { cmd = { 'open', '-a', '/Applications/Obsidian.app' } })
        else
          -- xdg-open hands obsidian:// to obsidian.desktop
          vim.ui.open(uri)
        end
      end,
    },
    workspaces = {
      {
        name = 'bemlo',
        path = '~/vaults/bemlo',
      },
      {
        name = 'personal',
        path = '~/vaults/personal',
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
      folder = '_meta/templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },
    attachments = {
      folder = '_meta/attachments',
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    -- Archiving is a queue, not a folder: the note moves to the vault's
    -- inbox/archive/, and the wiki session that drains the inbox files it for
    -- good and marks the pages that link to it as past. Links keep resolving
    -- meanwhile, since Obsidian links by basename.
    local function archive_note()
      local file = vim.api.nvim_buf_get_name(0)
      local root = file ~= '' and vim.fs.root(file, '.obsidian') or nil
      if not root then
        vim.notify('Not a vault note', vim.log.levels.WARN)
        return
      end
      local dir = root .. '/inbox/archive'
      local dest = dir .. '/' .. vim.fs.basename(file)
      if vim.uv.fs_stat(dest) then
        vim.notify('Already queued: ' .. dest, vim.log.levels.WARN)
        return
      end
      vim.cmd.write()
      vim.fn.mkdir(dir, 'p')
      if vim.fn.rename(file, dest) ~= 0 then
        vim.notify('Could not move ' .. file, vim.log.levels.ERROR)
        return
      end
      local old = vim.api.nvim_get_current_buf()
      vim.cmd.edit(vim.fn.fnameescape(dest))
      vim.api.nvim_buf_delete(old, { force = true })
      vim.notify('Queued for archive: ' .. vim.fs.basename(file))
    end

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
      { '<leader>oa', archive_note, desc = 'Queue for archive' },

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
