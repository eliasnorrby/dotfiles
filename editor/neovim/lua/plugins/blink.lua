local function should_allow_emmet(ctx)
  local kw = ctx:get_keyword() or ''
  if not kw:match('^[a-z0-9]+$') then
    return false
  end

  local line = ctx.line:sub(1, ctx.cursor[2])
  local prefix = line:sub(1, #line - #kw)

  -- If prefix ends with ">", decide whether it's an HTML > or an Emmet >
  if prefix:match('>$') then
    -- search backwards for the last "<"
    local lt = prefix:match('<[^<]*$')
    if lt then
      -- there is a "<" after the last previous "<" → assume it's HTML, allow
      return true
    else
      -- no matching "<" → it's an Emmet ">", block
      return false
    end
  end

  -- For other operators, block if directly preceding
  if prefix:match('[%.%+%*%[:%-]$') then
    return false
  end

  return true
end

-- https://cmp.saghen.dev/installation#lazy-nvim
---@type LazyPluginSpec
return {
  'saghen/blink.cmp',
  enabled = true,
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      accept = { auto_brackets = { enabled = true } },
      menu = {
        auto_show = function()
          return not vim.tbl_contains({ 'markdown', 'gitcommit' }, vim.bo.filetype)
        end,
      },
    },
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'enter',

      ['<C-e>'] = false,

      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      ['<C-d>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
      ['<C-f>'] = { 'hide', 'fallback' },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      per_filetype = {
        sql = { 'dadbod', 'snippets', 'buffer' },
      },
      providers = {
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100, -- make lazydev completions top priority (see `:h blink.cmp`)
        },
        lsp = {
          name = 'LSP',
          module = 'blink.cmp.sources.lsp',
          transform_items = function(ctx, items)
            local allow_emmet = should_allow_emmet(ctx)
            local out = {}
            for _, item in ipairs(items) do
              if item.client_name ~= 'emmet_language_server' or allow_emmet then
                table.insert(out, item)
              end
            end
            return out
          end,
        },
        emmet = {
          name = 'Emmet',
          module = 'blink.cmp.sources.lsp',
          -- keep it async/timeout defaults unless you want to change them
          transform_items = function(_, items)
            local out = {}
            for _, item in ipairs(items) do
              if item.client_name == 'emmet_language_server' then
                table.insert(out, item)
              end
            end
            return out
          end,
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

    vim.keymap.set('i', '<C-e>', function()
      local cmp = require('blink.cmp')

      -- if any menu is open, close it first
      if cmp.is_visible() then
        cmp.hide()
      end

      -- show Emmet suggestions
      cmp.show({
        providers = { 'emmet' },
        callback = function()
          cmp.accept({ index = 1 })
        end,
      })
    end, { desc = 'Trigger Emmet (accept first)' })

    -- Hide menu when opening brackets
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuOpen',
      callback = function()
        local col = vim.fn.col('.')
        local line = vim.fn.getline('.')
        if col > 1 then
          local prev_char = line:sub(col - 1, col - 1)
          if prev_char:match('[{(%[]') then
            require('blink.cmp').hide()
          end
        end
      end,
    })
  end,
}
