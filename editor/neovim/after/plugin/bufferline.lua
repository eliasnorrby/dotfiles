require('bufferline').setup({
  options = {
    custom_filter = function(buf_number)
      if vim.bo[buf_number].filetype ~= 'fugitive' then
        return true
      end
    end,
  },
})
