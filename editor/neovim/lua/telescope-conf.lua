local actions = require('telescope.actions')
require('telescope').setup{
  extensions = {
    ['ui-select'] = {},
  },
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
require('telescope').load_extension('ui-select')

local opts = {noremap=true, silent=true }
local function lsp_map(mode, keybind, command)
  vim.api.nvim_set_keymap(
    mode,
    keybind,
    "<cmd>lua require'telescope.builtin'." .. command .. "()<CR>",
    opts
  )
end

lsp_map('n', 'gr', "lsp_references")
lsp_map('n', 'gd', "lsp_definitions")
lsp_map('n', 'gi', "lsp_implementations")
lsp_map('n', 'go', "lsp_document_symbols")

require('telescope-pickers')
