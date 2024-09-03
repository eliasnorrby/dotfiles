-- Function to get PR number or issue tag from the clipboard URL
local function getIdentifier()
  local clipboard = hs.pasteboard.getContents()
  if clipboard then
    local prNumber = clipboard:match('/pull/(%d+)$')
    if prNumber then
      return '#' .. prNumber
    end
    local issueTag = clipboard:match('/issue/([A-Z]+-%d+)/')
    if issueTag then
      return issueTag
    end
  end
  hs.alert.show('Clipboard does not contain a supported URL')
  return nil
end

local function selectText(identifier)
  if identifier:match('^#%d+$') then
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left')
    hs.eventtap.keyStroke({ 'shift' }, 'left')
  else
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left')
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left')
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left')
  end
end

-- Function to type out the reference, select it, and paste the URL
local function typeAndPastePRLink()
  local identifier = getIdentifier()

  if identifier then
    -- Type the identifier
    hs.eventtap.keyStrokes(identifier)

    -- Select the typed text
    selectText(identifier)

    -- Paste the URL
    hs.eventtap.keyStroke({ 'cmd' }, 'v')

    -- Move the cursor to after the pasted URL
    hs.eventtap.keyStroke({}, 'right')
  end
end

-- Bind the function to a key combination (e.g., Cmd+Shift+P)
hs.hotkey.bind({ 'cmd', 'shift' }, 'P', typeAndPastePRLink)
