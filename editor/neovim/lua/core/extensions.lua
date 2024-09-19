local M = {}

local function quick_fix_todos()
  vim.fn.jobstart('branch_todos', {
    stdout_buffered = true,
    on_stdout = function(_, data)
      -- Remove trailing empty lines
      local cleaned_data = {}
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(cleaned_data, line)
        end
      end

      if #cleaned_data > 0 then
        vim.fn.setqflist({}, ' ', {
          title = 'TODOs',
          lines = cleaned_data,
        })
        vim.cmd('copen')
      end
    end,
    on_stderr = function(_, data)
      vim.api.nvim_err_writeln(table.concat(data, '\n'))
    end,
  })
end

M.quick_fix_todos = quick_fix_todos

return M
