return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.buildifier,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.lsp.config("pylsp", {
        plugins = {
          black = { enabled = true },
          yapf = { enabled = false },
          pylint = { enabled = true, executable = "pylint" },
          jedi_completion = { fuzzy = true },
        },
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index=false",
          "--header-insertion=never",
          "--enable-config",
          "--offset-encoding=utf-16",
          "--all-scopes-completion",
          "--completion-style=detailed",
          "--function-arg-placeholders=true",
          "--malloc-trim",
          "--pch-storage=disk",
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = "vim",
            },
            formatting = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

      vim.lsp.enable({ "lua_ls", "pylsp", "clangd" })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<leader>gr", require("telescope.builtin").lsp_references, opts)
          vim.keymap.set("n", "<leader>gc", require("telescope.builtin").lsp_incoming_calls, opts)
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.code_action({ apply = true })
          end, opts)
          vim.keymap.set("n", "<leader>ee", vim.diagnostic.open_float, opts)
          vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.buf.format, opts)
          vim.keymap.set("n", "<leader>gh", function()
            for _, win in pairs(vim.api.nvim_list_wins()) do
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                vim.api.nvim_win_close(win, true)
              end
            end
            vim.cmd("LspClangdSwitchSourceHeader")
          end, opts)
          vim.keymap.set("n", "<leader>ci", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "]e", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "]E", vim.diagnostic.goto_prev, opts)
        end,
      })
    end,
  },
}
