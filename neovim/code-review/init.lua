local ui = require("code-review.ui")
local picker = require("code-review.picker")

local M = {}

local default_highlights = {
	CodeReviewAccepted    = { link = "DiagnosticOk" },
	CodeReviewBorderBase  = { fg = "#89b4fa" },
	CodeReviewBorderGreen = { fg = "#a6e3a1" },
	CodeReviewBorderRed   = { fg = "#f38ba8" },
	CodeReviewCategory    = { fg = "#cba6f7", bold = true },
	CodeReviewHigh        = { fg = "#f38ba8", bold = true },
	CodeReviewInfo        = { link = "DiagnosticInfo" },
	CodeReviewInput       = { link = "CursorLine" },
	CodeReviewLow         = { link = "DiagnosticHint" },
	CodeReviewMedium      = { link = "DiagnosticWarn" },
	CodeReviewPending     = { link = "Comment" },
	CodeReviewPrompt      = { link = "DiagnosticWarn" },
	CodeReviewRejected    = { link = "DiagnosticError" },
	CodeReviewSeverity    = { fg = "#fab387", italic = true },
	CodeReviewText        = { link = "Normal" },
}

local status_to_severity = {
	accepted = vim.diagnostic.severity.HINT,
	pending  = vim.diagnostic.severity.INFO,
	prompt   = vim.diagnostic.severity.WARN,
	rejected = vim.diagnostic.severity.ERROR,
}

---@class CodeReview.State
local state = {
	entries = {},          ---@type table[]
	source_file = "",      ---@type string
	by_file = {},          ---@type table<string, table[]>
	ns = vim.api.nvim_create_namespace("code_review"),
	augroup = nil,         ---@type integer|nil
	rendered_bufs = {},    ---@type table<integer, boolean>
}

--- Setup highlights and diagnostic config
---@param opts? { highlights?: table<string, table> }
function M.setup(opts)
	opts = opts or {}
	local hls = vim.tbl_deep_extend("force", default_highlights, opts.highlights or {})

	-- Resolve CodeReviewText from Normal so floats get the editor bg
	if hls.CodeReviewText and hls.CodeReviewText.link == "Normal" then
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		hls.CodeReviewText = { fg = normal.fg, bg = normal.bg }
	end

	for name, hl in pairs(hls) do
		vim.api.nvim_set_hl(0, name, hl)
	end

	-- Configure diagnostics for our namespace
	-- Note: tiny-inline-diagnostic only reads global config for icons,
	-- so sign column icons are the only ones we can control per-namespace.
	vim.diagnostic.config({
		virtual_text = false,
		float = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰆄",  -- rejected
				[vim.diagnostic.severity.HINT]  = "󰆈",  -- accepted
				[vim.diagnostic.severity.INFO]  = "󰆉",  -- pending
				[vim.diagnostic.severity.WARN]  = "󰆊",  -- prompt
			},
		},
		underline = true,
	}, state.ns)
end

---@param path string
---@return string
local function normalize_path(path)
	return vim.fs.normalize(path):gsub("\\", "/")
end

---@param bufnr integer
---@return string|nil
local function buf_file_key(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	if bufname == "" then
		return nil
	end
	local abs = normalize_path(bufname)
	local cwd = normalize_path(vim.fn.getcwd())
	if abs:sub(1, #cwd) == cwd then
		return abs:sub(#cwd + 2)
	end
	return abs
end

---@param tbl table
---@return string
local function json_pretty(tbl)
	local json = vim.json.encode(tbl)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { json })
	vim.api.nvim_buf_set_option(buf, "filetype", "json")
	vim.api.nvim_buf_call(buf, function()
		vim.cmd("%!python -m json.tool --indent 2 2>nul || echo " .. json)
	end)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	vim.api.nvim_buf_delete(buf, { force = true })
	return table.concat(lines, "\n")
end

--- Set diagnostics for a buffer from its review entries
---@param bufnr integer
---@param entries table[]
local function set_diagnostics(bufnr, entries)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local diagnostics = {}

	for _, entry in ipairs(entries) do
		local lnum = math.max(0, math.min(entry.line - 1, line_count - 1))
		local end_lnum = math.max(0, math.min((entry.end_line or entry.line) - 1, line_count - 1))

		local start_text = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
		local col = math.min(math.max(0, (entry.col or 1) - 1), #start_text)

		local end_text = vim.api.nvim_buf_get_lines(bufnr, end_lnum, end_lnum + 1, false)[1] or ""
		local end_col = entry.end_col
		if not end_col or end_col == 0 then
			end_col = #end_text
		else
			end_col = math.min(end_col - 1, #end_text)
		end

		diagnostics[#diagnostics + 1] = {
			lnum = lnum,
			col = col,
			end_lnum = end_lnum,
			end_col = end_col,
			message = entry.comment,
			severity = status_to_severity[entry.status] or vim.diagnostic.severity.INFO,
			source = "code-review",
			user_data = { entry = entry },
		}
	end

	vim.diagnostic.set(state.ns, bufnr, diagnostics)
end

--- Render diagnostics for a buffer
---@param bufnr integer
function M.render(bufnr)
	local key = buf_file_key(bufnr)
	if not key then
		return
	end

	local entries = state.by_file[key]
	if not entries or #entries == 0 then
		return
	end

	-- Set diagnostics (always refresh to pick up status changes)
	set_diagnostics(bufnr, entries)

	-- Set keymaps only once per buffer
	if state.rendered_bufs[bufnr] then
		return
	end
	state.rendered_bufs[bufnr] = true

	local kopts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "[r", function()
		vim.diagnostic.goto_prev({ namespace = state.ns, float = false })
		M.open_review_window()
	end, vim.tbl_extend("force", kopts, { desc = "Previous review" }))
	vim.keymap.set("n", "]r", function()
		vim.diagnostic.goto_next({ namespace = state.ns, float = false })
		M.open_review_window()
	end, vim.tbl_extend("force", kopts, { desc = "Next review" }))
	vim.keymap.set("n", "<leader>r", function()
		M.open_review_window()
	end, vim.tbl_extend("force", kopts, { desc = "Open review window" }))
end

--- Load a review file
---@param filepath string
function M.load(filepath)
	if not filepath or filepath == "" then
		vim.notify("CodeReview: No file specified", vim.log.levels.ERROR)
		return
	end

	local abs_path = vim.fn.fnamemodify(filepath, ":p")
	if vim.fn.filereadable(abs_path) ~= 1 then
		vim.notify("CodeReview: File not found: " .. abs_path, vim.log.levels.ERROR)
		return
	end

	local content = table.concat(vim.fn.readfile(abs_path), "\n")
	local ok, entries = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("CodeReview: Invalid JSON: " .. tostring(entries), vim.log.levels.ERROR)
		return
	end

	if type(entries) ~= "table" then
		vim.notify("CodeReview: Expected JSON array", vim.log.levels.ERROR)
		return
	end

	M.setup()
	M.clear()

	for _, entry in ipairs(entries) do
		entry.file = normalize_path(entry.file)
		entry.status = entry.status or "pending"
		entry.response = entry.response or ""
	end

	state.entries = entries
	state.source_file = abs_path
	state.by_file = {}

	for _, entry in ipairs(entries) do
		if not state.by_file[entry.file] then
			state.by_file[entry.file] = {}
		end
		table.insert(state.by_file[entry.file], entry)
	end

	state.augroup = vim.api.nvim_create_augroup("CodeReview", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = state.augroup,
		callback = function(args)
			M.render(args.buf)
		end,
	})

	M.render(vim.api.nvim_get_current_buf())
	picker.open(state)

	local file_count = vim.tbl_count(state.by_file)
	vim.notify(("CodeReview: Loaded %d reviews across %d files"):format(#entries, file_count), vim.log.levels.INFO)
end

--- Save updated statuses and responses back to the review file
function M.done()
	if state.source_file == "" then
		vim.notify("CodeReview: No review file loaded", vim.log.levels.WARN)
		return
	end

	local output = json_pretty(state.entries)
	vim.fn.writefile(vim.split(output, "\n"), state.source_file)
	vim.notify("CodeReview: Saved " .. #state.entries .. " entries to " .. state.source_file, vim.log.levels.INFO)
end

--- Open the file tree picker
function M.pick()
	if #state.entries == 0 then
		vim.notify("CodeReview: No reviews loaded", vim.log.levels.WARN)
		return
	end
	picker.open(state)
end

--- Clear all diagnostics and state
function M.clear()
	-- Clear diagnostics from all rendered buffers
	for bufnr, _ in pairs(state.rendered_bufs) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.diagnostic.reset(state.ns, bufnr)
			pcall(vim.keymap.del, "n", "[r", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "]r", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "<leader>r", { buffer = bufnr })
		end
	end

	if state.augroup then
		vim.api.nvim_del_augroup_by_id(state.augroup)
		state.augroup = nil
	end

	state.entries = {}
	state.source_file = ""
	state.by_file = {}
	state.rendered_bufs = {}
end

--- Find the original entry from state.by_file matching a cursor line
---@param bufnr integer
---@param cursor_line integer 0-based
---@return table|nil entry
local function find_entry_at_line(bufnr, cursor_line)
	local key = buf_file_key(bufnr)
	if not key or not state.by_file[key] then
		return nil
	end
	for _, entry in ipairs(state.by_file[key]) do
		local start_line = entry.line - 1
		local end_line = (entry.end_line or entry.line) - 1
		if cursor_line >= start_line and cursor_line <= end_line then
			return entry
		end
	end
	return nil
end

--- Open review window for the review at cursor
function M.open_review_window()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

	-- Look up the original entry from state (not from diagnostic user_data which is a deep copy)
	local entry = find_entry_at_line(bufnr, cursor_line)
	if not entry then
		return
	end

	ui.open_review_window(entry, function()
		-- Refresh diagnostics to reflect status/response change
		local key = buf_file_key(bufnr)
		if key and state.by_file[key] then
			set_diagnostics(bufnr, state.by_file[key])
		end
	end, function(direction)
		-- Navigate: close current, jump, reopen
		if direction == "next" then
			vim.diagnostic.goto_next({ namespace = state.ns, float = false })
		else
			vim.diagnostic.goto_prev({ namespace = state.ns, float = false })
		end
		M.open_review_window()
	end)
end

return M
