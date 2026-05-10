require "nvchad.autocmds"

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function (args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client ~= nil and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
})

-- vim.api.nvim_create_autocmd("BufDelete", {
--   callback = function()
--     local bufs = vim.t.bufs
--     if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
--       vim.cmd "Nvdash"
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     require("nvim-tree.api").tree.open()
--   end,
-- })
