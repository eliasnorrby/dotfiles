local delay = 10000

local function split(input, separator)
    local result = {}
    for part in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(result, part)
    end
    return result
end

local function getIdentifier()
  local clipboard = hs.pasteboard.getContents()
  if clipboard then
    local prOrIssueNumber = clipboard:match('github.com/.*/(%d+)')
    if prOrIssueNumber then
      return {
        type = 'github',
        id = prOrIssueNumber,
      }
    end
    local issueTag = clipboard:match('linear.app/[^/]+/issue/([A-Z]+-%d+)/')
    if issueTag then
      return {
        type = 'linear',
        id = issueTag,
      }
    end
    local pageName = clipboard:match('notion.so/[^/]+/([a-zA-Z0-9-]+)')
    if pageName then
      local pageNameParts = split(pageName, '-')
      table.remove(pageNameParts, #pageNameParts)
      return {
        type = 'notion',
        id = table.concat(pageNameParts, ' '),
        wordCount = #pageNameParts,
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
  elseif identifier.type == 'notion' then
    for _ = 1, identifier.wordCount do
      hs.eventtap.keyStroke({ 'alt', 'shift' }, 'left', delay)
    end
  end
end

-- Type out the reference, select it, and paste the URL
local function typeAndPasteLink()
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
      local key = char == ' ' and 'space' or char
      hs.eventtap.keyStroke(mod, key, delay)
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
hs.hotkey.bind({ 'cmd', 'shift' }, 'P', typeAndPasteLink)
