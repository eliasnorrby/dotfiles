vim.opt_local.number = false
vim.opt_local.relativenumber = false

vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { buffer = true })
