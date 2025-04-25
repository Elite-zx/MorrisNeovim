-- ==============================
-- Search everying in neovim
-- ==============================

local ui = require("utils.icons").ui

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
	local cwd = vim.fn.getcwd()
	vim.ui.input({
		prompt = "Grep files in directory (" .. cwd .. "): ",
		completion = "dir",
	}, function(dir)
		-- 如果没有输入目录，则默认使用当前目录 "."
		if not dir or dir == "" then
			dir = "."
		end

		require("telescope.builtin").grep_string({
			cwd = dir,
			search = "",
			only_sort_text = true,
		})
	end)
end

local function find_files_plus()
	local cwd = vim.fn.getcwd()
	vim.ui.input({
		prompt = "Search files in directory (" .. cwd .. "): ",
		completion = "dir",
	}, function(dir)
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
			{ "<leader>fg", fuzzy_grep, desc = "fuzzy grep under cur dir" },
			{ "<leader>fG", fuzzy_grep_plus, desc = "fuzzy grep under specific dir" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file under cur dir" },
			{ "<leader>fF", find_files_plus, desc = "Find file with specific dir" },
			{ "<leader>fH", "<cmd>Telescope git_files<cr>", desc = "Find file under git repo (home)" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "find symbols in the current buffer" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "find buffer files" },
			{ "<leader>fl", "<cmd>Telescope resume<cr>", desc = "resume last search result" },
		},
		opts = {
			defaults = {
				mappings = {
					i = { -- insert mode
						["<C-h>"] = "which_key",
					},
				},
				prompt_prefix = " " .. ui.Telescope .. " ",
				selection_caret = ui.ChevronRight,
				scroll_strategy = "limit",
				results_title = false,
				layout_strategy = "flex",
				path_display = { "absolute" },
				file_ignore_patterns = {
					".git/",
					".cache",
					"build/",
					"%.class",
					"%.pdf",
					"%.mkv",
					"%.mp4",
					"%.zip",
					"arch2_group_backup_svn_code/",
				},

				layout_config = {
					horizontal = {
						prompt_position = "bottom",
						width = 0.9,
						preview_width = 0.5, -- 在 horizontal 模式下，预览窗口占比
						preview_cutoff = 40, -- 小窗口时隐藏预览
					},
					vertical = {
						mirror = false,
					},
					width = 0.85,
					height = 0.92,
					preview_cutoff = 120,
				},
				vimgrep_arguments = {
					-- default value
					"rg",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",

					"--trim", -- ripgrep remove indentation
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		},
		config = function(_, opts)
			local ts = require("telescope")
			ts.setup(opts)
			ts.load_extension("fzf") -- :h telescope-fzf-native
		end,
	},

	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
}
