local function use_oxlint()
  return vim.fs.find('.oxlintrc.json', {
    path = vim.fn.expand('%:p:h'),
    upward = true,
  })[1] ~= nil
end

return {
  'mfussenegger/nvim-lint',
  enabled = true,
  config = function()
    require('lint').linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
    }

    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = { '*.ts', '*.tsx', '*.js', '*.jsx' },
      callback = function()
        if use_oxlint() then
          require('lint').try_lint('oxlint')
          return
        end

        local file = vim.fn.expand('%:p') -- full path of the file

        -- Traverse upwards to find the nearest .eslintrc.* or package.json
        local function find_eslint_root(path)
          local root_markers = {
            '.eslintrc.js',
            '.eslintrc.json',
            'eslint.config.mjs',
            'package.json',
            '.git',
          }
          local dir = vim.fs.dirname(path)
          while dir do
            for _, marker in ipairs(root_markers) do
              if vim.fn.filereadable(vim.fs.joinpath(dir, marker)) == 1 then
                return dir
              end
            end
            local parent = vim.fs.dirname(dir)
            if parent == dir then
              break
            end -- reached root
            dir = parent
          end
          return nil
        end

        local eslint_root = find_eslint_root(file)
        if not eslint_root then
          print('eslint_d: Could not find ESLint config for ' .. file)
          return
        end
        vim.fn.jobstart({ 'eslint_d', '--fix', file }, {
          cwd = eslint_root,
          stdout_buffered = true,
          -- on_stdout = function(_, data)
          --   if data then
          --     print(table.concat(data, '\n'))
          --   end
          -- end,
          on_stderr = function(_, data)
            if data and #data > 0 then
              local output = table.concat(data, '\n')
              -- Only show meaningful errors (not just empty lines)
              if output:match('%S') then
                print('[eslint_d error] ' .. output)
              end
            end
          end,
          on_exit = function()
            -- Reload buffer from disk
            vim.schedule(function()
              vim.cmd('checktime')
            end)
          end,
        })
      end,
    })
  end,
}
