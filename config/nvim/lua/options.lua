require "nvchad.options"

local wo = vim.wo
local o = vim.o
local opt = vim.opt

vim.api.nvim_create_augroup("UserSettings_OPTION", { clear = true })

o.number = true
wo.relativenumber = true

-- opts
opt.list = true
opt.listchars = {
  tab = '»·',
  space = '·',
  trail = '·'
}
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true

-- vim.api.nvim_set_hl(0, 'NvimTreeGitIgnored', { fg = '#bf616a', bg = '#d8dee9' })

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
