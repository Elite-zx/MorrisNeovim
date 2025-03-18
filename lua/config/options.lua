-- ==========================
-- Basic Settings
-- ==========================
local opt = vim.opt
local cmd = vim.cmd
local api = vim.api
local global = vim.g

-- Line numbers
opt.number = true -- Show absolute line number
opt.relativenumber = true -- Show relative line number
opt.cursorline = true -- Highlight the line with the cursor

-- clipboard
opt.clipboard = "unnamedplus"

-- Syntax and colors
cmd("syntax enable") -- Enable syntax highlighting
opt.termguicolors = true -- Enable 24-bit color support
opt.background = "dark" -- Set background to dark

-- Filetype plugin indent
cmd("filetype plugin indent on") -- Automatically detect file types
cmd("filetype on") -- Enable filetype detection

-- Encoding settings
opt.encoding = "utf-8" -- Set internal encoding to utf-8
opt.fileencodings = { "utf-8", "ucs-bom", "gb18030", "gbk", "gb2312", "cp936" } -- File encodings to try

-- Indentation settings (for C++)
opt.smarttab = true -- Enable smart tab behavior
opt.shiftwidth = 4 -- Number of spaces to use for each indentation step
opt.tabstop = 2 -- Number of spaces that a tab character counts for
-- opt.expandtab = true        -- Optionally convert tabs to spaces (commented out)
-- opt.list = true             -- Optionally show tabs and spaces as visible characters

-- Working directory follows file's directory
opt.autochdir = false -- Automatically change directory to the file's directory

-- Font settings (GUI version)
opt.guifont = "Monaco 20" -- Set font for GUI versions of Vim

-- Allow buffer switching without saving
opt.hidden = true -- Allow buffers to be hidden without saving

-- Virtual editing settings
opt.virtualedit = "block" -- Allow the cursor to move beyond the last character

-- Mouse settings
opt.mouse = "n" -- Disable mouse support
opt.ttyfast = true -- Enable faster terminal communication

-- Indentation settings
opt.smartindent = true -- Enable smart indentation

-- Search settings
opt.ignorecase = true -- Ignore case in searches
opt.smartcase = true -- Case-sensitive search when uppercase is used

-- Matching bracket settings
opt.showmatch = true -- Show matching brackets/parentheses
opt.showcmd = true -- Show (partial) command in the last line

-- Backspace behavior
opt.backspace = "indent,eol,start" -- Allow backspace over indentation, end of line, and start of line

-- Search highlighting
opt.hlsearch = true -- Highlight search matches
opt.incsearch = true -- Incremental search (matches are displayed gradually)

-- Auto-indentation
opt.ai = true -- Enable auto-indentation
opt.si = true -- Enable smart indentation
opt.cindent = true -- Enable C-style indentation

-- UI
opt.signcolumn = "yes" -- always show sign column

-- ==========================
-- Window Splitting & Layout
-- ==========================
opt.splitright = true -- Place vertical splits to the right
opt.splitbelow = true -- Place horizontal splits below

-- ==========================
-- Mouse and Terminal Settings
-- ==========================
opt.mouse = "a" -- Enable mouse support in all modes

-- disable netrw at the very start of your init.lua
global.loaded_netrw = 1
global.loaded_netrwPlugin = 1
