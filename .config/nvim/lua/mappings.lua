require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
-- local opts = { silent = true }

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>te", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Dap Config
-- -- Set Breakpoints 
-- map(
-- 	"n",
-- 	"<leader>dd",
-- 	"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
-- 	{ desc = "Debugger set conditional breakpoint" }
-- )
-- map("n", "<leader>d<space>", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })

-- -- Stepping into breakpoints
-- map("n", "<leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
-- map("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
-- map("n", "<leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })


-- -- Continue or Reset execution
-- map('n', '<leader>dra', "<cmd>lua require'configs.dap.remote_dap'.attach_python_debugger()<CR>", opts)
-- map("n", "<leader>drc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
-- map("n", "<leader>drr", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
-- map("n", "<leader>drl", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- M.dap {
--   plugin = true,
--   n = {
--     ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" }
--   }
-- }
--
-- M.dap_python {
--   plugin = true,
--   n = {
--     ["<leader>dpr"] = { 
--       function ()
--         require("dap-python").test_method()
--       end
--     }
--   }
-- }
