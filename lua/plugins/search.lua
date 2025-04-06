-- ==============================
-- Search everying in neovim
-- ==============================

local ok_actions, actions = pcall(require, "telescope.actions")
if not ok_actions then
	actions = {
		close = function() end,
		to_fuzzy_refine = function() end,
	}
end

local function fuzzy_grep()
	require("telescope.builtin").grep_string({ search = "", only_sort_text = true })
end

local function fuzzy_grep_plus()
	vim.ui.input({ prompt = "Grep files in directory: ", completion = "dir" }, function(dir)
		-- 如果没有输入目录，则默认使用当前目录 "."
		if not dir or dir == "" then
			dir = "."
		end
		require("telescope.builtin").grep_string({
			cwd = dir,
			search = "",
			only_sort_text = true
		})
	end)
end

local function find_files_plus()
	vim.ui.input({ prompt = "Search files in directory: ", completion = "dir" }, function(dir)
		-- 如果没有输入目录，则默认使用当前目录 "."
		if not dir or dir == "" then
			dir = "."
		end

		require("telescope.builtin").find_files({
			cwd = dir,
			hidden = true,
		})
	end)
end

return {
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
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
			{ "<leader>fr", fuzzy_grep,                                desc = "fuzzy grep under cur dir" },
			{ "<leader>fR", fuzzy_grep_plus,                           desc = "fuzzy grep under specific dir" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>",           desc = "Find file under cur dir" },
			{ "<leader>fF", find_files_plus,                           desc = "Find file with specific dir" },
			{ "<leader>fG", "<cmd>Telescope git_files<cr>",            desc = "Find file under git repo" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "find symbols in the current buffer" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>",              desc = "find symbols in the current buffer" },
			{ "<leader>fl", "<cmd>Telescope resume<cr>",               desc = "resume last search result" },
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
								actions.close(prompt_bufnr)
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
				live_grep = {
					mappings = {
						i = { ["<c-f>"] = actions.to_fuzzy_refine }, -- switch live_grep to fuzzy mode
					},
				},
			},
			extensions = {},
		},
		config = function(_, opts)
			local ts = require("telescope")
			ts.setup(opts)
			ts.load_extension("fzf") -- :h telescope-fzf-native
		end,
	},
}
