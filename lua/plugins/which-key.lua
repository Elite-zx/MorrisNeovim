return {
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			delay = 1000, -- Delay before popup appears (1000ms = 1s)
		},
	},
}
