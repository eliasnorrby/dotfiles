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
      enabled = false,
    },
  },
  opts_extend = { 'sources.default' },
  config = function(_, opts)
    require('blink.cmp').setup(opts)
    vim.keymap.set({ 'n', 'i', 's' }, '<Esc>', function()
      if vim.snippet and vim.snippet.active({ direction = 1 }) then
        vim.snippet.stop()
      end
      return '<Esc>'
    end, { expr = true, noremap = true })
  end,
}
