local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local utils = require("utils.editor")

-- Use ';' instead of ':' to enter command mode (saves shift keypress)
-- map({ "n", "x" }, ";", ":")

-- Disable F1 (help key)
map("n", "<F1>", "<nop>", opts)
map("i", "<F1>", "<nop>", opts)
map("c", "<F1>", "<nop>", opts)

-- Quickly trigger Esc in insert mode with Ctrl-C
map("i", "<C-c>", "<Esc>", opts)
-- Toggle list characters display with F2
-- map("n", "<Fr>", ":<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list?<CR>", opts)
-- Better line navigation (keep cursor centered)
map("n", "k", "gkzz", opts)
map("n", "j", "gjzz", opts)
-- Auto select after adjusting indentation in visual mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
-- Smart way to manage tabs
map("n", "<leader>tn", ":tabnew<CR>", opts) -- Open a new tab
map("n", "<leader>to", ":tabonly<CR>", opts) -- Close all other tabs except the current one
map("n", "<leader>tc", ":tabclose<CR>", opts) -- Close the current tab
map("n", "<leader>tm", ":tabmove ", opts) -- Move the current tab (requires manual input for position)
map("n", "<leader>tw", "<C-w>T", opts) -- Move the current window to a new tab

-- Comment since christoomey/vim-tmux-navigator
-- Smart way to navigate between windows
-- map("n", "<C-j>", "<C-W>j", opts) -- Move to the window below
-- map("n", "<C-k>", "<C-W>k", opts) -- Move to the window above
-- map("n", "<C-h>", "<C-W>h", opts) -- Move to the window on the left
-- map("n", "<C-l>", "<C-W>l", opts) -- Move to the window on the right

-- Change/Delete text without writing to default register
map("n", "c", '"_c')
map("n", "C", '"_C')
map("n", "cc", '"_cc')
map("x", "c", '"_c')

-- Easier navigation to start/end of line
map({ "n", "x" }, "H", "^") -- Go to first non-blank character
map({ "n", "x" }, "L", "g_") -- Go to last non-blank character

-- Use very magic mode for all searches (less escaping)
-- map("n", "/", [[/\v]])

-- Change local working directory to current file's path and print it
map("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- Delete current buffer without closing the window
map("n", [[\d]], "<cmd>bprevious <bar> bdelete #<cr><cmd>echo 'Deleted current buffer.'<cr>", {
	silent = true,
	desc = "delete current buffer",
})

-- Normal mode: move current line
-- NOTE: To make alt work, set Preferences > Profiles: left option key -> ESC+ in iterm2
map("n", "<A-k>", function()
	utils.switch_line(vim.fn.line("."), "up")
end)
map("n", "<A-j>", function()
	utils.switch_line(vim.fn.line("."), "down")
end)

-- Replace visual selection with clipboard content without overwriting default register
map("x", "p", '"_c<Esc>p')

-- Insert a semicolon at the end of the line (Alt+;)
map("i", "<A-;>", "<Esc>miA;<Esc>`ii")
-- Join lines without moving the cursor (normal J)
map("n", "J", function()
	vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, {
	desc = "join lines without moving cursor",
})

-- Delete all other listed buffers except the current one
map("n", [[\D]], function()
	local buf_ids = vim.api.nvim_list_bufs()
	local cur_buf = vim.api.nvim_win_get_buf(0)
	local deleted_count = 0

	for _, buf_id in pairs(buf_ids) do
		if vim.api.nvim_get_option_value("buflisted", { buf = buf_id }) and buf_id ~= cur_buf then
			vim.api.nvim_buf_delete(buf_id, { force = true })
			deleted_count = deleted_count + 1
		end
	end
	-- Show a confirmation message
	vim.notify("Deleted " .. deleted_count .. " buffer(s), current buffer preserved", vim.log.levels.INFO, {
		title = "Buffer Cleanup",
	})
end, {
	desc = "delete other buffers",
})

-- Quickly open init.lua (your config file)
map("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", {
	silent = true,
	desc = "open init.lua",
})

-- Save and reload init.lua
map("n", "<leader>sv", function()
	vim.cmd([[
      update $MYVIMRC
      source $MYVIMRC
    ]])
	vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
end, {
	silent = true,
	desc = "reload init.lua",
})

-- Reselect the most recently pasted text
map("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
	expr = true,
	desc = "reselect last pasted area",
})
