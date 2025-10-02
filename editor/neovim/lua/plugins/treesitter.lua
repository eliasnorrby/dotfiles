---@type LazyPluginSpec
return {
  'nvim-treesitter/nvim-treesitter',
  main = 'nvim-treesitter.configs',
  branch = 'master',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = true,
  opts = {
    ensure_installed = {
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
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'markdown', 'prisma' },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = '.',
        node_decremental = ',',
        scope_incremental = 'grc',
      },
    },
    textobjects = {
      swap = {
        enable = true,
        swap_next = {
          ['<leader>rl'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>rh'] = '@parameter.inner',
        },
      },
    },
  },
}
