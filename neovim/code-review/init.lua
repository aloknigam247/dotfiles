local ui = require("code-review.ui")
local picker = require("code-review.picker")
local actions = require("code-review.actions")

local M = {}

local default_highlights = {
	CodeReviewAccepted = { link = "DiagnosticOk" },
	CodeReviewBorder   = { link = "FloatBorder" },
	CodeReviewHigh     = { link = "DiagnosticError" },
	CodeReviewInfo     = { link = "DiagnosticInfo" },
	CodeReviewLow      = { link = "DiagnosticHint" },
	CodeReviewMedium   = { link = "DiagnosticWarn" },
	CodeReviewPending  = { link = "Comment" },
	CodeReviewQuestion = { link = "DiagnosticWarn" },
	CodeReviewRejected = { link = "DiagnosticError" },
	CodeReviewText     = { link = "Normal" },
}

---@class CodeReview.State
local state = {
	entries = {},      ---@type table[]
	source_file = "",  ---@type string
	by_file = {},      ---@type table<string, table[]>
	ns = vim.api.nvim_create_namespace("code_review"),
	extmarks = {},     ---@type table<integer, table<integer, table>>
	augroup = nil,     ---@type integer|nil
}

--- Setup highlights and configuration
---@param opts? { highlights?: table<string, table> }
function M.setup(opts)
	opts = opts or {}
	local hls = vim.tbl_deep_extend("force", default_highlights, opts.highlights or {})
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
	-- Try to make relative
	if abs:sub(1, #cwd) == cwd then
		local rel = abs:sub(#cwd + 2) -- skip trailing /
		return rel
	end
	return abs
end

--- Pretty-print JSON with 2-space indent
---@param tbl table
---@return string
local function json_pretty(tbl)
	-- vim.json.encode produces compact JSON; manually format it
	local json = vim.json.encode(tbl)
	-- Use vim's built-in formatting by writing to a scratch buffer
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
	local key = buf_file_key(bufnr)
	if not key then
		return
	end

	local entries = state.by_file[key]
	if not entries or #entries == 0 then
		return
	end

	-- Clear existing extmarks for this buffer
	ui.clear_reviews(bufnr, state.ns)
	state.extmarks[bufnr] = nil

	-- Render and track extmarks
	local extmark_map = ui.render_reviews(bufnr, entries, state.ns)
	state.extmarks[bufnr] = extmark_map

	-- Set buffer-local keymaps
	local kopts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "<CR>", function() M.action() end, vim.tbl_extend("force", kopts, { desc = "Code review action" }))
	vim.keymap.set("n", "]r", function() ui.next_review(bufnr, state.ns) end, vim.tbl_extend("force", kopts, { desc = "Next review" }))
	vim.keymap.set("n", "[r", function() ui.prev_review(bufnr, state.ns) end, vim.tbl_extend("force", kopts, { desc = "Previous review" }))
end

--- Re-render a single entry's extmark after status change
---@param bufnr integer
---@param old_extmark_id integer
---@param entry table
local function rerender_entry(bufnr, old_extmark_id, entry)
	-- Delete old extmark
	vim.api.nvim_buf_del_extmark(bufnr, state.ns, old_extmark_id)

	-- Get the line from the entry (extmark may have moved)
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, state.ns, 0, -1, {})
	-- Re-render at the entry's line
	local line = entry.line - 1
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if line >= line_count then
		line = line_count - 1
	end
	if line < 0 then
		line = 0
	end

	local winid = vim.fn.bufwinid(bufnr)
	if winid == -1 then
		winid = 0
	end
	local box_width = ui.get_box_width(winid)
	local virt_lines = ui.build_comment_box(entry, box_width)
	local new_id = vim.api.nvim_buf_set_extmark(bufnr, state.ns, line, 0, {
		virt_lines = virt_lines,
		virt_lines_above = false,
	})

	-- Update tracking
	if state.extmarks[bufnr] then
		state.extmarks[bufnr][old_extmark_id] = nil
		state.extmarks[bufnr][new_id] = entry
	end
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

	-- Read and parse JSON
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

	-- Setup highlights
	M.setup()

	-- Clear previous state
	M.clear()

	-- Normalize entries
	for _, entry in ipairs(entries) do
		entry.file = normalize_path(entry.file)
		entry.status = entry.status or "pending"
	end

	-- Store state
	state.entries = entries
	state.source_file = abs_path
	state.by_file = {}

	-- Group by file
	for _, entry in ipairs(entries) do
		if not state.by_file[entry.file] then
			state.by_file[entry.file] = {}
		end
		table.insert(state.by_file[entry.file], entry)
	end

	-- Create autocmd for BufEnter
	state.augroup = vim.api.nvim_create_augroup("CodeReview", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = state.augroup,
		callback = function(args)
			M.render(args.buf)
		end,
	})

	-- Re-render on window resize
	vim.api.nvim_create_autocmd("WinResized", {
		group = state.augroup,
		callback = function()
			for bufnr, _ in pairs(state.extmarks) do
				if vim.api.nvim_buf_is_valid(bufnr) then
					M.render(bufnr)
				end
			end
		end,
	})

	-- Render current buffer if it matches
	M.render(vim.api.nvim_get_current_buf())

	-- Open the file tree sidebar
	picker.open(state)

	local file_count = vim.tbl_count(state.by_file)
	vim.notify(("CodeReview: Loaded %d reviews across %d files"):format(#entries, file_count), vim.log.levels.INFO)
end

--- Save updated statuses back to the review file
function M.done()
	if state.source_file == "" then
		vim.notify("CodeReview: No review file loaded", vim.log.levels.WARN)
		return
	end

	-- Update line numbers from extmark positions (in case file was edited)
	for bufnr, extmark_map in pairs(state.extmarks) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			for extmark_id, entry in pairs(extmark_map) do
				local marks = vim.api.nvim_buf_get_extmarks(bufnr, state.ns, extmark_id, extmark_id, {})
				if #marks > 0 then
					entry.line = marks[1][2] + 1 -- back to 1-based
				end
			end
		end
	end

	-- Write JSON
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

--- Clear all review annotations and state
function M.clear()
	-- Clear extmarks from all tracked buffers
	for bufnr, _ in pairs(state.extmarks) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			ui.clear_reviews(bufnr, state.ns)
			-- Remove buffer-local keymaps
			pcall(vim.keymap.del, "n", "<CR>", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "]r", { buffer = bufnr })
			pcall(vim.keymap.del, "n", "[r", { buffer = bufnr })
		end
	end

	-- Clear autocmds
	if state.augroup then
		vim.api.nvim_del_augroup_by_id(state.augroup)
		state.augroup = nil
	end

	-- Reset state
	state.entries = {}
	state.source_file = ""
	state.by_file = {}
	state.extmarks = {}
end

--- Trigger action menu for the review at cursor line
function M.action()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-based
	local extmark_map = state.extmarks[bufnr]

	if not extmark_map then
		return
	end

	-- Find the extmark at the cursor line
	local target_id, target_entry
	for extmark_id, entry in pairs(extmark_map) do
		local marks = vim.api.nvim_buf_get_extmarks(bufnr, state.ns, extmark_id, extmark_id, {})
		if #marks > 0 and marks[1][2] == cursor_line then
			target_id = extmark_id
			target_entry = entry
			break
		end
	end

	if not target_entry then
		return
	end

	actions.show_action_menu(target_entry, function()
		rerender_entry(bufnr, target_id, target_entry)
	end)
end

return M
