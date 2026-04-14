---@type LazySpec
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install {
        'bash',
        'css',
        'dockerfile',
        'go',
        'graphql',
        'hcl',
        'vimdoc',
        'html',
        'http',
        'java',
        'javascript',
        'jsdoc',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'php',
        'prisma',
        'python',
        'regex',
        'rust',
        'sql',
        'terraform',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'yaml',
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    keys = {
      { '<leader>rl', desc = 'Swap next parameter' },
      { '<leader>rh', desc = 'Swap previous parameter' },
    },
    config = function()
      vim.keymap.set('n', '<leader>rl', function()
        require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
      end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', '<leader>rh', function()
        require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
      end, { desc = 'Swap previous parameter' })
    end,
  },
}
