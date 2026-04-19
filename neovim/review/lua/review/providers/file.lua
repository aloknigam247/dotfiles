local util = require("review.util")

local M = {}

--- Create a file-based provider
---@param opts { path: string, name?: string, label?: string, author?: string }
---@return Provider
function M.new(opts)
	assert(type(opts) == "table" and type(opts.path) == "string", "file provider requires { path = '...' }")

	local path = opts.path
	local name = opts.name or "file"
	local label = opts.label or "File"
	local local_author = opts.author or "you"

	-- In-memory cache so reply/set_status mutate the same comments load() returned
	local cache = nil ---@type Comment[]|nil

	local function read_file()
		local abs = vim.fn.fnamemodify(path, ":p")
		if vim.fn.filereadable(abs) ~= 1 then
			util.notify("file not found: " .. abs, vim.log.levels.WARN)
			return {}
		end
		local content = table.concat(vim.fn.readfile(abs), "\n")
		if content == "" then return {} end
		local ok, decoded = pcall(vim.json.decode, content)
		if not ok then
			util.notify("invalid JSON in " .. abs .. ": " .. tostring(decoded), vim.log.levels.ERROR)
			return {}
		end
		if type(decoded) ~= "table" then return {} end
		return decoded
	end

	local function write_file(comments)
		local abs = vim.fn.fnamemodify(path, ":p")
		local out = util.json_pretty(comments)
		vim.fn.writefile(vim.split(out, "\n"), abs)
	end

	---@type Provider
	local provider = {
		name = name,
		label = label,
		load = function()
			local raw = read_file()
			cache = {}
			for i, c in ipairs(raw) do
				c.id = c.id or ("file:%s:%d:%d"):format(c.file or "?", c.line or 0, i)
				c.status = c.status or "pending"
				c.thread = c.thread or {}
				c.severity = c.severity or "info"
				c.author = c.author or "reviewer"
				cache[#cache + 1] = c
			end
			return cache
		end,
		save = function(comments)
			cache = comments
			write_file(comments)
		end,
		reply = function(comment_id, body)
			if not cache then return nil end
			local target
			for _, c in ipairs(cache) do
				if c.id == comment_id then target = c; break end
			end
			if not target then
				util.notify("reply: comment not found: " .. comment_id, vim.log.levels.WARN)
				return nil
			end
			local msg = {
				id = util.uid(),
				author = local_author,
				timestamp = util.now(),
				body = body,
			}
			target.thread = target.thread or {}
			table.insert(target.thread, msg)
			write_file(cache)
			return msg
		end,
		set_status = function(comment_id, status)
			if not cache then return false end
			for _, c in ipairs(cache) do
				if c.id == comment_id then
					c.status = status
					write_file(cache)
					return true
				end
			end
			return false
		end,
	}

	return provider
end

return M
