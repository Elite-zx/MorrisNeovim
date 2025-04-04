-- ==========================
-- Basic Settings
-- ==========================
local opt          = vim.opt
local cmd          = vim.cmd
local api          = vim.api
local global       = vim.g
local utils        = require("config.utils")

opt.splitbelow     = true
opt.splitright     = true
opt.splitkeep      = 'screen'

-- Mapping delay and CursorHold trigger time
opt.timeoutlen     = 500
opt.updatetime     = 500

-- Ignore certain files and directories when completing command line files
opt.wildignore     = {
	'*.o', '*.obj', '*.dylib', '*.bin', '*.dll', '*.exe',
	'*/.git/*', '*/.svn/*', '*/__pycache__/*', '*/build/**',
	'*.jpg', '*.png', '*.jpeg', '*.bmp', '*.gif', '*.tiff', '*.svg', '*.ico',
	'*.pyc', '*.pkl',
	'*.DS_Store',
	'*.aux', '*.bbl', '*.blg', '*.brf', '*.fls', '*.fdb_latexmk', '*.synctex.gz', '*.xdv',
}
opt.wildignorecase = true


-- Indentation settings (for C++)
opt.smarttab   = true -- Enable smart tab behavior
opt.shiftwidth = 4    -- Number of spaces to use for each indentation step
opt.tabstop    = 2    -- Number of spaces that a tab character counts for

-- Match brackets
opt.matchpairs:append({ '<:>', '「:」', '『:』', '【:】', '“:”', '‘:’', '《:》' })

-- Line numbers
opt.number         = true  -- Show absolute line number
opt.relativenumber = true  -- Show relative line number
opt.cursorline     = true  -- Highlight the line with the cursor

-- Search settings
opt.ignorecase     = true  -- Ignore case in searches
opt.smartcase      = true  -- Case-sensitive search when uppercase is used

-- Encoding settings
opt.fileencoding   = 'utf-8'
opt.fileencodings  = { 'ucs-bom', 'utf-8', 'cp936', 'gb18030', 'big5', 'euc-jp', 'euc-kr', 'latin1' }

-- Automatic line wrap and prefix characters
opt.linebreak      = true
opt.showbreak      = '↪'

-- 14. 命令补全模式与滚动
opt.wildmode       = 'list:longest'
opt.scrolloff      = 3

-- Turn on mouse support in normal mode, set mouse behavior and scroll step length
opt.mouse          = 'n'
opt.mousemodel     = 'popup'
opt.mousescroll    = 'ver:1,hor:0'


-- Allow buffer switching without saving
opt.hidden      = true
opt.autowrite   = true
opt.autoread    = true

opt.showmode    = false
opt.fileformats = { 'unix', 'dos' }
opt.confirm     = true
opt.visualbell  = true
opt.errorbells  = false
opt.history     = 500
opt.list        = true
opt.listchars   = {
	tab = '▸ ',
	extends = '❯',
	precedes = '❮',
	nbsp = '␣',
}

-- persistent undo
local undodir   = vim.fn.expand("~/.vim/undo")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end
opt.undofile    = true
opt.undodir     = undodir
opt.undolevels  = 1000
opt.undoreload  = 10000

-- Automatic alignment indentation to the next shiftwidth multiple; allows virtual cursor to be used in block selection for easy alignment editing
opt.shiftround  = true
opt.virtualedit = 'block'


-- 25. 真彩色与光标、符号栏
opt.termguicolors = true
opt.signcolumn    = "yes:1"
opt.background    = "dark"     -- Set background to dark


-- Remove == and commas from filename recognition characters
opt.isfname:remove("==")
opt.isfname:remove(",")

-- Forbid automatic line wrapping, turn off the default ruler display of the status bar, and set the command display position to the status bar
opt.wrap = false
opt.ruler = false
opt.showcmdloc = 'statusline'

-- Working directory follows file's directory
opt.autochdir = false -- Automatically change directory to the file's directory

-- Indentation settings
opt.smartindent = true -- Enable smart indentation

-- Matching bracket settings
opt.showmatch = true -- Show matching brackets/parentheses
opt.showcmd = true   -- Show (partial) command in the last line

-- Backspace behavior
opt.backspace = "indent,eol,start" -- Allow backspace over indentation, end of line, and start of line

-- Search highlighting
opt.hlsearch = true  -- Highlight search matches
opt.incsearch = true -- Incremental search (matches are displayed gradually)

-- Auto-indentation
opt.ai = true      -- Enable auto-indentation
opt.si = true      -- Enable smart indentation
opt.cindent = true -- Enable C-style indentation


-- disable netrw at the very start of your init.lua
global.loaded_netrw = 1
global.loaded_netrwPlugin = 1

-- clipboard
-- Yank (y)	写入 + 寄存器 → OSC52 → 本地剪贴板
-- Paste (p)	从 + 寄存器直接读取内容（非 OSC52）
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = utils.paste,
		["*"] = utils.paste,
	},
}

-- log
opt.verbose = 15
opt.verbosefile = vim.fn.stdpath('cache') .. '/nvim_verbose.log'

-- If ripgrep exists in the system, use it as the default grep tool
if vim.fn.executable('rg') == 1 then
	opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
	opt.grepformat = '%f:%l:%c:%m'
end
