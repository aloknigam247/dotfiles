local util = require("review.util")

local M = {}

--- Render a Comment + its thread as a list of {text, hl_group} chunks per line
--- Returns a flat list of plain lines (strings) and a parallel list of per-line hl groups.
---@param comment Comment
---@param width integer
---@return string[] lines, string[] line_hls
function M.render(comment, width)
	local lines = {}
	local hls = {}

	-- Initial comment as the first message
	local function push(text, hl)
		for _, l in ipairs(util.wrap(text, width)) do
			lines[#lines + 1] = l
			hls[#hls + 1] = hl or ""
		end
	end

	-- Initial post (the review body itself)
	local header = comment.author or "reviewer"
	if comment.timestamp then
		header = header .. " · " .. comment.timestamp
	end
	push(header, "ReviewChatAuthor")
	push(comment.body or "", "ReviewChatBody")

	-- Replies in thread
	for _, msg in ipairs(comment.thread or {}) do
		lines[#lines + 1] = string.rep("─", width)
		hls[#hls + 1] = "ReviewChatSep"
		local h = (msg.author or "?") .. (msg.timestamp and (" · " .. msg.timestamp) or "")
		if msg.pending then h = h .. "  …sending" end
		push(h, "ReviewChatAuthor")
		push(msg.body or "", "ReviewChatBody")
	end

	return lines, hls
end

return M
