local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local lint = require("lint")
local eslint = lint.linters.eslint_d

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
}

eslint.args = {
  "--no-warn-ignored",
  "--format",
  "json",
  "--stdin",
  "--stdin-filename",
  function()
    return vim.api.nvim_buf_get_name(0)
  end,
}

local lint_augroup = augroup("lint", { clear = true, })
autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end
})

