return {
  'tpope/vim-unimpaired',
  dependencies = { 'afreakk/unimpaired-which-key.nvim' },
  config = function()
    local wk = require('which-key')
    local uwk = require('unimpaired-which-key')
    -- The ]t, [t mappings are overwritten for todo-comments
    if uwk.normal_mode[']'] then
      uwk.normal_mode[']'].t = nil
    end
    if uwk.normal_mode['['] then
      uwk.normal_mode['['].t = nil
    end
    wk.register(uwk.normal_mode)
    wk.register(uwk.normal_and_visual_mode, { mode = { 'n', 'v' } })
  end,
}
