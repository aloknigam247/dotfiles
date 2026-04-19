local diagnostics = require("review.diagnostics")
local state = require("review.state")
local util = require("review.util")

local M = {}

--- Find the comment id at the cursor in the current window
---@return string|nil
function M.find_at_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	local key = util.buf_file_key(bufnr)
	if not key then return nil end
	local line0 = vim.api.nvim_win_get_cursor(0)[1] - 1
	local c = state.find_at(key, line0)
	return c and c.id or nil
end

--- Update active comment to whatever is at cursor (if any)
function M.sync_active_to_cursor()
	local id = M.find_at_cursor()
	if id then state.set_active(id) end
end

--- Jump to next review diagnostic in current buffer (wraps around)
function M.next()
	vim.diagnostic.goto_next({ namespace = diagnostics.ns_diag, float = false, wrap = true })
	M.sync_active_to_cursor()
end

--- Jump to previous review diagnostic
function M.prev()
	vim.diagnostic.goto_prev({ namespace = diagnostics.ns_diag, float = false, wrap = true })
	M.sync_active_to_cursor()
end

return M
