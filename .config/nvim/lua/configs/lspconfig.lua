local utils = require "utils"
local lspconfig_util = require "lspconfig/util"
local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = nvlsp.on_attach
local on_init = nvlsp.on_init
local capabilities = nvlsp.capabilities

local lspconfig = require "lspconfig"
local default_servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(default_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

local function organize_imports ()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

lspconfig.pylsp.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
  cmd = {
    "docker",
    "run",
    "-i",
    "--rm",
    "-v",
    vim.loop.os_homedir() .. ":" .. vim.loop.os_homedir(),
    utils.get_container_name(),
    "pylsp"
  },
  settings = {
    pylsp = {
      plugins = {
        ruff = { enable = true, formatEnabled = true, },
        pylsp_mypy = { enable = true, ignore_missing_imports = true, }
      }
    },
  },
}

lspconfig.ts_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
  },
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports"
    },
  },
}

lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dit = lspconfig_util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
}

