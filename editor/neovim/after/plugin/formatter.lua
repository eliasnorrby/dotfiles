local u = require('core.utils')
local util = require('formatter.util')

local prettier = {
  function()
    return {
      exe = 'prettier',
      args = { '--stdin-filepath', util.escape_path(util.get_current_buffer_file_path()) },
      stdin = true,
    }
  end,
}

local shfmt = {
  function()
    return {
      exe = 'shfmt',
      args = { '-filename', 'script.sh' },
      stdin = true,
    }
  end,
}

local tfmt = {
  function()
    return {
      exe = 'terraform',
      args = { 'fmt', '-' },
      stdin = true,
    }
  end,
}

require('formatter').setup({
  logging = false,
  filetype = {
    json = prettier,
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    yaml = prettier,
    toml = prettier,
    markdown = prettier,
    graphql = prettier,
    sh = shfmt,
    lua = require('formatter.filetypes.lua').stylua,
    terraform = tfmt,
  },
})

u.map('n', '<leader>ff', vim.cmd.Format)
