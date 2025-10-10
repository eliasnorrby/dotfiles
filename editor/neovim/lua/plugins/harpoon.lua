---@type LazyPluginSpec
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local wk = require('which-key')
    local harpoon = require('harpoon')
    harpoon.setup()

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    wk.add({
      {
        { '<leader>j', group = '+harpoon' },
        {
          '<C-b>',
          function()
            toggle_telescope(harpoon:list())
          end,
          desc = 'Open harpoon window',
        },
        {
          '<leader>jo',
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = 'Toggle quick menu',
        },
        {
          '<leader>jt',
          function()
            harpoon:list():add()
          end,
          desc = 'Add file',
        },
      },
    })
  end,
}
