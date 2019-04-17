-- A global variable for the Tab Mode
tabMode = hs.hotkey.modal.new()
tabModeStatusMessage = message.new('Tab Mode')

function enterTabMode()
  tabModeStatusMessage:show()
  tabMode:enter()
end

function exitTabMode()
  tabModeStatusMessage:hide()
  tabMode:exit()
end

tabMode:bind({}, 'space', exitTabMode)

-- First tab
tabMode:bind({}, 'k', function() 
  keyUpDown({'cmd'}, '1')
end)

-- Previous tab
tabMode:bind({}, 'h', function() 
  keyUpDown({'ctrl', 'shift'}, 'tab')
end)

-- Next tab
tabMode:bind({}, 'l', function() 
  keyUpDown({'ctrl'}, 'tab')
end)

-- Last tab
tabMode:bind({}, 'j', function() 
  keyUpDown({'cmd'}, '9')
end)
