-- Load submodules
require('modules.app-mode')
require('modules.special-paste')

-- Reload Hammerspoon
AppMode:bind({}, ']', function()
  hs.reload()
end)

AppMode:bind({ 'shift' }, ']', function()
  -- Load Spoons
  hs.loadSpoon('EmmyLua')
end)

hs.notify.new({ title = 'Hammerspoon', informativeText = 'Ready to rock 🤓🤘' }):send()
