local M = {}

local config_dir = vim.fn.stdpath('config')
local data_dir = vim.fn.stdpath('data')
local cache_dir = vim.fn.stdpath('cache')
local home_dir = vim.fn.expand('$HOME')

M.lsp = {
  ruff = {
    config_path = function ()
      local parent_dir = vim.fn.getcwd()
      local ruff_path = parent_dir .. '/ruff.toml'

      local ruff_file = io.open(ruff_path, 'r')
      if ruff_file ~= nil then
        return ruff_path
      end

      return config_dir .. '/queries/ruff/ruff.toml'
    end,
    cache_dir = cache_dir .. '/.ruff_cache',
    log_path = data_dir .. '/ruff.log'
  },

}

M.Filetypes = {
  ForTreesitter = {
      -- VIM/NeoVIM
      "vim",
      "lua",
      "vimdoc",
      -- Webdev
      "html",
      "css",
      "scss",
      -- JS & TS
      "jsdoc",
      "javascript",
      "typescript",
      -- JSON
      "json",
      -- Graphql
      "graphql",
      -- Python
      "python",
      -- Golang
      "go",
      -- YAML & TOML
      "yaml",
      "toml",
      -- Markdown
      "markdown",
      "markdown_inline",
      -- RST
      "rst",
      -- Lang
      "po",
      -- XML
      "xml",
      --CSV
      "csv",
      -- Shell
      "bash",
      "zsh",
      "powershell",
      -- Other
      "diff",
      "dockerfile"
  },
  -- ForIlluminate = { 'lua', 'json', 'python', 'text', 'markdown' },
  ForCode = { 'lua', 'json', 'python', 'rust' },
}

M.config_dir = config_dir
M.data_dir = data_dir
M.cache_dir = cache_dir
M.home_dir = home_dir

return M
