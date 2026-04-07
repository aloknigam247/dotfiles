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
	CodeReviewLine        = { bg = "#2a2a3a" },
	CodeReviewLow         = { link = "DiagnosticHint" },
	CodeReviewMedium      = { link = "DiagnosticWarn" },
	CodeReviewPending     = { link = "Comment" },
	CodeReviewPrompt      = { link = "DiagnosticWarn" },
	CodeReviewRejected    = { link = "DiagnosticError" },
	CodeReviewSeverity    = { fg = "#fab387", italic = true },
	CodeReviewText        = { link = "Normal" },
}

---@class CodeReview.State
local state = {
	entries = {},      ---@type table[]
	source_file = "",  ---@type string
	by_file = {},      ---@type table<string, table[]>
	ns = vim.api.nvim_create_namespace("code_review"),
	floats = {},       ---@type table<integer, table[]>  bufnr -> float_info[]
	float_bufs = {},   ---@type table<integer, boolean>  set of float buffer ids (to skip in BufEnter)
	augroup = nil,     ---@type integer|nil
}

--- Setup highlights and configuration
---@param opts? { highlights?: table<string, table> }
function M.setup(opts)
	opts = opts or {}
	local hls = vim.tbl_deep_extend("force", default_highlights, opts.highlights or {})

	-- Resolve CodeReviewText from Normal so floats get the editor bg, not NormalFloat bg
	if hls.CodeReviewText and hls.CodeReviewText.link == "Normal" then
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		hls.CodeReviewText = { fg = normal.fg, bg = normal.bg }
	end

	for name, hl in pairs(hls) do
		vim.api.nvim_set_hl(0, name, hl)
	end
end

--- Normalize a file path for consistent comparison
---@param path string
---@return string
local function normalize_path(path)
	return vim.fs.normalize(path):gsub("\\", "/")
end

--- Get the relative file key for a buffer
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

--- Pretty-print JSON with 2-space indent
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

--- Render reviews for a specific buffer
---@param bufnr integer
function M.render(bufnr)
	-- Skip float buffers
	if state.float_bufs[bufnr] then
		return
	end

	local key = buf_file_key(bufnr)
	if not key then
		return
	end

	local entries = state.by_file[key]
	if not entries or #entries == 0 then
		return
	end

	-- Skip if already rendered for this buffer
	if state.floats[bufnr] then
		return
	end

	-- Render highlights + spacers + floats
	local float_infos = ui.render_reviews(bufnr, entries, state.ns)
	state.floats[bufnr] = float_infos

	-- Track float buffer ids
	for _, info in ipairs(float_infos) do
		state.float_bufs[info.float_buf] = true
	end

	-- Set buffer-local keymaps
	local kopts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "<leader>c", function() M.action() end, vim.tbl_extend("force", kopts, { desc = "Code review: jump to comment" }))
	vim.keymap.set("n", "]r", function() ui.next_review(state.floats[bufnr]) end, vim.tbl_extend("force", kopts, { desc = "Next review" }))
	vim.keymap.set("n", "[r", function() ui.prev_review(state.floats[bufnr]) end, vim.tbl_extend("force", kopts, { desc = "Previous review" }))
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

	-- Collect responses from float buffers
	for _, float_infos in pairs(state.floats) do
		for _, info in ipairs(float_infos) do
			info.entry.response = info.get_response()
		end
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

--- Clear all review annotations, floats, and state
function M.clear()
	for bufnr, float_infos in pairs(state.floats) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			ui.clear_reviews(bufnr, state.ns, float_infos)
			pcall(vim.keymap.del, "n", "<leader>c", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "]r", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "[r", { buffer = bufnr })
		end
	end

	if state.augroup then
		vim.api.nvim_del_augroup_by_id(state.augroup)
		state.augroup = nil
	end

	state.entries = {}
	state.source_file = ""
	state.by_file = {}
	state.floats = {}
	state.float_bufs = {}
end

--- Jump to the nearest comment float from cursor (<leader>c)
function M.action()
	local bufnr = vim.api.nvim_get_current_buf()
	local float_infos = state.floats[bufnr]
	if not float_infos then
		return
	end
	ui.focus_nearest(float_infos)
end

return M
