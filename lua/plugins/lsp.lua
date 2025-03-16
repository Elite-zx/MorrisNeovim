return {
	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" }, -- Lazy load LSP
		dependencies = {
			"williamboman/mason.nvim", -- LSP manager
			"williamboman/mason-lspconfig.nvim", -- Mason 与 LSPConfig 集成
			"hrsh7th/cmp-nvim-lsp", -- LSP 补全支持
			"ray-x/lsp_signature.nvim", -- 输入函数参数时显示函数声明
		},
		config = function()
			-- Mason setup
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "ts_ls", "clangd" }, -- 预安装的 LSP
				automatic_installation = true,
			})

			-- LSP configurations
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- 让 LSP 和补全联动

			local servers = { "lua_ls", "pyright", "ts_ls", "clangd" }
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end

			-- Lua language server specific settings
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" }, -- 适用于 Neovim
						diagnostics = { globals = { "vim", "require" } }, -- 让 LSP 识别 Neovim 变量
						workspace = { library = vim.api.nvim_get_runtime_file("", true) }, -- 识别 Neovim 运行时
						telemetry = { enable = false }, -- 禁用遥测
					},
				},
			})
		end,
	},

	-- Auto-completion setup
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter", -- Load when entering insert mode
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completion support
			"hrsh7th/cmp-buffer", -- Buffer completion
			"hrsh7th/cmp-path", -- Path completion
			"hrsh7th/cmp-cmdline", -- Command line completion
			"L3MON4D3/LuaSnip", -- Snippet engine
			"saadparwaiz1/cmp_luasnip", -- LuaSnip completion
			"rafamadriz/friendly-snippets", -- ✅ 代码片段集合
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load() -- Load snippets

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion

					-- Enter key behavior
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm({ select = true }) -- Confirm selection
							end
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Tab key behavior
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1) -- Jump to next snippet placeholder
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Shift-Tab behavior (reverse jump)
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1) -- Jump to previous snippet placeholder
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- LSP completion
					{ name = "luasnip" }, -- Snippet completion
					{ name = "buffer" }, -- Buffer completion
					{ name = "path" }, -- Path completion
				}),
			})
		end,
	},
}
