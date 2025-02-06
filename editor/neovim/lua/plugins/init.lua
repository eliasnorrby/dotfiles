---@type LazySpec
return {
  'gpanders/editorconfig.nvim',
  'tpope/vim-abolish',
  'godlygeek/tabular',
  { 'numToStr/Comment.nvim', config = true },
  {
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = { 'tpope/vim-fugitive' },
  },
  { 'echasnovski/mini.ai', version = '*', config = true },
  {
    'kylechui/nvim-surround',
    version = '*',
    config = true,
  },
}
