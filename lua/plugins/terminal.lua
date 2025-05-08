-- ===============
--  operate terminal in neovim
-- ===============

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			size = 10, -- Terminal window size
			open_mapping = [[<C-t>]], -- Shortcut key to toggle terminal
			terminal_mappings = true, -- Enable terminal mappings
			insert_mappings = false, -- Disable insert mode mappings
			autochdir = false, -- Don't change terminal directory automatically
			shade_terminals = true, -- Darker background in terminal
			direction = "float", -- Terminal split mode ("horizontal", "vertical", "float", "tab")
			close_on_exit = true, -- Close terminal on process exit
			float_opts = {
				border = "curved", -- Rounded border
				winblend = 3, -- Transparency
			},
		},

		-- Use `config` only to apply terminal keymaps and fixes
		config = function(_, opts)
			require("toggleterm").setup(opts) -- Load options

			-- Define terminal mode keymaps
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					local keymap_opts = { buffer = 0 }
					vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]], keymap_opts) -- toggle normal mode
					-- vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], keymap_opts)
					-- vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], keymap_opts)
					-- vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], keymap_opts)
					-- vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], keymap_opts)
					-- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], keymap_opts)
				end,
			})

			local function SaveAndExit()
				-- wirte all buffers first
				vim.api.nvim_command(":wa")
				-- close all buffers first
				vim.api.nvim_command(":qa")
			end
			vim.api.nvim_create_user_command("ZZ", SaveAndExit, {})
			-- vim.api.nvim_set_keymap("c", "wqa", "Wqa", { noremap = true, silent = false })
		end,
	},
}
