-- A global variable for the App Mode
appMode = hs.hotkey.modal.new()
appModeStatusMessage = message.new('App Mode')

function enterAppMode()
  appModeStatusMessage:show()
  appMode:enter()
end

function exitAppMode()
  appModeStatusMessage:hide()
  appMode:exit()
end

appMode:bind({}, 'space', exitAppMode)

-- Open 1Password Quick Search
appMode:bind({}, 'p', function()
    keyUpDown({ 'cmd', 'alt' }, '\\')
  end)

-- Select tmux windows using number keys
-- These bindings must be matched by bindings in tmux.conf, i.e.
--   bind-key -n F1 select-window -t 1
for i=1,8 do
  appMode:bind({}, tostring(i), function()
    keyUpDown({}, 'F' .. i)
  end)
end

-- Bind the right cmd key
f16 = hs.hotkey.bind({}, 'F16', enterAppMode, exitAppMode)

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
  appMode:bind({}, m['from'], function()
      keyUpDown({}, m['to'])
    end)
end)

-- Toggle fullscreen
appMode:bind({}, 'return', function()
  local win = hs.window.frontmostWindow()
  win:setFullscreen(not win:isFullscreen())
end)

-- Apps
local status, appModeMappings = pcall(require, 'modules.app-mode.app-mappings')

for i, mapping in ipairs(appModeMappings) do
  local key = mapping[1]
  local app = mapping[2]
  appMode:bind({}, key, function()
    if (type(app) == 'string') then
      hs.application.open(app)
      exitAppMode()
    else
      hs.logger.new('apps'):e('Invalid mapping for App Mode +', key)
    end
  end)
end
