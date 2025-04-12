-- ==============================
--  Better surround behavior
-- ==============================
local icons = {
	ui = require("utils.icons").get("ui"),
	misc = require("utils.icons").get("misc"),
	git = require("utils.icons").get("git", true),
	cmp = require("utils.icons").get("cmp", true),
	dap = require("utils.icons").get("dap", true),
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

	-- smooth scroll
	{
		"karb94/neoscroll.nvim",
		opts = {},
	},

	{
		"ibhagwan/smartyank.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			highlight = {
				enabled = true, -- highlight yanked text
				higroup = "IncSearch", -- highlight group of yanked text
				timeout = 300, -- timeout for clearing the highlight
			},
			clipboard = {
				enabled = true,
			},
			tmux = {
				enabled = true,
				-- remove `-w` to disable copy to host client's clipboard
				cmd = { "tmux", "set-buffer", "-w" },
			},
			osc52 = {
				enabled = true,
				escseq = "tmux", -- use tmux escape sequence, only enable if you're using remote tmux and have issues (see #4)
				ssh_only = true, -- false to OSC52 yank also in local sessions
				silent = false, -- true to disable the "n chars copied" echo
				echo_hl = "Directory", -- highlight group of the OSC52 echo message
			},
		},
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
				{ "<leader>l", group = icons.ui.List .. " List" },
				{ "<leader>t", group = icons.cmp.TabNine .. "Tabline" },
				{ "<leader>e", group = icons.dap.StepOver .. "EasyMotion (flash)" },
			},
		},
	},

	-- FIXME:  label as search content error
	-- navigate code faster
	{
		"folke/flash.nvim",
		lazy = "VeryLazy",
		event = { "CursorHold", "CursorHoldI" },
		keys = {
			{
				"<leader>ef",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"<leader>eF",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"<leader>er",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"<leader>eR",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
}
