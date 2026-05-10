local config_dir = require('configs.paths').config_dir

require("luasnip.loaders.from_vscode").lazy_load({ paths = { config_dir .. '/snippets/vscode' } })
