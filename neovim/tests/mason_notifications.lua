local callbacks = {}
local notifications = {}
local setup_options
local script_path = debug.getinfo(1, "S").source:sub(2)
local config_path = arg[1] or vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(script_path)), "init.lua")
local source = table.concat(vim.fn.readfile(config_path), "\n")

assert(loadfile(config_path))

local function load_plugin(name, environment)
	local block = assert(source:match("addPlugin (%{\n%s*\"" .. vim.pesc(name) .. "\".-\n%})"), name .. " spec missing")
	local chunk = assert(loadstring("return " .. block, "@" .. config_path))
	setfenv(chunk, setmetatable(environment, { __index = _G }))
	return chunk()
end

local modules = {
	["mason"] = {
		setup = function(options)
			setup_options = options
		end
	},
	["mason-registry"] = {
		on = function(_, event, callback)
			assert(not callbacks[event], "Duplicate handler: " .. event)
			callbacks[event] = callback
		end
	},
	["notify"] = {
		notify = function(message, level, options)
			assert(not vim.in_fast_event(), "Notification delivered in a fast event")
			local record = { id = #notifications + 1 }
			table.insert(notifications, { level = level, message = message, options = options, record = record })
			return record
		end
	}
}
local mason = load_plugin("williamboman/mason.nvim", {
	require = function(name)
		return assert(modules[name], "Unexpected dependency: " .. name)
	end
})
local dependencies = type(mason.dependencies) == "string" and { mason.dependencies } or mason.dependencies or {}

assert(vim.list_contains(dependencies, "rcarriga/nvim-notify"), "Mason must depend on the configured notifier")
mason.config(nil, mason.opts)
assert(setup_options == mason.opts, "Mason setup options changed")
assert(#notifications == 0, "No install must mean no notification")

local function emit(event, payload)
	local previous = #notifications
	assert(callbacks[event], "Missing handler: " .. event)(payload)
	assert(vim.wait(1000, function() return #notifications > previous end), "No notification for " .. event)
	assert(#notifications == previous + 1, "Expected exactly one notification for " .. event)
	return notifications[#notifications]
end

local alpha = emit("package:install:handle", { package = { name = "fixture-alpha" } })
local beta = emit("package:install:handle", { package = { name = "fixture-beta" } })
assert(alpha.message == "Installing fixture-alpha" and beta.message == "Installing fixture-beta")
assert(alpha.level == vim.log.levels.INFO and beta.level == vim.log.levels.INFO)
assert(alpha.options.title == "Mason" and beta.options.title == "Mason")
assert(alpha.record ~= beta.record, "Concurrent installs must have independent records")

local beta_failed = emit("package:install:failed", { name = "fixture-beta" })
local alpha_installed = emit("package:install:success", { name = "fixture-alpha" })
assert(beta_failed.message == "fixture-beta failed" and beta_failed.level == vim.log.levels.ERROR)
assert(beta_failed.options.replace == beta.record, "Failure replaced the wrong package")
assert(alpha_installed.message == "fixture-alpha installed" and alpha_installed.level == vim.log.levels.INFO)
assert(alpha_installed.options.replace == alpha.record, "Success replaced the wrong package")
assert(emit("package:install:success", { name = "fixture-alpha" }).options.replace == nil, "Success leaked its record")
assert(emit("package:install:failed", { name = "fixture-beta" }).options.replace == nil, "Failure leaked its record")
print("PASS: named starts, concurrent replacements, terminal severity and cleanup")

do
	local expired = emit("package:install:handle", { package = { name = "fixture-expired" } })
	expired.options.on_close()
	local completed = emit("package:install:success", { name = "fixture-expired" })
	assert(completed.options.replace == nil, "Completion must create a new toast after expiry")

	local older = emit("package:install:handle", { package = { name = "fixture-retry" } })
	emit("package:install:success", { name = "fixture-retry" })
	local retry = emit("package:install:handle", { package = { name = "fixture-retry" } })
	older.options.on_close()
	assert(emit("package:install:failed", { name = "fixture-retry" }).options.replace == retry.record)
	print("PASS: expiry and stale close callbacks after retry")
end

do
	local live = emit("package:install:handle", { package = { name = "fixture-live" } })
	local buffer = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buffer, false, {
		col = 0, height = 1, relative = "editor", row = 0, style = "minimal", width = 20
	})
	live.options.on_open(window)
	assert(emit("package:install:success", { name = "fixture-live" }).options.replace == live.record)
	vim.api.nvim_win_close(window, true)
	vim.api.nvim_buf_delete(buffer, { force = true })

	local closing = emit("package:install:handle", { package = { name = "fixture-closing" } })
	buffer = vim.api.nvim_create_buf(false, true)
	window = vim.api.nvim_open_win(buffer, false, {
		col = 0, height = 1, relative = "editor", row = 0, style = "minimal", width = 20
	})
	closing.options.on_open(window)
	vim.api.nvim_win_close(window, true)
	local completed = emit("package:install:failed", { name = "fixture-closing" })
	assert(completed.options.replace == nil, "Closed window must not be replaced before on_close runs")
	assert(completed.level == vim.log.levels.ERROR, "Failure after window closure must remain ERROR")
	closing.options.on_close()
	vim.api.nvim_buf_delete(buffer, { force = true })
	print("PASS: visible windows and the deferred-close gap")
end

do
	local function emit_fast(event, payload)
		local callback_error
		local ran_in_fast_event = false
		local previous = #notifications
		local timer = assert(vim.uv.new_timer())
		timer:start(0, 0, function()
			ran_in_fast_event = vim.in_fast_event()
			local ok, err = pcall(callbacks[event], payload)
			if not ok then
				callback_error = err
			end
			timer:close()
		end)
		assert(vim.wait(1000, function() return callback_error ~= nil or #notifications > previous end))
		assert(callback_error == nil, callback_error)
		assert(ran_in_fast_event, "Timer did not exercise a fast event")
		assert(#notifications == previous + 1, "Fast event must produce exactly one notification")
		return notifications[#notifications]
	end

	local started = emit_fast("package:install:handle", { package = { name = "fixture-fast" } })
	local succeeded = emit_fast("package:install:success", { name = "fixture-fast" })
	assert(started.message == "Installing fixture-fast" and succeeded.options.replace == started.record)
	assert(succeeded.level == vim.log.levels.INFO)
	started = emit_fast("package:install:handle", { package = { name = "fixture-fast" } })
	local failed = emit_fast("package:install:failed", { name = "fixture-fast" })
	assert(failed.options.replace == started.record and failed.level == vim.log.levels.ERROR)
	print("PASS: all fast-event handlers deliver on the main loop")
end

do
	local components = {}
	local expected = {
		"function", "searchcount", "function", "selectioncount", "diagnostics", "hostname", "filesize", "encoding"
	}
	local options
	local lualine = load_plugin("nvim-lualine/lualine.nvim", {
		getColorFromHighlight = function(_, _, fallback) return fallback end,
		icons = setmetatable({}, { __index = function(_, name) return name end }),
		require = function(name)
			assert(name == "lualine", "Unexpected lualine dependency: " .. name)
			return { setup = function(config) options = config end }
		end
	})
	lualine.config()
	assert(not source:find("mason_installation", 1, true), "Old Mason state remains")
	assert(options.options.globalstatus == true, "Global statusline behavior changed")
	for _, component in ipairs(options.sections.lualine_x) do
		table.insert(components, type(component[1]) == "function" and "function" or component[1])
	end
	assert(vim.deep_equal(components, expected), "Unrelated lualine components changed")
	vim.g.formatting = "formatting-marker"
	assert(options.sections.lualine_x[1][1]() == "formatting-marker", "Formatting status must remain first")
	print("PASS: Mason statusline removed; other lualine components preserved")
end

print("PASS: Mason notification regression checks")
