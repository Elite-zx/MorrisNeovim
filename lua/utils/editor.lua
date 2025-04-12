local M = {}

-- Move a single line up or down
function M.switch_line(src_line, direction)
	local total_lines = vim.fn.line("$")
	if direction == "up" then
		if src_line == 1 then
			return
		end
		vim.cmd(src_line .. "move" .. (src_line - 2))
	elseif direction == "down" then
		if src_line == total_lines then
			return
		end
		vim.cmd(src_line .. "move" .. (src_line + 1))
	end
end

function M.paste()
	return {
		vim.fn.split(vim.fn.getreg(""), "\n"),
		vim.fn.getregtype(""),
	}
end

return M
