return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		event = "BufReadPre",
		build = ":TSUpdate",
		dependencies = { "nvim-lua/plenary.nvim", "HiPhish/rainbow-delimiters.nvim" },
		opts = {
			ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query" },
			sync_install = false,                               -- Install parsers synchronously
			highlight = {
				enable = true, additional_vim_regex_highlighting = false }, -- Enable syntax highlighting
			indent = { enable = true },                         -- Enable indentation
			incremental_selection = { enable = true },
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
