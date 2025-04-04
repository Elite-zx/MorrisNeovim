-- ==============================
-- LSP for autocompletion and format
-- ==============================

-- on_attach is a callback function for a LSP server,
-- which executed when lsp attached a buffer
local function on_attach(client, bufnr)
	-- 禁用语义高亮，交给 treesitter 处理
	if client.server_capabilities.semanticTokensProvider then
		client.server_capabilities.semanticTokensProvider = nil
	end

	-- 禁用 LSP 代码格式化（交给 conform.nvim 处理）
	-- client.server_capabilities.documentFormattingProvider = false
	-- client.server_capabilities.documentFormattingRangeProvider = false

	-- 只格式化修改过的部分（lsp-format-modifications）
	local augroup_id = vim.api.nvim_create_augroup("FormatModificationsDocumentFormattingGroup", { clear = false })
	vim.api.nvim_clear_autocmds({ group = augroup_id, buffer = bufnr })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = augroup_id,
		buffer = bufnr,
		callback = function()
			local lsp_format_modifications = require("lsp-format-modifications")
			lsp_format_modifications.format_modifications(client, bufnr)
		end,
	})
end

return {
	-- Mason (LSP Manager)
	{
		"williamboman/mason.nvim",
		lazy = false,
		opts = {},
	},

	-- Mason-LSPConfig (Closes some gaps that exist between mason.nvim and lspconfig)
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" }, -- 依赖 Mason
		opts = {
			-- -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
			ensure_installed = { "clangd", "lua_ls", "pyright", "ts_ls" },
			-- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
			-- This setting has no relation with the `ensure_installed` setting.
			automatic_installation = true,
			handlers = {
				-- default handler
				function(server_name)
					local capabilities = require("cmp_nvim_lsp").default_capabilities()
					require("lspconfig")[server_name].setup({
						-- cmp_nvim_lsp closes some gaps between nvim-cmp and nvim-lspconfig
						-- Add cmp_nvim_lsp capabilities settings to lspconfig
						-- This should be executed before you configure any language server
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end,

				-- custom handler
				-- note that custom handler overwrite default handler
				-- which means default handler's logic is not work for lsp server with custom handler
				clangd = function()
					local function get_binary_path_list(binaries)
						local path_list = {}
						for _, binary in ipairs(binaries) do
							local path = vim.fn.exepath(binary)
							if path ~= "" then
								table.insert(path_list, path)
							end
						end
						return table.concat(path_list, ",")
					end

					local function switch_source_header_splitcmd(bufnr, splitcmd)
						bufnr = require("lspconfig").util.validate_bufnr(bufnr)
						local clangd_client = require("lspconfig").util.get_active_client_by_name(bufnr, "clangd")
						local params = { uri = vim.uri_from_bufnr(bufnr) }
						if clangd_client then
							clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
								if err then
									error(tostring(err))
								end
								if not result then
									vim.notify(
										"Corresponding file can’t be determined",
										vim.log.levels.ERROR,
										{ title = "LSP Error!" }
									)
									return
								end
								vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
							end)
						else
							vim.notify(
								"Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
								vim.log.levels.ERROR,
								{ title = "LSP Error!" }
							)
						end
					end

					local capabilities = require("cmp_nvim_lsp").default_capabilities()
					require("lspconfig").clangd.setup({
						filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
						root_dir = function(fname)
							return require("lspconfig.util").root_pattern(
								".clangd",
								".clang-tidy",
								".clang-format",
								"compile_commands.json",
								"compile_flags.txt",
								"configure.ac" -- AutoTools
							)(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
						end,

						capabilities = vim.tbl_deep_extend(
							"keep",
							{ offsetEncoding = { "utf-16", "utf-8" } },
							capabilities
						),
						single_file_support = true,
						cmd = {
							"/usr/bin/clangd",
							"--clang-tidy",
							"--all-scopes-completion",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--pch-storage=disk",
							"--log=error",
							"--j=8",
							"--pretty",
							"--background-index=false",
							"--enable-config",
						},
						on_attach = on_attach,
						commands = {
							ClangdSwitchSourceHeader = {
								function()
									switch_source_header_splitcmd(0, "edit")
								end,
								description = "Open source/header in current buffer",
							},
							ClangdSwitchSourceHeaderVSplit = {
								function()
									switch_source_header_splitcmd(0, "vsplit")
								end,
								description = "Open source/header in a new vsplit",
							},
							ClangdSwitchSourceHeaderSplit = {
								function()
									switch_source_header_splitcmd(0, "split")
								end,
								description = "Open source/header in a new split",
							},
						},
						-- g: go to header
						vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<CR>"),
					})
				end,

				lua_ls = function()
					local capabilities = require("cmp_nvim_lsp").default_capabilities()
					require("lspconfig").lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									-- (most likely LuaJIT in the case of Neovim)
									version = "LuaJIT",
								},
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = {
										"vim",
										"require",
									},
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
								-- Do not send telemetry data containing a randomized but unique identifier
								telemetry = {
									enable = false,
								},
							},
						},
					})
				end,
			},
		},
	},

	-- LSPConfig (Neovim LSP 客户端)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" }, -- 延迟加载 LSP
		dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- This is where you enable features that only work
			-- if there is a language server active in the file
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
					--  automatically rename all references of variable/class/func,
					vim.keymap.set("n", "gR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					-- show parameter prompts
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					-- code action for quickfix:
					-- 1. fix variable/class/func spell error
					-- 2. import missing #include
					vim.keymap.set("n", "gq", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

					-- ✅ CursorHold 自动显示 diagnostic 浮窗
				end,
			})
			-- Function to check if a floating dialog exists and if not then check for diagnostics under the cursor
			function OpenDiagnosticIfNoFloat()
				for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
					if vim.api.nvim_win_get_config(winid).zindex then
						return
					end
				end
				vim.diagnostic.open_float(0, {
					scope = "cursor",
					focusable = false,
					close_events = {
						"CursorMoved",
						"CursorMovedI",
						"BufHidden",
						"InsertCharPre",
						"WinLeave",
					},
				})
			end

			vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold" }, {
				pattern = "*",
				command = "lua OpenDiagnosticIfNoFloat()",
				group = "lsp_diagnostics_hold",
			})
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "neovim/nvim-lspconfig" }, -- 依赖 LSPConfig
	},

	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		history = true,
		update_events = "TextChanged,TextChangedI",
		delete_check_events = "TextChanged,InsertLeave",
		dependencies = { "rafamadriz/friendly-snippets" }, -- 代码片段集合
		opts = function()
			require("luasnip.loaders.from_lua").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_snipmate").lazy_load()
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			{ "saadparwaiz1/cmp_luasnip", dependencies = { "L3MON4D3/LuaSnip" } },
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local col = vim.fn.col(".") - 1

			return {
				sources = {
					{ name = "nvim_lsp" }, -- autocompletion
					{ name = "luasnip" }, -- autosnippet
					{ name = "buffer" }, -- source for words in all open buffers
					{ name = "path" },
				},

				-- Preselect first item
				preselect = "item", -- set 'none' to cancel
				completion = {
					completeopt = "menu,menuone,noinsert",
				},

				-- Let luasnip handle snippet expansion for nvim-cmp
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = "select" })
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							fallback()
						else
							cmp.complete()
						end
					end, { "i", "s" }),

					-- Super shift tab
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = "select" })
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				-- Add border to autocompletion menu
				-- window = {
				-- 	completion = cmp.config.window.bordered(),
				-- 	documentation = cmp.config.window.bordered(),
				-- },
			}
		end,
	},

	{
		"dnlhc/glance.nvim",
		cmd = "Glance",
		keys = {
			{ "<leader>gd", "<CMD>Glance definitions<CR>" },
			{ "<leader>gR", "<CMD>Glance references<CR>" },
		},
		config = function()
			local glance = require("glance")
			local actions = glance.actions

			glance.setup({
				height = 18, -- Height of the window
				zindex = 45,

				-- When enabled, adds virtual lines behind the preview window to maintain context in the parent window
				-- Requires Neovim >= 0.10.0
				preserve_win_context = true,

				-- Controls whether the preview window is "embedded" within your parent window or floating
				-- above all windows.
				detached = function(winid)
					-- Automatically detach when parent window width < 100 columns
					return vim.api.nvim_win_get_width(winid) < 100
				end,
				-- Or use a fixed setting: detached = true,

				preview_win_opts = { -- Configure preview window options
					cursorline = true,
					number = true,
					wrap = true,
				},

				border = {
					enable = false, -- Show window borders. Only horizontal borders allowed
					top_char = "―",
					bottom_char = "―",
				},

				list = {
					position = "right", -- Position of the list window 'left'|'right'
					width = 0.33, -- Width as percentage (0.1 to 0.5)
				},

				theme = {
					enable = true, -- Generate colors based on current colorscheme
					mode = "auto", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
				},

				mappings = {
					list = {
						["j"] = actions.next, -- Next item
						["k"] = actions.previous, -- Previous item
						["<Down>"] = actions.next,
						["<Up>"] = actions.previous,
						["<Tab>"] = actions.next_location, -- Next location (skips groups, cycles)
						["<S-Tab>"] = actions.previous_location, -- Previous location (skips groups, cycles)
						["<C-u>"] = actions.preview_scroll_win(5), -- Scroll up the preview window
						["<C-d>"] = actions.preview_scroll_win(-5), -- Scroll down the preview window
						["v"] = actions.jump_vsplit, -- Open location in vertical split
						["s"] = actions.jump_split, -- Open location in horizontal split
						["t"] = actions.jump_tab, -- Open in new tab
						["<CR>"] = actions.jump,  -- Jump to location
						["o"] = actions.jump,
						["l"] = actions.open_fold,
						["h"] = actions.close_fold,
						["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
						["q"] = actions.close,      -- Closes Glance window
						["Q"] = actions.close,
						["<Esc>"] = actions.close,
						["<C-q>"] = actions.quickfix, -- Send all locations to quickfix list
						-- ['<Esc>'] = false -- Disable a mapping
					},

					preview = {
						["Q"] = actions.close,
						["<Tab>"] = actions.next_location, -- Next location (skips groups, cycles)
						["<S-Tab>"] = actions.previous_location, -- Previous location (skips groups, cycles)
						["<leader>l"] = actions.enter_win("list"), -- Focus list window
					},
				},

				hooks = {}, -- Described in Hooks section

				folds = {
					fold_closed = "",
					fold_open = "",
					folded = true, -- Automatically fold list on startup
				},

				indent_lines = {
					enable = true, -- Show indent guidelines
					icon = "│",
				},

				winbar = {
					enable = true, -- Enable winbar for the preview (requires neovim-0.8+)
				},
				use_trouble_qf = false, -- Quickfix action will open trouble.nvim instead of built-in quickfix list
			})
		end,
	},

	-- LSP Signature (函数签名提示)
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy", -- 在需要时加载
		opts = {},
	},
	-- handle code error
	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		keys = {
			-- l: list
			{
				-- d: diagnostics
				"<leader>ld",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "All opened buffer diagnostics (Trouble)",
			},
			{
				"<leader>lD",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Current buffer diagnostics (Trouble)",
			},
			{
				--s: symbols
				--replace plugin aerial
				"<leader>ls",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Code symbols outline  (Trouble)",
			},
			-- s: quickfix
			{
				"<leader>lq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
		opts = {},
	},

	-- format
	{
		"joechrisellis/lsp-format-modifications.nvim",
		event = "LspAttach",
	},

	{
		"stevearc/conform.nvim",
		opts = function()
			vim.keymap.set("n", "<leader>w", function()
				require("conform").format({ lsp_format = "fallback" }) -- 触发格式化
				vim.cmd("write")                           -- 保存文件
			end, { desc = "Format and save buffer" })
			return {
				formatters_by_ft = {
					lua = { "stylua" },
					cpp = { "clang-format" },
					c = { "clang-format" },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
				},

				-- format_on_save = { -- These options will be passed to conform.format()
				-- 	timeout_ms = 500,
				-- 	lsp_format = "fallback",
				-- },
			}
		end,
	},
}
