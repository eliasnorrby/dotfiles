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
