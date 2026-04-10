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

--- Build colorized title chunks for the float border
---@param entry table
---@return table[]
function M.build_title(entry)
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	return {
		{ " ", bhl },
		{ entry.category, "CodeReviewCategory" },
		{ " │ ", bhl },
		{ entry.severity:upper(), severity_hl[entry.severity] or "CodeReviewSeverity" },
		{ " │ ", bhl },
		{ (status_icons[entry.status] or "") .. " " .. entry.status, status_hl[entry.status] or "CodeReviewPending" },
		{ " ", bhl },
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
		{ "<Esc>", "CodeReviewPending" }, { ":Close", bhl },
		{ " ", bhl },
	}
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

--- Open the code review window for an entry
---@param entry table CodeReview.Entry
---@param on_update fun(entry: table) called after status/response change
function M.open_review_window(entry, on_update)
	local float_width = 60
	local inner_width = float_width - 2

	-- Build buffer content: comment (wrapped, read-only) + input (editable)
	local comment_lines = wrap_text(entry.comment, inner_width)
	local content = {}
	for _, cline in ipairs(comment_lines) do
		content[#content + 1] = cline
	end
	local input_start = #content -- 0-based index of first input line
	content[#content + 1] = entry.response or ""

	local float_height = math.min(#content + 1, 20)

	-- Create buffer
	local float_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, content)
	vim.bo[float_buf].buftype = "nofile"
	vim.bo[float_buf].modifiable = true

	-- Highlight comment lines with window bg, input with distinct bg
	local popup_ns = vim.api.nvim_create_namespace("code_review_popup")
	for i = 0, input_start - 1 do
		vim.api.nvim_buf_set_extmark(float_buf, popup_ns, i, 0, { line_hl_group = "CodeReviewText" })
	end
	for i = input_start, #content - 1 do
		vim.api.nvim_buf_set_extmark(float_buf, popup_ns, i, 0, { line_hl_group = "CodeReviewInput" })
	end

	-- Clamp cursor to input area
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = float_buf,
		callback = function()
			local row = vim.api.nvim_win_get_cursor(0)[1]
			if row <= input_start then
				vim.api.nvim_win_set_cursor(0, { input_start + 1, 0 })
			end
		end,
	})

	-- Create float window
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	local float_win = vim.api.nvim_open_win(float_buf, true, {
		relative = "cursor",
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

	-- Place cursor on input line
	vim.api.nvim_win_set_cursor(float_win, { input_start + 1, 0 })

	-- Helpers
	local closed = false

	local function get_response()
		if not vim.api.nvim_buf_is_valid(float_buf) then
			return entry.response or ""
		end
		local lines = vim.api.nvim_buf_get_lines(float_buf, input_start, -1, false)
		return (table.concat(lines, "\n"):match("^(.-)%s*$") or "")
	end

	local function close()
		if closed then
			return
		end
		closed = true
		entry.response = get_response()
		if vim.api.nvim_win_is_valid(float_win) then
			vim.api.nvim_win_close(float_win, true)
		end
		if vim.api.nvim_buf_is_valid(float_buf) then
			vim.api.nvim_buf_delete(float_buf, { force = true })
		end
	end

	local function set_status_and_close(new_status)
		entry.status = new_status
		close()
		on_update(entry)
	end

	local function close_only()
		close()
		on_update(entry)
	end

	-- Window-local keymaps (normal mode)
	vim.keymap.set("n", "A", function() set_status_and_close("accepted") end, { buffer = float_buf, noremap = true })
	vim.keymap.set("n", "R", function() set_status_and_close("rejected") end, { buffer = float_buf, noremap = true })
	vim.keymap.set("n", "P", function() set_status_and_close("prompt") end, { buffer = float_buf, noremap = true })
	vim.keymap.set("n", "<Esc>", close_only, { buffer = float_buf, noremap = true })
	vim.keymap.set("n", "q", close_only, { buffer = float_buf, noremap = true })

	-- Close on BufLeave
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = float_buf,
		once = true,
		callback = function()
			vim.schedule(close_only)
		end,
	})
end

return M
