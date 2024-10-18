local function toggle_git_status()
  local windows = vim.api.nvim_list_wins()
  for _, v in pairs(windows) do
    local status, _ = pcall(vim.api.nvim_win_get_var, v, 'fugitive_status')
    if status then
      vim.api.nvim_win_close(v, false)
      return
    end
  end
  vim.cmd([[Git]])
end

return {
  'tpope/vim-fugitive',
  dependencies = { 'tpope/vim-rhubarb' },
  cmd = { 'GBrowse' },
  keys = {
    {
      '<leader>gg',
      toggle_git_status,
      desc = 'Git status',
    },
    {
      'o',
      ":'<,'>GBrowse<CR>",
      desc = 'Open on GitHub',
      mode = 'v',
      silent = true,
    },
    {
      'O',
      ":'<,'>GBrowse!<CR>",
      desc = 'Copy permalink',
      mode = 'v',
      silent = true,
    },
  },
  config = function()
    local wk = require('which-key')
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'Set up fugitive keymap descriptions',
      pattern = 'fugitive',
      group = vim.api.nvim_create_augroup('fugitive_keymap_descriptions', { clear = true }),
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        wk.add({
          {
            buffer = bufnr,
            -- commit
            { 'cc', desc = 'Create a commit' },
            { 'ca', desc = 'Amend last commit (edit message)' },
            { 'ce', desc = 'Amend last commit (no edit)' },
            { 'cw', desc = 'Reword last commit' },
            { 'cvc', desc = 'Create a commit with -v' },
            { 'cva', desc = 'Amend last commit with -v' },
            { 'cf', desc = 'Fixup! commit' },
            { 'cF', desc = 'Fixup! commit and rebase' },
            { 'cs', desc = 'Squash! commit' },
            { 'cS', desc = 'Squash! commit and rebase' },
            { 'cA', desc = 'Squash! commit and edit message' },
            { 'c<Space>', desc = 'Git commit command' },
            { 'crc', desc = 'Revert commit' },
            { 'crn', desc = 'Revert commit (no commit)' },
            { 'cr<Space>', desc = 'Git revert command' },
            { 'cm<Space>', desc = 'Git merge command' },
            { 'c?', desc = 'Show commit help' },
            -- rebase
            { 'ri', desc = 'Interactive rebase' },
            { 'rf', desc = 'Autosquash rebase' },
            { 'ru', desc = 'Rebase against @{upstream}' },
            { 'rp', desc = 'Rebase against @{push}' },
            { 'rr', desc = 'Continue rebase' },
            { 'rs', desc = 'Skip commit and continue rebase' },
            { 'ra', desc = 'Abort rebase' },
            { 're', desc = 'Edit rebase todo' },
            { 'rw', desc = 'Rebase: reword commit' },
            { 'rm', desc = 'Rebase: edit commit' },
            { 'rd', desc = 'Rebase: drop commit' },
            { 'r<Space>', desc = 'Git rebase command' },
            { 'r?', desc = 'Show rebase help' },
            -- stash
            { 'cz', group = '+stash' },
            { 'czz', desc = 'Push stash' },
            { 'czw', desc = 'Push work-tree stash' },
            { 'czs', desc = 'Push stage stash' },
            { 'czA', desc = 'Apply stash' },
            { 'cza', desc = 'Apply stash (preserve index)' },
            { 'czP', desc = 'Pop stash' },
            { 'czp', desc = 'Pop stash (preserve index)' },
            { 'cz<Space>', desc = 'Git stash command' },
            { 'cz?', desc = 'Show stash help' },
          },
        })
      end,
    })
  end,
}
