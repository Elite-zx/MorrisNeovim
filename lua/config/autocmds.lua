local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local basic_auto_cmds = vim.api.nvim_create_augroup("BasicAutoCmds", { clear = true })

-- =============================================
-- basic autocmd
-- =============================================
-- Highlight the current line except in insert mode
autocmd({ "InsertLeave", "WinEnter" }, {
	group = basic_auto_cmds,
	pattern = "*",
	command = "set cursorline",
})
autocmd({ "InsertEnter", "WinLeave" }, {
	group = basic_auto_cmds,
	pattern = "*",
	command = "set nocursorline",
})

-- Automatically resize all split windows equally when Neovim window is resized
autocmd("VimResized", {
	group = basic_auto_cmds,
	pattern = "*",
	command = "wincmd =",
})

-- Restore cursor to last known position when reopening a file
autocmd("BufWinEnter", {
	group = basic_auto_cmds,
	pattern = "*",
	callback = function()
		local last_pos = vim.fn.line("'\"")
		if last_pos > 0 and last_pos <= vim.fn.line("$") then
			vim.cmd('silent! normal! g`"')
		end
	end,
})

-- Highlight text when yanked
autocmd("TextYankPost", {
	group = basic_auto_cmds,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

autocmd("CursorMoved", {
	group = augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd("nohlsearch")
			end)
		end
	end,
})

-- =============================================
-- plugins autocmds
-- =============================================
local plugins_auto_cmds = vim.api.nvim_create_augroup("PluginsAutoCmds", { clear = true })

-- ==============
-- nvim-tree
-- ==============
augroup("__nvim_tree__", { clear = true })
-- Close Neovim if NvimTree is the only window open
autocmd("BufEnter", {
	group = "__nvim_tree__",
	callback = function()
		local wins = vim.api.nvim_list_wins()
		local buffers = vim.api.nvim_list_bufs()
		if #wins == 1 and #buffers == 1 then
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname:match("NvimTree_") then
				vim.cmd("quit")
			end
		end
	end,
})

-- Close tab if NvimTree is the only window left
autocmd("BufEnter", {
	group = "__nvim_tree__",
	callback = function()
		if #vim.api.nvim_list_wins() == 1 then
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname:match("NvimTree_") then
				vim.cmd("quit")
			end
		end
	end,
})

autocmd("VimEnter", {
	group = "__nvim_tree__",
	callback = function()
		require("nvim-tree.api").tree.open()
		vim.cmd("wincmd p") -- Move cursor back to the previous window
	end,
})

-- Auto locate the current file in NvimTree
autocmd("BufWinEnter", {
	group = "__nvim_tree__",
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname ~= "" and not bufname:match("NvimTree_") then
			require("nvim-tree.api").tree.find_file()
		end
	end,
})
