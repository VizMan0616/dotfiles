local M = {}

M.mason = {
  ensure_installed = {
    -- Python
    -- "mypy",
    -- "ruff-lsp",
    "python-lsp-server",
    "ruff",
    "python-lsp-ruff",
    "debugpy",

    -- Lua
    "lua-language-server",
    "stylua",

    -- Basic Web
    "css-lsp",
    "html-lsp",

    -- JavaScript & TypeScript
    "typescript-language-server",
    "prettier",
    "eslint_d",

    -- Golang
    "gopls"
  }
}

M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

return M
