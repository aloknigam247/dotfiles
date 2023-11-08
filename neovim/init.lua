--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Profiling   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
---@class Profile
---@field count integer Number of times an autocommand is invoked
---@field start number Start time of current autocommand
---@field avg number Avergae time taken by autocommand
---@field total number Total time taken by autocommand
---@alias ProfileData table<string, Profile>
---Constains Autocommand profiling data
---@type ProfileData?
AuProfileData = {}

--@type bool Switch to toggle Autocommand profiling
AuProfileEnabled = false

---Collect autocommand data at autocommand startup, called for each event
---@param args any Autocommand callback data
function AuProfileStart(args)
    local event = args.event

    if AuProfileEnabled then
        local data = AuProfileData[event] or {}
        data['count'] = (data.count or 0) + 1
        data['start'] = os.clock()
        AuProfileData[event] = data
    end
end

---Collect autocommand data at autocommand startup, called for each event
---@param args any Autocommand callback data
function AuProfileEnd(args)
    if AuProfileEnabled then
        local data = AuProfileData[args.event]
        if data then
            local elapsed = os.clock() - data.start
            local total = (data.total or 0) + elapsed

            data['avg'] = total / data.count
            data['total'] = total

            AuProfileData[args.event] = data
        end
    end
end

---List of all valid autocommands to profile
---@type string[]
Event_list = { "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "BufFilePre", "BufHidden", "BufLeave", "BufModifiedSet", "BufNew", "BufNewFile", "BufRead", "BufReadPre", "BufUnload", "BufWinEnter", "BufWinLeave", "BufWipeout", "BufWrite or BufWritePre", "BufWritePost", "ChanInfo", "ChanOpen", "CmdUndefined", "CmdlineChanged", "CmdlineEnter", "CmdlineLeave", "CmdwinEnter", "CmdwinLeave", "ColorScheme", "ColorSchemePre", "CompleteChanged", "CompleteDone", "CompleteDonePre", "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI", "DiffUpdated", "DirChanged", "DirChangedPre", "ExitPre", "FileAppendPost", "FileAppendPre", "FileChangedRO", "FileChangedShell", "FileChangedShellPost", "FileReadPost", "FileReadPre", "FileType", "FileWritePost", "FileWritePre", "FilterReadPost", "FilterReadPre", "FilterWritePost", "FilterWritePre", "FocusGained", "FocusLost", "FuncUndefined", "InsertChange", "InsertCharPre", "InsertEnter", "InsertLeave", "InsertLeavePre", "MenuPopup", "ModeChanged", "OptionSet", "QuickFixCmdPost", "QuickFixCmdPre", "QuitPre", "RecordingEnter", "RecordingLeave", "RemoteReply", "SafeState", "SearchWrapped", "SessionLoadPost", "ShellCmdPost", "ShellFilterPost", "Signal", "SourcePost", "SourcePre", "SpellFileMissing", "StdinReadPost", "StdinReadPre", "SwapExists", "Syntax", "TabClosed", "TabEnter", "TabLeave", "TabNew", "TabNewEntered", "TermClose", "TermEnter", "TermLeave", "TermOpen", "TermResponse", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT", "TextYankPost", "UIEnter", "UILeave", "User", "VimEnter", "VimLeave", "VimLeavePre", "VimResized", "VimResume", "VimSuspend", "WinClosed", "WinEnter", "WinLeave", "WinNew", "WinResized", "WinScrolled" }

vim.api.nvim_create_autocmd(
    Event_list, {
        desc = 'Autocommand profile init',
        pattern = '*',
        callback = AuProfileStart
    }
)

vim.api.nvim_create_user_command(
    'ProfileAutocommand',
    function()
        vim.notify("Profiling started, stop by F6")
        AuProfileEnabled = true
        AuProfileData = {}
        AuCallbackProfileData = {}

        -- Autocommand to collect end data
        vim.api.nvim_create_autocmd(
            Event_list, {
                desc = 'Autocommand profile record',
                pattern = '*',
                callback = AuProfileEnd
            }
        )

        -- Mapping to stop autocommand profiling
        vim.api.nvim_set_keymap('n', '<F6>', '', {
            callback = function()
                AuProfileEnabled = false
                vim.cmd('profile stop')
                vim.notify('Autocommand profiling stopped')
            end
        })

        vim.cmd[[
            profile start nvim_profile
            " profile file *
            profile func *
        ]]
    end,
    { nargs = 0 }
)

---@type ProfileData?
-- AuCallbackProfileData = {}

-- function NvimCreateAutocmdWrapper(event, opts)
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
-- vim.api.nvim_create_autocmd = NvimCreateAutocmdWrapper
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
    collapse           = ' ',
    diagnostic         = ' ',
    diff_add           = '│',
    diff_change        = '┊',
    diff_change_delete = '~',
    diff_delete        = '',
    diff_delete_top    = '‾',
    error              = ' ',
    expand             = ' ',
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
        colorscheme = { },
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
---@field cmd string Lazy load on command
---@type Plugin[] List of plugins
Plugins = {}

---@class PopupMenu
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

-- local url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"
-- <~>
-- Functions</>
------------

---Adds a plugin Lazy nvim config
---@param opts Plugin Plugin config
function AddPlugin(opts)
    table.insert(Plugins, opts)
end

---Create background color adaptive to editor background
---@param lighten integer Lighter percent
---@param darken integer Darker percent
---@return string Color Hex format
function AdaptiveBG(lighten, darken)
    local bg
    if (vim.o.background == 'dark') then
        -- TODO: Review
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, lighten)
    else
        bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
        bg = string.format('%X', bg)
        bg = LightenDarkenColor(bg, darken)
    end
    return bg
end

-- TODO: Review
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
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
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

function ColorPalette()
    if vim.o.background == 'light' then
        return {
            { fg = '#00A6ED' },
            { fg = '#037171' },
            { fg = '#2100F5' },
            { fg = '#235789' },
            { fg = '#247BA0' },
            { fg = '#30B0A1' },
            { fg = '#5D536B' },
            { fg = '#61210F' },
            { fg = '#689784' },
            { fg = '#7E5CA3' },
            { fg = '#7FB800' },
            { fg = '#806443' },
            { fg = '#81A35C' },
            { fg = '#9C7C1C' },
            { fg = '#A42CD6' },
            { fg = '#CE2D4F' },
            { fg = '#735290' },
            { fg = '#F4743B' },
            { fg = '#F6511D' },
            { fg = '#FFB400' },
        }
    else
        return {
            { fg = '#4056F4' },
            { fg = '#5FAD56' },
            { fg = '#97CC04' },
            { fg = '#98fc03' },
            { fg = '#BDBEA9' },
            { fg = '#CE6D8B' },
            { fg = '#D4C2FC' },
            { fg = '#DDA15E' },
            { fg = '#E6E6E6' },
            { fg = '#E9D758' },
            { fg = '#F45D01' },
            { fg = '#F78154' },
            { fg = '#FFD447' },
            { fg = '#c0dbf5' },
            { fg = '#c0f5c8' },
            { fg = '#c0f5f1' },
            { fg = '#ccc0f5' },
            { fg = '#dff5c0' },
            { fg = '#f2c0f5' },
            { fg = '#f5eac0' },
        }
    end
end

function DebugWindows()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local win_list = vim.api.nvim_tabpage_list_wins(tabpage)
    for _, win in ipairs(win_list) do
        local win_config = vim.api.nvim_win_get_config(win)
        print(vim.inspect(win_config))
    end
end

function GetSign(name)
    local sign_list = vim.fn.sign_getdefined()
    for _, value in ipairs(sign_list) do
        if value.name == name then
            return value
        end
    end
end

function GetGitsign(lnum)
    local sign = vim.fn.sign_getplaced('%', {group = '*', lnum = lnum})
    local signs = sign[1].signs
    if #signs > 0 then
        local signdef = GetSign(signs[1].name)
        if signdef then
            return signdef.text
            -- return '%#' .. signdef.texthl .. '#' .. signdef.text .. ' '
        end
    end
    return ''
end

function GetTSInstlled(use_entension)
    local filetye_map = {
        ['python'] = 'py'
    }

    local installed_filetypes = {}

    for file, _ in vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath('data'), '/lazy/nvim-treesitter/parser')) do
        if file:sub(-3) == '.so' then
            local ftype = file:gsub('.so', '')
            if use_entension then
                ftype = filetye_map[ftype] or ftype
            end
            table.insert(installed_filetypes, ftype)
        end
    end

    return installed_filetypes
end

function IsLspAttached()
    return #vim.lsp.get_active_clients({bufnr = 0}) ~= 0
end

function LightenDarkenColor(col, amt)
    local num = tonumber(col, 16)
    local r = bit.rshift(num, 16) + amt
    local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
    local g = bit.band(num, 0x0000FF) + amt
    local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))
    local hex_code = string.format("#%-6X", newColor)
    return hex_code:gsub(' ', '0')
end

function TableContains(table, item)
    for _,k in ipairs(table) do
        if k == item then
            return item
        end
    end
    return nil
end

function MarkdownHeadingsHighlight()
    local palette = ColorPalette()
    for i=1,6 do
        local hl = { fg = palette[i].fg, bold = true, underline = false }
        -- vim.api.nvim_set_hl(0, '@text.title.' .. i .. '.markdown', hl)
        vim.api.nvim_set_hl(0, '@text.title.' .. i .. '.marker.markdown', hl)
    end
end

function NvimOpenWinSafe(bufnr, enter, config)
    -- FEAT dotted border for non focusable window
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
vim.api.nvim_open_win = NvimOpenWinSafe

function OpenFloat(path, relativity, col_offset, row_offset, enter)
    -- Create buffer
    local bufnr = vim.fn.bufadd(path)

    -- Create floating window
    if Preview_win == nil then
        Preview_win = vim.api.nvim_open_win(bufnr, enter, {
            border = 'rounded',
            col = col_offset,
            footer = ' [M-s] split [M-v] vsplit [M-t] tab open ',
            footer_pos = 'right',
            height = vim.o.lines - 8,
            relative = relativity,
            row = row_offset,
            title = path ,
            title_pos = 'center',
            width = vim.o.columns - 20,
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
                vim.api.nvim_win_set_config(0, {
                    width = vim.o.columns - 20,
                    height = vim.o.lines - 8
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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-s>', '', {
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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-v>', '', {
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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-t>', '', {
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

function PopupAction()
    -- local currentWindow = vim.api.nvim_get_current_win()
    -- local cursorPos = vim.api.nvim_win_get_cursor(currentWindow)
    vim.cmd('aunmenu PopUp')

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

function PopupMenuAdd(menu)
    table.insert(Pop_up_menu, menu)
end

TodoHilighterCache = {}
function TodoHilighter(_, match)
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

vim.api.nvim_set_hl(0, "Overlength", { bg = AdaptiveBG(70, -70) })
vim.api.nvim_create_autocmd(
    'BufWinEnter', {
        pattern = '*',
        desc = 'Overlength line marker',
        callback = function()
            vim.cmd('match Overlength /\\%' .. vim.bo.textwidth + 2 .. 'v/')
        end
    }
)

vim.api.nvim_create_autocmd(
    'BufReadPost', {
        pattern = '*',
        desc = 'Disable wrap for file with long lines',
        callback = function()
            for _, line in ipairs(vim.fn.getbufline(vim.api.nvim_get_current_buf(), 1, '$')) do
                local line_length = #line
                if line_length > 150 then
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
        desc = 'Load Treesitter on CursorHold',
        callback = function(arg)
            local ftype = vim.o.filetype
            if TableContains(GetTSInstlled(false), ftype) then
                vim.cmd('Lazy load nvim-treesitter')
                vim.api.nvim_del_autocmd(arg.id)
            end
        end
    }
)

vim.api.nvim_create_autocmd(
    'MenuPopup', {
        pattern = 'n',
        desc = 'Create popup menu based on context',
        callback = function()
            PopupAction()
        end
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

-- Sign_placelist = vim.fn.sign_placelist
-- vim.fn.sign_placelist = function(args)
--     for _,i in pairs(args) do
--         -- use tbl_extend or tbl_deep_extend
--         Signs[i.buffer] = {
--             [i.lnum] = i
--         }
--     end
--     Sign_placelist(args)
-- end

vim.highlight.priorities = {
    syntax = 50,
    treesitter = 100,
    semantic_tokens = 99,
    diagnostics = 150,
    user = 200
}

vim.notify = function(...)
    require('notify')
    vim.notify(...)
end

vim.ui.select = function(...)
    require('dressing')
    vim.ui.select(...)
end

vim.ui.input = function(...)
    require('dressing')
    vim.ui.input(...)
end

-- vim.fn.matchadd('HighlightURL', url_matcher, HlPriority.url)
-- <~>
-- PopUps</>
PopupMenuAdd({
    cond = IsLspAttached,
    opts = {
        {'Code Action              ',  '<Cmd>CodeActionMenu<CR>'},
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
-- <~>
-- Commands</>
Preview_win = nil
vim.api.nvim_create_user_command(
    'Peek',
    function(args)
        OpenFloat(args.args, 'editor', 8, 3, true)
    end,
    {
        complete = 'file',
        nargs = 1
    }
)
-- <~>
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
}

-- 'echasnovski/mini.align'

AddPlugin {
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
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
            Rule(' ', ' ')
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
AddPlugin {
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

AddPlugin {
    'Pocco81/high-str.nvim',
    cmd = 'HSHighlight'
}

AddPlugin {
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
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = AdaptiveBG(40, -40) })
        vim.cmd[[
           hi IlluminatedWordRead  guibg = #8AC926 guifg = #FFFFFF gui = bold
           hi IlluminatedWordWrite guibg = #FF595E guifg = #FFFFFF gui = italic
       ]]
    end,
    event = { 'CursorHold', 'CursorHoldI' }
}

AddPlugin {
    'azabiong/vim-highlighter',
    keys = { 'f<CR>' }
}

AddPlugin {
    'echasnovski/mini.hipatterns',
    event = 'VeryLazy',
    opts = {
        highlighters = {
            bug      = { pattern = '()BUG:()', group = TodoHilighter },
            docs     = { pattern = '()DOCME:()', group = TodoHilighter },
            error    = { pattern = '()ERROR:()', group = TodoHilighter },
            feat     = { pattern = '()FEAT:()', group = TodoHilighter },
            fix      = { pattern = '()FIX:()', group = TodoHilighter },
            hack     = { pattern = '()HACK:()', group = TodoHilighter },
            hint     = { pattern = '()HINT:()', group = TodoHilighter },
            info     = { pattern = '()INFO:()', group = TodoHilighter },
            perf     = { pattern = '()PERF:()', group = TodoHilighter },
            refactor = { pattern = '()REFACTOR:()', group = TodoHilighter },
            test     = { pattern = '()TEST:()', group = TodoHilighter },
            thought  = { pattern = '()THOUGHT:()', group = TodoHilighter },
            todo     = { pattern = '()TODO:()', group = TodoHilighter },
            warn     = { pattern = '()WARN:()', group = TodoHilighter },
        }
    }
}

AddPlugin {
    'folke/flash.nvim',
    lazy = true,
    opts = {
        -- labels = "abcdefghijklmnopqrstuvwxyz",
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
            -- search/jump in all windows
            multi_window = true,
            -- search direction
            forward = true,
            -- when `false`, find only matches in the given direction
            wrap = true,
            mode = "search",
            -- behave like `incsearch`
            incremental = true,
            exclude = {
                "notify",
                "cmp_menu",
                "noice",
                "flash_prompt",
                function(win)
                    -- exclude non-focusable windows
                    return not vim.api.nvim_win_get_config(win).focusable
                end,
            },
            -- Optional trigger character that needs to be typed before
            -- a jump label can be used. It's NOT recommended to set this,
            -- unless you know what you're doing
            trigger = "",
            -- max pattern length. If the pattern length is equal to this
            -- labels will no longer be skipped. When it exceeds this length
            -- it will either end in a jump or terminate the search
            max_length = false, ---@type number|false
        },
        jump = {
            -- save location in the jumplist
            jumplist = true,
            -- jump position
            pos = "start", ---@type "start" | "end" | "range"
            -- add pattern to search history
            history = false,
            -- add pattern to search register
            register = false,
            -- clear highlight after jump
            nohlsearch = false,
            -- automatically jump when there is only one match
            autojump = false,
            -- You can force inclusive/exclusive jumps by setting the
            -- `inclusive` option. By default it will be automatically
            -- set based on the mode.
            inclusive = nil, ---@type boolean?
            -- jump position offset. Not used for range jumps.
            -- 0: default
            -- 1: when pos == "end" and pos < current position
            offset = nil, ---@type number
        },
        label = {
            -- allow uppercase labels
            uppercase = true,
            -- add any labels with the correct case here, that you want to exclude
            exclude = "",
            -- add a label for the first match in the current window.
            -- you can always jump to the first match with `<CR>`
            current = true,
            -- show the label after the match
            after = true, ---@type boolean|number[]
            -- show the label before the match
            before = false, ---@type boolean|number[]
            -- position of the label extmark
            style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
            -- flash tries to re-use labels that were already assigned to a position,
            -- when typing more characters. By default only lower-case labels are re-used.
            reuse = "lowercase", ---@type "lowercase" | "all" | "none"
            -- for the current window, label targets closer to the cursor first
            distance = true,
            -- minimum pattern length to show labels
            -- Ignored for custom labelers.
            min_pattern_length = 0,
            -- Enable this to use rainbow colors to highlight labels
            -- Can be useful for visualizing Treesitter ranges.
            rainbow = {
                enabled = false,
                -- number between 1 and 9
                shade = 5,
            },
            format = function(opts)
                return { { opts.match.label, opts.hl_group } }
            end,
        },
        highlight = {
            -- show a backdrop with hl FlashBackdrop
            backdrop = true,
            -- Highlight the search matches
            matches = true,
            -- extmark priority
            priority = 5000,
            groups = {
                match = "FlashMatch",
                current = "FlashCurrent",
                backdrop = "FlashBackdrop",
                label = "FlashLabel",
            },
        },
        -- action to perform when picking a label.
        -- defaults to the jumping logic depending on the mode.
        action = nil,
        -- initial pattern to use when opening flash
        pattern = "",
        -- When `true`, flash will try to continue the last search
        continue = false,
        -- Set config to a function to dynamically change the config
        config = nil,
        modes = {
            -- options used when flash is activated through
            -- a regular search with `/` or `?`
            search = {
                -- when `true`, flash will be activated during regular search by default.
                -- You can always toggle when searching with `require("flash").toggle()`
                enabled = true,
                highlight = { backdrop = false },
                jump = { history = true, register = true, nohlsearch = true },
                search = {
                    -- `forward` will be automatically set to the search direction
                    -- `mode` is always set to `search`
                    -- `incremental` is set to `true` when `incsearch` is enabled
                },
            },
            -- options used when flash is activated through
            -- `f`, `F`, `t`, `T`, `;` and `,` motions
            char = {
                enabled = true,
                -- dynamic configuration for ftFT motions
                config = function(opts)
                    -- autohide flash when in operator-pending mode
                    opts.autohide = vim.fn.mode(true):find("no") and vim.v.operator == "y"

                    -- disable jump labels when enabled and when using a count
                    opts.jump_labels = opts.jump_labels and vim.v.count == 0

                    -- Show jump labels only in operator-pending mode
                    -- opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
                end,
                -- hide after jump when not using jump labels
                autohide = false,
                -- show jump labels
                jump_labels = false,
                -- set to `false` to use the current line only
                multi_line = true,
                -- When using jump labels, don't use these keys
                -- This allows using those keys directly after the motion
                label = { exclude = "hjkliardc" },
                -- by default all keymaps are enabled, but you can disable some of them,
                -- by removing them from the list.
                -- If you rather use another key, you can map them
                -- to something else, e.g., { [";"] = "L", [","] = H }
                keys = { "f", "F", "t", "T", ";", "," },
                ---@alias Flash.CharActions table<string, "next" | "prev" | "right" | "left">
                -- The direction for `prev` and `next` is determined by the motion.
                -- `left` and `right` are always left and right.
                char_actions = function(motion)
                    return {
                        [";"] = "next", -- set to `right` to always go right
                        [","] = "prev", -- set to `left` to always go left
                        -- clever-f style
                        [motion:lower()] = "next",
                        [motion:upper()] = "prev",
                        -- jump2d style: same case goes next, opposite case goes prev
                        -- [motion] = "next",
                        -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
                    }
                end,
                search = { wrap = false },
                highlight = { backdrop = true },
                jump = { register = false },
            },
            -- options used for treesitter selections
            -- `require("flash").treesitter()`
            treesitter = {
                labels = "abcdefghijklmnopqrstuvwxyz",
                jump = { pos = "range" },
                search = { incremental = false },
                label = { before = true, after = true, style = "inline" },
                highlight = {
                    backdrop = false,
                    matches = false,
                },
            },
            treesitter_search = {
                jump = { pos = "range" },
                search = { multi_window = true, wrap = true, incremental = false },
                remote_op = { restore = true },
                label = { before = true, after = true, style = "inline" },
            },
            -- options used for remote flash
            remote = {
                remote_op = { restore = true, motion = true },
            },
        },
        -- options for the floating window that shows the prompt,
        -- for regular jumps
        prompt = {
            enabled = true,
            prefix = { { "⚡", "FlashPromptIcon" } },
            win_config = {
                relative = "editor",
                width = 1, -- when <=1 it's a percentage of the editor width
                height = 1,
                row = -1, -- when negative it's an offset from the bottom
                col = 0, -- when negative it's an offset from the right
                zindex = 1000,
            },
        },
        -- options for remote operator pending mode
        remote_op = {
            -- restore window views and cursor position
            -- after doing a remote operation
            restore = false,
            -- For `jump.pos = "range"`, this setting is ignored.
            -- `true`: always enter a new motion when doing a remote operation
            -- `false`: use the window's cursor position and jump target
            -- `nil`: act as `true` for remote windows, `false` for the current window
            motion = false,
        },
    }
}

AddPlugin {
    'folke/paint.nvim',
    enabled = false,
    -- ft = { 'python' }, -- highlights code too https://github.com/folke/paint.nvim/issues/8
    opts = {
        highlights = {
            {
                filter = { filetype = 'python' },
                pattern = '%a+: ',
                hl = 'Constant'
            }
        }
    }
}

AddPlugin {
    'folke/lsp-colors.nvim',
    event = 'LspAttach'
}

AddPlugin {
    'folke/todo-comments.nvim',
    config = function()
        require('todo-comments').setup({
            colors = Todo_colors,
            keywords = {
                DOCME  = { icon = '', color = 'docs' },
                FEAT   = { icon = '󱩑', color = 'feat' },
                FIX    = { icon = '', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
                HACK   = { icon = '', color = 'hint' },
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
        { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
        { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' }
    }
}

AddPlugin {
    'kevinhwang91/nvim-hlslens',
    keys = { 'n', 'N', '*', '#', 'g*', 'g#' },
    opts = {
        calm_down = true
    }
}

AddPlugin {
    'brenoprata10/nvim-highlight-colors',
    cmd = 'HighlightColorsOn',
    opts = { render = 'background' }
}

AddPlugin {
    'nvim-zh/colorful-winsep.nvim',
    opts = {
        create_event = function()
            local win_n = CountWindows()
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

AddPlugin {
    't9md/vim-quickhl',
    config = function()
        local colors = {}
        for _,v in pairs(ColorPalette()) do
            local hi = "gui=italic,bold,underline guifg=#000000 guibg=" .. v.fg
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
AddPlugin {
    'tzachar/highlight-undo.nvim',
    config = true,
    keys = { 'u' },
    lazy = true
}

-- 'uga-rosa/ccc.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
function FixDiagnosticInfo()
    if (vim.o.background == 'light') then
        vim.cmd('hi clear DiagnosticInfo')
        vim.cmd('hi link DiagnosticInfo DiagnosticInformation')
    end
end

function FixIndentBlankline()
    for _, color in pairs({
        'IblIndent',
        'IblScope',
        'IndentBlanklineContextSpaceChar',
        'IndentBlanklineSpaceChar',
    }) do
        local hl = vim.api.nvim_get_hl_by_name(color, true)
        hl.background = nil
        hl.nocombine = false
        vim.api.nvim_set_hl(0, color, hl)
    end
end

function FixLimestone(char, context_char, method, symbol)
    require('starry').setup({
        custom_highlights = {
            IblIndent = { fg = char },
            IblScope = { fg = context_char },
            LineNr = { underline = false },
            ['@method'] = { fg = method, bold = true },
            ['@symbol'] = { fg = symbol }
        }
    })
end

function FixLineNr(fg)
    vim.api.nvim_set_hl(0, 'LineNr', { fg = fg })
end

function FixNontext()
    local bg = AdaptiveBG(60, -20)
    vim.api.nvim_set_hl(0, 'NonText', { fg = bg })
    vim.api.nvim_set_hl(0, 'IndentBlanklineSpaceChar', { fg = bg })
end

function FixStarry(char, context_char)
    require('starry').setup({
        custom_highlights = {
            IblIndent = { fg = char },
            IblScope = { fg = context_char },
            LineNr = { underline = false }
        }
    })
end

function FixVisual(bg)
    bg = bg or AdaptiveBG(50, -20)
    vim.api.nvim_set_hl(0, 'Visual', { bg = bg })
end

function FixVnNight()
    FixLineNr('#505275')
    vim.api.nvim_set_hl(0, 'Comment', { fg = '#7F82A5', italic = true })
    vim.api.nvim_set_hl(0, 'Folded', { bg = '#112943', fg = '#8486A4' })
end

-- https://github.com/SeniorMars/dotfiles/blob/master/.config/nvim/init.lua
function SeniorMarsTheme(transparent)
    require('gruvbox').setup({
        overrides = {
            CocCodeLens                = { fg = '#878787' },
            CocInlayHint               = { fg = '#87afaf' },
            CocWarningFloat            = { fg = '#dfaf87' },
            Comment                    = { fg = '#fe8019', italic = true },
            ContextVt                  = { fg = '#878787' },
            CursorLineNr               = { fg = '#fabd2f', bg = '#0E1018' },
            Define                     = { link = 'GruvboxPurple' },
            DiagnosticVirtualTextWarn  = { fg = '#dfaf87' },
            DiffAdd                    = { bold = true, reverse = false, fg = '', bg = '#2a4333' },
            DiffChange                 = { bold = true, reverse = false, fg = '', bg = '#333841' },
            DiffDelete                 = { bold = true, reverse = false, fg = '#442d30', bg = '#442d30' },
            DiffText                   = { bold = true, reverse = false, fg = '', bg = '#213352' },
            FoldColumn                 = { fg = '#fe8019', bg = '#0E1018' },
            Folded                     = { italic = true, fg = '#fe8019', bg = '#3c3836' },
            GruvboxAquaSign            = { fg = '#8EC07C', bg = '#0E1018' },
            GruvboxBlueSign            = { fg = '#83a598', bg = '#0E1018' },
            GruvboxGreenSign           = { fg = '#b8bb26', bg = '#0E1018' },
            GruvboxOrangeSign          = { fg = '#dfaf87', bg = '#0E1018' },
            GruvboxRedSign             = { fg = '#fb4934', bg = '#0E1018' },
            Macro                      = { link = 'GruvboxPurple' },
            Normal                     = { bg = '#0E1018' },
            SignColumn                 = { bg = '' },
            StatusLine                 = { bg = '#ffffff', fg = '#0E1018' },
            StatusLineNC               = { bg = '#3c3836', fg = '#0E1018' },
            VertSplit                  = { bg = '#0E1018' },
            WilderAccent               = { fg = '#f4468f', bg = '#0E1018' },
            WilderMenu                 = { fg = '#ebdbb2', bg = '#0E1018' },
            ['@constant.builtin']      = { link = 'GruvboxPurple' },
            ['@storageclass.lifetime'] = { link = 'GruvboxAqua' },
            ['@text.note']             = { link = 'TODO' },
        },
        transparent = transparent
    })
end

local colos = {}

local function ColorPlugin(opts)
    if opts.cfg then
        local cfg = opts.cfg
        local mod
        if #cfg == 2 then
            mod = cfg[1]
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

local function Dark(opts)
    opts.bg = 'dark'
    ColorPlugin(opts)
end

local function DarkT(opts)
    opts.trans = true
    Dark(opts)
end

local function Light(opts)
    opts.bg = 'light'
    ColorPlugin(opts)
end

AddPlugin { 'Tsuzat/NeoSolarized.nvim',                event = 'User NeoSolarized'                                        }
AddPlugin { 'mhartington/oceanic-next',                event = 'User OceanicNext'                                         }
AddPlugin { 'NLKNguyen/papercolor-theme',              event = 'User PaperColor'                                          }
AddPlugin { 'Mofiqul/adwaita.nvim',                    event = 'User adwaita'                                             }
AddPlugin { 'Shatur/neovim-ayu',                       event = 'User ayu'                                                 }
AddPlugin { 'ribru17/bamboo.nvim',                     event = 'User bamboo'                                              }
AddPlugin { 'RRethy/nvim-base16',                      event = 'User base16'                                              }
AddPlugin { 'uloco/bluloco.nvim',                      event = 'User bluloco', dependencies = 'rktjmp/lush.nvim'          }
AddPlugin { 'projekt0n/caret.nvim',                    event = 'User caret'                                               }
AddPlugin { 'catppuccin/nvim',                         event = 'User catppuccin'                                          }
AddPlugin { 'lalitmee/cobalt2.nvim',                   event = 'User cobalt2', dependencies = 'tjdevries/colorbuddy.nvim' }
AddPlugin { 'tomasiser/vim-code-dark',                 event = 'User codedark'                                            }
AddPlugin { 'santos-gabriel-dario/darcula-solid.nvim', event = 'User darcula-solid', dependencies = 'rktjmp/lush.nvim'    }
AddPlugin { 'LunarVim/darkplus.nvim',                  event = 'User darkplus'                                            }
AddPlugin { 'decaycs/decay.nvim',                      event = 'User decay'                                               }
AddPlugin { 'theniceboy/nvim-deus',                    event = 'User deus'                                                }
AddPlugin { 'sainnhe/edge',                            event = 'User edge'                                                }
AddPlugin { 'wuelnerdotexe/vim-enfocado',              event = 'User enfocado'                                            }
AddPlugin { 'sainnhe/everforest',                      event = 'User everforest'                                          }
AddPlugin { 'fenetikm/falcon',                         event = 'User falcon'                                              }
AddPlugin { 'maxmx03/FluoroMachine.nvim',              event = 'User fluoromachine'                                       }
AddPlugin { 'projekt0n/github-nvim-theme',             event = 'User github'                                              }
AddPlugin { 'ellisonleao/gruvbox.nvim',                event = 'User gruvbox'                                             }
AddPlugin { 'luisiacc/gruvbox-baby',                   event = 'User gruvbox-baby'                                        }
AddPlugin { 'kaiuri/nvim-juliana',                     event = 'User juliana'                                             }
AddPlugin { 'rebelot/kanagawa.nvim',                   event = 'User kanagawa'                                            }
AddPlugin { 'lmburns/kimbox',                          event = 'User kimbox'                                              }
AddPlugin { 'marko-cerovac/material.nvim',             event = 'User material'                                            }
AddPlugin { 'savq/melange',                            event = 'User melange'                                             }
AddPlugin { 'ramojus/mellifluous.nvim',                event = 'User mellifluous'                                         }
AddPlugin { 'xero/miasma.nvim',                        event = 'User miasma'                                              }
AddPlugin { 'polirritmico/monokai-nightasty.nvim',     event = 'User monokai-nightasty'                                   }
AddPlugin { 'loctvl842/monokai-pro.nvim',              event = 'User monokai-pro'                                         }
AddPlugin { 'bluz71/vim-moonfly-colors',               event = 'User moonfly'                                             }
AddPlugin { 'rafamadriz/neon',                         event = 'User neon'                                                }
AddPlugin { 'cryptomilk/nightcity.nvim',               event = 'User nightcity'                                           }
AddPlugin { 'bluz71/vim-nightfly-colors',              event = 'User nightfly'                                            }
AddPlugin { 'EdenEast/nightfox.nvim',                  event = 'User nightfox'                                            }
AddPlugin { 'talha-akram/noctis.nvim',                 event = 'User noctis'                                              }
AddPlugin { 'gbprod/nord.nvim',                        event = 'User nord'                                                }
AddPlugin { 'AlexvZyl/nordic.nvim',                    event = 'User nordic'                                              }
AddPlugin { 'Yazeed1s/oh-lucy.nvim',                   event = 'User oh-lucy'                                             }
AddPlugin { 'cpea2506/one_monokai.nvim',               event = 'User one_monokai'                                         }
AddPlugin { 'olimorris/onedarkpro.nvim',               event = 'User onedarkpro'                                          }
AddPlugin { 'rmehri01/onenord.nvim',                   event = 'User onenord'                                             }
AddPlugin { 'nyoom-engineering/oxocarbon.nvim',        event = 'User oxocarbon'                                           }
AddPlugin { 'JoosepAlviste/palenightfall.nvim',        event = 'User palenightfall'                                       }
AddPlugin { 'rose-pine/neovim',                        event = 'User rose-pine'                                           }
AddPlugin { 'lewpoly/sherbet.nvim',                    event = 'User sherbet'                                             }
AddPlugin { 'sainnhe/sonokai',                         event = 'User sonokai'                                             }
AddPlugin { 'ray-x/starry.nvim',                       event = 'User starry'                                              }
AddPlugin { 'NTBBloodbath/sweetie.nvim',               event = 'User sweetie'                                             }
AddPlugin { 'tiagovla/tokyodark.nvim',                 event = 'User tokyodark'                                           }
AddPlugin { 'folke/tokyonight.nvim',                   event = 'User tokyonight'                                          }
AddPlugin { 'sickill/vim-monokai',                     event = 'User vim-monokai'                                         }
AddPlugin { 'askfiy/visual_studio_code',               event = 'User visual_studio_code'                                  }
AddPlugin { '2nthony/vitesse.nvim',                    event = 'User vitesse', dependencies = 'tjdevries/colorbuddy.nvim' }
AddPlugin { 'nxvu699134/vn-night.nvim',                event = 'User vn-night'                                            }
AddPlugin { 'Mofiqul/vscode.nvim',                     event = 'User vscode'                                              }
AddPlugin { 'mcchrish/zenbones.nvim',                  event = 'User zenbones', dependencies = 'rktjmp/lush.nvim'         }
AddPlugin { 'glepnir/zephyr-nvim',                     event = 'User zephyr'                                              }
AddPlugin { 'titanzero/zephyrium',                     event = 'User zephyrium'                                           }

-- REFACTOR: use cfg field to reduce line length
DarkT { 'NeoSolarized',               '_'                              }
Light { 'NeoSolarized',               '_'                              }
Dark  { 'NeoSolarized',               '_', cfg = {transparent = false} }
Dark  { 'OceanicNext',                '_'                              }
Dark  { 'PaperColor',                 '_',           post = FixNontext }
Light { 'PaperColor',                 '_',           post = FixNontext }
Dark  { 'adwaita',                    '_'                              }
Light { 'adwaita',                    '_'                              }
DarkT { 'adwaita',                    '_', pre = function() vim.g.adwaita_transparent = true end }
Dark  { 'ayu-dark',                   'ayu'                            }
Light { 'ayu-light',                  'ayu'                            }
Dark  { 'ayu-mirage',                 'ayu'                            }
DarkT { 'bamboo',                     '_', cfg = {style = 'multiplex', transparent = true} }
Dark  { 'bamboo',                     '_', cfg = {style = 'multiplex'}                     }
DarkT { 'bamboo',                     '_', cfg = {style = 'vulgaris', transparent = true } }
Dark  { 'bamboo',                     '_', cfg = {style = 'vulgaris'}                      }
Dark  { 'bluloco-dark',               '_'                              }
DarkT { 'bluloco-dark',               '_', cfg = { 'bluloco', {transparent = true} } }
Dark  { 'carbonfox',                  'nightfox'                       }
Dark  { 'caret',                      '_'                              }
Dark  { 'catppuccin-frappe',          'catppuccin'                     }
DarkT { 'catppuccin-frappe',          'catppuccin', cfg = {transparent_background = true} }
Light { 'catppuccin-latte',           'catppuccin'                     }
Dark  { 'catppuccin-macchiato',       'catppuccin'                     }
DarkT { 'catppuccin-macchiato',       'catppuccin', cfg = {transparent_background = true} }
Dark  { 'catppuccin-mocha',           'catppuccin'                     }
Dark  { 'cobalt2',                    '_',           post = function() require('colorbuddy').colorscheme('cobalt2') end }
Dark  { 'codedark',                   '_'                                                                 }
DarkT { 'codedark',                   '_',           pre = function() vim.g.codedark_transparent = 1 end  }
Dark  { 'darcula-solid',              '_'                                                                 }
Dark  { 'darkplus',                   '_'                                                                 }
Dark  { 'darksolar',                  'starry',      pre = function() FixStarry('#691f48', '#922b64') end }
Light { 'dawnfox',                    'nightfox'                                                          }
Light { 'decay',                      '_'                                                                 }
Dark  { 'deus',                       '_',           post = FixVisual                                     }
Dark  { 'duskfox',                    'nightfox'                                                          }
DarkT { 'duskfox',                    'nightfox',    pre = function() require('nightfox').setup({transparent = true}) end }
Dark  { 'earlysummer',                'starry',      pre = function() FixStarry('#3f2b4c', '#694980') end }
Dark  { 'edge',                       '_'                                                                 }
Light { 'edge',                       '_'                                                                 }
Dark  { 'enfocado',                   '_'                                                                 }
Dark  { 'everforest',                 '_'                                                                 }
Light { 'everforest',                 '_'                                                                 }
Dark  { 'falcon',                     '_'                                                                 }
DarkT { 'fluoromachine',              '_', cfg = {glow = false, theme = 'fluoromachine', transparent = true} }
DarkT { 'fluoromachine',              '_', cfg = {glow = false, theme = 'retrowave', transparent = true}     }
Dark  { 'fluoromachine',              '_', cfg = {glow = true, theme = 'fluoromachine', transparent = false} }
Dark  { 'fluoromachine',              '_', cfg = {glow = true, theme = 'retrowave', transparent = false}  }
Dark  { 'forestbones',                'zenbones'                                                          }
DarkT { 'github_dark',                'github', cfg = {'github-theme', {options = {transparent = true}}}  }
Light { 'github_light',               'github'                                                            }
Dark  { 'gruvbox',                    '_'                                                                 }
Dark  { 'gruvbox',                    '_', pre  = function() SeniorMarsTheme(false) end                   }
DarkT { 'gruvbox',                    '_', pre  = function() SeniorMarsTheme(true) end                    }
DarkT { 'gruvbox',                    '_', cfg = {transparent_mode = true}                                }
Dark  { 'gruvbox-baby',               '_',                                                                }
DarkT { 'gruvbox-baby',               '_', pre = function() vim.g.gruvbox_baby_transparent_mode = 1 end   }
Dark  { 'habamax',                    '_',                                                                }
Dark  { 'juliana',                    '_', post = function() FixLineNr('#999999') end                     }
Dark  { 'kanagawa-dragon',            '_'                                                                 }
DarkT { 'kanagawa-dragon',            '_', cfg = {transparent = true}                                     }
Dark  { 'kanagawa-wave',              '_'                                                                 }
DarkT { 'kanagawa-wave',              '_', cfg = {transparent = true}                                     }
Dark  { 'kimbox',                     '_',           post = FixVisual                                     }
Light { 'limestone',                  'starry',      pre = function() FixLimestone('#223216', '#395425', '#4e9ba6', '#A30000') end                     }
Dark  { 'mariana',                    'starry',      pre = function() FixStarry('#414346', '#6c6f75') end                                              }
Light { 'material',                   '_',           pre = function() vim.g.material_style = 'lighter' end, post = function() FixVisual('#CCEAE7') end }
Dark  { 'melange',                    '_'                                                                                                              }
Dark  { 'mellifluous',                '_'                                                                                                              }
Dark  { 'monokai',                    'vim-monokai'                                                                          }
DarkT { 'monokai-nightasty',          '_'                                                                                    }
Light { 'monokai-nightasty',          '_'                                                                                    }
Dark  { 'monokai-nightasty',          '_',           cfg = {dark_style_background = 'transparent'} }
Dark  { 'monokai-pro',                '_',           cfg = {filter = 'machine'}                    }
Dark  { 'monokai-pro',                '_',           cfg = {filter = 'octagon'}                    }
Dark  { 'monokai-pro',                '_',           cfg = {filter = 'pro'}, post = FixVisual      }
Dark  { 'monokai-pro',                '_',           cfg = {filter = 'ristretto'}                  }
Dark  { 'monokai-pro',                '_',           cfg = {filter = 'spectrum'}                   }
DarkT { 'moonfly',                    '_',           pre = function() vim.g.moonflyTransparent = true end                                                     }
Light { 'neobones',                   'zenbones'                                                                                                              }
Light { 'neon',                       '_',           pre = function() vim.g.neon_style = 'light'   end, post = function() FixVisual() FixDiagnosticInfo() end }
Dark  { 'nightcity',                  '_',           pre = function() require('nightcity').setup({style = 'afterlife'}) end                                   }
Dark  { 'nightcity',                  '_',           pre = function() require('nightcity').setup({style = 'kabuki'}) end                                      }
Dark  { 'nightfly',                   '_'                                                                                                                     }
DarkT { 'nightfly',                   '_',           pre = function() vim.g.nightflyTransparent = true end                                                    }
Dark  { 'nightfox',                   'nightfox'                                                                                                              }
DarkT { 'nightfox',                   'nightfox',    pre = function() require('nightfox').setup({transparent = true}) end                                     }
Dark  { 'noctis_azureus',             'noctis'       }
Light { 'noctis_hibernus',            'noctis'       }
Light { 'noctis_lilac',               'noctis'       }
Light { 'noctis_lux',                 'noctis'       }
Dark  { 'noctis_minimus',             'noctis'       }
Dark  { 'nord',                       '_'            }
DarkT { 'nord',                       '_', pre = function() require('nord').setup({transparent = true}) end }
Dark  { 'nordbones',                  'zenbones'     }
Dark  { 'nordfox',                    'nightfox'     }
DarkT { 'nordfox',                    'nightfox',    pre = function() require('nightfox').setup({transparent = true}) end }
Dark  { 'nordic',                     '_'            }
DarkT { 'nordic',                     '_',           pre = function() require('nordic').setup({transparent_bg = true}) end }
DarkT { 'oh-lucy-evening',            'oh-lucy', pre = function() vim.g.oh_lucy_transparent_background = true end }
Dark  { 'one_monokai',                '_'            }
Dark  { 'onedark',                    'onedarkpro'   }
Light { 'onelight',                   '_'            } -- FIX: Gitsigns colors
Dark  { 'onenord',                    '_'            }
Light { 'onenord',                    '_'            }
Dark  { 'oxocarbon',                  '_'            }
Light { 'oxocarbon',                  '_'            }
Dark  { 'palenightfall',              '_'            }
DarkT { 'palenightfall',              '_', pre = function() require('palenightfall').setup({transparent = true}) end }
Dark  { 'retrobox',                   '_'            }
Dark  { 'rose-pine',                  '_'            }
Light { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'dawn'}) end }
DarkT { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'main', disable_background = true}) end }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'main'}) end }
DarkT { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'moon', disable_background = true}) end }
Dark  { 'rose-pine',                  '_',           pre = function() require('rose-pine').setup({dark_variant = 'moon'}) end }
Dark  { 'sherbet',                    '_'            }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'andromeda' end  }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'atlantis'  end  }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'default'   end  }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'maia'      end  }
Dark  { 'sonokai',                    '_',           pre = function() vim.g.sonokai_style = 'shusia'    end  }
Light { 'sweetie',                    '_'                                                                    }
DarkT { 'terafox',                    'nightfox', pre = function() require('nightfox').setup({transparent = true}) end }
Light { 'tokyobones',                 'zenbones'                                                            }
Dark  { 'tokyodark',                  '_'                                                                   }
DarkT { 'tokyodark',                  '_', pre = function() require('tokyodark').setup({transparent_background = true}) end }
Light { 'tokyonight-day',             'tokyonight'                                                          }
Dark  { 'tokyonight-moon',            'tokyonight'                                                          }
DarkT { 'tokyonight-moon',            'tokyonight', pre = function() require('tokyonight').setup({transparent = true}) end }
Dark  { 'tokyonight-night',           'tokyonight'                                                          }
DarkT { 'tokyonight-night',           'tokyonight', pre = function() require('tokyonight').setup({transparent = true}) end }
Dark  { 'tokyonight-storm',           'tokyonight'                                                          }
DarkT { 'tokyonight-storm',           'tokyonight', pre = function() require('tokyonight').setup({transparent = true}) end }
DarkT { 'visual_studio_code',         '_', pre = function() require('visual_studio_code').setup({mode = 'dark', transparent = true}) end }
Dark  { 'vitesse',                    '_'                                                                   }
DarkT { 'vitesse',                    '_', pre = function() require('vitesse').setup({transparent_background  = true}) end }
Dark  { 'vn-night',                   '_',           post = FixVnNight                                      }
DarkT { 'vscode',                     '_', pre = function() require('vscode').setup({transparent  = true}) end }
Dark  { 'zephyr',                     '_'                                                                   }
Dark  { 'zephyrium',                  '_'                                                                   }

function ColoRand(scheme_index)
    math.randomseed(os.time())
    scheme_index = scheme_index or math.random(1, #colos)
    local selection = colos[scheme_index]
    local scheme = selection[1]
    local bg = selection.bg
    local event = selection[2]
    local precmd = selection.pre
    local postcmd = selection.post
    local trans = selection.trans
    vim.o.background = bg
    vim.g.neovide_transparency = trans and 0.8 or 1
    local start_time = os.clock()
    vim.api.nvim_exec_autocmds('User', {pattern = event == '_' and scheme or event})
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
end
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup({
            ignore = '^$',
            extra = { eol = 'gce' },
        })

        require('Comment.ft').set('ps1', {'# %s', '<# %s #>'})
        require('Comment.ft').set('python', {'# %s', '""" %s """'})
    end,
    keys = {
        { 'gc', mode = { 'n', 'v' } },
        { 'gb', mode = { 'n', 'v' } },
        'gcc', 'gbc', 'gcO', 'gco', 'gce'
    }
}

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Completion   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/L3MON4D3/cmp-luasnip-choice
-- https://github.com/hrsh7th/cmp-omni
-- https://github.com/FelipeLema/cmp-async-path
-- https://github.com/dmitmel/cmp-cmdline-history
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/paopaol/cmp-doxygen
-- https://github.com/hrsh7th/cmp-nvim-lua
-- https://github.com/uga-rosa/cmp-dynamic

AddPlugin { -- FEAT: https://github.com/2KAbhishek/nerdy.nvim
    'chrisgrieser/cmp-nerdfont',
    event = 'InsertEnter'
}

AddPlugin {
    'dcampos/cmp-snippy',
    dependencies = 'nvim-snippy',
    event = 'InsertEnter'
}

AddPlugin {
    'hrsh7th/cmp-cmdline',
    event = 'CmdlineChanged'
}

AddPlugin {
    'hrsh7th/cmp-nvim-lsp',
    event = 'LspAttach'
}

AddPlugin {
    'hrsh7th/cmp-path',
    event = 'CmdlineChanged'
}

AddPlugin {
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
                sources = {
                    { name = 'buffer' }
                }
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
                expand = function(args) -- Select one snippet engine
                    -- vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
                    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
                end
            },
            sources = ({
                {
                    name = 'buffer',
                    option = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end
                    },
                    priority = 1
                },
                -- { name = 'fuzzy_buffer' },
                { name = 'nerdfont' },
                { name = 'nvim_lsp', priority = 2 },
                { name = 'path' },
                { name = 'snippy', priority = 3 },
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        for key, value in pairs(kind_hl) do
            vim.api.nvim_set_hl(0, 'CmpItemKind' .. key, value[vim.o.background])
        end
        vim.cmd([[
            hi CmpItemAbbrDeprecated gui = strikethrough
            hi CmpItemAbbrMatch gui = bold
            hi CmpItemAbbrMatchFuzzy gui = underline
        ]])
    end,
    dependencies = {
        'hrsh7th/cmp-buffer',
        -- { 'tzachar/cmp-fuzzy-buffer', dependencies = {'tzachar/fuzzy.nvim', dependencies = { 'romgrk/fzy-lua-native', build = 'make' }} },
    },
    event = 'CmdlineChanged',
}

-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Debugger    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/nvim-telescope/telescope-dap.nvim
-- Abstract-IDE dap configs
-- --------------------------
-- -- telescope-dap.nvim
-- pcall(require'telescope'.load_extension, 'dap')
-- --------------------------
--
--
-- --------------------------
-- -- nvim-dap-ui
-- require('dapui').setup({
-- 	icons = {expanded = '▾', collapsed = '▸'},
-- 	-- Expand lines larger than the window
-- 	-- Requires >= 0.7
-- 	expand_lines = vim.fn.has('nvim-0.7'),
-- 	sidebar = {
-- 		-- You can change the order of elements in the sidebar
-- 		elements = {
-- 			-- Provide as ID strings or tables with 'id' and 'size' keys
-- 			{
-- 				id = 'scopes',
-- 				size = 0.25, -- Can be float or integer > 1
-- 			},
-- 			{id = 'breakpoints', size = 0.25},
-- 			{id = 'stacks', size = 0.25},
-- 			{id = 'watches', size = 00.25},
-- 		},
-- 		size = 40,
-- 		position = 'left', -- Can be 'left', 'right', 'top', 'bottom'
-- 	},
-- 	tray = {
-- 		elements = {'repl', 'console'},
-- 		size = 10,
-- 		position = 'bottom', -- Can be 'left', 'right', 'top', 'bottom'
-- 	},
-- 	floating = {
-- 		max_height = nil, -- These can be integers or a float between 0 and 1.
-- 		max_width = nil, -- Floats will be treated as percentage of your screen.
-- 		border = 'single', -- Border style. Can be 'single', 'double' or 'rounded'
-- 		mappings = {close = {'q', '<Esc>'}},
-- 	},
-- 	windows = {indent = 1},
-- 	render = {
-- 		max_type_length = nil, -- Can be integer or nil.
-- 	},
-- })
-- 
-- -- end nvim-dap-ui
-- --------------------------
-- 
-- --------------------------
-- -- nvim-dap-virtual-text
-- require('nvim-dap-virtual-text').setup {
-- 	enabled = true, -- enable this plugin (the default)
-- 	enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
-- 	highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
-- 	highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
-- 	show_stop_reason = true, -- show stop reason when stopped for exceptions
-- 	commented = false, -- prefix virtual text with comment string
-- 	only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
-- 	all_references = false, -- show virtual text on all all references of the variable (not only definitions)
-- 	filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
-- 	-- experimental features:
-- 	virt_text_pos = 'eol', -- position of virtual text, see `:h nvim_buf_set_extmark()`
-- 	all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
-- 	virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
-- 	virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
-- 	-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
-- }
-- -- end nvim-dap-virtual-text
-- -- end nvim-dap
-- https://github.com/PatschD/zippy.nvim
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/jay-babu/mason-nvim-dap.nvim
-- AddPlugin {
--     'jbyuki/one-small-step-for-vimkind',
--     config = function()
--         local dap = require('dap')
--         dap.configurations.lua = {
--             {
--                 type = 'nlua',
--                 request = 'attach',
--                 name = 'Attach to running Neovim instance',
--             }
--         }

--         dap.adapters.nlua = function(callback, config)
--             callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
--         end
--     end,
--     lazy = true
-- }
-- https://github.com/nvim-telescope/telescope-vimspector.nvim
-- https://github.com/puremourning/vimspector
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'Pocco81/dap-buddy.nvim'
-- Start: complete setup for lua debugger
AddPlugin {
    'mfussenegger/nvim-dap',
    config = function()
        -- vim.api.nvim_set_keymap('n', '<F9>', [[:lua require("dap").toggle_breakpoint()<CR>]], { noremap = true })
        -- vim.api.nvim_set_keymap('n', '<F5>', [[:lua require("dap").continue()<CR>]], { noremap = true })
        -- vim.api.nvim_set_keymap('n', '<F10>', [[:lua require("dap").step_over()<CR>]], { noremap = true })
        -- vim.api.nvim_set_keymap('n', '<F11>', [[:lua require("dap").step_into()<CR>]], { noremap = true })
        -- vim.api.nvim_set_keymap('n', '<F12>', [[:lua require("dap.ui.widgets").hover()<CR>]], { noremap = true })
        -- vim.api.nvim_set_keymap('n', '<F5>', [[:lua require("osv").launch({port = 8086})<CR>]], { noremap = true })
        vim.cmd[[
            nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
            nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
            nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
            nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
            nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
            nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
            nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
            nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
            nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
        ]]
    end,
    lazy = true
}
-- use 'mfussenegger/nvim-dap-python'
-- use 'rcarriga/nvim-dap-ui'
-- https://github.com/jonboh/nvim-dap-rr
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Doc Generater  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/Zeioth/dooku.nvim
AddPlugin {
    'danymat/neogen',
    cmd = 'Neogen',
    config = true
}
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ File Explorer  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- directory case handling
AddPlugin {
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
            local function opts(desc)
              return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            -- Preview for NvimTree
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

                    OpenFloat(path, 'win', vim.fn.winwidth(0) + 2, 3, false)
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
            -- vim.keymap.set('n', '<Tab>',          custom_preview,                     opts('Open Preview'))
            vim.keymap.set('n', '<Tab>',          api.node.open.preview,              opts('Open Preview'))
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
            special_files = { 'Makefile', 'README.md', 'readme.md' },
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
-- autocmd BufNewFile,BufRead *.csproj set filetype=csproj
FileTypeActions = {
    ['markdown'] = function()
        vim.g.table_mode_corner = '|'
        MarkdownHeadingsHighlight()
    end
}

vim.api.nvim_create_autocmd(
    'FileType', {
        pattern = '*',
        desc = 'Run custom actions per filetype',
        callback = function(arg)
            local ftype = vim.o.filetype
            local actions = FileTypeActions[ftype]
            if actions then actions() end
            if TableContains(GetTSInstlled(false), ftype) == nil then
                -- vim.print('Load syntax for ' .. ftype)
                vim.cmd('syntax on')
                vim.api.nvim_del_autocmd(arg.id)
            end
        end
    }
)
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Folding     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- https://github.com/snelling-a/better-folds.nvim
    'anuvyklack/pretty-fold.nvim',
    -- cond = function()
    --     return vim.o.foldmethod == 'marker'
    -- end,
    config = function()
        require('pretty-fold').setup({
            sections = {
                left = {
                    'content',
                },
                right = {
                    ' ', 'number_of_folded_lines', ': ', 'percentage', ' ',
                    function(config) return config.fill_char:rep(3) end
                }
            },
            fill_char = '󰧟',

            remove_fold_markers = true,

            -- Keep the indentation of the content of the fold string.
            keep_indentation = true,

            -- Possible values:
            -- "delete" : Delete all comment signs from the fold string.
            -- "spaces" : Replace all comment signs with equal number of spaces.
            -- false    : Do nothing with comment signs.
            process_comment_signs = 'spaces',

            -- Comment signs additional to the value of `&commentstring` option.
            comment_signs = {},

            -- List of patterns that will be removed from content foldtext section.
            stop_words = {
                '@brief%s*', -- (for C++) Remove '@brief' and all spaces after.
            },

            add_close_pattern = true, -- true, 'last_line' or false

            matchup_patterns = {
                {  '{', '}' },
                { '%(', ')' }, -- % to escape lua pattern char
                { '%[', ']' }, -- % to escape lua pattern char
            },
        })
    end,
    lazy = true
}

-- configure or remove
-- AddPlugin {
--     'kevinhwang91/nvim-ufo',
--     -- cond = function()
--     --     return vim.o.foldmethod ~= 'marker'
--     -- end,
--     config = function()
--         vim.o.foldcolumn = '1' -- '0' is not bad
--         vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
--         vim.o.foldlevelstart = 99
--         vim.o.foldenable = true
--         require('ufo').setup({
--             fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
--                 local newVirtText = {}
--                 local suffix = (' 󰁂 %d '):format(endLnum - lnum)
--                 local sufWidth = vim.fn.strdisplaywidth(suffix)
--                 local targetWidth = width - sufWidth
--                 local curWidth = 0
--                 for _, chunk in ipairs(virtText) do
--                     local chunkText = chunk[1]
--                     local chunkWidth = vim.fn.strdisplaywidth(chunkText)
--                     if targetWidth > curWidth + chunkWidth then
--                         table.insert(newVirtText, chunk)
--                     else
--                         chunkText = truncate(chunkText, targetWidth - curWidth)
--                         local hlGroup = chunk[2]
--                         table.insert(newVirtText, {chunkText, hlGroup})
--                         chunkWidth = vim.fn.strdisplaywidth(chunkText)
--                         -- str width returned from truncate() may less than 2nd argument, need padding
--                         if curWidth + chunkWidth < targetWidth then
--                             suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
--                         end
--                         break
--                     end
--                     curWidth = curWidth + chunkWidth
--                 end
--                 table.insert(newVirtText, {suffix, 'MoreMsg'})
--                 return newVirtText
--             end,
--             provider_selector = function(_, _, _)
--                 return 'treesitter'
--             end
--         })
--         vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
--         vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
--     end,
--     dependencies = 'kevinhwang91/promise-async',
--     keys = { 'zM' }
-- }

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Formatting   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'sbdchd/neoformat',
    cmd = 'Neoformat'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      FZF       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/linrongbin16/fzfx.nvim
-- https://github.com/gfanto/fzf-lsp.nvim
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Git       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    '9seconds/repolink.nvim', -- FEAT: add support for azure devops
    cmd = 'RepoLink',
    opts = {}
}

AddPlugin {
    'FabijanZulj/blame.nvim',
    cmd = 'ToggleBlame'
}

AddPlugin {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    config = true
}

AddPlugin {
    'aaronhallaert/advanced-git-search.nvim',
    config = function()
        -- optional: setup telescope before loading the extension
        require('telescope').setup{
            -- move this to the place where you call the telescope setup function
            extensions = {
                advanced_git_search = {
                    -- fugitive or diffview
                    diff_plugin = 'diffview',
                    -- customize git in previewer
                    -- e.g. flags such as { '--no-pager' }, or { '-c', 'delta.side-by-side=false' }
                    git_flags = {},
                    -- customize git diff in previewer
                    -- e.g. flags such as { '--raw' }
                    git_diff_flags = {},
                    -- Show builtin git pickers when executing 'show_custom_functions' or :AdvancedGitSearch
                    show_builtin_git_pickers = true,
                }
            }
        }

        require('telescope').load_extension('advanced_git_search')
    end
}
-- https://github.com/akinsho/git-conflict.nvim
-- https://github.com/chrisgrieser/nvim-tinygit

AddPlugin {
    'cynix/vim-mergetool',
    cmd = 'MergetoolStart'
}

AddPlugin {
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
            -- show inline preview of diff on jump
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, {expr=true})

            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, {expr=true})
        end,
        preview_config = {
            border = 'rounded'
        },
        signs = { -- ┃┇│┆󰇝
            add          = { hl = 'GitSignsAdd'   ,       text = Icons.diff_add, numhl           = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'   , show_count = false },
            change       = { hl = 'GitSignsChange',       text = Icons.diff_change, numhl        = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
            changedelete = { hl = 'GitSignsChangedelete', text = Icons.diff_change_delete, numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn', show_count = false },
            delete       = { hl = 'GitSignsDelete',       text = Icons.diff_delete, numhl        = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
            topdelete    = { hl = 'GitSignsDelete',       text = Icons.diff_delete_top, numhl    = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn', show_count = false },
        },
        trouble = false
    }
}

AddPlugin {
    'rhysd/git-messenger.vim',
    config = function()
        vim.g.git_messenger_floating_win_opts = { ['border'] = 'rounded' }
        -- vim.g.git_messenger_include_diff = 'current'
        vim.g.git_messenger_max_popup_height = 20
        vim.g.git_messenger_max_popup_width = 80
        vim.g.git_messenger_popup_content_margins = false
    end,
    cmd = "GitMessenger"
}

-- https://github.com/ruifm/gitlinker.nvim

AddPlugin {
    'sindrets/diffview.nvim',
    cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Icons      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'DaikyXendo/nvim-material-icon',
    opts = {
        override = {
            ['c++']  = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
            cc       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'CPlusPlus' },
            cp       = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cp'        },
            cpp      = { color = '#F34B7D', cterm_color = '204', icon = '󰙲', name = 'Cpp'       },
            cs       = { color = '#596706', cterm_color = '58',  icon = '', name = 'Cs'        },
            csproj   = { color = '#854CC7', cterm_color = '98',  icon = '', name = 'Csproj'    }, -- TODO: remove now
            csv      = { color = '#89E051', cterm_color = '113', icon = '', name = 'Csv'       },
            md       = { color = '#42A5F5', cterm_color = '75',  icon = '', name = 'Md'        },
            mdx      = { color = '#519ABA', cterm_color = '67',  icon = '', name = 'Mdx'       },
            norg     = { color = '#40916C', cterm_color = '48',  icon = '', name = 'Neorg'     },
            ps1      = { color = '#4D5A5E', cterm_color = '240', icon = '', name = 'PromptPs1' },
            yaml     = { color = '#f44336', cterm_color = '203', icon = '󰙅', name = 'Yaml'      },
        }
    }
}

AddPlugin {
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
-- https://github.com/Darazaki/indent-o-matic
AddPlugin {
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
                        'else_clause',
                        'for_statement',
                        'if_statement',
                    }
                },
            },
            exclude = {
                language = {},
                node_type = {
                    -- ['*'] = {
                    --     'source_file',
                    --     'program',
                    -- },
                    -- lua = {
                    --     'chunk',
                    -- },
                    -- python = {
                    --     'module',
                    -- },
                },
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
-- https://github.com/Decodetalkers/csharpls-extended-lsp.nvim
-- https://github.com/Hoffs/omnisharp-extended-lsp.nvim

AddPlugin {
    -- https://github.com/Wansmer/symbol-usage.nvim
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
        decorator = function(line)
            line = '󰧶 ' .. line
            return line
        end,
        ignore_filetype = {}
    }
}

AddPlugin { -- PERF: Load on demand
    'antosha417/nvim-lsp-file-operations',
    config = true,
    event = 'LspAttach'
}

AddPlugin {
    -- https://github.com/Zeioth/garbage-day.nvim
    'hinell/lsp-timeout.nvim',
    event = 'LspAttach'
}

-- https://github.com/iamcco/diagnostic-languageserver

AddPlugin { -- resolve usage with vim.lsp.inlay_hint() https://www.reddit.com/r/neovim/comments/158404z/is_lspinlayhintsnvim_still_relevant/
    'lvimuser/lsp-inlayhints.nvim',
    branch = 'anticonceal',
    event = 'LspAttach',
    -- config = true,
    opts = {
        only_current_line = true,
    }
}

-- https://github.com/mattn/efm-langserver
-- https://github.com/mfussenegger/nvim-lint
-- https://github.com/nkoporec/checkmate-lsp

AddPlugin {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
        ui = {
            border = 'rounded'
        }
    }
}

AddPlugin {
    'williamboman/mason-lspconfig.nvim',
    config = function()
        local mason_lspconfig = require('mason-lspconfig')
        mason_lspconfig.setup()
        -- vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]
        local opts = { noremap=true, silent=true }
        -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        local on_attach = function(client, bufnr)
            require('lsp-inlayhints').on_attach(client, bufnr)
            -- require('lsp_signature').on_attach({ hint_enable = false, noice = false }, bufnr)

            -- Mappings.
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<F2>', '<cmd>Lspsaga rename<CR>', bufopts)
            vim.keymap.set('n', '<S-F12>', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)
            -- vim.keymap.set('n', '<leader>h', '<cmd>Lspsaga hover_doc<CR>', bufopts)
            vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', bufopts)
            vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', bufopts)
            vim.keymap.set('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', bufopts) -- Try Lspsaga peek_definition
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        end

        -- LSP settings (for overriding per client)
        local handlers = {
            -- ['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border_shape}),
            -- ['textDocument/signatureHelp'] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border_shape}), -- disable in favour of Noice
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
            ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded'}), -- disable in favour of Noice
        }

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }
        mason_lspconfig.setup_handlers {
            function (server_name)
                local lspconfig = require('lspconfig')
                if server_name == 'powershell_es' then
                    lspconfig.powershell_es.setup {
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services" -LogPath "./powershell_es.log" -SessionDetailsPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal'},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices" -LogPath "./powershell_es.log" -SessionDetailsPath "./powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal -EnableConsoleRepl'},
                        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "Import-Module 'C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\PowerShellEditorServices.psd1'; Start-EditorServices -HostName 'Visual Studio Code Host' -HostProfileId 'Microsoft.VSCode' -HostVersion '2022.12.1' -AdditionalModules @('PowerShellEditorServices.VSCode') -BundledModulesPath 'c:\\Users\\aloknigam\\.vscode\\extensions\\ms-vscode.powershell-2022.12.1\\modules' -EnableConsoleRepl -LogLevel 'Normal' -LogPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\logs\\1671314645-cea5c434-0147-4205-b2be-5907f5a8b7de1671314642966\\EditorServices.log' -SessionDetailsPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\sessions\\PSES-VSCode-39524-314832.json' -FeatureFlags @() -Stdio"},
                        -- bundle_path = 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services',
                        capabilities = capabilities,
                        root_dir = function() return vim.fn.getcwd() end,
                        handlers = handlers,
                        on_attach = on_attach
                    }
                elseif server_name == 'omnisharp' then
                    lspconfig.omnisharp.setup {
                        cmd = { 'dotnet', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp/OmniSharp.dll'},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == 'omnisharp_mono' then
                    lspconfig.omnisharp_mono.setup {
                        cmd = { 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp-mono/OmniSharp.exe'},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == 'lua_ls' then
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
                                        vim.fn.stdpath('data') .. '/lazy/neodev.nvim/types/nightly',
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

AddPlugin {
    'glepnir/lspsaga.nvim',
    cmd = 'Lspsaga',
    opts = {
        beacon = {
            enable = true,
            frequency = 7,
        },
        code_action = {
            num_shortcut = true,
            show_server_name = true,
            keys = {
                quit = 'q',
                exec = '<CR>',
            },
        },
        definition = {
            edit = 'o',
            vsplit = '<C-v>',
            split = '<C-s>',
            tabe = '<C-t>',
            quit = 'q',
        },
        diagnostic = {
            show_code_action = false,
            show_source = true,
            jump_num_shortcut = true,
            --1 is max
            max_width = 0.7,
            custom_fix = nil,
            custom_msg = nil,
            text_hl_follow = false,
            keys = {
                exec_action = 'o',
                quit = 'q',
                go_action = 'g'
            },
        },
        finder = {
            open = {'o', '<CR>'},
            vsplit = '<C-v>',
            split = '<C-s>',
            tabe = '<C-t>',
            quit = {'q', '<ESC>'},
        },
        lightbulb = {
            enable = true,
            enable_in_insert = true,
            sign = false,
            sign_priority = 40,
            virtual_text = true,
        },
        outline = {
            win_position = 'right',
            win_with = '',
            win_width = 30,
            show_detail = true,
            auto_preview = true,
            auto_refresh = true,
            auto_close = true,
            custom_sort = nil,
            keys = {
                jump = 'o',
                expand_collapse = 'u',
                quit = 'q',
            },
        },
        preview = {
            lines_above = 0,
            lines_below = 10,
        },
        rename = {
            quit = '<C-c>',
            exec = '<CR>',
            mark = 'x',
            confirm = '<CR>',
            in_select = true,
        },
        request_timeout = 2000,
        scroll_preview = {
            scroll_down = '<C-n>',
            scroll_up = '<C-p>',
        },
        symbol_in_winbar = {
            enable = false,
            separator = ' ',
            hide_keyword = true,
            show_file = true,
            folder_level = 2,
            respect_root = false,
            color_mode = true,
        },
        ui = {
            border      = 'rounded',
            code_action = Icons.code_action,
            collapse    = Icons.collapse,
            diagnostic  = Icons.diagnostic,
            expand      = Icons.expand,
            hover       = Icons.hover,
            incoming    = Icons.incoming,
            outgoing    = Icons.outgoing,
            preview     = Icons.preview,
            theme       = 'round',
            title       = true,
            winblend    = 20,
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
            }
        }
    }
}

AddPlugin {
    'j-hui/fidget.nvim',
    opts = {
        text = {
            done = '󰄴',
            spinner = 'arc'
        }
    },
    event = 'LspAttach',
    tag = 'legacy'
}

AddPlugin {
    'jayp0521/mason-null-ls.nvim',
    config = function ()
        local mnls = require('mason-null-ls')
        mnls.setup({
            automatic_setup = true,
            handlers = {}
        })
    end,
    dependencies = { 'jose-elias-alvarez/null-ls.nvim', config = true },
    event = 'LspAttach'
}

AddPlugin { 'p00f/clangd_extensions.nvim' }

AddPlugin {
    'ray-x/navigator.lua',
    config = true,
    dependencies = {
        { 'ray-x/guihua.lua', build = 'cd lua/fzy && make' }
    },
    -- event = 'LspAttach'
}

AddPlugin {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    opts = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = { -- These keymaps can be a string or a table for multiple keys
            close = {"<Esc>", "q"},
            goto_location = "<Cr>",
            focus_location = "o",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a",
            fold = "h",
            unfold = "l",
            fold_all = "W",
            unfold_all = "E",
            fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
            Array         = { icon = Icons.Array        , hl = 'CmpItemKindArray'         },
            Boolean       = { icon = Icons.Boolean      , hl = 'CmpItemKindBoolean'       },
            Class         = { icon = Icons.Class        , hl = 'CmpItemKindClass'         },
            Component     = { icon = Icons.Component    , hl = 'CmpItemKindComponent'     },
            Constant      = { icon = Icons.Constant     , hl = 'CmpItemKindConstant'      },
            Constructor   = { icon = Icons.Constructor  , hl = 'CmpItemKindConstructor'   },
            Enum          = { icon = Icons.Enum         , hl = 'CmpItemKindEnum'          },
            EnumMember    = { icon = Icons.EnumMember   , hl = 'CmpItemKindEnumMembe'     },
            Event         = { icon = Icons.Event        , hl = 'CmpItemKindEvent'         },
            Field         = { icon = Icons.Field        , hl = 'CmpItemKindField'         },
            File          = { icon = Icons.File         , hl = 'CmpItemKindFile'          },
            Fragment      = { icon = Icons.Fragment     , hl = 'CmpItemKindFragment'      },
            Function      = { icon = Icons.Function     , hl = 'CmpItemKindFunction'      },
            Interface     = { icon = Icons.Interface    , hl = 'CmpItemKindInterface'     },
            Key           = { icon = Icons.Key          , hl = 'CmpItemKindKey'           },
            Method        = { icon = Icons.Method       , hl = 'CmpItemKindMethod'        },
            Module        = { icon = Icons.Module       , hl = 'CmpItemKindModule'        },
            Namespace     = { icon = Icons.Namespace    , hl = 'CmpItemKindNamespace'     },
            Null          = { icon = Icons.Null         , hl = 'CmpItemKindNull'          },
            Number        = { icon = Icons.Number       , hl = 'CmpItemKindNumber'        },
            Object        = { icon = Icons.Object       , hl = 'CmpItemKindObject'        },
            Operator      = { icon = Icons.Operator     , hl = 'CmpItemKindOperator'      },
            Package       = { icon = Icons.Package      , hl = 'CmpItemKindPackage'       },
            Property      = { icon = Icons.Property     , hl = 'CmpItemKindProperty'      },
            String        = { icon = Icons.String       , hl = 'CmpItemKindString'        },
            Struct        = { icon = Icons.Struct       , hl = 'CmpItemKindStruct'        },
            TypeParameter = { icon = Icons.TypeParameter, hl = 'CmpItemKindTypeParameter' },
            Variable      = { icon = Icons.Variable     , hl = 'CmpItemKindVariable'      },
        }
    }
}

AddPlugin {
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    opts = {
        icons = Icons,
        nerd_font = false
    }
}

AddPlugin {
    'weilbith/nvim-code-action-menu',
    config = function ()
        vim.g.code_action_menu_window_border = 'rounded'
    end,
    cmd = 'CodeActionMenu'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Markdown    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/iamcco/markdown-preview.nvim

AddPlugin {
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

AddPlugin {
    'yaocccc/nvim-hl-mdcodeblock.lua',
    config = function ()
        require('hl-mdcodeblock').setup({
            events = {                  -- refresh event
                "BufEnter",
                "InsertLeave",
                "TextChanged",
                -- "TextChangedI",
                "WinScrolled"
            },
            hl_group = "MDCodeBlock",   -- default highlight group
            -- minumum_len = function () return math.max(math.floor(vim.api.nvim_win_get_width(0) * 0.8), 100) end
            minumum_len = 10,           -- minimum len to highlight (number | function)
            padding_right = 1,          -- always append 4 space at lineend
            query_by_ft = {             -- special parser query by filetype
                markdown = {            -- filetype
                    'markdown',         -- parser
                    '(fenced_code_block) @codeblock', -- query
                },
                rmd = {                 -- filetype
                    'markdown',         -- parser
                    '(fenced_code_block) @codeblock', -- query
                },
            },
            timer_delay = 300,           -- refresh delay(ms)
        })
        vim.api.nvim_set_hl(0, "MDCodeBlock", { bg = AdaptiveBG(10, -10) })
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
AddPlugin {
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
    keys = {
        {'ba', '<Plug>BookmarkAnnotate'},
        {'bm', '<Plug>BookmarkToggle'},
        {'bn', '<Plug>BookmarkNext'},
        {'bp', '<Plug>BookmarkPrev'},
        {'bs', '<Plug>BookmarkShowAll'}
    }
}

-- https://github.com/cbochs/grapple.nvim
AddPlugin {
    'kshenoy/vim-signature',
    cmd = 'SignatureToggle'
}
-- use 'chentoast/marks.nvim'
-- use 'crusj/bookmarks.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Quickfix    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- |-----------------+-----------------------------------------------------------|
-- | Command         | Explaination                                              |
-- |-----------------+-----------------------------------------------------------|
-- | cc [n]          | jump to n quickfix, if n is omitted jump to current again |
-- | [c]cn           | jump to next quickfix, with [c] jump to next [c]          |
-- | [c]cp           | jump to previous quickfix, with [c] jump to previous [c]  |
-- | cf file         | read error from file into quickfix                        |
-- | cb              | read error list from current buffer                       |
-- | cdo cmd         | execute cmd on each quickfix                              |
-- | Cfilter[!] patt | Filter quickfix for patt, with ! filter for unmatched     |
-- | col [c]         | Go to previous quickfix windows, c for count              |
-- | cnew [c]        | Go to next quickfix windows, c for count                  |
-- | chi             | Show list of quickfix window history                      |
-- |-----------------+-----------------------------------------------------------|

AddPlugin {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
    opts = {
        position = 'bottom', -- position of the list can be: bottom, top, left, right
        height = 10, -- height of the trouble list when position is top or bottom
        width = 50, -- width of the list when position is left or right
        icons = true, -- use devicons for filenames
        mode = 'document_diagnostics', -- 'workspace_diagnostics', 'document_diagnostics', 'quickfix', 'lsp_references', 'loclist'
        fold_open = '', -- icon used for open folds
        fold_closed = '', -- icon used for closed folds
        group = true, -- group results by file
        padding = false, -- add an extra new line on top of the list
        action_keys = { -- key mappings for actions in the trouble list
            -- map to {} to remove a mapping, for example:
            -- close = {},
            close = 'q', -- close the list
            cancel = '<esc>', -- cancel the preview and get back to your last window / buffer / cursor
            refresh = 'r', -- manually refresh
            jump = {'<cr>', '<tab>'}, -- jump to the diagnostic or open / close folds
            open_split = { '<c-s>' }, -- open buffer in new split
            open_vsplit = { '<c-v>' }, -- open buffer in new vsplit
            open_tab = { '<c-t>' }, -- open buffer in new tab
            jump_close = {'o'}, -- jump to the diagnostic and close the list
            toggle_mode = 'm', -- toggle between 'workspace' and 'document' diagnostics mode
            toggle_preview = 'P', -- toggle auto_preview
            hover = 'K', -- opens a small popup with the full multiline message
            preview = 'p', -- preview the diagnostic location
            close_folds = {'zM', 'zm'}, -- close all folds
            open_folds = {'zR', 'zr'}, -- open all folds
            toggle_fold = {'zA', 'za'}, -- toggle fold of current file
            previous = 'k', -- previous item
            next = 'j' -- next item
        },
        indent_lines = true, -- add an indent guide below the fold icons
        auto_open = false, -- automatically open the list when you have diagnostics
        auto_close = false, -- automatically close the list when you have no diagnostics
        auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false, -- automatically fold a file trouble list at creation
        auto_jump = { 'lsp_definitions' }, -- for the given modes, automatically jump if there is only a single result
        signs = {
            error = Icons.error,
            hint = Icons.hint,
            information = Icons.info,
            other = Icons.diagnostic,
            warning = Icons.warn
        },
        use_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
    }
}

    -- |-------------+----------------------------------------------------------+---------|
    -- | Function    | Action                                                   | Def Key |
    -- |-------------+----------------------------------------------------------+---------|
    -- | open        | open the item under the cursor in quickfix window        | <CR>    |
    -- | openc       | open the item, and close quickfix window                 | o       |
    -- | drop        | use drop to open the item, and close quickfix window     | O       |
    -- | tabdrop     | use tab drop to open the item, and close quickfix window |         |
    -- | tab         | open the item in a new tab                               | t       |
    -- | tabb        | open the item in a new tab, but stay at quickfix window  | T       |
    -- | tabc        | open the item in a new tab, and close quickfix window    | <C-t>   |
    -- | split       | open the item in vertical split                          | <C-s>   |
    -- | vsplit      | open the item in horizontal split                        | <C-v>   |
    -- | prevfile    | go to previous file under the cursor in quickfix window  | <C-p>   |
    -- | nextfile    | go to next file under the cursor in quickfix window      | <C-n>   |
    -- | prevhist    | go to previous quickfix list in quickfix window          | <       |
    -- | nexthist    | go to next quickfix list in quickfix window              | >       |
    -- | lastleave   | go to last leaving position in quickfix window           | '"      |
    -- | stoggleup   | toggle sign and move cursor up                           | <S-Tab> |
    -- | stoggledown | toggle sign and move cursor down                         | <Tab>   |
    -- | stogglevm   | toggle multiple signs in visual mode                     | <Tab>   |
    -- | stogglebuf  | toggle signs for same buffers under the cursor           | '<Tab>  |
    -- | sclear      | clear the signs in current quickfix list                 | z<Tab>  |
    -- | pscrollup   | scroll up half-page in preview window                    | <C-b>   |
    -- | pscrolldown | scroll down half-page in preview window                  | <C-f>   |
    -- | pscrollorig | scroll back to original position in preview window       | zo      |
    -- | ptogglemode | toggle preview window between normal and max size        | zp      |
    -- | ptoggleitem | toggle preview for an item of quickfix list              | p       |
    -- | ptoggleauto | toggle auto preview when cursor moved                    | P       |
    -- | filter      | create new list for signed items                         | zn      |
    -- | filterr     | create new list for non-signed items                     | zN      |
    -- | fzffilter   | enter fzf mode                                           | zf      |
    -- |-------------+----------------------------------------------------------+---------|
AddPlugin {
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
                        ['ctrl-t'] = {
                            description = [[Press ctrl-t to open up the item in a new tab]],
                            default = 'tabedit'
                        },
                        ['ctrl-v'] = {
                            description = [[Press ctrl-v to open up the item in a new vertical split]],
                            default = 'vsplit'
                        },
                        ['ctrl-s'] = {
                            description = [[Press ctrl-x to open up the item in a new horizontal split]],
                            default = 'split'
                        },
                        ['ctrl-q'] = {
                            description = [[Press ctrl-q to toggle sign for the selected items]],
                            default = 'signtoggle'
                        },
                        ['ctrl-c'] = {
                            description = [[Press ctrl-c to close quickfix window and abort fzf]],
                            default = 'closeall'
                        }
                    },
                    extra_opts = {
                        description = 'Extra options for fzf',
                        default = {'--bind', 'ctrl-o:toggle-all'}
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
            local filepath = vim.fn.fnamemodify(vim.fn.bufname('%'), ':p:h')
            setCwd(filepath)
        elseif opts.args == "file_git" then
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
AddPlugin {
    -- PERF: remove Telescope dependency
    -- https://github.com/aaditeynair/conduct.nvim
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
AddPlugin {
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
AddPlugin { -- STATUSCOL_OUT %@v:lua.ScFa@%C%T%#SignColumn#%*%=34%#SignColumn# %*
    'luukvbaal/statuscol.nvim',
    config = function()
        local builtin = require('statuscol.builtin')
        require('statuscol').setup({
            setopt = true,         -- Whether to set the 'statuscolumn' option, may be set to false for those who
            -- want to use the click handlers in their own 'statuscolumn': _G.Sc[SFL]a().
            -- Although I recommend just using the segments field below to build your
            -- statuscolumn to benefit from the performance optimizations in this plugin.
            -- builtin.lnumfunc number string options
            thousands = false,     -- or line number thousands separator string ("." / ",")
            relculright = true,   -- whether to right-align the cursor line number with 'relativenumber' set
            -- Builtin 'statuscolumn' options
            ft_ignore = nil,       -- lua table with filetypes for which 'statuscolumn' will be unset
            bt_ignore = nil,       -- lua table with 'buftype' values for which 'statuscolumn' will be unset
            -- Default segments (fold -> sign -> line number + separator), explained below
            segments = {
                { text = { '%C' }, click = 'v:lua.ScFa' },
                { sign = { name = { 'todo.*' } }, condition = { function() return TODO_COMMENTS_LOADED ~= nil end }, auto = true },
                { sign = { name = { 'Diagnostic' }, fillcharhl ='LineNr', auto = true } },
                { text = { builtin.lnumfunc }, condition = { true } },
                { sign = {
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
                }},
            },
            clickmod = "c",         -- modifier used for certain actions in the builtin clickhandlers:
            -- "a" for Alt, "c" for Ctrl and "m" for Meta.
            clickhandlers = {       -- builtin click handlers
                Lnum                    = builtin.lnum_click,
                FoldClose               = builtin.foldclose_click,
                FoldOpen                = builtin.foldopen_click,
                FoldOther               = builtin.foldother_click,
                DapBreakpointRejected   = builtin.toggle_breakpoint,
                DapBreakpoint           = builtin.toggle_breakpoint,
                DapBreakpointCondition  = builtin.toggle_breakpoint,
                DiagnosticSignError     = builtin.diagnostic_click,
                DiagnosticSignHint      = builtin.diagnostic_click,
                DiagnosticSignInfo      = builtin.diagnostic_click,
                DiagnosticSignWarn      = builtin.diagnostic_click,
                GitSignsTopdelete       = builtin.gitsigns_click,
                GitSignsUntracked       = builtin.gitsigns_click,
                GitSignsAdd             = builtin.gitsigns_click,
                GitSignsChange          = builtin.gitsigns_click,
                GitSignsChangedelete    = builtin.gitsigns_click,
                GitSignsDelete          = builtin.gitsigns_click,
                gitsigns_extmark_signs_ = builtin.gitsigns_click,
            }
        })
    end,
    -- event = 'VeryLazy'
}

--<~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Status Line   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    'nvim-lualine/lualine.nvim',
    config = function()
        local function lspIcon()
            local anim ={ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            Icon_index = (Icon_index) % #anim + 1
            return anim[Icon_index]
        end

        local function GetFgOrFallback(hl_name, fallback)
            local hl = vim.api.nvim_get_hl_by_name(hl_name, true)
            if hl then
                return string.format("#%X", hl.foreground)
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
                        'mode', -- use Neovim icon in normal mode
                        color = { gui = 'bold' },
                        fmt = function(str)
                            return str:sub(1,1)
                        end,
                        padding = { left = 0, right = 0 },
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
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        on_click = function()
                            vim.cmd('NvimTreeToggle')
                        end,
                        path = 0,                -- 0: Just the filename
                        padding = { left = 1, right = 1 },
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = Icons.file_modified, -- Text to show when the file is modified.
                            readonly = Icons.file_readonly, -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = Icons.file_unnamed,  -- Text to show for unnamed buffers.
                            newfile  = Icons.file_newfile   -- Text to show for new created file before first writting
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
                        -- icon = {'󰦓', color = {fg = '#9C95DC'}},
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
                        -- icon = {'', color = {fg = '#9C95DC'}},
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
                        icon = {'', color = { fg = string.format("#%X", vim.api.nvim_get_hl_by_name('Function', true).foreground)}},
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
                        cond = IsLspAttached,
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
                        -- icon = {'󰍒', align = 'left'},
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
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        path = 0,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = Icons.file_modified, -- Text to show when the file is modified.
                            readonly = Icons.file_readonly, -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = Icons.file_unnamed, -- Text to show for unnamed buffers.
                            newfile  = Icons.file_newfile, -- Text to show for new created file before first writting
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
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = true,   -- Display new file status (new file means no write after created)
                        path = 3,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = Icons.file_modified, -- Text to show when the file is modified.
                            readonly = Icons.file_readonly, -- Text to show when the file is non-modifiable or readonly.
                            unnamed  = Icons.file_unnamed, -- Text to show for unnamed buffers.
                            newfile  = Icons.file_newfile, -- Text to show for new created file before first writting
                        }
                    }
                },
            },
            extensions = {
                'aerial',
                'lazy',
                'nvim-tree',
                'quickfix',
                'symbols-outline',
                'toggleterm',
                'trouble',
            }
        }
    end,
    event = 'User VeryLazy',
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/willothy/nvim-cokeline
AddPlugin {
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
                -- element consists of {filetype: string, path: string, extension: string, directory: string}
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
            middle_mouse_command = 'bdelete! %d',
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
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Telescope   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/axkirillov/easypick.nvim
AddPlugin {
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
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                },
                undo = {
                    side_by_side = true
                }
            },
        })
        telescope.load_extension('fzf')
        telescope.load_extension('heading')
        telescope.load_extension('undo')
        telescope.load_extension('vim_bookmarks')
        vim.cmd[[autocmd User TelescopePreviewerLoaded setlocal nu]]
    end,
    dependencies = {
        'crispgm/telescope-heading.nvim',
        'debugloop/telescope-undo.nvim',
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        {'tom-anders/telescope-vim-bookmarks.nvim', dependencies = 'MattesGroeger/vim-bookmarks'}
    }
}

AddPlugin {
    'princejoogie/dir-telescope.nvim',
    cmd = { 'FileInDirectory', 'GrepInDirectory' },
    opts = {
        hidden = true,
        respect_gitignore = true,
    },
    dependencies = 'nvim-telescope/telescope.nvim',
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Terminal    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/voldikss/vim-floaterm

AddPlugin {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = true
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Tests      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/andythigpen/nvim-coverage
-- https://github.com/klen/nvim-test
-- https://github.com/nvim-neotest/neotest -- FEAT: use me
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Treesitter   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
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

AddPlugin {
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
            },
            rainbow = { -- TODO: still needed ?
                enable = true,
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
            }
        })
    end,
    dependencies = { { 'm-demare/hlargs.nvim' } },
    module = false
}

AddPlugin {
    'HiPhish/rainbow-delimiters.nvim',
    config = function()
        local rainbow_delimiters = require 'rainbow-delimiters'

        vim.g.rainbow_delimiters = {
            strategy = {
                [''] = rainbow_delimiters.strategy['global'],
                -- vim = rainbow_delimiters.strategy['local'],
            },
            query = {
                [''] = 'rainbow-delimiters',
                -- lua = 'rainbow-delimiters',
            },
            highlight = {
                'RainbowDelimiterRed',
                'RainbowDelimiterYellow',
                'RainbowDelimiterBlue',
                'RainbowDelimiterOrange',
                'RainbowDelimiterGreen',
                'RainbowDelimiterViolet',
                'RainbowDelimiterCyan',
            },
            -- blacklist = { 'lua' }
        }
        require('rainbow-delimiters').enable()
    end,
    -- event = 'CursorHold' -- FIX: slow on large files
}

AddPlugin {
    -- https://github.com/David-Kunz/markid
    'm-demare/hlargs.nvim',
    config = function()
        require('hlargs').setup({
            colorpalette = ColorPalette(),
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
    end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━       UI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
AddPlugin {
    -- @recording messages from messages https://www.reddit.com/r/neovim/comments/138ahlo/recording_a_macro_with_set_cmdheight0/
    'folke/noice.nvim',
    -- cond = function() return not vim.g.neovide end,
    config = function()
        vim.o.lazyredraw = false
        require('noice').setup({
            cmdline = {
                enabled = true, -- enables the Noice cmdline UI
                view = 'cmdline_popup', -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
                opts = {}, -- global options for the cmdline. See section on views
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = { pattern = '^:', icon = '', lang = 'vim', title = ''},
                    filter = { pattern = '^:%s*!', icon = '$', lang = 'powershell' , title = ''},
                    help = { pattern = '^:%s*he?l?p?%s+', icon = '' , title = ''},
                    input = {}, -- Used by input()
                    lua = { pattern = '^:%s*lua%s+', icon = '', lang = 'lua' , title = ''},
                    lua_print = { pattern = '^:%s*lua=%s+', icon = '󰇼', lang = 'lua' , title = ''},
                    search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex', view = 'cmdline' , title = ''},
                    search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' , title = ''},
                    -- lua = false, -- to disable a format, set to `false`
                },
            },
            messages = {
                -- If you enable messages, then the cmdline is enabled automatically.
                -- This is a current Neovim limitation.
                enabled = true, -- enables the Noice messages UI
                view = 'notify', -- default view for messages
                view_error = 'notify', -- view for errors
                view_warn = 'notify', -- view for warnings
                view_history = 'messages', -- view for :messages
                view_search = 'virtualtext', -- view for search count messages. Set to `false` to disable
            },
            popupmenu = {
                enabled = true, -- enables the Noice popupmenu UI
                backend = 'cmp', -- backend to use to show regular cmdline completions
                -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
                kind_icons = {}, -- set to `false` to disable icons
            },
            -- default options for require('noice').redirect
            -- see the section on Command Redirection
            redirect = {
                view = 'popup',
                filter = { event = 'msg_show' },
            },
            -- You can add any custom commands below that will be available with `:Noice command`
            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
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
                -- :Noice last
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
                -- :Noice errors
                errors = {
                    -- options for the message history that you get with `:Noice`
                    view = 'popup',
                    opts = { enter = true, format = 'details' },
                    filter = { error = true },
                    filter_opts = { reverse = true },
                },
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always 'notify' and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = true,
                view = 'notify',
            },
            lsp = {
                progress = {
                    enabled = true,
                    -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                    -- See the section on formatting for more details on how to customize.
                    format = 'lsp_progress',
                    format_done = 'lsp_progress_done',
                    throttle = 1000 / 30, -- frequency to update lsp progress message
                    view = 'mini',
                },
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
                    -- override the lsp markdown formatter with Noice
                    ['vim.lsp.util.stylize_markdown'] = false,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ['cmp.entry.get_documentation'] = false,
                },
                hover = {
                    enabled = true,
                    view = nil, -- when nil, use defaults from documentation
                    opts = {}, -- merged with defaults from documentation
                },
                signature = { -- 'ray-x/lsp_signature.nvim'
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    opts = {}, -- merged with defaults from documentation
                },
                message = {
                    -- Messages shown by lsp servers
                    enabled = true,
                    view = 'notify',
                    opts = {},
                },
                -- defaults for hover and signature help
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
                    ['|(%S-)|'] = vim.cmd.help, -- vim help links
                    ['%[.-%]%((%S-)%)'] = require('noice.util').open, -- markdown links
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
                checker = false, -- Disable if you don't want health checks to run
            },
            smart_move = {
                -- noice tries to move out of the way of existing floating windows.
                enabled = true, -- you can disable this behaviour here
                -- add any filetypes here, that shouldn't trigger smart move.
                excluded_filetypes = { 'cmp_menu', 'cmp_docs', 'notify' },
            },
            presets = {
                -- you can enable a preset by setting it to true, or a table that will override the preset config
                -- you can also add custom presets that you can enable/disable with enabled=true
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = false, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
            throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
            views = {
                -- cmdline_popup = {
                --     border = {
                --         style = "none",
                --         padding = { 0, 0 },
                --     },
                --     filter_options = {},
                --     win_options = {
                --         winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                --     },
                -- },
            }, ---@see section on views
            routes = {{
                view = "notify",
                filter = { event = "msg_showmode" },
            }},
            status = {}, --- @see section on statusline components
            format = {}, --- @see section on formatting
        })
    end,
    dependencies = { 'MunifTanjim/nui.nvim' },
    enabled = true,
    event = 'CmdlineEnter'
}

AddPlugin {
    'rcarriga/nvim-notify',
    config = function()
        local notify = require('notify')
        notify.setup({
            -- background_colour = vim.api.nvim_get_hl_by_name('Normal', true).background and 'Normal' or '#000000',
            minimum_width = 0,
            render = 'minimal',
            stages = 'slide'
        })
        vim.notify = notify
    end
}

AddPlugin {
    'stevearc/dressing.nvim'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Utilities    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/wellle/targets.vim
AddPlugin { -- config
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

AddPlugin {
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
                    H1Marker = '󰉫 ', -- Used by markdown treesitter parser
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
                    MarkdownH1 = '󰉫 ', -- Used by builtin markdown source
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


AddPlugin {
    'Danielhp95/tmpclone-nvim',
    cmd = 'TmpcloneClone'
}

-- https://github.com/EtiamNullam/deferred-clipboard.nvim
-- https://github.com/Marskey/telescope-sg

AddPlugin {
    'LiadOz/nvim-dap-repl-highlights',
    config = true
}

AddPlugin {
    'Pocco81/true-zen.nvim',
    cmd = { 'TZAtaraxis', 'TZMinimalist', 'TZNarrow', 'TZFocus' }
}

AddPlugin {
    'ThePrimeagen/refactoring.nvim',
    cmd = 'Refactor',
    config = true,
    dependencies = {
        {'nvim-lua/plenary.nvim'},
    }
}

AddPlugin {
    'TobinPalmer/BetterGx.nvim',
    keys = {
        { 'gx', '<CMD>lua require("better-gx").BetterGx()<CR>' },
    }
}

-- https://github.com/Wiebesiek/ZeoVim

AddPlugin {
    -- https://github.com/rareitems/printer.nvim
    'andrewferrier/debugprint.nvim',
    opts = {
        create_keymaps = false,
        create_commands = false,
        filetypes = {
            ["python"] = {
                left = 'print(f"',
                right = '")',
                mid_var = "{",
                right_var = '}")',
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

-- https://github.com/anuvyklack/hydra.nvim

AddPlugin {
    'cbochs/portal.nvim',
    cmd = 'Portal',
    dependencies = {
        'cbochs/grapple.nvim',
        'ThePrimeagen/harpoon'
    }
}

-- https://github.com/chipsenkbeil/distant.nvim

AddPlugin {
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

AddPlugin {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
}

-- https://github.com/dstein64/nvim-scrollview
AddPlugin {
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

AddPlugin {
    'echasnovski/mini.move',
    keys = {
        { "<C-h>", mode = 'v' },
        { "<C-l>", mode = 'v' },
        { "<C-j>", mode = 'v' },
        { "<C-k>", mode = 'v' },
        { "H", mode = 'n' },
        { "L", mode = 'n' },
        { "J", mode = 'n' },
        { "K", mode = 'n' },
    },
    opts = {
        mappings = {
            left = "<C-h>",
            right = "<C-l>",
            down = "<C-j>",
            up = "<C-k>",
            line_left = "H",
            line_right = "L",
            line_down = "J",
            line_up = "K",
        },
        options = {
            reindent_linewise = true
        }
    }
}

AddPlugin {
    'folke/neodev.nvim',
    event = 'LspAttach *.lua',
    opts = {
        library = {
            enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
            -- these settings will be used for your Neovim config directory
            runtime = true, -- runtime path
            types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
            plugins = true, -- installed opt or start plugins in packpath
            -- you can also specify the list of plugins to make available as a workspace library
            -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
        },
        setup_jsonls = false, -- configures jsonls to provide completion for project specific .luarc.json files
        -- for your Neovim config directory, the config.library settings will be used as is
        -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
        -- for any other directory, config.library.enabled will be set to false
        override = function(_, _) end,
        -- With lspconfig, Neodev will automatically setup your lua-language-server
        -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
        -- in your lsp start options
        lspconfig = true,
        -- much faster, but needs a recent built of lua-language-server
        -- needs lua-language-server >= 3.6.0
        pathStrict = true,
    }
}

-- 'jbyuki/instant.nvim'

AddPlugin {
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

-- https://github.com/glacambre/firenvim

AddPlugin {
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

-- https://github.com/mrshmllow/open-handlers.nvim

-- https://github.com/kndndrj/nvim-dbee

AddPlugin {
    'kylechui/nvim-surround',
    config = true
}

-- https://github.com/lewis6991/hover.nvim

-- https://github.com/mangelozzi/rgflow.nvim

AddPlugin {
    'mg979/vim-visual-multi',
    config = function()
        vim.cmd[[
            nmap <C-LeftMouse> <Plug>(VM-Mouse-Cursor)
            nmap <C-RightMouse> <Plug>(VM-Mouse-Word)
        ]]
    end,
    keys = { '<C-LeftMouse>', '<C-RightMouse>', '<C-Up>', '<C-Down>', '<C-N>' }
}

-- https://github.com/miversen33/netman.nvim
-- https://github.com/mrshmllow/open-handlers.nvim
-- https://github.com/nat-418/scamp.nvim

-- AddPlugin { 'nacro90/numb.nvim', config = true, event = 'CmdlineChanged' }

AddPlugin {
    -- https://github.com/RutaTang/compter.nvim
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

-- https://github.com/nosduco/remote-sshfs.nvim

AddPlugin {
    -- Lua copy https://github.com/ojroques/nvim-osc52
    'ojroques/vim-oscyank',
    cond = function()
        -- Check if connection is ssh
        return vim.env.SSH_CLIENT ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif]]
    end,
    lazy = false
}

AddPlugin {
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
}

-- https://github.com/roobert/surround-ui.nvim

AddPlugin {
    'ryleelyman/latex.nvim',
    config = true,
    ft = 'tex'
}

AddPlugin {
    'sickill/vim-pasta',
    config = function()
        vim.g.pasta_paste_before_mapping = '[p'
        vim.g.pasta_paste_after_mapping = '[P'
    end,
    keys = { '[p', '[P' }
}

AddPlugin {
    'shortcuts/no-neck-pain.nvim',
    cmd = 'NoNeckPain'
}

-- https://github.com/tomiis4/BufferTabs.nvim

AddPlugin {
    'tummetott/reticle.nvim',
    config = true
}

AddPlugin {
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

AddPlugin {
    'utilyre/sentiment.nvim',
    config = true,
    event = { 'CursorHold', 'CursorHoldI' }
}

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
-- Powershell indent issue autopair issue https://www.reddit.com/r/neovim/comments/14av861/powershell_indent_issue/
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/Weissle/persistent-breakpoints.nvim
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-fuzzy.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump.md
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-surround.md
-- https://github.com/hrsh7th/cmp-copilot
-- https://github.com/james1236/backseat.nvim
-- https://github.com/madox2/vim-ai
-- https://github.com/ofirgall/goto-breakpoints.nvim
-- https://github.com/zbirenbaum/copilot-cmp
-- https://github.com/zbirenbaum/copilot.lua

require('lazy').setup(Plugins, Lazy_config)
ColoRand()
-- <~>
-- vim: fmr=</>,<~> fdm=marker
