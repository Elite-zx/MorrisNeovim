return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })() -- Update treesitter parsers
		end,
		dependencies = { "nvim-lua/plenary.nvim", "HiPhish/rainbow-delimiters.nvim" },
		opts = {
			ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
			sync_install = false, -- Install parsers synchronously
			highlight = { enable = true, additional_vim_regex_highlighting = false }, -- Enable syntax highlighting
			indent = { enable = true }, -- Enable indentation
			incremental_selection = { enable = true },
		},
	},

	{ "HiPhish/rainbow-delimiters.nvim", lazy = false },
	{ "nvim-lua/plenary.nvim" },
}
