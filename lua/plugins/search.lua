-- ==============================
-- Search everying in neovim
-- ==============================

local ui = require("utils.icons").ui

local function fuzzy_grep_search(search_fn)
	local cwd = vim.fn.getcwd()
	vim.ui.input({
		prompt = "Grep files in directory (" .. cwd .. "): ",
		completion = "dir",
	}, function(dir)
		-- 如果没有输入目录，则默认使用当前目录 "."
		if not dir or dir == "" then
			dir = "."
		end

		-- 调用传入的搜索函数
		search_fn({ cwd = dir })
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
		event = "BufReadPre",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- Find content with ripGrep among files under current directory
			{ "<leader>ff", "<cmd>FzfLua files<cr>",       desc = "Find file under cur dir" },
			{ "<leader>fF", find_files_plus,               desc = "Find file with specific dir" },
			{ "<leader>fH", "<cmd>FzfLua git_files<cr>",   desc = "Find file under git repo (home)" },

			{ "<leader>fg", "<cmd>FzfLua grep<cr><cr>",    desc = "search for a pattern with rg" },
			{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>",  desc = "search word under cursor" },
			{ "<leader>fv", "<cmd>FzfLua grep_visual<cr>", desc = "search visual selection",          mode = "v" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>",     desc = "find buffer files" },
			{ "<leader>fs", "<cmd>FzfLua treesitter<cr>",  desc = "current buffer treesitter symbols" },
			{ "<leader>fl", "<cmd>FzfLua resume<cr>",      desc = "resume last search result" },
			{
				"<leader>fG",
				function()
					fuzzy_grep_search(require("fzf-lua").grep)
				end,
				desc = "search for a pattern with `grep` or `rg` plus",
			},
			{
				"<leader>fW",
				function()
					fuzzy_grep_search(require("fzf-lua").grep_cword)
				end,
				desc = "search word under cursor plus",
			},
			{
				"<leader>fV",
				function()
					fuzzy_grep_search(require("fzf-lua").grep_visual)
				end,

				desc = "search visual selection plus",
				mode = "v",
			},
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
			winopts = {
				border  = "rounded",
				height  = 1, -- window height
				width   = 0.8, -- window width
				preview = {
					-- Use Neovim builtin previewer (unset default)
					layout     = "vertical",
					vertical   = "down:60%",
					horizontal = "right:60%",
					wrap       = true,
					title      = true,
					scrollbar  = "border",
					title_pos  = "center",
				},
			},
			files = {
				hidden = false,
				find_opts = [[-type f \! -path '*/.git/*' \! -path '*/arch2_group_backup_svn_code/*']],
				rg_opts = [[--color=never --hidden --files -g "!.git" -g "!arch2_group_backup_svn_code"]],
				fd_opts = [[--color=never --type f --hidden --follow --exclude .git --ignore-file ]]
					.. vim.fn.expand("$HOME/.config/nvim/nvim-ignore"),
			},

			git = {
				files = {
					git_icons = false,
					cmd = "git ls-files --exclude-standard",
				},
			},
			previewers = {
				bat = {
					cmd  = "bat",
					args = "--color=always --style=numbers,changes",
				},
			},
			keymap = {
				builtin = {
					["?"]          = "toggle-help",
					["<PageDown>"] = "preview-page-down",
					["<PageUp>"]   = "preview-page-up",
				},
				fzf = {
					["ctrl-j"] = "down",
					["ctrl-k"] = "up",
					["ctrl-f"] = "half-page-down",
					["ctrl-b"] = "half-page-up",
					["alt-g"]  = "first",
					["alt-G"]  = "last",
				},
			},
		},

	},
}
