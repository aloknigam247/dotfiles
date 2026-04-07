local M = {}

local status_icons = {
	accepted = "󰄬",
	pending = "󰅐",
	prompt = "󰋗",
	rejected = "󰅖",
}

local severity_hl = {
	high = "CodeReviewHigh",
	info = "CodeReviewInfo",
	low = "CodeReviewLow",
	medium = "CodeReviewMedium",
}

local status_hl = {
	accepted = "CodeReviewAccepted",
	pending = "CodeReviewPending",
	prompt = "CodeReviewPrompt",
	rejected = "CodeReviewRejected",
}

local border_hl = {
	accepted = "CodeReviewBorderGreen",
	pending = "CodeReviewBorderBase",
	prompt = "CodeReviewBorderBase",
	rejected = "CodeReviewBorderRed",
}

--- Clamp a column value to the actual byte length of a buffer line
---@param bufnr integer
---@param line integer 0-based line number
---@param col integer 0-based column, or -1 for end-of-line
---@return integer
local function clamp_col(bufnr, line, col)
	local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
	if col < 0 then
		return #text
	end
	return math.min(col, #text)
end

--- Word-wrap text to a given width
---@param text string
---@param width integer
---@return string[]
local function wrap_text(text, width)
	local lines = {}
	for _, paragraph in ipairs(vim.split(text, "\n")) do
		if #paragraph == 0 then
			lines[#lines + 1] = ""
		else
			while #paragraph > width do
				local break_at = paragraph:sub(1, width):find("%s[^%s]*$") or width
				lines[#lines + 1] = paragraph:sub(1, break_at - 1)
				paragraph = paragraph:sub(break_at + 1)
			end
			if #paragraph > 0 then
				lines[#lines + 1] = paragraph
			end
		end
	end
	return lines
end

--- Build colorized title chunks for the float border
---@param entry table
---@return table[] title chunks for nvim_open_win
function M.build_title(entry)
	local sev_highlight = severity_hl[entry.severity] or "CodeReviewSeverity"
	local stat_highlight = status_hl[entry.status] or "CodeReviewPending"
	return {
		{ " ", border_hl[entry.status] or "CodeReviewBorderBase" },
		{ entry.category, "CodeReviewCategory" },
		{ " │ ", border_hl[entry.status] or "CodeReviewBorderBase" },
		{ entry.severity:upper(), sev_highlight },
		{ " │ ", border_hl[entry.status] or "CodeReviewBorderBase" },
		{ (status_icons[entry.status] or "") .. " " .. entry.status, stat_highlight },
		{ " ", border_hl[entry.status] or "CodeReviewBorderBase" },
	}
end

--- Build colorized footer chunks
---@param entry table
---@return table[]
function M.build_footer(entry)
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	return {
		{ " ", bhl },
		{ "A", "CodeReviewAccepted" }, { ":Accept", bhl },
		{ "  ", bhl },
		{ "R", "CodeReviewRejected" }, { ":Reject", bhl },
		{ "  ", bhl },
		{ "P", "CodeReviewPrompt" }, { ":Prompt", bhl },
		{ "  ", bhl },
		{ "<Esc>", "CodeReviewPending" }, { ":Back", bhl },
		{ " ", bhl },
	}
end

--- Update float border color and title/footer based on current status
---@param float_win integer
---@param entry table
local function update_float_chrome(float_win, entry)
	if not vim.api.nvim_win_is_valid(float_win) then
		return
	end
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	vim.api.nvim_win_set_config(float_win, {
		title = M.build_title(entry),
		title_pos = "center",
		footer = M.build_footer(entry),
		footer_pos = "center",
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
	})
	-- Update border highlight
	local win_buf = vim.api.nvim_win_get_buf(float_win)
	local current_whl = vim.wo[float_win].winhighlight or ""
	-- Replace FloatBorder highlight
	local new_whl = current_whl:gsub("FloatBorder:%w+", "FloatBorder:" .. bhl)
	vim.wo[float_win].winhighlight = new_whl
end

--- Create a single review float: range highlight + spacer virt_lines + floating window
---@param parent_bufnr integer
---@param parent_win integer
---@param entry table CodeReview.Entry
---@param ns integer namespace id
---@return table float_info
function M.create_review_float(parent_bufnr, parent_win, entry, ns)
	local line_count = vim.api.nvim_buf_line_count(parent_bufnr)
	local start_line = math.max(0, math.min(entry.line - 1, line_count - 1))
	local end_line = math.max(0, math.min((entry.end_line or entry.line) - 1, line_count - 1))
	local start_col = clamp_col(parent_bufnr, start_line, (entry.col or 1) - 1)
	local raw_end_col = entry.end_col
	local end_col
	if not raw_end_col or raw_end_col == 0 then
		end_col = clamp_col(parent_bufnr, end_line, -1)
	else
		end_col = clamp_col(parent_bufnr, end_line, raw_end_col - 1)
	end

	-- 1. Range highlight extmark
	local hl_mark = vim.api.nvim_buf_set_extmark(parent_bufnr, ns, start_line, start_col, {
		end_row = end_line,
		end_col = end_col,
		hl_group = "CodeReviewLine",
	})

	-- 2. Build float buffer: comment (read-only, wrapped) + input (editable)
	local float_width = 60
	local inner_width = float_width - 2 -- account for some padding
	local comment_lines = wrap_text(entry.comment, inner_width)
	local content = {}
	for _, cline in ipairs(comment_lines) do
		content[#content + 1] = cline
	end
	local input_start = #content -- 0-based first input line (right after comment)
	content[#content + 1] = entry.response or ""

	local float_height = #content
	local total_height = float_height + 2 -- +2 for border

	-- 3. Spacer virt_lines to push code down
	local spacer_lines = {}
	for _ = 1, total_height do
		spacer_lines[#spacer_lines + 1] = { { " ", "" } }
	end
	local spacer_mark = vim.api.nvim_buf_set_extmark(parent_bufnr, ns, end_line, 0, {
		virt_lines = spacer_lines,
		virt_lines_above = false,
	})

	-- 4. Create float buffer
	local float_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, content)
	vim.bo[float_buf].buftype = "nofile"
	vim.bo[float_buf].modifiable = true

	-- 5. Highlight comment lines to match window bg (CodeReviewText), input lines distinct
	local popup_ns = vim.api.nvim_create_namespace("code_review_popup")
	for i = 0, input_start - 1 do
		vim.api.nvim_buf_set_extmark(float_buf, popup_ns, i, 0, { line_hl_group = "CodeReviewText" })
	end
	for i = input_start, #content - 1 do
		vim.api.nvim_buf_set_extmark(float_buf, popup_ns, i, 0, { line_hl_group = "CodeReviewInput" })
	end

	-- 6. Clamp cursor: prevent moving into comment area
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = float_buf,
		callback = function()
			local row = vim.api.nvim_win_get_cursor(0)[1]
			if row <= input_start then
				vim.api.nvim_win_set_cursor(0, { input_start + 1, 0 })
			end
		end,
	})

	-- 7. Create floating window anchored to buffer position
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	local float_win = vim.api.nvim_open_win(float_buf, false, {
		relative = "win",
		win = parent_win,
		bufpos = { end_line, 0 },
		row = 1,
		col = 0,
		width = float_width,
		height = float_height,
		style = "minimal",
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		title = M.build_title(entry),
		title_pos = "center",
		footer = M.build_footer(entry),
		footer_pos = "center",
		focusable = true,
		zindex = 50,
	})
	vim.wo[float_win].winhighlight = "Normal:CodeReviewText,NormalFloat:CodeReviewText,FloatBorder:" .. bhl .. ",CursorLine:CodeReviewInput"
	vim.wo[float_win].cursorline = true

	-- 8. Window-local keymaps
	local function get_response()
		if not vim.api.nvim_buf_is_valid(float_buf) then
			return entry.response or ""
		end
		local lines = vim.api.nvim_buf_get_lines(float_buf, input_start, -1, false)
		return (table.concat(lines, "\n"):match("^(.-)%s*$") or "")
	end

	local function set_status(new_status)
		entry.status = new_status
		entry.response = get_response()
		update_float_chrome(float_win, entry)
	end

	local function jump_back()
		entry.response = get_response()
		if vim.api.nvim_win_is_valid(parent_win) then
			vim.api.nvim_set_current_win(parent_win)
		end
	end

	vim.keymap.set("n", "A", function() set_status("accepted") end, { buffer = float_buf, noremap = true, desc = "Accept review" })
	vim.keymap.set("n", "R", function() set_status("rejected") end, { buffer = float_buf, noremap = true, desc = "Reject review" })
	vim.keymap.set("n", "P", function() set_status("prompt") end, { buffer = float_buf, noremap = true, desc = "Prompt review" })
	vim.keymap.set("n", "<Esc>", jump_back, { buffer = float_buf, noremap = true, desc = "Back to code" })
	vim.keymap.set("n", "q", jump_back, { buffer = float_buf, noremap = true, desc = "Back to code" })

	return {
		hl_mark = hl_mark,
		spacer_mark = spacer_mark,
		float_win = float_win,
		float_buf = float_buf,
		entry = entry,
		input_start = input_start,
		get_response = get_response,
	}
end

--- Render all reviews for a buffer: highlights + spacers + permanent floats
---@param parent_bufnr integer
---@param entries table[]
---@param ns integer
---@return table[] float_infos
function M.render_reviews(parent_bufnr, entries, ns)
	local parent_win = vim.fn.bufwinid(parent_bufnr)
	if parent_win == -1 then
		return {}
	end

	local floats = {}
	for _, entry in ipairs(entries) do
		floats[#floats + 1] = M.create_review_float(parent_bufnr, parent_win, entry, ns)
	end
	return floats
end

--- Clear all review extmarks and close all floats for a buffer
---@param bufnr integer
---@param ns integer
---@param floats table[]|nil
function M.clear_reviews(bufnr, ns, floats)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	if floats then
		for _, info in ipairs(floats) do
			if vim.api.nvim_win_is_valid(info.float_win) then
				vim.api.nvim_win_close(info.float_win, true)
			end
			if vim.api.nvim_buf_is_valid(info.float_buf) then
				vim.api.nvim_buf_delete(info.float_buf, { force = true })
			end
		end
	end
end

--- Focus the nearest review float relative to cursor
---@param floats table[]
function M.focus_nearest(floats)
	if not floats or #floats == 0 then
		return
	end

	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local best, best_dist = nil, math.huge

	for _, info in ipairs(floats) do
		local s = info.entry.line
		local e = info.entry.end_line or info.entry.line
		local dist
		if cursor_line >= s and cursor_line <= e then
			dist = 0
		else
			dist = math.min(math.abs(cursor_line - s), math.abs(cursor_line - e))
		end
		if dist < best_dist then
			best_dist = dist
			best = info
		end
	end

	if best and vim.api.nvim_win_is_valid(best.float_win) then
		vim.api.nvim_set_current_win(best.float_win)
		vim.api.nvim_win_set_cursor(best.float_win, { best.input_start + 1, 0 })
	end
end

--- Jump to the next review line
---@param floats table[]
function M.next_review(floats)
	if not floats or #floats == 0 then
		return
	end
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = {}
	for _, info in ipairs(floats) do
		lines[#lines + 1] = info.entry.line
	end
	table.sort(lines)

	for _, line in ipairs(lines) do
		if line > cursor_line then
			vim.api.nvim_win_set_cursor(0, { line, 0 })
			return
		end
	end
	vim.api.nvim_win_set_cursor(0, { lines[1], 0 })
end

--- Jump to the previous review line
---@param floats table[]
function M.prev_review(floats)
	if not floats or #floats == 0 then
		return
	end
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = {}
	for _, info in ipairs(floats) do
		lines[#lines + 1] = info.entry.line
	end
	table.sort(lines, function(a, b) return a > b end)

	for _, line in ipairs(lines) do
		if line < cursor_line then
			vim.api.nvim_win_set_cursor(0, { line, 0 })
			return
		end
	end
	vim.api.nvim_win_set_cursor(0, { lines[1], 0 })
end

return M
