vim.cmd([[
augroup packer_user_config
  autocmd!
  autocmd BufWritePost packer_init.lua source <afile> | PackerCompile
augroup end
]])
