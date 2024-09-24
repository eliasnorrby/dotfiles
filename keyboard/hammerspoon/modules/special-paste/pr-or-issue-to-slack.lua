local delay = 10000

-- Function to get PR number or issue tag from the clipboard URL
local function getIdentifier()
  local clipboard = hs.pasteboard.getContents()
  if clipboard then
    local prOrIssueNumber = clipboard:match('github.com/.*/(%d+)$')
    if prOrIssueNumber then
      return {
        type = 'github',
        id = prOrIssueNumber,
      }
    end
    local issueTag = clipboard:match('/issue/([A-Z]+-%d+)/')
    if issueTag then
      return {
        type = 'linear',
        id = issueTag,
      }
    end
  end
  hs.alert.show('Clipboard does not contain a supported URL')
  return nil
end

local function selectText(identifier)
  if identifier.type == 'github' then
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left', delay)
    hs.eventtap.keyStroke({ 'shift' }, 'left')
  elseif identifier.type == 'linear' then
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left', delay)
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left', delay)
    hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left', delay)
  end
end

-- Function to type out the reference, select it, and paste the URL
local function typeAndPastePRLink()
  local identifier = getIdentifier()

  if identifier then
    -- Type the identifier
    if identifier.type == 'github' then
      hs.eventtap.keyStrokes('#')
      hs.timer.usleep(delay)
    end

    for i = 1, #identifier.id do
      local char = identifier.id:sub(i, i)
      local mod = char:match('[A-Z]') and { 'shift' } or {}
      hs.eventtap.keyStroke(mod, identifier.id:sub(i, i), delay)
    end

    -- Select the typed text
    selectText(identifier)

    -- Paste the URL
    hs.eventtap.keyStroke({ 'cmd' }, 'v', delay)

    -- Move the cursor to after the pasted URL
    hs.eventtap.keyStroke({}, 'right', delay)
  end
end

-- Bind the function to a key combination (e.g., Cmd+Shift+P)
hs.hotkey.bind({ 'cmd', 'shift' }, 'P', typeAndPastePRLink)
