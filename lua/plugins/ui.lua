-- ===============
--  Better UI for neovim
-- ===============
local icons = {
	misc = require("utils.icons").get("misc", true),
	diagnostics = require("utils.icons").get("diagnostics", true),
	ui = require("utils.icons").get("ui", true),
	git = require("utils.icons").get("git", true),
	git_nosep = require("utils.icons").get("git"),
}

local conditionals = {
	has_enough_room = function()
		return vim.o.columns > 100
	end,
	has_comp_before = function()
		return vim.bo.filetype ~= ""
	end,
	has_git = function()
		local gitdir = vim.fs.find(".git", {
			limit = 1,
			upward = true,
			type = "directory",
			path = vim.fn.expand("%:p:h"),
		})
		return #gitdir > 0
	end,
}

local utils = {
	force_centering = function()
		return "%="
	end,
	abbreviate_path = function(path)
		local home = require("utils.global").home
		if path:find(home, 1, true) == 1 then
			path = "~" .. path:sub(#home + 1)
		end
		return path
	end,
}

local components = {
	file_status = {
		function()
			local function is_new_file()
				local filename = vim.fn.expand("%")
				return filename ~= "" and vim.bo.buftype == "" and vim.fn.filereadable(filename) == 0
			end

			local symbols = {}
			if vim.bo.modified then
				table.insert(symbols, "[+]")
			end
			if vim.bo.modifiable == false then
				table.insert(symbols, "[-]")
			end
			if vim.bo.readonly == true then
				table.insert(symbols, "[RO]")
			end
			if is_new_file() then
				table.insert(symbols, "[New]")
			end
			return #symbols > 0 and table.concat(symbols, "") or ""
		end,
		padding = { left = -1, right = 1 },
		cond = conditionals.has_comp_before,
	},

	lsp = {
		function()
			local buf_ft = vim.bo.filetype
			local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
			local lsp_lists = {}
			local available_servers = {}
			if next(clients) == nil then
				return icons.misc.NoActiveLsp -- No server available
			end
			for _, client in ipairs(clients) do
				local filetypes = client.config.filetypes
				local client_name = client.name
				if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
					-- Avoid adding servers that already exists.
					if not lsp_lists[client_name] then
						lsp_lists[client_name] = true
						table.insert(available_servers, client_name)
					end
				end
			end
			return next(available_servers) == nil and icons.misc.NoActiveLsp
				or string.format("%s[%s]", icons.misc.LspAvailable, table.concat(available_servers, ", "))
		end,
		cond = conditionals.has_enough_room,
	},
	python_venv = {
		function()
			local function env_cleanup(venv)
				if string.find(venv, "/") then
					local final_venv = venv
					for w in venv:gmatch("([^/]+)") do
						final_venv = w
					end
					venv = final_venv
				end
				return venv
			end

			if vim.bo.filetype == "python" then
				local venv = os.getenv("CONDA_DEFAULT_ENV")
				if venv then
					return icons.misc.PyEnv .. env_cleanup(venv)
				end
				venv = os.getenv("VIRTUAL_ENV")
				if venv then
					return icons.misc.PyEnv .. env_cleanup(venv)
				end
			end
			return ""
		end,
		cond = conditionals.has_enough_room,
	},

	tabwidth = {
		function()
			return icons.ui.Tab .. vim.bo.tabstop
		end,
		padding = 1,
	},

	cwd = {
		function()
			return icons.ui.FolderWithHeart .. utils.abbreviate_path(vim.fs.normalize(vim.fn.getcwd()))
		end,
	},

	file_location = {
		function()
			local cursorline = vim.fn.line(".")
			local cursorcol = vim.fn.virtcol(".")
			local filelines = vim.fn.line("$")
			local position
			if cursorline == 1 then
				position = "Top"
			elseif cursorline == filelines then
				position = "Bot"
			else
				position = string.format("%2d%%%%", math.floor(cursorline / filelines * 100))
			end
			return string.format("%s · %3d:%-2d", position, cursorline, cursorcol)
		end,
	},
}
local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

return {
	-- colorscheme
	{
		"Mofiqul/dracula.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			vim.cmd.colorscheme("dracula")
		end,
	},
	-- startup screen
	{
		"goolord/alpha-nvim",
		config = function()
			local alpha = require("alpha")
			local startify = require("alpha.themes.startify")
			startify.section.header.val = require("utils.settings").startify_image
			alpha.setup(startify.opts)
		end,
	},
	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				disabled_filetypes = { statusline = { "alpha" } },
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						"filename",
						file_status = false,
						path = 4,
					},
					components.file_status,
				},
				lualine_c = {
					{
						"branch",
						icon = icons.git_nosep.Branch,
						cond = conditionals.has_git,
					},
					{
						"diff",
						symbols = {
							added = icons.git.Add,
							modified = icons.git.Mod_alt,
							removed = icons.git.Remove,
						},
						source = diff_source,
						colored = true,
						cond = conditionals.has_git,
						padding = { right = 1 },
					},
					{ utils.force_centering },
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warning,
							info = icons.diagnostics.Information,
							hint = icons.diagnostics.Hint_alt,
						},
					},
					components.lsp,
				},
				lualine_x = {
					{
						-- show Macros messages such as recording @
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ff9e64" },
					},

					{
						"encoding",
						show_bomb = true,
						fmt = string.upper,
						padding = { right = 1 },
						cond = conditionals.has_enough_room,
					},
				},
				lualine_y = {
					components.python_venv,
					components.cwd,
				},
				lualine_z = { components.file_location },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = { "quickfix", "neo-tree", "trouble" }, --clean lualine in neo-treeb
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			scope = { enabled = true, show_start = false, show_end = false },
		},
	},

	-- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/defaults.lua
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = false, -- neo-tree will lazily load itself
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>nn",
				"<cmd>Neotree toggle show reveal_force_cwd<cr>",
				desc = "Toggle Neotree",
				silent = true,
			},
			{
				"<leader>nf",
				"<cmd>Neotree show reveal_force_cwd<cr>",
				desc = "Locate current file on Neotree",
				silent = true,
			},
		},
		opts = {
			close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
			window = {
				position = "left",
				width = 30,
			},
			filesystem = {
				filtered_items = {
					visible = true,
					show_hidden_count = true,
					hide_dotfiles = true,
					hide_gitignored = true,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
			},
		},
	},

	{
		"rcarriga/nvim-notify",
		lazy = true,
		event = "VeryLazy",
		opts = {
			---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
			stages = "fade_in_slide_out",
			---@usage Function called when a new window is opened, use for changing win settings/config
			on_open = function(win)
				vim.api.nvim_set_option_value("winblend", 0, { scope = "local", win = win })
				vim.api.nvim_win_set_config(win, { zindex = 90 })
			end,
			---@usage Function called when a window is closed
			on_close = nil,
			---@usage timeout for notifications in ms, default 5000
			timeout = 2000,
			-- @usage User render fps value
			fps = 20,
			top_down = true,
			-- Render function for notifications. See notify-render()
			render = "default",
			---@usage highlight behind the window for stages that change opacity
			background_colour = "NotifyBackground",
			---@usage minimum width for notification windows
			minimum_width = 50,
			---@usage notifications with level lower than this would be ignored. [ERROR > WARN > INFO > DEBUG > TRACE]
			level = "INFO",
			---@usage Icons for the different levels
			icons = {
				ERROR = icons.diagnostics.Error,
				WARN = icons.diagnostics.Warning,
				INFO = icons.diagnostics.Information,
				DEBUG = icons.ui.Bug,
				TRACE = icons.ui.Pencil,
			},
		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup(opts)
			vim.notify = notify
		end,
	},

	{
		"folke/todo-comments.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			-- 只跳转到 ERROR 和 WARNING 标签
			{
				"]t",
				function()
					require("todo-comments").jump_next({ keywords = { "HACK", "FIXME", "WARNING", "TODO" } })
				end,
				desc = "Next ERROR/WARNING comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev({ keywords = { "HACK", "FIXME", "WARNING", "TODO" } })
				end,
				desc = "Previous ERROR/WARNING comment",
			},
		},
		opts = {
			signs = false, -- show icons in the signs column
			keywords = {
				FIX = {
					icon = icons.ui.Bug,
					color = "error",
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
				},
				TODO = { icon = icons.ui.Accepted, color = "info" },
				HACK = { icon = icons.ui.Fire, color = "warning" },
				WARN = { icon = icons.diagnostics.Warning, color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = icons.ui.Perf, alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = icons.ui.Note, color = "hint", alt = {} },
				TEST = { icon = icons.ui.Lock, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			gui_style = {
				fg = "NONE",
				bg = "BOLD",
			},
			merge_keywords = false, --  custom keywords only
			highlight = {
				multiline = false,
				keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty.
				after = "",
				comments_only = true,
				max_line_len = 500,
				exclude = {
					"alpha",
					"bigfile",
					"checkhealth",
					"dap-repl",
					"diff",
					"help",
					"log",
					"notify",
					"NeoTree",
					"Outline",
					"qf",
					"TelescopePrompt",
					"toggleterm",
					"undotree",
				},
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#F5C2E7" },
				default = { "Conditional", "#7C3AED" },
			},
		},
	},

	-- focus mode
	{
		"folke/zen-mode.nvim",
		keys = {
			{
				"<leader>zm",
				"<cmd>ZenMode<cr>",
				desc = "Toggle ZenMode",
				silent = true,
			},
		},
		opts = {},
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
		},
	},
}
