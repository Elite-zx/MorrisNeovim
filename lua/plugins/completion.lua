return {
	-- Mason (LSP Manager)
	{
		"williamboman/mason.nvim",
		lazy = false, -- 确保启动时加载
		opts = {}, -- Mason 无需额外配置，直接启用
	},

	-- Mason-LSPConfig (桥接 Mason 和 LSPConfig)
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" }, -- 依赖 Mason
		opts = {
			ensure_installed = { "lua_ls", "pyright", "ts_ls", "clangd" }, -- 预安装的 LSP
			automatic_installation = true,
		},
	},

	-- LSPConfig (Neovim LSP 客户端)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" }, -- 延迟加载 LSP
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- 让 LSP 和补全联动
			local servers = { "lua_ls", "pyright", "ts_ls", "clangd" }
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end

			-- Lua 语言服务器特定设置
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

	-- LSP Signature (函数签名提示)
	{
		"ray-x/lsp_signature.nvim",
		opts = {},
	},

	-- nvim-cmp (自动补全核心插件)
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter", -- 进入插入模式时加载
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			return {
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(), -- 手动触发补全

					-- 回车键行为
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm({ select = true }) -- 确认选择
							end
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Tab 键行为
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1) -- 跳转到下一个片段
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Shift-Tab 反向跳转
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
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- LSP 补全
					{ name = "luasnip" }, -- 代码片段
					{ name = "buffer" }, -- 缓冲区补全
					{ name = "path" }, -- 路径补全
				}),
			}
		end,
	},

	-- LuaSnip (代码片段引擎)
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		version = "*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			history = true,
			update_events = "TextChanged,TextChangedI",
			delete_check_events = "TextChanged,InsertLeave",
			-- require("luasnip.loaders.from_vscode").lazy_load(),
		},
	},

	-- friendly-snippets (预置代码片段集合)
	{
		"rafamadriz/friendly-snippets",
		dependencies = { "L3MON4D3/LuaSnip" },
	},
	-- nvim-cmp LSP 支持
	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	-- nvim-cmp 缓冲区补全
	{
		"hrsh7th/cmp-buffer",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	-- nvim-cmp 路径补全
	{
		"hrsh7th/cmp-path",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	-- nvim-cmp 命令行补全
	{
		"hrsh7th/cmp-cmdline",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	-- LuaSnip 代码片段补全
	{
		"saadparwaiz1/cmp_luasnip",
		dependencies = { "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip" },
	},
}
