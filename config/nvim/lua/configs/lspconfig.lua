require("nvchad.configs.lspconfig").defaults()

local paths = require('configs.paths')
local utils = require('utils')


-- function copied from: https://github.com/Jaehaks/nvim_config/blob/main/lua/jaehak/core/lsp.lua#L52-L102
local function get_lsp_capabilities(override, include_nvim_defaults)
  return vim.tbl_deep_extend('force', include_nvim_defaults and vim.lsp.make_client_capabilities() or {}, {
    general = {
      positionEncodings = { 'utf-16' }
    },
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false,
          documentationFormat = { 'markdown', 'plaintext' },
          deprecatedSupport = true,
          preselectSupport = false,
          tagSupport = { valueSet = { 1 } }, -- deprecated
          insertReplaceSupport = true,
          resolveSupport = {
            properties = {
              'documentation',
              'detail',
              'additionalTextEdits',
              'command',
              'data',
            },
          },
          insertTextModeSupport = { valueSet = { 1 } },
          labelDetailsSupport = true,
          completionList = {
            itemDefaults = {
              'commitCharacters',
              'editRange',
              'insertTextFormat',
              'insertTextMode',
              'data',
            },
          },

          contextSupport = true,
          insertTextMode = 1,
        },
      },
  },
}, override or {})
end

local function get_python_runtime(odoo_version)
  local workspace = vim.fn.getcwd()

  local is_running, _ = utils.check_if_odoo_container_is_running()
  if not is_running then
    return {
      ruff = { 'ruff', 'server' },
      basedpyright = {
        cmd = { 'basedpyright-langserver', '--stdio' },
        analysis = { typeCheckingMode = 'standard' }
      },
      pyrefly = { 'pyrefly', 'lsp' },
      -- odoo_ls = {
      --   paths.home_dir .. '/.local/share/nvim/lazy/odoo-neovim/odoo/odoo_ls_server',
      --   '--config-path', workspace .. '/odools.toml',
      --   '--stdlib', paths.home_dir .. '/.local/share/nvim/lazy/odoo-neovim/odoo/typeshed/stdlib',
      -- },
    }
  end

  local image_exist, _ = utils.check_if_odoo_development_image_exists(odoo_version)
  if not image_exist then
    utils.build_odoo_development_image(odoo_version)
  end

  -- utils.run_odoo_development_image(odoo_version, workspace)

  return {
    ruff = {
      'docker',
      'run',
      '-i',
      '--rm',
      '-v',
      workspace .. ':' .. workspace,
      'odoo-' .. odoo_version .. '-development:latest',
      'ruff',
      'server'
    },
    basedpyright = {
      cmd = {
        'docker',
        'run',
        '-i',
        '--rm',
        '-v',
        workspace .. ':' .. workspace,
        'odoo-' .. odoo_version .. '-development:latest',
        'basedpyright-langserver',
        '--stdio'
      },
      analysis = { typeCheckingMode = 'off' },
    },
    pyrefly = {
      'docker',
      'run',
      '-i',
      '--rm',
      '-v',
      workspace .. ':' .. workspace,
      'odoo-' .. odoo_version .. '-development:latest',
      'pyrefly',
      'lsp'
    },
    -- odoo_ls = {
    --   'docker',
    --   'run',
    --   '-i',
    --   '--rm',
    --   '-v',
    --   workspace .. ':' .. workspace,
    --   'odoo-' .. odoo_version .. '-development:latest',
    --   '/mnt/odoo_lsp/odoo_ls_server',
    --   '--config-path', workspace .. '/odools.toml',
    --   '--stdlib', '/mnt/odoo_lsp/typeshed/stdlib',
    -- }
  }
end

local capabilities = get_lsp_capabilities()
local ruff_config = paths.lsp.ruff.config_path()
local python_runtime = get_python_runtime("17")

-- language root dirs
local root_dir_lua = function(bufnr, cb)
  local root = vim.fs.root(bufnr, {
    'luarc.json',
    '.luarc.json',
    '.git'
  }) or vim.fn.expand('%:p:h')
  cb(root)
end

local root_dir_python = function(bufnr, cb)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if string.match(bufname, 'site%-packages') or string.match(bufname, '[\\/][Ll]ib[\\/]') then
    return
  end

  local root = vim.fs.root(bufnr, {
    'pyproject.toml',
    'pyrightconfig.json',
    'ruff.toml',
    '.ruff.toml',
    'pyrefly.toml',
    '.git'
  }) or vim.fn.expand('%:p:h')
  cb(root)
end

-- local root_dir_rust = function(bufnr, cb)
--   local bufname = vim.api.nvim
-- end

vim.diagnostic.config({ virtual_text = false })

-- vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
--   callback = set_language_color_column
-- })

-- Global configuration
vim.lsp.config('*', {
  root_dir = function (bufnr, cb)
    local root = vim.fs.root(bufnr, {'.git'}) or vim.fn.expand('%:p:h')
    cb(root)
  end,
  capabilities = capabilities
})

vim.lsp.config('lua_ls', {
  cmd = {'lua-language-server'},
  fileypes = {'lua'},
  root_dir = root_dir_lua,
  settings = {
    Lua = {
      completion = {
        -- callSnippet = 'Replace',
        showWord = 'Disable'
      },
      diagnostics = {
        disable = {
          'missing-parameter',
          'missing-fields',
          'unused-function'
        },
        globals = {'vim'},
        undefined_global = false,
      },
      workspace = {
        ignoreDir = {'.git'},
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.api.nvim_get_runtime_file('lua', true),
        }
      },
    },
    single_file_support = false,
  }
})

vim.lsp.config('ruff', {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = python_runtime.ruff,
  filetypes = {'python'},
  root_dir = root_dir_python,
  on_attach = function (client, _)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.hoverProvider = false
  end,
  init_options = {
    settings = {
      configuration = ruff_config,
      logFile = paths.lsp.ruff.log_path,
      logLevel = 'warn',
      organizeImports = true,
      showSyntaxErrors = true,
      codeAction = {
        disableRuleComment = { enable = false },
        fixViolation = { enable = false },
      },
      format = { preview = false },
      lint = { enable = true },
    },
  },
  single_file_support = false,
})

vim.lsp.config("basedpyright", {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = python_runtime.basedpyright.cmd,
  filetypes = { 'python' },
  root_dir = root_dir_python,
  on_attach = function(client, _)
    client.server_capabilities.completionProvider        = false
    client.server_capabilities.definitionProvider        = false
    client.server_capabilities.documentHighlightProvider = false
    client.server_capabilities.renameProvider            = false
    client.server_capabilities.semanticTokensProvider    = false
  end,
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = python_runtime.basedpyright.analysis.typeCheckingMode,
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = false,
          genericTypes = false,
        },
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticsMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        diagnosticServerityOverrides = {
          reportUnknownMeberType = 'none',
          reportUnusedCallResult = 'none',
        },
        exclude = {
          '**/.venv',
          '**/venv',
          '**/__pycache__',
          '**/dist',
          '**/build',
        }
      }
    },
  },
})

vim.lsp.config('pyrefly', {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = python_runtime.pyrefly,
  -- cmd = { "pyrefly", "lsp" },
  filetypes = { 'python' },
  root_dir = root_dir_python,
  on_attach = function(client, _)
    client.server_capabilities.codeActionProvider     = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.hoverProvider          = false
    client.server_capabilities.inlayHintProvider      = false
    client.server_capabilities.referenceProvider      = false
    client.server_capabilities.signatureHelpProvider  = false
  end,
  settings = {}
})

-- Commented until I figure out what's wrong
-- vim.lsp.config('odoo_ls', {
--   before_init = function(params)
--     params.processId = vim.NIL
--   end,
--   cmd = python_runtime.odoo_ls,
--   filetypes = { 'python', 'xml' },
-- })

vim.lsp.config('json_lsp', {
  cmd = {'vscode-json-language-server', '--stdio'},
  filetypes = {'json', 'jsonc'},
  init_options = {
    provideFormatter = true,
  },
})

vim.lsp.config('rust-analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' }
})

local servers = {
  "html",
  "cssls",
  'lua_ls',
  "ruff",
  'basedpyright',
  'pyrefly',
  -- 'odoo_ls',
  'json_lsp',
  'rust-analyzer'
}
vim.lsp.enable(servers)
