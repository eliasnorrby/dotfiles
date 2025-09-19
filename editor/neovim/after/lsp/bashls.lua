return {
  cmd_env = {
    -- lsp-config defaults will disable recursive scanning
    GLOB_PATTERN = '**/*@(.sh|.inc|.bash|.command)',
  },
  root_dir = function(fname)
    -- lsp-config will use util.path.dirname, which will be the directory
    -- containing the file - we won't scan anything in parent directories.
    return require('lspconfig').util.root_pattern('.git')(fname) or vim.fs.dirname(fname)
  end,
}
