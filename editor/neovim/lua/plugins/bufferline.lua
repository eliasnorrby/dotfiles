return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      custom_filter = function(buf_number)
        if vim.bo[buf_number].filetype ~= 'fugitive' then
          return true
        end
        if vim.fn.bufname(buf_number) ~= "[No Name]" then
            return true
        end
      end,
    },
  },
}
