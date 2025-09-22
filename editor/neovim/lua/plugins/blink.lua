-- https://cmp.saghen.dev/installation#lazy-nvim
---@type LazyPluginSpec
return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      accept = { auto_brackets = { enabled = true } },
    },
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'enter',

      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      ['<C-d>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
      ['<C-f>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100, -- make lazydev completions top priority (see `:h blink.cmp`)
        },
      },
    },
    signature = {
      enabled = true,
    },
  },
  opts_extend = { 'sources.default' },
}
