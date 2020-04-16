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

-- Bind the right cmd key
f16 = hs.hotkey.bind({}, 'F16', enterAppMode, exitAppMode)

-- Mess with backspace
function notifyDisabledBackspace()
  hs.notify.new({title='❌ Nope', informativeText='You should be more accurate 😉'}):send()
end

function disableBackspace()
  hs.notify.new({title='⚔️ Backspace disabled', informativeText='Be brave!'}):send()
  hs.hotkey.bind({}, 'F17', notifyDisabledBackspace)
end

function enableBackspace()
  hs.notify.new({title='🏖 Backspace enabled', informativeText='Enjoy!'}):send()
  hs.hotkey.bind({}, 'F17', function()
      keyUpDown({}, 'delete')
  end)
end

appMode:bind({}, 'F17', disableBackspace)
appMode:bind({}, '=', enableBackspace)

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
