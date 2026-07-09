return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ts_ls",
          "lua_ls",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim" },
    config = function()

      -- Python
      vim.lsp.config("pyright", {
        filetypes = { "python" },
      })

      -- TypeScript/JavaScript
      vim.lsp.config("ts_ls", {
        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      })

      -- Lua
      vim.lsp.config("lua_ls", {
        filetypes = { "lua" },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      vim.lsp.enable({ "pyright", "ts_ls", "lua_ls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
}
