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
				local gitsigns = require('gitsigns')
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- ]g --> next_hunk
				map('n', ']g', function()
					if vim.wo.diff then
						vim.cmd.normal({ ']g', bang = true })
					else
						gitsigns.nav_hunk('next')
					end
				end, { desc = "git: Goto next hunk" })

				-- [g --> prev_hunk
				map('n', '[g', function()
					if vim.wo.diff then
						vim.cmd.normal({ '[g', bang = true })
					else
						gitsigns.nav_hunk('prev')
					end
				end, { desc = "git: Goto prev hunk" })

				map('n', '<leader>gs', function()
					gitsigns.stage_hunk()
				end, { desc = "git: Toggle staging/unstaging of hunk" })

				map('v', '<leader>gs', function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "git: Toggle staging/unstaging of selected hunk" })

				map('n', '<leader>gb',
					function()
						gitsigns.blame_line({ full = true })
					end, { desc = "git: Blame line" }
				)
				map({ 'o', 'x' }, 'ih', " <Cmd>Gitsigns select_hunk<CR> ", { desc = "git: select hunk" }
				)
			end
		},
	},

	-- {
	-- 	"NeogitOrg/neogit",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim", -- required
	-- 		"sindrets/diffview.nvim", -- optional - Diff integration
	-- 		"nvim-telescope/telescope.nvim", -- optional
	-- 	},
	-- 	config = true
	-- }


}
