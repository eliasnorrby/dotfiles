return {
  'tpope/vim-fugitive',
  dependencies = { 'tpope/vim-rhubarb' },
  init = function()
    local wk = require('which-key')

    wk.register({
      ['o'] = { ":'<,'>GBrowse<CR>", 'Open on GitHub' },
      ['O'] = { ":'<,'>GBrowse!<CR>", 'Copy permalink' },
    }, { mode = 'v' })
  end,
}
