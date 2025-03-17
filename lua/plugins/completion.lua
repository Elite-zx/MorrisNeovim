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
						on_attach = function(client, _)
							-- Disable semantic highlights (hand it over to treesitter)
							if client.server_capabilities.semanticTokensProvider then
								client.server_capabilities.semanticTokensProvider = nil
							end
							-- Disable formatting capabilities (hand it over to conform.nvim)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentFormattingRangeProvider = false
						end,
					})
				end,
				-- custom handler
				lua_ls = function()
					require("lspconfig").lua_ls.setup({
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
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
					vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				end,
			})
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "neovim/nvim-lspconfig" }, -- 依赖 LSPConfig
	},

	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" }, -- 代码片段集合
		opts = function()
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load() --  自动加载 VSCode 片段
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"onsails/lspkind.nvim",
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			return {
				sources = {
					{ name = "nvim_lsp" }, -- autocompletion
					{ name = "luasnip" }, -- autosnippet
					{ name = "buffer" }, -- source for words in all open buffers
				},

				-- Let luasnip handle snippet from lsp for nvim-cmp
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},

				-- Preselect first item
				preselect = "item", -- set 'none' to cancel
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				mapping = cmp.mapping.preset.insert({
					-- `Enter` key to confirm completion
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then -- completion menu is visible
							if luasnip.expandable() then
								luasnip.expand() -- expend Snippet in snippet menu
							else
								cmp.confirm({ select = true }) -- confirm code completion
							end
						else
							fallback() -- do default behavior (input CR) if no menu exist
						end
					end, { "i", "s" }), -- mode limition

					-- Super Tab
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item() -- navigate auto code completion menu
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1) -- navigate snippet completion menu
						else
							fallback() -- do default behavior (input tab) if cmp or snippet not exists
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1) -- 跳转到上一个片段
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

	-- LSP Signature (函数签名提示)
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy", -- 在需要时加载
		opts = {},
	},
}
