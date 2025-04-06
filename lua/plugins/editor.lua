-- ==============================
--  Better surround behavior
-- ==============================
local icons = {
	ui = require("utils.icons").get("ui"),
	misc = require("utils.icons").get("misc"),
	git = require("utils.icons").get("git", true),
	cmp = require("utils.icons").get("cmp", true),
}

vim.api.nvim_set_hl(
	0,
	"FlashLabel",
	{ underline = true, bold = true, fg = "Orange", bg = "NONE", ctermfg = "Red", ctermbg = "NONE" }
)

return {
	-- nvim-autoclose
	{
		"m4xshen/autoclose.nvim",
		event = "InsertEnter",
		opts = {},
	},
	-- surround operation
	-- usage, see ":h nvim-surround.usage"
	{
		"kylechui/nvim-surround",
		version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},

	{
		"smoka7/hop.nvim",
		version = "*",
		event = { "CursorHold", "CursorHoldI" },
		keys = {
			{ "<leader><leader>f", "<cmd>HopWord<CR>", desc = "Go to any word in the current buffer" },
		},
		opts = {
			keys = "etovxqpdygfblzhckisuran",
		},
	},

	-- smooth scroll
	{
		"karb94/neoscroll.nvim",
		opts = {},
	},

	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			preset = "classic",
			delay = vim.o.timeoutlen,
			triggers = {
				{ "<auto>", mode = "nixso" },
			},
			plugins = {
				marks = true,
				registers = true,
				spelling = {
					enabled = true,
					suggestions = 20,
				},
				presets = {
					motions = false,
					operators = false,
					text_objects = true,
					windows = true,
					nav = true,
					z = true,
					g = true,
				},
			},
			win = {
				border = "none",
				padding = { 1, 2 },
				wo = { winblend = 0 },
			},
			expand = 1,
			icons = {
				group = "",
				rules = false,
				colors = false,
				breadcrumb = icons.ui.Separator,
				separator = icons.misc.Vbar,
				keys = {
					C = "C-",
					M = "A-",
					S = "S-",
					BS = "<BS> ",
					CR = "<CR> ",
					NL = "<NL> ",
					Esc = "<Esc> ",
					Tab = "<Tab> ",
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					Space = "<Space> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
				},
			},

			spec = {
				{ "<leader>g", group = icons.git.Git .. "Git" },
				{ "<leader>f", group = icons.ui.Telescope .. " Fuzzy Find" },
				{ "<leader>n", group = icons.ui.FolderOpen .. " Neotree" },
				{ "<leader>t", group = icons.cmp.TabNine .. "Tabline" },
			},


		},
	},
	-- navigate code faster
	{
		"folke/flash.nvim",
		lazy = "VeryLazy",
		event = { "CursorHold", "CursorHoldI" },
		keys = {
			{ "<leader>ef", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "F",          mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",          mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",          mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>",      mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
		opts = {
		},
	}
}
