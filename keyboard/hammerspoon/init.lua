local log = hs.logger.new('init.lua', 'debug')
message = require('modules.status-message')

-- Tap a key
keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

-- Load submodules
require('modules.app-mode')
require('modules.special-paste')

-- Reload Hammerspoon
appMode:bind({}, ']', function()
  hs.reload()
end)

appMode:bind({ 'shift' }, ']', function()
  -- Load Spoons
  hs.loadSpoon('EmmyLua')
end)

hs.notify.new({ title = 'Hammerspoon', informativeText = 'Ready to rock 🤓🤘' }):send()
