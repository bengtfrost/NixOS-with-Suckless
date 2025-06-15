-- ~/Utveckling/NixOS/dotfiles/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup({
            ui = { border = "rounded" },
            -- By default, Mason doesn't install anything unless listed in ensure_installed
            -- or triggered manually. This is good.
          })
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        -- No explicit config = true, we'll call setup in the main lspconfig below
        -- This ensures our custom setup runs after Mason is ready.
      },
      -- ... (cmp dependencies are fine) ...
      { "hrsh7th/nvim-cmp", lazy = true, },
      { "hrsh7th/cmp-nvim-lsp", lazy = true, },
      { "stevearc/conform.nvim", lazy = true, }, -- Conform is a formatter, not LSP directly
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local mason_lspconfig = require("mason-lspconfig") -- Ensure this is required

      local capabilities = cmp_nvim_lsp.default_capabilities()

      local on_attach = function(client, bufnr)
        -- ... (your existing on_attach function is good) ...
        local map = vim.keymap.set
        local opts = { buffer = bufnr, noremap = true, silent = true }
        opts.desc = "Go to Declaration"; map("n", "gD", vim.lsp.buf.declaration, opts)
        opts.desc = "Go to Definition"; map("n", "gd", vim.lsp.buf.definition, opts)
        opts.desc = "Hover Documentation"; map("n", "K", vim.lsp.buf.hover, opts)
        opts.desc = "Go to Implementation"; map("n", "gi", vim.lsp.buf.implementation, opts)
        opts.desc = "Signature Help"; map("n", "<leader>k", vim.lsp.buf.signature_help, opts)
        opts.desc = "Go to Type Definition"; map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        opts.desc = "Rename Symbol"; map("n", "<leader>rn", vim.lsp.buf.rename, opts)
        opts.desc = "Code Action"; map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        opts.desc = "Go to References"; map("n", "gr", vim.lsp.buf.references, opts)
        opts.desc = "Show Line Diagnostics"; map("n", "<leader>e", vim.diagnostic.open_float, opts)
        opts.desc = "Go to Previous Diagnostic"; map("n", "[d", vim.diagnostic.goto_prev, opts)
        opts.desc = "Go to Next Diagnostic"; map("n", "]d", vim.diagnostic.goto_next, opts)
        opts.desc = "Set Diagnostics Loclist"; map("n", "<leader>dq", vim.diagnostic.setloclist, opts)
        if client.supports_method("textDocument/formatting") then
          opts.desc = "LSP Formatting (Disabled)"
          map( { "n", "v" }, "<leader>lf", "<cmd>echo 'Use Conform (<leader>fd)'<CR>", opts )
        end
      end

      -- IMPORTANT: Configure mason-lspconfig to NOT install LSPs.
      -- We want it only to help lspconfig find the system-installed ones.
      mason_lspconfig.setup({
        ensure_installed = {}, -- Empty table: Mason will not install any LSPs.
                               -- LSPs must be in PATH from Nix.
        handlers = {
          -- Default handler: sets up lspconfig with capabilities and on_attach
          function(server_name) -- Default handler
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,

          -- Specific setups if needed (examples from your config)
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim", "require" } },
                  workspace = {
                    library = { vim.fn.expand("$VIMRUNTIME/lua"), vim.fn.stdpath("config") .. "/lua" },
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              },
            })
          end,
          ["zls"] = function()
            lspconfig.zls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              -- cmd = { vim.fn.expand("~/.local/bin/zls") }, -- REMOVE THIS or ensure it points to Nix-managed zls
                                                              -- If zls from pkgs.zls is in PATH, lspconfig finds it.
              root_dir = lspconfig.util.root_pattern("build.zig", ".git"),
              settings = {
                zls = {
                  enable_semantic_tokens = true, warn_style = true, enable_inlay_hints = true,
                },
              },
            })
          end,
          ["ruff_lsp"] = function() -- Newer ruff uses `ruff server`, lspconfig calls it `ruff_lsp` or `ruff`
            lspconfig.ruff_lsp.setup({ -- Or lspconfig.ruff.setup({ ... }) - check LazyVim's default
              capabilities = capabilities,
              on_attach = on_attach,
              -- cmd = {"ruff", "server", "--preview"} -- Ensure command is just 'ruff' if args are for the LSP client
            })
          end,
          -- Ensure you have handlers for pyright, ts_ls, taplo if they need custom setup.
          -- Often, the default handler is enough if the LSP is in PATH.
          ["pyright"] = function() lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach }) end,
          ["tsserver"] = function() -- typescript-language-server often registers as 'tsserver'
            lspconfig.tsserver.setup({ capabilities = capabilities, on_attach = on_attach })
          end,
          ["taplo"] = function() lspconfig.taplo.setup({ capabilities = capabilities, on_attach = on_attach }) end,
          -- Add jsonls, yamlls, marksman, etc. using the default handler if no special config needed
        }
      })
    end,
  },
}
