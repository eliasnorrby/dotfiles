-- Function to get PR number from the clipboard URL
local function getPRNumberFromClipboard()
  local clipboard = hs.pasteboard.getContents()
  local prNumber = clipboard:match('/pull/(%d+)$')
  if prNumber then
    return '#' .. prNumber
  else
    hs.alert.show('Clipboard does not contain a valid GitHub PR URL')
    return nil
  end
end

-- Function to type out the PR number, select it, and paste the URL
local function typeAndPastePRLink()
  local prNumber = getPRNumberFromClipboard()

  if prNumber then
    -- Type the PR number with hash
    hs.eventtap.keyStrokes(prNumber)

    -- Select the typed text
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left')
    hs.eventtap.keyStroke({ 'shift' }, 'left')

    -- Paste the URL
    hs.eventtap.keyStroke({ 'cmd' }, 'v')

    -- Move the cursor to after the pasted URL
    hs.eventtap.keyStroke({}, 'right')
  end
end

-- Bind the function to a key combination (e.g., Cmd+Shift+P)
hs.hotkey.bind({ 'cmd', 'shift' }, 'P', typeAndPastePRLink)
