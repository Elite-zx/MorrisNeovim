return {
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			auto_attach = true,
			sign_priority = 6,
			update_debounce = 100,
			word_diff = false,
			current_line_blame = true,
			diff_opts = { internal = true },
			watch_gitdir = { follow_files = true },
			current_line_blame_opts = { delay = 1000, virt_text = true, virtual_text_pos = "eol" },
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- ]g --> next_hunk
				map("n", "]g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]g", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "git: Goto next hunk" })

				-- [g --> prev_hunk
				map("n", "[g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[g", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "git: Goto prev hunk" })

				map(
					"n",
					"<leader>gs",
					"<cmd>Gitsigns stage_hunk<CR>",
					{ desc = "git: Toggle staging/unstaging of hunk" }
				)

				map("v", "<leader>gs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "git: Toggle staging/unstaging of selected hunk" })

				map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "git: Stage buffer" })

				map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "git: Reset hunk" })
				map("v", "<leader>gr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "git: Reset hunk" })
				map("n", "<leader>gb", function()
					gitsigns.blame_line({ full = true })
				end)
				map({ "o", "x" }, "ih", " <Cmd>Gitsigns select_hunk<CR> ", { desc = "git: select hunk" })
			end,
		},
	},

	{
		"sindrets/diffview.nvim",
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "git: Show diff" },
			{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "git: Close diff" },
		},
		opt = {
			diff_binaries = false, -- Show diffs for binaries
			enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
			git_cmd = { "git" }, -- The git executable followed by default args.
			hg_cmd = { "hg" }, -- The hg executable followed by default args.
			use_icons = true, -- Requires nvim-web-devicons
			show_help_hints = true, -- Show hints for how to open the help panel
			watch_index = true, -- Update views and index buffers when the git index changes.
		},
	},
}
