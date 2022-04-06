-- credits: https://github.com/nvim-telescope/telescope.nvim/issues/758

local M = {}

M.changed_branch_files = function()
  local previewers = require('telescope.previewers')
  local pickers = require('telescope.pickers')
  local sorters = require('telescope.sorters')
  local finders = require('telescope.finders')
  pickers.new {
    results_title = 'Modified on current branch',
    finder = finders.new_oneshot_job({'list_branch_files', 'list'}),
    sorter = sorters.get_fuzzy_file(),
    previewer = previewers.new_termopen_previewer {
      get_command = function(entry)
        return {'list_branch_files', 'diff', entry.value}
      end
    },
  }:find()
end

local opts = {noremap=true, silent=true }

vim.api.nvim_set_keymap(
  'n',
  '<leader>g<cr>',
  "<cmd>lua require'telescope-pickers'.changed_branch_files()<CR>",
  opts
)

return M
