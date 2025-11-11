-- Jump to the next {param} on the current line, skipping {{double-braced}} blocks,
-- delete it, and enter insert mode at its position.
local function next_param()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- row: 1-based, col: 0-based
  local line = vim.api.nvim_get_current_line()
  local n = #line

  -- Search helper: finds the next {something} not wrapped by double braces.
  local function find_param(start_idx)
    local s, e = line:find('{[^{}]+}', start_idx) -- Lua pattern, not PCRE
    while s do
      local prev = (s > 1) and line:sub(s - 1, s - 1) or ''
      local nextc = (e < n) and line:sub(e + 1, e + 1) or ''
      -- single-braced only: not preceded by '{' and not followed by '}'
      if prev ~= '{' and nextc ~= '}' then
        return s, e
      end
      -- keep scanning past this match
      s, e = line:find('{[^{}]+}', e + 1)
    end
    return nil, nil
  end

  -- 1) try from cursor to EOL, 2) wrap to SOL if needed
  local s, e = find_param(col + 1)
  if not s then
    s, e = find_param(1)
  end

  if not s then
    vim.notify('No single-braced {param} found on this line.', vim.log.levels.INFO)
    return
  end

  -- Move to start of param, delete it using buffer API, and enter insert mode.
  -- nvim_buf_set_text uses 0-based, end-exclusive columns; string.find is 1-based inclusive.
  vim.api.nvim_win_set_cursor(0, { row, s - 1 })
  vim.api.nvim_buf_set_text(0, row - 1, s - 1, row - 1, e, { '' })
  -- Place cursor where the param started (now an empty spot) and start insert
  vim.api.nvim_win_set_cursor(0, { row, s - 1 })
  vim.cmd('startinsert')
end

-- Command + keybind
vim.api.nvim_create_user_command('NextParam', next_param, {})
vim.keymap.set(
  'n',
  '<Tab>',
  next_param,
  { noremap = true, silent = true, desc = 'Jump to next {param}, delete, and insert' }
)

-----------------------------------------------------------
-- Folding
-----------------------------------------------------------

-- Use marker-based folding with ### as the marker
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.HttpFoldExpr(v:lnum)'
vim.opt_local.foldtext = 'v:lua.HttpFoldText()'

-- Fold expression: start a fold at lines beginning with ###
function _G.HttpFoldExpr(lnum)
  local line = vim.fn.getline(lnum)
  if line:match('^###%s+') then
    return '>1' -- Start a fold
  end
  return '=' -- Continue current fold level
end

-- Custom fold text: show only the request name
function _G.HttpFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local name = line:match('^###%s+(.+)') or 'Request'
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  return string.format('### %s  [%d lines] ', name, line_count)
end
