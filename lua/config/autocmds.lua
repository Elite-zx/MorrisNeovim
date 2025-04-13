local cmd = vim.cmd
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

-- Highlight text when yanked
autocmd("TextYankPost", {
	group = basic_auto_cmds,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})

-- no highlight after search
autocmd("CursorMoved", {
	group = basic_auto_cmds,
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				cmd("nohlsearch")
			end)
		end
	end,
})

autocmd("VimLeave", {
	callback = function()
		if vim.fn.has("nvim") == 1 then
			cmd("wshada")
		else
			cmd("wviminfo!")
		end
	end,
})

-- =============================================
-- plugins autocmds
-- =============================================

-- Toggle alpha-nvim and Neotree with tabnew
autocmd("TabNewEntered", {
	callback = function()
		if vim.fn.empty(vim.fn.expand("%")) == 1 then
			cmd("Alpha")
		end
	end,
})
