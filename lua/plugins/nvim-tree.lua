return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		keys = {
			{ "<leader>nn", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
			{ "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = { -- 在 opts 中提供 NvimTree 设置（lazy.nvim 会自动调用 setup()）
			sort = { sorter = "case_sensitive" },
			view = { width = 30 },
			renderer = { group_empty = true },
			filters = { dotfiles = true },
		},
	},

	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
