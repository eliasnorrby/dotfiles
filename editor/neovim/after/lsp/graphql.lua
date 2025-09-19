return {
  filetypes = {
    'graphql',
    'typescript',
    'typescriptreact',
    'javascriptreact',
  },
  root_dir = require('lspconfig').util.root_pattern('.graphqlrc.*', '.git'),
}
