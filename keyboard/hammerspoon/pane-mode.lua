-- A global variable for the Pane Mode
paneMode = hs.hotkey.modal.new()
paneModeStatusMessage = message.new('Pane Mode')

function enterPaneMode()
  exitHyperMode()
  paneModeStatusMessage:show()
  paneMode:enter()
end

function exitPaneMode()
  paneModeStatusMessage:hide()
  paneMode:exit()
end

hyper:bind({}, 'w', enterPaneMode)
paneMode:bind({}, 'space', exitPaneMode)

-- Split

local splitKey = {{''}}

-- Resize left

-- Resize right

-- Select left

-- Select right

tabMode:bind({}, 'k', function() 
  keyUpDown({'cmd'}, '1')
end)

tabMode:bind({}, 'h', function() 
  keyUpDown({'ctrl', 'shift'}, 'tab')
end)

tabMode:bind({}, 'l', function() 
  keyUpDown({'ctrl'}, 'tab')
end)

tabMode:bind({}, 'j', function() 
  keyUpDown({'cmd'}, '9')
end)


local terminalWindowFilter = hs.window.filter.new('iTerm2')
local itermHotkeys = hs.fnutils.each(itermHotkeyMappings, function(mapping)
  local fromMods = mapping['from'][1]
  local fromKey = mapping['from'][2]
  local toMods = mapping['to'][1]
  local toKey = mapping['to'][2]
  local hotkey = hs.hotkey.new(fromMods, fromKey, function()
    keyUpDown(toMods, toKey)
  end)
  enableHotkeyForWindowsMatchingFilter(terminalWindowFilter, hotkey)
end)