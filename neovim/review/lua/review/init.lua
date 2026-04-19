local diagnostics = require("review.diagnostics")
local nav = require("review.nav")
local panel = require("review.panel")
local provider = require("review.provider")
local state = require("review.state")
local tree = require("review.tree")
local util = require("review.util")

local M = {}

local default_highlights = {
	-- Background tints for status (range bg via extmarks)
	ReviewBgAccepted     = { bg = "#a6e3a1" },
	ReviewBgPending      = { bg = "#89b4fa" },
	ReviewBgRejected     = { bg = "#f38ba8" },

	-- Border colors for the panel
	ReviewBorderAccepted = { fg = "#a6e3a1" },
	ReviewBorderPending  = { fg = "#89b4fa" },
	ReviewBorderRejected = { fg = "#f38ba8" },

	-- Title chunks
	ReviewCategory       = { fg = "#cba6f7", bold = true },
	ReviewAuthor         = { fg = "#94e2d5", italic = true },

	ReviewSeverityHigh   = { fg = "#f38ba8", bold = true },
	ReviewSeverityMedium = { fg = "#fab387", bold = true },
	ReviewSeverityLow    = { fg = "#89b4fa" },
	ReviewSeverityInfo   = { fg = "#a6adc8" },

	ReviewStatusAccepted = { fg = "#a6e3a1", bold = true },
	ReviewStatusPending  = { fg = "#89b4fa" },
	ReviewStatusRejected = { fg = "#f38ba8", bold = true },

	-- Chat / panel content
	ReviewChatAuthor     = { fg = "#cba6f7", italic = true },
	ReviewChatBody       = { link = "Normal" },
	ReviewChatSep        = { fg = "#45475a" },

	-- Panel base bg matches Normal so it doesn't go float-grey
	ReviewPanelNormal    = { link = "Normal" },
}

---@class ReviewSetupOpts
---@field providers? Provider[]
---@field highlights? table<string, table>
---@field keymaps? boolean              -- default true; opt-out
---@field auto_render? boolean          -- default true; render on BufEnter

local opts_default = {
	providers = {},
	highlights = {},
	keymaps = true,
	auto_render = true,
}

local user_opts = opts_default
local augroup = nil

local function apply_highlights()
	local hls = vim.tbl_deep_extend("force", default_highlights, user_opts.highlights or {})
	-- Resolve ReviewPanelNormal from Normal so float bg matches editor (not NormalFloat)
	if hls.ReviewPanelNormal and hls.ReviewPanelNormal.link == "Normal" then
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		hls.ReviewPanelNormal = { fg = normal.fg, bg = normal.bg }
	end
	for name, hl in pairs(hls) do
		vim.api.nvim_set_hl(0, name, hl)
	end
end

local function setup_buf_keymaps(bufnr)
	if not user_opts.keymaps then return end
	local k = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end
	k("]c", nav.next, "Next review comment")
	k("[c", nav.prev, "Previous review comment")
	k("<leader>rc", function()
		local id = nav.find_at_cursor()
		if id then panel.open(id) end
	end, "Open review panel")
	k("<leader>rt", tree.open, "Open review tree")
	k("<leader>ra", function()
		local id = nav.find_at_cursor()
		if not id then return end
		local c = state.get(id); if not c then return end
		local new_status = c.status == "accepted" and "pending" or "accepted"
		local ok = provider.call(c.provider, "set_status", id, new_status)
		if ok then
			state.update_status(id, new_status)
			diagnostics.render(bufnr)
		end
	end, "Accept review")
	k("<leader>rx", function()
		local id = nav.find_at_cursor()
		if not id then return end
		local c = state.get(id); if not c then return end
		local new_status = c.status == "rejected" and "pending" or "rejected"
		local ok = provider.call(c.provider, "set_status", id, new_status)
		if ok then
			state.update_status(id, new_status)
			diagnostics.render(bufnr)
		end
	end, "Reject review")
	k("<leader>rr", function()
		local id = nav.find_at_cursor()
		if not id then return end
		panel.open(id)
		-- panel.open puts cursor on input line already; jump to insert
		vim.cmd("startinsert!")
	end, "Reply to review")
end

--- Render and wire keymaps for a buffer if it has comments
---@param bufnr integer
function M.render(bufnr)
	local key = util.buf_file_key(bufnr)
	if not key then return end
	local comments = state.by_file(key)
	if not comments or #comments == 0 then return end
	diagnostics.render(bufnr)
	setup_buf_keymaps(bufnr)
end

--- Setup the plugin (call from user config or :Review setup)
---@param opts? ReviewSetupOpts
function M.setup(opts)
	user_opts = vim.tbl_deep_extend("force", opts_default, opts or {})
	apply_highlights()
	diagnostics.configure()

	-- Register providers from config
	for _, p in ipairs(user_opts.providers or {}) do
		provider.register(p)
	end

	-- Auto-render on BufEnter
	if user_opts.auto_render then
		if augroup then pcall(vim.api.nvim_del_augroup_by_id, augroup) end
		augroup = vim.api.nvim_create_augroup("ReviewAutoRender", { clear = true })
		vim.api.nvim_create_autocmd("BufEnter", {
			group = augroup,
			callback = function(args) M.render(args.buf) end,
		})
	end

	-- Refresh diagnostics on status/message changes
	state.on("status_changed", function()
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(b) then diagnostics.render(b) end
		end
	end)
	state.on("comments_loaded", function()
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(b) then M.render(b) end
		end
	end)
end

--- Load comments from registered providers
---@param provider_name? string
function M.load(provider_name)
	local comments = provider.load(provider_name)
	state.set_comments(comments)
	local file_count = #state.files()
	util.notify(("loaded %d comments across %d files"):format(#comments, file_count))
end

--- Clear all state and rendering
function M.clear()
	panel.close()
	for b in pairs(state.all()) do _ = b end -- noop just to avoid lint
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(b) then diagnostics.clear(b) end
	end
	state.reset()
end

--- Public command dispatcher (used by :Review user command)
---@param subcmd string
---@param args string[]
function M.cmd(subcmd, args)
	args = args or {}
	if subcmd == "load" then
		M.load(args[1])
	elseif subcmd == "tree" then
		tree.open()
	elseif subcmd == "panel" then
		local id = nav.find_at_cursor()
		if id then panel.open(id) else util.notify("no review at cursor", vim.log.levels.WARN) end
	elseif subcmd == "reply" then
		local id = nav.find_at_cursor()
		if id then panel.open(id); vim.cmd("startinsert!") end
	elseif subcmd == "accept" then
		local id = nav.find_at_cursor()
		if not id then return end
		local c = state.get(id); if not c then return end
		local ok = provider.call(c.provider, "set_status", id, "accepted")
		if ok then state.update_status(id, "accepted") end
	elseif subcmd == "reject" then
		local id = nav.find_at_cursor()
		if not id then return end
		local c = state.get(id); if not c then return end
		local ok = provider.call(c.provider, "set_status", id, "rejected")
		if ok then state.update_status(id, "rejected") end
	elseif subcmd == "next" then
		nav.next()
	elseif subcmd == "prev" then
		nav.prev()
	elseif subcmd == "clear" then
		M.clear()
	else
		util.notify("unknown subcommand: " .. tostring(subcmd), vim.log.levels.WARN)
	end
end

M.subcommands = { "accept", "clear", "load", "next", "panel", "prev", "reject", "reply", "tree" }

return M
