local M = {}

--- Open the file tree sidebar showing reviewed files
---@param state table CodeReview state
function M.open(state)
	local Snacks = require("snacks")
	local items = {}

	for file, entries in pairs(state.by_file) do
		local pending = #vim.tbl_filter(function(e) return e.status == "pending" end, entries)
		items[#items + 1] = {
			text = file,
			file = vim.fs.joinpath(vim.fn.getcwd(), file),
			count = #entries,
			pending = pending,
		}
	end

	-- Sort: pending first, then by filename
	table.sort(items, function(a, b)
		if a.pending ~= b.pending then
			return a.pending > b.pending
		end
		return a.text < b.text
	end)

	Snacks.picker({
		title = "Code Reviews",
		items = items,
		layout = { preset = "sidebar" },
		format = function(item)
			local ret = {}
			local icon, hl = Snacks.util.icon(item.file, "file")
			ret[#ret + 1] = { icon .. " ", hl, virtual = true }
			ret[#ret + 1] = { item.text, "SnacksPickerFile" }
			ret[#ret + 1] = { " " }
			local badge_hl = item.pending > 0 and "DiagnosticWarn" or "DiagnosticOk"
			ret[#ret + 1] = { (" %d/%d "):format(item.pending, item.count), badge_hl, virtual = true }
			return ret
		end,
		confirm = { "jump", "close" },
		jump = { close = false },
		win = {
			list = {
				keys = {
					["<ESC>"] = false,
				}
			}
		},
	})
end

--- Close the sidebar picker if open
function M.close()
	-- Snacks pickers can be closed via the picker instance
	-- This is a best-effort cleanup; the user can also press q
end

return M
