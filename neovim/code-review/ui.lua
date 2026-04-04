local M = {}

local icons = {
	accepted = "󰄬",
	pending = "󰅐",
	question = "󰋗",
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
	question = "CodeReviewQuestion",
	rejected = "CodeReviewRejected",
}

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

--- Pad string to exact width (right-pad with spaces)
---@param str string
---@param width integer
---@return string
local function pad_right(str, width)
	local display_width = vim.fn.strdisplaywidth(str)
	if display_width >= width then
		return str
	end
	return str .. string.rep(" ", width - display_width)
end

--- Build virtual lines for a comment box
---@param entry table CodeReview.Entry
---@param box_width integer
---@return table[] virt_lines
function M.build_comment_box(entry, box_width)
	local inner_width = box_width - 4 -- "│ " + content + " │"
	local virt_lines = {}

	-- Header: ╭─── Category │ SEVERITY │ status ───╮
	local header_content = " " .. entry.category .. " │ " .. entry.severity:upper() .. " │ "
		.. (icons[entry.status] or "") .. " " .. entry.status .. " "
	local header_fill = box_width - 2 - vim.fn.strdisplaywidth(header_content) -- subtract ╭ and ╮
	if header_fill < 0 then
		header_fill = 0
	end
	local header_left_fill = 3
	local header_right_fill = header_fill - header_left_fill
	if header_right_fill < 0 then
		header_right_fill = 0
	end

	virt_lines[#virt_lines + 1] = {
		{ "╭" .. string.rep("─", header_left_fill), "CodeReviewBorder" },
		{ entry.category, "CodeReviewText" },
		{ " │ ", "CodeReviewBorder" },
		{ entry.severity:upper(), severity_hl[entry.severity] or "CodeReviewText" },
		{ " │ ", "CodeReviewBorder" },
		{ (icons[entry.status] or "") .. " " .. entry.status, status_hl[entry.status] or "CodeReviewPending" },
		{ " " .. string.rep("─", header_right_fill) .. "╮", "CodeReviewBorder" },
	}

	-- Comment body lines
	local wrapped = wrap_text(entry.comment, inner_width)
	for _, line in ipairs(wrapped) do
		virt_lines[#virt_lines + 1] = {
			{ "│ ", "CodeReviewBorder" },
			{ pad_right(line, inner_width), "CodeReviewText" },
			{ " │", "CodeReviewBorder" },
		}
	end

	-- Action buttons line
	local btn_accept = icons.accepted .. " Accept"
	local btn_reject = icons.rejected .. " Reject"
	local btn_question = icons.question .. " Question"
	local buttons = " " .. btn_accept .. "   " .. btn_reject .. "   " .. btn_question
	virt_lines[#virt_lines + 1] = {
		{ "│ ", "CodeReviewBorder" },
		{ pad_right(buttons, inner_width), "CodeReviewText" },
		{ " │", "CodeReviewBorder" },
	}

	-- Bottom border: ╰───────╯
	virt_lines[#virt_lines + 1] = {
		{ "╰" .. string.rep("─", box_width - 2) .. "╯", "CodeReviewBorder" },
	}

	return virt_lines
end

--- Compute box width for a given window
---@param winid integer
---@return integer
function M.get_box_width(winid)
	local win_width = vim.api.nvim_win_get_width(winid)
	-- Estimate gutter width (sign column + number column + fold column)
	local gutter = vim.fn.getwininfo(winid)[1].textoff or 0
	return math.min(80, win_width - gutter)
end

--- Render all review entries for a buffer
---@param bufnr integer
---@param entries table[] CodeReview.Entry[]
---@param ns integer namespace id
---@return table<integer, table> extmark_id -> entry mapping
function M.render_reviews(bufnr, entries, ns)
	local winid = vim.fn.bufwinid(bufnr)
	if winid == -1 then
		winid = 0
	end
	local box_width = M.get_box_width(winid)
	local extmark_map = {}

	for _, entry in ipairs(entries) do
		local line = entry.line - 1 -- 0-based
		if line < 0 then
			line = 0
		end
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		if line >= line_count then
			line = line_count - 1
		end

		local virt_lines = M.build_comment_box(entry, box_width)
		local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
			virt_lines = virt_lines,
			virt_lines_above = false,
		})
		extmark_map[extmark_id] = entry
	end

	return extmark_map
end

--- Clear all review extmarks from a buffer
---@param bufnr integer
---@param ns integer namespace id
function M.clear_reviews(bufnr, ns)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

--- Jump to the next review extmark
---@param bufnr integer
---@param ns integer namespace id
function M.next_review(bufnr, ns)
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-based
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	table.sort(marks, function(a, b) return a[2] < b[2] end)

	for _, mark in ipairs(marks) do
		if mark[2] > cursor_line then
			vim.api.nvim_win_set_cursor(0, { mark[2] + 1, 0 })
			return
		end
	end
	-- Wrap around to first
	if #marks > 0 then
		vim.api.nvim_win_set_cursor(0, { marks[1][2] + 1, 0 })
	end
end

--- Jump to the previous review extmark
---@param bufnr integer
---@param ns integer namespace id
function M.prev_review(bufnr, ns)
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-based
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	table.sort(marks, function(a, b) return a[2] > b[2] end) -- reverse sort

	for _, mark in ipairs(marks) do
		if mark[2] < cursor_line then
			vim.api.nvim_win_set_cursor(0, { mark[2] + 1, 0 })
			return
		end
	end
	-- Wrap around to last
	if #marks > 0 then
		vim.api.nvim_win_set_cursor(0, { marks[1][2] + 1, 0 })
	end
end

return M
