return {
  'jackMort/ChatGPT.nvim',
  enabled = false,
  lazy = true,
  opts = {
    api_key_cmd = 'op read op://work/OpenAI_ChatGPT_nvim_key/credential --no-newline',
  },
  keys = {
    { '<leader>agc', '<cmd>ChatGPT<CR>', desc = 'ChatGPT' },
    { '<leader>age', '<cmd>ChatGPTEditWithInstruction<CR>', desc = 'Edit with instruction', mode = { 'n', 'v' } },
    { '<leader>agg', '<cmd>ChatGPTRun grammar_correction<CR>', desc = 'Grammar Correction', mode = { 'n', 'v' } },
    { '<leader>agt', '<cmd>ChatGPTRun translate<CR>', desc = 'Translate', mode = { 'n', 'v' } },
    { '<leader>agk', '<cmd>ChatGPTRun keywords<CR>', desc = 'Keywords', mode = { 'n', 'v' } },
    { '<leader>agd', '<cmd>ChatGPTRun docstring<CR>', desc = 'Docstring', mode = { 'n', 'v' } },
    { '<leader>aga', '<cmd>ChatGPTRun add_tests<CR>', desc = 'Add Tests', mode = { 'n', 'v' } },
    { '<leader>ago', '<cmd>ChatGPTRun optimize_code<CR>', desc = 'Optimize Code', mode = { 'n', 'v' } },
    { '<leader>ags', '<cmd>ChatGPTRun summarize<CR>', desc = 'Summarize', mode = { 'n', 'v' } },
    { '<leader>agf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = 'Fix Bugs', mode = { 'n', 'v' } },
    { '<leader>agx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'Explain Code', mode = { 'n', 'v' } },
    { '<leader>agr', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = 'Roxygen Edit', mode = { 'n', 'v' } },
    {
      '<leader>agl',
      '<cmd>ChatGPTRun code_readability_analysis<CR>',
      desc = 'Code Readability Analysis',
      mode = { 'n', 'v' },
    },
  },
  init = function()
    require('which-key').add({
      { '<leader>a', group = '+ai' },
      { '<leader>ag', group = '+chatgpt' },
    })
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    -- TODO: Why is this a dependency?
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
