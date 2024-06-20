return {
  'mhartington/formatter.nvim',
  cmd = 'Format',
  opts = function()
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

    local black = {
      function()
        return {
          exe = 'black',
          args = { '-' },
          stdin = true,
        }
      end,
    }

    local prisma = {
      function()
        return {
          exe = 'prisma',
          args = {'format', '--schema', util.escape_path(util.get_current_buffer_file_path())},
          stdin = false,
          try_node_modules = true,
          transform = function(output)
            return output
          end,
        }
      end,
    }

    return {
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
        python = black,
        prisma = prisma,
      },
    }
  end,
  keys = {
    {
      '<leader>ff',
      vim.cmd.Format,
      desc = 'Format file',
    },
  },
}
