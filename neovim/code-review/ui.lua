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

--- Update comment window chrome (border color, title, footer)
---@param float_win integer
---@param entry table
local function update_chrome(float_win, entry)
	if not vim.api.nvim_win_is_valid(float_win) then
		return
	end
	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	vim.wo[float_win].winhighlight = "Normal:CodeReviewText,NormalFloat:CodeReviewText,FloatBorder:" .. bhl .. ",CursorLine:CodeReviewInput"
	vim.api.nvim_win_set_config(float_win, {
		title = M.build_title(entry),
		title_pos = "center",
		footer = M.build_footer(entry),
		footer_pos = "center",
	})
end

--- Open the code review window for an entry
---@param entry table CodeReview.Entry
---@param on_update fun(entry: table) called after status/response change
function M.open_review_window(entry, on_update)
	local float_width = 60
	local inner_width = float_width - 2

	-- Comment window: read-only wrapped comment text
	local comment_lines = wrap_text(entry.comment, inner_width)
	local comment_height = math.min(#comment_lines, 15)

	local comment_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(comment_buf, 0, -1, false, comment_lines)
	vim.bo[comment_buf].buftype = "nofile"
	vim.bo[comment_buf].modifiable = false

	local bhl = border_hl[entry.status] or "CodeReviewBorderBase"
	local comment_win = vim.api.nvim_open_win(comment_buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = float_width,
		height = comment_height,
		style = "minimal",
		border = { "╭", "─", "╮", "│", "┤", "─", "├", "│" },
		title = M.build_title(entry),
		title_pos = "center",
		footer = M.build_footer(entry),
		footer_pos = "center",
		focusable = true,
		zindex = 50,
	})
	vim.wo[comment_win].winhighlight = "Normal:CodeReviewText,NormalFloat:CodeReviewText,FloatBorder:" .. bhl

	-- Prompt window: editable, positioned directly below comment window
	local prompt_lines = { entry.response or "" }
	local prompt_height = 3

	local prompt_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, prompt_lines)
	vim.bo[prompt_buf].buftype = "nofile"
	vim.bo[prompt_buf].modifiable = true

	local prompt_win = vim.api.nvim_open_win(prompt_buf, false, {
		relative = "win",
		win = comment_win,
		row = comment_height + 2, -- directly below comment window border
		col = -1,
		width = float_width,
		height = prompt_height,
		style = "minimal",
		border = { "├", "─", "┤", "│", "╯", "─", "╰", "│" },
		title = { { " Prompt ", "CodeReviewPrompt" } },
		title_pos = "center",
		focusable = true,
		zindex = 50,
	})
	vim.wo[prompt_win].winhighlight = "Normal:CodeReviewInput,NormalFloat:CodeReviewInput,FloatBorder:" .. bhl
	vim.wo[prompt_win].cursorline = true

	-- State
	local closed = false

	local function get_response()
		if not vim.api.nvim_buf_is_valid(prompt_buf) then
			return entry.response or ""
		end
		local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false)
		return (table.concat(lines, "\n"):match("^(.-)%s*$") or "")
	end

	local function set_status(new_status)
		if entry.status == new_status then
			entry.status = "pending"
		else
			entry.status = new_status
		end
		entry.response = get_response()
		update_chrome(comment_win, entry)
		-- Sync prompt border color
		local new_bhl = border_hl[entry.status] or "CodeReviewBorderBase"
		if vim.api.nvim_win_is_valid(prompt_win) then
			vim.wo[prompt_win].winhighlight = "Normal:CodeReviewInput,NormalFloat:CodeReviewInput,FloatBorder:" .. new_bhl
		end
		on_update(entry)
	end

	local function close_all()
		if closed then
			return
		end
		closed = true
		entry.response = get_response()
		for _, w in ipairs({ comment_win, prompt_win }) do
			if vim.api.nvim_win_is_valid(w) then
				vim.api.nvim_win_close(w, true)
			end
		end
		for _, b in ipairs({ comment_buf, prompt_buf }) do
			if vim.api.nvim_buf_is_valid(b) then
				vim.api.nvim_buf_delete(b, { force = true })
			end
		end
		on_update(entry)
	end

	--- Jump between comment and prompt windows
	local function jump_to_prompt()
		if vim.api.nvim_win_is_valid(prompt_win) then
			vim.api.nvim_set_current_win(prompt_win)
		end
	end

	local function jump_to_comment()
		if vim.api.nvim_win_is_valid(comment_win) then
			vim.api.nvim_set_current_win(comment_win)
		end
	end

	-- Comment window keymaps
	vim.keymap.set("n", "A", function() set_status("accepted") end, { buffer = comment_buf, noremap = true })
	vim.keymap.set("n", "R", function() set_status("rejected") end, { buffer = comment_buf, noremap = true })
	vim.keymap.set("n", "P", jump_to_prompt, { buffer = comment_buf, noremap = true })
	vim.keymap.set("n", "<Esc>", close_all, { buffer = comment_buf, noremap = true })
	vim.keymap.set("n", "q", close_all, { buffer = comment_buf, noremap = true })
	vim.keymap.set("n", "<Tab>", jump_to_prompt, { buffer = comment_buf, noremap = true })

	-- Prompt window keymaps
	vim.keymap.set("n", "A", function() set_status("accepted") end, { buffer = prompt_buf, noremap = true })
	vim.keymap.set("n", "R", function() set_status("rejected") end, { buffer = prompt_buf, noremap = true })
	vim.keymap.set("n", "<Esc>", close_all, { buffer = prompt_buf, noremap = true })
	vim.keymap.set("n", "q", close_all, { buffer = prompt_buf, noremap = true })
	vim.keymap.set("n", "<Tab>", jump_to_comment, { buffer = prompt_buf, noremap = true })

	-- Close both on BufLeave from either window
	for _, buf in ipairs({ comment_buf, prompt_buf }) do
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buf,
			once = true,
			callback = function()
				vim.schedule(function()
					-- Only close if focus left BOTH windows (not just switching between them)
					local cur_buf = vim.api.nvim_get_current_buf()
					if cur_buf ~= comment_buf and cur_buf ~= prompt_buf then
						close_all()
					end
				end)
			end,
		})
	end
end

return M
