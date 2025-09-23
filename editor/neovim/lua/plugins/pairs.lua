-- instead of autopairs, dependency of nvim-cmp
return {
  enabled = true,
  'saghen/blink.pairs',
  version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  dependencies = 'saghen/blink.download',
  opts = {
    highlights = {
      enabled = false,
    },
  },
}
