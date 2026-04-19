local util = require("review.util")

local M = {}

---@class ReviewState
local state = {
	comments = {},   ---@type table<string, Comment>  id -> Comment
	by_file = {},    ---@type table<string, Comment[]>
	providers = {},  ---@type table<string, Provider>
	active_id = nil, ---@type string|nil
	listeners = {},  ---@type table<string, fun(payload)[]>
}

--- Reset all state (used by clear and reload)
function M.reset()
	state.comments = {}
	state.by_file = {}
	state.active_id = nil
	-- Don't clear providers or listeners — those are setup-time.
	M.emit("cleared", {})
end

--- Subscribe to a state event
---@param event string
---@param cb fun(payload: table)
function M.on(event, cb)
	state.listeners[event] = state.listeners[event] or {}
	table.insert(state.listeners[event], cb)
end

--- Emit an event to all subscribers
---@param event string
---@param payload table
function M.emit(event, payload)
	for _, cb in ipairs(state.listeners[event] or {}) do
		local ok, err = pcall(cb, payload)
		if not ok then
			util.notify("listener error for " .. event .. ": " .. tostring(err), vim.log.levels.WARN)
		end
	end
end

--- Add or update a list of comments (replaces existing by id)
---@param comments Comment[]
function M.set_comments(comments)
	state.comments = {}
	state.by_file = {}
	for _, c in ipairs(comments) do
		c.file = util.normalize_path(c.file)
		c.status = c.status or "pending"
		c.thread = c.thread or {}
		state.comments[c.id] = c
		state.by_file[c.file] = state.by_file[c.file] or {}
		table.insert(state.by_file[c.file], c)
	end
	M.emit("comments_loaded", { count = #comments })
end

--- Update a single comment's status (in place)
---@param id string
---@param status string
function M.update_status(id, status)
	local c = state.comments[id]
	if not c then return end
	c.status = status
	M.emit("status_changed", { id = id, status = status })
end

--- Notify that a message was added to a comment's thread.
--- Idempotent: if the message (by id) is already in the thread (because the
--- provider mutated the shared object), only emit the event. Otherwise append.
---@param id string
---@param msg Message
function M.add_message(id, msg)
	local c = state.comments[id]
	if not c then return end
	c.thread = c.thread or {}
	local already = false
	for _, existing in ipairs(c.thread) do
		if existing.id and msg.id and existing.id == msg.id then
			already = true
			break
		end
	end
	if not already then
		table.insert(c.thread, msg)
	end
	M.emit("message_added", { id = id, msg = msg })
end

--- Set the active comment (panel target)
---@param id string|nil
function M.set_active(id)
	state.active_id = id
	M.emit("active_changed", { id = id })
end

-- Accessors --------------------------------------------------------------

function M.get(id) return state.comments[id] end
function M.all() return state.comments end
function M.by_file(file) return state.by_file[file] or {} end
function M.files() return vim.tbl_keys(state.by_file) end
function M.active() return state.active_id and state.comments[state.active_id] end
function M.active_id() return state.active_id end
function M.providers() return state.providers end

--- Register a provider (called by provider.lua)
---@param p Provider
function M.register_provider(p)
	state.providers[p.name] = p
end

--- Find the comment whose range contains a given line in a file
---@param file string
---@param line0 integer 0-based line
---@return Comment|nil
function M.find_at(file, line0)
	for _, c in ipairs(state.by_file[file] or {}) do
		local s = c.line - 1
		local e = (c.end_line or c.line) - 1
		if line0 >= s and line0 <= e then
			return c
		end
	end
	return nil
end

return M
