return {
  'rhysd/git-messenger.vim',
  config = function()
    vim.cmd([[
      let g:git_messenger_floating_win_opts = { 'border': 'single' }
      let g:git_messenger_popup_content_margins = v:false
    ]])
  end,
}
