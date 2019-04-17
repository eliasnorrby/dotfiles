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

appMode:bind({}, 'p', function()
    keyUpDown({ 'ctrl', 'cmd', 'shift' }, 'l')
  end)

-- Bind the right cmd key
f16 = hs.hotkey.bind({}, 'F16', enterAppMode, exitAppMode)

-- Non-app bindings
-- Simpler vim movement:
local charactersToKeystrokes = {
  --- Movement
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

-- To get into window mode
appMode:bind({}, 'w', function()
  appMode:exit()
  enterWindowMode()
end)

-- Toggle fullscreen
appMode:bind({}, 'return', function()
  local win = hs.window.frontmostWindow()
  win:setFullscreen(not win:isFullscreen())
end)

-- Apps
local status, appModeMappings = pcall(require, 'keyboard.hyper-apps')

for i, mapping in ipairs(appModeMappings) do
  local key = mapping[1]
  local app = mapping[2]
  appMode:bind({}, key, function()
    if (type(app) == 'string') then
      hs.application.open(app)
      exitAppMode()
    else
      hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
    end
  end)
end
