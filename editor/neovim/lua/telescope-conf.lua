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
lsp_map('n', '<leader>ca', "lsp_code_actions")
lsp_map('n', 'gd', "lsp_definitions")
lsp_map('n', 'gi', "lsp_implementations")
lsp_map('n', 'go', "lsp_document_symbols")

require('telescope-pickers')
