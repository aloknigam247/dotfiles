local state = require("review.state")
local util = require("review.util")

local M = {}

--- Validate a provider object before registering
---@param p table
---@return boolean ok, string? err
local function validate(p)
	if type(p) ~= "table" then return false, "provider must be a table" end
	if type(p.name) ~= "string" or p.name == "" then return false, "provider.name required" end
	if type(p.load) ~= "function" then return false, "provider.load required" end
	return true
end

--- Register a provider
---@param p Provider
function M.register(p)
	local ok, err = validate(p)
	if not ok then
		util.notify("provider invalid: " .. (err or ""), vim.log.levels.ERROR)
		return
	end
	state.register_provider(p)
end

--- Safe-call a provider method; returns (ok, result_or_err)
---@param provider_name string
---@param method string
---@param ... any
---@return boolean ok, any result_or_err
function M.call(provider_name, method, ...)
	local providers = state.providers()
	local p = providers[provider_name]
	if not p then
		return false, "unknown provider: " .. provider_name
	end
	if type(p[method]) ~= "function" then
		return false, ("provider %q does not support %s"):format(provider_name, method)
	end
	local ok, result = pcall(p[method], ...)
	if not ok then
		util.notify(("provider %s.%s error: %s"):format(provider_name, method, tostring(result)), vim.log.levels.ERROR)
		return false, result
	end
	return true, result
end

--- Check if any provider supports a given method
---@param method string
---@return boolean
function M.supports(method)
	for _, p in pairs(state.providers()) do
		if type(p[method]) == "function" then return true end
	end
	return false
end

--- Load comments from one provider (or all if name is nil)
---@param name? string
---@return Comment[] all_comments
function M.load(name)
	local providers = state.providers()
	local all = {}
	local targets = {}
	if name then
		if not providers[name] then
			util.notify("unknown provider: " .. name, vim.log.levels.ERROR)
			return all
		end
		targets[name] = providers[name]
	else
		targets = providers
	end

	for pname, p in pairs(targets) do
		local ok, comments = pcall(p.load)
		if not ok then
			util.notify(("provider %s.load error: %s"):format(pname, tostring(comments)), vim.log.levels.ERROR)
		elseif type(comments) == "table" then
			for _, c in ipairs(comments) do
				c.provider = pname
				-- Default id if missing
				if not c.id then
					c.id = ("%s:%s:%d"):format(pname, c.file or "?", c.line or 0)
				end
				table.insert(all, c)
			end
		end
	end

	return all
end

--- Find the provider that owns a comment, or nil
---@param comment_id string
---@return Provider|nil
function M.owner_of(comment_id)
	local c = state.get(comment_id)
	if not c then return nil end
	return state.providers()[c.provider]
end

return M
