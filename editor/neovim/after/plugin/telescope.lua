local u = require('core.utils')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

require('telescope').setup{
  defaults = {
    prompt_prefix = "λ ",
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  }
}

local project_files = function()
  local opts = {}
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require"telescope.builtin".git_files({ use_git_root=false })
  else
    require"telescope.builtin".find_files(opts)
  end
end

u.map('n', '<leader><leader>', project_files)
u.map('n', '<leader>.', builtin.find_files)
u.map('n', '<leader><cr>', builtin.git_status)

u.map('n', '<leader>//', builtin.live_grep)

u.map('n', '<leader>/r', builtin.resume)
