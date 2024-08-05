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
      finder = finders.new_oneshot_job({ 'list_branch_files', 'list' }, {}),
      sorter = sorters.get_fuzzy_file(),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { 'list_branch_files', 'diff', entry.value }
        end,
      }),
    }, {})
    :find()
end

local grep_hidden_files = function()
  require('telescope.builtin').live_grep({
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob',
      '!.git',
    },
  })
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
    local wk = require('which-key')
    local builtin = require('telescope.builtin')
    wk.add({
      { '<leader><leader>', project_files, desc = 'Find project files' },
      { '<leader>.', builtin.find_files, desc = 'Find (non-git) project files' },
      { '<leader>/r', builtin.resume, desc = 'Resume previous picker' },
      { '<leader>//', builtin.live_grep, desc = 'Project grep' },
      { '<leader>/.', grep_hidden_files, desc = 'Project grep (hidden files)' },
      { '<leader>/w', builtin.grep_string, desc = 'Grep string' },
      { '<leader><cr>', builtin.git_status, desc = 'Find changed files' },
      { '<leader>bb', builtin.buffers, desc = 'Find buffers' },
      { '<leader>g<cr>', changed_branch_files, desc = 'Find changed files on current branch' },
    })
  end,
}
