-- Unified ctrl-hjkl navigation across vim windows, tmux panes and Hyprland
-- windows. The `navigate` script (shell/tmux topic) handles the hop out of
-- vim: tmux pane if one exists in the direction, Hyprland window otherwise.

local to_navigate_dir = { h = 'l', j = 'd', k = 'u', l = 'r' }

local function unified_nav(dir)
  -- A floating window (like the sidekick claude float) covers the editor, so
  -- vim-level navigation makes no sense there: leave the float focused and
  -- visible, and hop straight out to the next tmux pane / OS window. This is
  -- what lets you keep the claude transcript on screen while typing in the
  -- shell pane below.
  if vim.api.nvim_win_get_config(0).relative == '' then
    local before = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)
    if vim.api.nvim_get_current_win() ~= before then
      return
    end
  end
  vim.system({ 'navigate', to_navigate_dir[dir], '1' })
end

for dir in pairs(to_navigate_dir) do
  local desc = 'Navigate ' .. dir .. ' (win/tmux/wm)'
  vim.keymap.set('n', '<c-' .. dir .. '>', function()
    unified_nav(dir)
  end, { silent = true, desc = desc })
  -- Also from terminal buffers: ctrl-hjkl is reserved for navigation
  -- everywhere and must never reach the terminal job (ctrl-j used to insert
  -- a newline in claude).
  vim.keymap.set('t', '<c-' .. dir .. '>', function()
    vim.cmd.stopinsert()
    vim.schedule(function()
      unified_nav(dir)
    end)
  end, { silent = true, desc = desc })
end
