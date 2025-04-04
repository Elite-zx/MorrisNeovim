-- =============================================
-- Diagnostic Config
-- =============================================

local diagnostic = vim.diagnostic
local api = vim.api

-- Global configuration for diagnostics display
diagnostic.config {
	underline = false,  -- Disable underline for diagnostics
	virtual_text = false, -- Disable inline virtual text
	virtual_lines = false, -- Disable virtual lines
	signs = {
		text = {
			[diagnostic.severity.ERROR] = "❌", -- Icon for ERROR diagnostics
			[diagnostic.severity.WARN]  = "⚠️", -- Icon for WARN diagnostics
			[diagnostic.severity.INFO]  = "ℹ️", -- Icon for INFO diagnostics
			[diagnostic.severity.HINT]  = "", -- Icon for HINT diagnostics
		},
	},
	severity_sort = true,  -- Sort diagnostics by severity
	float = {
		source = true,     -- Show the diagnostic source in the float
		header = "Diagnostics:", -- Header text for float window
		prefix = " ",      -- Prefix before each line in float
		border = "single", -- Border style for diagnostic float window
	},
}
-- Show diagnostic float window on CursorHold if cursor moved to a new line with diagnostics
api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	callback = function()
		if #vim.diagnostic.get(0) == 0 then
			return
		end

		if not vim.b.diagnostics_pos then
			vim.b.diagnostics_pos = { nil, nil }
		end

		local cursor_pos = api.nvim_win_get_cursor(0)

		if not vim.deep_equal(cursor_pos, vim.b.diagnostics_pos) then
			diagnostic.open_float { width = 100 }
		end

		vim.b.diagnostics_pos = cursor_pos
	end,
})
