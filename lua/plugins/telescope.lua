return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	keys = {
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
	},

	opts = {
		defaults = {
			mappings = {
				i = {
					["<C-h>"] = "which_key",
				},
			},
		},
	},
}
