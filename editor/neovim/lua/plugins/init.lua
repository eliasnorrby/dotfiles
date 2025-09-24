---@type LazySpec
return {
  'gpanders/editorconfig.nvim',
  'tpope/vim-abolish',
  'godlygeek/tabular',
  'tpope/vim-commentary',
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
  { 'windwp/nvim-ts-autotag', config = true },
}
