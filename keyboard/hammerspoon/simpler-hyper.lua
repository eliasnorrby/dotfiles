local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types

-- A global variable for the Hyper Mode
hyper = hs.hotkey.modal.new()
hyperStatusMessage = message.new('Hyper Mode')

function enterHyperMode()
  hyperStatusMessage:show()
  hyper.active = true
  hyper.mods = {}
  hyper.modCount = 0
  hyper:enter()
end

function exitHyperMode()
  hyperStatusMessage:hide()
  hyper.active = false
  hyper.mods = {}
  hyper.modCount = 0
  hyper:exit()
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, 'F18', enterHyperMode, exitHyperMode)

hyperModeModifierKeyListener = eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
  if not hyper.active then
    return false
  end

  local charactersToModifers = {}
  charactersToModifers['d'] = 'alt'
  charactersToModifers['f'] = 'cmd'
  charactersToModifers['s'] = 'shift'
  charactersToModifers[' '] = 'ctrl'

  local modifierToIndex = {}
  modifierToIndex['alt'] = 1
  modifierToIndex['cmd'] = 2
  modifierToIndex['shift'] = 3
  modifierToIndex['ctrl'] = 4 

  local modifier = charactersToModifers[event:getCharacters()]
  if modifier then
    
    if (event:getType() == eventTypes.keyDown) then
      local index = hyper.modCount + 1
      hyper.mods[index] = modifier
      hyper.modCount = hyper.modCount + 1
    else
      local index = hyper.modCount + 1
      hyper.mods[index] = nil
      hyper.modCount = hyper.modCount - 1
    end
    return true
  end
end):start()

-- Toggle fullscreen
hyper:bind({}, 'return', function()
  local win = hs.window.frontmostWindow()
  win:setFullscreen(not win:isFullscreen())
end)

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
  hyper:bind({}, m['from'], function()
      keyUpDown(hyper.mods, m['to'])
    end)
end)
