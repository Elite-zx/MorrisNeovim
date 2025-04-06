local settings = require("utils.settings")

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		event = "BufReadPre",
		build = ":TSUpdate",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"HiPhish/rainbow-delimiters.nvim",
			"nvim-treesitter/nvim-treesitter-textobjects"
		},
		opts = {
			ensure_installed = settings["treesitter_deps"],
			sync_install = false, -- Install parsers synchronously
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},                 -- Enable syntax highlighting
			indent = { enable = true }, -- Enable indentation
			matchup = { enable = true },
			incremental_selection = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					vim.cmd("TSBufEnable highlight")
				end,
			})
		end,
	},

	{ "HiPhish/rainbow-delimiters.nvim", lazy = false },
	{ "nvim-lua/plenary.nvim" },
}
