local u = require('core.utils')
local wk = require('which-key')

-- save & quit
wk.register({
  ['fs'] = { ':w<CR>', 'save' },
  ['q'] = { ':q<CR>', 'quit' },
  ['Q'] = { ':qall<CR>', 'quit all' },
  ['x'] = { ':q!<CR>', 'force quit' },
  ['X'] = { ':qall!<CR>', 'force quit all' },
  ['R'] = { ':%bd!<CR>', 'remove all buffers' },
}, { prefix = '<leader>' })

-- windows
wk.register({
  ['v'] = { ':vsplit<CR>', 'vertical split' },
  ['s'] = { ':split<CR>', 'horizontal split' },
  ['o'] = { '<C-W>o', 'close other windows' },
  ['q'] = { '<C-W>q', 'close window' },
  ['='] = { '<C-W>=', 'balance windows' },
  ['-'] = { '<C-W>-', 'decrease height' },
  ['+'] = { '<C-W>+', 'increase height' },
  ['<'] = { '<C-W><', 'decrease width' },
  ['>'] = { '<C-W>>', 'increase width' },
  ['H'] = { '<C-W>H', 'move to left window' },
  ['J'] = { '<C-W>J', 'move to bottom window' },
  ['K'] = { '<C-W>K', 'move to top window' },
  ['L'] = { '<C-W>L', 'move to right window' },
  ['T'] = { '<C-W>T', 'move window to new tab' },
}, { prefix = '<leader>w' })

-- tabs
for i = 1, 5, 1 do
  u.map('n', '<leader>' .. i, i .. 'gt', { desc = 'which_key_ignore' })
end

wk.register({
  ['o'] = {
    name = '+options',
    -- line numbers
    ['l'] = {
      name = '+line numbers',
      ['r'] = {
        function()
          vim.wo.number = true
          vim.wo.relativenumber = true
        end,
        'relative line numbers',
      },
      ['n'] = {
        function()
          vim.wo.number = true
          vim.wo.relativenumber = false
        end,
        'regular line numbers',
      },
      ['o'] = {
        function()
          vim.wo.number = false
          vim.wo.relativenumber = false
        end,
        'no line numbers',
      },
    },
  },
}, { prefix = '<leader>' })

-- other
u.map('x', 'K', ":move '<-2<CR>gv=gv")
u.map('x', 'J', ":move '>+1<CR>gv=gv")

u.map('n', 'Q', '<nop>')
u.map('n', '-', '<nop>')

u.map('n', '<C-E>', '3<C-E>')
u.map('n', '<C-Y>', '3<C-Y>')

u.map('n', 'j', 'gj')
u.map('n', 'k', 'gk')

wk.register({
  ['c'] = {
    name = '+quickfix',
    ['o'] = { vim.cmd.copen, 'open' },
    ['c'] = { vim.cmd.cclose, 'close' },
  },
}, { prefix = '<leader>' })

wk.register({
  ['s'] = { ":'<,'>!sort<CR>", 'sort' },
  ['ft'] = { ':s/^  /	/<cr>', 'format heredoc' },
}, { mode = 'x', prefix = '<leader>' })

wk.register({
  ['l'] = {
    name = '+linear',
    ['f'] = { ':r !linear_issue_number fix<CR>', 'fixes...' },
    ['n'] = { 'd/##<CR>ONone.<ESC>O<ESC>jo<ESC>k', 'none' },
  },
}, { prefix = '<leader>' })

-- temporary
u.map('n', '<leader>so', vim.cmd.source)
