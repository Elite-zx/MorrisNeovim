-- ===============
--  Better UI for neovim
-- ===============

return {
	-- colorscheme
	{
		"Mofiqul/dracula.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			vim.cmd.colorscheme("dracula")
		end,
	},
	-- startup screen
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local startify = require("alpha.themes.startify")
			-- available: devicons, mini, default is mini
			-- if provider not loaded and enabled is true, it will try to use another provider
			startify.file_icons.provider = "devicons"
			return startify.config
		end,
	},
	-- nvim-lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = { theme = "dracula-nvim" },
		},
	},
}
