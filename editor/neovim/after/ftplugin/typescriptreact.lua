-- Put this somewhere in your config, e.g. lua/react_classname.lua and require it from init.lua
local M = {}

local function get_lang_from_ft(ft)
  if ft == 'typescriptreact' then
    return 'tsx'
  end
  if ft == 'javascriptreact' then
    return 'javascript'
  end
  return nil
end

local function pos_lt(a_r, a_c, b_r, b_c)
  if a_r ~= b_r then
    return a_r < b_r
  end
  return a_c < b_c
end

-- Find the current or next JSX element (opening+children+closing) or self-closing tag
local function find_next_jsx_tag(lang, cur_row, cur_col)
  local parser = vim.treesitter.get_parser(0, lang)
  if not parser then
    vim.notify('No Treesitter parser for ' .. lang, vim.log.levels.ERROR)
    return nil
  end
  local tree = parser:parse()[1]
  local root = tree:root()

  local ok, query = pcall(
    vim.treesitter.query.parse,
    lang,
    [[
    (jsx_element) @element
    (jsx_self_closing_element) @element
  ]]
  )
  if not ok then
    vim.notify('Treesitter query parse failed: ' .. tostring(query), vim.log.levels.ERROR)
    return nil
  end

  -- Pass 1: check if cursor is inside any element (opening, children, or closing)
  local inside_node
  for _, node in query:iter_captures(root, 0, cur_row, cur_row + 1) do
    local sr, sc, er, ec = node:range()
    if (cur_row > sr or (cur_row == sr and cur_col >= sc)) and (cur_row < er or (cur_row == er and cur_col <= ec)) then
      -- climb to the smallest enclosing jsx_element/self_closing_element
      inside_node = node
    end
  end
  if inside_node then
    return inside_node
  end

  -- Pass 2: find next element starting at/after cursor
  local best_node, best_sr, best_sc
  for _, node in query:iter_captures(root, 0, cur_row, -1) do
    local sr, sc = node:start()
    if (sr > cur_row) or (sr == cur_row and sc >= cur_col) then
      if not best_node or pos_lt(sr, sc, best_sr, best_sc) then
        best_node, best_sr, best_sc = node, sr, sc
      end
    end
  end

  -- Pass 3: wrap around to first element in file
  if not best_node then
    for _, node in query:iter_captures(root, 0, 0, -1) do
      local sr, sc = node:start()
      if not best_node or pos_lt(sr, sc, best_sr, best_sc) then
        best_node, best_sr, best_sc = node, sr, sc
      end
    end
  end

  return best_node
end

local function find_attr(node, name)
  for child in node:iter_children() do
    if child:type() == 'jsx_attribute' then
      local name_node = child:child(0)
      if name_node then
        local txt = vim.treesitter.get_node_text(name_node, 0)
        if txt == name then
          return child
        end
      end
    end
  end
  return nil
end

local function jump_inside_value(attr_node)
  local value_node = attr_node:child(2) -- jsx_attribute -> name '=' value
  if value_node then
    local _, _, er, ec = value_node:range()
    -- Go just before the closing quote or brace
    local target_row, target_col = er, ec - 1
    if target_col < 0 then
      target_col = 0
    end
    vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col })
    vim.cmd('startinsert')
    return true
  else
    -- Boolean attr: turn into =""
    local name_node = attr_node:child(0)
    local nr, nc = name_node:end_()
    vim.api.nvim_buf_set_text(0, nr, nc, nr, nc, { '=""' })
    vim.api.nvim_win_set_cursor(0, { nr + 1, nc + 2 }) -- inside the quotes
    vim.cmd('startinsert')
    return true
  end
end

function M.jump_or_insert_classname()
  local ft = vim.bo.filetype
  local lang = get_lang_from_ft(ft)
  if not lang then
    vim.notify('Unsupported filetype for JSX: ' .. ft, vim.log.levels.WARN)
    return
  end

  vim.cmd.normal({ args = { '^' }, bang = true })

  local cur = vim.api.nvim_win_get_cursor(0)
  local cur_row, cur_col = cur[1] - 1, cur[2]

  local tag = find_next_jsx_tag(lang, cur_row, cur_col)
  if not tag then
    vim.notify('No JSX tag found', vim.log.levels.INFO)
    return
  end

  -- If it's a full element, look at its first child (the opening element)
  if tag:type() == 'jsx_element' then
    tag = tag:child(0) -- jsx_opening_element
  end
  if not tag then
    vim.notify('No JSX tag found', vim.log.levels.INFO)
    return
  end

  -- Prefer React's className; also consider plain HTML 'class'
  local attr = find_attr(tag, 'className') or find_attr(tag, 'class')
  if attr then
    jump_inside_value(attr)
    return
  end

  -- Insert new className="" just before '>' or '/>'
  local er, ec = tag:end_()
  local is_self = (tag:type() == 'jsx_self_closing_element')
  local insert_row, insert_col = er, is_self and (ec - 2) or (ec - 1) -- before '/' or '>'
  if insert_col < 0 then
    insert_col = 0
  end

  local prefix = ' className="'
  local whole = prefix .. '"' -- results in: className=""

  vim.api.nvim_buf_set_text(0, insert_row, insert_col, insert_row, insert_col, { whole })
  vim.api.nvim_win_set_cursor(0, { insert_row + 1, insert_col + #prefix })
  vim.cmd('startinsert')
end

vim.keymap.set('n', '<C-f>', M.jump_or_insert_classname, { desc = 'Jump to or create className' })
return M
