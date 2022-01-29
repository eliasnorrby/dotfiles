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
require('telescope').load_extension('fzf')
