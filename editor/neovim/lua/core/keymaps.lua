local u = require('core.utils')
local wk = require('which-key')

-- save & quit
wk.add({
  { '<leader>fs', '<cmd>w<CR>', desc = 'save' },
  { '<leader>q', '<cmd>q<CR>', desc = 'quit' },
  { '<leader>Q', '<cmd>qall<CR>', desc = 'quit all' },
  { '<leader>x', '<cmd>q!<CR>', desc = 'force quit' },
  { '<leader>X', '<cmd>qall!<CR>', desc = 'force quit all' },
  {
    '<leader>R',
    function()
      local bufs = vim.api.nvim_list_bufs()
      for _, buf in ipairs(bufs) do
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
        if buftype ~= 'terminal' and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end,
    desc = 'remove all buffers (keep terminals)',
  },
})

wk.add({
  { '<leader>nt', '<cmd>tabnew<CR>', desc = 'new tab' },
})

-- file path yanking
local function get_line_range()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '' then
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    if start_line == end_line then
      return '#L' .. start_line
    else
      return '#L' .. start_line .. '-L' .. end_line
    end
  else
    return '#L' .. vim.fn.line('.')
  end
end

wk.add({
  {
    '<leader>fy',
    function()
      local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
      if vim.v.shell_error ~= 0 then
        vim.notify('Not in a git repository', vim.log.levels.WARN)
        return
      end
      local abs_path = vim.fn.expand('%:p')
      local rel_path = vim.fn.fnamemodify(abs_path, ':s?' .. git_root .. '/??')
      vim.fn.setreg('+', rel_path)
      vim.notify('Copied: ' .. rel_path, vim.log.levels.INFO)
    end,
    desc = 'yank relative path (git root)',
  },
  {
    '<leader>fY',
    function()
      local abs_path = vim.fn.expand('%:p')
      vim.fn.setreg('+', abs_path)
      vim.notify('Copied: ' .. abs_path, vim.log.levels.INFO)
    end,
    desc = 'yank absolute path',
  },
})

-- file path yanking with line ranges
wk.add({
  {
    mode = { 'n', 'v' },
    {
      '<leader>fl',
      function()
        local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        if vim.v.shell_error ~= 0 then
          vim.notify('Not in a git repository', vim.log.levels.WARN)
          return
        end
        local abs_path = vim.fn.expand('%:p')
        local repo_name = vim.fn.fnamemodify(git_root, ':t')
        local rel_path = vim.fn.fnamemodify(abs_path, ':s?' .. git_root .. '/??')
        local line_range = get_line_range()
        local result = repo_name .. '/' .. rel_path .. line_range
        vim.fn.setreg('+', result)
        vim.notify('Copied: ' .. result, vim.log.levels.INFO)
      end,
      desc = 'yank path with lines (repo/path)',
    },
    {
      '<leader>fL',
      function()
        local abs_path = vim.fn.expand('%:p')
        local line_range = get_line_range()
        local result = abs_path .. line_range
        vim.fn.setreg('+', result)
        vim.notify('Copied: ' .. result, vim.log.levels.INFO)
      end,
      desc = 'yank path with lines (absolute)',
    },
    {
      '<leader>fn',
      function()
        local filename = vim.fn.expand('%:t')
        local line_range = get_line_range()
        local result = filename .. line_range
        vim.fn.setreg('+', result)
        vim.notify('Copied: ' .. result, vim.log.levels.INFO)
      end,
      desc = 'yank path with lines (filename only)',
    },
  },
})

-- windows
wk.add({
  { '<leader>wv', '<cmd>vsplit<CR>', desc = 'vertical split' },
  { '<leader>ws', '<cmd>split<CR>', desc = 'horizontal split' },
  { '<leader>wo', '<C-W>o', desc = 'close other windows' },
  { '<leader>wq', '<C-W>q', desc = 'close window' },
  { '<leader>w=', '<C-W>=', desc = 'balance windows' },
  { '<leader>w-', '<C-W>-', desc = 'decrease height' },
  { '<leader>w+', '<C-W>+', desc = 'increase height' },
  { '<leader>w<', '<C-W><', desc = 'decrease width' },
  { '<leader>w>', '<C-W>>', desc = 'increase width' },
  { '<leader>wH', '<C-W>H', desc = 'move to left window' },
  { '<leader>wJ', '<C-W>J', desc = 'move to bottom window' },
  { '<leader>wK', '<C-W>K', desc = 'move to top window' },
  { '<leader>wL', '<C-W>L', desc = 'move to right window' },
  { '<leader>wT', '<C-W>T', desc = 'move window to new tab' },
})

-- tabs
for i = 1, 5, 1 do
  u.map('n', '<leader>' .. i, i .. 'gt', { desc = 'which_key_ignore' })
end

wk.add({
  { '<leader>t', group = '+options' },
  { '<leader>tl', group = '+line numbers' },
  {
    '<leader>tlr',
    function()
      vim.wo.number = true
      vim.wo.relativenumber = true
    end,
    desc = 'relative line numbers',
  },
  {
    '<leader>tln',
    function()
      vim.wo.number = true
      vim.wo.relativenumber = false
    end,
    desc = 'regular line numbers',
  },
  {
    '<leader>tlo',
    function()
      vim.wo.number = false
      vim.wo.relativenumber = false
    end,
    desc = 'no line numbers',
  },
})

-- other
u.map('x', 'K', ":move '<-2<CR>gv=gv")
u.map('x', 'J', ":move '>+1<CR>gv=gv")

u.map('n', 'Q', '<nop>')
-- u.map('n', '-', '<nop>')
u.map('n', '\\', '<C-^>')

u.map('n', '<C-E>', '3<C-E>')
u.map('n', '<C-Y>', '3<C-Y>')

u.map('n', 'j', 'gj')
u.map('n', 'k', 'gk')

wk.add({
  { '<leader>c', group = '+quickfix' },
  { '<leader>co', '<cmd>copen<CR>', desc = 'open' },
  { '<leader>cc', '<cmd>cclose<CR>', desc = 'close' },
})

wk.add({
  {
    mode = 'x',
    { '<leader>s', ":'<,'>!sort<CR>", desc = 'sort' },
    { '<leader>ft', ':s/^  /	/<cr>', desc = 'format heredoc' },
  },
})

wk.add({
  { '<leader>L', '<cmd>Lazy<CR>', desc = 'Lazy' },
  { '<leader>M', '<cmd>Mason<CR>', desc = 'Mason' },
})

wk.add({
  { '<leader>gt', require('core.extensions').quick_fix_todos, desc = 'quick fix todos' },
  { '<leader>ym', require('core.extensions').yank_ts_reference, desc = 'yank method ref' },
})

-- temporary
u.map('n', '<leader>so', vim.cmd.source)
-- paste surrounded by backticks
u.map('i', '<C-a>', '`<C-R>+`')
