---@type LazyPluginSpec
return {
  'folke/sidekick.nvim',
  enabled = true,
  lazy = true,
  event = 'InsertEnter',
  opts = {
    cli = {
      win = {
        keys = {
          prompt = { '<c-r>', 'prompt', mode = 't', desc = 'insert prompt or context' },
        },
        layout = 'float',
      },
    },
  },
  keys = {
    {
      '<tab>',
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require('sidekick').nes_jump_or_apply() then
          return '<Tab>' -- fallback to normal tab
        end
      end,
      expr = true,
      desc = 'Goto/Apply Next Edit Suggestion',
    },
    {
      '<C-p>',
      function()
        require('sidekick.cli').toggle()
      end,
      desc = 'Sidekick Toggle',
      mode = { 'n', 't', 'x' },
    },
    {
      '<leader>aot',
      function()
        require('sidekick.cli').toggle()
      end,
      desc = 'Sidekick Toggle CLI',
    },
    {
      '<leader>aos',
      function()
        require('sidekick.cli').select()
      end,
      desc = 'Sidekick Select CLI',
    },
    {
      '<leader>aod',
      function()
        require('sidekick.cli').close()
      end,
      desc = 'Sidekick Detach CLI',
    },
    {
      '<leader>aon',
      function()
        require('sidekick.cli').send({ msg = '{this}' })
      end,
      mode = { 'n', 'x' },
      desc = 'Sidekick Send This',
    },
    {
      '<leader>aof',
      function()
        require('sidekick.cli').send({ msg = '{file}' })
      end,
      desc = 'Sidekick Send File',
    },
    {
      '<leader>aov',
      function()
        require('sidekick.cli').send({ msg = '{selection}' })
      end,
      mode = { 'x' },
      desc = 'Sidekick Send Selection',
    },
    {
      '<leader>aop',
      function()
        require('sidekick.cli').prompt()
      end,
      mode = { 'n', 'x' },
      desc = 'Sidekick Select Prompt',
    },
    {
      '<leader>aoc',
      function()
        require('sidekick.cli').toggle({ name = 'claude', focus = true })
      end,
      desc = 'Sidekick Toggle Claude',
    },
  },
  init = function()
    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ao', group = '+opencode' },
    })
  end,
}
