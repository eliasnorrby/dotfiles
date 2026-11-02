-- Vimium's f for markdown: label every link in view with flash and follow
-- the one whose label is typed.
local M = {}

local code_queries = {
  markdown = '[(fenced_code_block) (indented_code_block)] @code',
  markdown_inline = '(code_span) @code',
}

-- Ranges of code between rows top and bottom (0-based), where link syntax is
-- only text
local function code_ranges(buf, top, bottom)
  local ranges = {}
  local ok, parser = pcall(vim.treesitter.get_parser, buf, 'markdown')
  if not ok or not parser then
    return ranges
  end
  parser:parse({ top, bottom + 1 })
  parser:for_each_tree(function(tree, ltree)
    local source = code_queries[ltree:lang()]
    if not source then
      return
    end
    local query = vim.treesitter.query.parse(ltree:lang(), source)
    for _, node in query:iter_captures(tree:root(), buf, top, bottom + 1) do
      table.insert(ranges, { node:range() })
    end
  end)
  return ranges
end

local function in_ranges(ranges, row, col)
  for _, r in ipairs(ranges) do
    local after_start = row > r[1] or (row == r[1] and col >= r[2])
    local before_end = row < r[3] or (row == r[3] and col < r[4])
    if after_start and before_end then
      return true
    end
  end
  return false
end

-- Links on one line: where each starts, where its label goes (the first
-- character render-markdown leaves visible) and what it points at
local function links_on_line(line)
  local links = {}
  local taken = {}
  local function add(link)
    table.insert(links, link)
    table.insert(taken, { link.col, link.end_col })
  end
  local function is_taken(col)
    for _, t in ipairs(taken) do
      if col >= t[1] and col < t[2] then
        return true
      end
    end
    return false
  end

  for s, inner, e in line:gmatch('()%[%[([^%]]+)%]%]()') do
    local bar = inner:find('|', 1, true)
    add({ col = s - 1, end_col = e - 1, label_col = s + 1 + (bar or 0), wiki = inner })
  end
  for s, dest, e in line:gmatch('()%[[^%]]*%]%(<?([^%s)>]+)>?[^)]*%)()') do
    if not is_taken(s - 1) then
      add({ col = s - 1, end_col = e - 1, label_col = s, dest = dest })
    end
  end
  for s, url, e in line:gmatch('()(%a[%w+.-]*://[^%s<>()%[%]`"]+)()') do
    if not is_taken(s - 1) then
      url = url:gsub('[.,;:!?]+$', '')
      add({ col = s - 1, end_col = s - 1 + #url, label_col = s - 1, dest = url })
    end
  end
  return links
end

local function matcher(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local top, bottom = unpack(vim.api.nvim_win_call(win, function()
    return { vim.fn.line('w0'), vim.fn.line('w$') }
  end))
  local code = code_ranges(buf, top - 1, bottom - 1)
  local lines = vim.api.nvim_buf_get_lines(buf, top - 1, bottom, false)
  local matches = {}
  for i, line in ipairs(lines) do
    local row = top + i - 1
    local folded = vim.api.nvim_win_call(win, function()
      return vim.fn.foldclosed(row) ~= -1
    end)
    if not folded then
      for _, link in ipairs(links_on_line(line)) do
        if not in_ranges(code, row - 1, link.col) then
          link.win = win
          link.pos = { row, link.label_col }
          link.end_pos = { row, link.label_col }
          table.insert(matches, link)
        end
      end
    end
  end
  return matches
end

local function follow(match)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(match.win, { match.pos[1], match.col })
  if match.dest and match.dest:match('^%a[%w+.-]*:') then
    vim.ui.open(match.dest)
  elseif vim.b.obsidian_buffer then
    vim.cmd('Obsidian follow_link')
  elseif match.dest then
    local path = vim.uri_decode((match.dest:gsub('#.*$', '')))
    if path ~= '' then
      local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
      vim.cmd.edit(vim.fn.fnameescape(vim.fs.normalize(vim.fs.joinpath(dir, path))))
    end
  else
    vim.notify('Wiki links only resolve inside a vault: ' .. match.wiki, vim.log.levels.WARN)
  end
end

function M.follow()
  require('flash').jump({
    search = { mode = 'search', max_length = 0, multi_window = false },
    label = { before = { 0, 0 }, after = false },
    matcher = matcher,
    action = follow,
  })
end

return M
