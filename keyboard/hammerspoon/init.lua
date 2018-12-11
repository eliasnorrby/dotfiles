local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, 'å', nil, function()
  hs.reload()
end)

keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

message = require('keyboard.status-message')
statusMessage = message.new('Config reloaded!')
statusMessage:notify(1)

enableHotkeyForWindowsMatchingFilter = function(windowFilter, hotkey)
  windowFilter:subscribe(hs.window.filter.windowFocused, function()
    hotkey:enable()
  end)

  windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
    hotkey:disable()
  end)
end

enableModalForWindowsMatchingFilter = function(windowFilter, modal)
  windowFilter:subscribe(hs.window.filter.windowFocused, function()
    modal:enter()
  end)

  windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
    modal:exit()
  end)
end

setContextForWindowsMatchingFilter = function(windowFilter, context)
  windowFilter:subscribe(hs.window.filter.windowFocused, function()
    hyper.context = context
  end)

  -- windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
  --   hyper.context = nil
  -- end)
end

-- Load submodules
require('keyboard.hyper')
require('keyboard.app-mode')
require('keyboard.tab-mode')

-- Vim Spoon
-- vim = hs.loadSpoon('VimMode')
-- vim:enableKeySequence('j', 'k')

-- Subscribe to the necessary events on the given window filter such that the
-- given hotkey is enabled for windows that match the window filter and disabled
-- for windows that don't match the window filter.
--
-- windowFilter - An hs.window.filter object describing the windows for which
--                the hotkey should be enabled.
-- hotkey       - The hs.hotkey object to enable/disable.
--
-- Returns nothing.



hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤓🤘'}):send()