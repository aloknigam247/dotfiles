local M = {}

--- Normalize a file path: forward slashes, no trailing slash
---@param path string
---@return string
function M.normalize_path(path)
	if not path or path == "" then
		return ""
	end
	return (vim.fs.normalize(path):gsub("\\", "/"):gsub("/$", ""))
end

--- Compute the relative key for a buffer (used to look up comments)
---@param bufnr integer
---@return string|nil
function M.buf_file_key(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	local abs = M.normalize_path(name)
	local cwd = M.normalize_path(vim.fn.getcwd())
	if abs:sub(1, #cwd + 1) == cwd .. "/" then
		return abs:sub(#cwd + 2)
	end
	return abs
end

--- Pure-Lua JSON pretty printer (2-space indent, sorted keys)
---@param val any
---@param indent? integer
---@return string
function M.json_pretty(val, indent)
	indent = indent or 0
	local pad = string.rep("  ", indent)
	local pad1 = string.rep("  ", indent + 1)
	local t = type(val)

	if t == "table" then
		if vim.islist(val) then
			if #val == 0 then
				return "[]"
			end
			local parts = {}
			for _, v in ipairs(val) do
				parts[#parts + 1] = pad1 .. M.json_pretty(v, indent + 1)
			end
			return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
		end
		local keys = vim.tbl_keys(val)
		table.sort(keys)
		if #keys == 0 then
			return "{}"
		end
		local parts = {}
		for _, k in ipairs(keys) do
			parts[#parts + 1] = pad1 .. vim.json.encode(k) .. ": " .. M.json_pretty(val[k], indent + 1)
		end
		return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
	end
	return vim.json.encode(val)
end

--- Generate a UUID-ish unique id
---@return string
function M.uid()
	local time = vim.loop.hrtime()
	local rand = math.random(0, 0xFFFFFF)
	return string.format("%x-%x", time, rand)
end

--- ISO-8601 timestamp (UTC)
---@return string
function M.now()
	return os.date("!%Y-%m-%dT%H:%M:%SZ") --[[@as string]]
end

--- Word-wrap text to a given width
---@param text string
---@param width integer
---@return string[]
function M.wrap(text, width)
	local out = {}
	for _, para in ipairs(vim.split(text, "\n")) do
		if #para == 0 then
			out[#out + 1] = ""
		else
			while #para > width do
				local brk = para:sub(1, width):find("%s[^%s]*$") or width
				out[#out + 1] = para:sub(1, brk - 1)
				para = para:sub(brk + 1)
			end
			if #para > 0 then
				out[#out + 1] = para
			end
		end
	end
	return out
end

--- Notify with the [review] prefix
---@param msg string
---@param level? integer
function M.notify(msg, level)
	vim.notify("[review] " .. msg, level or vim.log.levels.INFO)
end

return M
