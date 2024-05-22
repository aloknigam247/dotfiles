-- BUG: https://github.com/microsoft/terminal/issues/6987 https://www.reddit.com/r/neovim/comments/1ct8s6a/nvim_rendering_error_in_windows_ssh/
-- BUG: https://github.com/neovide/neovide/issues/2556
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Profiling   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- PERF: slow in PAGE UP/DOWN
-- ---@class Profile
-- ---@field cOunt integer Number of times an autOcommand is invoked
-- ---@field start number Start time of current autocommand
-- ---@field avg number Avergae time taken by autocommand
-- ---@field total number Total time taken by autocommand
-- ---@alias ProfileData table<string, Profile>
-- ---Constains Autocommand profiling data
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
-- 		data['count'] = (data.count or 0) + 1
-- 		data['start'] = os.clock()
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

-- 			data['avg'] = total / data.count
-- 			data['total'] = total

-- 			AuProfileData[args.event] = data
-- 		end
-- 	end
-- end

-- ---List of all valid autocommands to profile
-- ---@type string[]
-- local event_list = { "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "BufFilePre", "BufHidden", "BufLeave", "BufModifiedSet", "BufNew", "BufNewFile", "BufRead", "BufReadPre", "BufUnload", "BufWinEnter", "BufWinLeave", "BufWipeout", "BufWrite", "BufWritePost", "ChanInfo", "ChanOpen", "CmdUndefined", "CmdlineChanged", "CmdlineEnter", "CmdlineLeave", "CmdwinEnter", "CmdwinLeave", "ColorScheme", "ColorSchemePre", "CompleteChanged", "CompleteDone", "CompleteDonePre", "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI", "DiffUpdated", "DirChanged", "DirChangedPre", "ExitPre", "FileAppendPost", "FileAppendPre", "FileChangedRO", "FileChangedShell", "FileChangedShellPost", "FileReadPost", "FileReadPre", "FileType", "FileWritePost", "FileWritePre", "FilterReadPost", "FilterReadPre", "FilterWritePost", "FilterWritePre", "FocusGained", "FocusLost", "FuncUndefined", "InsertChange", "InsertCharPre", "InsertEnter", "InsertLeave", "InsertLeavePre", "MenuPopup", "ModeChanged", "OptionSet", "QuickFixCmdPost", "QuickFixCmdPre", "QuitPre", "RecordingEnter", "RecordingLeave", "RemoteReply", "SafeState", "SearchWrapped", "SessionLoadPost", "ShellCmdPost", "ShellFilterPost", "Signal", "SourcePost", "SourcePre", "SpellFileMissing", "StdinReadPost", "StdinReadPre", "SwapExists", "Syntax", "TabClosed", "TabEnter", "TabLeave", "TabNew", "TabNewEntered", "TermClose", "TermEnter", "TermLeave", "TermOpen", "TermResponse", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT", "TextYankPost", "UIEnter", "UILeave", "User", "VimEnter", "VimLeave", "VimLeavePre", "VimResized", "VimResume", "VimSuspend", "WinClosed", "WinEnter", "WinLeave", "WinNew", "WinResized", "WinScrolled" }

-- vim.api.nvim_create_autocmd(
-- 	event_list, {
-- 		desc = 'Autocommand profile init',
-- 		pattern = '*',
-- 		callback = auProfileStart
-- 	}
-- )

-- vim.api.nvim_create_user_command(
-- 	'ProfileAutocommand',
-- 	function()
-- 		vim.notify("Profiling started, stop by F6")
-- 		AuProfileEnabled = true
-- 		AuProfileData = {}
-- 		AuCallbackProfileData = {}

-- 		-- Autocommand to collect end data
-- 		vim.api.nvim_create_autocmd(
-- 			event_list, {
-- 				desc = 'Autocommand profile record',
-- 				pattern = '*',
-- 				callback = auProfileEnd
-- 			}
-- 		)

-- 		-- Mapping to stop autocommand profiling
-- 		vim.api.nvim_set_keymap('n', '<F6>', '', {
-- 			callback = function()
-- 				AuProfileEnabled = false
-- 				vim.cmd('profile stop')
-- 				vim.notify('Autocommand profiling stopped')
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

-- ---Create autocmd wrapper to emit perf telemtry
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

-- 					data['count']= (data.count or 0) + 1
-- 					data['avg'] = total / data.count
-- 					data['total'] = total
-- 					AuCallbackProfileData[arg.id] = data
-- 				end
-- 			end
-- 		end
-- 	end
-- 	vim.api.nvim_create_autocmd_orig(event, opts)
-- end

-- vim.api.nvim_create_autocmd_orig = vim.api.nvim_create_autocmd
-- vim.api.nvim_create_autocmd = nvimCreateAutocmdWrapper
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Configurations ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Variables</> -- FEAT: box comment
------------

---Shapes for dotted border
---@type string[]
local dotted_border = { '╭', '󰇘', '╮', '┆', '╯', '󰇘', '╰', '┆' }

---Defines highlight priorities for vairous components
---@type table<string, integer>
local hl_priority = {
	hlargs = 126,
	url = 202
}

---Defines Icons for global usage
---@type table<string, string>
local icons = {
	Array              = '󰅪 ',
	Boolean            = ' ',
	Class              = ' ',
	Color              = ' ',
	Component          = ' ',
	Constant           = ' ',
	Constructor        = ' ',
	Enum               = ' ',
	EnumMember         = ' ',
	Event              = ' ',
	Field              = ' ',
	File               = ' ',
	Folder             = '󰷏 ',
	Fragment           = ' ',
	Function           = ' ',
	History            = ' ',
	Interface          = ' ',
	Key                = ' ',
	Keyword            = ' ',
	Macro              = ' ',
	Method             = ' ',
	Module             = ' ',
	Namespace          = '󰘦 ',
	Null               = '󰢤 ',
	Number             = ' ',
	Object             = ' ',
	Operator           = ' ',
	Options            = ' ',
	Package            = ' ',
	Parameter          = ' ',
	Property           = ' ',
	Reference          = ' ',
	Snippet            = ' ',
	StaticMethod       = '󰡱 ',
	String             = ' ',
	Struct             = ' ',
	Text               = '󱄽 ',
	TypeAlias          = ' ',
	TypeParameter      = ' ',
	Unit               = ' ',
	Value              = ' ',
	Variable           = ' ',
	bookmark           = '󰃃',
	bookmark_annotate  = '󰃄',
	border_botleft     = '╰',
	border_botright    = '╯',
	border_hor         = '─',
	border_topleft     = '╭',
	border_topright    = '╮',
	border_vert        = '│',
	code_action        = ' ',
	diagnostic         = ' ',
	diff_add           = '│',
	diff_change        = '┊',
	diff_change_delete = '~',
	diff_delete        = '',
	diff_delete_top    = '‾',
	error              = ' ',
	file_modified      = '',
	file_newfile       = '',
	file_readonly      = '',
	file_unnamed       = '',
	hint               = ' ',
	hover              = ' ',
	incoming           = ' ',
	info               = ' ',
	outgoing           = ' ',
	preview            = ' ',
	symlink_arrow      = ' 壟 ',
	warn               = ' ',
	warning            = ' ',
	fold_open          = '',
	fold_close        = '',
	folder_open = '',
	folder_close = '',
}

---Defines highlight for kinds
---@type table<string, table>
local kind_hl = {
	Array         = { icon  = ' ' , dark = { bg = '#F42272', fg = '#000000' }, light = { bg = '#0B6E4F', fg = '#FFFFFF' } },
	Boolean       = { icon  = ' ' , dark = { bg = '#B8B8F3', fg = '#000000' }, light = { bg = '#69140E', fg = '#FFFFFF' } },
	Class         = { icon  = ' ' , dark = { bg = '#519872', fg = '#000000' }, light = { bg = '#1D3557', fg = '#FFFFFF' } },
	Color         = { icon  = ' ' , dark = { bg = '#A4B494', fg = '#000000' }, light = { bg = '#FA9F42', fg = '#000000' } },
	Constant      = { icon  = ' ' , dark = { bg = '#C5E063', fg = '#000000' }, light = { bg = '#744FC6', fg = '#FFFFFF' } },
	Constructor   = { icon  = ' ' , dark = { bg = '#4AAD52', fg = '#000000' }, light = { bg = '#755C1B', fg = '#FFFFFF' } },
	Enum          = { icon  = ' ' , dark = { bg = '#E3B5A4', fg = '#000000' }, light = { bg = '#A167A5', fg = '#000000' } },
	EnumMember    = { icon  = ' ' , dark = { bg = '#AF2BBF', fg = '#FFFFFF' }, light = { bg = '#B80C09', fg = '#FFFFFF' } },
	Event         = { icon  = ' ' , dark = { bg = '#6C91BF', fg = '#000000' }, light = { bg = '#53A548', fg = '#000000' } },
	Field         = { icon  = ' ' , dark = { bg = '#5BC8AF', fg = '#000000' }, light = { bg = '#E2DC12', fg = '#000000' } },
	File          = { icon  = ' ' , dark = { bg = '#EF8354', fg = '#000000' }, light = { bg = '#486499', fg = '#FFFFFF' } },
	Folder        = { icon  = ' ' , dark = { bg = '#BFC0C0', fg = '#000000' }, light = { bg = '#A74482', fg = '#FFFFFF' } },
	Function      = { icon  = ' ' , dark = { bg = '#E56399', fg = '#000000' }, light = { bg = '#228CDB', fg = '#000000' } },
	History       = { icon  = ' ' , dark = { bg = '#C2F8CB', fg = '#000000' }, light = { bg = '#85CB33', fg = '#000000' } },
	Interface     = { icon  = ' ' , dark = { bg = '#8367C7', fg = '#000000' }, light = { bg = '#537A5A', fg = '#FFFFFF' } },
	Key           = { icon  = ' ' , dark = { bg = '#D1AC00', fg = '#000000' }, light = { bg = '#645DD7', fg = '#FFFFFF' } },
	Keyword       = { icon  = ' ' , dark = { bg = '#20A4F3', fg = '#000000' }, light = { bg = '#E36414', fg = '#000000' } },
	Method        = { icon  = ' ' , dark = { bg = '#D7D9D7', fg = '#000000' }, light = { bg = '#197278', fg = '#FFFFFF' } },
	Module        = { icon  = ' ' , dark = { bg = '#F2FF49', fg = '#000000' }, light = { bg = '#EC368D', fg = '#000000' } },
	Namespace     = { icon  = 'ﬥ ' , dark = { bg = '#FF4242', fg = '#000000' }, light = { bg = '#2F9C95', fg = '#000000' } },
	Null          = { icon  = ' ' , dark = { bg = '#C1CFDA', fg = '#000000' }, light = { bg = '#56666B', fg = '#FFFFFF' } },
	Number        = { icon  = ' ' , dark = { bg = '#FB62F6', fg = '#000000' }, light = { bg = '#A5BE00', fg = '#000000' } },
	Object        = { icon  = ' ' , dark = { bg = '#F18F01', fg = '#000000' }, light = { bg = '#80A1C1', fg = '#000000' } },
	Operator      = { icon  = ' ' , dark = { bg = '#048BA8', fg = '#000000' }, light = { bg = '#F1DB4B', fg = '#000000' } },
	Options       = { icon  = ' ' , dark = { bg = '#99C24D', fg = '#000000' }, light = { bg = '#2292A4', fg = '#FFFFFF' } },
	Package       = { icon  = ' ' , dark = { bg = '#AFA2FF', fg = '#000000' }, light = { bg = '#B98EA7', fg = '#000000' } },
	Property      = { icon  = ' ' , dark = { bg = '#CED097', fg = '#000000' }, light = { bg = '#3777FF', fg = '#000000' } },
	Reference     = { icon  = ' ' , dark = { bg = '#1B2CC1', fg = '#FFFFFF' }, light = { bg = '#18A999', fg = '#000000' } },
	Snippet       = { icon  = ' ' , dark = { bg = '#7692FF', fg = '#000000' }, light = { bg = '#BF0D4B', fg = '#FFFFFF' } },
	String        = { icon  = ' ' , dark = { bg = '#FEEA00', fg = '#000000' }, light = { bg = '#D5573B', fg = '#000000' } },
	Struct        = { icon  = ' ' , dark = { bg = '#D81159', fg = '#FFFFFF' }, light = { bg = '#75485E', fg = '#FFFFFF' } },
	Text          = { icon  = ' ' , dark = { bg = '#0496FF', fg = '#000000' }, light = { bg = '#5762D5', fg = '#FFFFFF' } },
	TypeParameter = { icon  = ' ' , dark = { bg = '#FFFFFC', fg = '#000000' }, light = { bg = '#5D2E8C', fg = '#FFFFFF' } },
	Unit          = { icon  = ' ' , dark = { bg = '#C97B84', fg = '#000000' }, light = { bg = '#FF6666', fg = '#000000' } },
	Value         = { icon  = ' ' , dark = { bg = '#C6DDF0', fg = '#000000' }, light = { bg = '#2EC4B6', fg = '#000000' } },
	Variable      = { icon  = ' ' , dark = { bg = '#B7ADCF', fg = '#000000' }, light = { bg = '#548687', fg = '#FFFFFF' } }
}

---Global keymaps
---@type table<string, string>
local keymaps = {
	open_split = '<C-s>',
	open_tab = '<C-t>',
	open_vsplit = '<C-v>',
}

local lazy_config = {
	root = vim.fn.stdpath('data') .. '/lazy', -- directory where plugins will be installed
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
		version = nil,
		cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
		-- version = '*', -- enable this to try installing the latest stable versions of plugins
	},
	spec = nil, ---@type LazySpec
	lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json', -- lockfile generated after update.
	git = {
		log = { '-10' }, -- show the last 10 commits
		timeout = 12000, -- kill processes that take more than 2 minutes
		url_format = 'https://github.com/%s.git',
		filter = false,
	},
	dev = {
		path = '~/projects',
		---@type string[] plugins that match these patterns will use your local versions instead
		patterns = {}, -- For example {'folke'}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},
	install = {
		missing = true,
		colorscheme = { 'retrobox' },
	},
	ui = {
		size = { width = 0.8, height = 0.8 },
		wrap = true, -- wrap the lines in the ui
		border = 'rounded',
		title = nil, ---@type string only works when border is not 'none'
		title_pos = 'center', ---@type 'center' | 'left' | 'right'
		-- Show pills on top of the Lazy window
		pills = true, ---@type boolean
		icons = {
			cmd        = '',
			config     = '',
			event      = '',
			ft         = '',
			init       = '',
			import     = '󰋺',
			keys       = '',
			lazy       = ' ',
			list       = { '󰬺', ' 󰬻', '󰬼', '󰬽', '󰬾', '󰬿', '󰭀', '󰭁', '󰭂', '󰿩' },
			loaded     = '',
			not_loaded = '',
			plugin     = '',
			runtime    = '',
			source     = '',
			start      = '',
			task       = ''
		},
		browser = nil, ---@type string?
		throttle = 20, -- how frequently should the ui process render events
		custom_keys = {
			['<localleader>l'] = function(plugin)
				require('lazy.util').float_term({ 'lazygit', 'log' }, {
					cwd = plugin.dir,
				})
			end,
			['<localleader>t'] = function(plugin)
				require('lazy.util').float_term(nil, {
					cwd = plugin.dir,
				})
			end,
		},
	},
	diff = {
		cmd = 'git',
	},
	checker = {
		enabled = false,
		concurrency = nil, ---@type number? set to 1 to check for updates very slowly
		notify = true, -- get a notification when new updates are found
		frequency = 3600, -- check for updates every hour
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
				'csv',
				'editorconfig',
				'gzip',
				'man',
				'matchit',
				'matchparen',
				'netrwPlugin',
				'rplugin',
				'shada',
				'spellfile',
				'tarPlugin',
				'tohtml',
				'tutor',
				'zipPlugin',
			},
		},
	},
	readme = {
		enabled = true,
		root = vim.fn.stdpath('state') .. '/lazy/readme',
		files = { 'README.md', 'lua/**/README.md' },
		skip_if_doc_exists = true,
	},
	state = vim.fn.stdpath('state') .. '/lazy/state.json', -- state info for checker and other things
	profiling = {
		-- Enables extra stats on the debug tab related to the loader cache.
		-- Additionally gathers stats about all package.loaders
		loader = true,
		-- Track each new require in the Lazy profiling tab
		require = true,
	},
}

---@class Plugin
---@type Plugin[] List of plugins
local plugins = {}

---@class PopupMenu
---@field cond fun() Condition to evaluate for PopUp menu
---@field opts string[][] Config options
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
	default = { 'Identifier', '#7C3AED' },
	docs    = { 'Function', '#440381' },
	error   = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
	feat    = { 'Type', '#274C77' },
	hint    = { 'DiagnosticHint', '#10B981' },
	info    = { 'DiagnosticInfo', '#2563EB' },
	perf    = { 'String', '#C2F970' },
	test    = { 'Identifier', '#DDD92A' },
	todo    = { 'Todo', 'Keyword', '#1B998B' },
	warn    = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' }
}

local todo_config = {
	DOCS   = { icon = '', color = 'docs', alt = { 'DOCME' } },
	FEAT   = { icon = '󱩑', color = 'feat' },
	FIX    = { icon = '󰠭', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }},
	HACK   = { icon = '󰑶', color = 'hint' },
	NOTE   = { icon = '', color = 'info', alt = { 'INFO', 'THOUGHT' } },
	PERF   = { icon = '󰅒', color = 'perf', alt = { 'OPTIMIZE', 'PERFORMANCE' } },
	RECODE = { icon = '', color = 'info', alt = { 'REFACTOR' } },
	TEST   = { icon = '', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
	TODO   = { icon = '󰸞', color = 'todo' },
	WARN   = { icon = '!', color = 'warn', alt = { 'WARNING' } },
}

LargeFile = {}
-- <~>
-- Functions</>
------------

---Generates color palette for dark and light mode
---@return { bg: string, fg: string }[] # List of _nvim_set_hl()_ supported color config
function ColorPalette()
	if vim.o.background == 'light' then
		return {
			{ bg = '#000000', fg = '#78b98f' },
			{ bg = '#FFFFFF', fg = '#2524f9' },
			{ bg = '#000000', fg = '#fd048f' },
			{ bg = '#FFFFFF', fg = '#0b6d33' },
			{ bg = '#000000', fg = '#5ac230' },
			{ bg = '#000000', fg = '#3d8bb7' },
			{ bg = '#FFFFFF', fg = '#710c9e' },
			{ bg = '#000000', fg = '#f38ab6' },
			{ bg = '#FFFFFF', fg = '#3a3079' },
			{ bg = '#000000', fg = '#eb67f9' },
			{ bg = '#FFFFFF', fg = '#0c4152' },
			{ bg = '#000000', fg = '#6d7ddb' },
			{ bg = '#FFFFFF', fg = '#9b1b5c' },
			{ bg = '#000000', fg = '#d4a07f' },
			{ bg = '#FFFFFF', fg = '#5f2e0d' },
			{ bg = '#000000', fg = '#fd2c3b' },
			{ bg = '#FFFFFF', fg = '#900e08' },
			{ bg = '#000000', fg = '#ea6b12' },
			{ bg = '#FFFFFF', fg = '#464a15' },
			{ bg = '#000000', fg = '#daa218' },
		}
	end
	-- dark mode
	return {
		{ bg = '#FFFFFF', fg = '#8138fc' },
		{ bg = '#000000', fg = '#f3d426' },
		{ bg = '#000000', fg = '#68affc' },
		{ bg = '#000000', fg = '#fda547' },
		{ bg = '#FFFFFF', fg = '#516a9c' },
		{ bg = '#000000', fg = '#47faf4' },
		{ bg = '#000000', fg = '#399283' },
		{ bg = '#000000', fg = '#a2e67c' },
		{ bg = '#000000', fg = '#598322' },
		{ bg = '#000000', fg = '#bfdad4' },
		{ bg = '#000000', fg = '#21a708' },
		{ bg = '#000000', fg = '#44f270' },
		{ bg = '#FFFFFF', fg = '#565bd9' },
		{ bg = '#000000', fg = '#fcc2fb' },
		{ bg = '#FFFFFF', fg = '#c20da6' },
		{ bg = '#000000', fg = '#bd7ab4' },
		{ bg = '#000000', fg = '#fe79ec' },
		{ bg = '#FFFFFF', fg = '#876341' },
		{ bg = '#000000', fg = '#dc3c07' },
		{ bg = '#000000', fg = '#fa557a' },
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

		local ignore_filetype = { 'NvimTree' }
		local filetype = vim.api.nvim_get_option_value( 'filetype', { buf = bufnr })
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

---Light or dark color
---@param col string Color to shade
---@param amt integer Amount of shade
---@return string # Color in hex format
function LightenDarkenColor(col, amt)
	local num = tonumber(col, 16)
	local r = bit.rshift(num, 16) + amt
	local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
	local g = bit.band(num, 0x0000FF) + amt
	local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))
	local hex_code = string.format("#%-6X", newColor)
	local res = hex_code:gsub(' ', '0')
	return res
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
	if (vim.o.background == 'dark') then
		bg = vim.api.nvim_get_hl(0, { name = 'Normal', create = false }).bg or 0
		bg = string.format('%X', bg)
		bg = LightenDarkenColor(bg, lighten)
	else
		bg = vim.api.nvim_get_hl(0, { name = 'Normal', create = false }).bg or 16777215
		bg = string.format('%X', bg)
		bg = LightenDarkenColor(bg, darken)
	end
	return bg
end

---Get list filetypes/extentions for Treesitter languages installed
---@param map_entension boolean Convert filetype to extension
---@return string[] # List of filetypes or extensions
local function getTSInstlled(map_entension)
	if Installed_filetypes then
		return Installed_filetypes
	end

	Installed_filetypes = {}
	local filetye_map = {
		['python'] = 'py'
	}

	for file, _ in vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath('data'), '/lazy/nvim-treesitter/parser')) do
		if file:sub(-3) == '.so' then
			local ftype = file:gsub('.so', '')
			if map_entension then
				ftype = filetye_map[ftype] or ftype
			end
			table.insert(Installed_filetypes, ftype)
		end
	end

	return Installed_filetypes
end

---Check if LSP is attached to current buffer
---@return boolean # true if LSP is attached
local function isLspAttached()
	return #vim.lsp.get_clients({bufnr = 0}) ~= 0
end

--- Check if buffer is a large file
---@param bufId? integer buf id
---@return boolean # true if buffer is large file
local function isLargeFile(bufId)
	---@diagnostic disable-next-line: param-type-mismatch
	bufId = bufId or vim.fn.bufnr('%')
	-- return true
	return LargeFile[bufId] ~= nil
end

---Safe alternative to `nvim_open_win()`
---@param bufnr integer Buffer to display, or 0 for current buffer
---@param enter boolean Enter the window (make it the current window)
---@param config? table `nvim_open_win()` config
---@return integer # Window handle, or 0 on error
local function nvimOpenWinSafe(bufnr, enter, config)
	local fixTitle = function(title)
		if title[1] ~= ' ' then
			title = ' ' .. title
		end
		if title[#title] ~= ' ' then
			title = title .. ' '
		end
		return title
	end

	if config then
		-- Add margin to title
		if config.title then
			local title = config.title
			if type(title) == 'string' then
				config.title = fixTitle(title)
			elseif type(title) == 'table' then
				config.title[1][1] = fixTitle(config.title[1][1])
			end
		end

		-- Fix height
		if config.row and config.width and config.width > 1 then
			local editor_bottom = vim.o.lines - 1
			local window_bottom = config.row + config.height + 2
			local shift = window_bottom - editor_bottom
			if shift > 0 then
				-- config.row = math.max(0, config.row - shift) -- shift row up
				window_bottom = config.row + config.height + 2
				config.height = math.min(config.height, vim.o.lines - 3)
			end
		end

		-- Fix width
		if config.col and config.width and config.width > 1 then
			local editor_col = vim.o.columns
			local window_col = config.col + config.width + 2
			local shift = window_col - editor_col
			if shift > 0 then
				-- config.col = math.max(0, config.col - shift) -- shift row up
				window_col = config.col + config.width + 2
				config.width = math.min(config.width, vim.o.columns - 2)
			end
		end
	end

	return vim.api.nvim_open_win_orig(bufnr, enter, config)
end
vim.api.nvim_open_win_orig = vim.api.nvim_open_win
vim.api.nvim_open_win = nvimOpenWinSafe

---Open file in floating window
---@param path string File path
---@param relativity string Relaive postion of window
---@param col_offset integer Column offset
---@param row_offset integer Row offset
---@param enter boolean Enter into window on creation
local function openFloat(path, relativity, col_offset, row_offset, enter, split, vsplit)
	-- Create buffer
	local bufnr = vim.fn.bufadd(path)

	if not bufnr then
		return
	end

	-- Create floating window
	if Preview_win == nil then
		Preview_win = vim.api.nvim_open_win(bufnr, enter, {
			border = 'rounded',
			col = col_offset,
			footer = ' [C-s] split [M-v] vsplit [C-t] tab open ',
			footer_pos = 'right',
			height = vim.o.lines - 8,
			relative = relativity,
			row = row_offset,
			title = path ,
			title_pos = 'center',
			width = vim.o.columns - 8 - col_offset,
			zindex = 1
		})
	else
		vim.api.nvim_win_set_buf(Preview_win, bufnr)
	end

	-- Create autocommand to resize window
	local au_id = vim.api.nvim_create_autocmd('VimResized', {
		pattern = '*',
		desc = 'Resize preview window on vim resize',
		callback = function()
			local cfg = vim.api.nvim_win_get_config(Preview_win)
			vim.api.nvim_win_set_config(Preview_win, {
				height = vim.o.lines - 8,
				width = vim.o.columns - 8 - cfg.col[false]
			})
		end
	})

	-- Cleanup on window close
	vim.api.nvim_create_autocmd('WinClosed', {
		pattern = tostring(Preview_win),
		desc = 'Delete resize autocommand on Preview window close',
		callback = function(arg)
			Preview_win = nil
			vim.api.nvim_del_autocmd(au_id)
			vim.api.nvim_buf_del_keymap(arg.buf, 'n', '<C-s>')
			vim.api.nvim_buf_del_keymap(arg.buf, 'n', '<C-t>')
			vim.api.nvim_buf_del_keymap(arg.buf, 'n', '<M-v>')
			return true
		end
	})

	-- Reopen preview in split
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-s>', '', {
		callback = split or function()
			local file_path = vim.fn.expand('%:p')
			vim.cmd.quit()
			vim.cmd.split(file_path)
		end,
		desc = 'reopen Preview window in split',
		nowait = true,
		noremap = true,
		silent = true
	})

	-- Reopen preview in vsplit
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-v>', '', {
		callback = vsplit or function()
			local file_path = vim.fn.expand('%:p')
			vim.cmd.quit()
			vim.cmd.vsplit(file_path)
		end,
		desc = 'reopen Preview window in split',
		nowait = true,
		noremap = true,
		silent = true
	})

	-- Reopen preview in tab
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-t>', '', {
		callback = function()
			local file_path = vim.fn.expand('%:p')
			vim.cmd.quit()
			vim.cmd.tabedit(file_path)
		end,
		desc = 'reopen Preview window in split',
		nowait = true,
		noremap = true,
		silent = true
	})
end

--- Create popup menu when invoked
local function popupAction()
	-- local currentWindow = vim.api.nvim_get_current_win()
	-- local cursorPos = vim.api.nvim_win_get_cursor(currentWindow)
	vim.cmd('aunmenu PopUp') -- Clear popup menu

	-- Fill popup options
	for _,menu in pairs(pop_up_menu) do
		if menu.cond() then
			for _,opt in pairs(menu.opts) do
				local title = opt[1]
				local action = opt[2]
				title = title:gsub(' ', '\\ ')
				vim.cmd.nnoremenu('PopUp.' .. title .. ' ' .. action)
			end
		end
	end
end

---Add a popup menu
---@param menu PopupMenu Popup menu
local function popupMenuAdd(menu)
	table.insert(pop_up_menu, menu)
end
-- <~>
-- Auto Commands</>
-- -------------
vim.api.nvim_create_autocmd(
	'BufEnter', {
		pattern = '*',
		desc = 'Open directory in nvim-tree',
		callback = function(arg)
			local path = vim.fn.expand('%:p')
			if vim.fn.isdirectory(path) ~= 0 then
				require("nvim-tree.api").tree.open({path = path})
				return true
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	{ 'BufNewFile', 'BufRead' }, {
		pattern = '*',
		desc = 'Run for new files',
		callback = function ()
			local buf_name = vim.fn.expand('%:t')
			if string.lower(buf_name) == 'todo' then
				vim.o.filetype = 'todo'
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	'BufWinEnter', {
		pattern = '*',
		desc = 'Detect large files and disable slow plugins',
		callback = function(arg)
			local fsize = vim.fn.getfsize(vim.fn.expand('%:p'))
			if fsize > 170000 then
				LargeFile[arg.buf] = true
				vim.b[arg.buf].minihipatterns_disable = true -- disable mini.hipatterns
				require('illuminate').pause_buf()
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	'BufWinEnter', {
		pattern = '*',
		desc = 'Overlength line marker',
		callback = function()
			if not isLargeFile() and vim.bo.textwidth > 0 then
				for _, line in ipairs(vim.fn.getbufline(vim.api.nvim_get_current_buf(), 1, 100)) do
					local line_length = #line
					if line_length > 300 then
						return
					end
				end
				vim.api.nvim_set_hl(0, 'Overlength', { bg = adaptiveBG(70, -70) })
				vim.cmd('match Overlength /\\%' .. vim.bo.textwidth + 2 .. 'v/')
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	'BufWinEnter', {
		pattern = '*',
		desc = 'Disable wrap for file with long lines',
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
	'BufWritePre', {
		pattern = '*',
		desc = 'Create directory if it does not exists',
		callback = function()
			--  -- Function gets a table that contains match key, which maps to `<amatch>` (a full filepath).
			-- local dirname = vim.fs.dirname(t.match)
			-- -- Attempt to mkdir. If dir already exists, it returns nil.
			-- -- Use 755 permissions, which means rwxr.xr.x
			-- vim.loop.fs_mkdir(dirname, tonumber("0755", 8))
			local filedir = vim.fn.expand('%:p:h')
			if vim.fn.isdirectory(filedir) == 0 then
				vim.fn.mkdir(filedir, 'p')
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	'CmdlineEnter', {
		pattern = { '/', '?' },
		desc = 'Shift commandline for search',
		callback = function(arg)
			vim.cmd('set cmdheight=1')
		end
	}
)

vim.api.nvim_create_autocmd(
	'CmdlineLeave', {
		pattern = { '/', '?' },
		desc = 'Shift commandline back for search',
		callback = function(arg)
			vim.cmd('set cmdheight=0')
		end
	}
)

vim.api.nvim_create_autocmd(
	'CursorHold', {
		pattern = '*',
		desc = 'Load Treesitter on CursorHold for installed languages',
		callback = function(arg)
			local ftype = vim.o.filetype
			if vim.tbl_contains(getTSInstlled(false), ftype) then
				vim.cmd('Lazy load nvim-treesitter')
				vim.api.nvim_exec_autocmds('User', { pattern = 'TSLoaded' })
				return true
			end
		end
	}
)

vim.api.nvim_create_autocmd(
	'MenuPopup', {
		pattern = 'n',
		desc = 'Create popup menu based on context',
		callback = popupAction
	}
)

vim.api.nvim_create_autocmd(
	'TextYankPost', {
		pattern = '*',
		desc = 'Highlight text on yank',
		callback = function()
			vim.highlight.on_yank({ higroup="Search", timeout=500 })
		end
	}
)

vim.api.nvim_create_autocmd(
	'User', {
		pattern = 'VeryLazy',
		desc = 'Lazy load clipboard provider',
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
-- https://github.com/backdround/neowords.nvim
-- https://github.com/chaoren/vim-wordmotion
-- https://github.com/chrisgrieser/nvim-spider
-- vip select paragraph
-- FEAT: visual motion mappings
-- FEAT: [q ]q for jumping in quickfix
-- FEAT: mapping to delete word on <C-Del>
-- FEAT: use <C-w> to save
-- TODO: recheck word-motions help and reassign mappings
vim.keymap.set('i', '<C-BS>',      '<C-w>',                    { desc = 'Delete a word backword' })
vim.keymap.set('i', '<C-Left>',    '<C-\\><C-O>b',             { desc = 'Move a word backword' }) -- BUG: escaping while moving create problem in LSP
vim.keymap.set('i', '<C-Right>',   '<C-\\><C-O>e<C-\\><C-O>a', { desc = 'Move a word forward' }) -- BUG: escaping while moving create problem in LSP
vim.keymap.set('i', '<C-S-Left>',  '<C-\\><C-O>B',             { desc = 'Move a larger word backword' })
vim.keymap.set('i', '<C-S-Right>', '<C-\\><C-O>E<C-\\><C-O>a', { desc = 'Move a larger word forward' })
vim.keymap.set('n', '!!',          ':<Up><CR>',                { desc = 'Run last command' })
vim.keymap.set('n', '<BS>',        'X',                        { desc = 'Delete a letter backword' })
vim.keymap.set('n', '<C-Left>',    'b',                        { desc = 'Move a word backword' })
vim.keymap.set('n', '<C-Q>',       '<cmd>q<CR>',               { desc = 'Close window' })
vim.keymap.set('n', '<C-Right>',   'e',                        { desc = 'Move a word forward' })
vim.keymap.set('n', '<C-S-Left>',  'B',                        { desc = 'Move a larger word forward' })
vim.keymap.set('n', '<C-S-Right>', 'E',                        { desc = 'Move a larger word backword' })
vim.keymap.set('n', '<C-Tab>',     '<cmd>tabnext<CR>',         { desc = 'Move to next tab' })
vim.keymap.set('n', '<X1Mouse>',   '<C-o>',                    { desc = 'Jump forward' })
vim.keymap.set('n', '<X2Mouse>',   '<C-i>',                    { desc = 'Jump backword' })
vim.keymap.set('n', '_',           '<cmd>resize<CR>',          { desc = 'Make current window height maximum' })
vim.keymap.set('n', '|',           '<cmd>vertical-resize<CR>', { desc = 'Make current window width maximum' })
vim.keymap.set('x', '/',           '<Esc>/\\%V',               { desc = 'Search in select region' })
-- <~>
-- Misc</>
-------
vim.diagnostic.config({
	float = {
		source = 'if_many',
	},
	severity_sort = true,
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
		end,
		source = 'if_many'
	}
})

vim.cmd('sign define DiagnosticSignError text=' .. icons.error .. ' texthl=DiagnosticSignError linehl= numhl=')
vim.cmd('sign define DiagnosticSignWarn  text=' .. icons.warn  .. ' texthl=DiagnosticSignWarn  linehl= numhl=')
vim.cmd('sign define DiagnosticSignInfo  text=' .. icons.info  .. ' texthl=DiagnosticSignInfo  linehl= numhl=')
vim.cmd('sign define DiagnosticSignHint  text=' .. icons.hint  .. ' texthl=DiagnosticSignHint  linehl= numhl=')

vim.highlight.priorities = {
	syntax = 50,
	treesitter = 100,
	semantic_tokens = 125,
	diagnostics = 150,
	user = 200
}

-- Lazy load notify
--[[vim.notify = function(...)
	require('notify')
	vim.notify(...)
end]]

-- Lazy load dressing
vim.ui.select = function(...)
	require('dressing')
	vim.ui.select(...)
end

-- Lazy load dressing
vim.ui.input = function(...)
	require('dressing')
	vim.ui.input(...)
end

vim.api.nvim_set_hl(0, 'HighlightURL', { underline = true })
vim.fn.matchadd(
	'HighlightURL',
	"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+",
	202
)

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--single-branch',
		'https://github.com/folke/lazy.nvim.git',
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)
-- <~>
-- Commands</>
-----------
--[[
	FEAT: create command
	command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_
		\ | diffthis | wincmd p | diffthis
--]]
vim.api.nvim_create_user_command(
	'DropbarToggle',
	function()
		if DropbarEnabled == nil then
			require('dropbar')
		end
		DropbarEnabled = not DropbarEnabled
	end,
	{}
)

vim.api.nvim_create_user_command(
	'Peek',
	function(args)
		openFloat(args.args, 'editor', 8, 3, true)
	end,
	{
		complete = 'file',
		nargs = 1
	}
)
-- <~>
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Aligns     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'dhruvasagar/vim-table-mode',
	cmd = 'TableModeEnable'
}

-- 'echasnovski/mini.align'

addPlugin {
	'junegunn/vim-easy-align',
	cmd = 'EasyAlign'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Auto Pairs   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	-- https://github.com/altermo/ultimate-autopair.nvim
	-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pairs.md
	-- https://github.com/m4xshen/autoclose.nvim
	'windwp/nvim-autopairs',
	config = function()
		local pair = require('nvim-autopairs')
		local Rule = require('nvim-autopairs.rule')
		local cond = require('nvim-autopairs.conds')

		pair.setup()
		-- pair.add_rules(require('nvim-autopairs.rules.endwise-lua'))
		pair.add_rules {
			-- #include <|> pair for c and cpp
			Rule('#include <', '>', { 'c', 'cpp' }),
			-- Add spaces in pair after parentheses
			-- (|) --> space --> ( | )
			-- ( | ) --> ) --> ( )|
			Rule(' ', ' ', '-markdown')
			:with_pair(function (opts)
				local pair_set = opts.line:sub(opts.col - 1, opts.col)
				return vim.tbl_contains({ '()', '[]', '{}' }, pair_set)
			end)
			:with_del(cond.none()),
			Rule('( ', ' )')
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match('.%)') ~= nil
			end)
			:use_key(')'),
			Rule('{ ', ' }')
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match('.%}') ~= nil
			end)
			:use_key('}'),
			Rule('[ ', ' ]')
			:with_pair(function() return false end)
			:with_move(function(opts)
				return opts.prev_char:match('.%]') ~= nil
			end)
			:use_key(']'),
			-- Auto add space on =
			Rule('=', '')
			:with_pair(cond.not_inside_quote())
			:with_pair(function(opts)
				local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
				if last_char:match('[%w%=%s]') then
					return true
				end
				return false
			end)
			:replace_endpair(function(opts)
				local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
				local next_char = opts.line:sub(opts.col, opts.col)
				next_char = next_char == ' ' and '' or ' '
				if prev_2char:match('%w$') then
					return '<bs> =' .. next_char
				end
				if prev_2char:match('%=$') then
					return next_char
				end
				if prev_2char:match('=') then
					return '<bs><bs>=' .. next_char
				end
				return ''
			end)
			:set_end_pair_length(0)
			:with_move(cond.none())
			:with_del(cond.none())
		}
		-- Insert `()` after select function or method item
		local cmp_autopairs = require('nvim-autopairs.completion.cmp')
		local cmp = require('cmp')
		cmp.event:on(
			'confirm_done',
			cmp_autopairs.on_confirm_done()
		)
	end,
	event = 'InsertEnter'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Code Map    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/dstein64/nvim-scrollview
addPlugin {
	'echasnovski/mini.map',
	config = function()
		local minimap = require('mini.map')
		minimap.setup({
			integrations = {
				minimap.gen_integration.builtin_search(),
				minimap.gen_integration.gitsigns(),
				minimap.gen_integration.diagnostic(),
			},
			symbols = {
				encode = minimap.gen_encode_symbols.dot('4x2')
			},
			window = {
				show_integration_count = true
			}
		})
	end
}

addPlugin {
	'gorbit99/codewindow.nvim',
	opts = {
		exclude_filetypes = {},
		window_border = 'single',
		use_lsp = true,
		use_treesitter = true,
		use_git = true,
	}
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Coloring    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	-- https://github.com/FluxxField/bionic-reading.nvim
	-- https://github.com/nullchilly/fsread.nvim
	'JellyApple102/easyread.nvim',
	cmd = 'EasyreadToggle',
	opts = {
		hlValues = {
			['1'] = 1,
			['2'] = 1,
			['3'] = 2,
			['4'] = 2,
			['fallback'] = 0.4
		},
		hlgroupOptions = { bold = true },
		fileTypes = {},
		saccadeInterval = 0,
		saccadeReset = false,
		updateWhileInsert = true
	}
}

-- 'azabiong/vim-highlighter'
addPlugin {
	'Pocco81/high-str.nvim',
	keys = {
		{ '<Leader>l', '<Cmd>HSHighlight<CR>', mode = 'x', desc = 'add highlight' },
		{ '<Leader>L', '<Cmd>HSRmHighlight<CR>', mode = 'n', desc = 'remove highlight' },
	}
}

addPlugin {
	'RRethy/vim-illuminate',
	config = function()
		require('illuminate').configure({
			delay = 400,
			min_count_to_highlight = 2,
			modes_allowlist = {'i', 'n'},
			case_insensitive_regex = false,
			providers = {
				'lsp',
				'treesitter',
				'regex'
			}
		})
		vim.keymap.set('n', ']i', require('illuminate').goto_next_reference, { desc = 'Jump to next illuminated text' })
		vim.keymap.set('n', '[i', require('illuminate').goto_prev_reference, { desc = 'Jump to previous illuminated text' })
		vim.api.nvim_set_hl(0, 'IlluminatedWordText', { bg = adaptiveBG(40, -40) })
		vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { bg = '#8AC926', fg = '#FFFFFF', bold = true })
		vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { bg = '#FF595E', fg = '#FFFFFF', italic = true })
	end,
	event = { 'CursorHold' }
}

addPlugin {
	'echasnovski/mini.hipatterns',
	config = function()
		require('mini.hipatterns').setup({
		highlighters = (function()
			local config = {}

			---Get TODO highlights
			---@param set string Matched text
			---@return string? # Highlight for matched string
			local function getTodo(set)
				local color_set = todo_colors[set] or todo_colors.default

				for _, hl in pairs(color_set) do
					-- create new highlight if its a color
					if hl:sub(1, 1) == '#' then
						vim.api.nvim_set_hl(0, 'TodoHl' .. set, { fg = hl, force = true })
						return 'TodoHl' .. set
					end

					local hl_config = vim.api.nvim_get_hl(0, { name = hl, link = false })
					if not vim.tbl_isempty(hl_config) then
						if hl_config.undercurl == true then
							vim.api.nvim_set_hl(0, 'TodoHl' .. set, { fg = hl_config.sp, force = true })
							return 'TodoHl' .. set
						end
						return hl
					end
				end

				return nil
			end

			-- iterate for each config in todo_config
			for i,v in pairs(todo_config) do
				local keys = v.alt or {}
				table.insert(keys, i) -- add alt keys as well

				local hl_group = getTodo(v.color)
				for _,l in pairs(keys) do
					local key = l:lower()
					local cfg = { group = hl_group, pattern = '%f[%w]' .. l .. ':%W' }
					config[key] = cfg
				end
			end

			return config
		end)()
	})
	end,
	event = 'CursorHold'
}

addPlugin {
	'folke/paint.nvim',
	event = 'CursorHold *.lua,*.py',
	opts = {
		highlights = {
			{ filter = { filetype = 'lua' },    pattern = '━.*━',               hl = "Constant", },
			{ filter = { filetype = 'lua' },    pattern = '%s*%-%-%-%s*(@%w+)', hl = "Constant", },
			{ filter = { filetype = 'python' }, pattern = '    [%a%d_]+: ',     hl = '@parameter' },
			{ filter = { filetype = 'python' }, pattern = 'Args:',              hl = '@type' },
			{ filter = { filetype = 'python' }, pattern = 'Returns:',           hl = '@keyword' },
			{ filter = { filetype = 'python' }, pattern = 'Raises:',            hl = 'Statement' },
		}
	}
}

addPlugin {
	'folke/todo-comments.nvim',
	config = function()
		require('todo-comments').setup({
			colors = todo_colors,
			highlight = { pattern = [[(KEYWORDS):\W]] },
			keywords = todo_config,
			merge_keywords = false
		})
		TODO_COMMENTS_LOADED = true
	end,
	dependencies = { 'luukvbaal/statuscol.nvim' },
	keys = {
		{ '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous TODO' },
		{ ']t', function() require('todo-comments').jump_next() end, desc = 'Next TODO' }
	}
}

addPlugin {
	'brenoprata10/nvim-highlight-colors',
	cmd = 'HighlightColors',
	opts = { render = 'background' }
}

addPlugin {
	'nvim-zh/colorful-winsep.nvim',
	config = function()
		require('colorful-winsep').setup({
			symbols = {
				icons.border_hor,
				icons.border_vert,
				icons.border_topleft,
				icons.border_topright,
				icons.border_botleft,
				icons.border_botright,
			},
		})

		local utils = require('colorful-winsep.utils')
		utils.direction_have_orig = utils.direction_have
		utils.direction_have = function(direction)
			if CountWindows(false) > 2 then
				return utils.direction_have_orig(direction)
			end
			return false
		end
	end,
	event = 'WinNew'
}

addPlugin {
	't9md/vim-quickhl',
	config = function()
		local colors = {}
		for _,v in pairs(ColorPalette()) do
			local hi = 'guifg=' .. v.bg .. ' guibg=' .. v.fg
			table.insert(colors, hi)
		end
		vim.g.quickhl_manual_colors = colors
	end,
	keys = {
		{ '<Leader>w', '<Plug>(quickhl-manual-this-whole-word)', mode = 'n', desc = 'toggle quickhl for word' },
		{ '<Leader>w', '<Plug>(quickhl-manual-this)',            mode = 'x', desc = 'toggle quickhl for selection' },
		{ '<Leader>W', '<Plug>(quickhl-manual-reset)',           mode = 'n', desc = 'remove all quickhl' }
	}
}

-- 'yuki-yano/highlight-undo.nvim',
addPlugin {
	'tzachar/highlight-undo.nvim',
	config = true,
	keys = { 'u' },
	lazy = true
}

-- 'uga-rosa/ccc.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Colorscheme   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
---Fix LineNr highlight
---@param fg string fg color in hex
local function fixLineNr(fg)
	vim.api.nvim_set_hl(0, 'LineNr', { fg = fg })
end

--- Fix oxocarbon colorscheme
local function fixOxocarbon()
	vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#2A9D8F', nocombine = true })
	vim.api.nvim_set_hl(0, 'DiffChange', { fg = '#540D6E', nocombine = true })
	vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#EE4266', nocombine = true })
end

--- Fix retrobox colorscheme
local function fixRetro()
	vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#B8BB26', nocombine = true })
	vim.api.nvim_set_hl(0, 'DiffChange', { fg = '#8EC07C', nocombine = true })
	vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#FB4934', nocombine = true })
	vim.api.nvim_set_hl(0, 'Todo', { fg = '#8EC07C', nocombine = true })
end

---Fix Visual highlight
---@param bg? string bg color in hex
local function fixVisual(bg)
	bg = bg or adaptiveBG(50, -20)
	vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
end

--- Fix ayu colorscheme
local function fixAyu()
	vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitSignsAddLn' })
	vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'GitSignsDeleteLn' })
	vim.api.nvim_set_hl(0, 'LspInlayHint', { link = 'Comment' })
end

--- Fix material colorscheme
local function fixMaterial()
	vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#91B859', nocombine = true })
	vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#E53935', nocombine = true })
	fixVisual('#CCEAE7')
end

--- Fix sherbet colorscheme
local function fixSherbet()
	vim.api.nvim_set_hl(0, 'LspInlayHint', { link = 'Comment', force = true })
end

---Fix vn-night colorscheme
local function fixVnNight()
	fixLineNr('#505275')
	vim.api.nvim_set_hl(0, 'Comment', { fg = '#7F82A5', italic = true })
	vim.api.nvim_set_hl(0, 'Folded', { bg = '#112943', fg = '#8486A4' })
end

---@class ColorPlugin
---@field [1] string name of colorscheme
---@field [2] string event name to trigger
---@field bg? "dark"|"light" background theme of colorscheme
---@field cfg? table config to pass setup function
---@field post? fun():nil function to call after applying colorscheme
---@field pre? fun():nil function to call before applying colorscheme
---@field trans? boolean enable transparent mode
--- List of color plugins
---@type ColorPlugin[]
local colos = {}

---Add a color scheme
---@param opts ColorPlugin Color config
local function colorPlugin(opts)
	if opts.cfg then
		local cfg = opts.cfg
		local mod
		if #cfg == 2 then
			---@diagnostic disable-next-line: need-check-nil
			mod = cfg[1]
			---@diagnostic disable-next-line: need-check-nil
			cfg = cfg[2]
		else
			if opts[2] == '_' then
				mod = opts[1]
			else
				mod = opts[2]
			end
		end

		opts.pre = function()
			require(mod).setup(cfg)
		end
	end
	table.insert(colos, opts)
end

---Add a dark plugin
---@param opts ColorPlugin Color config
local function dark(opts)
	opts.bg = 'dark'
	colorPlugin(opts)
end

---Add a transparent dark plugin
---@param opts ColorPlugin Color config
local function darkT(opts)
	opts.trans = true
	dark(opts)
end

---Add a light plugin
---@param opts ColorPlugin Color config
local function light(opts)
	opts.bg = 'light'
	colorPlugin(opts)
end

---Add a transparent light plugin
---@param opts ColorPlugin Color config
local function lightT(opts)
	opts.trans = true
	dark(opts)
end

addPlugin { 'Shatur/neovim-ayu',                   event = 'User ayu'                                                   }
addPlugin { 'ribru17/bamboo.nvim',                 event = 'User bamboo'                                                }
addPlugin { 'uloco/bluloco.nvim',                  event = 'User bluloco',   dependencies = 'rktjmp/lush.nvim'          }
addPlugin { 'catppuccin/nvim',                     event = 'User catppuccin'                                            }
addPlugin { 'scottmckendry/cyberdream.nvim',       event = 'User cyberdream'                                            }
addPlugin { 'kaplanz/deku.nvim',                   event = 'User deku',      dependencies = 'rktjmp/lush.nvim'          }
addPlugin { 'sainnhe/edge',                        event = 'User edge'                                                  }
addPlugin { 'sainnhe/everforest',                  event = 'User everforest'                                            }
addPlugin { 'comfysage/evergarden',                event = 'User evergarden'                                            }
addPlugin { 'projekt0n/github-nvim-theme',         event = 'User github-theme'                                          }
addPlugin { 'HoNamDuong/hybrid.nvim',              event = 'User hybrid'                                                }
addPlugin { 'kaiuri/nvim-juliana',                 event = 'User juliana'                                               }
addPlugin { 'rebelot/kanagawa.nvim',               event = 'User kanagawa'                                              }
addPlugin { 'marko-cerovac/material.nvim',         event = 'User material'                                              }
addPlugin { 'savq/melange',                        event = 'User melange'                                               }
addPlugin { 'mellow-theme/mellow.nvim',            event = 'User mellow'                                                }
addPlugin { 'xero/miasma.nvim',                    event = 'User miasma'                                                }
addPlugin { 'fynnfluegge/monet.nvim',              event = 'User monet'                                                 }
addPlugin { 'polirritmico/monokai-nightasty.nvim', event = 'User monokai-nightasty'                                     }
addPlugin { 'EdenEast/nightfox.nvim',              event = 'User nightfox'                                              }
addPlugin { 'AlexvZyl/nordic.nvim',                event = 'User nordic'                                                }
addPlugin { 'dgox16/oldworld.nvim',                event = 'User oldworld'                                              }
addPlugin { 'navarasu/onedark.nvim',               event = 'User onedark'                                               }
addPlugin { 'rmehri01/onenord.nvim',               event = 'User onenord'                                               }
addPlugin { 'nyoom-engineering/oxocarbon.nvim',    event = 'User oxocarbon'                                             }
addPlugin { 'lewpoly/sherbet.nvim',                event = 'User sherbet'                                               }
addPlugin { 'sainnhe/sonokai',                     event = 'User sonokai'                                               }
addPlugin { 'loganswartz/sunburn.nvim',            event = 'User sunburn', dependencies = 'loganswartz/polychrome.nvim' }
addPlugin { 'folke/tokyonight.nvim',               event = 'User tokyonight'                                            }
addPlugin { 'nxvu699134/vn-night.nvim',            event = 'User vn-night'                                              }
addPlugin { 'Mofiqul/vscode.nvim',                 event = 'User vscode'                                                }
addPlugin { 'titanzero/zephyrium',                 event = 'User zephyrium'                                             }

dark  { 'ayu-dark',                   'ayu',          post = fixAyu                                                                }
light { 'ayu-light',                  'ayu',          post = fixAyu                                                                }
dark  { 'ayu-mirage',                 'ayu',          post = fixAyu                                                                }
dark  { 'bamboo',                     '_',            cfg = { style = 'multiplex' }                                                }
darkT { 'bamboo',                     '_',            cfg = { style = 'multiplex', transparent = true }                            }
light { 'bluloco',                    '_'                                                                                          }
dark  { 'bluloco',                    '_'                                                                                          }
darkT { 'bluloco',                    '_',            cfg = { transparent = true }                                                 }
light { 'catppuccin-latte',           'catppuccin'                                                                                 }
dark  { 'catppuccin-macchiato',       'catppuccin'                                                                                 }
darkT { 'cyberdream',                 '_'                                                                                          }
lightT{ 'cyberdream',                 '_',            cfg = { theme = { variant = 'light' } }                                      }
dark  { 'deku',                       '_'                                                                                          }
dark  { 'duskfox',                    'nightfox'                                                                                   }
darkT { 'duskfox',                    'nightfox',     cfg = { transparent = true }                                                 }
light { 'edge',                       '_'                                                                                          }
dark  { 'everforest',                 '_'                                                                                          }
dark  { 'evergarden',                 '_'                                                                                          }
darkT { 'evergarden',                 '_',            cfg = { transparent_background = true }                                      }
dark  { 'github_dark',                'github-theme'                                                                               }
darkT { 'github_dark',                'github-theme', cfg = { options = { transparent = true } }                                   }
darkT { 'github_dark_colorblind',     'github-theme', cfg = { options = { transparent = true } }                                   }
dark  { 'github_dark_default',        'github-theme'                                                                               }
darkT { 'github_dark_default',        'github-theme', cfg = { options = { transparent = true } }                                   }
dark  { 'github_dark_high_contrast',  'github-theme'                                                                               }
dark  { 'github_dark_tritanopia',     'github-theme'                                                                               }
darkT { 'github_dark_tritanopia',     'github-theme', cfg = { options = { transparent = true } }                                   }
light { 'github_light',               'github-theme'                                                                               }
light { 'github_light_default',       'github-theme'                                                                               }
light { 'github_light_tritanopia',    'github-theme'                                                                               }
dark  { 'hybrid',                     '_'                                                                                          }
darkT { 'hybrid',                     '_',            cfg = { transparent = true }                                                 }
dark  { 'juliana',                    '_',            post = function() fixLineNr('#999999') end                                   }
dark  { 'kanagawa-wave',              'kanagawa'                                                                                   }
darkT { 'kanagawa-wave',              'kanagawa',     cfg = { transparent = true }                                                 }
light { 'material',                   '_',            pre = function() vim.g.material_style = 'lighter' end, post = fixMaterial    } -- FIX: Visual
dark  { 'melange',                    '_'                                                                                          }
dark  { 'mellow',                     '_'                                                                                          }
dark  { 'monet',                      '_'                                                                                          }
darkT { 'monet',                      '_',            cfg = { transparent_background = true }                                      }
light { 'monet',                      '_',            cfg = { dark_mode = false }                                                  }
light { 'monokai-nightasty',          '_'                                                                                          }
dark  { 'nordic',                     '_',            cfg = { override = { IblScope = { fg = '#7E8188' } } }                       }
dark  { 'oldworld',                   '_'                                                                                          }
dark  { 'onedark',                    '_',            cfg = { style = 'cool' }                                                     }
darkT { 'onedark',                    '_',            cfg = { style = 'cool', transparent = true }                                 }
dark  { 'onedark',                    '_',            cfg = { style = 'dark' }                                                     }
darkT { 'onedark',                    '_',            cfg = { style = 'dark', transparent = true }                                 }
dark  { 'onedark',                    '_',            cfg = { style = 'darker' }                                                   }
darkT { 'onedark',                    '_',            cfg = { style = 'darker', transparent = true }                               }
dark  { 'onedark',                    '_',            cfg = { style = 'deep' }                                                     }
darkT { 'onedark',                    '_',            cfg = { style = 'deep', transparent = true }                                 }
light { 'onedark',                    '_',            cfg = { style = 'light' }                                                    }
dark  { 'onedark',                    '_',            cfg = { style = 'warm' }                                                     }
darkT { 'onedark',                    '_',            cfg = { style = 'warm', transparent = true }                                 }
dark  { 'onedark',                    '_',            cfg = { style = 'warmer' }                                                   }
darkT { 'onedark',                    '_',            cfg = { style = 'warmer', transparent = true }                               }
light { 'onenord',                    '_'                                                                                          }
light { 'oxocarbon',                  '_',            post = fixOxocarbon                                                          }
dark  { 'retrobox',                   '_',            post = fixRetro                                                              }
dark  { 'sherbet',                    '_',            pre = function() vim.g.sherbet_italic_comments = true end, post = fixSherbet }
dark  { 'sonokai',                    '_',            pre = function() vim.g.sonokai_style = 'shusia' end                          }
dark  { 'sunburn',                    '_',                                                                                         }
dark  { 'tokyonight-storm',           'tokyonight'                                                                                 }
darkT { 'tokyonight-storm',           'tokyonight',   cfg = { transparent = true }                                                 }
dark  { 'vn-night',                   '_',            post = fixVnNight                                                            }
dark  { 'vscode',                     '_'                                                                                          } -- TODO: fix TODO hl
light { 'vscode',                     '_'                                                                                          } -- TODO: fix TODO hl
dark  { 'zephyrium',                  '_'                                                                                          }

---Random colorscheme
---@param scheme_index? integer Index of colorscheme
function ColoRand(scheme_index)
	math.randomseed(os.time())
	scheme_index = scheme_index or math.random(1, #colos)
	local selection = colos[scheme_index]
	local scheme = selection[1]
	local bg = selection.bg
	local event = selection[2]
	local precmd = selection.pre
	local postcmd = selection.post

	vim.o.background = bg
	vim.g.neovide_transparency = selection.trans and 0.8 or 1

	local start_time = os.clock()
	vim.api.nvim_exec_autocmds('User', { pattern = event == '_' and scheme or event })

	if (precmd) then
		precmd()
	end

	vim.cmd.colorscheme(scheme)
	vim.cmd('highlight clear CursorLine')

	if (postcmd) then
		postcmd()
	end

	local elapsed = string.format(":%.0fms", (os.clock() - start_time)*1000)
	vim.g.ColoRand = scheme_index .. ':' .. scheme .. ':' .. bg .. ':' .. event .. elapsed

	-- Fix Todo highlight
	local todo_hl = vim.api.nvim_get_hl(0, { name = 'Todo', create = false })
	if todo_hl and todo_hl.bg then
		todo_hl.fg = todo_hl.bg
		todo_hl.bg = nil
		vim.api.nvim_set_hl(0, 'Todo', todo_hl)
	end
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Comments    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- FEAT: setup
-- FEAT: better command
addPlugin {
	'LudoPinelli/comment-box.nvim'
}

addPlugin {
	'numToStr/Comment.nvim',
	config = function()
		require('Comment').setup({
			ignore = '^$',
			extra = { eol = 'gce' },
		})

		require('Comment.ft')
		.set('ps1', {'# %s', '<# %s #>'})
		.set('python', {'# %s', '""" %s """'})
		.set('requirements', {'# %s'})
	end,
	keys = {
		{ 'gc', mode = { 'n', 'v' } },
		{ 'gb', mode = { 'n', 'v' } },
		'gcc', 'gbc', 'gcO', 'gco', 'gce'
	}
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Completion   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/hrsh7th/cmp-omni
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/uga-rosa/cmp-dynamic

addPlugin {
	'aloknigam247/cmp-path',
	event = 'CmdlineChanged'
}

addPlugin {
	'dcampos/cmp-snippy',
	dependencies = 'nvim-snippy',
	event = 'InsertEnter'
}

addPlugin {
	'hrsh7th/cmp-cmdline',
	event = 'CmdlineChanged'
}

addPlugin {
	'hrsh7th/cmp-nvim-lsp',
	event = 'LspAttach'
}

-- addPlugin {
--     'paopaol/cmp-doxygen',
--     event = 'InsertEnter *.cc,*.cpp,*.c,*.h'
-- }

addPlugin {
	'hrsh7th/nvim-cmp',
	config = function()
		local cmp = require('cmp')
		cmp.setup({
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{
						name = 'path',
						option = {
							trailing_slash = true
						}
					},
					{
						name = 'cmdline',
						option = {
							-- ignore_cmds = { 'split' }
						}
					}
				}
			}),
			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = 'buffer' } }
			}),
			autocomplete = false,
			completion = {
				-- completeopt = 'menu,menuone,noselect',
				keyword_length = 2
			},
			experimental = {
				ghost_text = true
			},
			formatting = {
				expandable_indicator = true,
				fields = { 'kind', 'abbr', 'menu' },
				format = function(entry, vim_item)
					local source_name = entry.source.name
					if entry.source.name == 'nvim_lsp' then
						source_name = '󰈸 ' .. entry.source.source.client.name
					elseif entry.source.name == 'cmdline' then
						vim_item.kind = 'Options'
						source_name = '󰸶 options'
					elseif entry.source.name == 'cmdline_history' then
						vim_item.kind = 'History'
						source_name = '󰋚 history'
					elseif entry.source.name == 'path' then
						source_name = ' path'
					elseif entry.source.name == 'snippy' then
						source_name = ' snippet'
					else
						source_name = '󰙩 ' .. entry.source.name
					end
					vim_item.menu = source_name
					local kind_symbol = ' ' .. icons[vim_item.kind]
					vim_item.kind = kind_symbol or vim_item.kind

					return vim_item
				end
			},
			matching = {
				disallow_fuzzy_matching = false,
				disallow_partial_matching = false,
				disallow_fullfuzzy_matching = false,
				disallow_prefix_unmatching = false,
			},
			mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
				['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Scroll the documentation window if visible
				['<C-d>'] = cmp.mapping.scroll_docs(4), -- Scroll the documentation window if visible
				['<C-e>'] = cmp.mapping.abort(),
				['<TAB>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
			}),
			preselect = cmp.PreselectMode.Item,
			snippet = {
				expand = function(args)
					require('snippy').expand_snippet(args.body)
				end
			},
			sources = {
				{
					name = 'nvim_lsp',
					entry_filter = function(entry, _)
						return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
					end
				},
				{
					name = 'buffer',
					option = {
						-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disable--enable-cmp-sources-only-on-certain-buffers
						get_bufnrs = function()
							return vim.api.nvim_list_bufs()
						end
					},
				},
				{
					name = 'path',
					trigger_characters = { './', '/', '.\\' },
					option = {
						trailing_slash = true
					}
				},
				{ name = 'snippy' },
			},
			window = {
				completion = {
					side_padding = 0
				},
				documentation = cmp.config.window.bordered(),
			},
			view = {
				docs = {
					auto_open = true
				},
				entries = {
					follow_cursor = true
				}
			}
		})

		for key, value in pairs(kind_hl) do
			vim.api.nvim_set_hl(0, 'CmpItemKind' .. key, value[vim.o.background])
		end
		vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { strikethrough = true })
		vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bold = true })
		vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { underline = true })
	end,
	dependencies = {
		'hrsh7th/cmp-buffer',
	},
	event = 'VeryLazy',
}

-- https://github.com/L3MON4D3/cmp-luasnip-choice
-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Debugger    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'LiadOz/nvim-dap-repl-highlights',
	config = true
}

addPlugin {
	'andrewferrier/debugprint.nvim',
	dependencies = { 'echasnovski/mini.comment' },
	lazy = true,
	opts = {
		filetypes = {
			['python'] = {
				left = 'print("',
				left_var = 'print(f"',
				mid_var = '{',
				right = '")  # noqa',
				right_var = '}")',
			}
		},
		keymaps = {
			normal = {
				plain_below = '<Leader>dp',
				plain_above = '<Leader>dP',
				variable_below = '<Leader>dv',
				variable_above = '<Leader>dV',
				variable_below_alwaysprompt = '<Leader>dw',
				variable_above_alwaysprompt = '<Leader>dW',
				textobj_below = nil,
				textobj_above = nil,
				toggle_comment_debug_prints = '<Leader>dc',
				delete_debug_prints = '<Leader>dd',
			},
			visual = {
				variable_below = '<Leader>dv',
				variable_above = '<Leader>dV',
			}
		},
		commands = {
			toggle_comment_debug_prints = nil,
			delete_debug_prints = nil
		}
	},
	keys = {
	'<Leader>dc', '<Leader>dd', '<Leader>dp', '<Leader>dP', '<Leader>dw', '<Leader>dW',
	{ '<Leader>dv', mode = { 'n', 'v' } },
	{ '<Leader>dV', mode = { 'n', 'v' } }
	}
}

addPlugin {
	'jbyuki/one-small-step-for-vimkind',
	config = function()
		local dap = require('dap')
		dap.configurations.lua = {
			{
				type = 'nlua',
				request = 'attach',
				name = 'Attach to running Neovim instance',
			}
		}

		dap.adapters.nlua = function(callback, config)
			callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
		end
	end,
	lazy = true
}

addPlugin {
	'mfussenegger/nvim-dap',
	config = function()
		vim.api.nvim_set_keymap('n', '<F8>', [[:lua require("dap").toggle_breakpoint()<CR>]], { noremap = true })
		vim.api.nvim_set_keymap('n', '<F9>', [[:lua require("dap").continue()<CR>]], { noremap = true })
		vim.api.nvim_set_keymap('n', '<F10>', [[:lua require("dap").step_over()<CR>]], { noremap = true })
		vim.api.nvim_set_keymap('n', '<F11>', [[:lua require("dap").step_into()<CR>]], { noremap = true })
		vim.api.nvim_set_keymap('n', '<F12>', [[:lua require("dap.ui.widgets").hover()<CR>]], { noremap = true })
		vim.api.nvim_set_keymap('n', '<F5>', [[:lua require("osv").launch({port = 8086})<CR>]], { noremap = true })

		-- vim.cmd[[
		--     nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
		--     nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
		--     nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
		--     nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
		--     nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
		--     nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
		--     nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
		--     nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
		--     nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
		-- ]]

		vim.api.nvim_set_hl(0, 'DapBreakpointFgHl', { fg = '#D21401' })
		vim.api.nvim_set_hl(0, 'DapBreakpointBgHl', { bg = '#D21401', fg = '#FFFFFF' })
		vim.api.nvim_set_hl(0, 'DapStoppedFgHl', { fg = '#FFBF00' })
		vim.api.nvim_set_hl(0, 'DapStoppedBgHl', { bg = '#FFBF00', fg = '#FFFFFF' })

		vim.fn.sign_define('DapBreakpoint', { text='', texthl='DapBreakpointFgHl', linehl='DapBreakpointBgHl', numhl='' })
		vim.fn.sign_define('DapBreakpointCondition', { text='', texthl='DapBreakpointFgHl', linehl='', numhl='' })
		vim.fn.sign_define('DapLogPoint', { text='', texthl='', linehl='DapBreakpointFgHl', numhl='' })
		vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpointFgHl', linehl='', numhl='' })
		vim.fn.sign_define('DapStopped', { text='', texthl='DapStoppedFgHl', linehl='DapStoppedBgHl', numhl='' })
	end,
	lazy = true
}

-- https://github.com/ofirgall/goto-breakpoints.nvim

addPlugin {
	'rcarriga/nvim-dap-ui',
	config = function()
		require("dapui").setup()
		require("dapui").open()
	end,
	dependencies = {
		'nvim-neotest/nvim-nio'
	}
}

-- https://github.com/PatschD/zippy.nvim
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/jay-babu/mason-nvim-dap.nvim
-- https://github.com/jonboh/nvim-dap-rr
-- https://github.com/nvim-telescope/telescope-dap.nvim
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'mfussenegger/nvim-dap-python'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Doc Generater  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'danymat/neogen',
	cmd = 'Neogen',
	opts = {
		input_after_comment = true,
		placeholders_hl = 'None',
		placeholders_text = {
			['description'] = '[DOCME' .. ': description]',
			['tparam'] = '[DOCME' .. ': tparam]',
			['parameter'] = '[DOCME' .. ': parameter]',
			['return'] = '[DOCME' .. ': return]',
			['class'] = '[DOCME' .. ': class]',
			['throw'] = '[DOCME' .. ': throw]',
			['varargs'] = '[DOCME' .. ': varargs]',
			['type'] = '[DOCME' .. ': type]',
			['attribute'] = '[DOCME' .. ': attribute]',
			['args'] = '[DOCME' .. ': args]',
			['kwargs'] = '[DOCME' .. ': kwargs]',
		},
		snippet_engine = 'snippy'
	}
}
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ File Explorer  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/nat-418/scamp.nvim
-- https://github.com/nosduco/remote-sshfs.nvim
addPlugin {
	'nvim-tree/nvim-tree.lua',
	cmd = 'NvimTreeOpen',
	dependencies = {
		'b0o/nvim-tree-preview.lua',
		'antosha417/nvim-lsp-file-operations'
	},
	opts = {
		actions = {
			change_dir = {
				enable = true,
				global = false,
				restrict_above_cwd = false,
			},
			expand_all = {
				exclude = { '.git' },
				max_folder_discovery = 300,
			},
			file_popup = {
				open_win_config = {
					border = 'rounded',
					col = 1,
					relative = 'cursor',
					row = 1,
					style = 'minimal',
				},
			},
			open_file = {
				quit_on_open = false,
				resize_window = true,
				window_picker = {
					chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
					enable = true,
					exclude = {
						buftype = { 'nofile', 'terminal', 'help' },
						filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
					},
					picker = 'default',
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
			dotfiles = false,
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
			prefix = '󰈲 ',
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
			vim.wo.statuscolumn = ''

			--- Common optios with description
			---@param desc string description
			---@return table # common options with description
			local function opts(desc)
			  return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			--- Preview for NvimTree
			local function custom_preview()
				local node = require("nvim-tree.lib").get_node_at_cursor()
				if node.name == ".." then
					require("nvim-tree.actions.root.change-dir").fn ".."
				elseif node.nodes then
					require("nvim-tree.lib").expand_or_collapse(node)
				else
					local path = node.absolute_path
					if node.link_to and not node.nodes then
					  path = node.link_to
					end

					openFloat(
						path,
						'editor',
						vim.fn.winwidth(0) + 2,
						3,
						false,
						function()
							vim.cmd.quit()
							require('nvim-tree.api').node.open.horizontal()
						end,
						function()
							vim.cmd.quit()
							require('nvim-tree.api').node.open.vertical()
						end
					)
				end
			end

			local api = require('nvim-tree.api')
			vim.keymap.set('n', '-',              api.tree.change_root_to_parent,     opts('Up'))
			vim.keymap.set('n', '<',              api.node.navigate.sibling.prev,     opts('Previous Sibling'))
			vim.keymap.set('n', '<2-LeftMouse>',  api.node.open.edit,                 opts('Open'))
			vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node,       opts('CD'))
			vim.keymap.set('n', '<C-e>',          api.node.open.replace_tree_buffer,  opts('Open: In Place'))
			vim.keymap.set('n', '<C-s>',          api.node.open.horizontal,           opts('Open: Horizontal Split'))
			vim.keymap.set('n', '<C-t>',          api.node.open.tab,                  opts('Open: New Tab'))
			vim.keymap.set('n', '<C-v>',          api.node.open.vertical,             opts('Open: Vertical Split'))
			vim.keymap.set('n', '<CR>',           api.node.open.edit,                 opts('Open'))
			vim.keymap.set('n', '<F2>',           api.fs.rename_sub,                  opts('Rename: Omit Filename'))
			vim.keymap.set('n', '<Leader>h',      api.node.show_info_popup,           opts('Info'))
			vim.keymap.set('n', '<Tab>',          custom_preview,                     opts('Open Preview'))
			vim.keymap.set('n', '>',              api.node.navigate.sibling.next,     opts('Next Sibling'))
			vim.keymap.set('n', '[c',             api.node.navigate.git.prev,         opts('Prev Git'))
			vim.keymap.set('n', '[d',             api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
			vim.keymap.set('n', ']c',             api.node.navigate.git.next,         opts('Next Git'))
			vim.keymap.set('n', ']d',             api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
			vim.keymap.set('n', 'a',              api.fs.create,                      opts('Create'))
			vim.keymap.set('n', 'bd',             api.marks.bulk.delete,              opts('Delete Bookmarked'))
			vim.keymap.set('n', 'bm',             api.marks.toggle,                   opts('Toggle Bookmark'))
			vim.keymap.set('n', 'bmv',            api.marks.bulk.move,                opts('Move Bookmarked'))
			vim.keymap.set('n', 'c',              api.fs.copy.node,                   opts('Copy'))
			vim.keymap.set('n', 'd',              api.fs.remove,                      opts('Delete'))
			vim.keymap.set('n', 'D',              api.fs.trash,                       opts('Trash'))
			vim.keymap.set('n', 'E',              api.tree.expand_all,                opts('Expand All'))
			vim.keymap.set('n', 'F',              api.live_filter.clear,              opts('Clean Filter'))
			vim.keymap.set('n', 'f',              api.live_filter.start,              opts('Filter'))
			vim.keymap.set('n', 'g?',             api.tree.toggle_help,               opts('Help'))
			vim.keymap.set('n', 'gy',             api.fs.copy.absolute_path,          opts('Copy Absolute Path'))
			vim.keymap.set('n', 'H',              api.tree.toggle_hidden_filter,      opts('Toggle Filter: Dotfiles'))
			vim.keymap.set('n', 'I',              api.tree.toggle_gitignore_filter,   opts('Toggle Filter: Git Ignore'))
			vim.keymap.set('n', 'o',              api.node.open.edit,                 opts('Open'))
			vim.keymap.set('n', 'O',              api.node.open.no_window_picker,     opts('Open: No Window Picker'))
			vim.keymap.set('n', 'p',              api.fs.paste,                       opts('Paste'))
			vim.keymap.set('n', 'P',              require('nvim-tree-preview').watch, opts('Toggle Preview'))
			vim.keymap.set('n', 'q',              api.tree.close,                     opts('Close'))
			vim.keymap.set('n', 'r',              api.fs.rename,                      opts('Rename'))
			vim.keymap.set('n', 'R',              api.tree.reload,                    opts('Refresh'))
			vim.keymap.set('n', 's',              api.node.run.system,                opts('Run System'))
			vim.keymap.set('n', 'S',              api.tree.search_node,               opts('Search'))
			vim.keymap.set('n', 'U',              api.tree.toggle_custom_filter,      opts('Toggle Filter: Hidden'))
			vim.keymap.set('n', 'W',              api.tree.collapse_all,              opts('Collapse'))
			vim.keymap.set('n', 'x',              api.fs.cut,                         opts('Cut'))
			vim.keymap.set('n', 'y',              api.fs.copy.filename,               opts('Copy Name'))
			vim.keymap.set('n', 'Y',              api.fs.copy.relative_path,          opts('Copy Relative Path'))
		end,
		prefer_startup_root = false,
		reload_on_bufenter = false,
		renderer = {
			add_trailing = true,
			full_name = true,
			group_empty = false,
			highlight_git = true,
			highlight_diagnostics = true,
			highlight_opened_files = 'all',
			highlight_modified = 'all',
			highlight_bookmarks = 'all',
			highlight_clipboard = 'name',
			indent_markers = {
				enable = true,
				icons = {
					bottom = '─',
					corner = '╰',
					edge   = '│',
					item   = '⎬',
					none   = ' ',
				},
				inline_arrows = true,
			},
			indent_width = 2,
			root_folder_label = ':~:s?$?/..?',
			icons = {
				bookmarks_placement = 'signcolumn',
				diagnostics_placement = 'after',
				git_placement = 'signcolumn',
				glyphs = {
					bookmark = icons.bookmark,
					default  = icons.file_unnamed,
					folder = {
						arrow_closed = icons.fold_close,
						arrow_open   = icons.fold_open,
						default      = icons.folder_close,
						empty        = '',
						empty_open   = '',
						open         = icons.folder_open,
						symlink      = '',
						symlink_open = '',
					},
					git = {
						deleted   = '󰧧',
						ignored   = ' ',
						renamed   = '➜',
						staged    = '⏽',
						unmerged  = '',
						unstaged  = '󰇝',
						untracked = icons.file_unnamed,
					},
					symlink = '󱅷',
				},
				modified_placement = 'after',
				padding = ' ',
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
			special_files = { 'Makefile', 'README.md', 'TODO.md', 'readme.md' },
			symlink_destination = true,
		},
		respect_buf_cwd = false,
		root_dirs = {},
		select_prompts = false,
		sort_by = 'name',
		sync_root_with_cwd = true,
		system_open = {
			cmd = '',
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
			cmd = 'gio trash',
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
			adaptive_size = false,
			centralize_selection = false,
			cursorline = false,
			float = {
				enable = false,
				open_win_config = {
					border = 'rounded',
					col = 1,
					height = 30,
					relative = 'editor',
					row = 1,
					width = 30,
				},
				quit_on_focus_loss = true,
			},
			number = false,
			preserve_window_proportions = false,
			relativenumber = false,
			side = 'left',
			signcolumn = 'yes',
			width = 30,
		},
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  File Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
---Set highlight for markdown headings
function MarkdownHeadingsHighlight()
	local title1_hl = vim.api.nvim_get_hl(0, { name = '@text.title.1.markdown', link = false })
	local title2_hl = vim.api.nvim_get_hl(0, { name = '@text.title.2.markdown', link = false })
	if title1_hl and title2_hl and title1_hl.fg ~= title2_hl.fg then
		return
	end

	local palette = ColorPalette()
	for i = 1,6 do
		local hl = { fg = palette[i].fg }
		vim.api.nvim_set_hl(0, '@text.title.' .. i .. '.markdown', hl)
		vim.api.nvim_set_hl(0, '@text.title.' .. i .. '.marker.markdown', hl)
	end
end

FileTypeActions = {
	['NvimTree'] = function(_)
		vim.cmd('setlocal statuscolumn=')
	end,
	['csv'] = function(_)
		vim.cmd('set textwidth=0')
	end,
	['neotest-summary'] = function(_)
		vim.cmd.setlocal('nowrap')
	end,
	['markdown'] = function(_)
		vim.g.table_mode_corner = '|'
		vim.cmd.setlocal('spell')
		MarkdownHeadingsHighlight()
	end,
	['todo'] = function(_)
		vim.cmd('set filetype=markdown')
	end
	-- ['python'] = function(bufnr)
	--     local highlighter = require('vim.treesitter.highlighter')
	--     if highlighter.active[bufnr] then
	--         require('ufo').attach(bufnr)
	--     else
	--         vim.api.nvim_create_autocmd(
	--             'User', {
	--                 pattern = 'TSLoaded',
	--                 desc = 'Attach nvim-ufo after loading treesitter',
	--                 once = true,
	--                 callback = function(arg)
	--                     require('ufo').attach(arg.buf)
	--                 end
	--             }
	--         )
	--     end
	-- end
}

vim.api.nvim_create_autocmd(
	'FileType', {
		pattern = '*',
		desc = 'Run custom actions per filetype',
		callback = function(arg)
			local ftype = vim.o.filetype
			local actions = FileTypeActions[ftype]

			if actions then
				actions(arg.buf)
			end

			-- Load syntax for non treesitter filetypes
			if vim.tbl_contains(getTSInstlled(false), ftype) == false then
				vim.cmd('syntax on')
			end
		end
	}
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Folding     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'kevinhwang91/nvim-ufo',
	config = function()
		vim.o.foldcolumn = '1' -- '0' is not bad
		vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
		vim.cmd('hi clear Folded')

		---@class UfoExtmarkVirtTextChunk
		---@field [1] string text
		---@field [2] string|number highlight
		---@class UfoFoldVirtTextHandlerContext
		---@field bufnr number buffer for closed fold
		---@field winid number window for closed fold
		---@field text string text for the first line of closed fold
		---@field get_fold_virt_text fun(lnum: number): UfoExtmarkVirtTextChunk[] a function to get virtual text by lnum

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
			local suffix = ('󰕱 %d'):format(endLnum - lnum)
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
						suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { ' ', '' })
			table.insert(newVirtText, { suffix, 'Comment' })
			return newVirtText
		end

		---Python fold text generator
		---@param virtText UfoExtmarkVirtTextChunk[] list of tokens and its highlight
		---@param lnum number first line number of fold
		---@param endLnum number last line number of fold
		---@param width number max width for fold text
		---@param truncate fun(str: string, width: number): string truncate the str to become specific width
		---@param ctx UfoFoldVirtTextHandlerContext the context used by ufo, export to caller
		---@return UfoExtmarkVirtTextChunk[] # Generated fold text
		local function ufoFoldPython(virtText, lnum, endLnum, width, truncate, ctx)
			local function getDoc(cnum, bufnr)
				local lines = vim.api.nvim_buf_get_lines(bufnr, cnum-1, cnum+2, false)
				local cur_line = lines[1]
				local next_line = lines[2]

				-- for
				-- """
				if cur_line:find('^%s*[\'"]+$') then
					if cur_line == next_line then
						return (' ' .. next_line):gsub('%s+', ' ')
					end
					next_line = next_line:gsub('"""$', ''):gsub("'''$", ''):gsub('%s+$', '')
					return (next_line .. cur_line):gsub('%s+', ' ')
				end

				-- for
				-- """ docstring
				if cur_line:find('^%s*[\'"]+') then
					return cur_line:gsub('[^"^\']', '')
				end

				-- for
				-- code
				-- """
				-- docstring
				if next_line:find('^%s*[\'"]+$') then
					next_line = lines[3]
					return '  ' .. next_line:gsub('^%s*[\'"]*', ''):gsub('[%s\'"]*$', '')
				end

				-- for
				-- code
				-- """ docstring
				if next_line:find('^%s*[\'"]+') then
					return '  ' .. next_line:gsub('^%s*[\'"]*', ''):gsub('[%s\'"]*$', '')
				end

				return nil
			end


			local doc_line = getDoc(lnum, ctx.bufnr)
			if doc_line then
				table.insert(virtText, { doc_line, '@string.documentation.python' })
			end
			return ufoFoldGeneric(virtText, lnum, endLnum, width, truncate, ctx)
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
			local ftype = vim.api.nvim_get_option_value('filetype', { buf = ctx.bufnr })

			if ftype == 'python' then
				require('ufo.decorator'):setVirtTextHandler(ctx.bufnr, ufoFoldPython)
				return ufoFoldPython(virtText, lnum, endLnum, width, truncate, ctx)
			else
				return ufoFoldGeneric(virtText, lnum, endLnum, width, truncate, ctx)
			end
		end

		require('ufo').setup({
			fold_virt_text_handler = ufoFoldResolve,
			provider_selector = function(_, _, _)
				return 'treesitter'
			end
		})

		vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
		vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
	end,
	dependencies = {'kevinhwang91/promise-async', 'luukvbaal/statuscol.nvim'}
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Formatting   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- addPlugin {
--     'sbdchd/neoformat',
--     cmd = 'Neoformat'
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      Git       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: How to view commit of current line https://github.com/rhysd/git-messenger.vim or gitsigns ?
addPlugin {
	'9seconds/repolink.nvim',
	cmd = 'RepoLink',
	opts = {
		custom_url_parser = function(remote_url)
			local host, user, project= string.match(remote_url, "https://(office.visualstudio.com)/DefaultCollection/(.*)/_git/(.*)")
			if host then
				return host, { user = user, project = project }, false
			end
			return nil, nil, true
		end,
		url_builders = {
			['office.visualstudio.com'] = function(args)
				return string.format(
					"https://office.visualstudio.com/%s/_git/%s?path=/%s&version=GC%s&line=%d&lineEnd=%d&lineStartColumn=0&lineStyle=plain&_a=contents",
					args.host_data.user,
					args.host_data.project,
					args.path:gsub('\\', '/'),
					args.commit_hash,
					args.start_line,
					args.end_line+1
				)
			end
		},
		use_full_commit_hash = true
	}
}

addPlugin {
	'FabijanZulj/blame.nvim',
	opts = {
		date_format = '%d/%m/%Y',
		mappings = {
			commit_info = '?',
		}
	},
	cmd = 'BlameToggle'
}

addPlugin {
	'aaronhallaert/advanced-git-search.nvim',
	cmd = 'AdvancedGitSearch',
	config = function()
		local telescope = require('telescope')
		telescope.setup({
			extensions = {
				advanced_git_search = {
					diff_plugin = 'diffview',
					git_flags = {},
					git_diff_flags = {},
					show_builtin_git_pickers = true,
				}
			}
		})

		telescope.load_extension('advanced_git_search')
	end,
	dependencies = { 'nvim-telescope/telescope.nvim' }
}

-- BUG: why word diff works only on current buffer
addPlugin {
	'lewis6991/gitsigns.nvim',
	cmd = 'Gitsigns',
	dependencies = { 'luukvbaal/statuscol.nvim' },
	event = { 'TextChangedI' },
	keys = { '[c', ']c' },
	opts = {
		attach_to_untracked = true,
		count_chars = {
			[1]   = '',
			[2]   = '2',
			[3]   = '3',
			[4]   = '4',
			[5]   = '5',
			[6]   = '6',
			[7]   = '7',
			[8]   = '8',
			[9]   = '9',
			['+'] = '',
		},
		current_line_blame_formatter = ' 󰀄 <author> 󰔟 <committer_time:%R>  <summary>',
		diff_opts = {
			internal = true
		},
		on_attach = function (bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map('n', ']c', function()
				if vim.wo.diff then return ']c' end
				vim.schedule(function() gs.next_hunk({preview = true}) end)
				return '<Ignore>'
			end, {expr=true})

			map('n', '[c', function()
				if vim.wo.diff then return '[c' end
				vim.schedule(function() gs.prev_hunk({preview = true}) end)
				return '<Ignore>'
			end, {expr=true})
		end,
		preview_config = {
			border = 'rounded'
		},
		signs = {
			add          = { hl = 'GitSignsAdd'   ,       text = icons.diff_add,           numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'   , show_count = false },
			change       = { hl = 'GitSignsChange',       text = icons.diff_change,        numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
			changedelete = { hl = 'GitSignsChangedelete', text = icons.diff_change_delete, numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
			delete       = { hl = 'GitSignsDelete',       text = icons.diff_delete,        numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
			topdelete    = { hl = 'GitSignsDelete',       text = icons.diff_delete_top,    numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
		},
		trouble = false
	}
}

addPlugin {
	'sindrets/diffview.nvim',
	cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Icons      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'2kabhishek/nerdy.nvim',
	cmd = 'Nerdy',
	dependencies = { 'stevearc/dressing.nvim', 'nvim-telescope/telescope.nvim', },
}

addPlugin {
	'DaikyXendo/nvim-material-icon',
	opts = {
		override = {
			['c++']  = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
			cc       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
			cp       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cp'        },
			cpp      = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cpp'       },
			cs       = { color = '#C20DA6', cterm_color = '58',  icon = '󰌛', name = 'Cs'        },
			csproj   = { color = '#854CC7', cterm_color = '98',  icon = '', name = 'Csproj'    },
			csv      = { color = '#89E051', cterm_color = '113', icon = '', name = 'Csv'       },
			md       = { color = '#42A5F5', cterm_color = '75',  icon = '', name = 'Md'        },
			mdx      = { color = '#519ABA', cterm_color = '67',  icon = '󰽛', name = 'Mdx'       },
			py       = { color = "#3D7BAB", cterm_color = "221", icon = '', name = 'Py'        },
			todo     = { color = '#7CB342', cterm_color = '107', icon = '', name = 'Todo'      }
		}
	}
}

addPlugin {
	'kyazdani42/nvim-web-devicons',
	config = function()
		require('nvim-web-devicons').setup({
			override = require('nvim-material-icon').get_icons()
		})
		require("nvim-web-devicons").set_default_icon('', '#6d8086', 66)
	end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Indent     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'lukas-reineke/indent-blankline.nvim',
	event = 'CursorHold',
	main = 'ibl',
	opts = {
		enabled = true,
		debounce = 500,
		viewport_buffer = {
			min = 30,
			max = 500,
		},
		indent = {
			char = '▏',
			tab_char = nil,
			highlight = 'IblIndent',
			smart_indent_cap = true,
			priority = 1,
		},
		whitespace = {
			highlight = 'IblWhitespace',
			remove_blankline_trail = true,
		},
		scope = {
			enabled = true,
			char = '▏',
			show_start = true,
			show_end = true,
			injected_languages = true,
			highlight = 'IblScope',
			priority = 1024,
			include = {
				node_type = {
					['*'] = {
						'elif_clause',
						'else_clause',
						'for_statement',
						'if_statement',
						'while_statement',
					},
					['lua'] = {
						'elseif_statement',
						'else_statement',
						'table_constructor'
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
				'lspinfo',
				'packer',
				'checkhealth',
				'help',
				'man',
				'gitcommit',
				'TelescopePrompt',
				'TelescopeResults',
				'',
			},
			buftypes = {
				'terminal',
				'nofile',
				'quickfix',
				'prompt',
			},
		},
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰      LSP       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	-- 'Wansmer/symbol-usage.nvim',
	'VidocqH/lsp-lens.nvim',
	event = 'LspAttach',
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
			line = '󰧶 ' .. line
			return line
		end,
		ignore_filetype = {}
	}
}

addPlugin {
	'aznhe21/actions-preview.nvim',
	dependencies = 'nvim-telescope/telescope.nvim'
}

addPlugin {
	'folke/neodev.nvim',
	event = 'LspAttach *.lua',
	opts = {
		library = {
			enabled = true,
			plugins = true,
			runtime = true,
			types = true,
		},
		lspconfig = true,
		pathStrict = true,
		override = function(_, _) end,
		setup_jsonls = false,
	}
}

addPlugin {
	'glepnir/lspsaga.nvim',
	cmd = 'Lspsaga',
	opts = {
		beacon = {
			enable = true,
			frequency = 7,
		},
		code_action = {
			extend_gitsigns = true,
			keys = {
				quit = 'q',
				exec = '<CR>',
			},
			num_shortcut = true,
			show_server_name = true,
		},
		definition = {
			edit = 'o',
			quit = 'q',
			split = '<C-s>',
			tabe = '<C-t>',
			vsplit = '<C-v>',
		},
		diagnostic = {
			custom_fix = nil,
			custom_msg = nil,
			extend_relatedInformation = true,
			jump_num_shortcut = true,
			keys = {
				exec_action = 'o',
				quit = 'q',
				go_action = 'g'
			},
			max_width = 0.7,
			show_code_action = false,
			show_source = true,
			text_hl_follow = false,
		},
		finder = {
			default = 'tyd+ref+imp+def',
			keys = {
				shuttle = '<TAB>',
				split = keymaps.open_split,
				tabe = keymaps.open_tab,
				toggle_or_open = '<CR>',
				vsplit = keymaps.open_vsplit
			},
			open = {
				'o',
				'<CR>',
			},
			quit = {
				'q',
				'<ESC>',
			},
			split = '<C-s>',
			tabe = '<C-t>',
			vsplit = '<C-v>',
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
				jump = 'o',
				expand_collapse = 'u',
				quit = 'q',
			},
			win_position = 'right',
			win_width = 30,
		},
		preview = {
			lines_above = 0,
			lines_below = 10,
		},
		rename = {
			confirm = '<CR>',
			in_select = true,
			keys = {
				quit = '<C-c>',
				exec = '<CR>',
			}
		},
		request_timeout = 2000,
		scroll_preview = {
			scroll_down = '<C-n>',
			scroll_up = '<C-p>',
		},
		symbol_in_winbar = {
			enable = false,
		},
		ui = {
			actionfix = ' ',
			border = 'rounded',
			code_action = icons.code_action,
			collapse = '',
			devicon = true,
			diagnostic = icons.diagnostic,
			expand = '',
			hover = icons.hover,
			incoming = icons.incoming,
			kind = {
				Array         = { icons.Array,         'CmpItemKindArray',        },
				Boolean       = { icons.Boolean,       'CmpItemKindBoolean',      },
				Class         = { icons.Class,         'CmpItemKindClass',        },
				Constant      = { icons.Constant,      'CmpItemKindConstant',     },
				Constructor   = { icons.Constructor,   'CmpItemKindConstructor',  },
				Enum          = { icons.Enum,          'CmpItemKindEnum',         },
				EnumMember    = { icons.EnumMember,    'CmpItemKindEnumMember',   },
				Event         = { icons.Event,         'CmpItemKindEvent',        },
				Field         = { icons.Field,         'CmpItemKindField',        },
				File          = { icons.File,          'CmpItemKindFile',         },
				Folder        = { icons.Folder,        'CmpItemKindFolder',       },
				Function      = { icons.Function,      'CmpItemKindFunction',     },
				Interface     = { icons.Interface,     'CmpItemKindInterface',    },
				Key           = { icons.Key,           'CmpItemKindKey',          },
				Macro         = { icons.Macro,         'CmpItemKindMacro',        },
				Method        = { icons.Method,        'CmpItemKindMethod',       },
				Module        = { icons.Module,        'CmpItemKindModule',       },
				Namespace     = { icons.Namespace,     'CmpItemKindNamespace',    },
				Null          = { icons.Null,          'CmpItemKindNull',         },
				Number        = { icons.Number,        'CmpItemKindNumber',       },
				Object        = { icons.Object,        'CmpItemKindObject',       },
				Operator      = { icons.Operator,      'CmpItemKindOperator',     },
				Package       = { icons.Package,       'CmpItemKindPackage',      },
				Parameter     = { icons.Parameter,     'CmpItemKindParameter',    },
				Property      = { icons.Property,      'CmpItemKindProperty',     },
				Snippet       = { icons.Snippet,       'CmpItemKindSnippet',      },
				StaticMethod  = { icons.StaticMethod,  'CmpItemKindStaticMethod', },
				String        = { icons.String,        'CmpItemKindString',       },
				Struct        = { icons.Struct,        'CmpItemKindStruct',       },
				Text          = { icons.Text,          'CmpItemKindText',         },
				TypeAlias     = { icons.TypeAlias,     'CmpItemKindTypeAlias',    },
				TypeParameter = { icons.TypeParameter, 'CmpItemKindTypeParameter',},
				Unit          = { icons.Unit,          'CmpItemKindUnit',         },
				Value         = { icons.Value,         'CmpItemKindValue',        },
				Variable      = { icons.Variable,      'CmpItemKindVariable',     },
			},
			lines = { '╰', '⎬', '│', '─', '╭' },
			outgoing = icons.outgoing,
			preview = icons.preview,
			title  = true,
		}
	}
}

addPlugin {
	'j-hui/fidget.nvim',
	opts = {
		progress = {
			ignore_done_already = false,
			ignore_empty_message = false,
			suppress_on_insert = true,
		}
	},
	event = 'LspAttach'
}

addPlugin {
	'kosayoda/nvim-lightbulb',
	event = 'LspAttach',
	config = function()
		vim.api.nvim_set_hl(0, 'LightBulbVirtualText', { fg = '#EEE600' })
		require('nvim-lightbulb').setup({
			autocmd = { enabled = true },
			sign = { enabled = false, },
			validate_config = 'never',
			virtual_text = {
				enabled = true,
				text = '',
				hl = 'LightBulbVirtualText',
			}
		})
	end
}

-- TODO: progress
addPlugin {
	'mfussenegger/nvim-lint'
}
-- https://github.com/mfussenegger/nvim-lint
-- https://github.com/nkoporec/checkmate-lsp
-- https://github.com/nvimtools/none-ls.nvim
-- https://github.com/p00f/clangd_extensions.nvim

addPlugin {
	'williamboman/mason.nvim',
	cmd = 'Mason',
	opts = {
		ui = {
			border = 'rounded',
			height = 0.8,
			width = 0.8,
		}
	}
}

addPlugin {
	'williamboman/mason-lspconfig.nvim',
	config = function()
		-- Lsp timeout
		-- Lsp_timer = vim.uv.new_timer()
		-- vim.api.nvim_create_autocmd(
		-- 	'FocusLost', {
		-- 		pattern = '*',
		-- 		desc = 'Stop LSP on focus lost',
		-- 		once = false,
		-- 		callback = function()
		-- 			vim.api.nvim_create_autocmd(
		-- 				'FocusGained', {
		-- 					pattern = '*',
		-- 					desc = 'Start LSP on focus gained',
		-- 					once = true,
		-- 					callback = function()
		-- 						Lsp_timer:stop()
		-- 						Lsp_timer:start(10000, 0, vim.schedule_wrap(function()
		-- 							if not isLspAttached() then
		-- 								vim.notify('LSP resumed')
		-- 								vim.cmd.LspStart()
		-- 							end
		-- 						end))
		-- 					end
		-- 				}
		-- 			)
		-- 			Lsp_timer:stop()
		-- 			Lsp_timer:start(60000, 0, vim.schedule_wrap(function()
		-- 				if isLspAttached() then
		-- 					vim.notify('LSP hibernated')
		-- 					vim.cmd.LspStop()
		-- 				end
		-- 			end))
		-- 		end
		-- 	}
		-- )

		local mason_lspconfig = require('mason-lspconfig')
		local on_attach = function(_, bufnr)
			-- enable inlay hints
			vim.lsp.inlay_hint.enable(true)

			-- Mappings.
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
			vim.keymap.set('n', '<F12>', '<cmd>Lspsaga goto_definition<CR>', bufopts)
			vim.keymap.set('n', '<F2>', '<cmd>Lspsaga rename<CR>', bufopts)
			vim.keymap.set('n', '<M-F12>', '<cmd>Lspsaga finder<CR>', bufopts)
			vim.keymap.set('n', '<S-F12>', vim.lsp.buf.references, bufopts)
			vim.keymap.set('n', '<Leader>h', '<cmd>Lspsaga hover_doc<CR>', bufopts)
			vim.keymap.set('n', '<C-.>', require("actions-preview").code_actions, bufopts)
			vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', bufopts)
			vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', bufopts)
			vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
			vim.keymap.set('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', bufopts)
			vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
		end

		popupMenuAdd({
			cond = isLspAttached,
			opts = {
				{'Code Action         <C-.>',  '<Cmd>lua require("actions-preview").code_actions()<CR>'},
				{'Declaration            gD',  '<Cmd>lua vim.lsp.buf.declaration()<CR>'},
				{'Definition            F12',  '<Cmd>lua vim.lsp.buf.definition()<CR>'},
				{'Hover                  \\h', '<Cmd>Lspsaga hover_doc<CR>'},
				{'Implementation         gi',  '<Cmd>lua vim.lsp.buf.implementation()<CR>'},
				{'LSP Finder        Alt F12',  '<Cmd>Lspsaga lsp_finder<CR>'},
				{'Peek Definition        gp',  '<Cmd>Lspsaga peek_definition<CR>'},
				{'References      Shift F12',  '<Cmd>lua vim.lsp.buf.references()<CR>'},
				{'Rename                 F2',  '<Cmd>Lspsaga rename<CR>'},
				{'Type Definition        gt',  '<Cmd>lua vim.lsp.buf.type_definition()<CR>'}
			}
		})

		mason_lspconfig.setup()
		local handlers = {
			['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
			['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded'}), -- disable in favour of Noice
		}

		local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true
		}

		mason_lspconfig.setup_handlers {
			function (server_name)
				local lspconfig = require('lspconfig')
				if server_name == 'lua_ls' then
					lspconfig.lua_ls.setup {
						capabilities = capabilities,
						handlers = handlers,
						on_attach = on_attach,
						settings = {
							Lua = {
								codeLens = {
									enable = true
								},
								completion = {
									callsnippet = 'Both',
									keywordSnippet = 'Both'
								},
								diagnostics = {
									globals = { 'bit', 'vim' }
								},
								hint = {
									arrayIndex = "Enable",
									enable = true,
									setType = true
								},
								workspace = {
									library = {
										vim.fn.stdpath('data') .. '/lazy/lazy.nvim/lua/lazy/types.lua',
										vim.fn.stdpath('data') .. '/lazy/neodev.nvim/types/stable',
									}
								}
							}
						}
					}
				else
					lspconfig[server_name].setup {
						capabilities = capabilities,
						handlers = handlers,
						on_attach = on_attach
					}
				end
			end
		}
		vim.cmd.LspStart()
	end,
	dependencies = { 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
	keys = { '<F12>' }
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Markdown    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- addPlugin { 'iamcco/markdown-preview.nvim', }
addPlugin {
	'toppair/peek.nvim',
	build = 'deno task --quiet build:fast',
	cmd = 'PeekOpen',
	config = function()
		require('peek').setup({
			app = 'webview',
			theme = vim.o.background
		})
		vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
		vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
	end
}

addPlugin {
	'yaocccc/nvim-hl-mdcodeblock.lua',
	config = function ()
		local code_block = require('hl-mdcodeblock')
		code_block.setup({
			events = {
				'BufEnter',
				'InsertLeave',
				'TextChanged',
				'WinScrolled'
			},
			hl_group = 'MDCodeBlock',
			minumum_len = 10,
			padding_right = 1,
			query_by_ft = {
				markdown = {
					'markdown',
					'(fenced_code_block) @codeblock',
				},
				rmd = {
					'markdown',
					'(fenced_code_block) @codeblock',
				},
			},
			timer_delay = 300,
		})
		vim.api.nvim_set_hl(0, 'MDCodeBlock', { bg = adaptiveBG(30, -10) })
		code_block.refresh()
	end,
	dependencies = 'nvim-treesitter/nvim-treesitter',
	event = 'CursorHold *.md'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Marks      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Guide:
-- https://vim.fandom.com/wiki/Using_marks
-- |----------------+---------------------------------------------------------------|
-- | Command        | Description                                                   |
-- |----------------+---------------------------------------------------------------|
-- | ''             | jump back (to line in current buffer where jumped from)       |
-- | 'a             | jump to line of mark a (first non-blank character in line)    |
-- | :delmarks a    | delete mark a                                                 |
-- | :delmarks a-d  | delete marks a, b, c, d                                       |
-- | :delmarks aA   | delete marks a, A                                             |
-- | :delmarks abxy | delete marks a, b, x, y                                       |
-- | :delmarks!     | delete all lowercase marks for the current buffer (a-z)       |
-- | :marks         | list all the current marks                                    |
-- | :marks aB      | list marks a, B                                               |
-- | ['             | jump to previous line with a lowercase mark                   |
-- | [`             | jump to previous lowercase mark                               |
-- | ]'             | jump to next line with a lowercase mark                       |
-- | ]`             | jump to next lowercase mark                                   |
-- | `"             | jump to position where last exited current buffer             |
-- | `.             | jump to position where last change occurred in current buffer |
-- | `0             | jump to position in last file edited (when exited Vim)        |
-- | `1             | like `0 but the previous file (also `2 etc)                   |
-- | `< or `>       | jump to beginning/end of last visual selection                |
-- | `[ or `]       | jump to beginning/end of previously changed or yanked text    |
-- | ``             | jump back (to position in current buffer where jumped from)   |
-- | `a             | jump to position (line and column) of mark a                  |
-- | c'a            | change text from current line to line of mark a               |
-- | d'a            | delete from current line to line of mark a                    |
-- | d`a            | delete from current cursor position to position of mark a     |
-- | ma             | set mark a at current cursor location                         |
-- | y`a            | yank text to unnamed buffer from cursor to position of mark a |
-- |----------------+---------------------------------------------------------------|
addPlugin {
	'MattesGroeger/vim-bookmarks',
	config = function()
		vim.g.bookmark_annotation_sign = icons.bookmark_annotate
		vim.g.bookmark_display_annotation = 1
		vim.g.bookmark_highlight_lines = 1
		vim.g.bookmark_location_list = 1
		vim.g.bookmark_no_default_key_mappings = 1
		vim.g.bookmark_save_per_working_dir = 0
		vim.g.bookmark_sign = icons.bookmark
	end,
	dependencies = 'luukvbaal/statuscol.nvim',
	keys = {
		{ 'ba', '<Plug>BookmarkAnnotate' },
		{ 'bm', '<Plug>BookmarkToggle' },
		{ 'bn', '<Plug>BookmarkNext' },
		{ 'bp', '<Plug>BookmarkPrev' },
		{ 'bs', '<Plug>BookmarkShowAll' }
	}
}

-- FEAT: 'chentoast/marks.nvim'

addPlugin {
	'kshenoy/vim-signature',
	lazy = false
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Outline     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'stevearc/aerial.nvim',
	cmd = { 'AerialNavToggle', 'AerialToggle' },
	opts = {
		attach_mode = 'global',
		autojump = false,
		backends = { 'treesitter', 'lsp', 'markdown', 'man' },
		disable_max_lines = 10000,
		disable_max_size = 2000000, -- Default 2MB
		filter_kind = { 'Class', 'Constructor', 'Enum', 'Function', 'Interface', 'Module', 'Method', 'Struct' },
		guides = { mid_item = '├ ', last_item = '╰ ', nested_top = '│ ', whitespace = ' ', },
		highlight_on_hover = true,
		icons = icons,
		nav = {
			keymaps = {
				['<Left>'] = 'actions.left',
				['<Right>'] = 'actions.right',
				[''] = 'actions.close',
			},
			min_height = { 20, 0.2 },
			preview = true,
		},
		nerd_font = false,
		placement = 'edge',
		show_guides = true,
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Quickfix    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
--[[ Guide
|-----------------+-----------------------------------------------------------|
| Command         | Explaination                                              |
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
-- TODO: reconfigure
addPlugin {
	'folke/trouble.nvim',
	branch = 'dev',
	cmd = 'Trouble',
	opts = {}
}

--[[ Guide
|-------------+----------------------------------------------------------+---------|
| Function    | Action                                                   | Def Key |
|-------------+----------------------------------------------------------+---------|
| drop        | use drop to open the item, and close quickfix window     | O       |
| filter      | create new list for signed items                         | zn      |
| filterr     | create new list for non-signed items                     | zN      |
| fzffilter   | enter fzf mode                                           | zf      |
| lastleave   | go to last leaving position in quickfix window           | '"      |
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
| stogglebuf  | toggle signs for same buffers under the cursor           | '<Tab>  |
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
	'kevinhwang91/nvim-bqf',
	config = function()
		require('bqf').setup {
			auto_resize_height = true,
			preview = {
				border = dotted_border,
			},
			filter = {
				fzf = {
					action_for = {
						['ctrl-t'] = { default = 'tabedit' },
						['ctrl-v'] = { default = 'vsplit' },
						['ctrl-s'] = { default = 'split' },
						['ctrl-q'] = { default = 'signtoggle' },
						['ctrl-c'] = { default = 'closeall' }
					}
				}
			}
		}
		vim.cmd('packadd cfilter')
	end,
	dependencies = 'junegunn/fzf',
	ft = 'qf'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Rooter     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
vim.api.nvim_create_user_command(
	'Cdroot',
	function(opts)
		local function getCwd()
			return CWD or vim.fn.getcwd()
		end

		local function setCwd(path)
			if path then
				if not CWD then
					CWD = vim.fn.getcwd()
				end
				vim.cmd.lc(path)
			end
		end

		if opts.args == "cwd" then
			setCwd(getCwd())
		elseif opts.args == "cwd_git" then
			local root = vim.fs.dirname(vim.fs.find({".git"}, {path = getCwd(), upward = true, limit = 1})[1])
			setCwd(root)
		elseif opts.args == "file" then
			---@diagnostic disable-next-line: param-type-mismatch
			local filepath = vim.fn.fnamemodify(vim.fn.bufname('%'), ':p:h')
			setCwd(filepath)
		elseif opts.args == "file_git" then
			---@diagnostic disable-next-line: param-type-mismatch
			local root = vim.fs.dirname(vim.fs.find({".git"}, {path = vim.fn.bufname('%'), upward = true, limit = 1})[1])
			setCwd(root)
		end
	end,
	{
		complete = function() return { 'cwd', 'cwd_git', 'file', 'file_git',} end,
		nargs = 1,
	}
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Sessions    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'rmagatti/auto-session',
	cmd = 'SessionSave',
	config = function()
		vim.g.auto_session_suppress_dirs = { 'C:\\Users\\aloknigam', '~' }
		require('auto-session').setup({
			post_delete_cmds = {
				"let g:auto_session_enabled = v:false",
				"let g:session_icon = ''"
			},
			post_restore_cmds = {
				"let g:session_icon = '󰅠'"
			},
			post_save_cmds = {
				"let g:session_icon = '󰅠'"
			}
		})
		vim.o.sessionoptions = 'blank,buffers,curdir,help,tabpages,winsize,winpos,terminal'
	end,
	init = function()
		if vim.fn.filereadable(vim.fn.stdpath('data') .. '\\sessions\\' .. vim.fn.getcwd():gsub('\\', '-'):gsub(':', '++') .. '.vim') == 1 then
			require('auto-session')
		end
	end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Snippets    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'dcampos/nvim-snippy',
	dependencies = 'honza/vim-snippets',
	opts = {
		mappings = {
			is = {
				['<Tab>'] = 'expand_or_advance',
				['<S-Tab>'] = 'previous',
			}
		}
	},
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Status Column  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
--- Default method to use until statuscol.nvim loads which then overrides it
---@return string
function StatusCol()
	return '%=%l%C '
end
vim.o.statuscolumn = "%!v:lua.StatusCol()"

addPlugin {
	'luukvbaal/statuscol.nvim',
	config = function()
		local builtin = require('statuscol.builtin')
		require('statuscol').setup({
			setopt = true,
			relculright = true,
			segments = {
				{ sign = { name = { 'todo' } }, condition = { function() return TODO_COMMENTS_LOADED ~= nil end }, auto = true },
				{ sign = { name = { 'Signature_' }, auto = true, fillcharhl ='LineNr' } },
				{ sign = { namespace = { '.*diagnostic.*' }, auto = true, colwidth = 2, fillcharhl ='LineNr' }, click = 'v:lua.ScSa' },
				{ sign = { name = { 'Bookmark' }, auto = true, fillcharhl ='LineNr' } },
				{ sign = { name = { 'Dap' }, auto = true, fillcharhl ='LineNr' } },
				{ sign = { name = { 'coverage' }, colwidth = 1, fillcharhl ='LineNr', auto = true } },
				{ text = { builtin.foldfunc }, click = 'v:lua.ScFa' }, -- FEAT: either merge with git signs or shift to left of num
				{ text = { builtin.lnumfunc }, click = 'v:lua.ScLa', condition = { true } },
				{
					sign = {
						text = {
							icons.diff_add,
							icons.diff_change,
							icons.diff_delete,
							icons.diff_delete_top,
							icons.diff_change_delete,
						},
						colwidth = 1,
						fillcharhl = 'LineNr',
						wrap = true,
					},
					click = 'v:lua.ScSa',
				},
			},
		})
	end,
	event = 'DiagnosticChanged'
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Status Line   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'nvim-lualine/lualine.nvim',
	config = function()
		local function lspIcon()
			local anim ={ '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
			Icon_index = (Icon_index) % #anim + 1
			return anim[Icon_index]
		end

		local function GetFgOrFallback(hl_name, fallback)
			local hl = vim.api.nvim_get_hl(0, { name = hl_name, create = false, link = false})
			if hl then
				return string.format("#%X", hl.fg)
			else
				return fallback
			end
		end

		Icon_index = 0
		vim.o.showcmdloc = 'statusline'

		require('lualine').setup {
			options = {
				icons_enabled = true,
				theme = 'auto',
				component_separators = { left = '', right = ''}, -- ⏽ 
				section_separators = { left = '', right = ''}, -- BUG: highlight issues in transparent mode
				ignore_focus = { 'NvimTree' },
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
						'mode',
						color = { gui = 'bold' },
						fmt = function(str)
							local first = str:sub(1,1)
							if first == 'N' then
								return ''
							elseif first == 'V' then
								return ''
							elseif first == 'I' then
								return ''
							elseif first == 'C' then
								return ''
							end
							return str:sub(1,1)
						end,
						padding = { left = 0, right = 1 },
						separator = { left = '█', right = '' }
					}
				},
				lualine_b = {
					{
						'filetype',
						icon_only = true,
						padding = { left = 1, right = 0 },
						separator = ''
					},
					{
						'filename',
						color = { gui = 'italic' },
						file_status = true,
						newfile_status = true,
						on_click = function()
							vim.cmd('NvimTreeOpen')
						end,
						path = 0,
						padding = { left = 0, right = 0 },
						shorting_target = 40,
						symbols = {
							modified = icons.file_modified,
							readonly = icons.file_readonly,
							unnamed  = ' ' .. icons.file_unnamed .. ' ',
							newfile  = icons.file_newfile .. ' '
						}
					}
				},
				lualine_c = {
					{
						'branch',
						color = { gui = 'bold' },
						icon = {'', color = {fg = '#F14C28'}},
						on_click = function()
							vim.cmd('Telescope git_branches')
						end,
						padding = { left = 1, right = 0 },
					},
					{
						'diff',
						on_click = function()
							vim.cmd('Telescope git_status')
						end,
						padding = { left = 1, right = 0 },
						symbols = {
							added = '+',
							modified = '~',
							removed = '-'
						}
					},
				},
				lualine_x = {
					{
						'searchcount',
						color = { fg = '#23CE6B', gui = 'bold' },
						fmt = function(str)
							return string.sub(str, 2, -2)
						end,
						icon = {'󰱽', color = { fg = '#EAC435' }},
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						function() return '󰳾' end,
						color = { fg = '#009DDC' },
						cond = function()
							return vim.b.VM_Selection ~= nil and not vim.tbl_isempty(vim.b.VM_Selection)
						end
					},
					{
						'selectioncount',
						color = { fg = '#BA2C73' },
						icon = { '', color = { fg = '#963484' }},
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						function() return vim.g.ColoRand end,
						color = { fg = GetFgOrFallback('Number', '#F2F230'), gui ='bold' },
						icon = {'', color = { fg = string.format("#%X", vim.api.nvim_get_hl_by_name('Function', true).foreground)}},
						padding = { left = 0, right = 1 }
					},
					{
						'diagnostics',
						on_click = function()
							vim.cmd('Trouble diagnostics')
						end,
						padding = { left = 0, right = 1 },
						sources = { 'nvim_diagnostic' },
						symbols = {
							error = icons.error,
							warn  = icons.warn,
							info  = icons.info,
							hint  = icons.hint
						},
					},
					{
						'hostname',
						color = { fg = '#119DA4', gui = 'bold' },
						cond = function()
							return vim.env.SSH_CLIENT ~= nil
						end,
						fmt = function(str)
							local alias = {
								['ALOKNIGAM-IDC'] = 'devbox'
							}
							return alias[str] or str
						end,
						icon = { '', color = { fg = '#3066BE' }},
						padding = { left = 0, right = 1 }
					},
					{
						'filesize',
						color = { fg = '#B90E0A', gui = 'bold' },
						cond = isLargeFile,
						fmt = function(str)
							return '[' .. str .. ']'
						end,
						padding = { left = 0, right = 1 }
					},
					{
						'encoding',
						color = { fg = GetFgOrFallback('String', '#C2F261'), gui ='italic' },
						fmt = function(str)
							if vim.o.bomb then
								str = str .. '-bom'
							end
							return string.gsub(str, 'utf.', 'u')
						end,
						padding = { left = 0, right = 1 }
					}
				},
				lualine_y = {
					{
						function() return '󰑊' end,
						color = { fg = '#B43757' },
						cond = function() return vim.fn.reg_recording() ~= '' end,
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						function() return vim.g.session_icon or '' end,
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						lspIcon,
						cond = isLspAttached,
						on_click = function()
							vim.cmd('LspInfo')
						end,
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						function()
							local buf = vim.api.nvim_get_current_buf()
							local highlighter = require('vim.treesitter.highlighter')
							if highlighter.active[buf] then
								return '󰐅'
							end
							return ''
						end,
						color = { fg = '#097969' },
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						function()
							if vim.o.wrap then
								return '󰖶'
							else
								return '󰯟'
							end
						end,
						color = { fg = '#FFBF00' },
						on_click = function()
							vim.cmd('set wrap!')
						end,
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						'fileformat',
						color = { fg = '#0096FF' },
						padding = { left = 0, right = 1 },
					},
				},
				lualine_z = {
					{
						'location',
						fmt = function(str)
							return str:gsub("^%s+", ""):gsub("%s+", "")
						end,
						on_click = function ()
							require('mini.map').toggle()
							require('codewindow').toggle_minimap()
						end,
						padding = { left = 0, right = 0 },
						separator = { left = '', right = '█' }
					}
				}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {'filename'},
				lualine_x = {'location'},
				lualine_y = {},
				lualine_z = {}
			},
			winbar = {
				lualine_a = {
					{
						'filetype',
						cond = function() return not DropbarEnabled and CountWindows(true) > 1 end,
						icon_only = true,
						padding = { left = 1, right = 0 },
						separator = ''
					},
					{
						'filename',
						color = { gui = 'italic' },
						cond = function() return not DropbarEnabled and CountWindows(true) > 1 end,
						file_status = true,
						newfile_status = true,
						path = 0,
						shorting_target = 40,
						symbols = {
							modified = icons.file_modified,
							readonly = icons.file_readonly,
							unnamed  = icons.file_unnamed,
							newfile  = icons.file_newfile,
						}
					},
					{
						function()
							if DropbarEnabled then
								return '%{%v:lua.dropbar.get_dropbar_str()%}'
							else
								return ''
							end
						end,
						padding = { left = 0, right = 0 },
						separator = { left = '', right = '' }
					},
				}
			},
			inactive_winbar = {
				lualine_a = {
					{
						'filetype',
						cond = function () return CountWindows(true) > 1 end,
						icon_only = true,
						padding = { left = 1, right = 0 },
						separator = ''
					},
					{
						'filename',
						color = { gui = 'italic' },
						cond = function () return CountWindows(true) > 1 end,
						file_status = true,
						newfile_status = true,
						path = 3,
						shorting_target = 40,
						symbols = {
							modified = icons.file_modified,
							readonly = icons.file_readonly,
							unnamed  = icons.file_unnamed,
							newfile  = icons.file_newfile,
						}
					}
				},
				lualine_c = {
					{
						'diff',
						cond = function () return CountWindows(true) > 1 end,
						padding = { left = 1, right = 0 },
						symbols = {
							added = '+',
							modified = '~',
							removed = '-'
						}
					},
				},
				lualine_z = {
					{
						lspIcon,
						cond = function () return CountWindows(true) > 1 and isLspAttached() end,
						on_click = function()
							vim.cmd('LspInfo')
						end,
						padding = { left = 0, right = 1 },
						separator = ''
					},
					{
						'diagnostics',
						cond = function () return CountWindows(true) > 1 end,
						on_click = function()
							vim.cmd('TroubleToggle')
						end,
						padding = { left = 1, right = 1 },
						sources = { 'nvim_diagnostic' },
						symbols = {
							error = icons.error,
							warn  = icons.warn,
							info  = icons.info,
							hint  = icons.hint
						}
					}
				}
			},
			extensions = {
				'aerial',
				'lazy',
				'mason',
				'nvim-dap-ui',
				'nvim-tree',
				'quickfix',
				'toggleterm',
				'trouble'
			}
		}
	end,
	event = 'User VeryLazy'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Tab Line    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'akinsho/bufferline.nvim',
	event = 'TabNew',
	opts = {
		options = {
			always_show_bufferline = false,
			diagnostics = 'nvim_lsp',
			diagnostics_indicator = function(_, _, diagnostics_dict, context)
				if context.buffer:current() then
					return ''
				end
				local res = ''
				for k, v in pairs(diagnostics_dict) do
					res = res .. icons[k] .. v .. ' '
				end
				return res
			end,
			get_element_icon = function(element)
				local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
				if element.filetype == 'netrw' then
					icon = ''
				elseif element.path == '[No Name]' then
					icon = icons.file_newfile
				end
				return icon, hl
			end,
			hover = {
				enabled = true,
				delay = 200,
				reveal = {'close'}
			},
			indicator = {
				style = 'underline'
			},
			middle_mouse_command = 'tabclose %d',
			mode = 'tabs',
			name_formatter = function (buf)
				if buf.name == '[No Name]' then
					return ''
				end
				return buf.name
			end,
			offsets = {
					{
							filetype = 'NvimTree',
							text = 'File Explorer',
							highlight = 'Directory',
							separator = false
					}
			},
			right_mouse_command = nil,
			separator_style = 'thick'
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Telescope   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/Marskey/telescope-sg
-- FEAT: search in current file only or open buffers only
addPlugin {
	'nvim-telescope/telescope.nvim',
	cmd = 'Telescope',
	config = function()
		local actions = require('telescope.actions')
		local telescope = require('telescope')
		telescope.setup({
			defaults = {
				dynamic_preview_title = true,
				entry_prefix = '   ',
				file_ignore_patterns = {},
				file_sorter = require('telescope.sorters').get_fuzzy_file,
				generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
				initial_mode = 'insert',
				multi_icon = ' ',
				prompt_prefix = '  ',
				selection_caret = ' ',
				timeout = 2000,
				windblend = 0,
				mappings = {
					i = {
						['<C-a>']      = actions.toggle_all,
						['<C-d>']      = false,
						['<C-l>']      = actions.send_selected_to_qflist,
						['<C-s>']      = actions.select_horizontal,
						['<C-t>']      = actions.select_tab,
						['<C-u>']      = false,
						['<C-v>']      = actions.select_vertical,
						['<M-l>']      = actions.add_selected_to_qflist,
						['<PageDown>'] = actions.preview_scrolling_down,
						['<PageUp>']   = actions.preview_scrolling_up,
						['<S-Tab>']    = false,
						['<Tab>']      = actions.toggle_selection
					},
					n = {
						['<C-a>']      = actions.toggle_all,
						['<C-d>']      = false,
						['<C-q>']      = actions.send_selected_to_qflist,
						['<C-s>']      = actions.select_horizontal,
						['<C-t>']      = actions.select_tab,
						['<C-u>']      = false,
						['<C-v>']      = actions.select_vertical,
						['<M-q>']      = actions.add_selected_to_qflist,
						['<PageDown>'] = actions.preview_scrolling_down,
						['<PageUp>']   = actions.preview_scrolling_up,
						['<S-Tab>']    = false,
						['<Tab>']      = actions.toggle_selection
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
					case_mode = 'smart_case',
				},
				undo = {
					side_by_side = true
				}
			},
		})

		telescope.load_extension('fzf')
		telescope.load_extension('undo')

		vim.api.nvim_create_autocmd(
			'User', {
				pattern = 'TelescopePreviewerLoaded',
				desc = 'Open directory in nvim-tree',
				command = 'setlocal nu'
			}
		)
	end,
	dependencies = {
		'debugloop/telescope-undo.nvim',
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
	},
	module = false
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Terminal    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'akinsho/toggleterm.nvim',
	cmd = 'ToggleTerm',
	config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Tests      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'andythigpen/nvim-coverage',
	cmd = 'Coverage',
	dependencies = { 'nvim-lua/plenary.nvim', 'luukvbaal/statuscol.nvim' },
	opts ={
		auto_reload = true,
		signs = {
			covered = { hl = 'CoverageCovered', text = '┃' },
			partial = { hl = 'CoveragePartial', text = '┃' },
			uncovered = { hl = 'CoverageUncovered', text = '┃' },
		},
		sign_group = 'coverage'
	}
}

addPlugin {
	'nvim-neotest/neotest',
	cmd = 'Neotest',
	config = function()
		require('neotest').setup({
			adapters = {
				require('neotest-python')({
					python = vim.fn.exepath('python')
				})
			},
			icons = {
				child_indent = '│',
				child_prefix = '├',
				collapsed = '─',
				expanded = '╮',
				failed = '',
				final_child_indent = ' ',
				final_child_prefix = '╰',
				non_collapsible = '─',
				passed = '',
				running = '',
				running_animated = { '◜', '◠', '◝', '◞', '◡', '◟' },
				skipped = '',
				unknown = '',
				watching = ''
			},
			output = {
				enabled = true,
				open_on_run = true
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
				attach = 'a',
				clear_marked = 'M',
				clear_target = 'T',
				debug = 'd',
				debug_marked = 'D',
				expand = { '<CR>', '<2-LeftMouse>' },
				expand_all = 'e',
				jumpto = 'i',
				mark = 'm',
				next_failed = 'J',
				output = 'o',
				prev_failed = 'K',
				run = 'r',
				run_marked = 'R',
				short = 'O',
				stop = 'u',
				target = 't',
				watch = 'w'
				},
				open = 'botright vsplit | vertical resize 50'
			},
			status = {
				enabled = true,
				signs = false,
				virtual_text = true
			},
		})
	end,
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-neotest/neotest-python'
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Treesitter   ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	-- https://github.com/echasnovski/mini.splitjoin
	'Wansmer/treesj',
	cmd = 'TSJToggle',
	opts = {
		max_join_length = 10000,
		use_default_keymaps = false,
	}
}

addPlugin {
	'nvim-treesitter/nvim-treesitter',
	config = function()
		require('nvim-treesitter.configs').setup({
			auto_install = false,
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
			}
		})
	end,
	dependencies = { 'utilyre/sentiment.nvim' }, -- BUG: not working
	module = false
}

addPlugin {
	'HiPhish/rainbow-delimiters.nvim',
	config = function()
		require('rainbow-delimiters').enable()
	end,
	event = 'User TSLoaded'
}

addPlugin {
	'nvim-treesitter/nvim-treesitter-textobjects',
	keys = {
		{ '<Leader>sn', mode = 'n', desc = 'swap with next parameter' },
		{ '<Leader>sp', mode = 'n', desc = 'swap with previous parameter' },
		{ '[[', mode = 'n', desc = 'jump to previous class' },
		{ '[m', mode = 'n', desc = 'jump to previous method' },
		{ ']]', mode = 'n', desc = 'jump to next class' },
		{ ']m', mode = 'n', desc = 'jump to next method' },
		{ 'am', mode = 'v', desc = 'select around method' },
		{ 'im', mode = 'v', desc = 'select inner method' }
	},
	main = 'nvim-treesitter.configs',
	opts = {
		textobjects = {
			lsp_interop = {
				enable = false
			},
			move = {
				enable = true,
				set_jumps = false,
				goto_next_start = {
					[']m'] = '@function.outer',
					[']]'] = '@class.outer',
				},
				goto_previous_start = {
					['[m'] = '@function.outer',
					['[['] = '@class.outer',
				}
			},
			select = {
				enable = true,
				include_surrounding_whitespace = false,
				keymaps = {
					['am'] = '@function.outer',
					['im'] = '@function.inner',
				},
				lookahead = false
			},
			swap = {
				enable = true,
				swap_next = {
					['<Leader>sn'] = '@parameter.inner',
				},
				swap_previous = {
					['<Leader>sp'] = '@parameter.inner',
				}
			}
		}
	}
}

addPlugin {
	'm-demare/hlargs.nvim',
	config = function()
		require('hlargs').setup({
			colorpalette = (function()
				local res = {}
				for _,v in ipairs(ColorPalette()) do
					table.insert(res, {fg = v.fg})
				end
				return res
			end)(),
			excluded_argnames = {
				declarations = {
					python = { 'self', 'cls' },
					lua = { 'self' }
				},
				usages = {
					python = { 'self', 'cls' },
					lua = { 'self' }
				}
			},
			extras = {
				named_parameters = true,
			},
			hl_priority = hl_priority.hlargs,
			paint_catch_blocks = {
				declarations = true,
				usages = true
			},
			use_colorpalette = true,
		})
	end,
	event = 'User TSLoaded'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       UI       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- BUG: sudden quit due to formatting
-- BUG: hides last char in substitute command
addPlugin {
	'folke/noice.nvim',
	config = function()
		vim.o.lazyredraw = false
		require('noice').setup({
			cmdline = {
				enabled = true,
				view = 'cmdline_popup',
				opts = {},
				format = {
					cmdline = { pattern = '^:', icon = '', lang = 'vim', title = ' cmd '},
					filter = { pattern = '^:%s*!', icon = '$', lang = 'powershell' , title = ''},
					help = { pattern = '^:%s*he?l?p?%s+', icon = '' , title = ' help '},
					input = {},
					lazy = { pattern = '^:%s*Lazy%s+', icon = ' ', lang = 'vim' , title = ' Lazy '},
					lua = { pattern = '^:%s*lua%s+', icon = '', lang = 'lua' , title = ' lua '},
					lua_print = { pattern = '^:%s*lua=%s+', icon = '󰇼', lang = 'lua' , title = ' lua echo '},
					search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex', view = 'cmdline' , title = ''},
					search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' , title = ''},
				},
			},
			messages = {
				enabled = true,
				view = 'notify',
				view_error = 'notify',
				view_warn = 'notify',
				view_history = 'messages',
				view_search = 'virtualtext',
			},
			popupmenu = {
				enabled = true,
				backend = 'cmp',
				kind_icons = {},
			},
			redirect = {
				view = 'popup',
				filter = { event = 'msg_show' },
			},
			-- commands = {
			-- 	history = {
			-- 		view = 'split',
			-- 		opts = { enter = true, format = 'details' },
			-- 		filter = {
			-- 			any = {
			-- 				{ event = 'notify' },
			-- 				{ error = true },
			-- 				{ warning = true },
			-- 				{ event = 'msg_show', kind = { '' } },
			-- 				{ event = 'lsp', kind = 'message' },
			-- 			},
			-- 		},
			-- 	},
			-- 	last = {
			-- 		view = 'popup',
			-- 		opts = { enter = true, format = 'details' },
			-- 		filter = {
			-- 			any = {
			-- 				{ event = 'notify' },
			-- 				{ error = true },
			-- 				{ warning = true },
			-- 				{ event = 'msg_show', kind = { '' } },
			-- 				{ event = 'lsp', kind = 'message' },
			-- 			},
			-- 		},
			-- 		filter_opts = { count = 1 },
			-- 	},
			-- 	errors = {
			-- 		view = 'popup',
			-- 		opts = { enter = true, format = 'details' },
			-- 		filter = { error = true },
			-- 		filter_opts = { reverse = true },
			-- 	},
			-- },
			notify = {
				enabled = true,
				view = 'notify',
			},
			lsp = {
				progress = {
					enabled = false,
					format = 'lsp_progress',
					format_done = 'lsp_progress_done',
					throttle = 1000 / 30,
					view = 'mini',
				},
				override = {
					['cmp.entry.get_documentation'] = true,
					['vim.lsp.util.convert_input_to_markdown_lines'] = true,
					['vim.lsp.util.stylize_markdown'] = true,
				},
				hover = {
					enabled = true,
					view = nil,
					opts = {},
				},
				-- signature = {
				-- 	enabled = true,
				-- 	auto_open = {
				-- 		enabled = true,
				-- 		trigger = true,
				-- 		luasnip = true,
				-- 		throttle = 50,
				-- 	},
				-- 	view = nil,
				-- 	opts = {},
				-- },
				message = {
					enabled = true,
					view = 'notify',
					opts = {},
				},
			-- 	documentation = {
			-- 		view = 'hover',
			-- 		opts = {
			-- 			lang = 'markdown',
			-- 			replace = true,
			-- 			render = 'plain',
			-- 			format = { '{ message }' },
			-- 			win_options = { concealcursor = 'n', conceallevel = 3 },
			-- 		},
			-- 	},
			},
			-- markdown = {
			-- 	hover = {
			-- 		['|(%S-)|'] = vim.cmd.help,
			-- 		['%[.-%]%((%S-)%)'] = require('noice.util').open,
			-- 	},
			-- 	highlights = {
			-- 		['|%S-|'] = '@text.reference',
			-- 		['@%S+'] = '@parameter',
			-- 		['^%s*(Parameters:)'] = '@text.title',
			-- 		['^%s*(Return:)'] = '@text.title',
			-- 		['^%s*(See also:)'] = '@text.title',
			-- 		['{%S-}'] = '@parameter',
			-- 	},
			-- },
			health = {
				checker = false,
			},
			smart_move = {
				enabled = true,
				excluded_filetypes = { 'cmp_menu', 'cmp_docs', 'notify' },
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
			routes = {{
				view = 'notify',
				filter = { event = 'msg_showmode' },
			}}
		})
	end,
	dependencies = { 'MunifTanjim/nui.nvim' },
	event = 'CmdlineEnter'
}

addPlugin {
	'rcarriga/nvim-notify',
	config = function()
		local notify = require('notify')
		notify.setup({
			minimum_width = 0,
			render = 'compact',
			stages = 'slide'
		})
		vim.notify = notify

		for _, hl_name in ipairs({ 'NotifyINFOIcon', 'NotifyINFOTitle' }) do
			local notify_hl = vim.api.nvim_get_hl(0, { name = hl_name, create = false })
			if notify_hl and notify_hl.fg == 11140968 then
				notify_hl.fg = '#654DFF'
				vim.api.nvim_set_hl(0, hl_name, notify_hl)
			end
		end

	end
}

addPlugin {
	'stevearc/dressing.nvim',
	dependencies = 'telescope.nvim',
	opts = {
		input = {
			title_pos = 'center'
		}
	}
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   Utilities    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'AndrewRadev/inline_edit.vim',
	cmd = 'InlineEdit'
}

-- BUG: debug working
addPlugin {
	'TheLeoP/powershell.nvim',
	opts = {
		bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services"
	}
}

addPlugin {
	'ThePrimeagen/refactoring.nvim',
	cmd = 'Refactor',
	config = true,
	dependencies = {
		'nvim-lua/plenary.nvim',
	}
}

addPlugin {
	'anuvyklack/hydra.nvim',
	config = function()
		local hydra = require('hydra')
		hydra({
			name = 'Window Control',
			mode = 'n',
			body = 'W',
			config = {
				invoke_on_body = true,
				desc = 'Enable window controls',
				hint = {
					type = 'window',
					position = 'middle',
					border = dotted_border
				}
			},
			heads = {
				{ '<Down>', function() vim.cmd('res -1') end, { desc = 'Decrease height' } },
				{ '<Left>', function() vim.cmd('vert res +1') end, { desc = 'Increase width' } },
				{ '<Right>', function() vim.cmd('vert res -1') end, { desc = 'Dencrease width' } },
				{ '<Up>', function() vim.cmd('res +1') end, { desc = 'Increase height' } },
				{ 'h', function() vim.cmd('wincmd h') end, { desc = 'Move left' } },
				{ 'j', function() vim.cmd('wincmd j') end, { desc = 'Move down' } },
				{ 'k', function() vim.cmd('wincmd k') end, { desc = 'Move right' } },
				{ 'l', function() vim.cmd('wincmd l') end, { desc = 'Move up' } },
				{ '=', function() vim.cmd('wincmd =') end, { desc = 'Realign windows', exit = true } },
				{ '-', function() vim.cmd('resize') end, { desc = 'Max height', exit = true } },
				{ '|', function() vim.cmd('vertical-resize') end, { desc = 'Max width', exit = true } }
			},
			hint = '[Window Controls]'
		})
	end,
	lazy = false
}

addPlugin {
	'ariel-frischer/bmessages.nvim', -- FIX: conflicts with Noice
	cmd = 'Bmessages',
	opts = {
		split_size_split = 10,
		split_type = 'split'
	}
}

addPlugin {
	'benlubas/wrapping-paper.nvim',
	dependencies = {
		'MunifTanjim/nui.nvim',
	},
	keys = {
		{ 'gww', function() require('wrapping-paper').wrap_line() end, desc = 'Unwrap current line' }
	}
}

addPlugin {
	'cbochs/portal.nvim',
	cmd = 'Portal',
	dependencies = { 'ThePrimeagen/harpoon', 'cbochs/grapple.nvim' }
}

addPlugin { -- FIX: needs fix for path issue
	'cameron-wags/rainbow_csv.nvim',
	config = true,
	ft = 'csv'
}

addPlugin {
	'cshuaimin/ssr.nvim',
	keys = {
		{ '<Leader>sr', function() require('ssr').open() end, mode = { 'n', 'x' }, desc = 'Structural Search and Replace' }
	},
	opts = {
		adjust_window = true,
		border = 'rounded',
		keymaps = {
			close = 'q',
			next_match = 'n',
			prev_match = 'N',
			replace_all = '<Leader><cr>',
			replace_confirm = '<cr>',
		},
		max_height = 25,
		max_width = 120,
		min_height = 5,
		min_width = 50
	}
}
-- addPlugin {
--     'dstein64483778129/vim-startuptime',
--     cmd = 'StartupTime'
-- }

addPlugin {
	'echasnovski/mini.move',
	keys = {
		{ '<C-h>', mode = 'v' },
		{ '<C-l>', mode = 'v' },
		{ '<C-j>', mode = 'v' },
		{ '<C-k>', mode = 'v' },
		{ 'H',     mode = 'n' },
		{ 'L',     mode = 'n' },
		{ 'J',     mode = 'n' },
		{ 'K',     mode = 'n' },
	},
	opts = {
		mappings = {
			left = '<C-h>',
			right = '<C-l>',
			down = '<C-j>',
			up = '<C-k>',
			line_left = 'H',
			line_right = 'L',
			line_down = 'J',
			line_up = 'K',
		},
		options = {
			reindent_linewise = true
		}
	}
}

addPlugin {
	-- https://github.com/kylechui/nvim-surround
	'echasnovski/mini.surround',
	config = true,
	keys = {
		{ 'sa', mode = { 'n', 'x' }, desc = 'Add surrounding' },
		{ 'sd', mode = { 'n', 'x' }, desc = 'Delete surrounding' },
		{ 'sr', mode = { 'n', 'x' }, desc = 'Replace surrounding' }
	}
}

-- 'jbyuki/instant.nvim'

addPlugin {
	'folke/flash.nvim',
	keys = { 'f', 'F' },
	opts = {
		labels = 'asdfghjklqwertyuiopzxcvbnm',
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
				label = { exclude = 'iardc' }
			}
		}
	}
}

addPlugin {
	'folke/which-key.nvim',
	event = 'VeryLazy',
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		plugins = {
			marks = false,
			registers = false,
			spelling = {
				enabled = false,
				suggestions = 20,
			},
			presets = {
				operators = true,
				motions = true,
				text_objects = true,
				windows = true,
				nav = true,
				z = true,
				g = true,
			},
		},
		operators = { gc = 'Comments' },
		key_labels = { },
		motions = {
			count = true,
		},
		icons = {
			breadcrumb = '»',
			separator = '➜',
			group = '+',
		},
		popup_mappings = {
			scroll_down = '<c-d>',
			scroll_up = '<c-u>',
		},
		window = {
			border = dotted_border,
			position = 'bottom',
			margin = { 0, 0, 1, 0 },
			padding = { 0, 0, 0, 0 },
			winblend = 0,
			zindex = 1000,
		},
		layout = {
			height = { min = 4, max = 25 },
			width = { min = 20, max = 50 },
			spacing = 3,
			align = 'left',
		},
		ignore_missing = false,
		hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', '^:', '^ ', '^call ', '^lua ' },
		show_help = true,
		show_keys = true,
		triggers = 'auto',
		triggers_nowait = {
			-- marks
			'`',
			"'",
			'g`',
			"g'",
			-- registers
			'"',
			'<c-r>',
			-- spelling
			'z=',
		},
		triggers_blacklist = {
			i = { 'j', 'k' },
			n = { 'v' },
			v = { 'j', 'k' },
		},
		disable = {
			buftypes = {},
			filetypes = {},
		},
	}
}

addPlugin {
	-- https://github.com/gregorias/coerce.nvim
	'johmsalas/text-case.nvim',
	init = function()
		---set keymap for text-case
		---@param key string key to set
		---@param case string case to be used
		---@param desc string description of mapping
		local setTextKey = function(key, case, desc)
			vim.keymap.set(
				{ 'n', 'x' },
				key,
				function() require('textcase').current_word(case) end,
				{ desc = desc }
			)
		end

		setTextKey('wc-', 'to_dash_case',         'dash-case'         )
		setTextKey('wc.', 'to_dot_case',          'dot.case'          )
		setTextKey('wc/', 'to_path_case',         'path/case'         )
		setTextKey('wc0', 'to_constant_case',     'CONSTANT_CASE'     )
		setTextKey('wc_', 'to_snake_case',        'snake_case'        )
		setTextKey('wcc', 'to_camel_case',        'camelCase'         )
		setTextKey('wch', 'to_phrase_case',       'Phrase case'       )
		setTextKey('wcl', 'to_lower_case',        'lowercase'         )
		setTextKey('wcL', 'to_lower_phrase_case', 'lower phrase case' )
		setTextKey('wcp', 'to_pascal_case',       'PascalCase'        )
		setTextKey('wct', 'to_title_case',        'Title Case'        )
		setTextKey('wcT', 'to_title_dash_case',   'Title_Dash_Case'   )
		setTextKey('wcu', 'to_upper_case',        'UPPERCASE'         )
		setTextKey('wcU', 'to_upper_phrase_case', 'UPPER PHRASE CASE' )
	end,
	lazy = true,
	opts = {
		default_keymappings_enabled = false,
	}
}

addPlugin {
	'gbprod/yanky.nvim',
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
	event = 'TextYankPost'
}

addPlugin {
	'kwkarlwang/bufjump.nvim',
	opts = {
		on_success = function()
			vim.cmd([[execute "normal! g`\"zz"]])
		end
	},
	keys = {
		{ '<C-S-I>', function() require('bufjump').forward() end },
		{ '<C-S-O>', function() require('bufjump').backward() end }
	}
}

-- https://github.com/kndndrj/nvim-dbee
-- https://github.com/lewis6991/hover.nvim
-- https://github.com/patrickpichler/hovercraft.nvim

addPlugin {
	'mg979/vim-visual-multi',
	config = function()
		vim.cmd[[
			let g:VM_set_statusline = 0
			nmap <C-LeftMouse> <Plug>(VM-Mouse-Cursor)
			nmap <C-RightMouse> <Plug>(VM-Mouse-Word)
		]]
	end,
	keys = { '<C-LeftMouse>', '<C-RightMouse>', '<C-Up>', '<C-Down>', '<C-N>' }
}

addPlugin {
	'nat-418/boole.nvim',
	keys = { '<C-a>', '<C-x>' },
	opts = {
		mappings = {
			increment = '<C-a>',
			decrement = '<C-x>'
		},
		additions = { },
		allow_caps_additions = {
			{ 'buy', 'sell' }
		}
	}
}

addPlugin {
	-- Lua copy https://github.com/ojroques/nvim-osc52
	-- :h clipboard-osc52
	'ojroques/vim-oscyank', -- do we need this plugin now, test on SSH
	cond = function()
		return vim.env.SSH_CLIENT ~= nil
	end,
	config = function()
		vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif]]
	end,
	lazy = false
}

addPlugin {
	'rickhowe/diffchar.vim',
	lazy = false
}

addPlugin {
	'rickhowe/spotdiff.vim',
	cmd = { 'Diffthis', 'VDiffthis'}
}

addPlugin {
	'sickill/vim-pasta',
	config = function()
		vim.g.pasta_paste_before_mapping = '[p'
		vim.g.pasta_paste_after_mapping = ']p'
	end,
	keys = { '[p', ']p' }
}

addPlugin {
	'shortcuts/no-neck-pain.nvim',
	cmd = 'NoNeckPain'
}

-- https://github.com/wellle/targets.vim
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Winbar     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
	'Bekaboo/dropbar.nvim',
	opts = {
		icons = {
			enable = true,
			kinds = {
				use_devicons = true,
				symbols = {
					Array = icons.Array,
					Boolean = icons.Boolean,
					BreakStatement = '󰙧 ',
					Call = '󰃷 ',
					CaseStatement = '󱃙 ',
					Class = icons.Class,
					Color = icons.Color,
					Constant = icons.Constant,
					Constructor = icons.Constructor,
					ContinueStatement = '→ ',
					Copilot = ' ',
					Declaration = '󰙠 ',
					Delete = '󰩺 ',
					DoStatement = '󰑐 ',
					Enum = icons.Enum,
					EnumMember = icons.EnumMember,
					Event = icons.Event,
					Field = icons.Field,
					File = icons.File,
					Folder = icons.Folder,
					ForStatement = '󰑐 ',
					Function = icons.Function,
					H1Marker = '󰉫 ',
					H2Marker = '󰉬 ',
					H3Marker = '󰉭 ',
					H4Marker = '󰉮 ',
					H5Marker = '󰉯 ',
					H6Marker = '󰉰 ',
					Identifier = '󰻾 ',
					IfStatement = '󰃻 ',
					Interface = icons.Interface,
					Keyword = icons.Keyword,
					List = ' ',
					Log = '󰦪 ',
					Lsp = '󰈸 ',
					Macro = icons.Macro,
					MarkdownH1 = '󰉫 ',
					MarkdownH2 = '󰉬 ',
					MarkdownH3 = '󰉭 ',
					MarkdownH4 = '󰉮 ',
					MarkdownH5 = '󰉯 ',
					MarkdownH6 = '󰉰 ',
					Method = icons.Method,
					Module = icons.Module,
					Namespace = icons.Namespace,
					Null = icons.Null,
					Number = icons.Number,
					Object = icons.Object,
					Operator = icons.Operator,
					Package = icons.Package,
					Pair = '󰅪 ',
					Property = icons.Property,
					Reference = icons.Reference,
					Regex = '󰑑 ',
					Repeat = '󰕇 ',
					Scope = '󰅩 ',
					Snippet = icons.Snippet,
					Specifier = '󰦪 ',
					Statement = '󰅩 ',
					String = icons.String,
					Struct = icons.Struct,
					SwitchStatement = '󰺟 ',
					Terminal = ' ',
					Text = icons.Text,
					Type = icons.TypeParameter,
					TypeParameter = icons.TypeParameter,
					Unit = icons.Unit,
					Value = icons.Value,
					Variable = icons.Variable,
					WhileStatement = '󰑐 ',
				},
			},
			ui = {
				bar = {
					separator = '  ',
					extends = '…',
				},
				menu = {
					separator = ' ',
					indicator = ' ',
				},
			},
		}
	}
}

require('lazy').setup(plugins, lazy_config)
ColoRand()
-- <~>
-- vim: fmr=</>,<~> fdm=marker textwidth=120 noexpandtab tabstop=2 shiftwidth=2
