-- ==============================
-- Search everying in neovim
-- ==============================

return {
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- "debugloop/telescope-undo.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
			},
		},
		keys = {
			-- Find content with ripGrep among files under current directory
			-- related: 'Telescope grep_string', Searches for the string under your cursor or selection in your current working director
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fr", "<cmd>Telescope git_files<cr>", desc = "Find file under git repo" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
			{ "<leader>fb", "<cmd>Telescope lsp_document_symbols<cr>", desc = "find tags in the current buffer" },

			-- tags
		},
		opts = {

			defaults = {
				mappings = {
					i = { -- insert mode
						["<C-h>"] = "which_key",
						-- hitting escape enter: exiting instead entering a normal-like mode
						-- ["<esc>"] = require("telescope.actions").close,

						-- ["<C-j>"] = require("telescope.actions").move_selection_next,
						-- ["<C-k>"] = require("telescope.actions").move_selection_previous,
					},
				},
				-- searching window layout
				-- swaps between horizontal and vertical strategies based on the window width
				layout_strategy = "flex",
				layout_config = {
					horizontal = {
						prompt_position = "bottom",
						width = 0.9,
						preview_width = 0.5, -- 在 horizontal 模式下，预览窗口占比
						preview_cutoff = 40, -- 小窗口时隐藏预览
					},
				},
				vimgrep_arguments = {
					-- default value
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",

					"--trim", -- ripgrep remove indentation
				},
			},
			pickers = {
				find_files = {
					mappings = {
						n = { -- normal mode
							-- worked when option autochdir is false
							["cd"] = function(prompt_bufnr)
								local selection = require("telescope.actions.state").get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								require("telescope.actions").close(prompt_bufnr)
								-- change
								-- 1. cd: global
								-- 2. lcd: current window
								-- 3. tcd :current tab
								-- working dir to selected file
								vim.cmd(string.format("silent lcd %s", dir))
							end,
						},
					},
				},
			},
			extensions = {},
		},
		config = function(_, opts)
			local ts = require("telescope")
			ts.setup(opts)
			ts.load_extension("fzf")
		end,
	},
}
