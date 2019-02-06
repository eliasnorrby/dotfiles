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

-- To get into app mode
-- hyper:bind({}, 'p', function()
--  hyper:exit()
--  enterAppMode()
-- end)

-- tmux prefix
hyper:bind({}, 'a', function()
  keyUpDown({'ctrl'}, 'b')
end)

-- To get into window mode
hyper:bind({}, 'w', function()
  hyper:exit()
  enterWindowMode()
end)

-- To get into tab mode
hyper:bind({}, 'q', function()
  enterTabMode()
end)

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

local paneLeftKey = 'u'
local paneRightKey = 'i'
local paneSplitKey = '\''

local paneMappings = {
  {
    name = 'split',
    from = {{}, paneSplitKey},
    to = {{'ctrl', 'shift', 'cmd'}, '-'},
  }, 
  {
    name = 'select left',
    from = {{}, paneLeftKey},
    to = {{'ctrl'}, 'y'},
  },
  {
    name = 'select right',
    from = {{}, paneRightKey},
    to = {{'ctrl'}, 'o'},
  },
  -- {
  --   name = 'resize left',
  --   from = {{'alt'}, paneLeftKey},
  --   to = {{'ctrl'}, 'u'},
  -- },
  -- {
  --   name = 'resize right',
  --   from = {{'alt'}, paneRightKey},
  --   to = {{'ctrl'}, 'i'},
  -- },
  -- {
  --   name = 'move left',
  --   from = {{'alt', 'shift'}, paneLeftKey},
  --   to = {{'ctrl', 'shift'}, 'y'},
  -- },
  -- {
  --   name = 'move right',
  --   from = {{'alt', 'shift'}, paneRightKey},
  --   to = {{'ctrl', 'shift'}, 'o'},
  -- },
  {
    name = 'move left',
    from = {{}, 'y'},
    to = {{'ctrl', 'shift'}, 'u'},
  },
  {
    name = 'move right',
    from = {{}, 'o'},
    to = {{'ctrl', 'shift'}, 'i'},
  },
}

local bindPaneKey = function(from, to)
  local fromMods = from[1]
  local fromKey = from[2]
  local toMods = to[1]
  local toKey = to[2]
  hyper:bind(fromMods, fromKey, function()
    keyUpDown(toMods, toKey)
  end)
end

local paneHotkeys = hs.fnutils.each(paneMappings, function(m)
  local action = m['name']
  print('========== Binding keys for')
  print(action)
  bindPaneKey(m['from'], m['to'])
end)
