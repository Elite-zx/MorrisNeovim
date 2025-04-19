-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local icons = {
	kind = require("utils.icons").get("kind"),
	documents = require("utils.icons").get("documents"),
	ui = require("utils.icons").get("ui"),
	ui_sep = require("utils.icons").get("ui", true),
	misc = require("utils.icons").get("misc"),
}

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	change_detection = { notify = false },
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "dracula" } },
	-- automatically check for plugin updates
	checker = { enabled = false },
	ui = {
		-- a number <1 is a percentage., >1 is a fixed size
		size = { width = 0.88, height = 0.8 },
		wrap = true, -- wrap the lines in the ui
		-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
		border = "rounded",
		icons = {
			cmd = icons.misc.Code,
			config = icons.ui.Gear,
			event = icons.kind.Event,
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			import = icons.documents.Import,
			keys = icons.ui.Keyboard,
			loaded = icons.ui.Check,
			not_loaded = icons.misc.Ghost,
			plugin = icons.ui.Package,
			runtime = icons.misc.Vim,
			source = icons.kind.StaticMethod,
			start = icons.ui.Play,
		},
	},
})
