local u = require('core.utils')
local wk = require('which-key')

-- save & quit
wk.add({
  { '<leader>fs', '<cmd>w<CR>', desc = 'save' },
  { '<leader>q', '<cmd>q<CR>', desc = 'quit' },
  { '<leader>Q', '<cmd>qall<CR>', desc = 'quit all' },
  { '<leader>x', '<cmd>q!<CR>', desc = 'force quit' },
  { '<leader>X', '<cmd>qall!<CR>', desc = 'force quit all' },
  { '<leader>R', '<cmd>%bd!<CR>', desc = 'remove all buffers' },
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
  { '<leader>o', group = '+options' },
  { '<leader>ol', group = '+line numbers' },
  {
    '<leader>olr',
    function()
      vim.wo.number = true
      vim.wo.relativenumber = true
    end,
    desc = 'relative line numbers',
  },
  {
    '<leader>oln',
    function()
      vim.wo.number = true
      vim.wo.relativenumber = false
    end,
    desc = 'regular line numbers',
  },
  {
    '<leader>olo',
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
u.map('n', '-', '<nop>')

u.map('n', '<C-E>', '3<C-E>')
u.map('n', '<C-Y>', '3<C-Y>')

u.map('n', 'j', 'gj')
u.map('n', 'k', 'gk')

u.map('n', '<CR>', '<cmd>x<CR>')

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
  { '<leader>l', group = '+linear' },
  { '<leader>lf', '<cmd>r !linear_issue_number fix<CR>', desc = 'fixes...' },
  { '<leader>ln', 'd/##<CR>ONone.<ESC>O<ESC>jo<ESC>k', desc = 'none' },
  { '<leader>L', '<cmd>Lazy<CR>', desc = 'Lazy' },
})

wk.add({
  { '<leader>gt', require('core.extensions').quick_fix_todos, desc = 'quick fix todos' },
})

-- temporary
u.map('n', '<leader>so', vim.cmd.source)
