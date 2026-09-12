-- Paste the clipboard URL as a rich-text hyperlink.
--
-- Reads clipboard content (expected URL), extracts a label:
-- - GitHub: github.com/.../123 -> #123
-- - Linear: linear.app/.../PROJ-123/... -> PROJ-123
-- - Notion: notion.so/.../Page-Name-uuid -> Page Name
--
-- Offers <a href="url">label</a> as html on the pasteboard (with the
-- label as plain-text fallback) and sends Cmd+V, so rich-text targets
-- (Slack, Linear, Notion, ...) insert a finished hyperlink. The
-- original clipboard is restored afterwards.
--
-- Mirrors wm/hyprland/special_paste.sh - keep the parsers in sync.

local function getLabel(url)
  local prOrIssueNumber = url:match('github%.com/.*/(%d+)')
  if prOrIssueNumber then
    return '#' .. prOrIssueNumber
  end

  local issueTag = url:match('linear%.app/[^/]+/issue/([A-Z]+-%d+)')
  if issueTag then
    return issueTag
  end

  -- Notion: page name without the UUID suffix; handles both the old
  -- notion.so/<ws>/<slug> and the new app.notion.com/p/<ws>/<slug> links
  local pageSlug = url:match('notion%.com/p/[^/]+/([%w%-]+)') or url:match('notion%.so/[^/]+/([%w%-]+)')
  if pageSlug then
    local pageName = pageSlug:gsub('%-[a-f0-9]*$', ''):gsub('%-', ' ')
    return pageName
  end

  return nil
end

local function htmlEscape(text)
  return (text:gsub('[&<>"]', {
    ['&'] = '&amp;',
    ['<'] = '&lt;',
    ['>'] = '&gt;',
    ['"'] = '&quot;',
  }))
end

local function pasteLink()
  local clipboard = hs.pasteboard.getContents()

  if not clipboard or clipboard == '' then
    hs.alert.show('Clipboard is empty')
    return
  end

  local label = getLabel(clipboard)

  if not label then
    hs.alert.show('Clipboard does not contain a supported URL')
    return
  end

  local html = '<a href="' .. htmlEscape(clipboard) .. '">' .. htmlEscape(label) .. '</a>'

  hs.pasteboard.writeDataForUTI(nil, 'public.html', html)
  hs.pasteboard.writeDataForUTI(nil, 'public.utf8-plain-text', label, true)
  hs.eventtap.keyStroke({ 'cmd' }, 'v')

  -- Give the target time to fetch the pasteboard, then restore it
  hs.timer.doAfter(0.5, function()
    hs.pasteboard.setContents(clipboard)
  end)
end

hs.hotkey.bind({ 'cmd', 'shift' }, 'P', pasteLink)
