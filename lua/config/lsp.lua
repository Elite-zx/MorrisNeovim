-- ==========================
-- neovim 0.11 lsp settings
-- ==========================
local lsp = vim.lsp

-- Lsp capabilities and on_attach {{{
lsp.config.luals = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc' },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = {
				globals = { "vim" },
				disable = { "different-requires", "undefined-field" },
			},
			workspace = {
				library = {
					vim.fn.expand("$VIMRUNTIME/lua"),
					vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
				},
				maxPreload = 100000,
				preloadFileSize = 10000,
			},
			hint = { enable = true, setType = true },
			format = { enable = true },
			telemetry = { enable = false },
			semantic = { enable = false },
		},
	},
}
lsp.enable('luals')


lsp.config.clangd = {
	cmd = {
		"clangd",
		"--j=12",
		"--enable-config",
		"--background-index",
		"--clang-tidy",
		"--clang-tidy-checks=*",
		"--all-scopes-completion",
		"--completion-style=detailed",
		"--header-insertion-decorators",
		"--header-insertion=iwyu",
		"--limit-references=3000",
		"--limit-results=350",
		"--pch-storage=disk",
		"--pretty",
		"--inlay-hints",
		"--fallback-style=llvm",
		"--compile-commands-dir=/data/zenonzhang/QQMail",
	},
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"CMakeLists.txt",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}
lsp.enable('clangd')
