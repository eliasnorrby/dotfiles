require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'css',
    'dockerfile',
    'go',
    'graphql',
    'hcl',
    'help',
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
    'prisma',
    'python',
    'regex',
    'rust',
    'terraform',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { 'markdown' },
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
})
