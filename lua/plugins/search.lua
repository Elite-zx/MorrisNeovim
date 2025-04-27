-- ==============================
-- Search everying in neovim
-- ==============================

local ui = require("utils.icons").ui

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

		require("fzf-lua").live_grep({
			cwd = dir,
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

		require("fzf-lua").files({
			cwd = dir,
		})
	end)
end

return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- Find content with ripGrep among files under current directory
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find file under cur dir" },
			{ "<leader>fF", find_files_plus, desc = "Find file with specific dir" },
			{ "<leader>fH", "<cmd>FzfLua git_files<cr>", desc = "Find file under git repo (home)" },

			{ "<leader>fgg", "<cmd>FzfLua live_grep<cr>", desc = "search for a pattern with `grep` or `rg`" },
			{ "<leader>fgG", fuzzy_grep_plus, desc = "search for a pattern with `grep` or `rg`" },
			{ "<leader>fgc", "<cmd>FzfLua grep_cword<cr>", desc = "search word under cursor" },
			{ "<leader>fgv", "<cmd>FzfLua grep_visual<cr>", desc = "search visual selection" },

			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "find buffer files" },
			{ "<leader>fs", "<cmd>FzfLua treesitter<cr>", desc = "current buffer treesitter symbols" },
			{ "<leader>fl", "<cmd>FzfLua resume<cr>", desc = "resume last search result" },
		},
		opts = {
			fzf_opts = {
				["--ansi"] = true,
				["--info"] = "inline-right",
				["--height"] = "100%",
				["--layout"] = "default",
				["--border"] = "none",
				["--highlight-line"] = true,
			},
			keymap = {},
		},
	},
}
