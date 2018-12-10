local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types

-- A global variable for the Hyper Mode
hyper = hs.hotkey.modal.new()
hyperStatusMessage = message.new('Hyper Mode')

function enterHyperMode()
  hyperStatusMessage:show()
  hyper.active = true
  hyper.modifiers = {}
  hyper:enter()
end

function exitHyperMode()
  hyperStatusMessage:hide()
  hyper.active = false
  hyper.modifiers = {}
  hyper:exit()
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, 'F18', enterHyperMode, exitHyperMode)


-- Watch for modifiers
--------------------------------------------------------------------------------
-- Watch for key down/up events that represent modifiers in Hyper Mode
--------------------------------------------------------------------------------
hyperModeModifierKeyListener = eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
  if not hyper.active then
    return false
  end

  local charactersToModifers = {}
  charactersToModifers['d'] = 'alt'
  charactersToModifers['f'] = 'cmd'
  charactersToModifers['s'] = 'shift'
  charactersToModifers[' '] = 'ctrl'

  local modifier = charactersToModifers[event:getCharacters()]
  if modifier then
    if (event:getType() == eventTypes.keyDown) then
      hyper.modifiers[modifier] = true
    else
      hyper.modifiers[modifier] = nil
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
hyperModeNavListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not hyper.active then
    return false
  end

  local charactersToKeystrokes = {
    h = 'left',
    j = 'down',
    k = 'up',
    l = 'right',
  }

  local keystroke = charactersToKeystrokes[event:getCharacters(true):lower()]
  if keystroke then
    local modifiers = {}
    n = 0
    -- Apply the custom Super Duper Mode modifier keys that are active (if any)
    for k, v in pairs(hyper.modifiers) do
      n = n + 1
      modifiers[n] = k
    end
    -- Apply the standard modifier keys that are active (if any)
    for k, v in pairs(event:getFlags()) do
      n = n + 1
      modifiers[n] = k
    end

    keyUpDown(modifiers, keystroke)
    return true
  end
end):start()


-- -- Apps

-- local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')

-- for i, mapping in ipairs(hyperModeAppMappings) do
--   local key = mapping[1]
--   local app = mapping[2]
--   hyper:bind({}, key, function()
--     if (type(app) == 'string') then
--       hs.application.open(app)
--     elseif (type(app) == 'function') then
--       app()
--     else
--       hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
--     end
--   end)
-- end

-- Browser navigation
--------------------------------------------------------------------------------
-- Watch for i/o key down events in Super Duper Mode, and trigger the
-- corresponding key events to navigate to the previous/next tab respectively
--------------------------------------------------------------------------------
-- hyperListener = eventtap.new({ eventTypes.keyDown }, function(event)
--   if not hyper.triggered then
--     return false
--   end

--   local charactersToKeystrokes = {
--     u = { {'cmd'}, '1' },          -- go to first tab
--     i = { {'ctrl', 'shift'}, 'tab' }, -- go to previous tab
--     o = { {'ctrl'}, 'tab' }, -- go to next tab
--     p = { {'cmd'}, '9' },          -- go to last tab
--   }
--   local keystroke = charactersToKeystrokes[event:getCharacters()]

--   if keystroke then
--     keyUpDown(table.unpack(keystroke))
--     return true
--   end
-- end):start()
