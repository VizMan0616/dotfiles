local overrides = require "configs.overrides"

return {
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  -- {
  --   "rcarriga/nvim-dap-ui",
  --   dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  --   config = function ()
  --     require("dapui").setup()
  --   end
  -- },
  -- {
  --   "mfussenegger/nvim-dap",
  --   config = function ()
  --     require "configs.dap"
  --   end
  -- },
  -- {
  --   "mfussenegger/nvim-dap-python",
  --   ft = "python",
  --   dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
  --   config = function (_, opts)
  --     local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
  --     require("dap-python").setup(path)
  --   end
  --
  -- },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lint"
    end,
  },
  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
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
        "jsonc",
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
        -- Bash
        "bash",
  		},
  	},
  },
}
