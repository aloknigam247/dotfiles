local state = require("review.state")
local util = require("review.util")

local M = {}

local function build_items()
	local items = {}
	for _, file in ipairs(state.files()) do
		local comments = state.by_file(file)
		local pending = 0
		for _, c in ipairs(comments) do
			if c.status == "pending" then pending = pending + 1 end
		end
		items[#items + 1] = {
			text = file,
			file = vim.fs.joinpath(vim.fn.getcwd(), file):gsub("\\", "/"),
			count = #comments,
			pending = pending,
		}
	end
	table.sort(items, function(a, b)
		if a.pending ~= b.pending then return a.pending > b.pending end
		return a.text < b.text
	end)
	return items
end

--- Open the file tree (Snacks picker, sticky sidebar)
function M.open()
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		util.notify("snacks.nvim not available; tree disabled", vim.log.levels.WARN)
		return
	end

	snacks.picker({
		title = "Reviews",
		items = build_items(),
		auto_close = false,
		layout = { preset = "sidebar" },
		format = function(item)
			local ret = {}
			local icon, hl = snacks.util.icon(item.file, "file")
			ret[#ret + 1] = { icon .. " ", hl, virtual = true }
			ret[#ret + 1] = { item.text, "SnacksPickerFile" }
			ret[#ret + 1] = { " " }
			local badge_hl = item.pending > 0 and "DiagnosticWarn" or "DiagnosticOk"
			ret[#ret + 1] = { (" %d/%d "):format(item.pending, item.count), badge_hl, virtual = true }
			return ret
		end,
		confirm = "jump",
		win = {
			list = { keys = { ["<ESC>"] = false } },
		},
	})
end

return M
