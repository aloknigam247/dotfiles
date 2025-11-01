--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configurations ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Profiling</>
------------
-- ---@class Profile
-- ---@field count integer Number of times an autOcommand is invoked
-- ---@field start number Start time of current autocommand
-- ---@field avg number Average time taken by autocommand
-- ---@field total number Total time taken by autocommand
-- ---@alias ProfileData table<string, Profile>
-- ---Contains Autocommand profiling data
-- ---@type ProfileData?
-- AuProfileData = {}

-- --@type boolean Switch to toggle Autocommand profiling
-- AuProfileEnabled = false

-- ---Collect autocommand data at autocommand startup, called for each event
-- ---@param args any Autocommand callback data
-- local function auProfileStart(args)
-- 	local event = args.event

-- 	if AuProfileEnabled then
-- 		local data = AuProfileData[event] or {}
-- 		data["count"] = (data.count or 0) + 1
-- 		data["start"] = os.clock()
-- 		AuProfileData[event] = data
-- 	end
-- end

-- ---Collect autocommand data at autocommand startup, called for each event
-- ---@param args any Autocommand callback data
-- local function auProfileEnd(args)
-- 	if AuProfileEnabled then
-- 		local data = AuProfileData[args.event]
-- 		if data then
-- 			local elapsed = os.clock() - data.start
-- 			local total = (data.total or 0) + elapsed

-- 			data["avg"] = total / data.count
-- 			data["total"] = total

-- 			AuProfileData[args.event] = data
-- 		end
-- 	end
-- end

-- ---List of all valid autocommands to profile
-- ---@type string[]
-- local event_list = {
-- 	"BufAdd",
-- 	"BufDelete",
-- 	"BufEnter",
-- 	"BufFilePost",
-- 	"BufFilePre",
-- 	"BufHidden",
-- 	"BufLeave",
-- 	"BufModifiedSet",
-- 	"BufNew",
-- 	"BufNewFile",
-- 	"BufRead",
-- 	"BufReadPre",
-- 	"BufUnload",
-- 	"BufWinEnter",
-- 	"BufWinLeave",
-- 	"BufWipeout",
-- 	"BufWrite",
-- 	"BufWritePost",
-- 	"ChanInfo",
-- 	"ChanOpen",
-- 	"CmdUndefined",
-- 	"CmdlineChanged",
-- 	"CmdlineEnter",
-- 	"CmdlineLeave",
-- 	"CmdwinEnter",
-- 	"CmdwinLeave",
-- 	"ColorScheme",
-- 	"ColorSchemePre",
-- 	"CompleteChanged",
-- 	"CompleteDone",
-- 	"CompleteDonePre",
-- 	"CursorHold",
-- 	"CursorHoldI",
-- 	"CursorMoved",
-- 	"CursorMovedI",
-- 	"DiffUpdated",
-- 	"DirChanged",
-- 	"DirChangedPre",
-- 	"ExitPre",
-- 	"FileAppendPost",
-- 	"FileAppendPre",
-- 	"FileChangedRO",
-- 	"FileChangedShell",
-- 	"FileChangedShellPost",
-- 	"FileReadPost",
-- 	"FileReadPre",
-- 	"FileType",
-- 	"FileWritePost",
-- 	"FileWritePre",
-- 	"FilterReadPost",
-- 	"FilterReadPre",
-- 	"FilterWritePost",
-- 	"FilterWritePre",
-- 	"FocusGained",
-- 	"FocusLost",
-- 	"FuncUndefined",
-- 	"InsertChange",
-- 	"InsertCharPre",
-- 	"InsertEnter",
-- 	"InsertLeave",
-- 	"InsertLeavePre",
-- 	"MenuPopup",
-- 	"ModeChanged",
-- 	"OptionSet",
-- 	"QuickFixCmdPost",
-- 	"QuickFixCmdPre",
-- 	"QuitPre",
-- 	"RecordingEnter",
-- 	"RecordingLeave",
-- 	"RemoteReply",
-- 	"SafeState",
-- 	"SearchWrapped",
-- 	"SessionLoadPost",
-- 	"ShellCmdPost",
-- 	"ShellFilterPost",
-- 	"Signal",
-- 	"SourcePost",
-- 	"SourcePre",
-- 	"SpellFileMissing",
-- 	"StdinReadPost",
-- 	"StdinReadPre",
-- 	"SwapExists",
-- 	"Syntax",
-- 	"TabClosed",
-- 	"TabEnter",
-- 	"TabLeave",
-- 	"TabNew",
-- 	"TabNewEntered",
-- 	"TermClose",
-- 	"TermEnter",
-- 	"TermLeave",
-- 	"TermOpen",
-- 	"TermResponse",
-- 	"TextChanged",
-- 	"TextChangedI",
-- 	"TextChangedP",
-- 	"TextChangedT",
-- 	"TextYankPost",
-- 	"UIEnter",
-- 	"UILeave",
-- 	"User",
-- 	"VimEnter",
-- 	"VimLeave",
-- 	"VimLeavePre",
-- 	"VimResized",
-- 	"VimResume",
-- 	"VimSuspend",
-- 	"WinClosed",
-- 	"WinEnter",
-- 	"WinLeave",
-- 	"WinNew",
-- 	"WinResized",
-- 	"WinScrolled",
-- }

-- vim.api.nvim_create_autocmd(
-- 	event_list, {
-- 		desc = "Autocommand profile init",
-- 		pattern = "*",
-- 		callback = auProfileStart
-- 	}
-- )

-- vim.api.nvim_create_user_command(
-- 	"ProfileAutocommand",
-- 	function()
-- 		vim.notify("Profiling started, stop by F6")
-- 		AuProfileEnabled = true
-- 		AuProfileData = {}
-- 		AuCallbackProfileData = {}

-- 		-- Autocommand to collect end data
-- 		vim.api.nvim_create_autocmd(
-- 			event_list, {
-- 				desc = "Autocommand profile record",
-- 				pattern = "*",
-- 				callback = auProfileEnd
-- 			}
-- 		)

-- 		-- Mapping to stop autocommand profiling
-- 		vim.api.nvim_set_keymap("n", "<F6>", "", {
-- 			callback = function()
-- 				AuProfileEnabled = false
-- 				vim.cmd("profile stop")
-- 				vim.notify("Autocommand profiling stopped")
-- 			end
-- 		})

-- 		vim.cmd[[
-- 			profile start nvim_profile
-- 			" profile file *
-- 			profile func *
-- 		]]
-- 	end,
-- 	{ nargs = 0 }
-- )

-- ---@type ProfileData?
-- AuCallbackProfileData = {}

-- ---Create autocmd wrapper to emit perf telemetry
-- ---@param event string Name of event
-- ---@param opts table Autocmd config
-- local function nvimCreateAutocmdWrapper(event, opts)
-- 	if opts then
-- 		local cb = opts.callback
-- 		if cb then
-- 			opts.callback = function(arg)
-- 				local start = os.clock()
-- 				cb(arg)
-- 				local elapsed = os.clock() - start

-- 				if AuProfileEnabled then
-- 					local data = AuCallbackProfileData[arg.id] or {}
-- 					local total = (data.total or 0) + elapsed

-- 					data["count"]= (data.count or 0) + 1
-- 					data["avg"] = total / data.count
-- 					data["total"] = total
-- 					AuCallbackProfileData[arg.id] = data
-- 				end
-- 			end
-- 		end
-- 	end
-- 	vim.api.__nvim_create_autocmd(event, opts)
-- end

-- vim.api.__nvim_create_autocmd = vim.api.nvim_create_autocmd
-- vim.api.nvim_create_autocmd = nvimCreateAutocmdWrapper
-- <~>
-- Variables</>
------------

---Shapes for dotted border
---@type string[]
local dotted_border = { "╭", "󰇘", "╮", "┊", "╯", "󰇘", "╰", "┊" }

---Defines Icons for global usage
---@type table<string, string>
local icons = {
	Array              = "󰅪 ",
	Boolean            = " ",
	Class              = " ",
	Color              = " ",
	Component          = " ",
	Constant           = " ",
	Constructor        = " ",
	Enum               = " ",
	EnumMember         = " ",
	Event              = " ",
	Field              = " ",
	File               = " ",
	Folder             = "󰷏 ",
	Fragment           = " ",
	Function           = " ",
	Git                = "󰱼 ",
	History            = " ",
	Interface          = " ",
	Key                = " ",
	Keyword            = " ",
	Macro              = " ",
	Method             = " ",
	Module             = " ",
	Namespace          = "󰘦 ",
	Null               = "󰢤 ",
	Number             = " ",
	Object             = " ",
	Operator           = " ",
	Options            = " ",
	Package            = " ",
	Parameter          = " ",
	Path               = " ",
	Property           = " ",
	Reference          = " ",
	Ripgrep            = "󰱼 ",
	Snippet            = " ",
	StaticMethod       = "󰡱 ",
	String             = " ",
	Struct             = " ",
	Text               = "󱄽 ",
	TypeAlias          = " ",
	TypeParameter      = " ",
	Unit               = " ",
	Value              = " ",
	Variable           = " ",
	bookmark           = "󰃃",
	bookmark_annotate  = "󰃄",
	border_botleft     = "╰",
	border_botright    = "╯",
	border_hor         = "─",
	border_topleft     = "╭",
	border_topright    = "╮",
	border_vert        = "│",
	code_action        = " ",
	diagnostic         = " ",
	diff_add           = "│",
	diff_change        = "┊",
	diff_change_delete = "~",
	diff_delete        = "",
	diff_delete_top    = "‾",
	diff_untracked     = "┆",
	error              = " ",
	file_added         = "󰻭",
	file_modified      = "",
	file_newfile       = "",
	file_readonly      = "",
	file_unnamed       = "",
	fold_close         = "",
	fold_open          = "",
	folder_close       = "",
	folder_open        = "",
	git_added          = "+",
	git_modified       = "~",
	git_removed        = "-",
	hint               = " ",
	hover              = " ",
	incoming           = " ",
	info               = " ",
	lazy               = " ",
	lsp                = "󰈸",
	outgoing           = " ",
	preview            = " ",
	symlink_arrow      = " 壟 ",
	warn               = " ",
	warning            = " ",
}

---Defines highlight for kinds
---@type table<string, table>
local kind_hl = {
	Array         = { icon = " ", dark = { fg = "#F42272", bg = "#313244" }, light = { fg = "#0B6E4F", bg = "#CCD0DA" }},
	Boolean       = { icon = " ", dark = { fg = "#B8B8F3", bg = "#313244" }, light = { fg = "#69140E", bg = "#CCD0DA" }},
	Class         = { icon = " ", dark = { fg = "#519872", bg = "#313244" }, light = { fg = "#1D3557", bg = "#CCD0DA" }},
	Color         = { icon = " ", dark = { fg = "#A4B494", bg = "#313244" }, light = { fg = "#FA9F42", bg = "#CCD0DA" }},
	Constant      = { icon = " ", dark = { fg = "#C5E063", bg = "#313244" }, light = { fg = "#744FC6", bg = "#CCD0DA" }},
	Constructor   = { icon = " ", dark = { fg = "#4AAD52", bg = "#313244" }, light = { fg = "#755C1B", bg = "#CCD0DA" }},
	Enum          = { icon = " ", dark = { fg = "#E3B5A4", bg = "#313244" }, light = { fg = "#A167A5", bg = "#CCD0DA" }},
	EnumMember    = { icon = " ", dark = { fg = "#AF2BBF", bg = "#313244" }, light = { fg = "#B80C09", bg = "#CCD0DA" }},
	Event         = { icon = " ", dark = { fg = "#6C91BF", bg = "#313244" }, light = { fg = "#53A548", bg = "#CCD0DA" }},
	Field         = { icon = " ", dark = { fg = "#5BC8AF", bg = "#313244" }, light = { fg = "#E2DC12", bg = "#CCD0DA" }},
	File          = { icon = " ", dark = { fg = "#EF8354", bg = "#313244" }, light = { fg = "#486499", bg = "#CCD0DA" }},
	Folder        = { icon = " ", dark = { fg = "#BFC0C0", bg = "#313244" }, light = { fg = "#A74482", bg = "#CCD0DA" }},
	Function      = { icon = " ", dark = { fg = "#E56399", bg = "#313244" }, light = { fg = "#228CDB", bg = "#CCD0DA" }},
	History       = { icon = " ", dark = { fg = "#C2F8CB", bg = "#313244" }, light = { fg = "#85CB33", bg = "#CCD0DA" }},
	Interface     = { icon = " ", dark = { fg = "#8367C7", bg = "#313244" }, light = { fg = "#537A5A", bg = "#CCD0DA" }},
	Key           = { icon = " ", dark = { fg = "#D1AC00", bg = "#313244" }, light = { fg = "#645DD7", bg = "#CCD0DA" }},
	Keyword       = { icon = " ", dark = { fg = "#20A4F3", bg = "#313244" }, light = { fg = "#E36414", bg = "#CCD0DA" }},
	Method        = { icon = " ", dark = { fg = "#D7D9D7", bg = "#313244" }, light = { fg = "#197278", bg = "#CCD0DA" }},
	Module        = { icon = " ", dark = { fg = "#F2FF49", bg = "#313244" }, light = { fg = "#EC368D", bg = "#CCD0DA" }},
	Namespace     = { icon = "ﬥ ", dark = { fg = "#FF4242", bg = "#313244" }, light = { fg = "#2F9C95", bg = "#CCD0DA" }},
	Null          = { icon = " ", dark = { fg = "#C1CFDA", bg = "#313244" }, light = { fg = "#56666B", bg = "#CCD0DA" }},
	Number        = { icon = " ", dark = { fg = "#FB62F6", bg = "#313244" }, light = { fg = "#A5BE00", bg = "#CCD0DA" }},
	Object        = { icon = " ", dark = { fg = "#F18F01", bg = "#313244" }, light = { fg = "#80A1C1", bg = "#CCD0DA" }},
	Operator      = { icon = " ", dark = { fg = "#048BA8", bg = "#313244" }, light = { fg = "#F1DB4B", bg = "#CCD0DA" }},
	Options       = { icon = " ", dark = { fg = "#99C24D", bg = "#1E1E2E" }, light = { fg = "#99C24D", bg = "#CCD0DA" }},
	Package       = { icon = " ", dark = { fg = "#AFA2FF", bg = "#313244" }, light = { fg = "#B98EA7", bg = "#CCD0DA" }},
	Path          = { icon = " ", dark = { fg = "#EFC6BD", bg = "#313244" }, light = { fg = "#DC836F", bg = "#CCD0DA" }},
	Property      = { icon = " ", dark = { fg = "#CED097", bg = "#313244" }, light = { fg = "#3777FF", bg = "#CCD0DA" }},
	Reference     = { icon = " ", dark = { fg = "#1B2CC1", bg = "#313244" }, light = { fg = "#18A999", bg = "#CCD0DA" }},
	Snippet       = { icon = " ", dark = { fg = "#7692FF", bg = "#313244" }, light = { fg = "#BF0D4B", bg = "#CCD0DA" }},
	String        = { icon = " ", dark = { fg = "#FEEA00", bg = "#313244" }, light = { fg = "#D5573B", bg = "#CCD0DA" }},
	Struct        = { icon = " ", dark = { fg = "#D81159", bg = "#313244" }, light = { fg = "#75485E", bg = "#CCD0DA" }},
	Text          = { icon = " ", dark = { fg = "#0496FF", bg = "#313244" }, light = { fg = "#5762D5", bg = "#CCD0DA" }},
	TypeParameter = { icon = " ", dark = { fg = "#FFFFFC", bg = "#313244" }, light = { fg = "#5D2E8C", bg = "#CCD0DA" }},
	Unit          = { icon = " ", dark = { fg = "#C97B84", bg = "#313244" }, light = { fg = "#FF6666", bg = "#CCD0DA" }},
	Value         = { icon = " ", dark = { fg = "#C6DDF0", bg = "#313244" }, light = { fg = "#2EC4B6", bg = "#CCD0DA" }},
	Variable      = { icon = " ", dark = { fg = "#B7ADCF", bg = "#313244" }, light = { fg = "#548687", bg = "#CCD0DA" }}
}

---Global keymaps
---@type table<string, string>
local keymaps = {
	open_split = "<M-s>",
	open_tab = "<M-t>",
	open_vsplit = "<M-v>",
}

local lazy_config = {
	root = vim.fn.stdpath("data") .. "/lazy", -- directory where plugins will be installed
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
		version = nil,
		cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
		-- version = "*", -- enable this to try installing the latest stable versions of plugins
	},
	lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after update.
	install = {
		missing = true,
		colorscheme = { "default" },
	},
	ui = {
		size = { width = 0.8, height = 0.8 },
		wrap = true, -- wrap the lines in the ui
		border = "rounded",
		title = nil, ---@type string only works when border is not "none"
		title_pos = "center", ---@type "center" | "left" | "right"
		-- Show pills on top of the Lazy window
		pills = true, ---@type boolean
		icons = {
			cmd        = "",
			config     = "",
			event      = "",
			ft         = "",
			init       = "",
			import     = "󰋺",
			keys       = "󰌌",
			lazy       = icons.lazy,
			list       = { "󰬺", " 󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", "󰿩" },
			loaded     = "",
			not_loaded = "",
			plugin     = "",
			runtime    = "",
			source     = "",
			start      = "",
			task       = ""
		},
		browser = nil, ---@type string?
		throttle = 20, -- how frequently should the ui process render events
		custom_keys = {
			["<localleader>l"] = function(plugin)
				require("lazy.util").float_term({ "lazygit", "log" }, {
					cwd = plugin.dir,
				})
			end,
			["<localleader>t"] = function(plugin)
				require("lazy.util").float_term(nil, {
					cwd = plugin.dir,
				})
			end,
		},
	},
	change_detection = {
		enabled = false,
		notify = true, -- get a notification when changes are found
	},
	performance = {
		cache = {
			enabled = true,
		},
		reset_packpath = true, -- reset the package path to improve startup time
		rtp = {
			reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
			---@type string[]
			paths = {}, -- add any custom paths here that you want to includes in the rtp
			---@type string[] list any plugins you want to disable here
			disabled_plugins = {
				"csv",
				"editorconfig",
				"gzip",
				"man",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"rplugin",
				"shada",
				"spellfile",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	state = vim.fn.stdpath("state") .. "/lazy/state.json", -- state info for checker and other things
	profiling = {
		-- Enables extra stats on the debug tab related to the loader cache.
		-- Additionally gathers stats about all package.loaders
		loader = true,
		-- Track each new require in the Lazy profiling tab
		require = true,
	},
	rocks = {
		enabled = false
	}
}

---Defines highlight priorities for various components
---@type table<string, integer>
local priority_hl = {
	url = 0,
	hlargs = 150
}

---Defines window priorities for various components
---@type table<string, integer>
local priority_win = {
	peek = 50
}

---Defines virtual text priority
---@type table<string, integer>
local priority_virt = {
	diagnostics = 5000
}

---@type string[] List of filetypes to enable Overlength marker
local overlength_filetypes = {
	"cpp",
	"lua",
	"markdown",
	"python"
}

---@class Plugin
---@type Plugin[] List of plugins
local plugins = {}

---@class PopupMenuOption
---@field name string name of option
---@field key? string key map for the option
---@field exec fun() option execution function

---@class PopupMenu
---@field cond? fun() Condition to evaluate for PopUp menu
---@field options PopupMenuOption[] Config options
---@type PopupMenu[]
local pop_up_menu = {}

---@class TodoColors
---@field default string[] Default colors
---@field docs string[] Docs colors
---@field error string[] Error colors
---@field feat string[] Feature colors
---@field hint string[] Hint colors
---@field info string[] Info colors
---@field perf string[] Performance colors
---@field test string[] Test colors
---@field todo string[] Todo colors
---@field warn string[] Warning colors
---@type TodoColors Contains colors configuration for Color highlights
local todo_colors = {
	default = { "Identifier", "#7C3AED" },
	docs    = { "Function", "#440381" },
	error   = { "DiagnosticError", "ErrorMsg", "#DC2626" },
	feat    = { "Type", "#274C77" },
	hint    = { "DiagnosticHint", "#10B981" },
	info    = { "DiagnosticInfo", "#2563EB" },
	perf    = { "String", "#C2F970" },
	test    = { "Identifier", "#DDD92A" },
	todo    = { "Todo", "Keyword", "#1B998B" },
	warn    = { "DiagnosticWarn", "WarningMsg", "#FBBF24" }
}

local todo_config = {
	DOCS   = { icon = "", color = "docs", alt = { "DOCME" } },
	FEAT   = { icon = "󱩑", color = "feat" },
	FIX    = { icon = "󰠭", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }},
	HACK   = { icon = "󰑶", color = "hint" },
	NOTE   = { icon = "", color = "info", alt = { "INFO", "THOUGHT" } },
	PERF   = { icon = "󱙷", color = "perf", alt = { "OPTIMIZE", "PERFORMANCE" } },
	RECODE = { icon = "", color = "info", alt = { "REFACTOR" } },
	TEST   = { icon = "󰙨", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
	TODO   = { icon = "󰸞", color = "todo" },
	WARN   = { icon = "!", color = "warn", alt = { "WARNING" } },
}

LargeFile = {}
-- <~>
-- Functions</>
------------

---Generates color palette for dark and light mode
---@return { bg: string, fg: string }[] # List of _nvim_set_hl()_ supported color config
function ColorPalette()
	if vim.o.background == "light" then
		return {
			{ bg = "#FFFFFF", fg = "#8543DA" },
			{ bg = "#000000", fg = "#E0D366" },
			{ bg = "#000000", fg = "#6CA4E0" },
			{ bg = "#000000", fg = "#DA9E5D" },
			{ bg = "#FFFFFF", fg = "#46587B" },
			{ bg = "#000000", fg = "#35D7D0" },
			{ bg = "#000000", fg = "#528E84" },
			{ bg = "#000000", fg = "#94C880" },
			{ bg = "#FFFFFF", fg = "#5F7C47" },
			{ bg = "#000000", fg = "#8D9C94" },
			{ bg = "#000000", fg = "#66C856" },
			{ bg = "#000000", fg = "#49D176" },
			{ bg = "#FFFFFF", fg = "#6569C0" },
			{ bg = "#000000", fg = "#E5B5E1" },
			{ bg = "#FFFFFF", fg = "#AD3D9D" },
			{ bg = "#000000", fg = "#B481B4" },
			{ bg = "#000000", fg = "#D670C8" },
			{ bg = "#FFFFFF", fg = "#83694C" },
			{ bg = "#FFFFFF", fg = "#BC573B" },
			{ bg = "#000000", fg = "#D35F7D" },
		}
	end
	-- dark mode
	return {
		{ bg = "#000000", fg = "#A46EFF" },
		{ bg = "#000000", fg = "#F8E879" },
		{ bg = "#000000", fg = "#9CCBFF" },
		{ bg = "#000000", fg = "#FFC97E" },
		{ bg = "#000000", fg = "#7C8FBA" },
		{ bg = "#000000", fg = "#8CFFF9" },
		{ bg = "#000000", fg = "#67B9A9" },
		{ bg = "#000000", fg = "#C7F5A8" },
		{ bg = "#000000", fg = "#8AAF52" },
		{ bg = "#000000", fg = "#A0B1AE" },
		{ bg = "#000000", fg = "#57DD3C" },
		{ bg = "#000000", fg = "#86FFAB" },
		{ bg = "#000000", fg = "#898CFF" },
		{ bg = "#000000", fg = "#FFE4FF" },
		{ bg = "#000000", fg = "#EA6CD8" },
		{ bg = "#000000", fg = "#DFABD9" },
		{ bg = "#000000", fg = "#FFB1F6" },
		{ bg = "#000000", fg = "#AF8C6D" },
		{ bg = "#000000", fg = "#FF7648" },
		{ bg = "#000000", fg = "#FF99A8" },
	}
end

---Count number of windows visible
---@param ignore boolean Enable ignoring of filetypes
---@return integer # Number of windows
function CountWindows(ignore)
	local tabpage = vim.api.nvim_get_current_tabpage()
	local win_list = vim.api.nvim_tabpage_list_wins(tabpage)
	local named_window = 0
	local visited_window = {}
	local isValidBuf = function(bufnr, buf_name, win_config)
		-- ignore empty buffers
		if buf_name == "" then
			return false
		end

		if win_config.relative ~= nil and win_config.relative ~= "" then
			return false
		end

		if not ignore then return true end

		local ignore_filetype = { "NvimTree" }
		local filetype = vim.api.nvim_get_option_value( "filetype", { buf = bufnr })
		for _,v in pairs(ignore_filetype) do
			if v == filetype then
				return false
			end
		end

		return true
	end

	for _, win in ipairs(win_list) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		local buf_name = vim.api.nvim_buf_get_name(bufnr)
		local win_config = vim.api.nvim_win_get_config(win)
		if isValidBuf(bufnr, buf_name, win_config) then
			if not visited_window[buf_name] then
				visited_window[buf_name] = true
				named_window = named_window + 1
			end
		end
	end

	return named_window
end

--- Get background color from highlight or fallback
---@param hl_name string highlight name
---@param fallback? string fallback color
function GetBgOrFallback(hl_name, fallback)
	local hl = vim.api.nvim_get_hl(0, { name = hl_name, create = false, link = false })
	if not vim.tbl_isempty(hl) and hl.bg then
		return string.format("#%06X", hl.bg)
	end
	return fallback
end

--- Get foreground color from highlight or fallback
---@param hl_name string highlight name
---@param fallback? string fallback color
function GetFgOrFallback(hl_name, fallback)
	local hl = vim.api.nvim_get_hl(0, { name = hl_name, create = false, link = false })
	if not vim.tbl_isempty(hl) and hl.fg then
		return string.format("#%06X", hl.fg)
	end
	return fallback
end

---Light or dark color
---@param col string hex Color to shade
---@param amt integer Amount of shade
---@return string # Color in hex format
function LightenDarkenColor(col, amt)
	local function clamp(x) return math.max(0, math.min(255, x)) end

	local num = tonumber(col:sub(2), 16)	
	local r = clamp(bit.rshift(num, 16) + amt)
	local b = clamp(bit.band(bit.rshift(num, 8), 0x00FF) + amt)
	local g = clamp(bit.band(num, 0x0000FF) + amt)
	local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))

	hex, _ = string.format("#%-6X", newColor):gsub(" ", "0")
	return hex
end

---Adds a plugin Lazy nvim config
---@param opts Plugin Plugin config
local function addPlugin(opts)
	table.insert(plugins, opts)
end

---Create background color adaptive to editor background
---@param lighten integer Lighter percent
---@param darken integer Darker percent
---@return string # Color in Hex format
local function adaptiveBG(lighten, darken)
	local bg

	if vim.o.background == "dark" then
		bg = vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg or 0
		bg = string.format("#%X", bg)
		return LightenDarkenColor(bg, lighten)
	else
		bg = vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg or 16777215
		bg = string.format("#%X", bg)
		return LightenDarkenColor(bg, darken)
	end
end

---Get list filetypes/extentions for Treesitter languages installed
---@return string[] # List of filetypes or extensions
local function getTSInstalled()
	if Installed_filetypes then
		return Installed_filetypes
	end

	Installed_filetypes = {}
	local filetye_map = {
		["python"] = "py",
		["powershell"] = "ps1"
	}

	-- Collect treesitter languages from nvim-treesitter and runtime path
	for _, path in ipairs(vim.fn.split(
	---@diagnostic disable-next-line: param-type-mismatch
		vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "nvim-treesitter") .. "," .. vim.o.runtimepath, -- combine paths
		","
	)) do
		for file, _ in vim.fs.dir(vim.fs.joinpath(path, "parser")) do
			local ftype = nil
			if file:sub(-3) == ".so" then
				ftype = file:gsub(".so", "")
			elseif file:sub(-4) == ".dll" then
				ftype = file:gsub(".dll", "")
			end

			if ftype ~= nil then
				table.insert(Installed_filetypes, ftype)
				if filetye_map[ftype] then
					table.insert(Installed_filetypes, filetye_map[ftype])
				end
			end
		end
	end

	return Installed_filetypes
end

---Check if LSP is attached to current buffer
---@param bufnr? integer buffer number
---@return boolean # true if LSP is attached
local function isLspAttached(bufnr)
	bufnr = bufnr or 0
	return #vim.lsp.get_clients({bufnr = bufnr}) ~= 0
end

---Check if buffer is a large file
---@param bufId? integer buf id
---@return boolean # true if buffer is large file
local function isLargeFile(bufId)
	bufId = bufId or 0

	-- check for value in the cache or fill it
	if LargeFile[bufId] == nil then
		local path = vim.api.nvim_buf_get_name(bufId)
		if path ~= nil and path ~= "" and vim.fn.exists(path) then
			LargeFile[bufId] = vim.fn.getfsize(path) > 250000
		end
	end

	-- return from cache
	return LargeFile[bufId]
end

---Check if tressitter is attached to buffer
---@param bufnr? integer buffer number to check
---@return boolean # true if treeistter is attached
local function isTsAttached(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local highlighter = require("vim.treesitter.highlighter")
	if highlighter.active[bufnr] then
		return true
	end
	return false
end


---Adds a popup menu
---@param menu PopupMenu Popup menu
local function popupMenuAdd(menu)
	table.insert(pop_up_menu, menu)
end
-- <~>
-- Classes</>

---@class CmdOptions
---@field option_config table<string, string[]>
---@field option_value string
CmdOptions = {}
CmdOptions.__index = CmdOptions

--- CmdOptions constructor
---@return CmdOptions
function CmdOptions:new()
	local instance = {
		option_config = {},
		option_value = {}
	}
	setmetatable(instance, CmdOptions)
	return instance
end

---Add an option
---@param option_name string option name
---@param possibleValues? string[] option values
---@param def string? default value
function CmdOptions:addOption(option_name, possibleValues, def)
	self.option_config[option_name] = possibleValues or {}
	self.option_value[option_name] = def
end

function CmdOptions:getOptions()
	return vim.tbl_keys(self.option_config)
end

function CmdOptions:option(name)
	return self.option_value[name]
end

---Get possible values for an option
---@param option_name string option name
---@return string[] # option values
function CmdOptions:getOptionValues(option_name)
	return self.option_config[option_name]
end

---Parse options with format key=value, throws error on invalid options
---@param option_list string[] list of options
---@return boolean # true if invalid options are present
function CmdOptions:parseOptions(option_list)
	local error = false

	for _, option in pairs(option_list) do
		local splits = vim.split(option, "=")
		local key = splits[1]
		local val = splits[2]
		if vim.list_contains(self:getOptions(), key) then
			self.option_value[key] = val
		else
			error = true
			vim.notify("Invalid option " .. key, vim.log.levels.ERROR)
		end
	end

	return error
end
-- <~>
-- Auto Commands</>
-- -------------
vim.api.nvim_create_autocmd(
	"BufEnter", {
		pattern = "*",
		desc = "Open directory in nvim-tree",
		callback = function()
			local path = vim.fn.expand("%:p")
			if vim.fn.isdirectory(path) ~= 0 then
				require("nvim-tree.api").tree.open({path = path})
				return true
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	{ "BufNewFile", "BufRead" }, {
		pattern = "*",
		desc = "Run for new files",
		callback = function ()
			local buf_name = vim.fn.expand("%:t")
			if string.lower(buf_name) == "todo" then
				vim.o.filetype = "todo"
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"BufWinEnter", {
		pattern = "*",
		desc = "Detect large files and disable slow plugins",
		callback = function(arg)
			if isLargeFile(arg.buf) then
				vim.b[arg.buf].minihipatterns_disable = true -- disable mini.hipatterns
				require("illuminate").pause_buf()
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"BufWinEnter", {
		pattern = "*",
		desc = "Overlength line marker",
		callback = function()
			if vim.tbl_contains(overlength_filetypes, vim.bo.filetype) and not isLargeFile() and vim.bo.textwidth > 0 then
				for _, line in ipairs(vim.fn.getbufline(vim.api.nvim_get_current_buf(), 1, 100)) do
					local line_length = #line
					if line_length > 300 then
						return
					end
				end
				vim.cmd("match Overlength /\\%" .. vim.bo.textwidth + 1 .. "v/")
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"BufWinEnter", {
		pattern = "*",
		desc = "Disable wrap for file with long lines",
		callback = function()
			for _, line in ipairs(vim.fn.getbufline(vim.api.nvim_get_current_buf(), 1, 500)) do
				local line_length = #line
				if line_length > vim.bo.textwidth then
					vim.opt_local.wrap = false
					break
				end
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"BufWritePre", {
		pattern = "*",
		desc = "Create directory if it does not exists",
		callback = function()
			--  -- Function gets a table that contains match key, which maps to `<amatch>` (a full filepath).
			-- local dirname = vim.fs.dirname(t.match)
			-- -- Attempt to mkdir. If dir already exists, it returns nil.
			-- -- Use 755 permissions, which means rwxr.xr.x
			-- vim.loop.fs_mkdir(dirname, tonumber("0755", 8))
			local filedir = vim.fn.expand("%:p:h")
			if vim.fn.isdirectory(filedir) == 0 then
				vim.fn.mkdir(filedir, "p")
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"CmdlineEnter", {
		pattern = { "/", "?" },
		desc = "Shift commandline for search",
		callback = function()
			vim.cmd("set cmdheight=1")
		end
	}
)

vim.api.nvim_create_autocmd(
	"CmdlineLeave", {
		pattern = { "/", "?" },
		desc = "Shift commandline back for search",
		callback = function()
			vim.cmd("set cmdheight=0")
		end
	}
)

vim.api.nvim_create_autocmd(
	"CursorHold", {
		pattern = "*",
		desc = "Load Treesitter on CursorHold for installed languages",
		callback = function()
			local ftype = vim.o.filetype
			if vim.tbl_contains(getTSInstalled(), ftype) then
				vim.cmd("Lazy load nvim-treesitter")
				vim.api.nvim_exec_autocmds("User", { pattern = "TSLoaded" })
				return true
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	"MenuPopup", {
		pattern = "*",
		desc = "Create popup menu based on context",
		callback = function()
			-- local currentWindow = vim.api.nvim_get_current_win()
			-- local cursorPos = vim.api.nvim_win_get_cursor(currentWindow)

			-- Fill popup options
			local options = {}
			for _,menu in pairs(pop_up_menu) do
				if menu.cond == nil or menu.cond() then
					if #options ~= 0 then
						table.insert(options, { name = "separator" })
					end
					for _,opt in pairs(menu.options) do
						local option = {}
						option["name"] = opt.name
						option["rtxt"] = opt.key
						option["cmd"] = opt.exec
						option["items"] = opt.items
						table.insert(options, option)
					end
				end
			end

			if #options ~= 0 then require("menu").open(options, { border = false, mouse = true }) end
		end
	}
)

vim.api.nvim_create_autocmd(
	"TextYankPost", {
		pattern = "*",
		desc = "Highlight text on yank",
		callback = function()
			vim.highlight.on_yank({ higroup="Search", timeout=500 })
		end
	}
)

vim.api.nvim_create_autocmd(
	"User", {
		pattern = "VeryLazy",
		desc = "Lazy load clipboard provider",
		callback = function()
			vim.cmd([[
				unlet g:loaded_clipboard_provider
				runtime autoload/provider/clipboard.vim
			]])
			return true
		end
	}
)
-- <~>
-- Mappings</>
-----------
-- ━━ command abbreviations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("ca", "sf",  "sfind")
vim.keymap.set("ca", "vsf", "vert sfind")
-- ━━ commands ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "!!",    ":<Up><CR>",   { desc = "Run last command" })
vim.keymap.set("n", "<C-q>", "<cmd>q<CR>",  { desc = "Close window" })
vim.keymap.set("n", "<C-s>", "<cmd>w!<CR>", { desc = "Save file" })
-- ━━ mouse ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump backward" })
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump forward" })
-- ━━ paste ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("c", "<C-p>", "<C-r>+", { desc = "Paste in command line" })
vim.keymap.set("i", "<C-p>", "<C-o>P", { desc = "Paste in insert mode", noremap = true })
vim.keymap.set("v", "p",       '"_dP',   { desc = "Do not copy while pasting in visual mode" })
-- ━━ path separator convertor ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "wc\\", "<cmd>s/\\/\\+/\\\\\\\\/g<CR>", { desc = "Convert / to \\\\" })
vim.keymap.set("n", "wc/",  "<cmd>s/\\\\\\+/\\//g<CR>",     { desc = "Convert \\\\ to /" })
-- ━━ register ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("i", "<C-R>", function() require("telescope.builtin").registers(require("telescope.themes").get_cursor()) end, { desc = "Pick registers" })
-- ━━ search ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search in select region" })
-- ━━ scrolling ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set({"n", "v"}, "<S-Up>",   "<C-y>", { noremap = true, desc = "Scroll 1 line up" })
vim.keymap.set({"n", "v"}, "<S-Down>", "<C-e>", { noremap = true, desc = "Scroll 1 line down" })
-- ━━ tab switch ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-S-Tab>", "<cmd>tabprevious<CR>", { desc = "Switch to previous tab" })
vim.keymap.set("n", "<C-Tab>",   "<cmd>tabnext<CR>",     { desc = "Switch to next tab" })
-- ━━ window controls ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-w>p", "<cmd>Peek %<CR>", { desc = "Open current buffer in Peek" })
vim.keymap.set("n", "<M-w>",  function() require("which-key").show({ keys = "<C-w>", loop = true }) end, { desc = "Open window controls" })
vim.keymap.del("n", "<C-w>d")
-- ━━ word deletion ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("i", "<C-BS>",  "<C-w>",   { desc = "Delete a word backward" })
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { desc = "Delete a word" })
vim.keymap.set("n", "<BS>",    "X",       { desc = "Delete a letter backward" })
vim.keymap.set("n", "<C-BS>",  "db",      { desc = "Delete a word backward" })
vim.keymap.set("c", "<C-BS>",  "<C-w>",      { desc = "Delete a word backward" })
vim.keymap.set("n", "<C-Del>", "dw",      { desc = "Delete a word" })
-- ━━ word selection ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-Space>", "viw", { desc = "Select current word" })
vim.keymap.set("n", "<Space>",   "ciw", { desc = "Change current word" })
vim.keymap.set("v", "<C-Space>", function() require("flash").treesitter({ actions = { ["<c-space>"] = "next" }, label = { before = false, after = false }, prompt = { enabled = false } }) end, { desc = "Increment selected node" })
-- <~>
-- Misc</>
-------
vim.cmd[[
if executable("fd")
	func FindFiles(cmdarg, cmdcomplete)
		let fnames = systemlist('git ls-files')
		return fnames->filter('v:val =~? a:cmdarg')
	endfunc
	set findfunc=FindFiles
endif
]]

-- set powershell shell
vim.cmd([[
	if has("win32") || has("win64") || has("win16")
			let &shell = executable("pwsh") ? "pwsh" : "powershell"
			let &shellcmdflag = '-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';$PSStyle.OutputRendering=''plaintext'';'
			let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
			let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
			set shellquote= shellxquote=
	endif
]])

vim.diagnostic.config({
	float = {
		source = "if_many",
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.error,
			[vim.diagnostic.severity.WARN] = icons.warn,
			[vim.diagnostic.severity.INFO] = icons.info,
			[vim.diagnostic.severity.HINT] = icons.hint,
		}
	},
	update_in_insert = false,
	virtual_text = {
		prefix = function(diag, _, _)
			if diag.severity == vim.diagnostic.severity.ERROR then
				return icons.error
			elseif diag.severity == vim.diagnostic.severity.HINT then
				return icons.hint
			elseif diag.severity == vim.diagnostic.severity.INFO then
				return icons.info
			elseif diag.severity == vim.diagnostic.severity.WARN then
				return icons.warn
			end
			return ""
		end,
		source = "if_many"
	}
})

vim.cmd("sign define DiagnosticSignError text=" .. icons.error .. " texthl=DiagnosticSignError linehl= numhl=")
vim.cmd("sign define DiagnosticSignWarn  text=" .. icons.warn  .. " texthl=DiagnosticSignWarn  linehl= numhl=")
vim.cmd("sign define DiagnosticSignInfo  text=" .. icons.info  .. " texthl=DiagnosticSignInfo  linehl= numhl=")
vim.cmd("sign define DiagnosticSignHint  text=" .. icons.hint  .. " texthl=DiagnosticSignHint  linehl= numhl=")

vim.highlight.priorities = {
	syntax = 50,
	treesitter = 100,
	semantic_tokens = 99,
	diagnostics = 150,
	user = 200
}

-- Lazy load dressing
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require("dressing")
	vim.ui.select(...)
end

-- Lazy load dressing
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.input = function(...)
	require("dressing")
	vim.ui.input(...)
end

vim.fn.matchadd(
	"HighlightURL",
	"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+",
	priority_hl.url
)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)
-- <~>
-- Commands</>
-----------
-- FEAT: how about a picker
vim.api.nvim_create_user_command(
	"Cdroot",
	function(opts)
		---Get rooter path
		---@param option string option for rooter
		---@return string # root path
		local function getRoot(option)
			local cwd = _CWD or vim.fn.getcwd()
			local root_path = cwd

			if option == "cwd" then
				root_path = cwd
			elseif option == "cwd_git" then
				root_path = vim.fs.dirname(vim.fs.find({ ".git" }, { path = cwd, upward = true, limit = 1 })[1])
			elseif option == "file" then
				---@diagnostic disable-next-line: param-type-mismatch
				root_path = vim.fn.fnamemodify(vim.fn.bufname("%"), ":p:h")
			elseif option == "file_git" then
				---@diagnostic disable-next-line: param-type-mismatch
				root_path = vim.fs.dirname(vim.fs.find({ ".git" }, { path = vim.fn.bufname("%"), upward = true, limit = 1 })[1])
			end
			return vim.fs.normalize(root_path)
		end

		local path = getRoot(opts.args:match("^(.*) \""))
		if path then
			if not _CWD then
				_CWD = vim.fn.getcwd()
			end
			vim.cmd.cd(path)
		end
	end,
	{
		complete = function() return {
			'cwd "' .. getRoot("cwd"),
			'cwd_git "' .. getRoot("cwd_git"),
			'file "' .. getRoot("file"),
			'file_git "' .. getRoot("file_git"),
		} end,
		desc = "Change directory based on current file",
		range = true,
		nargs = 1
	}
)

vim.api.nvim_create_user_command(
	"ColorizeTerminal",
	function() require("snacks").terminal.colorize() end,
	{ desc = "Replaces ansii color codes with the actual colors" }
)

vim.api.nvim_create_user_command(
	"DiffUnsaved",
	"let current_filetype = &filetype | vert new | set buftype=nofile | execute 'set filetype=' . current_filetype | unlet current_filetype | read # | 1d_ | diffthis | wincmd p | diffthis",
	{ desc = "Diff current buffer with saved file" }
)

vim.api.nvim_create_user_command(
	"Divider",
	function (opts)
		if opts.args == "clear" then
			vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace("divider"), 0, -1)
			return
		end

		local line = vim.api.nvim_win_get_cursor(0)[1]
		if opts.args == "above" then
			line = line - 1
		end

		vim.api.nvim_buf_set_extmark(
			0, vim.api.nvim_create_namespace("divider"), line, 0,
			{
				virt_lines = { { { string.rep("─", vim.api.nvim_win_get_width(0)), "Comment" } } },
				virt_lines_above = true,
				hl_mode = "combine"
			}
		)
	end,
	{ nargs = 1, complete = function(_, _, _) return { "above", "below", "clear" } end }
)

vim.api.nvim_create_user_command(
	"DropbarEnable",
	function()
		require("dropbar")
		DropbarEnabled = true
	end,
	{ desc = "Enable dropbar" }
)

vim.api.nvim_create_user_command(
	"Lazygit", -- FIX: colors
	function()
		require("snacks").lazygit.open()
	end,
	{ desc = "Open Lazygit" }
)

vim.api.nvim_create_user_command(
	"Peek",
	function(args)
		local snacks = require("snacks")
		local prev_win = Preview_win
		local path = args.args

		local function reopen(mode)
			Preview_win:hide()

			local picked_win = require('window-picker').pick_window({ include_current_win = true })
			if picked_win and vim.api.nvim_win_is_valid(picked_win) then
				vim.api.nvim_set_current_win(picked_win)
				vim.api.nvim_command(mode)
				local split_win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(split_win, Preview_win.buf)
				Preview_win:close()
			else
				Preview_win:show()
			end
		end

		-- Create floating window
		Preview_win = snacks.win({
			minimal = false,
			border = "rounded",
			file = path,
			enter = true,
			keys = {
				{ mode = "n", keymaps.open_split, function() reopen("split") end },
				{ mode = "n", keymaps.open_vsplit, function() reopen("vsplit") end },
				{ mode = "n", keymaps.open_tab, function() vim.cmd("tab split"); Preview_win:close() end },
			},
			resize = true,
			title = " " .. path .. " ",
			title_pos = "center",
			footer = " " .. keymaps.open_split .. " split " .. keymaps.open_vsplit .." vsplit " .. keymaps.open_tab .. " tab open ",
			footer_pos = "right",
			bo = { modifiable = true }
		})

		-- close previous Peek window
		if prev_win ~= nil then
			prev_win:close()
		end
	end,
	{
		complete = "file",
		desc = "Peek file content in a floating window",
		nargs = 1
	}
)
-- <~>
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Aligns     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"dhruvasagar/vim-table-mode",
	cmd = "TableModeEnable"
}

addPlugin {
	"junegunn/vim-easy-align",
	cmd = "EasyAlign"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Auto Pairs   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"windwp/nvim-autopairs",
	config = function()
		local pair = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")

		pair.setup()
		-- pair.add_rules(require("nvim-autopairs.rules.endwise-lua"))
		pair.add_rules {
			-- #include <|> pair for c and cpp
			Rule("#include <", ">", { "c", "cpp" }),
			-- Add spaces in pair after parentheses
			-- (|) --> space --> ( | )
			-- ( | ) --> ) --> ( )|
			Rule(" ", " ", "-markdown")
			:with_pair(function (opts)
				local pair_set = opts.line:sub(opts.col - 1, opts.col)
				return vim.tbl_contains({ "()", "[]", "{}" }, pair_set)
			end)
			:with_del(cond.none()),
			Rule("( ", " )")
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match(".%)") ~= nil
			end)
			:use_key(")"),
			Rule("{ ", " }")
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match(".%}") ~= nil
			end)
			:use_key("}"),
			Rule("[ ", " ]")
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match(".%]") ~= nil
			end)
			:use_key("]"),
			-- Auto add space on =
			Rule("=", "", "-xml")
			:with_pair(cond.not_inside_quote())
			:with_pair(function(opts)
				local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
				if last_char:match("[%w%=%s]") then
					return true
				end
				return false
			end)
			:replace_endpair(function(opts)
				local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
				local next_char = opts.line:sub(opts.col, opts.col)
				next_char = next_char == " " and "" or " "
				if prev_2char:match("%w$") then
					return "<bs> =" .. next_char
				end
				if prev_2char:match("%=$") then
					return next_char
				end
				if prev_2char:match("=") then
					return "<bs><bs>=" .. next_char
				end
				return ""
			end)
			:set_end_pair_length(0)
			:with_move(cond.none())
			:with_del(cond.none())
		}
	end,
	event = "InsertEnter"
}

-- addPlugin {
-- 	"saghen/blink.pairs",
-- 	config = function(plugin, cfg)
-- 		-- add space around "=" sequence
-- 		vim.keymap.set("i", "=", function()
-- 			local col = vim.fn.col(".") - 1
-- 			if col == 0 then return "="end

-- 			local line = vim.api.nvim_get_current_line()
-- 			local prev = line:sub(col, col)
-- 			local prev2 = line:sub(col-1, col)

-- 			if prev2 == "= " then return "<BS><BS>== " -- add around = sequence
-- 			elseif prev:match("%w") then return " = " -- add for first =
-- 			else return "=" end

-- 		end, { expr = true, noremap = true })

-- 		require('vim._extui').enable({})
-- 		require(plugin.name).setup(cfg)
-- 	end,
-- 	dependencies = "saghen/blink.download",
--   version = '*', -- (recommended) only required with prebuilt binaries
-- 	event = "InsertEnter",
-- 	--- @module "blink.pairs"
-- 	--- @type blink.pairs.Config
-- 	opts = {
-- 		mappings = {
-- 			enabled = true,
-- 			disabled_filetypes = {},
-- 		},
-- 		highlights = {
-- 			enabled = true,
-- 			groups = {
-- 				"BlinkPairsOrange",
-- 				"BlinkPairsPurple",
-- 				"BlinkPairsBlue",
-- 			},

-- 			matchparen = {
-- 				enabled = false,
-- 				group = "BlinkPairsMatchParen",
-- 			},
-- 		},
-- 		debug = false,
-- 	}
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Code Map    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/kensyo/nvim-scrlbkun
addPlugin {
	"dstein64/nvim-scrollview",
	cmd = "ScrollViewToggle",
	opts = {
		cursor_symbol = ">",
		search_symbol = " ",
		floating_windows = true,
		hide_on_intersect = true,
		signs_on_startup = {
			"changelist",
			"conflicts",
			"cursor",
			"diagnostics",
			"folds",
			"keywords",
			"latestchange",
			"loclist",
			"marks",
			"quickfix",
			"search",
			"spell"
		}
	}
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Coloring    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	-- https://github.com/FluxxField/bionic-reading.nvim
	-- https://github.com/nullchilly/fsread.nvim
	"JellyApple102/easyread.nvim",
	cmd = "EasyreadToggle",
	opts = {
		hlValues = {
			["1"] = 1,
			["2"] = 1,
			["3"] = 2,
			["4"] = 2,
			["fallback"] = 0.4
		},
		hlgroupOptions = { bold = true },
		fileTypes = {},
		saccadeInterval = 0,
		saccadeReset = false,
		updateWhileInsert = true
	}
}

addPlugin {
	"grapp-dev/nui-components.nvim",
	dependencies = "MunifTanjim/nui.nvim"
}

vim.keymap.set("v", "<Leader>ft", function()
	-- popup menu to apply highlight on text, like bold, italic, fg color, bg color
	-- https://nui-components.grapp.dev/docs/getting-started
	-- https://github.com/jrop/morph.nvim
	-- https://github.com/nvzone/volt
	-- bold toggle
	vim.api.nvim_set_hl(0, "NuiComponentsButton", { bg = "#0000FF" })
	vim.api.nvim_set_hl(0, "NuiComponentsButtonActive", { bg = "#00FF00" })
	vim.api.nvim_set_hl(0, "NuiComponentsButtonFocus", { bg = "#FFFF00" })

	local txtfmt_ns = vim.api.nvim_create_namespace("txtfmt_ns")
	local buf = vim.api.nvim_get_current_buf()

	vim.fn.feedkeys(":", "nx")
	local start_mark = vim.api.nvim_buf_get_mark(0, "<")
	local start_row, start_col = start_mark[1], start_mark[2]
	local end_mark = vim.api.nvim_buf_get_mark(0, ">")
	local end_row, end_col = end_mark[1], end_mark[2]

	local n = require("nui-components")

	local widget = n.create_renderer({
		width = 2,
		height = 1,
	})

	local getHl = function()
		return {}
	end

	widget:render(function()
		return n.columns(
			n.button({
				label = " B ",
				autofocus = true,
				press_key = { "<LeftMouse>", "<CR>" },
				on_press = function(self)
					local props = self:get_props()
					props.is_active = not props.is_active
					local cur_hl = getHl()
					vim.hl.range(buf, txtfmt_ns, "Boolean", start_mark, end_mark)
				end
			})
		)
	end)

	-- italic toggle
	-- underline toggle
	-- strikethrough toggle
	-- fg/bg color tab
		-- color palette
		-- color slider
	-- Get current attributes if applied
	-- Clear all
	-- Border around widget
	-- support ctrl-v
end)

addPlugin {
	"Pocco81/high-str.nvim",
	cmd = "HSHighlight",
	init = function()
		vim.api.nvim_set_hl(0, "ExBlack2Bg", { bg = "#F8F03F" })
		popupMenuAdd({
			options = {
				{ name = "Highlight", items = {
					{ name = "Highlight 0", cmd = "HSHighlight 0" },
					{ name = "Highlight 1", cmd = "HSHighlight 1" },
					{ name = "Highlight 2", cmd = "HSHighlight 2" },
					{ name = "Highlight 3", cmd = "HSHighlight 3" },
					{ name = "Highlight 4", cmd = "HSHighlight 4" },
					{ name = "Highlight 5", cmd = "HSHighlight 5" },
					{ name = "Highlight 6", cmd = "HSHighlight 6" },
					{ name = "Highlight 7", cmd = "HSHighlight 7" },
					{ name = "Highlight 8", cmd = "HSHighlight 8" },
					{ name = "Highlight 9", cmd = "HSHighlight 9" }
				}},
				{ name = "Clear Highlight", exec = function() vim.cmd("HSRmHighlight rm_all") end },
			}
		})
	end,
	keys = {
		{ "<Leader>l", "<Cmd>HSHighlight<CR>", mode = "x", desc = "add highlight" },
		{ "<Leader>L", "<Cmd>HSRmHighlight rm_all<CR>", mode = "n", desc = "remove highlight" },
	}
}

addPlugin {
	"RRethy/vim-illuminate",
	config = function()
		require("illuminate").configure({
			delay = 400,
			min_count_to_highlight = 2,
			modes_allowlist = { "i", "n" },
			case_insensitive_regex = false,
			providers = {
				"lsp",
				"treesitter",
				"regex"
			}
		})

		vim.keymap.set("n", "]i", require("illuminate").goto_next_reference, { desc = "Jump to next illuminated text" })
		vim.keymap.set("n", "[i", require("illuminate").goto_prev_reference, { desc = "Jump to previous illuminated text" })
	end,
	event = { "CursorHold" }
}

addPlugin {
	"nvim-mini/mini.hipatterns",
	config = function(plugin)
		---Get TODO highlights from todo_config, create new highlight if required
		---@param set string Matched text
		---@return string? # Highlight name for matched string
		local function getTodo(set)
			local color_set = todo_colors[set] or todo_colors.default

			for _, hl in pairs(color_set) do
				-- create new highlight if its a color
				if hl:sub(1, 1) == "#" then
					vim.api.nvim_set_hl(0, "TodoHl" .. set, { fg = hl, force = true })
					return "TodoHl" .. set
				end

				local hl_config = vim.api.nvim_get_hl(0, { name = hl, link = false })
				if not vim.tbl_isempty(hl_config) then
					if hl_config.undercurl == true then
						vim.api.nvim_set_hl(0, "TodoHl" .. set, { fg = hl_config.sp, force = true })
						return "TodoHl" .. set
					end
					return hl
				end
			end

			return nil
		end

		--- Generate a pattern list from list of keys
		---@param keys string[] list of keys
		---@return string[] # list of patterns from keys
		local function createPatternList(keys)
			local pattern_list = {}
			for _,v in pairs(keys) do
				table.insert(pattern_list, "%f[%w]" .. v .. ":$?")
			end
			return pattern_list
		end

		local function patternFilter(cfg)
			return function(buf_id)
				if cfg.filetype then
					if vim.bo[buf_id].filetype == cfg.filetype then
						return cfg.pattern
					end
					return nil
				end
				return cfg.pattern
			end
		end

		require(plugin.name).setup({
			highlighters = (function()
				local config = {
					cpp_doc_brief     = { pattern = patternFilter({ filetype = "cpp"   , pattern = " @brief .*"           }), group = "Constant"   },
					cpp_doc_param     = { pattern = patternFilter({ filetype = "cpp"   , pattern = " @param .*"           }), group = "@variable"  },
					cpp_doc_return    = { pattern = patternFilter({ filetype = "cpp"   , pattern = " @return .*"          }), group = "@keyword"   },
					lua_doc           = { pattern = patternFilter({ filetype = "lua"   , pattern = "%s*%-%-%-%s?()@%w+()" }), group = "Constant"   },
					lua_heading       = { pattern = patternFilter({ filetype = "lua"   , pattern = "━.*━"                 }), group = "Constant"   },
					python_doc_args   = { pattern = patternFilter({ filetype = "python", pattern = "Args:"                }), group = "@type"      },
					python_doc_param  = { pattern = patternFilter({ filetype = "python", pattern = "    [%a%d_]+: "       }), group = "@parameter" },
					python_doc_raises = { pattern = patternFilter({ filetype = "python", pattern = "Raises:"              }), group = "Statement"  },
					python_doc_return = { pattern = patternFilter({ filetype = "python", pattern = "Returns:"             }), group = "@keyword"   },
					python_doc_yield  = { pattern = patternFilter({ filetype = "python", pattern = "Yields:"              }), group = "@keyword"   },
				}

				-- iterate for each config in todo_config
				for i,v in pairs(todo_config) do
					local keys = v.alt or {}
					table.insert(keys, i) -- add alt keys as well
					config[i] = { pattern = createPatternList(keys), group = getTodo(v.color) }
				end

				return config
			end)()
		})
	end,
	event = "CursorHold"
}

addPlugin {
	"KieranCanter/candela.nvim",
	cmd = "Candela",
	opts = {
		syntax_highlighting = {
			enabled = false
		}
	}
}

addPlugin {
	"fei6409/log-highlight.nvim",
	config = true,
	ft = "log"
}

addPlugin {
	"folke/todo-comments.nvim",
	config = function()
		require("todo-comments").setup({
			colors = todo_colors,
			highlight = { pattern = "(KEYWORDS):$?", multiline = false },
			keywords = todo_config,
			merge_keywords = false
		})
		TODO_COMMENTS_LOADED = true

		vim.api.nvim_create_user_command("TodoEnable", require("todo-comments").enable, { desc = "Enable TODO Comments" })
		vim.api.nvim_create_user_command("TodoDisable", require("todo-comments").disable, { desc = "Enable TODO Comments" })
	end,
	dependencies = { "luukvbaal/statuscol.nvim" },
	keys = {
		{ "[t", function() require("todo-comments").jump_prev(); vim.cmd("normal! zO") end, desc = "Previous TODO" },
		{ "]t", function() require("todo-comments").jump_next(); vim.cmd("normal! zO") end, desc = "Next TODO" }
	}
}

addPlugin {
	"brenoprata10/nvim-highlight-colors",
	cmd = "HighlightColors",
	opts = {
		render = "virtual",
		virtual_symbol = "",
		enable_hsl = false,
		enable_hsl_without_function = false,
		enable_var_usage = false,
		enable_named_colors = false
	}
}

addPlugin {
	"t9md/vim-quickhl",
	config = function()
		local colors = {}
		for _,v in pairs(ColorPalette()) do
			local hi = "guifg=" .. v.bg .. " guibg=" .. v.fg
			table.insert(colors, hi)
		end
		vim.g.quickhl_manual_colors = colors
	end,
	keys = {
		{ "<Leader>w", "<Plug>(quickhl-manual-this-whole-word)", mode = "n", desc = "toggle quickhl for word" },
		{ "<Leader>w", "<Plug>(quickhl-manual-this)",            mode = "x", desc = "toggle quickhl for selection" },
		{ "<Leader>W", "<Plug>(quickhl-manual-reset)",           mode = "n", desc = "remove all quickhl" }
	}
}

-- "yuki-yano/highlight-undo.nvim",
addPlugin {
	"tzachar/highlight-undo.nvim",
	config = true,
	keys = { "u" },
	lazy = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Colorscheme   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
local function applyColorscheme()
	vim.cmd.colorscheme("catppuccin")

	-- global override colorscheme
	vim.api.nvim_set_hl(0, "Overlength", { bg = adaptiveBG(70, -70) })
	vim.api.nvim_set_hl(0, "HighlightURL", { underline = true })
	vim.api.nvim_set_hl(0, "MatchParen", { reverse = true })

	-- configure Neovide
	if vim.fn.exists("g:neovide") == 1 then
		vim.g.neovide_normal_opacity = 0.7
		vim.g.neovide_title_background_color = GetBgOrFallback("Normal", vim.o.background == "dark" and "#000000" or "#FFFFFF")
	else
		require("mini.misc").setup_termbg_sync()
	end
end

addPlugin {
	"catppuccin/nvim",
	main = "catppuccin",
	priority = 100,
	lazy = false,
	config = function(plugin, cfg)
		require(plugin.main).setup(cfg)
		applyColorscheme()
	end,
	opts = {
		auto_integrations = true,
		background = {
			light = "latte",
			dark = "mocha"
		},
		float = {
			transparent = true,
			solid = true
		},
		transparent_background = true,
		term_colors = false,
		highlight_overrides = {
			all = function(palette)
				return {
					BlinkCmpSource = { fg = palette.surface1, style = { "italic" } }, -- FIX: color
					Todo = { fg = palette.blue, bg = "" },
					Visual = { bg = palette.surface0, style = {} }
				}
			end
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Comments    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"LudoPinelli/comment-box.nvim",
	cmd = "CB",
	config = function()
		local cb = require("comment-box")
		local cb_options = CmdOptions:new()

		cb_options:addOption("box", { "c", "l", "r" }, "l")
		cb_options:addOption("text", { "a", "c", "l", "r" }, "a")
		cb_options:addOption("type", { "box", "line" }, "box")
		cb_options:addOption("style")

		local function exec(opts)
			cb_options:parseOptions(opts.fargs)
			local func_name = cb_options:option("box") .. cb_options:option("text") .. cb_options:option("type")
			cb[func_name](cb_options:option("style"), opts.line1, opts.line2)
		end

		local function cb_complete(lead)
			if lead == "" then
				return cb_options:getOptions()
			else
				return cb_options:getOptionValues(string.sub(lead, 1, -2)) -- clip = and call
			end
		end

		vim.api.nvim_create_user_command("CB", exec, { complete = cb_complete, desc = "Create comment box", nargs = "*", range = 2 })
	end
}

addPlugin {
	"nvim-mini/mini.comment",
	keys = {
		{ "cc", mode = { "o", "v" }, desc = "Comments text object" }
	},
	opts = {
		mappings = {
			textobject = "cc"
		}
	}
}

addPlugin {
	"numToStr/Comment.nvim",
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("Comment").setup({
			ignore = "^$",
			---@diagnostic disable-next-line: missing-fields
			extra = { eol = "gce" },
		})

		require("Comment.ft")
		.set("ps1", {"# %s", "<# %s #>"})
		.set("python", {"# %s", '""" %s """'})
		.set("requirements", {"# %s"})
	end,
	keys = {
		{ "gc", mode = { "n", "v" } },
		{ "gb", mode = { "n", "v" } },
		"gcc", "gbc", "gcO", "gco", "gce"
	}
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Completion   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"saghen/blink.cmp",
	config = function(_, cfg)
		require("blink.cmp").setup(cfg)

		-- ╭─ HACK: to remove deuplicates : https://github.com/Saghen/blink.cmp/issues/1222 ─╮
		local original = require("blink.cmp.completion.list").show
		require("blink.cmp.completion.list").show = function(ctx, items_by_source)
			local seen = {}
			local function filter(item)
				if seen[item.label] then return false end
				seen[item.label] = true
				return true
			end
			for id in vim.iter(cfg.sources.default) do
				items_by_source[id] = items_by_source[id] and vim.iter(items_by_source[id]):filter(filter):totable()
			end
			return original(ctx, items_by_source)
		end
		-- ╰─────────────────────────────────────────────────────────────────────────────────╯

		for kind_name,hl in pairs(kind_hl) do
			vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind_name, hl[vim.o.background])
		end
	end,
	dependencies = { "mikavilpas/blink-ripgrep.nvim", "xzbdmw/colorful-menu.nvim" },
	event = { "CmdlineEnter", "InsertEnter" },
	---@type blink.cmp.Config
	opts = {
		appearance = {
			use_nvim_cmp_as_default = true
		},
		cmdline = {
			completion = {
				ghost_text = {
					enabled = true
				},
				list = {
					selection = {
						auto_insert = true,
						preselect = false
					}
				},
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description" }, { "source_name" }
						}
					}
				}
			},
			keymap = {
				["<Down>"] = { "fallback" },
				["<Up>"] = { "fallback" },
				["<Left>"] = { },
				["<Right>"] = { }
			},
		},
		completion = {
			accept = {
				auto_brackets = {
					enabled = true
				}
			},
			documentation = {
				auto_show = true,
				window = {
					border = dotted_border
				}
			},
			ghost_text = {
				enabled = true,
				show_with_menu = true,
				show_with_selection = true,
				show_without_menu = true,
				show_without_selection = true
			},
			list = {
				selection = {
					auto_insert = false,
					preselect = false
				}
			},
			menu = {
				enabled = true,
				auto_show = true,
				draw = {
					columns = {
						{ "kind_icon", "label", gap = 1 }, { "source_name" }
					},
					components = {
						kind_icon = {
							text = function(ctx)
								local function getIcon(_ctx)
									local kind
									local stat = nil
									if _ctx.item.textEdit ~= nil then
										stat = vim.loop.fs_stat(_ctx.item.textEdit.newText)
									end
									if stat then
										-- file/path icons
										if stat.type == "file" then
											local ext = _ctx.label:match(".[^.]+$"):gsub("%.", "")
											local icon = require("nvim-web-devicons").get_icons_by_extension()[ext]
											-- create highlight for extension
											if icon then
												_ctx._icon_hl = "BlinkCmpKindDev" .. icon.name
												vim.api.nvim_set_hl(0, _ctx._icon_hl, { fg = icon.color, bg = kind_hl["Array"][vim.o.background].bg })
												return icon.icon
											end
											kind = "File"
											_ctx._icon_hl = "BlinkCmpKind" .. kind
											return icons[kind]
										elseif stat.type == "directory" then
											kind = "Path"
											_ctx._icon_hl = "BlinkCmpKind" .. kind
											return icons[kind]
										end
									end

									if _ctx.source_name:match("cmdline$") then
										kind = "Options"
										_ctx._icon_hl = "BlinkCmpKind" .. kind
										return icons[kind]
									end

									return icons[_ctx.kind] or _ctx.kind
								end

								return " " .. getIcon(ctx)
							end,
							highlight = function(ctx)
								return ctx._icon_hl or ctx.kind_hl
							end
						},
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},
						source_name = {
							text = function(ctx)
								if ctx.source_name == "LSP" then
									return "(" .. ctx.item.client_name .. ")"
								end

								return "(" .. ctx.source_name .. ")"
							end,
							highlight = function(_)
								return "BlinkCmpSource"
							end
						}
					},
					cursorline_priority = 0,
					padding = 0
				}
			}
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
			prebuilt_binaries = {
				force_version = "v1.7.0"
			}
		},
		keymap = {
			["<Down>"] = { "select_next", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Left>"] = {},
			["<Right>"] = {},
			["<Tab>"] = {
				function(cmp)
					return cmp.is_visible() and cmp.accept({ index = cmp.get_selected_item_idx() or 1 })
				end,
				"fallback"
			}
		},
		signature = {
			enabled = true,
			trigger = {
				show_on_insert = true,
				show_on_keyword = true
			},
			window = {
				max_width = 50,
				show_documentation = true,
				winblend = 70
			}
		},
		sources = {
			default = { "buffer", "lazydev", "lsp", "path", "ripgrep" },
			providers = {
				buffer = {
					name = "buffer",
					override = {
						enabled = function()
							local utils = require("blink.cmp.sources.lib.utils")
							return
								not utils.is_command_line()
								or utils.is_command_line({ "/", "?" })
								or utils.in_ex_context({ "global", "lua", "substitute", "vglobal" })
						end
					}
				},
				cmdline = {
					name = "cmdline",
					override = {
						get_trigger_characters = function(self)
							local triggers = self:get_trigger_characters()
							table.insert(triggers, "\\")
							return triggers
						end
					}
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink"
				},
				path = {
					name = "path",
					transform_items = function(_, items)
						for _, item in pairs(items) do
							item.label = item.label:gsub("/", "\\")
							item.insertText = item.insertText:gsub("/", "\\")
						end
						return items
					end
				},
				ripgrep = {
					module = "blink-ripgrep",
					name = "ripgrep",
					---@module "blink-ripgrep"
					---@type blink-ripgrep.Options
					opts = {
						backend = {
							ripgrep = {
								max_filesize = "300K",
								search_casing = "--smart-case",
								ignore_paths = { "C:\\Users\\aloknigam" }
							},
							use = "gitgrep-or-ripgrep"
						}
					}
				},
				snippets = {
					name = "snippet"
				}
			}
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      CSV       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- addPlugin {
-- 	"cameron-wags/rainbow_csv.nvim",
-- 	config = true,
-- 	ft = "csv"
-- }

-- addPlugin {
-- 	"emmanueltouzery/decisive.nvim",
-- 	cmd = "CSVAlignVirtual",
-- 	config = function()
-- 		vim.api.nvim_create_user_command("CSVAlignVirtual", require("decisive").align_csv, { desc = "Align csv" })
-- 		vim.api.nvim_create_user_command("CSVAlignVirtualClear", require("decisive").align_csv_clear, { desc = "Clear csv align" })
-- 		require("decisive").setup({})
-- 	end
-- }

addPlugin {
	"hat0uma/csvview.nvim",
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	opts = {}
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Debugger    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"andrewferrier/debugprint.nvim",
	dependencies = { "nvim-mini/mini.comment", "nvim-mini/mini.hipatterns" },
	lazy = true,
	opts = {
		commands = {
			toggle_comment_debug_prints = nil,
			delete_debug_prints = nil
		},
		filetypes = {
			["python"] = {
				left = 'print("',
				left_var = 'print(f"',
				mid_var = "{",
				right = '")',
				right_var = '}")',
			}
		},
		keymaps = {
			normal = {
				plain_below = "<Leader>dp",
				plain_above = "<Leader>dP",
				variable_below = "<Leader>dv",
				variable_above = "<Leader>dV",
				surround_plain = "<Leader>ds",
				surround_variable = "<Leader>dsv",
				variable_below_alwaysprompt = "<Leader>dw",
				variable_above_alwaysprompt = "<Leader>dW",
				textobj_below = nil,
				textobj_above = nil,
				toggle_comment_debug_prints = "<Leader>dc",
				delete_debug_prints = "<Leader>dd",
			},
			visual = {
				variable_below = "<Leader>dv",
				variable_above = "<Leader>dV",
				surround_variable = "<Leader>dsv"
			}
		}
	},
	config = function(_, cfg)
		require("debugprint").setup(cfg)
		vim.cmd("ResetDebugPrintsCounter")
	end,
	keys = {
		"<Leader>dP", "<Leader>dW", "<Leader>dc", "<Leader>dd", "<Leader>dp", "<Leader>ds", "<Leader>dsv", "<Leader>dw",
		{ "<Leader>dv", mode = { "n", "v" } },
		{ "<Leader>dV", mode = { "n", "v" } }
	}
}

-- https://github.com/PatschD/zippy.nvim
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/Willem-J-an/nvim-dap-powershell
-- https://github.com/Willem-J-an/visidata.nvim
-- https://github.com/byuki/one-small-step-for-vimkind
-- https://github.com/carriga/nvim-dap-ui
-- https://github.com/fussenegger/nvim-dap
-- https://github.com/gergol/cmake-debugger.nvim
-- https://github.com/iadOz/nvim-dap-repl-highlights
-- https://github.com/igorlfs/nvim-dap-view
-- https://github.com/jay-babu/mason-nvim-dap.nvim
-- https://github.com/jonboh/nvim-dap-rr
-- https://github.com/lucaSartore/nvim-dap-exception-breakpoints
-- https://github.com/mfussenegger/nvim-dap-python
-- https://github.com/nvim-telescope/telescope-dap.nvim
-- https://github.com/ofirgall/goto-breakpoints.nvim
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Doc Generator  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"danymat/neogen",
	cmd = "Neogen",
	opts = {
		input_after_comment = true,
		placeholders_hl = "None",
		placeholders_text = {
			["description"] = "[DOCME" .. ": description].",
			["tparam"] = "[DOCME" .. ": tparam]",
			["parameter"] = "[DOCME" .. ": parameter]",
			["return"] = "[DOCME" .. ": return]",
			["class"] = "[DOCME" .. ": class]",
			["throw"] = "[DOCME" .. ": throw]",
			["varargs"] = "[DOCME" .. ": varargs]",
			["type"] = "[DOCME" .. ": type]",
			["attribute"] = "[DOCME" .. ": attribute]",
			["args"] = "[DOCME" .. ": args]",
			["kwargs"] = "[DOCME" .. ": kwargs]",
		},
		snippet_engine = "nvim"
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ File Explorer  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"b0o/nvim-tree-preview.lua",
	opts = {
		max_height = 500,
		max_width = 500,
	}
}

addPlugin {
	"nvim-tree/nvim-tree.lua",
	cmd = "NvimTreeOpen",
	opts = {
		actions = {
			change_dir = {
				enable = true,
				global = false,
				restrict_above_cwd = false,
			},
			expand_all = {
				exclude = { ".git" },
				max_folder_discovery = 300,
			},
			file_popup = {
				open_win_config = {
					border = "rounded",
					col = 1,
					relative = "cursor",
					row = 1,
					style = "minimal",
				},
			},
			open_file = {
				quit_on_open = false,
				resize_window = true,
				window_picker = {
					chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
					enable = true,
					exclude = {
						buftype = { "nofile", "terminal", "help" },
						filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
					},
					picker = "default",
				},
			},
			remove_file = { close_window = true },
			use_system_clipboard = true,
		},
		auto_reload_on_write = true,
		diagnostics = {
			debounce_delay = 50,
			enable = true,
			icons = {
				error   = icons.error,
				hint    = icons.hint,
				info    = icons.info,
				warning = icons.warn,
			},
			severity = {
				min = vim.diagnostic.severity.HINT,
				max = vim.diagnostic.severity.ERROR,
			},
			show_on_dirs = true,
			show_on_open_dirs = true,
		},
		disable_netrw = true,
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
			ignore_dirs = {},
		},
		filters = {
			dotfiles = true,
			git_clean = false,
			no_buffer = false,
			custom = {},
			exclude = {},
		},
		git = {
			enable = true,
			ignore = true,
			show_on_dirs = true,
			show_on_open_dirs = true,
			timeout = 400,
		},
		hijack_cursor = true,
		hijack_directories = {
			auto_open = true,
			enable = true,
		},
		hijack_netrw = true,
		hijack_unnamed_buffer_when_opening = false,
		live_filter = {
			always_show_folders = true,
			prefix = "󰈲 ",
		},
		log = {
			enable = false,
			truncate = false,
			types = {
				all         = false,
				config      = false,
				copy_paste  = false,
				dev         = false,
				diagnostics = false,
				git         = false,
				profile     = false,
				watcher     = false,
			},
		},
		modified = {
			enable = true,
			show_on_dirs = true,
			show_on_open_dirs = true
		},
		notify = { threshold = vim.log.levels.INFO },
		on_attach = function(bufnr)
			vim.wo.statuscolumn = ""

			---Common options with description
			---@param desc string description
			---@return table # common options with description
			local function opts(desc)
			  return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			local api = require("nvim-tree.api")
			local preview = require("nvim-tree-preview")
			vim.keymap.set("n", "-",              api.tree.change_root_to_parent,     opts("Up"))
			vim.keymap.set("n", "<",              api.node.navigate.sibling.prev,     opts("Previous Sibling"))
			vim.keymap.set("n", "<2-LeftMouse>",  api.node.open.edit,                 opts("Open"))
			vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node,       opts("CD"))
			vim.keymap.set("n", "<C-e>",          api.node.open.replace_tree_buffer,  opts("Open: In Place"))
			vim.keymap.set("n", "<CR>",           api.node.open.edit,                 opts("Open"))
			vim.keymap.set("n", "<F2>",           api.fs.rename_sub,                  opts("Rename: Omit Filename"))
			vim.keymap.set("n", "<Leader>h",      api.node.show_info_popup,           opts("Info"))
			vim.keymap.set("n", "<Tab>",          preview.node_under_cursor,          opts("Preview"))
			vim.keymap.set("n", ">",              api.node.navigate.sibling.next,     opts("Next Sibling"))
			vim.keymap.set("n", "D",              api.fs.trash,                       opts("Trash"))
			vim.keymap.set("n", "E",              api.tree.expand_all,                opts("Expand All"))
			vim.keymap.set("n", "F",              api.live_filter.clear,              opts("Clean Filter"))
			vim.keymap.set("n", "H",              api.tree.toggle_hidden_filter,      opts("Toggle Filter: Dotfiles"))
			vim.keymap.set("n", "I",              api.tree.toggle_gitignore_filter,   opts("Toggle Filter: Git Ignore"))
			vim.keymap.set("n", "O",              api.node.open.no_window_picker,     opts("Open: No Window Picker"))
			vim.keymap.set("n", "P",              preview.watch,                      opts("Toggle Preview"))
			vim.keymap.set("n", "R",              api.tree.reload,                    opts("Refresh"))
			vim.keymap.set("n", "S",              api.tree.search_node,               opts("Search"))
			vim.keymap.set("n", "U",              api.tree.toggle_custom_filter,      opts("Toggle Filter: Hidden"))
			vim.keymap.set("n", "W",              api.tree.collapse_all,              opts("Collapse"))
			vim.keymap.set("n", "Y",              api.fs.copy.relative_path,          opts("Copy Relative Path"))
			vim.keymap.set("n", "[c",             api.node.navigate.git.prev,         opts("Prev Git"))
			vim.keymap.set("n", "[d",             api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
			vim.keymap.set("n", "]c",             api.node.navigate.git.next,         opts("Next Git"))
			vim.keymap.set("n", "]d",             api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
			vim.keymap.set("n", "a",              api.fs.create,                      opts("Create"))
			vim.keymap.set("n", "bd",             api.marks.bulk.delete,              opts("Delete Bookmarked"))
			vim.keymap.set("n", "bm",             api.marks.toggle,                   opts("Toggle Bookmark"))
			vim.keymap.set("n", "bmv",            api.marks.bulk.move,                opts("Move Bookmarked"))
			vim.keymap.set("n", "c",              api.fs.copy.node,                   opts("Copy"))
			vim.keymap.set("n", "d",              api.fs.remove,                      opts("Delete"))
			vim.keymap.set("n", "f",              api.live_filter.start,              opts("Filter"))
			vim.keymap.set("n", "g?",             api.tree.toggle_help,               opts("Help"))
			vim.keymap.set("n", "gy",             api.fs.copy.absolute_path,          opts("Copy Absolute Path"))
			vim.keymap.set("n", "o",              api.node.open.edit,                 opts("Open"))
			vim.keymap.set("n", "p",              api.fs.paste,                       opts("Paste"))
			vim.keymap.set("n", "q",              api.tree.close,                     opts("Close"))
			vim.keymap.set("n", "r",              api.fs.rename,                      opts("Rename"))
			vim.keymap.set("n", "s",              api.node.run.system,                opts("Run System"))
			vim.keymap.set("n", "x",              api.fs.cut,                         opts("Cut"))
			vim.keymap.set("n", "y",              api.fs.copy.filename,               opts("Copy Name"))
			vim.keymap.set("n", keymaps.open_split,  api.node.open.horizontal,        opts("Open: Horizontal Split"))
			vim.keymap.set("n", keymaps.open_tab,    api.node.open.tab,               opts("Open: New Tab"))
			vim.keymap.set("n", keymaps.open_vsplit, api.node.open.vertical,          opts("Open: Vertical Split"))
		end,
		prefer_startup_root = false,
		reload_on_bufenter = false,
		renderer = {
			add_trailing = true,
			full_name = true,
			group_empty = false,
			hidden_display = "all",
			highlight_git = true,
			highlight_diagnostics = true,
			highlight_opened_files = "all",
			highlight_modified = "all",
			highlight_bookmarks = "all",
			highlight_clipboard = "name",
			indent_markers = {
				enable = true,
				icons = {
					bottom = "─",
					corner = "╰",
					edge   = "│",
					item   = "⎬",
					none   = " ",
				},
				inline_arrows = true,
			},
			indent_width = 2,
			root_folder_label = ":~:s?$?/..?",
			icons = {
				bookmarks_placement = "signcolumn",
				diagnostics_placement = "after",
				git_placement = "signcolumn",
				glyphs = {
					bookmark = icons.bookmark,
					default  = icons.file_unnamed,
					folder = {
						arrow_closed = icons.fold_close,
						arrow_open   = icons.fold_open,
						default      = icons.folder_close,
						empty        = "",
						empty_open   = "",
						open         = icons.folder_open,
						symlink      = "",
						symlink_open = "",
					},
					git = {
						deleted   = "󰧧",
						ignored   = " ",
						renamed   = "➜",
						staged    = "⏽",
						unmerged  = "",
						unstaged  = "󰇝",
						untracked = icons.file_added,
					},
					symlink = "󱅷",
				},
				modified_placement = "after",
				padding = " ",
				show = {
					file = true,
					folder = true,
					folder_arrow = true,
					git = true,
					modified = true
				},
				symlink_arrow = icons.symlink_arrow,
				webdev_colors = true,
				web_devicons = {
					file = {
						enable = true,
						color = true,
					},
					folder = {
						enable = false,
						color = true,
					},
				},
			},
			special_files = { "Makefile", "README.md", "TODO.md", "readme.md" },
			symlink_destination = true,
		},
		respect_buf_cwd = false,
		root_dirs = {},
		select_prompts = false,
		sort_by = "name",
		sync_root_with_cwd = true,
		system_open = {
			cmd = "",
			args = {},
		},
		tab = {
			sync = {
				close = false,
				ignore = {},
				open = false,
			},
		},
		trash = {
			cmd = "gio trash",
			require_confirm = true,
		},
		ui = {
			confirm = {
				remove = true,
				trash = true
			}
		},
		update_focused_file = {
			debounce_delay = 15,
			enable = true,
			ignore_list = {},
			update_root = false,
		},
		view = {
			adaptive_size = true,
			centralize_selection = true,
			cursorline = true,
			float = {
				enable = false,
				open_win_config = {
					border = "rounded",
					col = 1,
					height = 30,
					relative = "editor",
					row = 1,
					width = 30,
				},
				quit_on_focus_loss = true,
			},
			number = false,
			preserve_window_proportions = false,
			relativenumber = false,
			side = "left",
			signcolumn = "yes",
			width = 30,
		},
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  File Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
FileTypeActions = {
	["NvimTree"] = function(_)
		vim.cmd("setlocal statuscolumn=")
	end,
	["csv"] = function(_)
		vim.cmd("setlocal cursorlineopt=both")
	end,
	["neotest-summary"] = function(_)
		vim.cmd.setlocal("nowrap")
	end,
	["markdown"] = function(_)
		vim.g.table_mode_corner = "|"
		vim.cmd[[
			setlocal listchars-=multispace:·
			setlocal listchars-=lead:·
		]]
	end,
	["todo"] = function(_)
		vim.cmd("set filetype=markdown")
	end
}

vim.api.nvim_create_autocmd(
	"FileType", {
		pattern = "*",
		desc = "Run custom actions per filetype",
		callback = function(arg)
			local ftype = vim.o.filetype
			local actions = FileTypeActions[ftype]

			if actions then
				actions(arg.buf)
			end

			-- Load syntax for non treesitter filetypes
			if vim.tbl_contains(getTSInstalled(), ftype) == false then
				vim.cmd("syntax on")
			end
		end
	}
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Folding     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- create own folding code
-- Use nvim-ufo python description
-- Provider indent
-- Provider treesitter
-- Provider lsp
-- Provider for markdown ?
-- Provider fold import section in python
-- fold python docstring and if and loops like nvim-ufo

-- Mapping to fold recursively for current buffer only
vim.keymap.set("n", "zz", function()
	require("statuscol")
	vim.wo.foldcolumn = "1"
	if vim.wo.foldmethod ~= "marker" and isTsAttached() then
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
	end
	vim.wo.foldlevel = 1

	CURRENT_LINE_MAP = {}

	local function addCurrentLine(virtText, lnum, ctx)
		local current_line = vim.api.nvim_buf_get_lines(ctx.bufnr, lnum-1, lnum, false)[1]
		local count = 0
		local prev_capture = nil
		local text = ""
		local curr_capture

		for i in current_line:gmatch(".") do
			local capture = vim.treesitter.get_captures_at_pos(ctx.bufnr, lnum-1, count)
			if #capture > 0 then
				curr_capture = "@" .. capture[#capture].capture
			else
				curr_capture = nil
			end

			if curr_capture ~= prev_capture then
				table.insert(virtText, { text, prev_capture })
				text = ""
			end
			text = text .. i

			prev_capture = curr_capture
			count = count + 1
		end
		table.insert(virtText, { text, prev_capture })
	end

	---Python fold text generator
	local function ufoFoldPython(virtText, lnum, ctx)
		local function getDoc(cnum, bufnr)
			local lines = vim.api.nvim_buf_get_lines(bufnr, cnum-1, cnum+2, false)
			local cur_line = lines[1]
			local next_line = lines[2]

			-- for
			-- """
			if cur_line:find('^%s*[\'"]+$') then
				if cur_line == next_line then
					return (" " .. next_line):gsub("%s+", " ")
				end
				next_line = next_line:gsub('"""$', ""):gsub("'''$", ""):gsub("%s+$", "")
				return (next_line .. cur_line):gsub("%s+", " ")
			end

			-- for
			-- """ docstring
			if cur_line:find('^%s*[\'"]+') then
				return cur_line:gsub('[^"^\']', "")
			end

			-- for
			-- code
			-- """
			-- docstring
			if next_line:find('^%s*[\'"]+$') then
				next_line = lines[3]
				return '  ' .. next_line:gsub('^%s*[\'"]*', ''):gsub('[%s\'"]*$', "")
			end

			-- for
			-- code
			-- """ docstring
			if next_line:find('^%s*[\'"]+') then
				return "  " .. next_line:gsub('^%s*[\'"]*', ""):gsub('[%s\'"]*$', "")
			end

			return nil
		end

		-- do not show docs in diff mode
		if vim.wo[ctx.winid].diff == false then
			local doc_line = getDoc(lnum, ctx.bufnr)
			if doc_line then
				table.insert(virtText, { doc_line, "@string.documentation.python" })
			end
		end
	end

	function FoldText()
		local fold_text = {}
		local ctx = {
			bufnr = vim.api.nvim_get_current_buf(),
			winid = vim.fn.win_getid()
		}
		if CURRENT_LINE_MAP[vim.v.foldstart] then
			fold_text = CURRENT_LINE_MAP[vim.v.foldstart]
		else
			addCurrentLine(fold_text, vim.v.foldstart, ctx)
			CURRENT_LINE_MAP[vim.v.foldstart] = fold_text
		end

		ufoFoldPython(fold_text, vim.v.foldstart, ctx)
		return fold_text
	end
	vim.cmd("set foldtext=v:lua.FoldText()")
end, { noremap = true, silent = true, buffer = true })

addPlugin {
	"kevinhwang91/nvim-ufo",
	config = function()
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
		vim.cmd("hi clear Folded")

		---Generic fold text generator
		---@param virtText UfoExtmarkVirtTextChunk[] list of tokens and its highlight
		---@param lnum number first line number of fold
		---@param endLnum number last line number of fold
		---@param width number max width for fold text
		---@param truncate fun(str: string, width: number): string truncate the str to become specific width
		---@param _ UfoFoldVirtTextHandlerContext the context used by ufo, export to caller
		---@return UfoExtmarkVirtTextChunk[] # Generated fold text
		local function ufoFoldGeneric(virtText, lnum, endLnum, width, truncate, _)
			local newVirtText = {}
			local suffix = ("󰕱 %d"):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					-- str width returned from truncate() may less than 2nd argument, need padding
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { " ", "" })
			table.insert(newVirtText, { suffix, "Comment" })
			return newVirtText
		end


		---Resolves fold method by filetype
		---@param virtText UfoExtmarkVirtTextChunk[] list of tokens and its highlight
		---@param lnum number first line number of fold
		---@param endLnum number last line number of fold
		---@param width number max width for fold text
		---@param truncate fun(str: string, width: number): string truncate the str to become specific width
		---@param ctx UfoFoldVirtTextHandlerContext the context used by ufo, export to caller
		---@return UfoExtmarkVirtTextChunk[] # Generated fold text
		local function ufoFoldResolve(virtText, lnum, endLnum, width, truncate, ctx)
			local ftype = vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr })

			if ftype == "python" then
				require("ufo.decorator"):setVirtTextHandler(ctx.bufnr, ufoFoldPython)
				return ufoFoldPython(virtText, lnum, endLnum, width, truncate, ctx)
			else
				return ufoFoldGeneric(virtText, lnum, endLnum, width, truncate, ctx)
			end
		end

		require("ufo").setup({
			fold_virt_text_handler = ufoFoldResolve,
			provider_selector = function(_, _, _)
				return "treesitter"
			end
		})

		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
	end,
	dependencies = { "kevinhwang91/promise-async", "luukvbaal/statuscol.nvim" },
	-- init = function()
	-- 	-- Mapping to attach nvim-ufo
	-- 	vim.keymap.set("n", "zz", function()
	-- 		require("ufo").attach()

	-- 		-- modify mapping to close folds
	-- 		vim.keymap.set("n", "zz", function()
	-- 			require("ufo.action").closeFolds(1)
	-- 		end, { buffer = 0, desc = "Fold to level 1" })
	-- 	end, { desc = "Attach nvim-ufo" })
	-- end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Formatting   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"stevearc/conform.nvim",
	init = function()
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			local filename = vim.fn.expand("%:t")
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			vim.notify(" Formatting " .. filename, vim.log.levels.INFO)
			vim.g.formatting = " " .. filename
			require("conform").format(
				{ async = true, range = range },
				function()
					vim.notify(" Completed " .. filename, vim.log.levels.INFO)
					vim.g.formatting = nil
				end
			)
		end, { range = true })
	end,
	opts = {
		format_after_save = nil,
		formatters_by_ft = {
			cpp = { "clang-format" },
			json = { "prettier" },
			markdown = { "prettier" },
			python = { "ruff_format", "ruff_organize_imports" },
			yaml = { "prettier" },
			xml = { "prettier" }
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      Git       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"nvim-mini/mini.diff",
	init = function()
		vim.api.nvim_create_user_command(
			"ToggleMiniDiff",
			function()
				local mini = require("mini.diff")
				if mini.get_buf_data(0) == nil then
					mini.enable()
					mini.toggle_overlay()
				else
					mini.toggle_overlay()
					mini.disable()
				end
			end, {
				desc = "Toggle mini diff word highlight"
			}
		)
	end,
	config = true
}

addPlugin {
	"isakbm/gitgraph.nvim",
	cmd = "GitGraph",
	dependencies = { "sindrets/diffview.nvim" },
	opts = {
		symbols = {
			merge_commit = "",
			commit = "󰜘",
		},
		format = {
			timestamp = "%H:%M:%S %d-%m-%Y",
			fields = { "hash", "timestamp", "author", "branch_name", "tag" },
		},
	},
	init = function()
		vim.api.nvim_create_user_command("GitGraph", function()
			require("gitgraph").draw({}, { all = true, max_count = 5000 })
		end, {})
	end,
}

addPlugin {
	"rhysd/git-messenger.vim",
	cmd = "GitMessenger",
	config = function()
		vim.g.git_messenger_always_into_popup = true
		vim.g.git_messenger_floating_win_opts = { border = "rounded" }
		vim.g.git_messenger_into_popup_after_show = false
		vim.g.git_messenger_max_popup_height = 30
		vim.g.git_messenger_max_popup_width = 80
		vim.g.git_messenger_popup_content_margins = false
	end
}

addPlugin {
	"FabijanZulj/blame.nvim",
	opts = {
		date_format = "%d/%m/%Y",
		mappings = {
			commit_info = "?",
		}
	},
	cmd = "BlameToggle"
}

addPlugin {
	"aaronhallaert/advanced-git-search.nvim",
	cmd = "AdvancedGitSearch",
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			extensions = {
				advanced_git_search = {
					diff_plugin = "diffview",
					git_flags = {},
					git_diff_flags = {},
					show_builtin_git_pickers = true,
				}
			}
		})

		telescope.load_extension("advanced_git_search")
	end,
	dependencies = { "nvim-telescope/telescope.nvim" }
}

addPlugin {
	"lewis6991/gitsigns.nvim",
	cmd = "Gitsigns",
	dependencies = { "luukvbaal/statuscol.nvim" },
	event = { "TextChangedI" },
	keys = {
		{ "[c", mode = "n", desc = "previous git diff change" },
		{ "]c", mode = "n", desc = "next git diff change" }
	},
	opts = {
		attach_to_untracked = true,
		current_line_blame_formatter = " 󰀄 <author> 󰔟 <committer_time:%R>  <summary>",
		on_attach = function (bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "[c", function()
				if vim.wo.diff then return "[c" end
				vim.schedule(function() gs.nav_hunk("prev", { preview = true }) end)
				return "<Ignore>"
			end, { desc = "previous git diff change", expr = true })

			map("n", "]c", function()
				if vim.wo.diff then return "]c" end
				vim.schedule(function() gs.nav_hunk("next", { preview = true }) end)
				return "<Ignore>"
			end, { desc = "next git diff change", expr = true })
		end,
		preview_config = {
			border = dotted_border
		},
		signs = {
			add          = { text = icons.diff_add           },
			change       = { text = icons.diff_change        },
			changedelete = { text = icons.diff_change_delete },
			delete       = { text = icons.diff_delete        },
			topdelete    = { text = icons.diff_delete_top    },
			untracked    = { text = icons.diff_untracked }
		},
		signs_staged = {
			add          = { text = icons.diff_add           },
			change       = { text = icons.diff_change        },
			changedelete = { text = icons.diff_change_delete },
			delete       = { text = icons.diff_delete        },
			topdelete    = { text = icons.diff_delete_top    },
			untracked    = { text = icons.diff_untracked }
		},
		trouble = false
	}
}

addPlugin {
	"sindrets/diffview.nvim",
	cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Icons      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"2kabhishek/nerdy.nvim",
	cmd = "Nerdy",
	config = true,
	dependencies = { "stevearc/dressing.nvim", "nvim-telescope/telescope.nvim", },
}

addPlugin {
	"kyazdani42/nvim-web-devicons",
	config = function()
		require("nvim-web-devicons").setup({
			override = {
				["c++"]  = { color = "#F34B7D", cterm_color = "204", icon = "󰙲", name = "CPlusPlus" },
				cc       = { color = "#F34B7D", cterm_color = "204", icon = "󰙲", name = "CPlusPlus" },
				cp       = { color = "#F34B7D", cterm_color = "204", icon = "󰙲", name = "Cp"        },
				cpp      = { color = "#F34B7D", cterm_color = "204", icon = "󰙲", name = "Cpp"       },
				cs       = { color = "#C20DA6", cterm_color = "58",  icon = "󰌛", name = "Cs"        },
				csproj   = { color = "#854CC7", cterm_color = "98",  icon = "", name = "Csproj"    },
				csv      = { color = "#89E051", cterm_color = "113", icon = "", name = "Csv"       },
				md       = { color = "#42A5F5", cterm_color = "75",  icon = "", name = "Md"        },
				mdx      = { color = "#519ABA", cterm_color = "67",  icon = "󰽛", name = "Mdx"       },
				py       = { color = "#3D7BAB", cterm_color = "221", icon = "", name = "Py"        },
				todo     = { color = "#7CB342", cterm_color = "107", icon = "", name = "Todo"      },
			}
		})
		require("nvim-web-devicons").set_default_icon("", "#6d8086", 66)
	end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Indent     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"NMAC427/guess-indent.nvim",
	cmd = "GuessIndent",
	config = true
}

addPlugin {
	"lukas-reineke/indent-blankline.nvim",
	event = "CursorHold",
	main = "ibl",
	config = function(plugin, cfg)
		require(plugin.main).setup(cfg)
		local hooks = require "ibl.hooks"
		hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
	end,
	opts = {
		enabled = true,
		debounce = 500,
		viewport_buffer = {
			min = 30,
			max = 500,
		},
		indent = {
			char = "▏",
			tab_char = nil,
			highlight = "IblIndent",
			smart_indent_cap = true,
			priority = 1,
		},
		whitespace = {
			highlight = "IblWhitespace",
			remove_blankline_trail = true,
		},
		scope = {
			enabled = true,
			char = "▎",
			show_start = true,
			show_end = true,
			injected_languages = true,
			highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			},
			priority = 1024,
			include = {
				node_type = {
					["*"] = {
						"elif_clause",
						"else_clause",
						"for_statement",
						"if_statement",
						"while_statement",
					},
					["lua"] = {
						"elseif_statement",
						"else_statement",
						"table_constructor"
					}
				},
			},
			exclude = {
				language = {},
				node_type = {},
			},
		},
		exclude = {
			filetypes = {
				"lspinfo",
				"packer",
				"checkhealth",
				"help",
				"man",
				"gitcommit",
				"TelescopePrompt",
				"TelescopeResults",
				"",
			},
			buftypes = {
				"terminal",
				"nofile",
				"quickfix",
				"prompt",
			},
		},
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      LSP       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: dotnet
-- FEAT: https://github.com/anachary/dotnet-core.nvim
-- FEAT: https://github.com/anachary/dotnet-plugin.nvim
-- FEAT: csharp lsp: try https://github.com/dotnet/roslyn as roslyn_ls https://github.com/seblyng/roslyn.nvim
-- addPlugin {
-- 	"GustavEikaas/easy-dotnet.nvim",
-- 	dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
-- 	config = function()
-- 		require("easy-dotnet").setup()
-- 	end
-- }

-- FEAT: Use umdercurl in diagnostics

-- FEAT: powershell lsp
-- FEAT: https://github.com/hinell/lsp-timeout.nvim
-- FEAT: https://github.com/amadanmath/diag_ignore.nvim

-- none-ls
-- FEAT: https://github.com/nvimtools/none-ls.nvim -- create custom code actions
-- FEAT: https://github.com/Zeioth/none-ls-autoload.nvim
-- FEAT: https://github.com/Zeioth/none-ls-external-sources.nvim
-- FEAT: https://github.com/gwinn/none-ls-jsonlint.nvim

-- FEAT: https://github.com/p00f/clangd_extensions.nvim
-- FEAT: https://github.com/Davidyz/inlayhint-filler.nvim

addPlugin {
	-- FEAT: https://github.com/oribarilan/lensline.nvim
	-- FEAT: "Wansmer/symbol-usage.nvim",
	"VidocqH/lsp-lens.nvim",
	event = "LspAttach",
	opts = {
		enable = true,
		include_declaration = false, -- Reference include declaration
		hide_zero_counts = true, -- Hide lsp sections which have no content
		sections = {
			definition = function(count)
				if count == 1 then
					return ""
				end
				return "Definitions: " .. count
			end,
			references = function(count)
				return "References: " .. count
			end,
			implements = function(count)
				if count == 1 then
					return ""
				end
				return "Implements: " .. count
			end,
			git_authors = false --[[ function(latest_author, count)
				return "󰀄 " .. latest_author .. (count - 1 == 0 and "" or (" + " .. count - 1))
			end ]]
		},
		separator = " 󰧞 ",
		target_symbol_kinds = {
			vim.lsp.protocol.SymbolKind.Function,
			vim.lsp.protocol.SymbolKind.Method,
		},
		decorator = function(line)
			line = "󰧶 " .. line
			return line
		end,
		ignore_filetype = {}
	}
}

-- addPlugin {
-- 	"Zeioth/garbage-day.nvim",
-- 	event = "LspAttach",
-- 	opts = {
-- 		excluded_lsp_clients = {},
-- 		grace_period = 60, -- FIX: values
-- 		notifications = true,
-- 		wakeup_delay = 1000
-- 	}
-- }

addPlugin {
	-- FEAT: check options
	"aznhe21/actions-preview.nvim",
	dependencies = "nvim-telescope/telescope.nvim"
}

-- FIX: hover doc float border highliggt
-- FIX: hover doc checks from all LSP, disable for ruff
addPlugin {
	"glepnir/lspsaga.nvim",
	cmd = "Lspsaga",
	opts = {
		beacon = {
			enable = true,
			frequency = 7,
		},
		code_action = {
			extend_gitsigns = true,
			keys = {
				quit = "q",
				exec = "<CR>",
			},
			num_shortcut = true,
			show_server_name = true,
		},
		definition = {
			edit = "o",
			quit = "q",
			split = keymaps.open_vsplit,
			tabe = keymaps.open_tab,
			vsplit = keymaps.open_vsplit,
		},
		diagnostic = {
			custom_fix = nil,
			custom_msg = nil,
			extend_relatedInformation = true,
			jump_num_shortcut = false,
			keys = {
				exec_action = "<CR>",
				quit = "q",
				go_action = "g"
			},
			max_height = 0.5,
			max_width = 0.7,
			show_code_action = false,
			show_layout = "float",
			show_source = true,
			text_hl_follow = true,
		},
		finder = {
			default = "tyd+ref+imp+def",
			keys = {
				shuttle = "<TAB>",
				split = keymaps.open_split,
				tabe = keymaps.open_tab,
				toggle_or_open = "<CR>",
				vsplit = keymaps.open_vsplit
			},
			open = {
				"o",
				"<CR>",
			},
			quit = {
				"q",
				"<ESC>",
			},
			split = keymaps.open_split,
			tabe = keymaps.open_tab,
			vsplit = keymaps.open_vsplit,
		},
		implement = {
			enable = true,
			sign = true,
			virtual_text = true
		},
		lightbulb = {
			enable = false,
			enable_in_insert = true,
			sign = false,
			sign_priority = 40,
			virtual_text = true,
		},
		outline = {
			auto_preview = true,
			auto_refresh = true,
			detail = true,
			keys = {
				jump = "o",
				expand_collapse = "u",
				quit = "q",
			},
			win_position = "right",
			win_width = 30,
		},
		preview = {
			lines_above = 0,
			lines_below = 10,
		},
		rename = {
			confirm = "<CR>",
			in_select = true,
			keys = {
				quit = "<C-c>",
				exec = "<CR>",
			}
		},
		request_timeout = 2000,
		scroll_preview = {
			scroll_down = "<C-n>",
			scroll_up = "<C-p>",
		},
		symbol_in_winbar = {
			enable = false,
		},
		ui = {
			actionfix = " ",
			border = "rounded",
			code_action = icons.code_action,
			collapse = icons.fold_open,
			devicon = true,
			diagnostic = icons.diagnostic,
			expand = icons.fold_close,
			hover = icons.hover,
			incoming = icons.incoming,
			kind = {
				Array         = { icons.Array,         "BlinkCmpKindArray",        },
				Boolean       = { icons.Boolean,       "BlinkCmpKindBoolean",      },
				Class         = { icons.Class,         "BlinkCmpKindClass",        },
				Constant      = { icons.Constant,      "BlinkCmpKindConstant",     },
				Constructor   = { icons.Constructor,   "BlinkCmpKindConstructor",  },
				Enum          = { icons.Enum,          "BlinkCmpKindEnum",         },
				EnumMember    = { icons.EnumMember,    "BlinkCmpKindEnumMember",   },
				Event         = { icons.Event,         "BlinkCmpKindEvent",        },
				Field         = { icons.Field,         "BlinkCmpKindField",        },
				File          = { icons.File,          "BlinkCmpKindFile",         },
				Folder        = { icons.Folder,        "BlinkCmpKindFolder",       },
				Function      = { icons.Function,      "BlinkCmpKindFunction",     },
				Interface     = { icons.Interface,     "BlinkCmpKindInterface",    },
				Key           = { icons.Key,           "BlinkCmpKindKey",          },
				Macro         = { icons.Macro,         "BlinkCmpKindMacro",        },
				Method        = { icons.Method,        "BlinkCmpKindMethod",       },
				Module        = { icons.Module,        "BlinkCmpKindModule",       },
				Namespace     = { icons.Namespace,     "BlinkCmpKindNamespace",    },
				Null          = { icons.Null,          "BlinkCmpKindNull",         },
				Number        = { icons.Number,        "BlinkCmpKindNumber",       },
				Object        = { icons.Object,        "BlinkCmpKindObject",       },
				Operator      = { icons.Operator,      "BlinkCmpKindOperator",     },
				Package       = { icons.Package,       "BlinkCmpKindPackage",      },
				Parameter     = { icons.Parameter,     "BlinkCmpKindParameter",    },
				Property      = { icons.Property,      "BlinkCmpKindProperty",     },
				Snippet       = { icons.Snippet,       "BlinkCmpKindSnippet",      },
				StaticMethod  = { icons.StaticMethod,  "BlinkCmpKindStaticMethod", },
				String        = { icons.String,        "BlinkCmpKindString",       },
				Struct        = { icons.Struct,        "BlinkCmpKindStruct",       },
				Text          = { icons.Text,          "BlinkCmpKindText",         },
				TypeAlias     = { icons.TypeAlias,     "BlinkCmpKindTypeAlias",    },
				TypeParameter = { icons.TypeParameter, "BlinkCmpKindTypeParameter",},
				Unit          = { icons.Unit,          "BlinkCmpKindUnit",         },
				Value         = { icons.Value,         "BlinkCmpKindValue",        },
				Variable      = { icons.Variable,      "BlinkCmpKindVariable",     }
			},
			lines = { "╰", "⎬", "│", "─", "╭" },
			outgoing = icons.outgoing,
			preview = icons.preview,
			title  = true
		}
	}
}

addPlugin {
	"j-hui/fidget.nvim",
	opts = {
		progress = {
			display = {
				done_icon = " ",
				progress_icon = { pattern = "dots", period = 1 }
			}
		}
	},
	event = "LspAttach"
}

addPlugin {
	"kosayoda/nvim-lightbulb",
	event = "LspAttach",
	config = function()
		vim.api.nvim_set_hl(0, "LightBulbVirtualText", { fg = "#EEE600" })
		---@diagnostic disable-next-line: missing-fields
		require("nvim-lightbulb").setup({
			autocmd = { enabled = true },
			action_kinds = {
				"",
				"quickfix",
				"refactor",
				"refactor.extract",
				"refactor.inline",
				"refactor.rewrite",
				"source",
				-- "source.organizeImports",
				-- "source.fixAll"
			},
			sign = { enabled = false, },
			validate_config = "never",
			virtual_text = {
				enabled = true,
				text = "󰛨",
				hl = "LightBulbVirtualText",
			}
		})
	end
}

-- FEAT: addPlugin { "mfussenegger/nvim-lint" } -- have windows path issues
-- FEAT: https://github.com/netmute/ctags-lsp

addPlugin {
	"p00f/clangd_extensions.nvim",
	event = "LspAttach *.cpp"
}

-- FEAT: https://github.com/sontungexpt/better-diagnostic-virtual-text
addPlugin {
	"rachartier/tiny-inline-diagnostic.nvim",
	config = function()
		require("tiny-inline-diagnostic").setup({
			hi = {
				background = "None",
			},
			options = {
				show_source = true,
				use_icons_from_diagnostic = true,
				multilines = {
					enabled = true,
					always_show = true,
				},
				enable_on_insert = true,
				format = function(arg)
					if arg.code then return arg.message .. " [" .. arg.code .. "]" end
					return arg.message
				end,
				virt_texts = {
					priority = priority_virt.diagnostics
				}
			},
			signs = {
				left = "",
				right = "",
				diag = "●",
				arrow = "  ",
				up_arrow = "    ",
				vertical = " │",
				vertical_end = " ╰",
			},
			blend = {
				factor = 0.22,
			},
		})
		vim.diagnostic.config({ virtual_text = false })
	end,
	event = "Colorscheme",
	lazy = false
}

addPlugin {
	"williamboman/mason.nvim",
	cmd = "Mason",
	init = function()
		local path_sep = vim.fn.has("win64") and ";" or ":"
		vim.env.PATH = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin") .. path_sep .. vim.env.PATH
	end,
	opts = {
		install_root_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason"),
		PATH = "skip",
		ui = {
			border = "rounded",
			height = 0.8,
			width = 0.6,
		}
	}
}

addPlugin {
	"williamboman/mason-lspconfig.nvim",
	config = function()
		-- ╭────────────────────────╮
		-- │ LSP Running animations │
		-- ╰────────────────────────╯
		Lsp_anim = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		Lsp_icon = ""
		Lsp_icon_index = 0

		---@diagnostic disable-next-line: undefined-field
		vim.uv.timer_start(vim.uv.new_timer(), 700, 700, function()
			Lsp_icon_index = (Lsp_icon_index) % #Lsp_anim + 1
			Lsp_icon = Lsp_anim[Lsp_icon_index]
		end)

		-- TODO:
		-- Lsp_timer = {
		-- 	---@diagnostic disable-next-line: undefined-field
		-- 	timer = vim.uv.new_timer(),
		-- 	auto_stopped = false
		-- }

		-- vim.api.nvim_create_autocmd(
		-- 	"FocusLost", {
		-- 		pattern = "*",
		-- 		desc = "Stop LSP on focus lost",
		-- 		once = false,
		-- 		callback = function()
		-- 			vim.api.nvim_create_autocmd(
		-- 				"FocusGained", {
		-- 					pattern = "*",
		-- 					desc = "Start LSP on focus gained",
		-- 					once = true,
		-- 					callback = function()
		-- 						Lsp_timer.timer:stop()
		-- 						-- reattach LSP
		-- 						Lsp_timer.timer:start(10000, 0, vim.schedule_wrap(function()
		-- 							if Lsp_timer.auto_stopped and true or not isLspAttached() then
		-- 								vim.notify("LSP resumed")
		-- 								vim.cmd.LspStart()
		-- 							end
		-- 						end))
		-- 					end
		-- 				}
		-- 			)
		-- 			Lsp_timer.timer:stop()
		-- 			-- stop LSP
		-- 			Lsp_timer.timer:start(60000, 0, vim.schedule_wrap(function()
		-- 				if isLspAttached() then
		-- 					vim.notify("LSP hibernated")
		-- 					vim.cmd.LspStop()
		-- 					Lsp_timer.auto_stopped = true
		-- 				end
		-- 			end))
		-- 		end
		-- 	}
		-- )

		-- vim.api.nvim_create_autocmd("LspDetach", {
		-- 	callback = function(args)
		-- 		local client_id = args.data.client_id
		-- 		local client = vim.lsp.get_client_by_id(client_id)
		-- 		local current_buf = args.buf

		-- 		if client then
		-- 			local clients = vim.lsp.get_clients({ id = client_id })
		-- 			local count = 0

		-- 			if clients and #clients > 0 then
		-- 				local remaining_client = clients[1]

		-- 				if remaining_client.attached_buffers then
		-- 					for buf_id in pairs(remaining_client.attached_buffers) do
		-- 						if buf_id ~= current_buf then
		-- 							count = count + 1
		-- 						end
		-- 					end
		-- 				end
		-- 			end

		-- 			if count == 0 then
		-- 				client:stop()
		-- 			end
		-- 		end
		-- 	end
		-- })

		popupMenuAdd({
			cond = isLspAttached,
			options = {
				{ name = " Code Action", key = "<C-.>", exec = require("actions-preview").code_actions },
				{ name = " Declaration", key = "gD", exec = vim.lsp.buf.declaration },
				{ name = " Definition", key = "F12", exec = vim.lsp.buf.definition },
				{ name = " Hover", key = "\\h", exec = function() vim.cmd("Lspsaga hover_doc") end },
				{ name = " Implementation", key = "gi", exec = vim.lsp.buf.implementation },
				{ name = "󱦞 LSP Finder", key = "Alt F12", exec = function() vim.cmd("Lspsaga lsp_finder") end },
				{ name = " Peek Definition", key = "gp", exec = function() vim.cmd("Lspsaga peek_definition") end },
				{ name = " References", key = "Shift F12", exec = vim.lsp.buf.references },
				{ name = "󰏫 Rename", key = "F2", exec = function() vim.cmd("Lspsaga rename") end },
				{ name = " Type Definition", key = "gt", exec = vim.lsp.buf.type_definition }
			}
		})

		require("mason-lspconfig").setup()

		-- enable inlay hints
		vim.lsp.inlay_hint.enable(true)

		-- Mappings.
		local bufopts = { noremap = true, silent = true }
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
		vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
		vim.keymap.set("n", "<M-F12>", "<cmd>Lspsaga finder<CR>", bufopts)
		vim.keymap.set("n", "<S-F12>", vim.lsp.buf.references, bufopts)
		vim.keymap.set("n", "<Leader>h", "<cmd>Lspsaga hover_doc<CR>", bufopts)
		vim.keymap.set("n", "<C-.>", require("actions-preview").code_actions, bufopts)
		vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts) -- FEAT: how to select the code action displayed
		vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", bufopts)
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)

		vim.lsp.config["*"] = {
			capabilities = require("blink.cmp").get_lsp_capabilities()
		}

		vim.lsp.config.basedpyright = {
			settings = {
				basedpyright = {
					analysis = {
						diagnosticMode = "workspace",
					},
				},
			},
		}

		vim.lsp.config.lua_ls = {
			settings = {
				Lua = {
					codeLens = {
						enable = true
					},
					completion = {
						callsnippet = "Both",
						keywordSnippet = "Both"
					},
					diagnostics = {
						globals = { "bit", "vim" }
					},
					hint = {
						arrayIndex = "Enable",
						enable = true,
						setType = true
					}
				}
			}
		}

	end,
	dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
	keys = "<F12>"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Markdown    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/hedyhli/markdown-toc.nvim
-- FEAT: https://github.com/idossha/LiveMD.nvim
-- FEAT: https://github.com/jeangiraldoo/markup.nvim
-- FEAT: https://github.com/jghauser/follow-md-links.nvim
-- FEAT: https://github.com/magnusriga/markdown-tools.nvim
-- FEAT: https://github.com/richardbizik/nvim-toc
-- FEAT: https://github.com/tadmccorkle/markdown.nvim
-- FEAT: https://github.com/topazape/md-preview.nvim
-- FEAT: https://github.com/erel213/markdown-writer.nvim
-- FEAT: https://github.com/YousefHadder/markdown-plus.nvim
-- "OXY2DEV/markview.nvim"
-- TODO: revisit config
addPlugin {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",
	opts = {
		latex = {
			enabled = false,
		},
		anti_conceal = {
			enabled = false
		},
		heading = {
			enabled = true,
			sign = false,
			position = "inlay",
			-- icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " }, -- FEAT: use sequence of blocks
			icons = { "󰫎 " },
			signs = { "󰫎 " },
			width = { "full", "block", "block"},
			left_margin = 0,
			left_pad = 0,
			right_pad = 2,
			min_width = 0,
			border = false,
			border_virtual = false,
			border_prefix = false,
		},
		code = {
			enabled = true,
			render_modes = { "n", "v", "V" },
			sign = false,
			style = "full",
			position = "left",
			language_pad = 0,
			disable_background = { "" },
			width = "block",
			left_margin = 0,
			left_pad = 0,
			right_pad = 1,
			min_width = 10,
			border = "thick",
			language_name = true,
			inline_pad = 1
		},
		bullet = {
			enabled = true,
			icons = { "", "", "󰨐", "" },
		},
		checkbox = {
			enabled = true,
			position = "overlay",
			unchecked = {
				icon = "    ", -- FEAT: better icons
			},
			checked = {
				icon = "    ",
				scope_highlight = "RenderMarkdownChecked"
			},
			custom = {
				working = {
					raw = "[-]",
					rendered = "    ",
					highlight = "RenderMarkdownTodo",
					scope_highlight = "RenderMarkdownTodo",
				}
			}
		},
		quote = {
			enabled = true,
			icon = "▍",
			repeat_linebreak = true,
		},
		pipe_table = { -- FEAT: experiment on table format
			enabled = true,
			border = {
				"┌", "┬", "┐",
				"├", "┼", "┤",
				"└", "┴", "┘",
				"│", "─",
			},
			preset = "round",
			style = "normal",
			cell = "trimmed",
			min_width = 0,
			alignment_indicator = "•",
		},
		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
			caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
		},
		link = {
			enabled = true,
			image = "󰥶 ",
			email = "󰀓 ",
			hyperlink = "󰌹 ",
			custom = {
				akams = { pattern = "https://aka.ms", icon = "󰇩 " },
				azuredevops = { pattern = "[%a]+%.visualstudio%.com", icon = " " },
				discord = { pattern = "discord%.com", icon = "󰙯 " },
				github = { pattern = "github%.com", icon = "󰊤 " },
				microsoft = { pattern = "microsoft%.com", icon = "󰇩 " },
				neovim = { pattern = "neovim%.io", icon = " " },
				reddit = { pattern = "reddit%.com", icon = "󰑍 " },
				stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
				web = { pattern = "^http[s]?://", icon = "󰖟 " },
				youtube = { pattern = "youtube%.com", icon = "󰗃 " }
			},
		},
		sign = {
			enabled = false,
		},
		win_options = {
			concealcursor = {
				default = vim.api.nvim_get_option_value("concealcursor", {}),
				rendered = vim.api.nvim_get_option_value("concealcursor", {})
			}
		}
	}
}

addPlugin {
	"OXY2DEV/helpview.nvim",
	ft = "help"
}

addPlugin {
	"bngarren/checkmate.nvim", -- FIX: overrites highlight for inline ``
	ft = "markdown",
	opts = {
		files = {
			"todo",
			"TODO",
			"*.todo",
			"*.md",
		},
		keys = {
			["<TAB>"] = {
				rhs = "<cmd>Checkmate toggle<CR>",
				desc = "Toggle todo item",
				modes = { "n", "v" }
			},
			["<leader>TR"] = {
				rhs = "<cmd>Checkmate remove_all_metadata<CR>",
				desc = "Remove all metadata from a todo item",
				modes = { "n", "v" },
			},
			["<leader>Ta"] = {
				rhs = "<cmd>Checkmate archive<CR>",
				desc = "Archive checked/completed todo items (move to bottom section)",
				modes = { "n" },
			},
			["<leader>Tv"] = {
				rhs = "<cmd>Checkmate metadata select_value<CR>",
				desc = "Update the value of a metadata tag under the cursor",
				modes = { "n" },
			}
		},
		todo_action_depth = 10,
		todo_count_formatter = function(completed, total)
			return string.format("%d/%d (%.0f%%)", completed, total, completed / total * 100)
		end,
		todo_markers = {
			unchecked = "[ ]",
			checked = "[x]",
		},
		linter = {
			enabled = true,
		}
	}
}

addPlugin {
	"gaoDean/autolist.nvim",
	ft = "markdown",
	config = function(_, cfg)
		require("autolist").setup(cfg)
		vim.keymap.set("i", "<S-CR>", "<CR><Cmd>AutolistNewBullet<CR>")
		vim.keymap.set("n", "<<", "<<<Cmd>AutolistRecalculate<CR>")
		vim.keymap.set("n", ">>", ">><Cmd>AutolistRecalculate<CR>")
		vim.keymap.set("n", "O", "O<Cmd>AutolistNewBulletBefore<CR>")
		vim.keymap.set("n", "dd", "dd<Cmd>AutolistRecalculate<CR>")
		vim.keymap.set("n", "o", "o<Cmd>AutolistNewBullet<CR>")
	end,
	opts = {
		lists = {
			markdown = {
				"[-+*]", -- - + *
				"%d+[.)]", -- 1. 2. 3.
				"%a[.)]", -- a) b) c)
				"%u*[.)]", -- I. II. III.
				"> " -- blockqoutes marker
			}
		}
	}
}

addPlugin {
	-- "iamcco/markdown-preview.nvim"
	"toppair/peek.nvim",
	build = "deno task --quiet build:fast",
	cmd = "PeekOpen",
	config = function()
		require("peek").setup({
			app = "webview",
			theme = vim.o.background
		})
		vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
		vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
	end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Marks      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Guide:
-- https://vim.fandom.com/wiki/Using_marks
-- |----------------+---------------------------------------------------------------|
-- | Command        | Description                                                   |
-- |----------------+---------------------------------------------------------------|
-- | ""             | jump back (to line in current buffer where jumped from)       |
-- | "a             | jump to line of mark a (first non-blank character in line)    |
-- | :delmarks a    | delete mark a                                                 |
-- | :delmarks a-d  | delete marks a, b, c, d                                       |
-- | :delmarks aA   | delete marks a, A                                             |
-- | :delmarks abxy | delete marks a, b, x, y                                       |
-- | :delmarks!     | delete all lowercase marks for the current buffer (a-z)       |
-- | :marks         | list all the current marks                                    |
-- | :marks aB      | list marks a, B                                               |
-- | ["             | jump to previous line with a lowercase mark                   |
-- | [`             | jump to previous lowercase mark                               |
-- | ]"             | jump to next line with a lowercase mark                       |
-- | ]`             | jump to next lowercase mark                                   |
-- | `"             | jump to position where last exited current buffer             |
-- | `.             | jump to position where last change occurred in current buffer |
-- | `0             | jump to position in last file edited (when exited Vim)        |
-- | `1             | like `0 but the previous file (also `2 etc)                   |
-- | `< or `>       | jump to beginning/end of last visual selection                |
-- | `[ or `]       | jump to beginning/end of previously changed or yanked text    |
-- | ``             | jump back (to position in current buffer where jumped from)   |
-- | `a             | jump to position (line and column) of mark a                  |
-- | c"a            | change text from current line to line of mark a               |
-- | d"a            | delete from current line to line of mark a                    |
-- | d`a            | delete from current cursor position to position of mark a     |
-- | ma             | set mark a at current cursor location                         |
-- | y`a            | yank text to unnamed buffer from cursor to position of mark a |
-- |----------------+---------------------------------------------------------------|
-- https://github.com/LintaoAmons/bookmarks.nvim
-- FEAT: see annotations as diagnistic texts
addPlugin {
	"MattesGroeger/vim-bookmarks",
	config = function()
		vim.g.bookmark_annotation_sign = icons.bookmark_annotate
		vim.g.bookmark_display_annotation = 1
		vim.g.bookmark_highlight_lines = 1
		vim.g.bookmark_location_list = 1
		vim.g.bookmark_no_default_key_mappings = 1
		vim.g.bookmark_save_per_working_dir = 0
		vim.g.bookmark_sign = icons.bookmark
	end,
	dependencies = "luukvbaal/statuscol.nvim",
	keys = {
		{ "ba", "<Plug>BookmarkAnnotate" },
		{ "bm", "<Plug>BookmarkToggle" },
		{ "bn", "<Plug>BookmarkNext" },
		{ "bp", "<Plug>BookmarkPrev" },
		{ "bs", "<Plug>BookmarkShowAll" }
	}
}

-- FEAT: configure addPlugin {
-- 	"chentoast/marks.nvim"
-- }

addPlugin {
	"kshenoy/vim-signature",
	config = function()
		vim.g.SignatureIncludeMarks = "abcdefghijklmnopqrstuvwxABCDEFGHIJKLMNOPQRSTUVWXYZ"
	end,
	lazy = false
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Popup Menu   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: improve it
addPlugin {
	"nvzone/menu",
	init = function()
		vim.cmd("aunmenu PopUp") -- Clear popup menu
	end,
	dependencies = "nvzone/volt"
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Outline     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"stevearc/aerial.nvim",
	cmd = { "AerialNavToggle", "AerialToggle" },
	opts = {
		attach_mode = "global",
		autojump = false,
		backends = { "treesitter", "lsp", "markdown", "man" },
		disable_max_lines = 10000,
		disable_max_size = 2000000, -- Default 2MB
		filter_kind = { "Class", "Constructor", "Enum", "Function", "Interface", "Module", "Method", "Struct" },
		guides = { mid_item = "├ ", last_item = "╰ ", nested_top = "│ ", whitespace = " ", },
		highlight_on_hover = true,
		icons = icons,
		nav = {
			keymaps = {
				["<Left>"] = "actions.left",
				["<Right>"] = "actions.right",
				[""] = "actions.close",
			},
			min_height = { 20, 0.2 },
			preview = true,
		},
		nerd_font = false,
		placement = "edge",
		show_guides = true,
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Quickfix    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
--[[ Guide
|-----------------+-----------------------------------------------------------|
| Command         | Explanation                                               |
|-----------------+-----------------------------------------------------------|
| Cfilter[!] patt | Filter quickfix for patt, with ! filter for unmatched     |
| [c]cn           | jump to next quickfix, with [c] jump to next [c]          |
| [c]cp           | jump to previous quickfix, with [c] jump to previous [c]  |
| cb              | read error list from current buffer                       |
| cc [n]          | jump to n quickfix, if n is omitted jump to current again |
| cdo cmd         | execute cmd on each quickfix                              |
| cf file         | read error from file into quickfix                        |
| chi             | Show list of quickfix window history                      |
| cnew [c]        | Go to next quickfix windows, c for count                  |
| col [c]         | Go to previous quickfix windows, c for count              |
|-----------------+-----------------------------------------------------------|
]]
addPlugin {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {
		restore = false,
		keys = {
			[keymaps.open_split] = "jump_split",
			[keymaps.open_vsplit] = "jump_vsplit",
			j = "next",
			k = "prev"
		}
	}
}

--[[ Guide
|-------------+----------------------------------------------------------+---------|
| Function    | Action                                                   | Def Key |
|-------------+----------------------------------------------------------+---------|
| drop        | use drop to open the item, and close quickfix window     | O       |
| filter      | create new list for signed items                         | zn      |
| filterr     | create new list for non-signed items                     | zN      |
| fzffilter   | enter fzf mode                                           | zf      |
| lastleave   | go to last leaving position in quickfix window           | ""      |
| nextfile    | go to next file under the cursor in quickfix window      | <C-n>   |
| nexthist    | go to next quickfix list in quickfix window              | >       |
| open        | open the item under the cursor in quickfix window        | <CR>    |
| openc       | open the item, and close quickfix window                 | o       |
| prevfile    | go to previous file under the cursor in quickfix window  | <C-p>   |
| prevhist    | go to previous quickfix list in quickfix window          | <       |
| pscrolldown | scroll down half-page in preview window                  | <C-f>   |
| pscrollorig | scroll back to original position in preview window       | zo      |
| pscrollup   | scroll up half-page in preview window                    | <C-b>   |
| ptoggleauto | toggle auto preview when cursor moved                    | P       |
| ptoggleitem | toggle preview for an item of quickfix list              | p       |
| ptogglemode | toggle preview window between normal and max size        | zp      |
| sclear      | clear the signs in current quickfix list                 | z<Tab>  |
| split       | open the item in vertical split                          | <C-s>   |
| stogglebuf  | toggle signs for same buffers under the cursor           | "<Tab>  |
| stoggledown | toggle sign and move cursor down                         | <Tab>   |
| stoggleup   | toggle sign and move cursor up                           | <S-Tab> |
| stogglevm   | toggle multiple signs in visual mode                     | <Tab>   |
| tab         | open the item in a new tab                               | t       |
| tabb        | open the item in a new tab, but stay at quickfix window  | T       |
| tabc        | open the item in a new tab, and close quickfix window    | <C-t>   |
| tabdrop     | use tab drop to open the item, and close quickfix window |         |
| vsplit      | open the item in horizontal split                        | <C-v>   |
|-------------+----------------------------------------------------------+---------|
]]
addPlugin {
	"kevinhwang91/nvim-bqf",
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("bqf").setup {
			auto_resize_height = true,
			func_map = {
				open = "<CR>",
				split = keymaps.open_split,
				tabb = keymaps.open_tab,
				vsplit = keymaps.open_vsplit
			},
			preview = {
				border = dotted_border,
			}
		}
		vim.cmd("packadd cfilter")
	end,
	dependencies = "junegunn/fzf",
	ft = "qf"
}

addPlugin {
	"stefandtw/quickfix-reflector.vim"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Sessions    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/niba/continue.nvim
-- FEAT: https://github.com/nvim-mini/mini.sessions
addPlugin {
	"rmagatti/auto-session",
	cmd = "SessionSave",
	config = function()
		require("auto-session").setup({
			post_delete_cmds = {
				"let g:auto_session_enabled = v:false",
				"let g:session_icon = ''"
			},
			post_restore_cmds = {
				"let g:session_icon = '󰅠'"
			},
			post_save_cmds = {
				"let g:session_icon = '󰅠'"
			},
			suppressed_dirs = { "C:\\Users\\aloknigam", "~" }
		})
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,localoptions,tabpages,winsize,winpos,terminal"
	end,
	init = function()
		if vim.fn.filereadable(vim.fn.stdpath("data") .. "\\sessions\\" .. vim.fn.getcwd():gsub("\\", "%%5C"):gsub(":", "%%3A") .. ".vim") == 1 then
			require("auto-session")
		end
	end
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Status Column  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
---Default method to use until statuscol.nvim loads which then overrides it
---@return string
function StatusCol()
	return "%=%l%C "
end
vim.o.statuscolumn = "%!v:lua.StatusCol()"

-- BUG: does not load if marks are created before loading plugin
addPlugin {
	"luukvbaal/statuscol.nvim",
	config = function()
		local builtin = require("statuscol.builtin")
		require("statuscol").setup({
			setopt = true,
			relculright = true,
			segments = {
				{ sign = { name = { "todo" }, auto = true, foldclosed = true }, condition = { function() return TODO_COMMENTS_LOADED ~= nil end } },
				{ sign = { name = { "Signature_" }, auto = true, fillcharhl ="LineNr" } },
				{ sign = { namespace = { ".*diagnostic.*" }, auto = true, colwidth = 2, fillcharhl ="LineNr", maxwidth = 1, foldclosed = true }, click = "v:lua.ScSa" },
				{ sign = { name = { "Bookmark" }, auto = true, fillcharhl ="LineNr" } },
				{ sign = { name = { "Dap" }, auto = true, fillcharhl ="LineNr" } },
				{ text = { builtin.foldfunc }--[[ , click = "v:lua.ScFa" ]] },
				{ text = { builtin.lnumfunc }, --[[ click = "v:lua.ScLa", ]] condition = { true } },
				{ sign = { name = { "coverage" }, colwidth = 1, fillcharhl ="LineNr", auto = true } },
				{
					sign = {
						text = {
							icons.diff_add,
							icons.diff_change,
							icons.diff_delete,
							icons.diff_delete_top,
							icons.diff_change_delete,
							icons.diff_untracked
						},
						colwidth = 1,
						fillcharhl = "LineNr",
						wrap = true
					},
					click = "v:lua.ScSa",
				}
			}
		})
	end,
	event = "DiagnosticChanged"
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Status Line   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"b0o/incline.nvim",
	config = function()
		require("incline").setup({
			ignore = {
				unlisted_buffers = false,
				buftypes = {},
				filetypes = { "NvimTree" },
				wintypes = {}
			},
			render = function(props)
				if CountWindows(true) > 1 then
					local full_filename = vim.api.nvim_buf_get_name(props.buf)
					local filename = vim.fn.fnamemodify(full_filename, ":t")
					local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)

					local git_signs = require("lualine.components.diff.git_diff").get_sign_count(props.buf)
					local labels = {}

					if filename == "" then
						filename = "[Scratch]"
					end

					if git_signs then
						if git_signs["added"] > 0 or git_signs["modified"] > 0 or git_signs["removed"] > 0 then
							labels = { " 󰦓", guifg = "#85C581" }
						end
					end

					return {
						{ ft_icon, " ", guifg = ft_color },
						full_filename:find("^gitsigns:") and "gitsigns:" .. filename or filename,
						vim.bo[props.buf].modified and " " .. icons.file_modified or "",
						labels,
						isLspAttached(props.buf) and { " " .. icons.lsp, guifg = "#EAC435" } or "",
						#vim.diagnostic.get(props.buf, { severity = { min = vim.diagnostic.severity.HINT }}) > 0 and { " ", guifg = "#EE4266" } or ""
					}
				end
				return nil
			end,
			window = {
				margin = {
					vertical = 0
				},
				placement = {
					vertical = "bottom"
				}
			}
		})
	end,
	event = "CursorHold",
}

addPlugin {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" }, -- ⏽ 
				section_separators = { left = "", right = "" },
				ignore_focus = { "NvimTree" },
				always_divide_middle = false,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				}
			},
			sections = {
				lualine_a = {
					{
						"mode",
						color = { gui = "bold" },
						fmt = function(str)
							local first = str:sub(1,1)
							if first == "N" then
								return ""
							elseif first == "V" then
								return ""
							elseif first == "I" then
								return ""
							elseif first == "C" then
								return ""
							end
							return str:sub(1,1)
						end,
						padding = { left = 0, right = 1 },
						separator = { left = "█", right = "" }
					}
				},
				lualine_b = {
					{
						"filetype",
						icon_only = true,
						fmt = function(str)
							if str == "" then
								return " "
							end
							return str
						end,
						padding = { left = 1, right = 0 },
						separator = ""
					},
					{
						"filename",
						color = { gui = "italic" },
						file_status = true,
						newfile_status = true,
						on_click = function()
							vim.cmd("NvimTreeOpen")
						end,
						path = 0,
						padding = { left = 0, right = 0 },
						shorting_target = 40,
						symbols = {
							modified = icons.file_modified,
							readonly = icons.file_readonly,
							unnamed  = " " .. icons.file_unnamed .. " ",
							newfile  = " " .. icons.file_newfile .. " "
						}
					}
				},
				lualine_c = {
					{
						"branch",
						color = { gui = "bold" },
						icon = { "", color = { fg = "#F14C28" }},
						on_click = function()
							vim.cmd("Telescope git_branches")
						end,
						padding = { left = 1, right = 0 },
					},
					{
						"diff",
						on_click = function()
							vim.cmd("Telescope git_status")
						end,
						padding = { left = 1, right = 0 },
						symbols = {
							added = icons.git_added,
							modified = icons.git_modified,
							removed = icons.git_removed
						}
					}
				},
				lualine_x = {
					{
						function() return vim.g.formatting or "" end,
						color = "Boolean",
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						"searchcount",
						color = { fg = "#23CE6B", gui = "bold" },
						fmt = function(str)
							return string.sub(str, 2, -2)
						end,
						icon = {"󰱽", color = { fg = "#EAC435" }},
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						function() return "󰳾" end,
						color = { fg = "#009DDC" },
						cond = function()
							return vim.b.VM_Selection ~= nil and not vim.tbl_isempty(vim.b.VM_Selection)
						end
					},
					{
						"selectioncount",
						color = { fg = "#BA2C73" },
						icon = { "󰴑", color = { fg = "#963484" }},
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						"diagnostics",
						on_click = function()
							vim.cmd("Trouble diagnostics")
						end,
						padding = { left = 0, right = 1 },
						sources = { "nvim_diagnostic" },
						symbols = {
							error = icons.error,
							warn  = icons.warn,
							info  = icons.info,
							hint  = icons.hint
						},
					},
					{
						"hostname",
						color = { fg = "#119DA4", gui = "bold" },
						cond = function()
							return vim.env.SSH_CLIENT ~= nil
						end,
						fmt = function(str)
							local alias = {
								["ALOKNIGAM-IDC"] = "devbox"
							}
							return alias[str] or str
						end,
						icon = { "", color = { fg = "#3066BE" }},
						padding = { left = 0, right = 1 }
					},
					{
						"filesize",
						color = { fg = "#B90E0A", gui = "bold" },
						cond = isLargeFile,
						fmt = function(str)
							return "[" .. str .. "]"
						end,
						padding = { left = 0, right = 1 }
					},
					{
						"encoding",
						color = { fg = GetFgOrFallback("String", "#C2F261"), gui ="italic" },
						fmt = function(str)
							if vim.o.bomb then
								str = str .. "-bom"
							end
							return string.gsub(str, "utf.", "u")
						end,
						padding = { left = 0, right = 1 }
					}
				},
				lualine_y = {
					{
						function() return "󰑊" end,
						color = { fg = "#B43757" },
						cond = function() return vim.fn.reg_recording() ~= "" end,
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						function() return vim.g.session_icon or "" end,
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						function() return Lsp_icon end,
						cond = isLspAttached,
						on_click = function()
							vim.cmd("LspInfo")
						end,
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						function()
							if isTsAttached() then
								return "󰐅"
							end
							return ""
						end,
						color = { fg = "#097969" },
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						function()
							if vim.o.wrap then
								return "󰖶"
							else
								return "󰯟"
							end
						end,
						color = { fg = "#A35CFF" },
						on_click = function()
							vim.cmd("set wrap!")
						end,
						padding = { left = 0, right = 1 },
						separator = ""
					},
					{
						"fileformat",
						color = { fg = "#0096FF" },
						padding = { left = 0, right = 1 },
					},
				},
				lualine_z = {
					{
						"location",
						fmt = function(str)
							return str:gsub("^%s+", ""):gsub("%s+", "")
						end,
						on_click = function ()
							vim.cmd("ScrollViewToggle")
						end,
						padding = { left = 0, right = 0 },
						separator = { left = "", right = "█" }
					}
				}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {"filename"},
				lualine_x = {"location"},
				lualine_y = {},
				lualine_z = {}
			},
			-- winbar = {
				-- 	lualine_a = {
					-- 		{
						-- 			"filetype",
						-- 			cond = function() return not DropbarEnabled and CountWindows(true) > 1 end,
						-- 			icon_only = true,
						-- 			padding = { left = 1, right = 0 },
						-- 			separator = ""
						-- 		},
						-- 		{
							-- 			"filename",
							-- 			color = { gui = "italic" },
							-- 			cond = function() return not DropbarEnabled and CountWindows(true) > 1 end,
							-- 			file_status = true,
							-- 			newfile_status = true,
							-- 			path = 0,
							-- 			shorting_target = 40,
							-- 			symbols = {
								-- 				modified = icons.file_modified,
								-- 				readonly = icons.file_readonly,
								-- 				unnamed  = icons.file_unnamed,
								-- 				newfile  = icons.file_newfile,
								-- 			}
								-- 		},
								-- 		{
									-- 			function()
										-- 				if DropbarEnabled then
										-- 					return "%{%v:lua.dropbar.get_dropbar_str()%}"
										-- 				else
										-- 					return ""
										-- 				end
										-- 			end,
										-- 			padding = { left = 0, right = 0 },
										-- 			separator = { left = "", right = "" }
										-- 		},
										-- 	}
										-- },
										-- inactive_winbar = {
											-- 	lualine_a = {
												-- 		{
													-- 			"filetype",
													-- 			cond = function () return CountWindows(true) > 1 end,
													-- 			icon_only = true,
													-- 			padding = { left = 1, right = 0 },
													-- 			separator = ""
													-- 		},
													-- 		{
														-- 			"filename",
														-- 			color = { gui = "italic" },
														-- 			cond = function () return CountWindows(true) > 1 end,
														-- 			file_status = true,
														-- 			newfile_status = true,
														-- 			path = 3,
														-- 			shorting_target = 40,
														-- 			symbols = {
															-- 				modified = icons.file_modified,
															-- 				readonly = icons.file_readonly,
															-- 				unnamed  = icons.file_unnamed,
															-- 				newfile  = icons.file_newfile,
															-- 			}
															-- 		}
															-- 	},
															-- 	lualine_c = {
																-- 		{
																	-- 			"diff",
																	-- 			cond = function () return CountWindows(true) > 1 end,
																	-- 			padding = { left = 1, right = 0 },
																	-- 			symbols = {
																		-- 				added = "+",
																		-- 				modified = "~",
																		-- 				removed = "-"
																		-- 			}
																		-- 		},
																		-- 	},
																		-- 	lualine_z = {
																			-- 		{
																				-- 			function return Lsp_icon end,
																				-- 			cond = function () return CountWindows(true) > 1 and isLspAttached() end,
																				-- 			on_click = function()
																					-- 				vim.cmd("LspInfo")
																					-- 			end,
																					-- 			padding = { left = 0, right = 1 },
																					-- 			separator = ""
																					-- 		},
																					-- 		{
																						-- 			"diagnostics",
																						-- 			cond = function () return CountWindows(true) > 1 end,
																						-- 			on_click = function()
																							-- 				vim.cmd("TroubleToggle")
																							-- 			end,
																							-- 			padding = { left = 1, right = 1 },
																							-- 			sources = { "nvim_diagnostic" },
																							-- 			symbols = {
																								-- 				error = icons.error,
																								-- 				warn  = icons.warn,
																								-- 				info  = icons.info,
																								-- 				hint  = icons.hint
																								-- 			}
																								-- 		}
																								-- 	}
																								-- },
																								extensions = {
																									"aerial",
																									"lazy",
																									"mason",
																									"nvim-dap-ui",
																									"nvim-tree",
																									"quickfix",
																									"toggleterm",
																									"trouble"
																								}
																							})
																						end,
	event = "VeryLazy"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Tab Line    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/romgrk/barbar.nvim
addPlugin {
	"akinsho/bufferline.nvim",
	event = "TabNew",
	opts = {
		options = {
			always_show_bufferline = false,
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(_, _, diagnostics_dict, context)
				if context.buffer:current() then
					return ""
				end
				local res = ""
				for k, v in pairs(diagnostics_dict) do
					res = res .. icons[k] .. v .. " "
				end
				return res
			end,
			get_element_icon = function(element)
				local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
				if element.filetype == "netrw" then
					icon = ""
				elseif element.path == "[No Name]" then
					icon = icons.file_newfile
				end
				return icon, hl
			end,
			hover = {
				enabled = true,
				delay = 200,
				reveal = {"close"}
			},
			indicator = {
				style = "underline"
			},
			middle_mouse_command = "tabclose %d",
			mode = "tabs",
			name_formatter = function (buf)
				if buf.name == "[No Name]" then
					return ""
				end
				return buf.name
			end,
			offsets = {
					{
							filetype = "NvimTree",
							text = "File Explorer",
							highlight = "Directory",
							separator = false
					}
			},
			right_mouse_command = nil,
			separator_style = "thick"
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Telescope   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/BlankTiger/telescope-rg.nvim
-- FEAT: https://github.com/Marskey/telescope-sg
-- FEAT: https://github.com/SGauvin/ctest-telescope.nvim
-- FEAT: https://github.com/benfowler/telescope-luasnip.nvim
-- FEAT: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
-- FEAT: https://github.com/nvim-telescope/telescope-frecency.nvim
-- FEAT: https://github.com/nvim-telescope/telescope-live-grep-args.nvim
-- FEAT: https://github.com/ray-x/telescope-ast-grep.nvim
addPlugin {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	config = function()
		local actions = require("telescope.actions")
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				dynamic_preview_title = true,
				entry_prefix = "   ",
				file_ignore_patterns = {},
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				initial_mode = "insert",
				multi_icon = " ",
				prompt_prefix = "  ",
				selection_caret = "  ",
				timeout = 2000,
				windblend = 0,
				mappings = {
					i = {
						["<C-a>"]      = actions.toggle_all,
						["<C-d>"]      = false,
						["<C-l>"]      = actions.send_selected_to_qflist,
						["<C-u>"]      = false,
						["<M-l>"]      = actions.add_selected_to_qflist,
						["<PageDown>"] = actions.preview_scrolling_down,
						["<PageUp>"]   = actions.preview_scrolling_up,
						["<S-Tab>"]    = false,
						["<Tab>"]      = actions.toggle_selection,
						[keymaps.open_split]  = actions.select_horizontal,
						[keymaps.open_tab]    = actions.select_tab,
						[keymaps.open_vsplit] = actions.select_vertical
					},
					n = {
						["<C-a>"]      = actions.toggle_all,
						["<C-d>"]      = false,
						["<C-q>"]      = actions.send_selected_to_qflist,
						["<C-u>"]      = false,
						["<M-q>"]      = actions.add_selected_to_qflist,
						["<PageDown>"] = actions.preview_scrolling_down,
						["<PageUp>"]   = actions.preview_scrolling_up,
						["<S-Tab>"]    = false,
						["<Tab>"]      = actions.toggle_selection,
						[keymaps.open_split]  = actions.select_horizontal,
						[keymaps.open_tab]    = actions.select_tab,
						[keymaps.open_vsplit] = actions.select_vertical
					}
				},
			},
			extensions = {
				heading = {
					treesitter = true
				},
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				undo = {
					side_by_side = true
				}
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("undo")

		vim.api.nvim_create_autocmd(
			"User", {
				pattern = "TelescopePreviewerLoaded",
				desc = "Open directory in nvim-tree",
				command = "setlocal nu"
			}
		)
	end,
	dependencies = {
		"debugloop/telescope-undo.nvim", -- FEAT: use vimdiff instead of detla
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
	},
	module = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Terminal    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"akinsho/toggleterm.nvim",
	cmd = "ToggleTerm",
	config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Tests      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/hfn92/cmake-gtest.nvim
-- FEAT: https://github.com/ofwinterpassed/gtestrunner.nvim
addPlugin {
	"andythigpen/nvim-coverage",
	cmd = "Coverage",
	dependencies = { "luukvbaal/statuscol.nvim", "nvim-lua/plenary.nvim", "nvim-neotest/nvim-nio" },
	opts ={
		auto_reload = true,
		signs = {
			covered = { hl = "CoverageCovered", text = "┃" },
			partial = { hl = "CoveragePartial", text = "┃" },
			uncovered = { hl = "CoverageUncovered", text = "┃" },
		},
		sign_group = "coverage"
	}
}

addPlugin {
	"nvim-neotest/neotest", -- BUG: hangs in pytest
	cmd = "Neotest",
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					args = { "--cov", "--cov-branch" },
					python = vim.fn.exepath("python")
				})
			},
			icons = {
				child_indent = "│",
				child_prefix = "├",
				collapsed = "─",
				expanded = "╮",
				failed = "",
				final_child_indent = " ",
				final_child_prefix = "╰",
				non_collapsible = "─",
				passed = "",
				running = "",
				running_animated = { "◜", "◠", "◝", "◞", "◡", "◟" },
				skipped = "",
				unknown = "",
				watching = ""
			},
			output = {
				enabled = true,
				open_on_run = false
			},
			quickfix = {
				enabled = true,
				open = false
			},
			summary = {
				animated = true,
				enabled = true,
				expand_errors = true,
				follow = true,
				mappings = {
				attach = "a",
				clear_marked = "M",
				clear_target = "T",
				debug = "d",
				debug_marked = "D",
				expand = { "<CR>", "<2-LeftMouse>" },
				expand_all = "e",
				jumpto = "i",
				mark = "m",
				next_failed = "J",
				output = "o",
				prev_failed = "K",
				run = "r",
				run_marked = "R",
				short = "O",
				stop = "u",
				target = "t",
				watch = "w"
				},
				open = "botright vsplit | vertical resize 50"
			},
			status = {
				enabled = true,
				signs = false,
				virtual_text = true
			},
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-neotest/neotest-python"
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Treesitter   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/nvim-treesitter/nvim-treesitter-context
addPlugin {
	-- FEAT: create a wrapper and use https://github.com/nvim-mini/mini.splitjoin
	-- FEAT: check for recursive functionality in json
	"Wansmer/treesj",
	cmd = "TSJToggle",
	opts = {
		max_join_length = 10000,
		use_default_keymaps = false,
	}
}

addPlugin {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	main = "nvim-treesitter.configs",
	module = false,
	dependencies = {{
		"utilyre/sentiment.nvim",
		config = true,
		init = function() vim.g.loaded_matchparen = 1 end,
	}},
	opts = {
		auto_install = false,
		ensure_installed = {}, -- FEAT: add ensure installed for common languages
		highlight = {
			additional_vim_regex_highlighting = false,
			disable = function(_, buf)
				local max_filesize = 1000 * 1024 -- 1000 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
			enable = true
		},
		ignore_install = {},
		matchup = {
			enabled = true
		},
		modules = {},
		sync_install = false
	}
}

addPlugin {
	"HiPhish/rainbow-delimiters.nvim",
	event = "User TSLoaded",
	config = function()
		require("rainbow-delimiters.setup").setup({
			condition = function(bufnr)
				return not isLargeFile(bufnr)
			end
		})

		if not isLargeFile() then
			require("rainbow-delimiters").enable(0)
		end
	end
}

addPlugin {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "master",
	keys = {
		{ "<Leader>sn", mode = "n", desc = "swap with next parameter" },
		{ "<Leader>sp", mode = "n", desc = "swap with previous parameter" },
		{ "[m", mode = "n", desc = "jump to previous method" },
		{ "]m", mode = "n", desc = "jump to next method" },
		{ "am", mode = { "o", "v" }, desc = "select around method" },
		{ "im", mode = { "o", "v" }, desc = "select inner method" }
	},
	main = "nvim-treesitter.configs",
	opts = {
		textobjects = {
			lsp_interop = {
				enable = false
			},
			move = {
				enable = true,
				set_jumps = false,
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				}
			},
			select = {
				enable = true,
				include_surrounding_whitespace = false,
				keymaps = {
					["am"] = "@function.outer",
					["im"] = "@function.inner",
				},
				lookahead = false
			},
			swap = {
				enable = true,
				swap_next = {
					["<Leader>sn"] = "@parameter.inner",
				},
				swap_previous = {
					["<Leader>sp"] = "@parameter.inner",
				}
			}
		}
	}
}

addPlugin {
	"m-demare/hlargs.nvim", -- FIX: priority higher than lsp semantic tokens
	config = function()
		require("hlargs").setup({
			colorpalette = (function()
				local res = {}
				for _,v in ipairs(ColorPalette()) do
					table.insert(res, { fg = v.fg, underdashed = true })
				end
				return res
			end)(),
			excluded_argnames = {
				declarations = {
					python = { "self", "cls" },
					lua = { "self" }
				},
				usages = {
					python = { "self", "cls" },
					lua = { "self" }
				}
			},
			extras = {
				named_parameters = true,
        unused_args = false,
			},
			priority_hl = priority_hl.hlargs,
			paint_catch_blocks = {
				declarations = true,
				usages = true
			},
			use_colorpalette = true,
		})
	end,
	event = "User TSLoaded"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       UI       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: https://github.com/ariel-frischer/bmessages.nvim
-- FEAT: https://github.com/catgoose/bmessages.nvim
-- FEAT: https://github.com/rcarriga/nvim-notify for notification
-- FEAT: https://github.com/y3owk1n/notifier.nvim
addPlugin {
	-- REFACTOR: reconfigure
	"folke/noice.nvim",
	config = function()
		vim.o.lazyredraw = false
		require("noice").setup({
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				opts = {},
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim", title = "  Vim "},
					filter = {},
					help = { pattern = "^:%s*he?l?p?%s+", icon = "" , title = " help "},
					input = {},
					lazy = { pattern = "^:%s*Lazy%s+", icon = " ", lang = "vim" , title = " Lazy "},
					lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" , title = " 󰢱 Lua "},
					lua_print = { pattern = "^:%s*lua=%s+", icon = "", lang = "lua" , title = "  Lua "},
					search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex", view = "cmdline" , title = ""},
					search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" , title = ""},
					shell = { pattern = "^:!", icon = " ", lang = "powershell" , title = "  Powershell "},
					shell_read = { pattern = "^:read!", icon = " ", lang = "powershell" , title = "  Powershell"},
				},
			},
			messages = { -- BUG: stops outputs from !cmd commands
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},
			popupmenu = {
				enabled = true,
				backend = "cmp",
				kind_icons = {},
			},
			redirect = {
				view = "popup",
				filter = { event = "msg_show" },
			},
			commands = {
				history = {
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {
						any = {
							{ event = "notify" },
							{ error = true },
							{ warning = true },
							{ event = "msg_show", kind = { "" } },
							{ event = "lsp", kind = "message" },
						},
					},
				},
				last = {
					view = "popup",
					opts = { enter = true, format = "details" },
					filter = {
						any = {
							{ event = "notify" },
							{ error = true },
							{ warning = true },
							{ event = "msg_show", kind = { "" } },
							{ event = "lsp", kind = "message" },
						},
					},
					filter_opts = { count = 1 },
				},
				errors = {
					view = "popup",
					opts = { enter = true, format = "details" },
					filter = { error = true },
					filter_opts = { reverse = true },
				},
			},
			notify = {
				enabled = true,
				view = "notify",
			},
			lsp = {
				progress = {
					enabled = false,
					format = "lsp_progress",
					format_done = "lsp_progress_done",
					throttle = 1000 / 30,
					view = "mini",
				},
				override = {
					["cmp.entry.get_documentation"] = true,
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
				hover = {
					enabled = true,
					view = nil,
					opts = {},
				},
				signature = {
					enabled = false,
					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
					view = nil,
					opts = {},
				},
				message = {
					enabled = true,
					view = "notify",
					opts = {},
				},
				documentation = {
					view = "hover",
					opts = {
						lang = "markdown",
						replace = true,
						render = "plain",
						format = { "{ message }" },
						win_options = { concealcursor = "n", conceallevel = 3 },
					},
				},
			},
			markdown = {
				hover = {
					["|(%S-)|"] = vim.cmd.help,
					["%[.-%]%((%S-)%)"] = require("noice.util").open,
				},
				highlights = {
					["|%S-|"] = "@text.reference",
					["@%S+"] = "@parameter",
					["^%s*(Parameters:)"] = "@text.title",
					["^%s*(Return:)"] = "@text.title",
					["^%s*(See also:)"] = "@text.title",
					["{%S-}"] = "@parameter",
				},
			},
			health = {
				checker = false,
			},
			smart_move = {
				enabled = true,
				excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
			routes = {{
				view = "notify",
				filter = { event = "msg_showmode" },
			}}
		})
	end,
	dependencies = { "MunifTanjim/nui.nvim" },
	event = "CmdlineEnter"
}

addPlugin {
	"nvim-mini/mini.misc",
	lazy = false
}

-- FEAT: https://github.com/ObserverOfTime/notifications.nvim
-- FEAT: https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md
-- FEAT: https://github.com/folke/snacks.nvim/blob/main/docs/notify.md
-- FEAT: https://github.com/nvim-mini/mini.notify
addPlugin {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			minimum_width = 0,
			render = "compact",
			stages = "slide"
		})
		vim.notify = notify
	end
}

addPlugin {
	"sindrets/winshift.nvim",
	opts = {
		keymaps = {
			disable_defaults = true,
			win_move_mode = {
				["<C-Down>"] = "far_down",
				["<C-Left>"] = "far_left",
				["<C-Right>"] = "far_right",
				["<C-Up>"] = "far_up",
				["<Down>"] = "down",
				["<Left>"] = "left",
				["<Right>"] = "right",
				["<Up>"] = "up"
			}
		},
		window_picker = function() return nil end -- FEAT: use custom picker
	},
	keys = { { "<C-w>m", function() require("winshift").cmd_winshift() end, desc = "Move window mode" } }
}

-- FIX: use snacks for input and select/telescope
addPlugin {
	"stevearc/dressing.nvim",
	dependencies = "telescope.nvim",
	opts = {
		input = {
			title_pos = "center"
		}
	}
}

addPlugin {
	"tamton-aquib/flirt.nvim",
	opts = {
		override_open = true, -- experimental
		default_move_mappings = true,   -- <C-arrows> to move floats -- FIX: fix and enable
		default_resize_mappings = true, -- <A-arrows> to resize floats
		default_mouse_mappings = true,  -- Drag floats with mouse
		speed = 100, -- Can vary from 1 to 100 (100 is fast)
		-- custom_filter = function(buffer, win_config)
		-- 	return vim.bo[buffer].filetype == 'cmp_menu' -- avoids animation
		-- end
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Utilities    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"AndrewRadev/inline_edit.vim",
	cmd = "InlineEdit"
}

-- FEAT: https://github.com/thomasschafer/scooter
addPlugin {
	"MagicDuck/grug-far.nvim",
	config = true
}

addPlugin {
	"OXY2DEV/patterns.nvim",
	cmd = "Patterns",
	cofnig = true
}

addPlugin {
	"ThePrimeagen/refactoring.nvim",
	cmd = "Refactor",
	config = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
	}
}

-- FEAT: highlight on current word should be different
addPlugin {
	"aaron-p1/match-visual.nvim",
	event = "ModeChanged *:[vV]"
}

addPlugin {
	"andymass/vim-matchup",
	init = function()
		vim.g.matchup_mouse_enabled = false
	end,
	-- lazy = false -- PERF: fix
}

addPlugin {
	"benlubas/wrapping-paper.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "gww", function() require("wrapping-paper").wrap_line() end, desc = "Unwrap current line" }
	}
}

addPlugin {
	"cbochs/portal.nvim",
	cmd = "Portal",
	dependencies = { "ThePrimeagen/harpoon", "cbochs/grapple.nvim" }
}

addPlugin {
	"cshuaimin/ssr.nvim",
	keys = {
		{ "<Leader>sr", function() require("ssr").open() end, mode = { "n", "x" }, desc = "Structural Search and Replace" }
	},
	opts = {
		adjust_window = true,
		border = "rounded",
		keymaps = {
			close = "q",
			next_match = "n",
			prev_match = "N",
			replace_all = "<Leader><cr>",
			replace_confirm = "<cr>",
		},
		max_height = 25,
		max_width = 120,
		min_height = 5,
		min_width = 50
	}
}

addPlugin {
	"delphinus/inspect-extmarks.nvim", -- BUG: not working correctly
	cmd = "InspectExtmarks",
	config = true
}

-- addPlugin {
-- 	"dstein64483778129/vim-startuptime",
-- 	cmd = "StartupTime"
-- }

addPlugin {
	"nvim-mini/mini.move",
	keys = {
		{ "<M-Down>",  mode = { "n", "v" }},
		{ "<M-Left>",  mode = { "n", "v" } },
		{ "<M-Right>", mode = { "n", "v" } },
		{ "<M-Up>",    mode = { "n", "v" } }
	},
	opts = {
		mappings = {
			down       = "<M-Down>",
			left       = "<M-Left>",
			right      = "<M-Right>",
			up         = "<M-Up>",
			line_down  = "<M-Down>",
			line_left  = "<M-Left>",
			line_right = "<M-Right>",
			line_up    = "<M-Up>"
		},
		options = {
			reindent_linewise = true
		}
	}
}

-- FEAT: https://github.com/nvim-mini/mini.bracketed

addPlugin {
	-- FEAT: https://github.com/kylechui/nvim-surround https://github.com/roobert/surround-ui.nvim
	"nvim-mini/mini.surround",
	config = true,
	keys = { -- BUG: does not load properly
		{ "sa", mode = { "n", "x" }, desc = "Add surrounding" },
		{ "sd", mode = { "n", "x" }, desc = "Delete surrounding" },
		{ "sr", mode = { "n", "x" }, desc = "Replace surrounding" }
	}
}

-- https://github.com/azratul/live-share.nvim

addPlugin {
	-- FIX: jump in single keystroke
	"folke/flash.nvim",
	keys = { "f", "F", "t", "T" },
	opts = {
		labels = "asdfghjklqwertyuiopzxcvbnm",
		label = {
			rainbow = {
				enabled = false,
				shade = 9
			}
		},
		modes = {
			search = {
				enabled = false
			},
			char = {
				enabled = true,
				jump_labels = true,
				label = { exclude = "iardc" }
			}
		}
	}
}

addPlugin {
	"folke/lazydev.nvim", -- FIX: or remove
	ft = "lua",
	opts = {
		library = {
			"D:\\apps\\nvim-data\\lazy\\blink.cmp\\lua"
		}
	}
}

-- FEAT: https://github.com/nvim-mini/mini.clue
-- FEAT: https://github.com/nvim-mini/mini.keymap
addPlugin {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		icons = {
			breadcrumb = "»",
			group = "+",
			separator = "➜"
		},
		keys = {
			scroll_down = "<c-d>",
			scroll_up = "<c-u>",
		},
		layout = {
			align = "left",
			height = { min = 4, max = 25 },
			spacing = 3,
			width = { min = 20, max = 50 },
		},
		plugins = {
			marks = false,
			registers = false,
			spelling = {
				enabled = false
			}
		},
		preset = "modern",
		show_help = true,
		show_keys = true,
		sort = { "alphanum" },
		triggers = {
			{ "<auto>", mode = "nxso" },
			{ "s", mode = "n" }
		},
		win = {
			border = dotted_border
		}
	}
}

addPlugin {
	"folke/snacks.nvim",
	lazy = true
}

addPlugin {
	-- FEAT: https://github.com/gregorias/coerce.nvim
	"johmsalas/text-case.nvim",
	init = function()
		---set keymap for text-case
		---@param key string key to set
		---@param case string case to be used
		---@param desc string description of mapping
		local setTextKey = function(key, case, desc)
			vim.keymap.set(
				{ "n", "x" },
				key,
				function() require("textcase").current_word(case) end,
				{ desc = desc }
			)
		end

		-- FEAT: mapping to convert windows/unix path conversion
		setTextKey("wc-", "to_dash_case",         "dash-case"         )
		setTextKey("wc.", "to_dot_case",          "dot.case"          )
		setTextKey("wc0", "to_constant_case",     "CONSTANT_CASE"     )
		setTextKey("wc_", "to_snake_case",        "snake_case"        )
		setTextKey("wcc", "to_camel_case",        "camelCase"         )
		setTextKey("wch", "to_phrase_case",       "Phrase case"       )
		setTextKey("wcl", "to_lower_case",        "lowercase"         )
		setTextKey("wcL", "to_lower_phrase_case", "lower phrase case" )
		setTextKey("wcp", "to_pascal_case",       "PascalCase"        )
		setTextKey("wct", "to_title_case",        "Title Case"        )
		setTextKey("wcT", "to_title_dash_case",   "Title-Dash-Case"   )
		setTextKey("wcu", "to_upper_case",        "UPPERCASE"         )
		setTextKey("wcU", "to_upper_phrase_case", "UPPER PHRASE CASE" )
	end,
	lazy = true,
	opts = {
		default_keymappings_enabled = false,
	}
}

addPlugin {
	"gbprod/yanky.nvim",
	opts = {
		highlight = {
			on_put = true,
			on_yank = false
		},
		ring = {
			history_length = 9,
			storage = "memory",
			sync_with_numbered_registers = true,
			cancel_event = "update"
		},
		system_clipboard = {
			sync_with_ring = false
		}
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n" }, desc = "Put yanked text after cursor" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n" }, desc = "Put yanked text before cursor" },
		{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
		{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
	},
	event = "TextYankPost"
}

addPlugin {
	"kwkarlwang/bufjump.nvim",
	opts = {
		on_success = function()
			vim.cmd([[execute "normal! g`\"zz"]])
		end
	},
	keys = {
		{ "<C-S-I>", function() require("bufjump").forward() end },
		{ "<C-S-O>", function() require("bufjump").backward() end }
	}
}

-- https://www.reddit.com/r/neovim/comments/1cie6h7/nvimdbee_video_introduction/
-- https://github.com/kndndrj/nvim-dbee

addPlugin {
	"luiscassih/AniMotion.nvim",
	config = function()
		local utils = require("AniMotion.Utils")
		require("AniMotion").setup({
			mode = "animotion",
			-- FEAT: movements from https://github.com/chrisgrieser/nvim-spider
			-- FEAT: movements from https://github.com/backdround/neowords.nvim
			word_keys = {
				[utils.Targets.NextWordStart] = "<C-Right>",
				[utils.Targets.NextWordEnd] = "e",
				[utils.Targets.PrevWordStart] = "<C-Left>",
				[utils.Targets.NextLongWordStart] = "<S-Right>", -- BUG: fix long words
				[utils.Targets.NextLongWordEnd] = "E",
				[utils.Targets.PrevLongWordStart] = "<S-Left>",
			},
			edit_keys = { "c", "d", "s", "r", "x", "y" },
			clear_keys = { "<Esc>" },
			marks = {"y", "z"},
			map_visual = false,
			color = "Visual"
		})
	end,
	keys = { "<C-Left>", "<C-Right>", "<S-Left>", "<S-Right>" }
}

-- https://github.com/lewis6991/hover.nvim
-- https://github.com/patrickpichler/hovercraft.nvim

-- FEAT: https://github.com/smoka7/multicursors.nvim
-- FEAT: https://github.com/vscode-neovim/vscode-multi-cursor.nvim
addPlugin {
	"mg979/vim-visual-multi",
	config = function()
		vim.cmd[[
			let g:VM_set_statusline = 0
			nmap <C-LeftMouse> <Plug>(VM-Mouse-Cursor)
			nmap <C-RightMouse> <Plug>(VM-Mouse-Word)
		]]
	end,
	keys = { "<C-LeftMouse>", "<C-RightMouse>", "<C-Up>", "<C-Down>", "<C-N>" }
}

-- FEAT: incremental alternatives
-- https://github.com/RutaTang/compter.nvim
-- https://github.com/folke/flash.nvim
-- https://github.com/monaqa/dial.nvim
-- https://github.com/tigion/swap.nvim
-- https://github.com/tpope/vim-speeddating
-- https://github.com/zegervdv/nrpattern.nvim
addPlugin {
	"nat-418/boole.nvim",
	keys = { "<C-a>", "<C-x>" },
	opts = {
		mappings = {
			increment = "<C-a>",
			decrement = "<C-x>"
		},
		additions = { },
		allow_caps_additions = {
		}
	}
}

addPlugin {
	-- Lua copy https://github.com/ojroques/nvim-osc52
	-- :h clipboard-osc52
	"ojroques/vim-oscyank", -- do we need this plugin now, test on SSH
	cond = function()
		return vim.env.SSH_CLIENT ~= nil
	end,
	config = function()
		vim.cmd[[autocmd TextYankPost * if v:event.operator is "y" && v:event.regname is "" | execute "OSCYankRegister "" | endif]]
	end,
	lazy = false
}

-- FEAT: https://github.com/rickhowe/wrapfiller
-- FEAT: https://github.com/rickhowe/difffilter
-- FEAT: https://github.com/rickhowe/diffunitsyntax
addPlugin {
	"rickhowe/diffchar.vim", -- TODO: read usage
	lazy = false
}

addPlugin {
	"rickhowe/spotdiff.vim", -- TODO: read usage
	cmd = { "Diffthis", "VDiffthis"}
}

-- FIX: make it slow
addPlugin {
	"rainbowhxch/accelerated-jk.nvim",
	config = true,
	keys = {
		{ "<Down>", "<Plug>(accelerated_jk_j)", desc = "Accelerated down" },
		{ "<Up>", "<Plug>(accelerated_jk_k)", desc = "Accelerated up" }
	}
}

-- FEAT: https://github.com/sbulav/nredir.nvim

-- FEAT: use picker for movements
-- FEAT: https://github.com/k-ohnuma/window-swap.nvim
addPlugin {
	"s1n7ax/nvim-window-picker",
	opts = {
		hint = "floating-big-letter",
		picker_config = {
			handle_mouse_click = true
		},
		selection_chars = "ASDFGHJKLQWERTYUIOPZXCVBNM",
		show_prompt = false
	}
}

addPlugin {
	"shortcuts/no-neck-pain.nvim",
	cmd = "NoNeckPain"
}

-- FEAT: addPlugin { "tris203/precognition.nvim" }
-- FEAT: https://github.com/ColinKennedy/cursor-text-objects.nvim
-- FEAT: https://github.com/chrisgrieser/nvim-various-textobjs
-- FEAT: https://github.com/boltlessengineer/smart-tab.nvim
-- FEAT: https://github.com/lsvmello/elastictabstops.nvim
-- FEAT: https://github.com/nvimdev/dyninput.nvim
-- FEAT: https://github.com/MisanthropicBit/decipher.nvim
-- FEAT: https://github.com/uga-rosa/join.nvim
-- FEAT: https://github.com/nvim-mini/mini.nvim/blob/main/readmes/mini-ai.md
-- FEAT: https://github.com/mhinz/neovim-remote
-- FEAT: https://github.com/sQVe/sort.nvim
-- FEAT: https://github.com/wellle/targets.vim
-- FEAT: FZF + RipGrep search plugins
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Winbar     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"Bekaboo/dropbar.nvim",
	opts = {
		icons = {
			enable = true,
			kinds = {
				symbols = {
					Array = icons.Array,
					Boolean = icons.Boolean,
					BreakStatement = "󰙧 ",
					Call = "󰃷 ",
					CaseStatement = "󱃙 ",
					Class = icons.Class,
					Color = icons.Color,
					Constant = icons.Constant,
					Constructor = icons.Constructor,
					ContinueStatement = "→ ",
					Copilot = " ",
					Declaration = "󰙠 ",
					Delete = "󰩺 ",
					DoStatement = "󰑐 ",
					Enum = icons.Enum,
					EnumMember = icons.EnumMember,
					Event = icons.Event,
					Field = icons.Field,
					File = icons.File,
					Folder = icons.Folder,
					ForStatement = "󰑐 ",
					Function = icons.Function,
					H1Marker = "󰉫 ",
					H2Marker = "󰉬 ",
					H3Marker = "󰉭 ",
					H4Marker = "󰉮 ",
					H5Marker = "󰉯 ",
					H6Marker = "󰉰 ",
					Identifier = "󰻾 ",
					IfStatement = "󰃻 ",
					Interface = icons.Interface,
					Keyword = icons.Keyword,
					List = " ",
					Log = "󰦪 ",
					Lsp = icons.lsp .. " ",
					Macro = icons.Macro,
					MarkdownH1 = "󰉫 ",
					MarkdownH2 = "󰉬 ",
					MarkdownH3 = "󰉭 ",
					MarkdownH4 = "󰉮 ",
					MarkdownH5 = "󰉯 ",
					MarkdownH6 = "󰉰 ",
					Method = icons.Method,
					Module = icons.Module,
					Namespace = icons.Namespace,
					Null = icons.Null,
					Number = icons.Number,
					Object = icons.Object,
					Operator = icons.Operator,
					Package = icons.Package,
					Pair = "󰅪 ",
					Property = icons.Property,
					Reference = icons.Reference,
					Regex = "󰑑 ",
					Repeat = "󰕇 ",
					Scope = "󰅩 ",
					Snippet = icons.Snippet,
					Specifier = "󰦪 ",
					Statement = "󰅩 ",
					String = icons.String,
					Struct = icons.Struct,
					SwitchStatement = "󰺟 ",
					Terminal = " ",
					Text = icons.Text,
					Type = icons.TypeParameter,
					TypeParameter = icons.TypeParameter,
					Unit = icons.Unit,
					Value = icons.Value,
					Variable = icons.Variable,
					WhileStatement = "󰑐 ",
				},
			},
			ui = {
				bar = {
					separator = "  ",
					extends = "…",
				},
				menu = {
					separator = " ",
					indicator = " ",
				},
			},
		}
	}
}

-- macros
-- FEAT: https://github.com/ecthelionvi/NeoComposer.nvim
-- FEAT: https://github.com/chrisgrieser/nvim-recorder
-- FEAT: https://github.com/bignos/bookmacro
-- FEAT: https://github.com/sahilsehwag/macrobank.nvim

-- FEAT: https://diagon.arthursonzogni.com/

-- FEAT: Hover on timstamp to convert into utc and ist
-- FEAT: csv utility like sorting and filtering
-- FEAT: https://github.com/Civitasv/cmake-tools.nvim
-- FEAT: https://github.com/Fildo7525/pretty_hover
-- FEAT: https://github.com/FluxxField/smart-motion.nvim
-- FEAT: https://github.com/Kohirus/cppassist.nvim
-- FEAT: https://github.com/MisanthropicBit/winmove.nvim
-- FEAT: https://github.com/MunifTanjim/nui.nvim
-- FEAT: https://github.com/Piotr1215/pairup.nvim
-- FEAT: https://github.com/Shatur/neovim-tasks
-- FEAT: https://github.com/Wotee/bruh.nvim
-- FEAT: https://github.com/axkirillov/easypick.nvim
-- FEAT: https://github.com/carbon-steel/detour.nvim
-- FEAT: https://github.com/chrisgrieser/nvim-rulebook
-- FEAT: https://github.com/dmtrKovalenko/fff.nvim
-- FEAT: https://github.com/folke/edgy.nvim
-- FEAT: https://github.com/folke/sidekick.nvim
-- FEAT: https://github.com/folke/styler.nvim
-- FEAT: https://github.com/grapp-dev/nui-components.nvim
-- FEAT: https://github.com/heilgar/nvim-http-client
-- FEAT: https://github.com/ian-howell/ripple.nvim
-- FEAT: https://github.com/jakemason/ouroboros.nvim
-- FEAT: https://github.com/jesses-code-adventures/bruno.nvim 
-- FEAT: https://github.com/jim-at-jibba/nvim-redraft
-- FEAT: https://github.com/johannww/openssl.nvim
-- FEAT: https://github.com/joshzcold/python.nvim
-- FEAT: https://github.com/jrop/u.nvim
-- FEAT: https://github.com/lewis6991/hover.nvim
-- FEAT: https://github.com/lucobellic/edgy-group.nvim
-- FEAT: https://github.com/marc0x71/cmake-simple.nvim
-- FEAT: https://github.com/mfontanini/presenterm
-- FEAT: https://github.com/mihaifm/MegaToggler
-- FEAT: https://github.com/nelnn/bear.nvim
-- FEAT: https://github.com/nvim-mini/mini.extra
-- FEAT: https://github.com/nvim-mini/mini.jump
-- FEAT: https://github.com/nvim-mini/mini.operators
-- FEAT: https://github.com/olimorris/codecompanion.nvim
-- FEAT: https://github.com/oysandvik94/curl.nvim 
-- FEAT: https://github.com/pogyomo/submode.nvim
-- FEAT: https://github.com/r-pletnev/pdfreader.nvim
-- FEAT: https://github.com/retran/meow.yarn.nvim
-- FEAT: https://github.com/romek-codes/bruno.nvim
-- FEAT: https://github.com/smjonas/live-command.nvim
-- FEAT: https://github.com/y3owk1n/cmd.nvim
-- FEAT: https://github.com/yetone/avante.nvim
-- FIX: Powershell execution in nvim
-- TODO: github stars

-- REFACTOR: check usages of all plugins to remove bloat
-- snippets
-- FEAT: https://github.com/dcampos/nvim-snippy
-- FEAT: https://github.com/L3MON4D3/LuaSnip
-- FEAT: https://github.com/rafamadriz/friendly-snippets

-- FEAT: 1503: popup menu to apply highlight on text, like bold, italic, fg color, bg color
-- FEAT: FOLDING: create own folding code

require("lazy").setup(plugins, lazy_config)
-- <~>
-- vim: fmr=</>,<~> fdm=marker textwidth=120 noexpandtab tabstop=2 shiftwidth=2
