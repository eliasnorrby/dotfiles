return {
  'tpope/vim-unimpaired',
  dependencies = { 'afreakk/unimpaired-which-key.nvim' },
  config = function()
    local wk = require('which-key')
    local uwk = require('unimpaired-which-key')
    wk.register(uwk.normal_mode)
    wk.register(uwk.normal_and_visual_mode, { mode = { 'n', 'v' } })
  end,
}
