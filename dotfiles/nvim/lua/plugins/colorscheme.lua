-- ~/Utveckling/NixOS/dotfiles/nvim/lua/plugins/colorscheme.lua
-- Using EdenEast/nightfox.nvim with the 'carbonfox' style

return {
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox", -- Optional: a name for LazyVim
		lazy = false, -- Load this theme immediately on startup
		priority = 1000, -- Ensure it loads early
		config = function()
			-- Available options:
			-- nightfox, dayfox, dawnfox, nordfox,
			-- carbonfox, terafox, duskfox, anuvadfox
			local style = "carbonfox" -- Set your desired style here

			-- You can also set a global variable before loading if preferred by some old configs,
			-- but require('nightfox').setup() is the modern way.
			-- vim.g.nightfox_style = style

			require("nightfox").setup({
				options = {
					-- Transparent background
					-- transparent = false,
					-- Italics
					-- styles = {
					--   comments = "italic",
					--   keywords = "italic",
					--   functions = "italic",
					--   variables = "italic",
					-- },
					-- For more customization, see :help nightfox-options
				},
				palettes = {}, -- You can override specific colors here
				specs = {}, -- You can override highlight groups here
				groups = {}, -- You can override full highlight groups here (advanced)
			})

			-- Apply the colorscheme
			vim.cmd("colorscheme " .. style)
		end,
	},
}
