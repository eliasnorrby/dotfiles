vim.cmd([[
command! -nargs=0 XMLFormat :%!xmllint --encode UTF-8 --format -
]])
