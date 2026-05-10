local paths = require('configs.paths')
local M = {}

-- vim.notify(paths.lsp.ruff.config_path())

M.ft = paths.Filetypes.ForCode

M.options = {
  formatters = {
    stylua = {},
    ruff = {
      command = 'ruff',
      args = {
        'format',
        '--config=' .. paths.lsp.ruff.config_path(),
        '--force-exclude',
        '--stdin-filename',
        '$FILENAME',
        '-'
      },
      stdin = true,
    },
    ruff_remove_imports = {
      command = 'ruff',
      args = {
        "check",
        "--fix",
        "--select",
        "F401",
        "--stdin-filename",
        "$FILENAME",
        "-"
      },
      stdin = true,
    },
    ruff_fix_single_quotes = {
      command = 'ruff',
      args = {
        "check",
        "--fix",
        "--select",
        "Q000",
        "--stdin-filename",
        "$FILENAME",
        "-"
      },
      stdin = true,
    }
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff', 'ruff_remove_imports', 'ruff_fix_single_quotes' },
    -- ["*"] = { "codespell" },       -- on all filetypes
  },
  format_on_save = nil,
  format_after_save = nil
}

return M
