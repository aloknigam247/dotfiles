--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Profiling   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- ---@class Profile
-- ---@field count integer Number of times an autocommand is invoked
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
--     local event = args.event

--     if AuProfileEnabled then
--         local data = AuProfileData[event] or {}
--         data['count'] = (data.count or 0) + 1
--         data['start'] = os.clock()
--         AuProfileData[event] = data
--     end
-- end

-- ---Collect autocommand data at autocommand startup, called for each event
-- ---@param args any Autocommand callback data
-- local function auProfileEnd(args)
--     if AuProfileEnabled then
--         local data = AuProfileData[args.event]
--         if data then
--             local elapsed = os.clock() - data.start
--             local total = (data.total or 0) + elapsed

--             data['avg'] = total / data.count
--             data['total'] = total

--             AuProfileData[args.event] = data
--         end
--     end
-- end

-- ---List of all valid autocommands to profile
-- ---@type string[]
-- local event_list = { "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "BufFilePre", "BufHidden", "BufLeave", "BufModifiedSet", "BufNew", "BufNewFile", "BufRead", "BufReadPre", "BufUnload", "BufWinEnter", "BufWinLeave", "BufWipeout", "BufWrite", "BufWritePost", "ChanInfo", "ChanOpen", "CmdUndefined", "CmdlineChanged", "CmdlineEnter", "CmdlineLeave", "CmdwinEnter", "CmdwinLeave", "ColorScheme", "ColorSchemePre", "CompleteChanged", "CompleteDone", "CompleteDonePre", "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI", "DiffUpdated", "DirChanged", "DirChangedPre", "ExitPre", "FileAppendPost", "FileAppendPre", "FileChangedRO", "FileChangedShell", "FileChangedShellPost", "FileReadPost", "FileReadPre", "FileType", "FileWritePost", "FileWritePre", "FilterReadPost", "FilterReadPre", "FilterWritePost", "FilterWritePre", "FocusGained", "FocusLost", "FuncUndefined", "InsertChange", "InsertCharPre", "InsertEnter", "InsertLeave", "InsertLeavePre", "MenuPopup", "ModeChanged", "OptionSet", "QuickFixCmdPost", "QuickFixCmdPre", "QuitPre", "RecordingEnter", "RecordingLeave", "RemoteReply", "SafeState", "SearchWrapped", "SessionLoadPost", "ShellCmdPost", "ShellFilterPost", "Signal", "SourcePost", "SourcePre", "SpellFileMissing", "StdinReadPost", "StdinReadPre", "SwapExists", "Syntax", "TabClosed", "TabEnter", "TabLeave", "TabNew", "TabNewEntered", "TermClose", "TermEnter", "TermLeave", "TermOpen", "TermResponse", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT", "TextYankPost", "UIEnter", "UILeave", "User", "VimEnter", "VimLeave", "VimLeavePre", "VimResized", "VimResume", "VimSuspend", "WinClosed", "WinEnter", "WinLeave", "WinNew", "WinResized", "WinScrolled" }

-- vim.api.nvim_create_autocmd(
--     event_list, {
--         desc = 'Autocommand profile init',
--         pattern = '*',
--         callback = auProfileStart
--     }
-- )

-- vim.api.nvim_create_user_command(
--     'ProfileAutocommand',
--     function()
--         vim.notify("Profiling started, stop by F6")
--         AuProfileEnabled = true
--         AuProfileData = {}
--         AuCallbackProfileData = {}

--         -- Autocommand to collect end data
--         vim.api.nvim_create_autocmd(
--             event_list, {
--                 desc = 'Autocommand profile record',
--                 pattern = '*',
--                 callback = auProfileEnd
--             }
--         )

--         -- Mapping to stop autocommand profiling
--         vim.api.nvim_set_keymap('n', '<F6>', '', {
--             callback = function()
--                 AuProfileEnabled = false
--                 vim.cmd('profile stop')
--                 vim.notify('Autocommand profiling stopped')
--             end
--         })

--         vim.cmd[[
--             profile start nvim_profile
--             " profile file *
--             profile func *
--         ]]
--     end,
--     { nargs = 0 }
-- )

---@type ProfileData?
-- AuCallbackProfileData = {}

-- ---Create autocmd wrapper to emit perf telemtry
-- ---@param event string Name of event
-- ---@param opts table Autocmd config
-- local function nvimCreateAutocmdWrapper(event, opts)
--     if opts then
--         local cb = opts.callback
--         if cb then
--             opts.callback = function(arg)
--                 local start = os.clock()
--                 cb(arg)
--                 local elapsed = os.clock() - start

--                 if AuProfileEnabled then
--                     local data = AuCallbackProfileData[arg.id] or {}
--                     local total = (data.total or 0) + elapsed

--                     data['count']= (data.count or 0) + 1
--                     data['avg'] = total / data.count
--                     data['total'] = total
--                     AuCallbackProfileData[arg.id] = data
--                 end
--             end
--         end
--     end
--     vim.api.nvim_create_autocmd_orig(event, opts)
-- end

-- vim.api.nvim_create_autocmd_orig = vim.api.nvim_create_autocmd
-- vim.api.nvim_create_autocmd = nvimCreateAutocmdWrapper
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- Variables</>
------------

-- Vim Globals
vim.g.editorconfig = false
vim.g.loaded_clipboard_provider = 1

-- Lua Globals
--------------

---Shapes for dotted border
---@type string[]
Dotted_border = {"╭", "-", "╮", "┆", "╯", "-", "╰", "┆"}

---Defines highlight priorities for vairous components
---@type table<string, integer>
Hl_priority = {
    hlargs = 126,
    url = 202
}

---Defines Icons for global usage
---@type table<string, string>
Icons = {
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
    Namespace          = 'ﬥ ',
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
    diff_add           = '┃',
    diff_change        = '║',
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
}

Lazy_config = {
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
Plugins = {}

---@class PopupMenu
---@field cond fun() Condition to evaluate for PopUp menu
---@field opts string[][] Config options
---@type PopupMenu[]
Pop_up_menu = {}

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
Todo_colors = {
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

-- Lua locals
-------------
local kind_hl = {
    Array         = { icon  = ' ' , dark = { fg = '#F42272' }, light = { fg = '#0B6E4F' } },
    Boolean       = { icon  = ' ' , dark = { fg = '#B8B8F3' }, light = { fg = '#69140E' } },
    Class         = { icon  = ' ' , dark = { fg = '#519872' }, light = { fg = '#1D3557' } },
    Color         = { icon  = ' ' , dark = { fg = '#A4B494' }, light = { fg = '#FA9F42' } },
    Constant      = { icon  = ' ' , dark = { fg = '#C5E063' }, light = { fg = '#744FC6' } },
    Constructor   = { icon  = ' ' , dark = { fg = '#4AAD52' }, light = { fg = '#755C1B' } },
    Enum          = { icon  = ' ' , dark = { fg = '#E3B5A4' }, light = { fg = '#A167A5' } },
    EnumMember    = { icon  = ' ' , dark = { fg = '#AF2BBF' }, light = { fg = '#B80C09' } },
    Event         = { icon  = ' ' , dark = { fg = '#6C91BF' }, light = { fg = '#53A548' } },
    Field         = { icon  = ' ' , dark = { fg = '#5BC8AF' }, light = { fg = '#E2DC12' } },
    File          = { icon  = ' ' , dark = { fg = '#EF8354' }, light = { fg = '#486499' } },
    Folder        = { icon  = ' ' , dark = { fg = '#BFC0C0' }, light = { fg = '#A74482' } },
    Function      = { icon  = ' ' , dark = { fg = '#E56399' }, light = { fg = '#228CDB' } },
    History       = { icon  = ' ' , dark = { fg = '#C2F8CB' }, light = { fg = '#85CB33' } },
    Interface     = { icon  = ' ' , dark = { fg = '#8367C7' }, light = { fg = '#537A5A' } },
    Key           = { icon  = ' ' , dark = { fg = '#D1AC00' }, light = { fg = '#645DD7' } },
    Keyword       = { icon  = ' ' , dark = { fg = '#20A4F3' }, light = { fg = '#E36414' } },
    Method        = { icon  = ' ' , dark = { fg = '#D7D9D7' }, light = { fg = '#197278' } },
    Module        = { icon  = ' ' , dark = { fg = '#F2FF49' }, light = { fg = '#EC368D' } },
    Namespace     = { icon  = 'ﬥ ' , dark = { fg = '#FF4242' }, light = { fg = '#2F9C95' } },
    Null          = { icon  = ' ' , dark = { fg = '#C1CFDA' }, light = { fg = '#56666B' } },
    Number        = { icon  = ' ' , dark = { fg = '#FB62F6' }, light = { fg = '#A5BE00' } },
    Object        = { icon  = ' ' , dark = { fg = '#F18F01' }, light = { fg = '#80A1C1' } },
    Operator      = { icon  = ' ' , dark = { fg = '#048BA8' }, light = { fg = '#F1DB4B' } },
    Options       = { icon  = ' ' , dark = { fg = '#99C24D' }, light = { fg = '#2292A4' } },
    Package       = { icon  = ' ' , dark = { fg = '#AFA2FF' }, light = { fg = '#B98EA7' } },
    Property      = { icon  = ' ' , dark = { fg = '#CED097' }, light = { fg = '#3777FF' } },
    Reference     = { icon  = ' ' , dark = { fg = '#1B2CC1' }, light = { fg = '#18A999' } },
    Snippet       = { icon  = ' ' , dark = { fg = '#7692FF' }, light = { fg = '#BF0D4B' } },
    String        = { icon  = ' ' , dark = { fg = '#FEEA00' }, light = { fg = '#D5573B' } },
    Struct        = { icon  = ' ' , dark = { fg = '#D81159' }, light = { fg = '#75485E' } },
    Text          = { icon  = ' ' , dark = { fg = '#0496FF' }, light = { fg = '#5762D5' } },
    TypeParameter = { icon  = ' ' , dark = { fg = '#FFFFFC' }, light = { fg = '#5D2E8C' } },
    Unit          = { icon  = ' ' , dark = { fg = '#C97B84' }, light = { fg = '#FF6666' } },
    Value         = { icon  = ' ' , dark = { fg = '#C6DDF0' }, light = { fg = '#2EC4B6' } },
    Variable      = { icon  = ' ' , dark = { fg = '#B7ADCF' }, light = { fg = '#548687' } }
}

-- <~>
-- Functions</>
------------

---Adds a plugin Lazy nvim config
---@param opts Plugin Plugin config
local function addPlugin(opts)
    table.insert(Plugins, opts)
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

---Print config of all windows
function DebugWindows()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local win_list = vim.api.nvim_tabpage_list_wins(tabpage)
    for _, win in ipairs(win_list) do
        local win_config = vim.api.nvim_win_get_config(win)
        print(vim.inspect(win_config))
    end
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
    return #vim.lsp.get_active_clients({bufnr = 0}) ~= 0
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
local function openFloat(path, relativity, col_offset, row_offset, enter)
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
            footer = ' [C-s] split [C-v] vsplit [C-t] tab open ',
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
    local au_id = vim.api.nvim_create_autocmd(
        'VimResized', {
            pattern = '*',
            desc = 'Resize preview window on vim resize',
            callback = function()
                local cfg = vim.api.nvim_win_get_config(Preview_win)
                print(vim.inspect(cfg.row[false]))
                vim.api.nvim_win_set_config(Preview_win, {
                    height = vim.o.lines - 8,
                    width = vim.o.columns - 8 - cfg.col[false]
                })
            end
        }
    )

    -- Cleanup on window close
        vim.api.nvim_create_autocmd(
        'WinClosed', {
            pattern = tostring(Preview_win),
            desc = 'Delete resize autocommand on Preview window close',
            callback = function(arg)
                Preview_win = nil
                vim.api.nvim_del_autocmd(au_id)
                vim.api.nvim_del_autocmd(arg.id)
            end
        }
    )

    -- Reopen preview in split
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-s>', '', {
        callback = function()
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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-v>', '', {
        callback = function()
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
    for _,menu in pairs(Pop_up_menu) do
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
    table.insert(Pop_up_menu, menu)
end

---Get TODO highlights
---@param _ integer Buffer id
---@param match string Matched text
---@return string? # Highlight for matched string
local function getTodoHl(_, match)
    if not TodoHilighterCache then
        TodoHilighterCache = {}
    end

    local cache = TodoHilighterCache[match]
    if cache then
        return cache
    end

    local color_set = {}
    if match == 'BUG:' then
        color_set = Todo_colors.error
    elseif match == 'DOCME:' then
        color_set = Todo_colors.docs
    elseif match == 'ERROR:' then
        color_set = Todo_colors.error
    elseif match == 'FEAT:' then
        color_set = Todo_colors.feat
    elseif match == 'FIX:' then
        color_set = Todo_colors.feat
    elseif match == 'HACK:' then
        color_set = Todo_colors.hint
    elseif match == 'HINT:' then
        color_set = Todo_colors.hint
    elseif match == 'INFO:' then
        color_set = Todo_colors.info
    elseif match == 'NOTE:' then
        color_set = Todo_colors.info
    elseif match == 'PERF:' then
        color_set = Todo_colors.perf
    elseif match == 'REFACTOR:' then
        color_set = Todo_colors.info
    elseif match == 'TEST:' then
        color_set = Todo_colors.test
    elseif match == 'THOUGHT:' then
        color_set = Todo_colors.info
    elseif match == 'TODO:' then
        color_set = Todo_colors.todo
    elseif match == 'WARN:' then
        color_set = Todo_colors.warn
    else
        color_set = Todo_colors.default
    end

    for _, hl in pairs(color_set) do
        if hl[1] == '#' then
            TodoHilighterCache[match] = hl
            return hl
        end
        if vim.api.nvim_get_hl(0, { name = hl }) then
            TodoHilighterCache[match] = hl
            return hl
        end
    end
    return nil
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
                vim.api.nvim_del_autocmd(arg.id)
                require("nvim-tree.api").tree.open({path = path})
            end
        end
    }
)

vim.api.nvim_create_autocmd(
    'BufWinEnter', {
        pattern = '*',
        desc = 'Overlength line marker',
        callback = function()
            if vim.bo.textwidth > 0 then
                vim.api.nvim_set_hl(0, "Overlength", { bg = adaptiveBG(70, -70) })
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
            local filedir = vim.fn.expand('%:p:h')
            if vim.fn.isdirectory(filedir) == 0 then
                vim.fn.mkdir(filedir, 'p')
            end
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
                vim.api.nvim_del_autocmd(arg.id)
                vim.api.nvim_exec_autocmds('User', { pattern = 'TSLoaded' })
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
            vim.highlight.on_yank { higroup="Search", timeout=300 }
        end
    }
)

vim.api.nvim_create_autocmd(
    'User', {
        pattern='VeryLazy',
        desc = 'Lazy load clipboard provider',
        callback = function()
            vim.cmd([[
                unlet g:loaded_clipboard_provider
                runtime autoload/provider/clipboard.vim
            ]])
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
-- <~>
-- Mappings</>
-----------
vim.keymap.set('i', '<C-BS>', '<C-w>', {})
vim.keymap.set('n', '<BS>', 'x', {})
vim.keymap.set('n', '<C-Q>', '<cmd>q<CR>', {})
vim.keymap.set('n', '<C-Tab>', '<cmd>tabnext<CR>', {})
vim.keymap.set('n', '<M-Down>', '<cmd>res -1<cr>', {})
vim.keymap.set('n', '<M-Left>', '<cmd>vert res -1<cr>', {})
vim.keymap.set('n', '<M-Right>', '<cmd>vert res +1<cr>', {})
vim.keymap.set('n', '<M-Up>', '<cmd>res +1<cr>', {})
-- <~>
-- Misc</>
-------
vim.diagnostic.config({
    float = {
        source = true
    },
    severity_sort = true,
    virtual_text = {
        prefix = ' ',
        source = true
    }
})

vim.cmd('sign define DiagnosticSignError text=' .. Icons.error .. ' texthl=DiagnosticSignError linehl= numhl=')
vim.cmd('sign define DiagnosticSignWarn  text=' .. Icons.warn  .. ' texthl=DiagnosticSignWarn  linehl= numhl=')
vim.cmd('sign define DiagnosticSignInfo  text=' .. Icons.info  .. ' texthl=DiagnosticSignInfo  linehl= numhl=')
vim.cmd('sign define DiagnosticSignHint  text=' .. Icons.hint  .. ' texthl=DiagnosticSignHint  linehl= numhl=')

vim.highlight.priorities = {
    syntax = 50,
    treesitter = 100,
    semantic_tokens = 125,
    diagnostics = 150,
    user = 200
}

-- Lazy load notify
vim.notify = function(...)
    require('notify')
    vim.notify(...)
end

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

vim.fn.matchadd(
    'HighlightURL',
    "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+",
    Hl_priority.url
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    -- https://github.com/altermo/ultimate-autopair.nvim
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pairs.md
    -- https://github.com/m4xshen/autoclose.nvim
    'windwp/nvim-autopairs',
    config = function()
        local pair = require('nvim-autopairs')
        local Rule = require('nvim-autopairs.rule')
        local cond = require('nvim-autopairs.conds')

        pair.setup({
            enable_check_bracket_line = false -- Don't add pairs if close pair is in the same line
        })
        pair.add_rules {
            -- function() | end pair for lua
            Rule('function() ', ' end', { 'lua' }),
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Coloring    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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

-- addPlugin { 'Pocco81/high-str.nvim', cmd = 'HSHighlight' }

addPlugin {
    'RRethy/vim-illuminate',
    config = function()
        require('illuminate').configure({
            delay = 400,
            min_count_to_highlight = 2,
            modes_allowlist = {'i', 'n'},
            providers = {
                'lsp',
                'treesitter',
                'regex'
            }
        })
        vim.api.nvim_set_hl(0, 'IlluminatedWordText', { bg = adaptiveBG(40, -40) })
        vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { bg = '#8AC926', fg = '#FFFFFF', bold = true })
        vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { bg = '#FF595E', fg = '#FFFFFF', italic = true })
    end,
    event = { 'CursorHold', 'CursorHoldI' }
}

-- addPlugin { 'azabiong/vim-highlighter', keys = { 'f<CR>' } }

addPlugin {
    'echasnovski/mini.hipatterns',
    event = 'VeryLazy',
    opts = {
        highlighters = {
            bug      = { pattern = '()BUG:()',      group = getTodoHl },
            docs     = { pattern = '()DOCME:()',    group = getTodoHl },
            error    = { pattern = '()ERROR:()',    group = getTodoHl },
            feat     = { pattern = '()FEAT:()',     group = getTodoHl },
            fix      = { pattern = '()FIX:()',      group = getTodoHl },
            hack     = { pattern = '()HACK:()',     group = getTodoHl },
            hint     = { pattern = '()HINT:()',     group = getTodoHl },
            info     = { pattern = '()INFO:()',     group = getTodoHl },
            note     = { pattern = '()NOTE:()',     group = getTodoHl },
            perf     = { pattern = '()PERF:()',     group = getTodoHl },
            refactor = { pattern = '()REFACTOR:()', group = getTodoHl },
            test     = { pattern = '()TEST:()',     group = getTodoHl },
            thought  = { pattern = '()THOUGHT:()',  group = getTodoHl },
            todo     = { pattern = '()TODO:()',     group = getTodoHl },
            warn     = { pattern = '()WARN:()',     group = getTodoHl },
        }
    }
}

-- addPlugin { 'folke/flash.nvim' }

addPlugin {
    'folke/paint.nvim',
    event = 'CursorHold *.lua,*.py',
    opts = {
        highlights = {
            { filter = { filetype = 'lua' },    pattern = '━.*━', hl = "Constant", },
            { filter = { filetype = 'lua' },    pattern = '%s*%-%-%-%s*(@%w+)', hl = "Constant", },
            { filter = { filetype = 'python' }, pattern = '    [%a%d_]+: ',     hl = '@parameter' },
            { filter = { filetype = 'python' }, pattern = 'Args:',              hl = 'Conditional' },
            { filter = { filetype = 'python' }, pattern = 'Returns:',           hl = 'Conditional' },
            { filter = { filetype = 'python' }, pattern = 'Raises:',            hl = 'Conditional' },
        }
    }
}

addPlugin {
    'folke/todo-comments.nvim',
    config = function()
        require('todo-comments').setup({
            colors = Todo_colors,
            keywords = {
                DOCME  = { icon = '', color = 'docs' },
                FEAT   = { icon = '󱩑', color = 'feat' },
                FIX    = { icon = '󰠭', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }},
                HACK   = { icon = '󰑶', color = 'hint' },
                NOTE   = { icon = '', color = 'info', alt = { 'INFO', 'THOUGHT' } },
                PERF   = { icon = '', color = 'perf', alt = { 'OPTIMIZE', 'PERFORMANCE' } },
                RECODE = { icon = '', color = 'info', alt = { 'REFACTOR' } },
                TEST   = { icon = '', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
                TODO   = { icon = '󰸞', color = 'todo' },
                WARN   = { icon = '!', color = 'warn', alt = { 'WARNING' } },
            },
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
    cmd = 'HighlightColorsOn',
    opts = { render = 'background' }
}

addPlugin {
    'nvim-zh/colorful-winsep.nvim',
    opts = {
        create_event = function()
            local win_n = CountWindows(false)
            if win_n < 3 then
                require("colorful-winsep").NvimSeparatorDel()
            end
        end,
        symbols = {
            Icons.border_hor,
            Icons.border_vert,
            Icons.border_topleft,
            Icons.border_topright,
            Icons.border_botleft,
            Icons.border_botright,
        },
    },
    event = 'WinNew'
}

addPlugin {
    't9md/vim-quickhl',
    config = function()
        local colors = {}
        for _,v in pairs(ColorPalette()) do
            local hi = "guifg=" .. v.bg .. " guibg=" .. v.fg
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
---Fix limestone colorscheme
local function fixLimestone()
    require('starry').setup({
        custom_highlights = {
            IblIndent = { fg = '#223216' },
            IblScope = { fg = '#395425' },
            LineNr = { underline = false },
            ['@method'] = { fg = '#4e9ba6', bold = true },
            ['@symbol'] = { fg = '#A30000' }
        }
    })
end

---Fix LineNr highlight
---@param fg string fg color in hex
local function fixLineNr(fg)
    vim.api.nvim_set_hl(0, 'LineNr', { fg = fg })
end

---Fix Visual highlight
---@param bg? string bg color in hex
local function fixVisual(bg)
    bg = bg or adaptiveBG(50, -20)
    vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
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

addPlugin { 'Shatur/neovim-ayu',                       event = 'User ayu'                                              }
addPlugin { 'ribru17/bamboo.nvim',                     event = 'User bamboo'                                           }
addPlugin { 'uloco/bluloco.nvim',                      event = 'User bluloco', dependencies = 'rktjmp/lush.nvim'       }
addPlugin { 'catppuccin/nvim',                         event = 'User catppuccin'                                       }
addPlugin { 'santos-gabriel-dario/darcula-solid.nvim', event = 'User darcula-solid', dependencies = 'rktjmp/lush.nvim' }
addPlugin { 'sainnhe/edge',                            event = 'User edge'                                             }
addPlugin { 'sainnhe/everforest',                      event = 'User everforest'                                       }
addPlugin { 'kaiuri/nvim-juliana',                     event = 'User juliana'                                          }
addPlugin { 'rebelot/kanagawa.nvim',                   event = 'User kanagawa'                                         }
addPlugin { 'marko-cerovac/material.nvim',             event = 'User material'                                         }
addPlugin { 'savq/melange',                            event = 'User melange'                                          }
addPlugin { 'xero/miasma.nvim',                        event = 'User miasma'                                           }
addPlugin { 'polirritmico/monokai-nightasty.nvim',     event = 'User monokai-nightasty'                                }
addPlugin { 'EdenEast/nightfox.nvim',                  event = 'User nightfox'                                         }
addPlugin { 'AlexvZyl/nordic.nvim',                    event = 'User nordic'                                           }
addPlugin { 'cpea2506/one_monokai.nvim',               event = 'User one_monokai'                                      }
addPlugin { 'olimorris/onedarkpro.nvim',               event = 'User onedarkpro'                                       }
addPlugin { 'rmehri01/onenord.nvim',                   event = 'User onenord'                                          }
addPlugin { 'nyoom-engineering/oxocarbon.nvim',        event = 'User oxocarbon'                                        }
addPlugin { 'rose-pine/neovim',                        event = 'User rose-pine'                                        }
addPlugin { 'lewpoly/sherbet.nvim',                    event = 'User sherbet'                                          }
addPlugin { 'sainnhe/sonokai',                         event = 'User sonokai'                                          }
addPlugin { 'tiagovla/tokyodark.nvim',                 event = 'User tokyodark'                                        }
addPlugin { 'folke/tokyonight.nvim',                   event = 'User tokyonight'                                       }
addPlugin { 'askfiy/visual_studio_code',               event = 'User visual_studio_code'                               }
addPlugin { 'nxvu699134/vn-night.nvim',                event = 'User vn-night'                                         }
addPlugin { 'Mofiqul/vscode.nvim',                     event = 'User vscode'                                           }
addPlugin { 'titanzero/zephyrium',                     event = 'User zephyrium'                                        }

dark  { 'ayu-dark',             'ayu'                              }
-- dark  { 'ayu-mirage',           'ayu'                              }
-- dark  { 'bamboo',               '_', cfg = { style = 'multiplex' } }
-- dark  { 'bluloco-dark',         '_'                                                    }
dark  { 'catppuccin-macchiato', 'catppuccin'                                           }
dark  { 'darcula-solid',        '_'                                                    }
dark  { 'duskfox',              'nightfox'                                             }
dark  { 'edge',                 '_' }
-- dark  { 'everforest',           '_' }
dark  { 'juliana',              '_', post = function() fixLineNr('#999999') end }
-- dark  { 'kanagawa-wave',        'kanagawa'                                      }
dark  { 'melange',              '_' }
dark  { 'nordic',               '_', cfg = { override = { IblScope = { fg = '#7E8188' } } } }
dark  { 'one_monokai',          '_'          }
dark  { 'onedark',              'onedarkpro' }
dark  { 'onenord',              '_'          }
dark  { 'retrobox',             '_'          }
-- dark  { 'rose-pine',            '_', cfg = { disable_italics = true }                            }
dark  { 'sherbet',              '_' }
-- dark  { 'sonokai',              '_', pre = function() vim.g.sonokai_style = 'shusia' end }
dark  { 'tokyodark',            '_'                                          }
dark  { 'tokyonight-storm',     'tokyonight'                                 }
dark  { 'visual_studio_code',   '_'                               }
-- dark  { 'vn-night',             '_', post = fixVnNight            }
-- dark  { 'zephyrium',            '_'                               }
-- darkT { 'bamboo',               '_', cfg = { style = 'multiplex', transparent = true } }
-- darkT { 'bluloco-dark',         '_', cfg = { 'bluloco', { transparent = true } }       }
-- darkT { 'duskfox',              'nightfox', cfg = { transparent = true }               }
-- darkT { 'kanagawa-wave',        'kanagawa', cfg = { transparent = true }        }
-- darkT { 'rose-pine',            '_', cfg = { disable_background = true, disable_italics = true } }
-- darkT { 'tokyodark',            '_', cfg = { transparent_background = true } }
-- darkT { 'tokyonight-storm',     'tokyonight', cfg = { transparent = true }   }
-- darkT { 'visual_studio_code',   '_', cfg = { transparent = true } }
-- light { 'ayu-light',            'ayu'                              }
-- light { 'catppuccin-latte',     'catppuccin'                                           }
-- light { 'edge',                 '_' }
-- light { 'material',             '_', pre = function() vim.g.material_style = 'lighter' end, post = function() fixVisual('#CCEAE7') end }
-- light { 'monokai-nightasty',    '_' }
-- light { 'onelight',             '_'          }
-- light { 'onenord',              '_'          }
-- light { 'oxocarbon',            '_'          }
-- light { 'tokyonight-day',       'tokyonight'                                 }

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

    -- Fix Todo highlight
    local todo_hl = vim.api.nvim_get_hl(0, { name = 'Todo', create = false })
    if todo_hl and todo_hl.bg then
        todo_hl.fg = todo_hl.bg
        todo_hl.bg = nil
        vim.api.nvim_set_hl(0, 'Todo', todo_hl)
    end

    vim.g.ColoRand = '[' .. scheme_index .. ']' .. scheme .. elapsed
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
    end,
    keys = {
        { 'gc', mode = { 'n', 'v' } },
        { 'gb', mode = { 'n', 'v' } },
        'gcc', 'gbc', 'gcO', 'gco', 'gce'
    }
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Completion   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/hrsh7th/cmp-omni
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/uga-rosa/cmp-dynamic

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

addPlugin {
    'hrsh7th/cmp-path',
    event = 'CmdlineChanged'
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
                    { name = 'cmdline' },
                    { name = 'path' },
                }
            }),
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = 'buffer' } }
            }),
            completion = {
                keyword_length = 2
            },
            experimental = {
                ghost_text = true
            },
            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(entry, vim_item)
                    if entry.source.name == 'nvim_lsp' then
                        vim_item.menu = '{' .. entry.source.source.client.name .. '}'
                    elseif entry.source.name == 'cmdline' then
                        vim_item.kind = 'Options'
                    elseif entry.source.name == 'cmdline_history' then
                        vim_item.kind = 'History'
                    else
                        vim_item.menu = '[' .. entry.source.name .. ']'
                    end
                    local kind_symbol = Icons[vim_item.kind]
                    vim_item.kind = kind_symbol or vim_item.kind

                    return vim_item
                end
            },
            mapping = cmp.mapping.preset.insert({ -- arrow keys + enter to select
                ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Scroll the documentation window if visible
                ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Scroll the documentation window if visible
                ['<C-e>'] = cmp.mapping.abort(),
                ['<TAB>'] = cmp.mapping.confirm({ select = true }),
            }),
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
                { name = 'path', trigger_characters = { './', '/', '.\\' } },
                { name = 'async_path', trigger_characters = { './', '/', '.\\' } },
                { name = 'snippy' },
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            view = {
                docs = {
                    auto_open = true
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
    event = 'CmdlineChanged',
}

-- https://github.com/L3MON4D3/cmp-luasnip-choice
-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Debugger    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    'LiadOz/nvim-dap-repl-highlights',
    config = true
}

addPlugin {
    'andrewferrier/debugprint.nvim',
    opts = {
        create_keymaps = false,
        create_commands = false,
        filetypes = {
            ['python'] = {
                left = 'print(f"',
                mid_var = '{',
                right_var = '}")',
                right = '")',
            }
        }
    },
    keys = {
        { '<Leader>dP', function() return require('debugprint').debugprint({ above = true }) end,                  expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true, variable = true }) end, expr = true, mode = 'n' },
        { '<Leader>dV', function() return require('debugprint').debugprint({ above = true, variable = true }) end, expr = true, mode = 'v' },
        { '<Leader>dd', function() return require('debugprint').deleteprints() end,                                             mode = 'n' },
        { '<Leader>dp', function() return require('debugprint').debugprint() end,                                  expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,               expr = true, mode = 'n' },
        { '<Leader>dv', function() return require('debugprint').debugprint({ variable = true }) end,               expr = true, mode = 'v' },
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
    end
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Doc Generater  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    'danymat/neogen',
    cmd = 'Neogen',
    opts = {
        input_after_comment = true,
        snippet_engine = "snippy"
    }
}
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ File Explorer  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/nat-418/scamp.nvim
-- https://github.com/nosduco/remote-sshfs.nvim
addPlugin {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeOpen',
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
                error   = Icons.error,
                hint    = Icons.hint,
                info    = Icons.info,
                warning = Icons.warn,
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

                    openFloat(path, 'editor', vim.fn.winwidth(0) + 2, 3, true)
                end
            end

            local api = require('nvim-tree.api')
            vim.keymap.set('n', '<C-e>',          api.node.open.replace_tree_buffer,  opts('Open: In Place'))
            vim.keymap.set('n', '<leader>h',      api.node.show_info_popup,           opts('Info'))
            vim.keymap.set('n', '<F2>',           api.fs.rename_sub,                  opts('Rename: Omit Filename'))
            vim.keymap.set('n', '<C-t>',          api.node.open.tab,                  opts('Open: New Tab'))
            vim.keymap.set('n', '<C-v>',          api.node.open.vertical,             opts('Open: Vertical Split'))
            vim.keymap.set('n', '<C-s>',          api.node.open.horizontal,           opts('Open: Horizontal Split'))
            vim.keymap.set('n', '<CR>',           api.node.open.edit,                 opts('Open'))
            vim.keymap.set('n', '<Tab>',          custom_preview,                     opts('Open Preview'))
            vim.keymap.set('n', '>',              api.node.navigate.sibling.next,     opts('Next Sibling'))
            vim.keymap.set('n', '<',              api.node.navigate.sibling.prev,     opts('Previous Sibling'))
            vim.keymap.set('n', '-',              api.tree.change_root_to_parent,     opts('Up'))
            vim.keymap.set('n', 'a',              api.fs.create,                      opts('Create'))
            vim.keymap.set('n', 'bd',             api.marks.bulk.delete,              opts('Delete Bookmarked'))
            vim.keymap.set('n', 'bmv',            api.marks.bulk.move,                opts('Move Bookmarked'))
            vim.keymap.set('n', 'c',              api.fs.copy.node,                   opts('Copy'))
            vim.keymap.set('n', '[c',             api.node.navigate.git.prev,         opts('Prev Git'))
            vim.keymap.set('n', ']c',             api.node.navigate.git.next,         opts('Next Git'))
            vim.keymap.set('n', 'd',              api.fs.remove,                      opts('Delete'))
            vim.keymap.set('n', 'D',              api.fs.trash,                       opts('Trash'))
            vim.keymap.set('n', 'E',              api.tree.expand_all,                opts('Expand All'))
            vim.keymap.set('n', ']d',             api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
            vim.keymap.set('n', '[d',             api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
            vim.keymap.set('n', 'F',              api.live_filter.clear,              opts('Clean Filter'))
            vim.keymap.set('n', 'f',              api.live_filter.start,              opts('Filter'))
            vim.keymap.set('n', 'g?',             api.tree.toggle_help,               opts('Help'))
            vim.keymap.set('n', 'gy',             api.fs.copy.absolute_path,          opts('Copy Absolute Path'))
            vim.keymap.set('n', 'H',              api.tree.toggle_hidden_filter,      opts('Toggle Filter: Dotfiles'))
            vim.keymap.set('n', 'I',              api.tree.toggle_gitignore_filter,   opts('Toggle Filter: Git Ignore'))
            vim.keymap.set('n', 'bm',             api.marks.toggle,                   opts('Toggle Bookmark'))
            vim.keymap.set('n', 'o',              api.node.open.edit,                 opts('Open'))
            vim.keymap.set('n', 'O',              api.node.open.no_window_picker,     opts('Open: No Window Picker'))
            vim.keymap.set('n', 'p',              api.fs.paste,                       opts('Paste'))
            vim.keymap.set('n', 'P',              api.node.navigate.parent,           opts('Parent Directory'))
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
            vim.keymap.set('n', '<2-LeftMouse>',  api.node.open.edit,                 opts('Open'))
            vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node,       opts('CD'))
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
                    item   = '├',
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
                    bookmark = Icons.bookmark,
                    default  = Icons.file_unnamed,
                    folder = {
                        arrow_closed = '',
                        arrow_open   = '',
                        default      = '',
                        empty        = '',
                        empty_open   = '',
                        open         = '',
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
                        untracked = Icons.file_unnamed,
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
                symlink_arrow = Icons.symlink_arrow,
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  File Options  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
    ['markdown'] = function()
        vim.g.table_mode_corner = '|'
        MarkdownHeadingsHighlight()
    end,
    ['python'] = function(bufnr)
        local highlighter = require('vim.treesitter.highlighter')
        if highlighter.active[bufnr] then
            require('ufo').attach(bufnr)
        else
            vim.api.nvim_create_autocmd(
                'User', {
                    pattern = 'TSLoaded',
                    desc = 'Attach nvim-ufo after loading treesitter',
                    once = true,
                    callback = function(arg)
                        require('ufo').attach(arg.buf)
                    end
                }
            )
        end
    end
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
                vim.api.nvim_del_autocmd(arg.id)
            end
        end
    }
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Folding     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Formatting   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- addPlugin {
--     'sbdchd/neoformat',
--     cmd = 'Neoformat'
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Git       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
    cmd = 'ToggleBlame'
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

addPlugin {
    -- https://github.com/lewis6991/gitsigns.nvim/issues/927
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
            add          = { hl = 'GitSignsAdd'   ,       text = Icons.diff_add, numhl           = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'   , show_count = false },
            change       = { hl = 'GitSignsChange',       text = Icons.diff_change, numhl        = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
            changedelete = { hl = 'GitSignsChangedelete', text = Icons.diff_change_delete, numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
            delete       = { hl = 'GitSignsDelete',       text = Icons.diff_delete, numhl        = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
            topdelete    = { hl = 'GitSignsDelete',       text = Icons.diff_delete_top, numhl    = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
        },
        trouble = false
    }
}

addPlugin {
    'sindrets/diffview.nvim',
    cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Icons      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
            cs       = { color = '#C20DA6', cterm_color = '58',  icon = '', name = 'Cs'        },
            csproj   = { color = '#854CC7', cterm_color = '98',  icon = '', name = 'Csproj'    },
            csv      = { color = '#89E051', cterm_color = '113', icon = '', name = 'Csv'       },
            md       = { color = '#42A5F5', cterm_color = '75',  icon = '', name = 'Md'        },
            mdx      = { color = '#519ABA', cterm_color = '67',  icon = '', name = 'Mdx'       },
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Indentation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
            char = '▎',
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      LSP       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
            code_action = Icons.code_action,
            collapse = '',
            devicon = true,
            diagnostic = Icons.diagnostic,
            expand = '',
            hover = Icons.hover,
            incoming = Icons.incoming,
            kind = {
                Array         = { Icons.Array,         'CmpItemKindArray',        },
                Boolean       = { Icons.Boolean,       'CmpItemKindBoolean',      },
                Class         = { Icons.Class,         'CmpItemKindClass',        },
                Constant      = { Icons.Constant,      'CmpItemKindConstant',     },
                Constructor   = { Icons.Constructor,   'CmpItemKindConstructor',  },
                Enum          = { Icons.Enum,          'CmpItemKindEnum',         },
                EnumMember    = { Icons.EnumMember,    'CmpItemKindEnumMember',   },
                Event         = { Icons.Event,         'CmpItemKindEvent',        },
                Field         = { Icons.Field,         'CmpItemKindField',        },
                File          = { Icons.File,          'CmpItemKindFile',         },
                Folder        = { Icons.Folder,        'CmpItemKindFolder',       },
                Function      = { Icons.Function,      'CmpItemKindFunction',     },
                Interface     = { Icons.Interface,     'CmpItemKindInterface',    },
                Key           = { Icons.Key,           'CmpItemKindKey',          },
                Macro         = { Icons.Macro,         'CmpItemKindMacro',        },
                Method        = { Icons.Method,        'CmpItemKindMethod',       },
                Module        = { Icons.Module,        'CmpItemKindModule',       },
                Namespace     = { Icons.Namespace,     'CmpItemKindNamespace',    },
                Null          = { Icons.Null,          'CmpItemKindNull',         },
                Number        = { Icons.Number,        'CmpItemKindNumber',       },
                Object        = { Icons.Object,        'CmpItemKindObject',       },
                Operator      = { Icons.Operator,      'CmpItemKindOperator',     },
                Package       = { Icons.Package,       'CmpItemKindPackage',      },
                Parameter     = { Icons.Parameter,     'CmpItemKindParameter',    },
                Property      = { Icons.Property,      'CmpItemKindProperty',     },
                Snippet       = { Icons.Snippet,       'CmpItemKindSnippet',      },
                StaticMethod  = { Icons.StaticMethod,  'CmpItemKindStaticMethod', },
                String        = { Icons.String,        'CmpItemKindString',       },
                Struct        = { Icons.Struct,        'CmpItemKindStruct',       },
                Text          = { Icons.Text,          'CmpItemKindText',         },
                TypeAlias     = { Icons.TypeAlias,     'CmpItemKindTypeAlias',    },
                TypeParameter = { Icons.TypeParameter, 'CmpItemKindTypeParameter',},
                Unit          = { Icons.Unit,          'CmpItemKindUnit',         },
                Value         = { Icons.Value,         'CmpItemKindValue',        },
                Variable      = { Icons.Variable,      'CmpItemKindVariable',     },
            },
            lines = { '╰', '├', '│', '─', '╭' },
            outgoing = Icons.outgoing,
            preview = Icons.preview,
            title  = true,
        }
    }
}

addPlugin {
    'hinell/lsp-timeout.nvim',
    event = 'LspAttach'
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

-- https://github.com/mattn/efm-langserver
-- https://github.com/mfussenegger/nvim-lint
-- https://github.com/nkoporec/checkmate-lsp
-- https://github.com/p00f/clangd_extensions.nvim'

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
        local mason_lspconfig = require('mason-lspconfig')
        local on_attach = function(_, bufnr)
            vim.lsp.inlay_hint.enable(bufnr, true)

            -- Mappings.
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<F12>', '<cmd>Lspsaga goto_definition<CR>', bufopts)
            vim.keymap.set('n', '<F2>', '<cmd>Lspsaga rename<CR>', bufopts)
            vim.keymap.set('n', '<M-F12>', '<cmd>Lspsaga finder<CR>', bufopts)
            vim.keymap.set('n', '<S-F12>', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<leader>h', '<cmd>Lspsaga hover_doc<CR>', bufopts)
            vim.keymap.set('n', '<space>ca', require("actions-preview").code_actions, bufopts)
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
                {'Code Action     <space>ca',  '<Cmd>lua require("actions-preview").code_actions()<CR>'},
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
    dependencies = { 'luukvbaal/statuscol.nvim', 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
    keys = { '<F12>' }
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Markdown    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
        require('hl-mdcodeblock').setup({
            events = {
                "BufEnter",
                "InsertLeave",
                "TextChanged",
                "WinScrolled"
            },
            hl_group = "MDCodeBlock",
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
        vim.api.nvim_set_hl(0, "MDCodeBlock", { bg = adaptiveBG(30, -10) })
        require('hl-mdcodeblock').refresh()
    end,
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = 'CursorHold *.md'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Marks      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
        vim.g.bookmark_annotation_sign = Icons.bookmark_annotate
        vim.g.bookmark_display_annotation = 1
        vim.g.bookmark_highlight_lines = 1
        vim.g.bookmark_location_list = 1
        vim.g.bookmark_no_default_key_mappings = 1
        vim.g.bookmark_save_per_working_dir = 0
        vim.g.bookmark_sign = Icons.bookmark
    end,
    dependencies = 'luukvbaal/statuscol.nvim',
    keys = {
        {'ba', '<Plug>BookmarkAnnotate'},
        {'bm', '<Plug>BookmarkToggle'},
        {'bn', '<Plug>BookmarkNext'},
        {'bp', '<Plug>BookmarkPrev'},
        {'bs', '<Plug>BookmarkShowAll'}
    }
}

-- https://github.com/cbochs/grapple.nvim
-- addPlugin {
--     'kshenoy/vim-signature',
--     cmd = 'SignatureToggle'
-- }
-- use 'chentoast/marks.nvim'
-- use 'crusj/bookmarks.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Outline     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
        icons = Icons,
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Quickfix    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
addPlugin {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
    opts = {
        action_keys = {
            close = 'q',
            cancel = '<esc>',
            refresh = 'r',
            jump = { '<cr>', '<tab>' },
            open_split = { '<c-s>' },
            open_vsplit = { '<c-v>' },
            open_tab = { '<c-t>' },
            jump_close = { 'o' },
            toggle_mode = 'm',
            toggle_preview = 'P',
            hover = 'K',
            preview = 'p',
            close_folds = { 'zM', 'zm' },
            open_folds = { 'zR', 'zr' },
            toggle_fold = { 'zA', 'za' },
            previous = 'k',
            next = 'j',
        },
        auto_close = false,
        auto_fold = false,
        auto_jump = { 'lsp_definitions' },
        auto_open = false,
        auto_preview = true,
        fold_closed = '',
        fold_open = '',
        group = true,
        height = 10,
        icons = true,
        indent_lines = true,
        mode = 'document_diagnostics',
        padding = false,
        position = 'bottom',
        signs = {
            error = Icons.error,
            hint = Icons.hint,
            information = Icons.info,
            other = Icons.diagnostic,
            warning = Icons.warn,
        },
        use_diagnostic_signs = true,
        width = 50,
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
                border = Dotted_border,
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Rooter     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Sessions    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/aaditeynair/conduct.nvim
addPlugin {
    'rmagatti/auto-session',
    cmd = 'SessionSave',
    config = function()
        vim.g.auto_session_suppress_dirs = { 'C:\\Users\\aloknigam', '~' }
        require('auto-session').setup({
            -- log_level = 'debug',
            post_delete_cmds = {
                "let g:auto_session_enabled = v:false",
                "let g:session_icon = ''"
            },
            post_restore_cmds = {
                "let g:session_icon = ''"
            },
            post_save_cmds = {
                "let g:session_icon = ''"
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Snippets    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
-- https://github.com/ellisonleao/carbon-now.nvim
-- https://github.com/norcalli/snippets.nvim
-- https://github.com/notomo/cmp-neosnippet
-- https://github.com/quangnguyen30192/cmp-nvim-ultisnips
-- https://github.com/rafamadriz/friendly-snippets
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/smjonas/snippet-converter.nvim
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Status Column  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    'luukvbaal/statuscol.nvim',
    config = function()
        local builtin = require('statuscol.builtin')
        require('statuscol').setup({
            setopt = true,
            relculright = true,
            segments = {
                {
                    sign = { name = { 'todo' } },
                    condition = { function() return TODO_COMMENTS_LOADED ~= nil end },
                    auto = true,
                },
                { sign = { name = { 'Diagnostic' }, fillcharhl ='LineNr', auto = true }, click = 'v:lua.ScSa' },
                { sign = { name = { 'Bookmark' }, fillcharhl ='LineNr', auto = true } },
                { sign = { name = { 'Dap' }, fillcharhl ='LineNr', auto = true } },
                { text = { builtin.lnumfunc }, click = 'v:lua.ScLa', condition = { true } },
                {
                    sign = {
                        text = {
                            Icons.diff_add,
                            Icons.diff_change,
                            Icons.diff_delete,
                            Icons.diff_delete_top,
                            Icons.diff_change_delete,
                        },
                        colwidth = 1,
                        fillcharhl = 'LineNr',
                        wrap = true,
                    },
                    click = 'v:lua.ScSa',
                },
                { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
            },
        })
    end,
    enabled = true
}
--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Status Line   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    'nvim-lualine/lualine.nvim',
    config = function()
        local function lspIcon()
            local anim ={ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
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
                section_separators = { left = '', right = ''},
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
                            vim.cmd('NvimTreeToggle')
                        end,
                        path = 0,
                        padding = { left = 1, right = 1 },
                        shorting_target = 40,
                        symbols = {
                            modified = Icons.file_modified,
                            readonly = Icons.file_readonly,
                            unnamed  = Icons.file_unnamed,
                            newfile  = Icons.file_newfile
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
                        icon = {'󰱽', color = {fg = '#EAC435'}},
                        padding = { left = 0, right = 1 },
                        separator = ''
                    },
                    {
                        'selectioncount',
                        color = { fg = '#BA2C73' },
                        icon = { '', color = { fg = '#963484' }},
                        padding = { left = 0, right = 1 },
                        separator = ''
                    },
                    {
                        'diagnostics',
                        on_click = function()
                            vim.cmd('TroubleToggle')
                        end,
                        padding = { left = 1, right = 0 },
                        sources = { 'nvim_diagnostic' },
                        symbols = {
                            error = Icons.error,
                            warn  = Icons.warn,
                            info  = Icons.info,
                            hint  = Icons.hint
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
                                ['ALOKNIGAM-IDC'] = "devbox"
                            }
                            return alias[str] or str
                        end,
                        icon = { '', color = { fg = '#3066BE' }},
                        padding = { left = 0, right = 1 }
                    },
                    {
                        function() return vim.g.ColoRand end,
                        color = { fg = GetFgOrFallback('Number', '#F2F230') },
                        icon = {'', color = { fg = string.format("#%X", vim.api.nvim_get_hl(0, { name = 'Function', create = false, link = false }).fg)}},
                        padding = { left = 1, right = 1 }
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
                        path = 0,
                        shorting_target = 40,
                        symbols = {
                            modified = Icons.file_modified,
                            readonly = Icons.file_readonly,
                            unnamed  = Icons.file_unnamed,
                            newfile  = Icons.file_newfile,
                        }
                    }
                },
                lualine_c = {
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
                            modified = Icons.file_modified,
                            readonly = Icons.file_readonly,
                            unnamed  = Icons.file_unnamed,
                            newfile  = Icons.file_newfile,
                        }
                    }
                },
            },
            extensions = {
                'aerial',
                'lazy',
                'mason',
                'nvim-dap-ui',
                'nvim-tree',
                'quickfix',
                'toggleterm',
                'trouble',
            }
        }
    end,
    event = 'User VeryLazy',
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
                    res = res .. Icons[k] .. v .. ' '
                end
                return res
            end,
            get_element_icon = function(element)
                local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
                if element.filetype == 'netrw' then
                    icon = ''
                elseif element.path == '[No Name]' then
                    icon = Icons.file_newfile
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
            right_mouse_command = nil,
            separator_style = 'thick'
        }
    }
}
-- https://github.com/tomiis4/BufferTabs.nvim
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Telescope   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/Marskey/telescope-sg
-- https://github.com/axkirillov/easypick.nvim
addPlugin {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
        local actions = require 'telescope.actions'
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
        vim.cmd[[autocmd User TelescopePreviewerLoaded setlocal nu]]
    end,
    dependencies = {
        'debugloop/telescope-undo.nvim',
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    module = false
}

addPlugin {
    'princejoogie/dir-telescope.nvim',
    cmd = { 'FileInDirectory', 'GrepInDirectory' },
    config = true,
    dependencies = 'nvim-telescope/telescope.nvim',
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Terminal    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/voldikss/vim-floaterm
addPlugin {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Tests      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/andythigpen/nvim-coverage
-- addPlugin {
--     'nvim-neotest/neotest',
--     config = function()
--         require('neotest').setup({
--             adapters = {
--                 require('neotest-python')
--             }
--         })
--     end,
--     dependencies = {
--         'nvim-lua/plenary.nvim',
--         'nvim-neotest/neotest-python'
--     },
--     lazy = false
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Treesitter   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    -- https://github.com/AckslD/nvim-trevJ.lua
    -- https://github.com/AndrewRadev/splitjoin.vim
    -- https://github.com/CKolkey/ts-node-action
    -- https://github.com/echasnovski/mini.splitjoin
    'Wansmer/treesj',
    cmd = 'TSJToggle',
    opts = {
        max_join_length = 10000
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
    -- https://github.com/David-Kunz/markid
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
            hl_priority = Hl_priority.hlargs,
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
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━       UI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
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
                    lazy = { pattern = '^:%s*Lazy%s+', icon = '', lang = 'vim' , title = ' Lazy '},
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
            commands = {
                history = {
                    view = 'split',
                    opts = { enter = true, format = 'details' },
                    filter = {
                        any = {
                            { event = 'notify' },
                            { error = true },
                            { warning = true },
                            { event = 'msg_show', kind = { '' } },
                            { event = 'lsp', kind = 'message' },
                        },
                    },
                },
                last = {
                    view = 'popup',
                    opts = { enter = true, format = 'details' },
                    filter = {
                        any = {
                            { event = 'notify' },
                            { error = true },
                            { warning = true },
                            { event = 'msg_show', kind = { '' } },
                            { event = 'lsp', kind = 'message' },
                        },
                    },
                    filter_opts = { count = 1 },
                },
                errors = {
                    view = 'popup',
                    opts = { enter = true, format = 'details' },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
            },
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
                signature = {
                    enabled = true,
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
                    view = 'notify',
                    opts = {},
                },
                documentation = {
                    view = 'hover',
                    opts = {
                        lang = 'markdown',
                        replace = true,
                        render = 'plain',
                        format = { '{message}' },
                        win_options = { concealcursor = 'n', conceallevel = 3 },
                    },
                },
            },
            markdown = {
                hover = {
                    ['|(%S-)|'] = vim.cmd.help,
                    ['%[.-%]%((%S-)%)'] = require('noice.util').open,
                },
                highlights = {
                    ['|%S-|'] = '@text.reference',
                    ['@%S+'] = '@parameter',
                    ['^%s*(Parameters:)'] = '@text.title',
                    ['^%s*(Return:)'] = '@text.title',
                    ['^%s*(See also:)'] = '@text.title',
                    ['{%S-}'] = '@parameter',
                },
            },
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
            throttle = 1000 / 30,
            views = {},
            routes = {{
                view = 'notify',
                filter = { event = 'msg_showmode' },
            }},
            status = {},
            format = {},
        })
    end,
    dependencies = { 'MunifTanjim/nui.nvim' },
    enabled = true,
    event = 'CmdlineEnter'
}

addPlugin {
    'rcarriga/nvim-notify',
    config = function()
        local notify = require('notify')
        notify.setup({
            minimum_width = 0,
            render = 'minimal',
            stages = 'slide'
        })
        vim.notify = notify

        -- Fix Notify hl
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
    'stevearc/dressing.nvim'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Utilities    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
addPlugin {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- https://github.com/EtiamNullam/deferred-clipboard.nvim

-- addPlugin {
--     'ThePrimeagen/refactoring.nvim',
--     cmd = 'Refactor',
--     config = true,
--     dependencies = {
--         {'nvim-lua/plenary.nvim'},
--     }
-- }

addPlugin {
    'TobinPalmer/BetterGx.nvim',
    keys = {
        { 'gx', '<CMD>lua require("better-gx").BetterGx()<CR>' },
    }
}

-- https://github.com/anuvyklack/hydra.nvim

addPlugin {
    'cbochs/portal.nvim',
    cmd = 'Portal',
    dependencies = { 'ThePrimeagen/harpoon', 'cbochs/grapple.nvim' }
}

-- https://github.com/chipsenkbeil/distant.nvim

addPlugin {
    -- https://github.com/cameron-wags/rainbow_csv.nvim
    -- https://github.com/mechatroner/rainbow_csv
    'chrisbra/csv.vim',
    config = function()
        vim.g.csv_default_delim = ','
        vim.g.csv_highlight_column = 'y'
    end,
    ft = 'csv'
}

-- https://github.com/cshuaimin/ssr.nvim

-- addPlugin {
--     'dstein64/vim-startuptime',
--     cmd = 'StartupTime'
-- }

-- https://github.com/dstein64/nvim-scrollview
addPlugin {
    'echasnovski/mini.map',
    config = function ()
        local minimap = require('mini.map')
        minimap.setup({
            integrations = {
                minimap.gen_integration.builtin_search(),
                minimap.gen_integration.gitsigns(),
                minimap.gen_integration.diagnostic(),
            },
            symbols = {
                encode = minimap.gen_encode_symbols.dot('4x2')
            }
        })
    end
}

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

-- 'jbyuki/instant.nvim'

addPlugin {
    'gbprod/yanky.nvim',
    opts = {
        ring = {
            history_length = 100,
            storage = "memory",
            sync_with_numbered_registers = true,
            cancel_event = "update",
        },
        system_clipboard = {
            sync_with_ring = false,
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

-- addPlugin {
--     'kylechui/nvim-surround',
--     config = true
-- }

-- https://github.com/lewis6991/hover.nvim

addPlugin {
    'mg979/vim-visual-multi',
    config = function()
        vim.cmd[[
            nmap <C-LeftMouse> <Plug>(VM-Mouse-Cursor)
            nmap <C-RightMouse> <Plug>(VM-Mouse-Word)
        ]]
    end,
    keys = { '<C-LeftMouse>', '<C-RightMouse>', '<C-Up>', '<C-Down>', '<C-N>' }
}

-- https://github.com/mrshmllow/open-handlers.nvim

addPlugin {
    'nat-418/boole.nvim',
    opts = {
        mappings = {
            increment = '<C-a>',
            decrement = '<C-x>'
        },
        -- User defined loops
        additions = {
            { 'buy', 'sell' }
        },
        allow_caps_additions = {
        }
    },
    keys = { '<C-a>', '<C-x>' }
}

addPlugin {
    -- Lua copy https://github.com/ojroques/nvim-osc52
    -- :h clipboard-osc52
    'ojroques/vim-oscyank',
    cond = function()
        return vim.env.SSH_CLIENT ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif]]
    end,
    lazy = false
}

addPlugin {
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
}

-- https://github.com/roobert/surround-ui.nvim

addPlugin {
    'sickill/vim-pasta',
    config = function()
        vim.g.pasta_paste_before_mapping = '[P'
        vim.g.pasta_paste_after_mapping = '[p'
    end,
    lazy = false
}

addPlugin {
    'shortcuts/no-neck-pain.nvim',
    cmd = 'NoNeckPain'
}

addPlugin {
    'tversteeg/registers.nvim', -- Insert more does not work good with new lines
    opts = {
        register_user_command = false,
        show = "0123456789abcdefghijklmnopqrstuvwxyz*+\"-/_=",
        show_empty = false,
        symbols = { newline = '', tab = '»' },
        trim_whitespace = false,
        window = { border = 'rounded' }
    },
    keys = {
        { '"',     mode = 'n' },
        { '"',     mode = 'v' },
        { '<C-R>', mode = 'i' }
    }
}

addPlugin {
    'utilyre/sentiment.nvim',
    config = true,
    event = { 'CursorHold', 'CursorHoldI' }
}

-- https://github.com/wellle/targets.vim
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-fuzzy.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-surround.md

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Winbar     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO:
addPlugin {
    'Bekaboo/dropbar.nvim',
    opts = {
        icons = {
            enable = true,
            kinds = {
                use_devicons = true,
                symbols = {
                    Array = Icons.Array,
                    Boolean = Icons.Boolean,
                    BreakStatement = '󰙧 ',
                    Call = '󰃷 ',
                    CaseStatement = '󱃙 ',
                    Class = Icons.Class,
                    Color = Icons.Color,
                    Constant = Icons.Constant,
                    Constructor = Icons.Constructor,
                    ContinueStatement = '→ ',
                    Copilot = ' ',
                    Declaration = '󰙠 ',
                    Delete = '󰩺 ',
                    DoStatement = '󰑖 ',
                    Enum = Icons.Enum,
                    EnumMember = Icons.EnumMember,
                    Event = Icons.Event,
                    Field = Icons.Field,
                    File = Icons.File,
                    Folder = Icons.Folder,
                    ForStatement = '󰑖 ',
                    Function = Icons.Function,
                    H1Marker = '󰉫 ',
                    H2Marker = '󰉬 ',
                    H3Marker = '󰉭 ',
                    H4Marker = '󰉮 ',
                    H5Marker = '󰉯 ',
                    H6Marker = '󰉰 ',
                    Identifier = '󰀫 ',
                    IfStatement = '󰇉 ',
                    Interface = Icons.Interface,
                    Keyword = Icons.Keyword,
                    List = '󰅪 ',
                    Log = '󰦪 ',
                    Lsp = ' ',
                    Macro = Icons.Macro,
                    MarkdownH1 = '󰉫 ',
                    MarkdownH2 = '󰉬 ',
                    MarkdownH3 = '󰉭 ',
                    MarkdownH4 = '󰉮 ',
                    MarkdownH5 = '󰉯 ',
                    MarkdownH6 = '󰉰 ',
                    Method = Icons.Method,
                    Module = Icons.Module,
                    Namespace = Icons.Namespace,
                    Null = Icons.Null,
                    Number = Icons.Number,
                    Object = Icons.Object,
                    Operator = Icons.Operator,
                    Package = Icons.Package,
                    Pair = '󰅪 ',
                    Property = Icons.Property,
                    Reference = Icons.Reference,
                    Regex = ' ',
                    Repeat = '󰑖 ',
                    Scope = '󰅩 ',
                    Snippet = Icons.Snippet,
                    Specifier = '󰦪 ',
                    Statement = '󰅩 ',
                    String = Icons.String,
                    Struct = Icons.Struct,
                    SwitchStatement = '󰺟 ',
                    Terminal = ' ',
                    Text = Icons.Text,
                    Type = ' ',
                    TypeParameter = Icons.TypeParameter,
                    Unit = Icons.Unit,
                    Value = Icons.Value,
                    Variable = Icons.Variable,
                    WhileStatement = '󰑖 ',
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
require('lazy').setup(Plugins, Lazy_config)
ColoRand()
-- <~>
-- vim: fmr=</>,<~> fdm=marker textwidth=120
