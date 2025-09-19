---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      schemas = {
        ['http://json-schema.org/draft-07/schema#'] = 'schema.{yml,yaml}',
        ['./packages/cli/schema.yaml'] = '**/.bemlorc',
        ['/Users/elias/dev/which-cmd/schema.yml'] = '**/commands.yml',
      },
    },
  },
}
