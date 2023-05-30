local project_files = function()
  local opts = {}
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require('telescope.builtin').git_files({ use_git_root = false })
  else
    require('telescope.builtin').find_files(opts)
  end
end

-- credit: https://github.com/nvim-telescope/telescope.nvim/issues/758
local changed_branch_files = function()
  local previewers = require('telescope.previewers')
  local pickers = require('telescope.pickers')
  local sorters = require('telescope.sorters')
  local finders = require('telescope.finders')
  pickers
    .new({
      results_title = 'Modified on current branch',
      finder = finders.new_oneshot_job({ 'list_branch_files', 'list' }),
      sorter = sorters.get_fuzzy_file(),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { 'list_branch_files', 'diff', entry.value }
        end,
      }),
    })
    :find()
end

return {
  'nvim-telescope/telescope.nvim',
  version = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    local opts = {
      extensions = {
        ['ui-select'] = {},
      },
      defaults = {
        prompt_prefix = 'λ ',
        mappings = {
          i = {
            ['<esc>'] = require('telescope.actions').close,
            ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
          },
        },
      },
    }
    require('telescope').setup(opts)
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')
  end,
  init = function()
    local u = require('core.utils')
    local builtin = require('telescope.builtin')
    u.map('n', '<leader><leader>', project_files, { desc = 'Find project files' })
    u.map('n', '<leader>.', builtin.find_files, { desc = 'Find (non-git) project files' })
    u.map('n', '<leader><cr>', builtin.git_status, { desc = 'Find changed files' })

    u.map('n', '<leader>//', builtin.live_grep, { desc = 'Project grep' })
    u.map('n', '<leader>bb', builtin.buffers, { desc = 'Find buffers' })

    u.map('n', '<leader>/r', builtin.resume, { desc = 'Resume previous picker' })

    u.map('n', '<leader>g<cr>', changed_branch_files, { desc = 'Find changed files on current branch' })
  end,
}
