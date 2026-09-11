-- Toggle a claude owned by this nvim instance, starting one if needed.
-- Deliberately bypasses sidekick's session picker: its tmux backend lists
-- every claude pane on the tmux server as an attachable session, but it can
-- only re-attach sessions it created itself, so picking one of ours just
-- shows a blank screen. Filtering out `external` sessions leaves the local
-- terminal session (if any) and the bare tool entry, so this never prompts.
local function toggle_claude()
  local State = require('sidekick.cli.state')
  local states = vim.tbl_filter(function(s)
    return not s.external
  end, State.get({ name = 'claude' }))
  local state = states[1]
  if not state then
    return vim.notify('claude is not available', vim.log.levels.WARN)
  end
  -- Mirrors sidekick.cli.toggle(): a fresh attach opens the terminal itself,
  -- an existing one gets its window toggled. Don't pass `show` to attach --
  -- that re-opens a hidden terminal right before toggle() closes it again,
  -- making the toggle stick in the hidden state.
  local just_attached
  state, just_attached = State.attach(state)
  local terminal = state.terminal
  if not terminal then
    return
  end
  if not just_attached then
    terminal:toggle()
  end
  if terminal:is_open() then
    terminal:focus()
  end
end

---@type LazyPluginSpec
return {
  'folke/sidekick.nvim',
  enabled = true,
  lazy = true,
  event = 'InsertEnter',
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      win = {
        keys = {
          prompt = { '<c-r>', 'prompt', mode = 't', desc = 'insert prompt or context' },
          -- Drop sidekick's buffer-local ctrl-hjkl mappings: in a float
          -- layout their expr action returns the key itself, feeding a raw
          -- ctrl-j (newline) to claude and shadowing the global float-aware
          -- terminal-mode navigation from legacy/navigation.lua.
          nav_left = false,
          nav_down = false,
          nav_up = false,
          nav_right = false,
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
      toggle_claude,
      desc = 'Sidekick Toggle Claude',
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
      toggle_claude,
      desc = 'Sidekick Toggle Claude',
    },
  },
  init = function()
    -- Entrypoint for the `vc` alias: `nvim +Claude`. Requiring a sidekick
    -- module makes lazy.nvim load the plugin.
    vim.api.nvim_create_user_command('Claude', toggle_claude, { desc = 'Toggle a local claude in sidekick' })
    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ao', group = '+opencode' },
    })
  end,
}
