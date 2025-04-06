-- ==============================
--  Better surround behavior
-- ==============================
return {
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			delay = 1000, -- Delay before popup appears (1000ms = 1s)
		},
	},
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

}
