local M = {}

local icons = {
	accepted = "󰄬",
	question = "󰋗",
	rejected = "󰅖",
}

--- Show the action menu for a review entry
---@param entry table CodeReview.Entry
---@param on_update fun(entry: table) callback after status change
function M.show_action_menu(entry, on_update)
	local Menu = require("nui.menu")
	local NuiText = require("nui.text")

	local menu = Menu({
		relative = "cursor",
		position = { row = 1, col = 0 },
		border = {
			style = "rounded",
			text = {
				top = NuiText(
					" " .. entry.category .. " │ " .. entry.severity:upper() .. " ",
					"CodeReviewText"
				),
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:CodeReviewBorder,CursorLine:Visual",
		},
	}, {
		lines = {
			Menu.item(
				NuiText("  " .. icons.accepted .. "  Accept   ", entry.status == "accepted" and "CodeReviewAccepted" or "Normal"),
				{ action = "accepted" }
			),
			Menu.item(
				NuiText("  " .. icons.rejected .. "  Reject   ", entry.status == "rejected" and "CodeReviewRejected" or "Normal"),
				{ action = "rejected" }
			),
			Menu.item(
				NuiText("  " .. icons.question .. "  Question ", entry.status == "question" and "CodeReviewQuestion" or "Normal"),
				{ action = "question" }
			),
		},
		on_submit = function(item)
			entry.status = item.action
			on_update(entry)
		end,
	})

	menu:mount()
end

return M
