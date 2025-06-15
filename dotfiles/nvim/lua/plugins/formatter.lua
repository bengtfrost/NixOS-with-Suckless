-- ~/Utveckling/NixOS/dotfiles/nvim/lua/plugins/formatter.lua
return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo", "Format" },
		keys = {
			{
				"<leader>fd",
				function()
					require("conform").format({ async = true, lsp_fallback = "always" })
				end,
				mode = { "n", "v" },
				desc = "Format Document/Selection",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" }, -- Ensure pkgs.stylua is in home.packages
				python = { "ruff_format" }, -- ruff_format is part of pkgs.ruff
				-- python = { "ruff_format", "black" }, -- If you want black as a fallback or primary
				javascript = { "prettierd" }, -- Ensure pkgs.prettierd (or pkgs.nodePackages.prettier)
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				toml = { "taplo" }, -- Ensure pkgs.taplo
				markdown = { "prettierd" },
				bash = { "shfmt" }, -- Ensure pkgs.shfmt
				sh = { "shfmt" },
				nix = { "nixpkgs_fmt" }, -- Add pkgs.nixpkgs-fmt to home.packages
				c = { "clang_format" }, -- clang-format is from llvmPackages_XX.clang-tools
				cpp = { "clang_format" },
				rust = { "rustfmt" }, -- rustfmt is from rustup component
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = "always",
			},
			-- You can remove the 'formatters' table if you don't need to pass specific args
			-- to these formatters, as conform.nvim will find them in PATH.
			-- formatters = {
			--   stylua = {},
			--   ruff_format = {},
			--   prettierd = {},
			--   taplo = {},
			--   shfmt = { args = { "-i", "2" } }, -- Example: pass args to shfmt
			-- },
		},
	},
}
