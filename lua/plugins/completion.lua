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
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentFormattingRangeProvider = false
end

return {
	-- Mason-LSPConfig (closes some gaps that exist between mason.nvim and lspconfig)
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { {
			"williamboman/mason.nvim",
			opts = {},
		} }, -- LSP Manager
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

	-- LSPConfig (Neovim LSP Client)
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
				end,
			})
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

	-- LSP Signature (function name prompt)
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
	},

	{
		"nvimdev/lspsaga.nvim",
		lazy = true,
		event = "LspAttach",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require('lspsaga').setup({})
		end,
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
