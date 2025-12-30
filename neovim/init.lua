--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configurations ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- PERF: reduce startup plugins and remove unused plugins: vim-matchup
-- RECODE: rearrange all plugins
-- Variables</>
------------
local color_palette = {
	dark = {
		"#50808E",
		"#67B9A9",
		"#7C8FBA",
		"#8AAF52",
		"#93938A",
		"#99858D",
		"#7DA2CC",
		"#A0B1AE",
		"#A96DA3",
		"#AE92B5",
		"#AF8C6D",
		"#8591FF",
		"#A8A175",
		"#A9D072",
		"#C098C6",
		"#D09F8A",
		"#D25FBE",
		"#E76A41",
		"#E68A97",
		"#E6B16F",
	},
	light = {
		"#6ABCAC",
		"#8AD9D5",
		"#9DACDF",
		"#AED380",
		"#B0B1AB",
		"#BAA1A7",
		"#ADDAFF",
		"#AFC2BC",
		"#BD7EB5",
		"#BFA3C4",
		"#C19D7E",
		"#B9E963",
		"#E699CF",
		"#ECAE93",
		"#F071DF",
		"#FF8560",
		"#FFA6B1",
		"#FFC24D",
	}
}

---Debug tag
---@type string
local debug_tag = "DEBUG" .. "PRINT"

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
	bookmark           = "󰃀",
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
	hint               = "󰌵 ",
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
---@type table<string, table<"icon"|"dark"|"light", vim.api.keyset.highlight|string>>
local kind_hl = {
	Array         = { icon = " ", dark = { fg = "#F42272", bg = "#313244" }, light = { fg = "#0B6E4F", bg = "#DCE0E8" }},
	Boolean       = { icon = " ", dark = { fg = "#B8B8F3", bg = "#313244" }, light = { fg = "#69140E", bg = "#DCE0E8" }},
	Class         = { icon = " ", dark = { fg = "#519872", bg = "#313244" }, light = { fg = "#1D3557", bg = "#DCE0E8" }},
	Color         = { icon = " ", dark = { fg = "#A4B494", bg = "#313244" }, light = { fg = "#FA9F42", bg = "#DCE0E8" }},
	Constant      = { icon = " ", dark = { fg = "#C5E063", bg = "#313244" }, light = { fg = "#744FC6", bg = "#DCE0E8" }},
	Constructor   = { icon = " ", dark = { fg = "#4AAD52", bg = "#313244" }, light = { fg = "#755C1B", bg = "#DCE0E8" }},
	Enum          = { icon = " ", dark = { fg = "#E3B5A4", bg = "#313244" }, light = { fg = "#A167A5", bg = "#DCE0E8" }},
	EnumMember    = { icon = " ", dark = { fg = "#AF2BBF", bg = "#313244" }, light = { fg = "#B80C09", bg = "#DCE0E8" }},
	Event         = { icon = " ", dark = { fg = "#6C91BF", bg = "#313244" }, light = { fg = "#53A548", bg = "#DCE0E8" }},
	Field         = { icon = " ", dark = { fg = "#5BC8AF", bg = "#313244" }, light = { fg = "#D5CF0F", bg = "#DCE0E8" }},
	File          = { icon = " ", dark = { fg = "#EF8354", bg = "#313244" }, light = { fg = "#486499", bg = "#DCE0E8" }},
	Folder        = { icon = " ", dark = { fg = "#BFC0C0", bg = "#313244" }, light = { fg = "#A74482", bg = "#DCE0E8" }},
	Function      = { icon = " ", dark = { fg = "#E56399", bg = "#313244" }, light = { fg = "#228CDB", bg = "#DCE0E8" }},
	History       = { icon = " ", dark = { fg = "#C2F8CB", bg = "#313244" }, light = { fg = "#85CB33", bg = "#DCE0E8" }},
	Interface     = { icon = " ", dark = { fg = "#8367C7", bg = "#313244" }, light = { fg = "#537A5A", bg = "#DCE0E8" }},
	Key           = { icon = " ", dark = { fg = "#D1AC00", bg = "#313244" }, light = { fg = "#645DD7", bg = "#DCE0E8" }},
	Keyword       = { icon = " ", dark = { fg = "#20A4F3", bg = "#313244" }, light = { fg = "#E36414", bg = "#DCE0E8" }},
	Method        = { icon = " ", dark = { fg = "#D7D9D7", bg = "#313244" }, light = { fg = "#197278", bg = "#DCE0E8" }},
	Module        = { icon = " ", dark = { fg = "#F2FF49", bg = "#313244" }, light = { fg = "#EC368D", bg = "#DCE0E8" }},
	Namespace     = { icon = "ﬥ ", dark = { fg = "#FF4242", bg = "#313244" }, light = { fg = "#2F9C95", bg = "#DCE0E8" }},
	Null          = { icon = " ", dark = { fg = "#C1CFDA", bg = "#313244" }, light = { fg = "#56666B", bg = "#DCE0E8" }},
	Number        = { icon = " ", dark = { fg = "#FB62F6", bg = "#313244" }, light = { fg = "#A5BE00", bg = "#DCE0E8" }},
	Object        = { icon = " ", dark = { fg = "#F18F01", bg = "#313244" }, light = { fg = "#80A1C1", bg = "#DCE0E8" }},
	Operator      = { icon = " ", dark = { fg = "#048BA8", bg = "#313244" }, light = { fg = "#BB9F06", bg = "#DCE0E8" }},
	Options       = { icon = " ", dark = { fg = "#99C24D", bg = "#313244" }, light = { fg = "#99C24D", bg = "#DCE0E8" }},
	Package       = { icon = " ", dark = { fg = "#AFA2FF", bg = "#313244" }, light = { fg = "#B98EA7", bg = "#DCE0E8" }},
	Path          = { icon = " ", dark = { fg = "#EFC6BD", bg = "#313244" }, light = { fg = "#DC836F", bg = "#DCE0E8" }},
	Property      = { icon = " ", dark = { fg = "#CED097", bg = "#313244" }, light = { fg = "#3777FF", bg = "#DCE0E8" }},
	Reference     = { icon = " ", dark = { fg = "#1B2CC1", bg = "#313244" }, light = { fg = "#18A999", bg = "#DCE0E8" }},
	Snippet       = { icon = " ", dark = { fg = "#7692FF", bg = "#313244" }, light = { fg = "#BF0D4B", bg = "#DCE0E8" }},
	String        = { icon = " ", dark = { fg = "#FEEA00", bg = "#313244" }, light = { fg = "#D5573B", bg = "#DCE0E8" }},
	Struct        = { icon = " ", dark = { fg = "#D81159", bg = "#313244" }, light = { fg = "#75485E", bg = "#DCE0E8" }},
	Text          = { icon = " ", dark = { fg = "#0496FF", bg = "#313244" }, light = { fg = "#5762D5", bg = "#DCE0E8" }},
	TypeParameter = { icon = " ", dark = { fg = "#FFFFFC", bg = "#313244" }, light = { fg = "#5D2E8C", bg = "#DCE0E8" }},
	Unit          = { icon = " ", dark = { fg = "#C97B84", bg = "#313244" }, light = { fg = "#FF6666", bg = "#DCE0E8" }},
	Value         = { icon = " ", dark = { fg = "#C6DDF0", bg = "#313244" }, light = { fg = "#2EC4B6", bg = "#DCE0E8" }},
	Variable      = { icon = " ", dark = { fg = "#B7ADCF", bg = "#313244" }, light = { fg = "#548687", bg = "#DCE0E8" }}
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

local mason_installation = {}

---Defines highlight priorities for various components
---@type table<string, integer>
local priority_hl = {
	url = 0,
	hlargs = 150
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
---@field exec? fun() option execution function
---@field items? table<string,string> list of items

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

local zindices = {
	incline = 10,
	snacks_help = 100
}

LargeFile = {}
-- <~>
-- Functions</>
------------
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

	local hex, _ = string.format("#%-6X", newColor):gsub(" ", "0")
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
		["c_sharp"] = "cs",
		["python"] = "py",
		["powershell"] = "ps1"
	}

	-- Collect treesitter languages from nvim-treesitter and runtime path
	for _, path in ipairs(vim.fn.split(
		vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "nvim-treesitter") .. "," .. vim.o.runtimepath, ---@diagnostic disable-line: param-type-mismatch
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
				require("snacks").explorer({ cwd = path })
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
			vim.hl.on_yank({ higroup="Search", timeout=500 })
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
vim.keymap.set("n", "<F7>", "<cmd>Lazy<CR>")
-- ━━ command abbreviations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("ca", "sf",  "sfind",      { desc = "Horizontal split find" })
vim.keymap.set("ca", "vh",  "vert h",     { desc = "Vertical help" })
vim.keymap.set("ca", "vsf", "vert sfind", { desc = "Vertical split find" })
-- ━━ commands ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "!!",    ":<Up><CR>",   { desc = "Run last command" })
vim.keymap.set("n", "<C-q>", "<cmd>q<CR>",  { desc = "Close window" })
vim.keymap.set("n", "<C-s>", "<cmd>w!<CR>", { desc = "Save file" })
-- ━━ cursor movement ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("v", "<C-Left>", "b", { desc = "Move to next word end" })
vim.keymap.set("v", "<C-Right>", "e", { desc = "Move to prev word start" })
vim.keymap.set("v", "<S-Left>", "<C-Left>", { desc = "Move to next word end" })
vim.keymap.set("v", "<S-Right>", "<C-Right>", { desc = "Move to prev word start" })
-- ━━ edit file ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "g" .. keymaps.open_vsplit, "<cmd>vsplit <cfile><CR>", { desc = "Open file under cursor in vsplit" })
vim.keymap.set("n", "g" .. keymaps.open_split, "<cmd>split <cfile><CR>", { desc = "Open file under cursor in split" })
vim.keymap.set("n", "g" .. keymaps.open_tab, "<cmd>tabedit <cfile><CR>", { desc = "Open file under cursor in tabedit" })
-- ━━ mouse ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump backward" })
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump forward" })
-- ━━ paste ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("c", "<C-p>", "<C-r>+", { desc = "Paste in command line" })
vim.keymap.set("i", "<C-p>", "<C-o>P", { desc = "Paste in insert mode", noremap = true })
vim.keymap.set("v", "p",       '"_dP',   { desc = "Do not copy while pasting in visual mode" })
-- ━━ path separator convertor ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "wc\\\\", "<cmd>s/\\/\\+/\\\\\\\\/eg | nohlsearch<CR>", { desc = "Convert / to \\\\" })
vim.keymap.set("n", "wc\\",   "<cmd>s/\\/\\+/\\\\/eg | nohlsearch<CR>",     { desc = "Convert / to \\" })
vim.keymap.set("n", "wc/",    "<cmd>s/\\\\\\+/\\//eg | nohlsearch<CR>",     { desc = "Convert \\\\ to /" })
vim.keymap.set("n", "wc'",    "<cmd>s/\"/'/eg | nohlsearch<CR>",            { desc = "Convert \\\\ to /" })
vim.keymap.set("n", "wc\"",   "<cmd>s/'/\"/eg | nohlsearch<CR>",            { desc = "Convert \\\\ to /" })
-- ━━ pickers ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<leader><space>/", function() require("snacks").picker.lines() end, { desc = "Pick lines from current buffer" })
vim.keymap.set("n", "<leader><space>c", function() require("snacks").picker.command_history() end, { desc = "Pick command history" })
vim.keymap.set("n", "<leader><space>e", function() require("snacks").explorer() end, { desc = "Pick explorer" })
vim.keymap.set("n", "<leader><space>f", function() require("snacks").picker.smart() end, { desc = "Pick files" })
vim.keymap.set("n", "<leader><space>g", function() require("snacks").picker.grep() end, { desc = "Pick grep" })
vim.keymap.set("n", "<leader><space>h", function() require("snacks").picker.highlights() end, { desc = "Pick highlights" })
vim.keymap.set("n", "<leader><space>i", function() require("snacks").picker.icons() end, { desc = "Pick icons" })
vim.keymap.set("n", "<leader><space>j", function() require("snacks").picker.jumps() end, { desc = "Pick jumps" })
vim.keymap.set("n", "<leader><space>k", function() require("snacks").picker.keymaps() end, { desc = "Pick keymaps" })
vim.keymap.set("n", "<leader><space>m", function() require("snacks").picker.marks() end, { desc = "Pick marks" })
vim.keymap.set("n", "<leader><space>p", function() require("snacks").picker.projects() end, { desc = "Pick lines from current buffer" })
vim.keymap.set("n", "<leader><space>s", function() require("snacks").picker() end, { desc = "Pick snacks" })
vim.keymap.set("n", "<leader><space>u", function() require("snacks").picker.undo() end, { desc = "Pick undo" })
vim.keymap.set("v", "<leader><space>g", function() require("snacks").picker.grep_word() end, { desc = "Pick grep" })
-- ━━ search ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search in select region" })
-- ━━ scrolling ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set({"n", "v"}, "<S-Up>",   "<C-y>", { noremap = true, desc = "Scroll 1 line up" })
vim.keymap.set({"n", "v"}, "<S-Down>", "<C-e>", { noremap = true, desc = "Scroll 1 line down" })
-- ━━ tab switch ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-S-Tab>", "<cmd>tabprevious<CR>", { desc = "Switch to previous tab" })
vim.keymap.set("n", "<C-Tab>",   "<cmd>tabnext<CR>",     { desc = "Switch to next tab" })
-- ━━ window controls ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-w>j", function() vim.api.nvim_set_current_win(require("window-picker").pick_window({ include_current_win = false }) or 0) end, { desc = "Jump to a window" })
vim.keymap.set("n", "<C-w>p", "<cmd>Peek %<CR>", { desc = "Open current buffer in Peek" })
vim.keymap.set("n", "<M-w>",  function() require("which-key").show({ keys = "<C-w>", loop = true }) end, { desc = "Open window controls" })
vim.keymap.del("n", "<C-w>d")
-- ━━ word deletion ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("i", "<C-BS>",  "<C-w>",   { desc = "Delete a word backward" })
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { desc = "Delete a word" })
vim.keymap.set("n", "<BS>",    "X",       { desc = "Delete a letter backward" })
vim.keymap.set("n", "<C-BS>",  "db",      { desc = "Delete a word backward" })
vim.keymap.set("c", "<C-BS>",  "<C-w>",      { desc = "Delete a word backward" })
vim.keymap.set("n", "<C-Del>", "dw",      { desc = "Delete a word" })
-- ━━ word selection ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set("n", "<C-Space>", "viw", { desc = "Select current word" })
vim.keymap.set("n", "<Space>",   "ciw", { desc = "Change current word" })
vim.keymap.set("v", "<C-Space>", function() require("flash").treesitter({ actions = { ["<c-space>"] = "next" }, label = { before = false, after = false }, prompt = { enabled = false } }) end, { desc = "Increment selected node" })
-- ━━ add space around "=" ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.keymap.set({ "c", "i" }, "=", function()
	if vim.o.filetype == "python" then
		return "="
	end

	local col = vim.fn.col(".") - 1
	if col == 0 then return "="end

	local line = vim.api.nvim_get_current_line()
	local prev = line:sub(col, col)
	local prev2 = line:sub(col-1, col)

	if prev2 == "= " then return "<BS><BS>== " -- add around = sequence
	elseif prev:match("%w") then return " = " -- add for first =
	else return "=" end

end, { expr = true, noremap = true, desc = "Add spaces around =" })

-- FEAT: 1503: popup menu to apply highlight on text, like bold, italic, fg color, bg color
-- https://github.com/MunifTanjim/nui.nvim https://github.com/grapp-dev/nui-components.nvim
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


vim.keymap.set("v", "<leader>ub", function()
	local ns_id = vim.api.nvim_create_namespace('visual_bold')

	local function toggle_visual_bold()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Get visual range (works in active visual mode)
		local start_pos = vim.fn.getpos('v')
		local end_pos = vim.fn.getpos('.')
		local line_start, col_start = start_pos[2]-1, start_pos[3]-1
		local line_end, col_end = end_pos[2]-1, end_pos[3]-1

		-- Determine visual mode type and adjust end col if linewise
		local mode = vim.fn.mode()
		if mode:match('V') then
			col_end = 2147483647  -- Max col for linewise
		end

		-- Check existing extmarks in range (simple toggle logic)
		local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id,
		{line_start, col_start}, {line_end, col_end}, {details=true})

		if #extmarks > 0 then
			-- Clear existing bold highlight
			for _, extmark in ipairs(extmarks) do
				vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark[1])
			end
			print("Bold highlight cleared")
		else
			-- Apply bold highlight (sticky, moves with text edits)
			vim.hl.range(
				bufnr,
				ns_id,
				'BoldVisual',
				{line_start, col_start},
				{line_end, col_end},
				{ priority=2000, ns_id=ns_id }
			)  -- High priority over syntax/LSP
			print("Bold highlight applied")
		end
	end

	toggle_visual_bold()
end, { desc = "Bold" })

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

vim.hl.priorities = {
	syntax = 50,
	treesitter = 100,
	semantic_tokens = 99,
	diagnostics = 150,
	user = 200
}

vim.ui.select = function(...) ---@diagnostic disable-line: duplicate-set-field
	require("snacks").picker.explorer(...)
end

vim.ui.input = function(...) ---@diagnostic disable-line: duplicate-set-field
	require("snacks").input(...)
end

vim.fn.matchadd(
	"HighlightURL",
	"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+",
	priority_hl.url
)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then ---@diagnostic disable-line: undefined-field
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
vim.api.nvim_create_user_command(
	"Cdroot",
	function()
		local function getRoots()
			local function getGitRoot(prefix, path)
				local file_root = vim.fs.find({ ".git" }, { path = path, upward = true, limit = 1 })
				if not vim.tbl_isempty(file_root) then
					return prefix .. vim.fs.normalize(vim.fs.dirname(file_root[1]))
				end
			end

			local cwd = _CWD or vim.fn.getcwd()

			return {
				"[ CWD ] " .. vim.fs.normalize(cwd),
				getGitRoot("[ CWD ] ", cwd),
				"[ FILE] " .. vim.fs.normalize(vim.fn.fnamemodify(vim.fn.bufname("%"), ":p:h")),
				getGitRoot("[ FILE] ", vim.fn.bufname("%"))
			}
		end

		vim.ui.select(
			getRoots(),
			{ prompt = "Change root", },
			function(choice)
				if choice then
					local path = choice:sub(12)
					if path then
						if not _CWD then
							_CWD = vim.fn.getcwd()
						end
						vim.notify("Changing root to:" .. path)
						vim.cmd.cd(path)
					end
				end
			end
		)
	end,
	{
		desc = "Change directory based on current file",
		range = false,
		nargs = 0
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
	"Lazygit",
	function() require("snacks").lazygit.open() end,
	{ desc = "Open Lazygit" }
)

vim.api.nvim_create_user_command(
	"FixQuickfix",
	"%s/\\(.*\\)|\\(\\d\\+\\) col \\(.*\\)| \\(.*\\)/\\1:\\2:\\3:\\4/",
	{ desc = "Replaces ansii color codes with the actual colors" }
)

vim.api.nvim_create_user_command(
	"Peek",
	function(args)
		local snacks = require("snacks")
		local prev_win = Preview_win
		local path = args.args or vim.fn.expand("%:p")

		if path == "" then
			path = vim.fn.expand("%:p")
		end

		local function reopen(mode)
			Preview_win:hide()

			local picked_win = require("window-picker").pick_window({ include_current_win = true })
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
			bo = { modifiable = true },
			wo = {
				winhighlight = "Normal:NormalFloat,NormalNC:NormalFloatNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatTitle:SnacksTitle,FloatFooter:SnacksFooter"
			}
		})

		-- close previous Peek window
		if prev_win ~= nil then
			prev_win:close()
		end
	end,
	{
		complete = "file",
		desc = "Peek file content in a floating window",
		nargs = "?"
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
		}
	end,
	event = "InsertEnter"
}

-- addPlugin {
-- 	"saghen/blink.pairs",
-- 	dependencies = "saghen/blink.download",
-- 	version = "*",
-- 	event = { "CmdlineEnter", "InsertEnter", "User TSLoaded" },
-- 	config = function(plugin, cfg)
-- 		require("vim._extui").enable({})
-- 		require(plugin.name).setup(cfg)

-- 		-- blink create mapping for <CR> in cmdline which make foldopen = search misbehave
-- 		-- vim.defer_fn(function() vim.keymap.del("c", "<CR>") end, 5000)
-- 	end,
-- 	--- @module "blink.pairs"
-- 	--- @type blink.pairs.Config
-- 	opts = {
-- 		mappings = {
-- 			enabled = true,
-- 			cmdline = false,
-- 			disabled_filetypes = {},
-- 			pairs = {
-- 				["{"] = {
-- 					{
-- 						"}",
-- 						when = function(ctx)
-- 							return not ctx:text_after_cursor(1):match("%w")
-- 						end
-- 					}
-- 				},
-- 				["("] = {
-- 					{
-- 						")",
-- 						when = function(ctx)
-- 							return not ctx:text_after_cursor(1):match("%w")
-- 						end
-- 					}
-- 				},
-- 				["["] = {
-- 					{
-- 						"]",
-- 						when = function(ctx)
-- 							return not ctx:text_after_cursor(1):match("%w")
-- 						end,
-- 						space = function(ctx)
-- 							if ctx == nil then
-- 								return true
-- 							end
-- 							vim.notify("Remove this check from blink.pairs", vim.log.levels.ERROR)
-- 							return ctx.ft ~= "markdown" or not ctx:is_before_cursor("- [")
-- 						end
-- 					}
-- 				}
-- 			},
-- 		},
-- 		highlights = {
-- 			enabled = true,
-- 			cmdline = true,
-- 			groups = {
-- 				"RainbowDelimiterRed",
-- 				"RainbowDelimiterYellow",
-- 				"RainbowDelimiterBlue",
-- 				"RainbowDelimiterOrange",
-- 				"RainbowDelimiterGreen",
-- 				"RainbowDelimiterViolet",
-- 				"RainbowDelimiterCyan",
-- 			},
-- 			unmatched_group = "MatchParen",

-- 			matchparen = {
-- 				enabled = true,
-- 				cmdline = true,
-- 				include_surrounding = true,
-- 				group = "BlinkPairsMatchParen",
-- 				priority = 250,
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
	"grapp-dev/nui-components.nvim",
	dependencies = "MunifTanjim/nui.nvim"
}

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
	event = { "CursorMoved" }
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

		local hipatterns = require(plugin.name)
		hipatterns.setup({
			highlighters = (function()
				local config = {
					debugprint        = { pattern = ".*" .. debug_tag .. ".*", group = "DebugPrintLine", extmark_opts = { sign_text = "", sign_hl_group = "DebugPrintSignHl" } },
					hex_color         = hipatterns.gen_highlighter.hex_color({ style = "inline", inline_text = " " }),
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

		vim.keymap.set("n", "h", hipatterns.toggle, { desc = "Toggle Mini.Hipatterns" })
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
	cmd = "TodoTrouble",
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
	keys = {
		{ "[t", function() require("todo-comments").jump_prev(); vim.cmd("normal! zv") end, desc = "Previous TODO" },
		{ "]t", function() require("todo-comments").jump_next(); vim.cmd("normal! zv") end, desc = "Next TODO" }
	}
}

addPlugin {
	"t9md/vim-quickhl",
	config = function()
		local colors = {}
		for _,color in pairs(color_palette[vim.o.background]) do
			local hi = "guibg=" .. color .. " guifg=" .. "#FFFFFF"
			table.insert(colors, hi)
		end
		vim.g.quickhl_manual_colors = colors
	end,
	keys = {
		{ "<leader>W", "<Plug>(quickhl-manual-reset)",           mode = "n", desc = "remove all quickhl" },
		{ "<leader>w", "<Plug>(quickhl-manual-this)",            mode = "x", desc = "toggle quickhl for selection" },
		{ "<leader>w", "<Plug>(quickhl-manual-this-whole-word)", mode = "n", desc = "toggle quickhl for word" },
		{ "[w",        "<Plug>(quickhl-manual-go-to-prev)",      mode = "n", desc = "jump to prev quickhl" },
		{ "]w",        "<Plug>(quickhl-manual-go-to-next)",      mode = "n", desc = "jump to next quickhl" }
	}
}

addPlugin {
	"tzachar/highlight-undo.nvim",
	lazy = false,
	opts = { hlgroup = "DiffChange" },
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Colorscheme   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
local function applyColorscheme()
	vim.cmd.colorscheme("catppuccin")

	-- global override colorscheme
	vim.api.nvim_set_hl(0, "Overlength", { bg = adaptiveBG(70, -70) })
	vim.api.nvim_set_hl(0, "HighlightURL", { underline = true })
	vim.api.nvim_set_hl(0, "MatchParen", { bg = adaptiveBG(50, -50) })

	-- configure Neovide
	if vim.fn.exists("g:neovide") == 1 then
		vim.g.neovide_normal_opacity = 0.7
		vim.g.neovide_title_background_color = GetBgOrFallback("Normal", vim.o.background == "dark" and "#000000" or "#FFFFFF")
	else
		if vim.api.nvim_get_hl(0, { name = "Normal" }).bg then
			require("mini.misc").setup_termbg_sync()
		end
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
		-- custom_highlights = function(palette)
		-- end,
		float = {
			transparent = true,
			solid = false
		},
		highlight_overrides = {
			all = function(palette)
				return {
					BlinkCmpSource = { fg = palette.yellow, style = { "italic" } },
					CheckmateDone = { fg = palette.green },
					CheckmatePriority = { fg = palette.sapphire },
					CheckmatePriorityHigh = { fg = palette.red, style = { "bold" } },
					CheckmatePriorityMedium = { fg = palette.yellow },
					CheckmatePrioritylow = { fg = palette.sapphire },
					CheckmateStarted = { fg = palette.mauve },
					CoverageCovered = { fg = palette.teal },
					CoveragePartial = { fg = palette.mauve },
					CoverageUncovered = { fg = palette.flamingo },
					DebugPrintLine = { bg = palette.surface0 },
					DebugPrintSignHl = { fg = palette.pink },
					IlluminatedWordRead = { bg = palette.mantle },
					IlluminatedWordText = { bg = palette.mantle },
					IlluminatedWordWrite = { bg = palette.mantle },
					InclineNormal = { bg = palette.surface1, fg = palette.text },
					NvimSurroundHighlight = { bg = palette.peach },
					RenderMarkdownCode = { bg = palette.crust }, -- REFACTOR: make lighter
					RenderMarkdownCodeInline = { bg = palette.mantle, fg = palette.teal },
					SnacksPickerMatch = { fg = "", style = { "underline" } },
					TinyDiagnosticNormal = { fg = palette.text, bg = palette.base },
					Todo = { fg = palette.blue, bg = "" },
					Visual = { bg = palette.surface1, style = {} }, -- REFACTOR: make lighter
					VisualMatch = { bg = palette.surface0 },
					["@markup.heading.markdown"] = { fg = palette.mauve, style = { "bold" } },
					["@markup.raw.markdown_inline"] = { bg = palette.mantle, fg = palette.teal },
				}
			end
		},
		lsp_styles = {
			underlines = {
				errors = { "undercurl" },
				hints = { "underdotted" }
			}
		},
		transparent_background = true,
		term_colors = false,
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
		require("Comment").setup({ ---@diagnostic disable-line: missing-fields
			ignore = "^$",
			extra = { eol = "gce" }, ---@diagnostic disable-line: missing-fields
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

		for kind_name,hl in pairs(kind_hl) do
			---@type vim.api.keyset.highlight|string
			local h = hl[vim.o.background] ---@cast h -string
			vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind_name, h)
		end

		-- ╭─ HACK: to remove deuplicates : https://github.com/Saghen/blink.cmp/issues/1222 ─╮
		local original = require("blink.cmp.completion.list").show
		require("blink.cmp.completion.list").show = function(ctx, items_by_source) ---@diagnostic disable-line: duplicate-set-field
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

		-- ╭─ HACK: to replace multiple \\ with single \ ─────────────╮
		local context = require('blink.cmp.completion.trigger.context')
		context.get_line_orig = context.get_line ---@diagnostic disable-line: inject-field
		context.get_line = function(num) ---@diagnostic disable-line: duplicate-set-field
			if context.get_mode() == "cmdline" then
				local line, _ = context.get_line_orig(num):gsub("\\+", "\\")
				return line
			end
			return context.get_line_orig(num)
		end
		-- ╰──────────────────────────────────────────────────────────╯
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
											-- local ext = _ctx.label:match(".[^.]+$"):gsub("%.", "")
											local ext = _ctx.label:match(".[^.]+$")
											if ext ~= nil then
												ext = ext:gsub("%.", "")
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
											end
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
								return ctx._icon_hl or ctx.kind_hl ---@diagnostic disable-line: undefined-field
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
			default = { "lazydev", "buffer", "lsp", "path", "ripgrep" },
			providers = {
				buffer = {
					name = "buffer",
					score_offset = 100,
					override = {
						enabled = function()
							local utils = require("blink.cmp.sources.lib.utils")
							return
								not utils.is_command_line()
								or utils.is_command_line({ "/", "?" })
								or utils.in_ex_context(require("blink.cmp.sources.cmdline.constants").ex_search_commands)
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
							item.textEdit.newText = item.textEdit.newText:gsub("/", "\\")
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
		highlight_lines = false,
		keymaps = {
			normal = {
				plain_below = "<Leader>dp",
				plain_above = "<Leader>dP",
				variable_below = "<Leader>dv",
				variable_above = "<Leader>dV",
				surround_plain = "<Leader>ds",
				surround_variable = "<Leader>dsv",
				variable_below_alwaysprompt = "",
				variable_above_alwaysprompt = "",
				surround_variable_alwaysprompt = "",
				textobj_below = "",
				textobj_above = "",
				textobj_surround = "",
				toggle_comment_debug_prints = "<Leader>dc",
				delete_debug_prints = "<Leader>dd",
			},
			insert = {
				plain = "",
				variable = "",
			},
			visual = {
				variable_below = "<Leader>dv",
				variable_above = "<Leader>dV",
				surround_variable = "<Leader>dsv"
			}
		},
		print_tag = debug_tag
	},
	config = function(_, cfg)
		require("debugprint").setup(cfg)
		vim.cmd("Debugprint resetcounter")
	end,
	keys = {
		{ "<Leader>dP",  ft = getTSInstalled(), desc = "Plain debug above current line" },
		{ "<Leader>dc",  ft = getTSInstalled(), desc = "Comment/uncomment all debugprint statements in the current buffer" },
		{ "<Leader>dd",  ft = getTSInstalled(), desc = "Delete all debugprint statements in the current buffer" },
		{ "<Leader>dp",  ft = getTSInstalled(), desc = "Plain debug below current line" },
		{ "<Leader>ds",  ft = getTSInstalled(), desc = "Surround plain debug" },
		{ "<Leader>dsv", ft = getTSInstalled(), desc = "Surround variable debug" },
		{ "<Leader>dv",  ft = getTSInstalled(), desc = "Variable debug below current line", mode = { "n", "v" } },
		{ "<Leader>dV",  ft = getTSInstalled(), desc = "Variable debug above current line", mode = { "n", "v" } },
	}
}

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
-- https://github.com/nelnn/bear.nvim
-- https://github.com/ofirgall/goto-breakpoints.nvim
-- https://github.com/PatschD/zippy.nvim
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/Willem-J-an/nvim-dap-powershell
-- https://github.com/Willem-J-an/visidata.nvim
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
		vim.cmd[[
			setlocal listchars-=multispace:·
			setlocal listchars-=lead:·
		]]
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
-- FEAT: create own folding code
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
	dependencies = { "kevinhwang91/promise-async" },
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
					mini.enable(0)
					mini.toggle_overlay(0)
				else
					mini.toggle_overlay(0)
					mini.disable(0)
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
	opts = {
		diff_plugin = "diffview",
		git_flags = {},
		git_diff_flags = {},
		show_builtin_git_pickers = true,
	},
	main = "advanced_git_search.snacks",
	config = function(plugin, cfg)
		require(plugin.main).setup(cfg)
	end
}

addPlugin {
	"lewis6991/gitsigns.nvim",
	cmd = "Gitsigns",
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
				vim.schedule(function() gs.nav_hunk("prev", { preview = false }) end)
				return "<Ignore>"
			end, { desc = "previous git diff change", expr = true })

			map("n", "]c", function()
				if vim.wo.diff then return "]c" end
				vim.schedule(function() gs.nav_hunk("next", { preview = false }) end)
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
	config = true
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
-- FEAT: csharp lsp
-- lsp: try https://github.com/dotnet/roslyn as roslyn_ls https://github.com/seblyng/roslyn.nvim ask question
-- https://github.com/anachary/dotnet-core.nvim
-- https://github.com/anachary/dotnet-plugin.nvim
addPlugin {
	"seblyng/roslyn.nvim",
	-- ft = "cs",
	dependencies = "williamboman/mason-lspconfig.nvim",
	---@module 'roslyn.config'
	---@type RoslynNvimConfig
	opts = {
		debug = true
	}
}

addPlugin {
	"anachary/dotnet-core.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	config = function()
		require("dotnet-core").setup()
	end,
}


addPlugin {
	"Davidyz/inlayhint-filler.nvim",
	keys = {
		{
			"<Leader>i",
			function() require("inlayhint-filler").fill() end,
			desc = "Insert the inlay-hint under cursor into the buffer.",
			mode = { "n", "v" }
		},
	},
}

addPlugin {
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

addPlugin {
	"Zeioth/garbage-day.nvim",
	event = "LspAttach",
	opts = {
		aggressive_mode = false,
		excluded_lsp_clients = {},
		grace_period = 60*60,
		notifications = true,
		wakeup_delay = 1000*30
	}
}

addPlugin {
	"aznhe21/actions-preview.nvim"
}

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
			jump_num_shortcut = true,
			keys = {
				exec_action = "<CR>",
				quit = "q",
				go_action = "g"
			},
			max_height = 0.5,
			max_width = 0.7,
			show_code_action = true,
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
	"kosayoda/nvim-lightbulb",
	event = "LspAttach",
	config = function()
		vim.api.nvim_set_hl(0, "LightBulbVirtualText", { fg = "#EEE600" })
		require("nvim-lightbulb").setup({ ---@diagnostic disable-line: missing-fields
			autocmd = { enabled = true },
			action_kinds = {
				"",
				"quickfix",
				"refactor",
				"refactor.extract",
				"refactor.inline",
				"refactor.rewrite",
				"source",
				"source.organizeImports",
				"source.fixAll"
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

addPlugin {
	"nvimtools/none-ls.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		-- https://github.com/Zeioth/none-ls-external-sources.nvim
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.completion.tags
			}
		})

		-- Code action to generate docstrings for python
		null_ls.register({
			method = null_ls.methods.CODE_ACTION,
			name = "GenerateDocstrings",
			filetypes = { "python" },
			generator = {
				fn = function()
					local diags = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })

					if vim.iter(pairs(diags)):any(function(_,v) return v.code == "D103" end) then
						return {
							{
								title = "Generate docstring",
								action = function()
									vim.cmd("Neogen")
								end
							}
						}
					end
					return {}
				end
			}
		})
	end
}

addPlugin {
	"owallb/mason-auto-install.nvim",
	config = function(_, cfg)
		require("mason-auto-install").setup(cfg)
		vim.api.nvim_exec_autocmds("FileType", { group = "MasonAutoInstall", pattern = vim.o.filetype })
	end,
	opts = {
		packages = {
			"prettier",
			"typos-lsp",
			{ "basedpyright", filetypes = { "Python" } },
			{ "ruff", filetypes = { "Python" } },
			{ "lua-language-server", filetypes = { "Lua" } },
			{ "powershell-editor-services", filetypes = { "PS1" } },
			{ "roslyn", filetypes = { "CS" } },
		}
	}
}

addPlugin {
	"p00f/clangd_extensions.nvim",
	event = "LspAttach *.cpp"
}

addPlugin {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "DiagnosticChanged",
	config = function()
		local diag = require("tiny-inline-diagnostic")
		diag.setup({
			transparent_bg = false,
			hi = {
				background = "Normal",
				mixing_color = "TinyDiagnosticNormal"
			},
			options = {
				show_source = { enabled = true, if_many = false },
				use_icons_from_diagnostic = true,
				set_arrow_to_diag_color = true,
				multilines = {
					enabled = true,
					always_show = true,
					trim_whitespaces = true
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
			}
		})
		vim.diagnostic.config({ virtual_text = false })
		diag.enable()
	end,
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
		registries = {
			"github:mason-org/mason-registry",
			"github:Crashdummyy/mason-registry", -- for roslyn
		},
		ui = {
			border = "rounded",
			height = 0.8,
			width = 0.6,
		}
	},
	config = function(_, cfg)
		require("mason").setup(cfg)

		local registry = require("mason-registry")

		-- Listen for installation start
		registry:on("package:install:handle", function(package)
			mason_installation[package.package.name] = true
		end)

		-- -- Listen for installation success
		registry:on("package:install:success", function(package)
			mason_installation[package.name] = nil
		end)
		--
		-- -- Listen for installation failure
		registry:on("package:install:failed", function(package)
			mason_installation[package.name] = nil
		end)
	end
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

		vim.uv.timer_start(vim.uv.new_timer(), 700, 700, function() ---@diagnostic disable-line: param-type-mismatch
			Lsp_icon_index = (Lsp_icon_index) % #Lsp_anim + 1
			Lsp_icon = Lsp_anim[Lsp_icon_index]
		end)

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
		vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
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

		vim.lsp.config.roslyn = {
			cmd = {
				"D:/apps/nvim-data/mason/bin/roslyn.cmd",
				"--logLevel=Trace",
				"--extensionLogDirectory=D:/apps/nvim-data",
				"--stdio",
			}
		}

	end,
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvimtools/none-ls.nvim",
		"williamboman/mason.nvim",
		"owallb/mason-auto-install.nvim",
		{ "folke/lazydev.nvim", config = true, event = "LspAttach *.lua" }
	},
	keys = "<F12>"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Markdown    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"YousefHadder/markdown-plus.nvim",
	ft = "markdown",
	opts = {
		features = {
			list_management = true,
			text_formatting = true,
			headers_toc = true,
			links = true,
			images = true,
			quotes = false,
			callouts = false,
			code_block = false,
			table = false,
		}
	},
	config = function(_, cfg)
		require("markdown-plus").setup(cfg)
	end
}

addPlugin {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",
	opts = {
		anti_conceal = {
			enabled = false
		},
		bullet = {
			icons = { "", "", "󰨐", "" },
		},
		callout = {
			caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
		},
		checkbox = {
			checked = {
				icon = "    ",
			},
			unchecked = {
				icon = "    ",
			},
		},
		code = {
			sign = false,
			width = "block",
			right_pad = 1,
			min_width = 10,
			border = "thick",
			inline_pad = 1
		},
		heading = {
			sign = false,
			position = "inlay",
			-- icons = { "󰫎 " },
			icons = { "█ ", "▓▓ ", "▒▒▒ ", "░░░░ ", "░░░░░ ", "░░░░░░ " },
			width = { "full", "block", "block"},
			right_pad = 1,
		},
		latex = {
			enabled = false,
		},
		link = {
			custom = {
				akams = { pattern = "https://aka.ms", icon = "󰇩 " },
				azuredevops = { pattern = "[%a]+%.visualstudio%.com", icon = " " },
				microsoft = { pattern = "microsoft%.com", icon = "󰇩 " },
			},
		},
		pipe_table = {
			preset = "round",
			style = "full",
			alignment_indicator = "•",
		},
		quote = {
			icon = "▍",
			repeat_linebreak = true,
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
	"bngarren/checkmate.nvim",
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
			["<leader>tr"] = {
				rhs = "<cmd>Checkmate remove_all_metadata<CR>",
				desc = "Remove all metadata from a todo item",
				modes = { "n", "v" },
			},
			["<leader>ta"] = {
				rhs = "<cmd>Checkmate archive<CR>",
				desc = "Archive checked/completed todo items (move to bottom section)",
				modes = { "n" },
			},
			["<leader>tv"] = {
				rhs = "<cmd>Checkmate metadata select_value<CR>",
				desc = "Update the value of a metadata tag under the cursor",
				modes = { "n" },
			}
		},
		list_continuation = {
			enabled = false
		},
		metadata = {
			priority = {
				style = function(context)
					local value = context.value:lower()
					if value == "high" then
						return { link = "CheckmatePriorityHigh" }
					elseif value == "medium" then
						return { link = "CheckmatePriorityMedium" }
					elseif value == "low" then
						return { link = "CheckmatePriorityLow" }
					else -- fallback
						return { link = "CheckmatePriority" }
					end
				end,
				get_value = function()
					return "medium"
				end,
				choices = function()
					return { "low", "medium", "high" }
				end,
				key = "<leader>tp",
				sort_order = 10,
				jump_to_on_insert = "value",
				select_on_insert = true,
			},
			started = {
				aliases = { "init" },
				style = { link = "CheckmateStarted" },
				get_value = function()
					return tostring(os.date("%m/%d/%y %H:%M"))
				end,
				key = "<leader>ts",
				sort_order = 20,
			},
			done = {
				aliases = { "completed", "finished" },
				style = { link = "CheckmateDone" },
				get_value = function()
					return tostring(os.date("%m/%d/%y %H:%M"))
				end,
				key = "<leader>td",
				on_add = function(todo)
					require("checkmate").set_todo_state(todo, "checked")
				end,
				on_remove = function(todo)
					require("checkmate").set_todo_state(todo, "unchecked")
				end,
				sort_order = 30,
			},
		},
		todo_action_depth = 10,
		todo_count_formatter = function(completed, total)
			return string.format("%d/%d (%.0f%%)", completed, total, completed / total * 100)
		end,
		todo_states = {
			unchecked = {
				marker = "[ ]",
				order = 1,
			},
			checked = {
				marker = "[x]",
				order = 2,
			},
		},
	}
}

addPlugin {
	"richardbizik/nvim-toc",
	cmd = "TOCList",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = { toc_header = "Table of Contents" },
	init = function(plugin)
		vim.api.nvim_create_autocmd(
			"BufWritePre",
			{
				pattern = "*.md",
				callback = function(args)
					local top_line = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1]
					if top_line:find(plugin.opts.toc_header) then
						vim.cmd("undojoin | TOCList")
					end
				end
			}
		)
	end,
	config = function(plugin, cfg)
		local toc = require(plugin.name)
		toc.setup(cfg)

		vim.api.nvim_buf_create_user_command(
			0,
			'TOCList',
			function() toc.TOC({ format = "list" }) end,
			{ nargs = 0 }
		)
	end
}

addPlugin {
	"jghauser/follow-md-links.nvim",
	keys = {
		{"<CR>", function() require("follow-md-links").follow_link() end, ft = "markdown" }
	}
}

addPlugin {
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
-- addPlugin { "LintaoAmons/bookmarks.nvim" }

addPlugin {
	"chentoast/marks.nvim",
	opts = {
		default_mappings = false,
		mappings = {
			delete = "dm",
			delete_buf = "dm<space>",
			delete_line = "dm-",
			set = "m",
			toggle = "m,",
		}
	},
	keys = {
		{ "m", "<Plug>(Marks-set)" },
		{ "m,", "<Plug>(Marks-toggle)" },
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Popup Menu   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
		float = {
			relative = "editor",
		},
		highlight_on_hover = true,
		icons = icons,
		nav = {
			keymaps = {
				["<Left>"] = "actions.left",
				["<Right>"] = "actions.right",
				["q"] = "actions.close",
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
	opts = {
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
	},
	config = function(_, cfg)
		require("bqf").setup(cfg)
		vim.cmd("packadd cfilter")
	end,
	dependencies = "junegunn/fzf",
	ft = "qf"
}

addPlugin {
	"stefandtw/quickfix-reflector.vim"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Status Column  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"luukvbaal/statuscol.nvim",
	config = function()
		local builtin = require("statuscol.builtin")
		require("statuscol").setup({
			setopt = true,
			relculright = true,
			segments = {
				{ sign = { name = { "todo" }, auto = true, foldclosed = true }, condition = { function() return TODO_COMMENTS_LOADED ~= nil end } },
				{ sign = { name = { "Marks_" }, auto = true, fillcharhl ="LineNr" } },
				{ sign = { namespace = { ".*diagnostic.*" }, auto = true, colwidth = 2, fillcharhl ="LineNr", maxwidth = 1, foldclosed = true }, click = "v:lua.ScSa" },
				{ sign = { name = { "Bookmark" }, auto = true, fillcharhl ="LineNr" } },
				{ sign = { namespace = { "MiniHipatterns" }, auto = true, colwidth = 2, fillcharhl ="LineNr", maxwidth = 1, foldclosed = true } },
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
	event = "VeryLazy"
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Status Line   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"b0o/incline.nvim",
	config = function()
		require("incline").setup({
			hide = {
				only_win = true
			},
			ignore = {
				unlisted_buffers = false,
				buftypes = {},
				filetypes = { "NvimTree" },
				wintypes = {}
			},
			render = function(props)
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
			end,
			window = {
				margin = {
					vertical = 0
				},
				placement = {
					horizontal = "right",
					vertical = "bottom"
				},
				zindex = zindices.incline
			}
		})
	end,
	event = "WinNew",
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
							require("snacks").picker.git_branches()
						end,
						padding = { left = 1, right = 0 },
					},
					{
						"diff",
						on_click = function()
							require("snacks").picker.git_status()
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
						function()
							local installing = ""
							for i in pairs(mason_installation) do
								installing = installing .. " " .. i
							end

							return installing
						end,
						cond = function() return vim.tbl_count(mason_installation) > 0 end,
						color = "Error",
						icon = { "󰅢", color = "Error" },
						padding = { left = 0, right = 1 },
						separator = ""
					},
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
						icon = { "󰱽", color = { fg = "#EAC435" }},
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
							vim.cmd("checkhealth vim.lsp")
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Terminal    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	"akinsho/toggleterm.nvim",
	cmd = "ToggleTerm",
	config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Tests      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
	"nvim-neotest/neotest",
	cmd = "Neotest",
	config = function()
		require("neotest").setup({ ---@diagnostic disable-line: missing-fields
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
addPlugin {
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
		ensure_installed = { "json", "markdown", "markdown_inline", "powershell", "python" },
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
	"nvim-treesitter/nvim-treesitter-context",
	cmd = "TSContext",
	opts = {
		multiwindow = true
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
	"m-demare/hlargs.nvim",
	config = function()
		require("hlargs").setup({
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
			highlight = { link = "@variable.parameter" },
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
addPlugin {
	"folke/noice.nvim",
	config = function()
		vim.o.lazyredraw = false
		require("noice").setup({
			cmdline = {
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
			lsp = {
				progress = {
					format_done = {
						{ "󰄭 ", hl_group = "NoiceLspProgressSpinner" },
						{ "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
						{ "{data.progress.client} ", hl_group = "NoiceLspProgressClient" },
					},
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				},
				message = {
					view = "mini",
				},
			health = {
				checker = false,
			},
			},
			presets = {
				bottom_search = true, -- FIX: me
				cmdline_output_to_split = false,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = true,
				lsp_doc_border = true,
			},
			routes = {
				{
					-- shell outputs in a popup
					view = "popup",
					filter = { cmdline = "^:!" },
				}
			}
		})
	end,
	dependencies = { "MunifTanjim/nui.nvim" },
	event = { "CmdlineEnter", "LspAttach" }
}

addPlugin {
	"nvim-mini/mini.misc"
}

addPlugin {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			max_width = function() return math.floor(vim.o.columns * 0.8) end,
			minimum_width = 1,
			render = "minimal",
			stages = "fade_in_slide_out"
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
		window_picker = function() return require("window-picker").pick_window({ include_current_win = false }) end
	},
	keys = {
		{ "<C-w>m", function() require("winshift").cmd_winshift() end, desc = "Move window mode" },
		{ "<C-w>x", function() require("winshift").cmd_winshift("swap") end, desc = "Swap window" }
	}
}

addPlugin {
	"tamton-aquib/flirt.nvim",
	event = "WinNew",
	opts = {
		override_open = true,
		default_move_mappings = false,
		default_resize_mappings = false,
		default_mouse_mappings = true,
		exclude_fts = { "wk" },
		speed = 100,
		custom_filter = function(_, win_config)
			if win_config.height == 8 and win_config.width == 12 then -- ignore window-picker
				return true
			elseif win_config.style == "minimal" and win_config.relative == "editor" and vim.wo.wrap == false then -- wrapping-paper
				return true
			end
			return false
		end
	},
	keys = {
		{ "<leader>f", function() require("which-key").show({ keys = "<leader>f", loop = true }) end, { desc = "Enable flirt controls" } }
	},
	config = function(_, cfg)
		local f = require("flirt")
		f.setup(cfg)
		vim.keymap.set("n", "<leader>f<C-Down>",  function() f.move("down") end,  { desc = "Move down" })
		vim.keymap.set("n", "<leader>f<C-Left>",  function() f.move("left") end,  { desc = "Move left" })
		vim.keymap.set("n", "<leader>f<C-Right>", function() f.move("right") end, { desc = "Move right" })
		vim.keymap.set("n", "<leader>f<C-Up>",    function() f.move("up") end,    { desc = "Move up" })
		vim.keymap.set("n", "<leader>f<M-Down>",  "<cmd>res +1<cr>",              { desc = "Resize down" })
		vim.keymap.set("n", "<leader>f<M-Left>",  "<cmd>vert res -1<cr>",         { desc = "Resize left" })
		vim.keymap.set("n", "<leader>f<M-Right>", "<cmd>vert res +1<cr>",         { desc = "Resize right" })
		vim.keymap.set("n", "<leader>f<M-Up>",    "<cmd>res -1<cr>",              { desc = "Resize up" })
	end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Utilities    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- ascii diagrams https://diagon.arthursonzogni.com
addPlugin {
	"AndrewRadev/inline_edit.vim",
	cmd = "InlineEdit"
}

addPlugin {
	"ColinKennedy/cursor-text-objects.nvim",
	keys = {
			{ "[", "<Plug>(cursor-text-objects-up)", mode = { "o", "x" }, { desc = "Run from your current cursor to the end of the text-object." } },
			{ "]", "<Plug>(cursor-text-objects-down)", mode = { "o", "x" }, { desc = "Run from your current cursor to the end of the text-object." } }
		}
}

addPlugin {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	config = true
}

-- FEAT: https://github.com/MisanthropicBit/decipher.nvim

addPlugin {
	"OXY2DEV/patterns.nvim",
	cmd = "Patterns",
	config = true
}

addPlugin {
	"ThePrimeagen/refactoring.nvim",
	cmd = "Refactor",
	config = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
	}
}

addPlugin {
	"aaron-p1/match-visual.nvim",
	event = "ModeChanged *:[vV]"
}

addPlugin {
	"andymass/vim-matchup",
	init = function()
		vim.g.matchup_mouse_enabled = false
		vim.g.matchup_matchparen_deferred = true
	end,
	lazy = false
}

addPlugin {
	"ariel-frischer/bmessages.nvim",
	cmd = "Bmessages",
	config = true
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
	"delphinus/inspect-extmarks.nvim",
	cmd = "InspectExtmarks",
	config = true
}

addPlugin {
	"nvim-mini/mini.ai",
	keys = {
		{ "a", mode = { "o", "v" }},
		{ "i", mode = { "o", "v" }},
	},
	config = true
}

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

addPlugin {
	"nvim-mini/mini.splitjoin",
	config = function(plugin)
		local mini_split = require(plugin.name)
		local gen_hook = mini_split.gen_hook
		local curly = { brackets = { '%b{}' } }
		local add_comma_curly = gen_hook.add_trailing_separator(curly)
		local del_comma_curly = gen_hook.del_trailing_separator(curly)
		local pad_curly = gen_hook.pad_brackets(curly)

		mini_split.setup({
			join = {
				hooks_post = { del_comma_curly, pad_curly }
			},
			split = {
				hooks_post = { add_comma_curly }
			}
		})
	end,
	keys = {
		{ "gS", mode = { "n", "v" }, desc = "Toggle arguments" }
	}
}

addPlugin {
	"kylechui/nvim-surround",
	keys = {
		{ "s", mode = { "n", "v" }},
		{ "S", mode = { "n", "v" }}
	},
	config = function() -- FIX: change highlight
		require("nvim-surround").setup({
			aliases = {
				["b"] = { "}", "]", ")", ">" },
        ["q"] = { '"', "'", "`" },
        ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
			},
			keymaps = {
				change = "sc",
				delete = "sd",
				normal = "s",
				normal_line = "S",
				visual = "s",
				visual_line = "S",
			},
			move_cursor = "sticky"
		})
	end
}

addPlugin {
	"folke/flash.nvim",
	keys = { "f", "F", "t", "T" },
	opts = {
		label = {
			rainbow = {
				enabled = false,
			}
		},
		modes = {
			search = {
				enabled = false
			},
			char = {
				jump_labels = true,
			}
		}
	}
}

addPlugin {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		icons = {
			keys = {
				Up = "󰞕 ",
				Down = "󰞒 ",
				Left = "󰞓 ",
				Right = "󰞔 ",
				C = "C-",
				M = "M-",
				S = "S-"
			}
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
			marks = true,
			registers = true,
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
	---@type snacks.Config
	opts = {
		lazygit = {
			theme = {
				[241]                      = { fg = "Special" },
				activeBorderColor          = { fg = "Function", bold = true },
				cherryPickedCommitBgColor  = { fg = "Identifier" },
				cherryPickedCommitFgColor  = { fg = "Function" },
				defaultFgColor             = { fg = "Normal" },
				inactiveBorderColor        = { fg = "Comment" },
				optionsTextColor           = { fg = "Function" },
				searchingActiveBorderColor = { fg = "MatchParen", bold = true },
				selectedLineBgColor        = { bg = "Visual" },
				unstagedChangesColor       = { fg = "DiagnosticError" },
			}
		},
		picker = {
			icons = {
				files = {
					dir = icons.folder_close,
					dir_open = icons.folder_open,
					file = icons.file_unnamed
				},
				lsp = {
					attached = icons.lsp
				},
				tree = {
					vertical = "│ ",
					middle   = "├╴",
					last     = "╰╴",
				},
				ui = {
					unselected = "  "
				}
			},
			matcher = {
				cwd_bonus = true,
				frecency = true
			},
			sources = {
				explorer = {
					actions = {
						toggle_preview = function(picker) --[[Override]]
							picker.preview.win:toggle()
						end,
					},
					layout = {
						preset = 'sidebar',
						preview = false, ---@diagnostic disable-line
					},
					on_show = function(picker)
						local show = false
						local gap = 1
						local clamp_width = function(value)
							return math.max(20, math.min(100, value))
						end
						--
						local position = picker.resolved_layout.layout.position
						local rel = picker.layout.root
						local update = function(win) ---@param win snacks.win
							local border = win:border_size().left + win:border_size().right
							win.opts.row = vim.api.nvim_win_get_position(rel.win)[1]
							win.opts.height = 0.8
							if position == "left" then
								win.opts.col = vim.api.nvim_win_get_width(rel.win) + gap
								win.opts.width = clamp_width(vim.o.columns - border - win.opts.col)
							end
							if position == "right" then
								win.opts.col = -vim.api.nvim_win_get_width(rel.win) - gap
								win.opts.width = clamp_width(vim.o.columns - border + win.opts.col)
							end
							win:update()
						end
						local preview_win = require("snacks").win.new {
							relative = "editor",
							external = false,
							focusable = false,
							border = dotted_border,
							backdrop = false,
							show = show,
							bo = {
								filetype = "snacks_float_preview",
								buftype = "nofile",
								buflisted = false,
								swapfile = false,
								undofile = false,
							},
							on_win = function(win)
								update(win)
								picker:show_preview()
							end,
						}
						rel:on("WinLeave", function()
							vim.schedule(function()
								if not picker:is_focused() then
									picker.preview.win:close()
								end
							end)
						end)
						rel:on("WinResized", function()
							update(preview_win)
						end)
						picker.preview.win = preview_win
						picker.main = preview_win.win
					end,
					on_close = function(picker)
						picker.preview.win:close()
					end,
					win = {
						list = {
							keys = {
								["<ESC>"] = false
							}
						}
					}
				},
				grep = { layout = { preset = "ivy" }},
				grep_word = { layout = { preset = "ivy" }},
				highlights = { layout = { preset = "dropdown" }},
				icons = { layout = { preset = "select" }},
				jumps = { layout = { preset = "bottom" }},
				keymaps = { layout = { preset = "vertical" }},
				marks = { layout = { preset = "dropdown" }},
				projects = { patterns = { ".csproj", ".git", ".sln" } },
				smart = { layout = { preset = "vertical" }},
				undo = { layout = { preset = "dropdown" }},
			},
			win = {
				input = {
					keys = {
						["<C-q>"] = false,
						["<M-q>"] = { "qflist", mode = { "i", "n" } },
						["<C-s>"] = false,
						["<C-t>"] = false,
						["<C-u>"] = false,
						["<C-v>"] = false,
						["<M-s>"] = { "edit_split", mode = { "i", "n" } },
						["<M-t>"] = { "tab", mode = { "n", "i" } },
						["<M-v>"] = { "edit_vsplit", mode = { "i", "n" } },
					}
				},
				list = {
					keys = {
						["<C-q>"] = false,
						["<M-q>"] = { "qflist", mode = { "i", "n" } },
						["<C-s>"] = false,
						["<C-t>"] = false,
						["<C-u>"] = false,
						["<C-v>"] = false,
						["<M-s>"] = { "edit_split", mode = { "i", "n" } },
						["<M-t>"] = { "tab", mode = { "n", "i" } },
						["<M-v>"] = { "edit_vsplit", mode = { "i", "n" } },
					}
				}
			},
		},
		styles = {
			help = {
				zindex = zindices.snacks_help
			}
		}
	},
	config = function(_, cfg)
		require("snacks").setup(cfg)

		-- HACK: to fix windows path issues
		local actions = require("snacks.explorer.actions")
		actions.reveal_orig = actions.reveal
		actions.reveal = function(picker, path) ---@diagnostic disable-line: duplicate-set-field
			return actions.reveal_orig(picker, path:gsub("\\", "/"))
		end
	end
}

addPlugin {
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
	dependencies = "folke/snacks.nvim",
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
		{ "<C-R>", function() require("snacks").picker.yanky({ layout = { preset = "vertical" }}) end, mode = { "i" }, desc = "Yank text" }, ---@diagnostic disable-line: undefined-field
		{ "'", function() require("snacks").picker.yanky({ layout = { preset = "vertical" }}) end, mode = { "n" }, desc = "Yank text" }, ---@diagnostic disable-line: undefined-field
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

addPlugin {
	"luiscassih/AniMotion.nvim",
	config = function()
		local utils = require("AniMotion.Utils")
		require("AniMotion").setup({
			clear_keys = { "<Esc>" },
			color = { link = "IncSearch" },
			edit_keys = { "c", "d", "x" },
			map_visual = false,
			marks = { "y", "z" },
			mode = "animotion",
			word_keys = {
				[utils.Targets.NextLongWordEnd] = "E",
				[utils.Targets.NextLongWordStart] = "<S-Right>",
				[utils.Targets.NextWordEnd] = "e",
				[utils.Targets.NextWordStart] = "<C-Right>",
				[utils.Targets.PrevLongWordStart] = "<S-Left>",
				[utils.Targets.PrevWordStart] = "<C-Left>",
			},
		})
	end,
	keys = { "<C-Left>", "<C-Right>", "<S-Left>", "<S-Right>" }
}


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

addPlugin { -- FEAT: true-false
	"monaqa/dial.nvim",
	keys = {
		{ "<C-a>", "<Plug>(dial-increment)",    mode = { "n", "x" }, desc = "Increment" },
		{ "<C-x>", "<Plug>(dial-decrement)",    mode = { "n", "x" }, desc = "Decrement" },
		{ "g<C-a>", "<Plug>(dial-g-increment)", mode = { "n", "x" }, desc = "Increment (global)" },
		{ "g<C-x>", "<Plug>(dial-g-decrement)", mode = { "n", "x" }, desc = "Decrement (global)" },
	}
}

addPlugin {
	"rickhowe/wrapfiller",
	event = "DiffUpdated"
}

addPlugin {
	"rickhowe/spotdiff.vim",
	cmd = { "Diffthis", "VDiffthis"}
}

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
	cmd = "NoNeckPain",
	opts = {
		width = 105
	}
}

addPlugin {
	"smjonas/live-command.nvim",
	cmd = { "Preview", "Norm" },
	main = "live-command",
	opts = {
		commands = {
			Norm = { cmd = "norm" }
		}
	}
}
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

require("lazy").setup(plugins, lazy_config)
-- <~>
-- vim: fmr=</>,<~> fdm=marker textwidth=120 noexpandtab tabstop=2 shiftwidth=2
