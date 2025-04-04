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
		event = "BufWinEnter",
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

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	{
		"karb94/neoscroll.nvim",
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			-- 只跳转到 ERROR 和 WARNING 标签
			{
				"]t",
				function()
					require("todo-comments").jump_next({ keywords = { "HACK", "FIXME", "WARNING", "TODO" } })
				end,
				desc = "Next ERROR/WARNING comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev({ keywords = { "HACK", "FIXME", "WARNING", "TODO" } })
				end,
				desc = "Previous ERROR/WARNING comment",
			},
		},
		opts = {
			signs = false, -- show icons in the signs column
			keywords = {
				FIX = {
					icon = "",
					color = "error",
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
				},
				NOTE = { icon = " ", color = "hint" },
				TODO = { icon = "", color = "info" },
				HACK = { icon = "", color = "warning" },
				WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
			},
			merge_keywords = false, --  custom keywords only
		},
	}
}
