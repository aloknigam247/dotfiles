local state = require("review.state")
local util = require("review.util")

local M = {}

M.ns_diag = vim.api.nvim_create_namespace("review_diag")
M.ns_bg = vim.api.nvim_create_namespace("review_bg")

local severity_to_diag = {
	high = vim.diagnostic.severity.ERROR,
	medium = vim.diagnostic.severity.WARN,
	low = vim.diagnostic.severity.INFO,
	info = vim.diagnostic.severity.HINT,
}

local status_to_bg_hl = {
	pending = "ReviewBgPending",
	accepted = "ReviewBgAccepted",
	rejected = "ReviewBgRejected",
}

--- Configure default diagnostic display for our namespace
function M.configure()
	vim.diagnostic.config({
		virtual_text = false, -- prefer signs + bg; tiny-inline-diagnostic handles the rest if installed
		float = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰆄",
				[vim.diagnostic.severity.WARN]  = "󰆊",
				[vim.diagnostic.severity.INFO]  = "󰆉",
				[vim.diagnostic.severity.HINT]  = "󰆈",
			},
		},
		underline = false,
	}, M.ns_diag)
end

--- Clamp a column to the actual line byte length
local function clamp_col(bufnr, line0, col0)
	local text = vim.api.nvim_buf_get_lines(bufnr, line0, line0 + 1, false)[1] or ""
	if col0 < 0 then return #text end
	return math.min(col0, #text)
end

--- Resolve a Comment to a normalized 0-based range (start_line, start_col, end_line, end_col)
---@param bufnr integer
---@param c Comment
local function resolve_range(bufnr, c)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local sl = math.max(0, math.min(c.line - 1, line_count - 1))
	local el = math.max(0, math.min((c.end_line or c.line) - 1, line_count - 1))
	local sc = clamp_col(bufnr, sl, math.max(0, (c.col or 1) - 1))
	local raw_ec = c.end_col
	local ec
	if not raw_ec or raw_ec == 0 then
		ec = clamp_col(bufnr, el, -1)
	else
		ec = clamp_col(bufnr, el, raw_ec - 1)
	end
	return sl, sc, el, ec
end

--- Render diagnostics + bg extmarks for a buffer's comments
---@param bufnr integer
function M.render(bufnr)
	local key = util.buf_file_key(bufnr)
	if not key then return end
	local comments = state.by_file(key)
	if not comments or #comments == 0 then return end

	local diags = {}
	-- Clear bg first; diagnostic.set replaces our diag namespace entirely
	vim.api.nvim_buf_clear_namespace(bufnr, M.ns_bg, 0, -1)

	for _, c in ipairs(comments) do
		local sl, sc, el, ec = resolve_range(bufnr, c)
		local severity = severity_to_diag[c.severity] or vim.diagnostic.severity.INFO
		diags[#diags + 1] = {
			lnum = sl,
			col = sc,
			end_lnum = el,
			end_col = ec,
			severity = severity,
			message = c.body or c.comment or "",
			source = "review:" .. (c.provider or "?"),
			user_data = { id = c.id },
		}
		-- BG extmark for status visual
		local bg_hl = status_to_bg_hl[c.status] or "ReviewBgPending"
		vim.api.nvim_buf_set_extmark(bufnr, M.ns_bg, sl, sc, {
			end_row = el,
			end_col = ec,
			hl_group = bg_hl,
			priority = 50,
		})
	end

	vim.diagnostic.set(M.ns_diag, bufnr, diags)
end

--- Clear all review diagnostics + bg highlights from a buffer
---@param bufnr integer
function M.clear(bufnr)
	vim.diagnostic.reset(M.ns_diag, bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, M.ns_bg, 0, -1)
end

return M
