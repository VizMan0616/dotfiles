require "nvchad.options"

-- local opt = vim.opt
local wo  = vim.wo
local o = vim.o
-- local g = vim.g

o.number = true
wo.relativenumber = true

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false
  }
)
-- vim.diagnostic.config({ virtual_text = false })
