local log = hs.logger.new('init.lua', 'debug')
message = require('modules.status-message')
statusMessage = message.new('Config reloaded!')
statusMessage:notify(1)

-- Tap a key
keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

-- Load submodules
require('modules.app-mode')
wifi = require('modules.wifi')

-- Reload Hammerspoon
appMode:bind({}, ']', function()
    hs.reload()
  end)

-- Connect to wifi
-- appMode:bind({}, ']', function()
--     wifi.connect()
--   end)

hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤓🤘'}):send()
