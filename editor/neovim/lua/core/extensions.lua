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

function M.yank_ts_reference()
  local node = vim.treesitter.get_node()

  if not node then
    vim.notify('No treesitter node found', vim.log.levels.WARN)
    return
  end

  local class_name = nil
  local method_name = nil

  local current = node
  while current do
    local type = current:type()

    if type == 'method_definition' then
      if not method_name then
        local name_node = current:field('name')[1]
        if name_node then
          method_name = vim.treesitter.get_node_text(name_node, 0)
        end
      end
    elseif type == 'class_declaration' then
      if not class_name then
        local name_node = current:field('name')[1]
        if name_node then
          class_name = vim.treesitter.get_node_text(name_node, 0)
        end
      end
    end

    if class_name and method_name then
      break
    end

    current = current:parent()
  end

  local result = nil
  if class_name and method_name then
    result = class_name .. '#' .. method_name
  elseif class_name then
    result = class_name
  elseif method_name then
    result = method_name
  end

  if result then
    vim.fn.setreg('+', result)
    vim.notify('Copied: ' .. result, vim.log.levels.INFO)
  else
    vim.notify('No class or method found', vim.log.levels.WARN)
  end
end

return M
