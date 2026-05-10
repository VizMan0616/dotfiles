require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map('n', '<leader>qq', '<cmd>qa<CR>', { desc = "Exit VIM" })
map('n', '<leader>qs', '<cmd>wqa<CR>', { desc = "Exit VIM & save buffer" })

map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- =========== Formatter mappings ==========
-- Only for Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = 'python',
  callback = function ()
    -- This format imports
    map({ 'n', 'x' }, '<leader>fi', function ()
      require('conform').format({
        async = true,
        lsp_fallback = true,
        formatters = { 'ruff_organize_imports' },
      }, function() print('All imports were organized!') end)
    end, { buffer = true, desc = "Organize imports" })

    -- This remove unused imports
    map({ 'n', 'x' }, '<leader>fx', function ()
      require('conform').format({
        async = true,
        lsp_fallback = true,
        formatters = { 'ruff_remove_imports' },
      }, function() print('Unused imports cleaned!') end)
    end, { buffer = true, desc = "Remove unused imports"})

    -- This changes single quotes by double quotes
    map({ 'n', 'x' }, '<leader>fq', function ()
      require('conform').format({
        async = true,
        lsp_fallback = true,
        formatters = { 'ruff_fix_single_quotes' },
      }, function() print('\' now is \"!') end)
    end, { buffer = true, desc = "Fix quote style"})
  end
})

