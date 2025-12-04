-- A global variable for the App Mode
AppMode = hs.hotkey.modal.new()

local log = hs.logger.new('init.lua', 'debug')
local message = require('modules.status-message')
local appModeStatusMessage = message.new('🚀')
local appModeBlocked = false

-- Tap a key
local function keyUpDown(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

local function enterAppMode()
  if appModeBlocked then
    return
  end
  appModeStatusMessage:show()
  AppMode:enter()
end

local function exitAppMode()
  appModeStatusMessage:hide()
  AppMode:exit()
end

AppMode:bind({}, 'space', exitAppMode)

-- Select tmux windows using number keys
-- These bindings must be matched by bindings in tmux.conf, i.e.
--   bind-key -n F1 select-window -t 1
for i = 1, 8 do
  AppMode:bind({}, tostring(i), function()
    keyUpDown({}, 'F' .. i)
  end)
end

-- Bind the right cmd key
hs.hotkey.bind({}, 'F16', enterAppMode, exitAppMode)

-- Non-app bindings
-- vim movement:
local charactersToKeystrokes = {
  {
    from = 'h',
    to = 'left',
  },
  {
    from = 'j',
    to = 'down',
  },
  {
    from = 'k',
    to = 'up',
  },
  {
    from = 'l',
    to = 'right',
  },
}

hs.fnutils.each(charactersToKeystrokes, function(m)
  AppMode:bind({}, m['from'], function()
    keyUpDown({}, m['to'])
  end)
end)

-- Toggle fullscreen
AppMode:bind({}, 'return', function()
  local win = hs.window.frontmostWindow()
  win:setFullScreen(not win:isFullScreen())
end)

-- Apps
local _, appModeMappings = pcall(require, 'modules.app-mode.app-mappings')

for _, mapping in ipairs(appModeMappings) do
  local key = mapping[1]
  local app = mapping[2]
  local mods = mapping[3] or {}
  AppMode:bind(mods, key, function()
    if type(app) == 'string' then
      hs.application.open(app)
      exitAppMode()
    elseif type(app) == 'function' then
      app()
    else
      hs.logger.new('apps'):e('Invalid mapping for App Mode +', key)
    end
  end)
end
