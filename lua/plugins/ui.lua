-- ===============
--  Better UI for neovim
-- ===============
local icons = require("utils.icons")

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
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
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
	},

	{
		"rcarriga/nvim-notify",
		lazy = true,
		event = "VeryLazy",
		opts = {
			---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
			stages = "fade_in_slide_out",
			---@usage Function called when a new window is opened, use for changing win settings/config
			on_open = function(win)
				vim.api.nvim_set_option_value("winblend", 0, { scope = "local", win = win })
				vim.api.nvim_win_set_config(win, { zindex = 90 })
			end,
			---@usage Function called when a window is closed
			on_close = nil,
			---@usage timeout for notifications in ms, default 5000
			timeout = 1000,
			-- @usage User render fps value
			fps = 20,
			-- Render function for notifications. See notify-render()
			render = "default",
			---@usage highlight behind the window for stages that change opacity
			background_colour = "NotifyBackground",
			---@usage minimum width for notification windows
			minimum_width = 50,
			---@usage notifications with level lower than this would be ignored. [ERROR > WARN > INFO > DEBUG > TRACE]
			level = "INFO",
			---@usage Icons for the different levels
			icons = {
				ERROR = icons.diagnostics.Error,
				WARN = icons.diagnostics.Warning,
				INFO = icons.diagnostics.Information,
				DEBUG = icons.ui.Bug,
				TRACE = icons.ui.Pencil,
			},

		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup(opts)
			vim.notify = notify
		end,
	}
}
