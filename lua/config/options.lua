-- ==========================
-- Basic Settings
-- ==========================
local opt          = vim.opt
local global       = vim.g
local fn           = vim.fn
local editor       = require("utils.editor")

-- window
opt.splitbelow     = true
opt.splitright     = true
opt.splitkeep      = 'screen'
opt.previewheight  = 12
opt.winminwidth    = 10
opt.winwidth       = 30

-- Cursor
opt.timeout        = true
opt.timeoutlen     = 300 -- Mapping delay and
opt.ttimeout       = true
opt.ttimeoutlen    = 0
opt.updatetime     = 200 --CursorHold trigger time
opt.virtualedit    = 'block'
opt.scrolloff      = 2

-- Ignore certain files and directories when completing command line files
opt.wildignore     =
".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
opt.wildignorecase = true
opt.concealcursor  = "niv"
opt.conceallevel   = 0

-- Indentation s
opt.smarttab       = true -- Enable smart tab behavior
opt.tabstop        = 4    -- Number of spaces that a tab character counts for
opt.autoindent     = true -- Enable smart indentation
opt.jumpoptions    = "stack"
opt.shiftwidth     = 4    -- Number of spaces to use for each indentation step
opt.shiftround     = true

-- Matching bracket settings
opt.matchpairs:append({ '<:>', '「:」', '『:』', '【:】', '“:”', '‘:’', '《:》' })
opt.showmatch      = true -- Show matching brackets/parentheses

-- completion
opt.complete       = ".,w,b,k,kspell"
opt.completeopt    = "menuone,noselect,popup"

-- format
opt.formatoptions  = "1jcroql"

-- backup
opt.backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"

-- short message
opt.shortmess      = "aoOTIcF"

-- Line numbers
opt.nu             = true -- Show absolute line number
opt.rnu            = true -- Show relative line number
opt.cursorline     = true -- Highlight the line with the cursor
opt.ruler          = true

-- Search settings
opt.ignorecase     = true -- Ignore case in searches
opt.smartcase      = true -- Case-sensitive search when uppercase is used

-- Encoding settings
opt.encoding       = "utf-8"

-- line wrap
opt.wrap           = true
opt.whichwrap      = "h,l,<,>,[,],~"
opt.linebreak      = true
opt.breakat        = [[\ \	;:,!?]]
opt.showbreak      = "↳  "
opt.breakindentopt = "shift:2,min:20"

-- Turn on mouse support in normal mode, set mouse behavior and scroll step length
opt.mouse          = 'n'
opt.mousemodel     = 'popup'
opt.mousescroll    = "ver:3,hor:6"

-- Buffer
opt.hidden         = true -- Allow buffer switching without saving
opt.autowrite      = true
opt.autoread       = true
opt.switchbuf      = "usetab,uselast"
opt.writebackup    = false

-- statusline
opt.showmode       = false
opt.errorbells     = true
opt.history        = 2000
opt.list           = true
opt.listchars      = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
opt.laststatus     = 3

-- virtual
opt.visualbell     = true

-- ui
-- opt.termguicolors  = true // default
opt.signcolumn     = "yes:1"
opt.background     = "dark" -- Set background to dark
opt.redrawtime     = 1500
opt.synmaxcol      = 2500
opt.guifont        = 'Monaco NFM'
opt.showtabline    = 2 -- always show tabline


-- file
opt.autochdir      = false -- Automatically change directory to the file's directory
opt.swapfile       = false
opt.fileformats    = "unix,mac,dos"

-- command line
opt.showcmd        = false -- Show (partial) command in the last line
opt.cmdheight      = 1     -- 0, 1, 2
opt.cmdwinheight   = 5
opt.display        = "lastline"
opt.helpheight     = 12
opt.inccommand     = "nosplit"

-- Backspace behavior
opt.backspace      = "indent,eol,start" -- Allow backspace over indentation, end of line, and start of line

-- Search highlighting
opt.hlsearch       = true -- Highlight search matches
opt.incsearch      = true -- Incremental search (matches are displayed gradually)
opt.wrapscan       = true

-- session
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winpos,winsize"
opt.shada          = "!,'500,<50,@100,s10,h" -- shared data file

-- clipboard
-- Yank with OSC52
-- Paste with register
local osc52        = require("vim.ui.clipboard.osc52")
vim.o.clipboard    = "unnamedplus"
vim.g.clipboard    = {
	name = "OSC 52",
	copy = {
		["+"] = osc52.copy("+"),
		["*"] = osc52.copy("*"),
	},
	paste = {
		["+"] = editor.paste,
		["*"] = editor.paste,
	},
}

-- If ripgrep exists in the system, use it as the default grep tool
if fn.executable('rg') == 1 then
	opt.grepprg = "rg --hidden --vimgrep --smart-case --"
	opt.grepformat = '%f:%l:%c:%m'
end

-- automatically create undo file
local undodir = fn.expand("~/.vim/undo")
if fn.isdirectory(undodir) == 0 then
	fn.mkdir(undodir, "p")
end
-- persistent undo
opt.undofile   = true
opt.undodir    = undodir
opt.undolevels = 1000
opt.undoreload = 10000
