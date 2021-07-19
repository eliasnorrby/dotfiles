local prettier = {
  function()
    return {
      exe = "prettier",
      args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
      stdin = true
    }
  end
}

local shfmt = {
  function()
    return {
      exe = "shfmt",
      args = {"-filename", "script.sh"},
      stdin = true
    }
  end
}

local luafmt = {
  function()
    return {
      exe = "lua-format",
      stdin = true
    }
  end
}

require('formatter').setup({
  logging = false,
  filetype = {
    json = prettier,
    javascript = prettier,
    yaml = prettier,
    toml = prettier,
    markdown = prettier,
    sh = shfmt,
    lua = luafmt,
  }
})
