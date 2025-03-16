local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- =============================================
-- basic keymaps and cmds
-- =============================================
-- Disable F1 (help key)
map("n", "<F1>", "<nop>", opts)
map("i", "<F1>", "<nop>", opts)
map("c", "<F1>", "<nop>", opts)
-- Quickly trigger Esc in insert mode with Ctrl-C
map("i", "<C-c>", "<Esc>", opts)
-- Toggle list characters display with F2
map("n", "<F2>", ":<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list?<CR>", opts)
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

-- Smart way to navigate between windows
map("n", "<C-j>", "<C-W>j", opts) -- Move to the window below
map("n", "<C-k>", "<C-W>k", opts) -- Move to the window above
map("n", "<C-h>", "<C-W>h", opts) -- Move to the window on the left
map("n", "<C-l>", "<C-W>l", opts) -- Move to the window on the right
