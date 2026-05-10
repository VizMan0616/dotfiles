local blame = require('configs.blame')

return {
  -- ========== NvChad Configs ==========
  {
    "stevearc/conform.nvim",
    ft = require('configs.conform').ft,
    opts = require('configs.conform').options,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    opts = require("configs.nvim-tree")
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = require('configs.paths').Filetypes.ForTreesitter,
    },
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("configs.luasnip")
    end
  },

  -- ========== Custom Plugins ========== 
  { 'HiPhish/rainbow-delimiters.nvim' },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = { mode = 'topline', max_lines = 10 },
    -- config = function ()
    --   require('treesitter-context').setup {
    --     enable = true,
    --     zindex = 20,
    --   }
    -- end
  },

  {
    -- LSP progess message with mini notifying format
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
      progress = {
        suppress_on_insert = true, -- suppress new messages while insert
        ignore_done_already = true,
        ignore_empty_message = true,
        ignore = { -- After #a01443a, add function
          function (msg)
            return msg.lsp_client.name == 'lua_ls' and string.find(msg.title, 'Diagnosing')
          end,
        },
      },
      notification = {
        window = {
          max_width = 0, -- disable width limit of message
        }
      },
      logger = {
        level = vim.log.levels.OFF, -- disable logging
      }
    }
  },

  {
    'tzachar/local-highlight.nvim',
    event = 'BufReadPre',
    opts = {
      disable_file_types = {
        'help',
        -- 'dashboard',
        -- 'NeogitStatus',
        'gitcommit',
        'markdown',
      },
      min_match_len = 2,
      highlight_single_match = false,
      animate = {
        enabled = false,
      },
    }
  },

  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    config = require('configs.nvim-ts-autotag'),
  },

  {
    'nmac427/guess-indent.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = require('configs.guess-indent'),
  }
}
