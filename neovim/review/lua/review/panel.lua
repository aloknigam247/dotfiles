local chat = require("review.chat")
local provider = require("review.provider")
local state = require("review.state")
local util = require("review.util")

local M = {}

local severity_hl = {
	high = "ReviewSeverityHigh",
	medium = "ReviewSeverityMedium",
	low = "ReviewSeverityLow",
	info = "ReviewSeverityInfo",
}

local status_border_hl = {
	pending  = "ReviewBorderPending",
	accepted = "ReviewBorderAccepted",
	rejected = "ReviewBorderRejected",
}

local status_hl = {
	pending  = "ReviewStatusPending",
	accepted = "ReviewStatusAccepted",
	rejected = "ReviewStatusRejected",
}

-- Single-instance state
local panel = {
	win = nil,        ---@type integer|nil
	buf = nil,        ---@type integer|nil
	id = nil,         ---@type string|nil   active comment id
	input_start = 0,  ---@type integer      0-based line where reply input begins (-1 = no input region)
	popup_ns = vim.api.nvim_create_namespace("review_panel"),
}

---@return boolean
function M.is_open()
	return panel.win ~= nil and vim.api.nvim_win_is_valid(panel.win)
end

local function safe_close()
	if panel.win and vim.api.nvim_win_is_valid(panel.win) then
		pcall(vim.api.nvim_win_close, panel.win, true)
	end
	if panel.buf and vim.api.nvim_buf_is_valid(panel.buf) then
		pcall(vim.api.nvim_buf_delete, panel.buf, { force = true })
	end
	panel.win = nil
	panel.buf = nil
	panel.id = nil
end

function M.close()
	safe_close()
end

local function build_title(c)
	local sev_hl = severity_hl[c.severity] or "ReviewSeverityInfo"
	local stat_hl = status_hl[c.status] or "ReviewStatusPending"
	local b = status_border_hl[c.status] or "ReviewBorderPending"
	return {
		{ " ", b },
		{ c.category or "Comment", "ReviewCategory" },
		{ " · ", b },
		{ (c.severity or "info"):upper(), sev_hl },
		{ " · ", b },
		{ c.status or "pending", stat_hl },
		{ " · ", b },
		{ c.author or "?", "ReviewAuthor" },
		{ " ", b },
	}
end

local function build_footer(c)
	local b = status_border_hl[c.status] or "ReviewBorderPending"
	return {
		{ " ", b },
		{ "a", "ReviewStatusAccepted" }, { ":Accept ", b },
		{ "x", "ReviewStatusRejected" }, { ":Reject ", b },
		{ "r", "ReviewCategory" }, { ":Reply ", b },
		{ "]c/[c", "ReviewAuthor" }, { ":Nav ", b },
		{ "<Esc>", "ReviewStatusPending" }, { ":Close", b },
	}
end

--- Compute the (target_line, target_col) of the comment in the parent window
--- Used to position the floating panel near the comment
local function panel_geom(parent_win)
	local cols = vim.o.columns
	local width = math.min(math.floor(cols * 0.6), 90)
	-- Height computed dynamically from content; cap at 25
	return width
end

--- Set buffer content + per-line highlights, mark non-input lines read-only via cursor clamp
local function fill_buffer(c, width)
	local thread_lines, thread_hls = chat.render(c, width - 2)
	-- Separator + Reply: prompt
	thread_lines[#thread_lines + 1] = string.rep("─", width - 2)
	thread_hls[#thread_hls + 1] = "ReviewChatSep"
	thread_lines[#thread_lines + 1] = "Reply (press <C-s> to send):"
	thread_hls[#thread_hls + 1] = "ReviewCategory"
	local input_start = #thread_lines -- 0-based index where input begins (i.e. next line)
	thread_lines[#thread_lines + 1] = ""

	-- Set into the buffer
	vim.bo[panel.buf].modifiable = true
	vim.api.nvim_buf_set_lines(panel.buf, 0, -1, false, thread_lines)

	-- Apply per-line highlights (skip empty hl_group)
	vim.api.nvim_buf_clear_namespace(panel.buf, panel.popup_ns, 0, -1)
	for i, hl in ipairs(thread_hls) do
		if hl ~= "" then
			vim.api.nvim_buf_set_extmark(panel.buf, panel.popup_ns, i - 1, 0, { line_hl_group = hl })
		end
	end

	panel.input_start = input_start
	return #thread_lines
end

--- Create or refresh the floating panel for a given comment id
---@param comment_id string
function M.open(comment_id)
	local c = state.get(comment_id)
	if not c then
		util.notify("comment not found: " .. comment_id, vim.log.levels.WARN)
		return
	end

	state.set_active(comment_id)

	-- Reuse existing buffer/window if open
	local parent_win = vim.api.nvim_get_current_win()
	local width = panel_geom(parent_win)

	if not M.is_open() then
		panel.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[panel.buf].buftype = "nofile"
		vim.bo[panel.buf].swapfile = false
	end

	local total_lines = fill_buffer(c, width)
	local height = math.min(total_lines + 1, 25)

	if not M.is_open() then
		local b = status_border_hl[c.status] or "ReviewBorderPending"
		panel.win = vim.api.nvim_open_win(panel.buf, true, {
			relative = "cursor",
			row = 1,
			col = 0,
			width = width,
			height = height,
			style = "minimal",
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			title = build_title(c),
			title_pos = "center",
			footer = build_footer(c),
			footer_pos = "center",
			focusable = true,
			zindex = 50,
		})
		vim.wo[panel.win].winhighlight = "Normal:ReviewPanelNormal,NormalFloat:ReviewPanelNormal,FloatBorder:" .. b
		vim.wo[panel.win].cursorline = true
		vim.wo[panel.win].spell = false
		M._setup_keymaps(c.id)
		M._setup_cursor_clamp()
	else
		-- Refresh in place
		vim.api.nvim_win_set_config(panel.win, {
			relative = "cursor",
			row = 1,
			col = 0,
			width = width,
			height = height,
			title = build_title(c),
			title_pos = "center",
			footer = build_footer(c),
			footer_pos = "center",
		})
		local b = status_border_hl[c.status] or "ReviewBorderPending"
		vim.wo[panel.win].winhighlight = "Normal:ReviewPanelNormal,NormalFloat:ReviewPanelNormal,FloatBorder:" .. b
	end

	panel.id = comment_id
	-- Position cursor on input line
	pcall(vim.api.nvim_win_set_cursor, panel.win, { panel.input_start + 1, 0 })
end

function M.toggle(comment_id)
	if M.is_open() and panel.id == comment_id then
		M.close()
	else
		M.open(comment_id)
	end
end

function M.refresh()
	if not M.is_open() or not panel.id then return end
	local c = state.get(panel.id)
	if not c then return end
	local width = vim.api.nvim_win_get_width(panel.win)
	local total = fill_buffer(c, width)
	vim.api.nvim_win_set_config(panel.win, {
		title = build_title(c),
		title_pos = "center",
		footer = build_footer(c),
		footer_pos = "center",
	})
	local b = status_border_hl[c.status] or "ReviewBorderPending"
	vim.wo[panel.win].winhighlight = "Normal:ReviewPanelNormal,NormalFloat:ReviewPanelNormal,FloatBorder:" .. b
	pcall(vim.api.nvim_win_set_height, panel.win, math.min(total + 1, 25))
end

local function get_reply_text()
	if not panel.buf or not vim.api.nvim_buf_is_valid(panel.buf) then return "" end
	local lines = vim.api.nvim_buf_get_lines(panel.buf, panel.input_start, -1, false)
	return (table.concat(lines, "\n"):match("^(.-)%s*$") or "")
end

local function clear_reply_input()
	if not panel.buf or not vim.api.nvim_buf_is_valid(panel.buf) then return end
	vim.bo[panel.buf].modifiable = true
	vim.api.nvim_buf_set_lines(panel.buf, panel.input_start, -1, false, { "" })
end

--- Submit the reply input via the owning provider
function M.submit_reply()
	if not panel.id then return end
	local body = get_reply_text()
	if body == "" then
		util.notify("reply is empty", vim.log.levels.WARN)
		return
	end
	local c = state.get(panel.id)
	if not c then return end
	local ok, msg = provider.call(c.provider, "reply", panel.id, body)
	if not ok or not msg then
		util.notify("reply failed", vim.log.levels.WARN)
		return
	end
	state.add_message(panel.id, msg)
	clear_reply_input()
	M.refresh()
end

--- Toggle a status; if already that status, revert to pending
local function toggle_status(target)
	if not panel.id then return end
	local c = state.get(panel.id)
	if not c then return end
	local new_status = (c.status == target) and "pending" or target
	local ok = provider.call(c.provider, "set_status", panel.id, new_status)
	if not ok then
		util.notify("status change not supported by provider", vim.log.levels.WARN)
		return
	end
	state.update_status(panel.id, new_status)
	M.refresh()
end

function M._setup_keymaps(_comment_id)
	local kopts = { buffer = panel.buf, noremap = true, silent = true }
	vim.keymap.set("n", "a", function() toggle_status("accepted") end, kopts)
	vim.keymap.set("n", "x", function() toggle_status("rejected") end, kopts)
	vim.keymap.set("n", "r", function()
		if panel.win and vim.api.nvim_win_is_valid(panel.win) then
			pcall(vim.api.nvim_win_set_cursor, panel.win, { panel.input_start + 1, 0 })
			vim.cmd("startinsert!")
		end
	end, kopts)
	vim.keymap.set("n", "<Esc>", M.close, kopts)
	vim.keymap.set("n", "q", M.close, kopts)
	vim.keymap.set({ "n", "i" }, "<C-s>", function()
		vim.cmd("stopinsert")
		M.submit_reply()
	end, kopts)
end

--- Clamp cursor to input region (prevent edits to comment/thread area)
function M._setup_cursor_clamp()
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = panel.buf,
		callback = function()
			if not panel.win or not vim.api.nvim_win_is_valid(panel.win) then return end
			local row = vim.api.nvim_win_get_cursor(panel.win)[1]
			if row <= panel.input_start then
				pcall(vim.api.nvim_win_set_cursor, panel.win, { panel.input_start + 1, 0 })
			end
		end,
	})
end

return M
