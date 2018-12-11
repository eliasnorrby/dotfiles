-- A global variable for the Tab Mode
tabMode = hs.hotkey.modal.new()
tabModeStatusMessage = message.new('Tab Mode')

function enterTabMode()
  exitHyperMode()
  tabModeStatusMessage:show()
  tabMode:enter()
end

function exitTabMode()
  tabModeStatusMessage:hide()
  tabMode:exit()
end

hyper:bind({}, 'q', enterTabMode)
tabMode:bind({}, 'space', exitTabMode)

--------------------------------------------------------------------------------
-- Watch for i/o key down events in Super Duper Mode, and trigger the
-- corresponding key events to navigate to the previous/next tab respectively
--------------------------------------------------------------------------------
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

	-- u = { {'cmd'}, '1' },          -- go to first tab
 --    i = { {'ctrl', 'shift'}, 'tab' }, -- go to previous tab
 --    o = { {'ctrl'}, 'tab' }, -- go to next tab
 --    p = { {'cmd'}, '9' },          -- go to last tab