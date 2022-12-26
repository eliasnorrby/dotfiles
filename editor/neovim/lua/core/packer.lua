local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use('wbthomason/packer.nvim')

  use('gpanders/editorconfig.nvim')
  use('tpope/vim-unimpaired')
  use('moll/vim-bbye')

  use({
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    requires = { 'nvim-lua/plenary.nvim' },
  })
  -- pin due to https://github.com/phaazon/hop.nvim/issues/345
  use({ 'phaazon/hop.nvim', commit = 'caaccee' })

  use('nvim-lualine/lualine.nvim')
  use('lewis6991/gitsigns.nvim')

  use({ 'kyazdani42/nvim-tree.lua', requires = { 'nvim-tree/nvim-web-devicons' } })

  use('marko-cerovac/material.nvim')

  use('tpope/vim-fugitive')
  use({
    'junegunn/gv.vim',
    cmd = { 'GV' },
    requires = { 'tpope/vim-fugitive' },
  })

  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  })

  use({
    'kylechui/nvim-surround',
    tag = '*',
    config = function()
      require('nvim-surround').setup()
    end,
  })
  use({
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  })
  use({
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({})
    end,
  })

  use({ -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  })

  use({ -- Autocompletion
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  })

  use('mhartington/formatter.nvim')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
