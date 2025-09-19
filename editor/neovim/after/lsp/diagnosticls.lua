return {
  cmd = { 'diagnostic-languageserver', '--stdio' },
  filetypes = {
    'lua',
    'sh',
    'markdown',
    'json',
    'json5',
    'yaml',
    'toml',
    'dockerfile',
  },
  init_options = {
    linters = {
      shellcheck = {
        command = 'shellcheck',
        debounce = 100,
        args = { '--format', 'json', '-' },
        sourceName = 'shellcheck',
        parseJson = {
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '${message} [${code}]',
          security = 'level',
        },
        securities = {
          error = 'error',
          warning = 'warning',
          info = 'info',
          style = 'hint',
        },
      },
      hadolint = {
        command = 'hadolint',
        debounce = 100,
        args = { '--format', 'json', '-' },
        sourceName = 'Dockerfile',
        parseJson = {
          sourceName = 'file',
          line = 'line',
          column = 'column',
          message = '${message} [${code}]',
          security = 'level',
        },
        securities = {
          error = 'error',
          warning = 'warning',
          info = 'info',
          style = 'hint',
        },
      },
    },
    filetypes = {
      sh = 'shellcheck',
      dockerfile = 'hadolint',
    },
    formatters = {
      shfmt = {
        command = 'shfmt',
        args = { '-filename', 'script.sh' },
      },
      prettier = {
        command = 'prettier',
        args = { '--stdin-filepath', '%filepath' },
      },
    },
    formatFiletypes = {
      sh = 'shfmt',
      json = 'prettier',
      yaml = 'prettier',
      toml = 'prettier',
      markdown = 'prettier',
      lua = 'prettier',
    },
  },
}
