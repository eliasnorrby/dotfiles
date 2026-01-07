local project_files = function()
  local opts = {}
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require('telescope.builtin').git_files({ use_git_root = false })
  else
    require('telescope.builtin').find_files(opts)
  end
end

vim.api.nvim_create_user_command('ProjectFiles', function()
  vim.schedule(project_files)
end, {
  desc = 'Find project files (git or non-git)',
})

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

local changed_branch_files_from_ref = function()
  local previewers = require('telescope.previewers')
  local pickers = require('telescope.pickers')
  local sorters = require('telescope.sorters')
  local finders = require('telescope.finders')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- Helper function to show changed files for a given base ref
  local show_changed_files = function(base_ref)
    pickers
      .new({
        results_title = 'Modified relative to ' .. base_ref,
        finder = finders.new_oneshot_job({ 'list_branch_files', 'list', base_ref }, {}),
        sorter = sorters.get_fuzzy_file(),
        previewer = previewers.new_termopen_previewer({
          get_command = function(entry)
            return { 'list_branch_files', 'diff', entry.value, base_ref }
          end,
        }),
      }, {})
      :find()
  end

  -- Get ancestor branches
  local handle = io.popen('list_ancestor_branches')
  if not handle then
    vim.notify('Failed to run list_ancestor_branches', vim.log.levels.ERROR)
    return
  end
  local result = handle:read('*a')
  handle:close()

  local branches = {}
  for branch in result:gmatch('[^\r\n]+') do
    table.insert(branches, branch)
  end

  -- If only one candidate, use it directly
  if #branches == 1 then
    show_changed_files(branches[1])
    return
  end

  -- If no candidates, fall back to showing all local branches
  if #branches == 0 then
    vim.notify('No ancestor branches found, showing all local branches', vim.log.levels.INFO)
    branches = {}
    local handle_all = io.popen('git branch --sort=-committerdate')
    if not handle_all then
      vim.notify('Failed to list git branches', vim.log.levels.ERROR)
      return
    end
    local result_all = handle_all:read('*a')
    handle_all:close()
    for branch in result_all:gmatch('[^\r\n]+') do
      local trimmed = branch:gsub('^%s*%*?%s*', '')
      table.insert(branches, trimmed)
    end
  end

  -- Show picker for multiple branches
  pickers
    .new({
      prompt_title = 'Select base branch',
      finder = finders.new_table({
        results = branches,
      }),
      sorter = sorters.get_fuzzy_file(),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not selection then
            return
          end

          show_changed_files(selection.value)
        end)
        return true
      end,
    }, {})
    :find()
end

local grep_buffer_dir = function()
  local buffer_dir = vim.fn.expand('%:p:h')
  require('telescope.builtin').live_grep({
    cwd = buffer_dir,
    prompt_title = 'Grep in ' .. vim.fn.fnamemodify(buffer_dir, ':~:.'),
  })
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
      {
        '<leader>--',
        function()
          vim.notify('Switch keyboard layout to English', vim.log.levels.INFO)
        end,
      },
      {
        '<leader>/a',
        function()
          builtin.live_grep({
            default_text = 'async ',
          })
        end,
        desc = 'Find async method',
      },
      {
        '<leader>/q',
        function()
          builtin.live_grep({
            default_text = 'query ',
          })
        end,
        desc = 'Find GraphQL query',
      },
      {
        '<leader>/q',
        function()
          builtin.live_grep({
            default_text = 'mutation ',
          })
        end,
        desc = 'Find GraphQL mutation',
      },
      { '<leader>/.', grep_hidden_files, desc = 'Project grep (hidden files)' },
      { '<leader>/d', grep_buffer_dir, desc = 'Grep in buffer directory' },
      { '<leader>/w', builtin.grep_string, desc = 'Grep string' },
      { '<leader><cr>', builtin.git_status, desc = 'Find changed files' },
      { '<leader>bb', builtin.buffers, desc = 'Find buffers' },
      { '<leader>g<cr>', changed_branch_files, desc = 'Find changed files on current branch' },
      { '<leader>gb', changed_branch_files_from_ref, desc = 'Find changed files from base ref' },
    })
  end,
}
