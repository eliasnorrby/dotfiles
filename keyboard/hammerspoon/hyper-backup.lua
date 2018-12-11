local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types

-- A global variable for the Hyper Mode
hyper = hs.hotkey.modal.new()
hyperStatusMessage = message.new('Hyper Mode')

function enterHyperMode()
  hyperStatusMessage:show()
  hyper.active = true
  hyper.modifiers = {}
  hyper.mods = {}
  hyper.modCount = 0
  hyper:enter()
end

function exitHyperMode()
  hyperStatusMessage:hide()
  hyper.active = false
  hyper.modifiers = {}
  hyper.mods = {}
  hyper.modCount = 0
  hyper:exit()
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, 'F18', enterHyperMode, exitHyperMode)


-- Watch for modifiers
--------------------------------------------------------------------------------
-- Watch for key down/up events that represent modifiers in Hyper Mode
--------------------------------------------------------------------------------
-- hyperModeModifierKeyListener = eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
--   if not hyper.active then
--     return false
--   end

--   local charactersToModifers = {}
--   charactersToModifers['d'] = 'alt'
--   charactersToModifers['f'] = 'cmd'
--   charactersToModifers['s'] = 'shift'
--   charactersToModifers[' '] = 'ctrl'

--   local modifier = charactersToModifers[event:getCharacters()]
--   if modifier then
--     if (event:getType() == eventTypes.keyDown) then
--       hyper.modifiers[modifier] = true
--     else
--       hyper.modifiers[modifier] = nil
--     end
--     return true
--   end
-- end):start()
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
hyper:bind({}, 'p', function()
  hyper:exit()
  enterAppMode()
end)


-- Toggle fullscreen
hyper:bind({}, "return", function()
  local win = hs.window.frontmostWindow()
  win:setFullscreen(not win:isFullscreen())
end)

-- Movement

-- hyper:bind({}, 'j', function()
--   keyUpDown({}, "down")
-- end)

-- hyper:bind({}, 'k', function()
--   keyUpDown({}, "up")
-- end)

-- hyper:bind({}, 'h', function()
--   keyUpDown({}, "left")
-- end)

-- hyper:bind({}, 'l', function()
--   keyUpDown({}, "right")
-- end)


-- Super Movement
--------------------------------------------------------------------------------
-- Watch for h/j/k/l key down events in Super Duper Mode, and trigger the
-- corresponding arrow key events
--------------------------------------------------------------------------------
-- hyperModeNavListener = eventtap.new({ eventTypes.keyDown }, function(event)
--   if not hyper.active then
--     return false
--   end

--   local charactersToKeystrokes = {
--     h = 'left',
--     j = 'down',
--     k = 'up',
--     l = 'right',
--   }

--   local keystroke = charactersToKeystrokes[event:getCharacters(true):lower()]
--   if keystroke then
--     local modifiers = {}
--     n = 0
--     -- Apply the custom Super Duper Mode modifier keys that are active (if any)
--     for k, v in pairs(hyper.modifiers) do
--       n = n + 1
--       modifiers[n] = k
--     end
--     -- Apply the standard modifier keys that are active (if any)
--     for k, v in pairs(event:getFlags()) do
--       n = n + 1
--       modifiers[n] = k
--     end

--     keyUpDown(modifiers, keystroke)
--     return true
--   end
-- end):start()

-- Simpler:
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
  hyper:bind({}, m['from'], function()
      keyUpDown(hyper.mods, m['to'])
    end)
end)

-- Panes
-- Split : -
local mySplitMods = {'ctrl', 'alt'}
local mySplitKey = 'ä'

-- Select left : u
local mySelectLeftMods = {'ctrl', 'alt'}
local mySelectLeftKey = 'u'


-- Select right : i
local mySelectRightMods = {'ctrl', 'alt'}
local mySelectRightKey = 'i'


-- Resize left : alt + u
local myResizeLeftMods = {'alt'}
local myResizeLeftKey = 'u'


-- Resize right : alt + i
local myResizeRightMods = {'alt'} 
local myResizeRightKey = 'i'

-- Move left : 
local myMoveLeftMods = {'alt', 'shift'}
local myMoveLeftKey = 'u'

-- Move right :
local myMoveRightMods = {'alt', 'shift'}
local myMoveRightKey = 'i'

-- local fromMap = {
--   split = {
--     mods = mySplitMods,
--     key = mySplitKey
--   },
--   selectLeft
-- }

hyper:bind({}, 'ä', function()
  print('pressed ä')
  keyUpDown(hyper.mods, 'u')
end)



local paneHotkeyMappings = {
	{
		app = 'Code',
    mappings = {
		  -- split = {
      {
        name = 'split',
        from = {mySplitMods, mySplitKey},
        to = {{'ctrl', 'shift', 'cmd'}, '-'},
      },
      -- selectLeft = {
      {
        name = 'selectLeft',
        from = {mySelectLeftMods, mySelectLeftKey},
        to = {{'ctrl', 'shift', 'cmd'}, 'u'}
      },
      -- selectRight = {
      {
        name = 'selectRight',
        from = {mySelectRightMods, mySelectRightKey},
        to = {{'ctrl', 'shift', 'cmd'}, 'i'}
      },
      -- resizeLeft = {
      -- name = '',
      -- from = {myResizeLeftMods, myResizeLeftKey}
      --   to = {}
      -- },
      -- resizeRight = {
      -- name = '',
      -- from = {myResizeRightMods, myResizeRightKey}
      --   to = {}
      -- },
      -- moveLeft = {
      {
        name = 'moveLeft',
        from = {myMoveLeftMods, myMoveLeftKey},
        to = {{'ctrl', 'shift', 'cmd', 'alt'}, 'u'}
      },
      -- moveRight = {
      {
        name = 'moveRight',
        from = {myMoveRightMods, myMoveRightKey},
        to = {{'ctrl', 'shift', 'cmd', 'alt'}, 'i'}
      },
    },
	},
  {
    app = 'iTerm2',
    mappings = {
      -- split = {
      {
        from = {mySplitMods, mySplitKey},
        to = {{'ctrl'}, '-'},
      },
      -- selectLeft = {
      {
        from = {mySelectLeftMods, mySelectLeftKey},
        to = {{'ctrl'}, 'u'}
      },
      -- selectRight = {
      {
        from = {mySelectRightMods, mySelectRightKey},
        to = {{'ctrl'}, 'i'}
      },
      -- resizeLeft = {
      {
        from = {myResizeLeftMods, myResizeLeftKey},
        to = {{'ctrl'}, 'h'}
      },
      -- resizeRight = {
      {
        from = {myResizeRightMods, myResizeRightKey},
        to = {{'ctrl'}, 'l'}
      },
    },
  },
}

-- Template:
-- {
--     app = 'Code',
--     mappings = {
--       split = {
--         from = {mySplitMods, mySplitKey},
--         to = {{'ctrl', 'alt', 'cmd', 'shift'}, '7'},
--       },
--       selectLeft = {
--         from = {mySelectLeftMods, mySelectLeftKey},
--         to = {{}}
--       },
--       selectRight = {
--         from = {mySelectRightMods, mySelectRightKey}
--         to = {}
--       },
--       resizeLeft = {
--         from = {myResizeLeftMods, myResizeLeftKey}
--         to = {}
--       },
--       resizeRight = {
--         from = {myResizeRightMods, myResizeRightKey}
--         to = {}
--       },
--     }
--   },

-- local lolToMods = paneHotkeyMappings[1]['mappings']['split']['from'][1]

-- local lolToMods = paneHotkeyMappings[1]['mappings'][1]['to'][1]
-- local lolToKey = paneHotkeyMappings[1]['mappings'][1]['to'][2]
-- print('mySplitMods')
-- print(mySplitMods)
-- print('mySplitKey')
-- print(mySplitKey)
-- print('lolToMods')
-- print(lolToMods)
-- hs.fnutils.each(lolToMods, function(m)
--   print(m)
--   end)
-- print('lolToKey')
-- print(lolToKey)
-- local testHotkey = hs.hotkey.new(mySplitMods, mySplitKey, function() 
--   keyUpDown(lolToMods, lolToKey)
--   end)
-- local testFilter = hs.window.filter.new(paneHotkeyMappings[1]['app'])
-- enableHotkeyForWindowsMatchingFilter(testFilter, testHotkey)

local paneHotkeys = hs.fnutils.each(paneHotkeyMappings, function(appMap)
 local app = appMap['app']
 print('========== Binding keys for')
 print(app)
 local filter = hs.window.filter.new(app)
 local mappingHotkeys = hs.fnutils.each(appMap['mappings'], function(mapping)
  print("--- binding new thing: ")
  print(mapping['name'])
  local fromMods = mapping['from'][1]
  print('fromMods: ')
  hs.fnutils.each(fromMods, function(m)
    print(m)
  end)
  local fromKey = mapping['from'][2]
  print('fromKey: ')
  print(fromKey)
  local toMods = mapping['to'][1]
  print('toMods: ')
  hs.fnutils.each(toMods, function(m)
    print(m)
  end)
  local toKey = mapping['to'][2]
  print('toKey: ')
  print(toKey)
  local hotkey = hs.hotkey.new(fromMods, fromKey, function()
    keyUpDown(toMods, toKey)
  end)
  enableHotkeyForWindowsMatchingFilter(filter, hotkey)
 end)
end)
