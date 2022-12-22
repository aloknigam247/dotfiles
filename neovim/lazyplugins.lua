--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]
-- TODO: format on paste
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
LazyConfig = {
  root = vim.fn.stdpath("data") .. "/lazy", -- directory where plugins will be installed
  defaults = {
    lazy = true, -- should plugins be lazy-loaded?
    version = nil,
  },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json", -- lockfile generated after running update.
  concurrency = nil, ---@type number limit the maximum amount of concurrent tasks
  git = {
    log = { "--since=3 days ago" }, -- show commits from the last 3 days
    timeout = 120, -- kill processes that take more than 2 minutes
    url_format = "https://github.com/%s.git",
  },
  dev = {
    path = "~/projects",
    patterns = {}, -- For example {"folke"}
  },
  install = {
    missing = true,
    colorscheme = { },
  },
  ui = {
    border = "rounded",
    icons = {
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      keys = " ",
      plugin = " ",
      runtime = " ",
      source = " ",
      start = "",
      task = " ",
    },
    throttle = 20, -- how frequently should the ui process render events
  },
  checker = {
    enabled = false,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = true, -- get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
  },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("state") .. "/lazy/cache",
      -- Once one of the following events triggers, caching will be disabled.
      -- To cache all modules, set this to `{}`, but that is not recommended.
      -- The default is to disable on:
      --  * VimEnter: not useful to cache anything else beyond startup
      --  * BufReadPre: this will be triggered early when opening a file from the command line directly
      disable_events = { },
    },
    reset_packpath = true, -- reset the package path to improve startup time
    rtp = {
      reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
      disabled_plugins = {
        -- "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        -- "tarPlugin",
        -- "tohtml",
        -- "tutor",
        -- "zipPlugin",
      },
    },
  },
  -- lazy can generate helptags from the headings in markdown readme files,
  -- so :help works even for plugins that don't have vim docs.
  -- when the readme opens with :help it will be correctly displayed as markdown
  readme = {
    root = vim.fn.stdpath("state") .. "/lazy/readme",
    files = { "README.md" },
    -- only generate markdown helptags for plugins that dont have docs
    skip_if_doc_exists = true,
  },
}
-- <~>

-- setup ➡️ init
-- requires ➡️ dependencies
-- as ➡️ name
-- opt ➡️ lazy
-- run ➡️ build
-- lock ➡️ pin
-- module is auto-loaded. No need to specify


Plugins = {
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
},

-- use 'echasnovski/mini.align',

{
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign'
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'windwp/nvim-autopairs',
    config = function()
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require'nvim-autopairs.conds'

        npairs.setup({
            enable_check_bracket_line = false -- Don't add pairs if close pair is in the same line
        })
        npairs.add_rules {
            -- #include <> pair for c and cpp
            Rule("#include <", ">", { "c", "cpp" }),
            -- Disable " rule for vim
            Rule('"', '"')
            :with_pair(cond.not_filetypes({"vim"})),
            -- Add spaces in pair after parentheses
            -- (|) --> space --> ( | )
            -- ( | ) --> ) --> ( )|
            Rule(' ', ' ')
            :with_pair(function (opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({ '()', '[]', '{}' }, pair)
            end),
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
        -- Insert `(` after select function or method item
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
        )
    end,
    event = 'InsertEnter',
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Coloring    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- {
--     'David-Kunz/markid',
--     -- after = 'nvim-treesitter'
--     config = function()
--         local m = require'markid'
--         require'nvim-treesitter.configs'.setup {
--             markid = {
--                 enable = true,
--                 colors = m.colors.medium,
--                 queries = m.queries,
--                 is_supported = function(lang)
--                     local queries = configs.get_module("markid").queries
--                     return pcall(vim.treesitter.parse_query, lang, queries[lang] or queries['default'])
--                 end
--             }
--         }
--     end
-- },

{
    'RRethy/vim-illuminate',
    config = function()
        require('illuminate').configure({
            providers =  {
                -- 'lsp',
                'treesitter',
                'regex'
            }
        })
        function LightenDarkenColor(col, amt)
            local num = tonumber(col, 16)
            local r = bit.rshift(num, 16) + amt
            local b = bit.band(bit.rshift(num, 8), 0x00FF) + amt
            local g = bit.band(num, 0x0000FF) + amt
            local newColor = bit.bor(g, bit.bor(bit.lshift(b, 8), bit.lshift(r, 16)))
            return string.format("#%X", newColor)
        end

        local bg = vim.api.nvim_get_hl_by_name('Normal', true).background
        bg = string.format("%X", tostring(bg))
        -- print(bg)
        if (vim.o.background ==  "dark") then
            bg = LightenDarkenColor(bg, 40)
        else
            bg = LightenDarkenColor(bg, -40)
        end
        -- print(bg)
        vim.api.nvim_set_hl(0, "IlluminatedWordText", {
            bg = bg,
            -- underline = true
        })
        vim.cmd[[
           " hi IlluminatedWordText guibg = underline
           hi IlluminatedWordRead guibg = #A5BE00 guifg = #000000
           hi IlluminatedWordWrite guibg = #1F7A8C gui = italic
           hi LspReferenceText guibg = #679436
           hi LspReferenceWrite guibg = #A5BE00
           hi LspReferenceRead guibg = #427AA1
       ]]
    end,
    -- dependencies = 'nvim-treesitter', TODO:
    event = 'CursorHold'
},

-- use 'azabiong/vim-highlighter'

{
    'folke/lsp-colors.nvim',
    event = "LspAttach"
},

-- -- https://github.com/folke/paint.nvim

{
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
    end,
    event = "CursorHold"
},

{
    'kevinhwang91/nvim-hlslens',
    config = function()
        require('hlslens').setup()
    end,
    keys = { "n", "N", "*", "#", "g*", "g#" }
},

{
    'melkster/modicator.nvim',
    config = function()
        local modicator = require('modicator')
        local modes = {
            ['R'] = vim.api.nvim_get_hl_by_name('lualine_a_replace', true).background,
            ['S'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['V'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
            ['c'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['i'] = vim.api.nvim_get_hl_by_name('lualine_a_insert', true).background,
            ['n'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['s'] = vim.api.nvim_get_hl_by_name('lualine_a_normal', true).background,
            ['v'] = vim.api.nvim_get_hl_by_name('lualine_a_visual', true).background,
        }
        if vim.fn.hlexists('lualine_a_command') ~= 0 then
            modes['c'] = vim.api.nvim_get_hl_by_name('lualine_a_command', true).background
        end
        modicator.setup({
            line_numbers = true,
            cursorline = true,
            highlights = {
                modes = modes
            }
        })

        modicator.set_highlight(modes['n'])
    end,
    dependencies = 'nvim-lualine/lualine.nvim',
    event = 'CursorHold'
},

{
    'norcalli/nvim-colorizer.lua',
    cmd = "ColorizerToggle",
    config = function()
    require('colorizer').setup()
    end
},

{
    't9md/vim-quickhl',
    config = function()
        vim.cmd[[
            nmap <Leader>w <Plug>(quickhl-manual-this)
            xmap <Leader>w <Plug>(quickhl-manual-this)
            nmap <Leader>W <Plug>(quickhl-manual-reset)
            xmap <Leader>W <Plug>(quickhl-manual-reset)
        ]]
    end,
    keys = {'<Leader>w', "<Leader>W"}
},

{
    -- https://github.com/xiyaowong/nvim-transparent
    'tribela/vim-transparent',
    cmd = 'TransparentToggle'
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>

-- https://github.com/lifepillar/vim-colortemplate
-- https://github.com/folke/styler.nvim

{ 'Domeee/mosel.nvim',                event = 'User mosel'         },
{ 'EdenEast/nightfox.nvim',           event = 'User nightfox'      },
{ 'LunarVim/darkplus.nvim',           event = 'User darkplus'      },
{ 'Mofiqul/adwaita.nvim',             event = 'User adwaita'       },
{ 'NLKNguyen/papercolor-theme',       event = 'User PaperColor'    },
{ 'Shatur/neovim-ayu',                event = 'User ayu'           },
{ 'Th3Whit3Wolf/one-nvim',            event = 'User one-nvim'      },
{ 'Yazeed1s/oh-lucy.nvim',            event = 'User oh-lucy'       },
{ 'aca/vim-monokai-pro',              event = 'User monokai_pro'   },
{ 'atelierbram/Base2Tone-nvim',       event = 'User base2tone'     },
{ 'catppuccin/nvim',                  event = 'User catppuccin'    },
{ 'cpea2506/one_monokai.nvim',        event = 'User one_monokai'   },
{ 'fenetikm/falcon',                  event = 'User falcon'        },
{ 'folke/tokyonight.nvim',            event = 'User tokyonight'    },
{ 'gbprod/nord.nvim',                 event = 'User nord'          },
{ 'glepnir/zephyr-nvim',              event = 'User zephyr'        },
{ 'jsit/toast.vim',                   event = 'User toast'         },
{ 'kaiuri/nvim-juliana',              event = 'User juliana'       },
{ 'kvrohit/mellow.nvim',              event = 'User mellow'        },
{ 'lmburns/kimbox',                   event = 'User kimbox'        },
{ 'luisiacc/gruvbox-baby',            event = 'User gruvbox-baby'  },
{ 'marko-cerovac/material.nvim',      event = 'User material'      },
{ 'maxmx03/FluoroMachine.nvim',       event = 'User fluoromachine' },
{ 'mhartington/oceanic-next',         event = 'User OceanicNext'   },
{ 'ntk148v/vim-horizon',              event = 'User horizon'       },
{ 'nxvu699134/vn-night.nvim',         event = 'User vn-night'      },
{ 'nyoom-engineering/oxocarbon.nvim', event = 'User oxocarbon'     },
{ 'olimorris/onedarkpro.nvim',        event = 'User onedarkpro'    },
{ 'projekt0n/github-nvim-theme',      event = 'User github'        },
{ 'rafamadriz/neon',                  event = 'User neon'          },
{ 'ray-x/aurora',                     event = 'User aurora'        },
{ 'ray-x/starry.nvim',                event = 'User starry'        },
{ 'rebelot/kanagawa.nvim',            event = 'User kanagawa'      },
{ 'rmehri01/onenord.nvim',            event = 'User onenord'       },
{ 'rose-pine/neovim',                 event = 'User rose-pine'     },
{ 'sainnhe/edge',                     event = 'User edge'          },
{ 'sainnhe/everforest',               event = 'User everforest'    },
{ 'sainnhe/sonokai',                  event = 'User sonokai'       },
{ 'sam4llis/nvim-tundra',             event = 'User tundra'        },
{ 'savq/melange',                     event = 'User melange'       },
{ 'shaunsingh/moonlight.nvim',        event = 'User moonlight'     },
{ 'sickill/vim-monokai',              event = 'User vim-monokai'   },
{ 'tanvirtin/monokai.nvim',           event = 'User monokai.nvim'  },
{ 'theniceboy/nvim-deus',             event = 'User deus'          },
{ 'tiagovla/tokyodark.nvim',          event = 'User tokyodark'     },
{ 'titanzero/zephyrium',              event = 'User zephyrium'     },
{ 'tomasiser/vim-code-dark',          event = 'User codedark'      },
{ 'w3barsi/barstrata.nvim',           event = 'User barstrata'     },
{ 'wuelnerdotexe/vim-enfocado',       event = 'User enfocado'      },
{ 'yashguptaz/calvera-dark.nvim',     event = 'User calvera'       },
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'b3nj5m1n/kommentary',
    config = function()
        require('kommentary.config').configure_language("default", {
            prefer_single_line_comments = true,
        })
        vim.api.nvim_set_keymap("n", "<C-t>", "<Plug>kommentary_line_default", {})
        vim.api.nvim_set_keymap("v", "<C-t>", "<Plug>kommentary_visual_default", {})
    end,
    -- init = function()
        -- vim.g.kommentary_create_default_mappings = false
    -- end,
    keys = { "<C-t>" }
},
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Completion   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'hrsh7th/nvim-cmp',
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    {
                        name = 'cmdline',
                    },
                }
            }),
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            }),
            experimental = {
                ghost_text = true
            },
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    if entry.source.name == "nvim_lsp" then
                        vim_item.menu = '{' .. entry.source.source.client.name .. '}'
                    elseif entry.source.name == "cmdline" then
                        vim_item.menu = "(options)"
                        vim_item.kind = "Options"
                    elseif entry.source.name == "cmdline_history" then
                        vim_item.menu = "(history)"
                        vim_item.kind = "History"
                    else
                        vim_item.menu = '[' .. entry.source.name .. ']'
                    end
                    local kind_symbol = vim.g.cmp_kinds[vim_item.kind]
                    vim_item.kind = kind_symbol and kind_symbol .. vim_item.kind or vim_item.kind

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
                    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end
            },
            sources = ({
                {
                    name = 'buffer',
                    option = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end
                    }
                },
                { name = 'neorg' },
                { name = 'nvim_lsp' },
                { name = 'snippy' }
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

    end,
    -- use 'kwkarlwang/cmp-nvim-insert-text-lsp'
    dependencies = { "dcampos/cmp-snippy", "dcampos/nvim-snippy","hrsh7th/cmp-buffer", "hrsh7th/cmp-cmdline", "hrsh7th/cmp-nvim-lsp" },
    event = { "CmdlineEnter", "InsertEnter" }
},

-- https://github.com/jameshiew/nvim-magic
-- https://github.com/kristijanhusak/vim-dadbod-completion
-- https://github.com/lukas-reineke/cmp-rg
-- https://github.com/lukas-reineke/cmp-under-comparator
-- https://github.com/rcarriga/cmp-dap
-- https://github.com/tzachar/cmp-fuzzy-buffer
-- https://github.com/tzachar/cmp-fuzzy-path
-- https://github.com/zbirenbaum/copilot-cmp
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Debugger    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO:
-- Abstract-IDE dap configs
-- --------------------------
-- -- telescope-dap.nvim
-- pcall(require'telescope'.load_extension, 'dap')
-- --------------------------
--
--
-- --------------------------
-- -- nvim-dap-ui
-- require("dapui").setup({
-- 	icons = {expanded = "▾", collapsed = "▸"},
-- 	-- Expand lines larger than the window
-- 	-- Requires >= 0.7
-- 	expand_lines = vim.fn.has("nvim-0.7"),
-- 	sidebar = {
-- 		-- You can change the order of elements in the sidebar
-- 		elements = {
-- 			-- Provide as ID strings or tables with "id" and "size" keys
-- 			{
-- 				id = "scopes",
-- 				size = 0.25, -- Can be float or integer > 1
-- 			},
-- 			{id = "breakpoints", size = 0.25},
-- 			{id = "stacks", size = 0.25},
-- 			{id = "watches", size = 00.25},
-- 		},
-- 		size = 40,
-- 		position = "left", -- Can be "left", "right", "top", "bottom"
-- 	},
-- 	tray = {
-- 		elements = {"repl", "console"},
-- 		size = 10,
-- 		position = "bottom", -- Can be "left", "right", "top", "bottom"
-- 	},
-- 	floating = {
-- 		max_height = nil, -- These can be integers or a float between 0 and 1.
-- 		max_width = nil, -- Floats will be treated as percentage of your screen.
-- 		border = "single", -- Border style. Can be "single", "double" or "rounded"
-- 		mappings = {close = {"q", "<Esc>"}},
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
-- require("nvim-dap-virtual-text").setup {
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
-- https://github.com/jayp0521/mason-nvim-dap.nvim
-- use {
--     'jbyuki/one-small-step-for-vimkind',
--     config = function()
--         local dap = require"dap"
--         dap.configurations.lua = {
--             {
--                 type = 'nlua',
--                 request = 'attach',
--                 name = "Attach to running Neovim instance",
--             }
--         }

--         dap.adapters.nlua = function(callback, config)
--             callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
--         end
--     end
-- }
-- https://github.com/nvim-telescope/telescope-vimspector.nvim
-- https://github.com/puremourning/vimspector
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'Pocco81/dap-buddy.nvim'
-- use {
--     'mfussenegger/nvim-dap',
--     config = function()
--         vim.cmd[[
--             nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
--             nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
--             nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
--             nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
--             nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
--             nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
--             nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
--             nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
--             nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
--         ]]
--     end
-- }
-- use 'mfussenegger/nvim-dap-python'
-- use 'rcarriga/nvim-dap-ui'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Doc Generater  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use {
--     "danymat/neogen",
--     after = 'nvim-treesitter',
--     cmd = 'Neogen',
--     config = function()
--         require('neogen').setup {}
--     end
-- }
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ File Explorer  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    module = false,
    config = function()
        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        require('neo-tree').setup({
            default_component_configs = {
                git_status = {
                    symbols = {
                        -- Change type
                        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        deleted   = "",-- this can only be used in the git_status source
                        renamed   = "",-- this can only be used in the git_status source
                        -- Status type
                        untracked = "",
                        ignored   = "",
                        unstaged  = "",
                        staged    = "",
                        conflict  = "",
                    }
                },
                icon = {
                    folder_closed = '',
                    folder_open = '',
                    folder_empty = '',
                    default = ''
                },
                indent = {
                    last_indent_marker = '╰'
                }
            },
            diagnostics = {
              autopreview = true, -- Whether to automatically enable preview mode
              autopreview_config = {}, -- Config table to pass to autopreview (for example `{ use_float = true }`)
              autopreview_event = "neo_tree_buffer_enter", -- The event to enable autopreview upon (for example `"neo_tree_window_after_open"`)
              bind_to_cwd = true,
              diag_sort_function = "severity", -- "severity" means diagnostic items are sorted by severity in addition to their positions.
                                               -- "position" means diagnostic items are sorted strictly by their positions.
                                               -- May also be a function.
              follow_behavior = { -- Behavior when `follow_current_file` is true
                always_focus_file = true, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
                expand_followed = true, -- Ensure the node of the followed file is expanded
                collapse_others = true, -- Ensure other nodes are collapsed
              },
            },
            filesystem = {
                follow_current_file = true,
                hijack_netrw_behavior = 'open_current'
            },
            popup_border_style = "rounded",
            sources = {
                "diagnostics",
                "filesystem"
            }
        })
    end,
    dependencies = { 'MunifTanjim/nui.nvim', 'mrbjarksen/neo-tree-diagnostics.nvim', 'nvim-lua/plenary.nvim' }
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Folding     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use {
--     'anuvyklack/pretty-fold.nvim',
--     cond = function()
--         return vim.o.foldmethod == "marker"
--     end,
--     config = function()
--         require('pretty-fold').setup {
--             fill_char = ' ',
--             process_comment_signs = 'delete'
--         }
--     end
-- }

-- use {
--     'kevinhwang91/nvim-ufo',
--     cond = function()
--         return vim.o.foldmethod ~= "marker"
--     end,
--     config = function()
--         vim.o.foldcolumn = '1' -- '0' is not bad
--         vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
--         vim.o.foldlevelstart = 99
--         vim.o.foldenable = true
--         require('ufo').setup({
--             provider_selector = function(bufnr, filetype, buftype)
--                 return {'treesitter', 'indent'}
--             end
--         })
--     end
-- }

-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Formatting   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use {
--     'sbdchd/neoformat',
--     cmd = "Neoformat"
-- }
-- use 'joechrisellis/lsp-format-modifications.nvim'
-- use 'lukas-reineke/format.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      FZF       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/gfanto/fzf-lsp.nvim
-- https://github.com/ibhagwan/fzf-lua
-- https://github.com/junegunn/fzf
-- https://github.com/junegunn/fzf.vim
-- https://github.com/ojroques/nvim-lspfuzzy
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Git       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/akinsho/git-conflict.nvim
-- https://github.com/cynix/vim-mergetool
-- use 'hotwatermorning/auto-git-diff'
-- use 'ldelossa/gh.nvim'
{
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup {
            signs = {
                add          = { hl = 'GitSignsAdd'   , text = '│', numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'    },
                change       = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
                delete       = { hl = 'GitSignsDelete', text = '', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
                topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
                changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            },
            current_line_blame_formatter_opts = {
                relative_time = true
            },
            current_line_blame_formatter = '  <author>  <committer_time>  <summary>`',
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
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, {expr=true})

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, {expr=true})
            end
        }
    end,
    event = 'CursorHold'
},

{
    'rhysd/git-messenger.vim',
    cmd = "GitMessenger"
},

{
    'sindrets/diffview.nvim',
    cmd = "DiffviewOpen"
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Icons      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'DaikyXendo/nvim-material-icon',
    config = function()
        require('nvim-material-icon').setup({
            override = {
                json = {
                    color = "#cbcb41",
                    cterm_color = "185",
                    icon = "ﬥ ",
                    name = "Json"
                },
                norg = {
                    icon = '🦄 ',
                    name = "Neorg"
                }
            }
        })
    end,
},

{
    'kyazdani42/nvim-web-devicons',
    config = function()
        require'nvim-web-devicons'.setup({
            override = require('nvim-material-icon').get_icons()
        })
    end,
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Indentation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true
        })
    end,
    event = "CursorHold"
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Libraries   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- {
--     'MunifTanjim/nui.nvim',
-- },

-- {
--     'kevinhwang91/promise-async',
-- },

-- {
--     'nvim-lua/plenary.nvim',
-- },
-- use 'nvim-lua/popup.nvim'
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      LSP       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'Decodetalkers/csharpls-extended-lsp.nvim'
-- use 'Hoffs/omnisharp-extended-lsp.nvim'
-- https://github.com/lvimuser/lsp-inlayhints.nvim
-- https://github.com/DNLHC/glance.nvim

{
    'SmiteshP/nvim-navic',
    config = function()
        require('nvim-navic').setup {
            icons = vim.g.cmp_kinds,
            highlight = true,
            separator = "  ",
            depth_limit = 0,
            depth_limit_indicator = "..",
            safe_output = true
        }
    end,
    event = 'LspAttach'
},

-- TODO:
{
    'liuchengxu/vista.vim',
    config = function()
        vim.cmd[[
        let g:vista_default_executive = 'nvim_lsp'
        let g:vista_icon_indent = ["╰─ ", "├─ "]
        let g:vista#renderer#icons = {
            \   "constant": "",
            \   "class": "",
            \   "function": "",
            \   "variable": "",
            \  }
        ]]
    end,
    cmd = 'Vista'
},

-- {
    -- 'neovim/nvim-lspconfig',
-- },

{
    'williamboman/mason.nvim',
    cmd = 'Mason',
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded"
            }
        })
    end,
},

{
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
            local navic = require('nvim-navic')
            -- Mappings.
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<F2>', "<cmd>Lspsaga rename<CR>", bufopts)
            vim.keymap.set('n', '<S-F12>', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<leader>h', "<cmd>Lspsaga hover_doc<CR>", bufopts)
            vim.keymap.set('n', '[d', "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
            vim.keymap.set('n', ']d', "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wl', function()
            --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, bufopts)
            -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

            vim.cmd[[
                aunmenu PopUp
                nnoremenu PopUp.Declaration\ \ \ \ \ \ \ \ \ \ \ \ gD <Cmd>lua vim.lsp.buf.declaration()<CR>
                nnoremenu PopUp.Definition\ \ \ \ \ \ \ \ \ \ \ \ F12 <Cmd>lua vim.lsp.buf.definition()<CR>
                nnoremenu PopUp.Hover\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \\h <Cmd>lua vim.lsp.buf.hover()<CR>
                nnoremenu PopUp.Implementation\ \ \ \ \ \ \ \ \ gi <Cmd>lua vim.lsp.buf.implementation()<CR>
                nnoremenu PopUp.LSP\ Finder  <Cmd>Lspsaga lsp_finder<CR>
                nnoremenu PopUp.References\ \ \ \ \ \ Shift\ F12 <Cmd>lua vim.lsp.buf.references()<CR>
                nnoremenu PopUp.Rename\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ F2 <Cmd>lua vim.lsp.buf.rename()<CR>
                nnoremenu PopUp.Type\ Definition\ \ \ \ \ \ \ \ gt <Cmd>lua vim.lsp.buf.type_definition()<CR>
            ]]

            navic.attach(client, bufnr)
        end

        -- LSP settings (for overriding per client)
        local handlers =  {
            ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border_shape}),
            -- ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border_shape}), -- disable in favour of Noice
        }

        -- Add additional capabilities supported by nvim-cmp
        -- -- Gets a new ClientCapabilities object describing the LSP client
        -- -- capabilities.
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities.textDocument.completion.completionItem = {
        --     documentationFormat = {
        --         "markdown",
        --         "plaintext",
        --     },
        --     snippetSupport = true,
        --     preselectSupport = true,
        --     insertReplaceSupport = true,
        --     labelDetailsSupport = true,
        --     deprecatedSupport = true,
        --     commitCharactersSupport = true,
        --     tagSupport = {
        --         valueSet = { 1 },
        --     },
        --     resolveSupport = {
        --         properties = {
        --             "documentation",
        --             "detail",
        --             "additionalTextEdits",
        --         },
        --     },
        -- }
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        mason_lspconfig.setup_handlers {
            function (server_name)
                local lspconfig = require('lspconfig')
                if server_name == "powershell_es" then
                    lspconfig.powershell_es.setup {
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services" -LogPath "./powershell_es.log" -SessionDetailsPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal'},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices" -LogPath "./powershell_es.log" -SessionDetailsPath "./powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal -EnableConsoleRepl'},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "Import-Module 'C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\PowerShellEditorServices.psd1'; Start-EditorServices -HostName 'Visual Studio Code Host' -HostProfileId 'Microsoft.VSCode' -HostVersion '2022.12.1' -AdditionalModules @('PowerShellEditorServices.VSCode') -BundledModulesPath 'c:\\Users\\aloknigam\\.vscode\\extensions\\ms-vscode.powershell-2022.12.1\\modules' -EnableConsoleRepl -LogLevel 'Normal' -LogPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\logs\\1671314645-cea5c434-0147-4205-b2be-5907f5a8b7de1671314642966\\EditorServices.log' -SessionDetailsPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\sessions\\PSES-VSCode-39524-314832.json' -FeatureFlags @() -Stdio"},
                        bundle_path = 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services',
                        capabilities = capabilities,
                        -- root_dir = function() return 'C:/Users/aloknigam/learn/powershell' end,
                        handlers = handlers,
                        on_attach = on_attach
                    }
                elseif server_name == "omnisharp" then
                    lspconfig.omnisharp.setup {
                        cmd = { "dotnet", "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp/OmniSharp.dll"},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == "omnisharp_mono" then
                    lspconfig.omnisharp_mono.setup {
                        cmd = { "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/omnisharp-mono/OmniSharp.exe"},
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        enable_ms_build_load_projects_on_demand = true,
                        organize_imports_on_format = true
                    }
                elseif server_name == "sumneko_lua" then
                    lspconfig.sumneko_lua.setup {
                        capabilities = capabilities,
                        handlers = handlers,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "bit", "vim" }
                                },
                                -- workspace = {
                                --     library = vim.api.nvim_get_runtime_file("", true)
                                -- }
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
        vim.cmd('LspStart')
    end,
    dependencies = { 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' }, -- mason should come from require
    event = 'CursorHold'
},

{
    'ray-x/lsp_signature.nvim',
    config = function()
        require "lsp_signature".setup({
            hint_enable = false,
            noice = false
        })
    end,
    event = 'LspAttach'
},

{
    "glepnir/lspsaga.nvim",
    branch = "main",
    cmd = 'Lspsaga',
    config = function()
        require('lspsaga').init_lsp_saga({
            border_style = "rounded",
            saga_winblend = 0,
            move_in_saga = { prev = '<C-p>',next = '<C-n>'},
            diagnostic_header = { " ", " ", " ", "ﴞ " },
            -- preview lines above of lsp_finder
            preview_lines_above = 0,
            -- preview lines of lsp_finder and definition preview
            max_preview_lines = 10,
            -- use emoji lightbulb in default
            code_action_icon = "💡",
            -- if true can press number to execute the codeaction in codeaction window
            code_action_num_shortcut = true,
            -- same as nvim-lightbulb but async
            code_action_lightbulb = {
                enable = true,
                enable_in_insert = false,
                cache_code_action = true,
                sign = false,
                update_time = 150,
                sign_priority = 20,
                virtual_text = true,
            },
            finder_icons = {
                def = '  ',
                ref = '諭 ',
                link = '  ',
            },
            finder_request_timeout = 1500,
            finder_action_keys = {
                open = {'o', '<CR>'},
                vsplit = 'v',
                split = 's',
                tabe = 't',
                quit = {'q', '<ESC>'},
            },
            code_action_keys = {
                quit = 'q',
                exec = '<CR>',
            },
            definition_action_keys = {
                edit = '<C-c>o',
                vsplit = '<C-c>v',
                split = '<C-c>i',
                tabe = '<C-c>t',
                quit = 'q',
            },
            rename_action_quit = '<C-c>',
            rename_in_select = true,
            -- show symbols in winbar must nightly
            -- in_custom mean use lspsaga api to get symbols
            -- and set it to your custom winbar or some winbar plugins.
            -- if in_cusomt = true you must set in_enable to false
            symbol_in_winbar = {
                in_custom = false,
                enable = false,
                separator = ' ',
                show_file = false,
                file_formatter = "",
                click_support = false,
            },
            -- show outline
            show_outline = {
                win_position = 'right',
                --set special filetype win that outline window split.like NvimTree neotree
                -- defx, db_ui
                win_with = '',
                win_width = 30,
                auto_enter = true,
                auto_preview = true,
                virt_text = '┃',
                jump_key = 'o',
                -- auto refresh when change buffer
                auto_refresh = true,
            },
            -- custom lsp kind
            -- usage { Field = 'color code'} or {Field = {your icon, your color code}}
            custom_kind = {},
            server_filetype_map = {},
        })
    end
},

{
    'j-hui/fidget.nvim',
    config = function()
        require("fidget").setup({
            text = {
                done = '陼',
                spinner = 'arc'
            }
        })
    end,
    event = "LspAttach"
},

{
    'jayp0521/mason-null-ls.nvim',
    config = function ()
        local mnls = require("mason-null-ls")
        mnls.setup({
            automatic_setup = true
        })
        mnls.setup_handlers({})
    end,
    dependencies = 'jose-elias-alvarez/null-ls.nvim',
    event = "LspAttach"
},

-- use {
--     'p00f/clangd_extensions.nvim',
--     after = 'nvim-lspconfig',
--     config = function()
--         require("clangd_extensions").setup {
--             server = {
--                 -- options to pass to nvim-lspconfig
--                 -- i.e. the arguments to require("lspconfig").clangd.setup({})
--             },
--             extensions = {
--                 -- defaults:
--                 -- Automatically set inlay hints (type hints)
--                 autoSetHints = true,
--                 -- These apply to the default ClangdSetInlayHints command
--                 inlay_hints = {
--                     -- Only show inlay hints for the current line
--                     only_current_line = false,
--                     -- Event which triggers a refersh of the inlay hints.
--                     -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
--                     -- not that this may cause  higher CPU usage.
--                     -- This option is only respected when only_current_line and
--                     -- autoSetHints both are true.
--                     only_current_line_autocmd = "CursorHold",
--                     -- whether to show parameter hints with the inlay hints or not
--                     show_parameter_hints = true,
--                     -- prefix for parameter hints
--                     parameter_hints_prefix = "<- ",
--                     -- prefix for all the other hints (type, chaining)
--                     other_hints_prefix = "=> ",
--                     -- whether to align to the length of the longest line in the file
--                     max_len_align = false,
--                     -- padding from the left if max_len_align is true
--                     max_len_align_padding = 1,
--                     -- whether to align to the extreme right or not
--                     right_align = false,
--                     -- padding from the right if right_align is true
--                     right_align_padding = 7,
--                     -- The color of the hints
--                     highlight = "Comment",
--                     -- The highlight group priority for extmark
--                     priority = 100,
--                 },
--                 ast = {
--                     -- These are unicode, should be available in any font
--                     role_icons = {
--                         type = "🄣",
--                         declaration = "🄓",
--                         expression = "🄔",
--                         statement = ";",
--                         specifier = "🄢",
--                         ["template argument"] = "🆃",
--                     },
--                     kind_icons = {
--                         Compound = "🄲",
--                         Recovery = "🅁",
--                         TranslationUnit = "🅄",
--                         PackExpansion = "🄿",
--                         TemplateTypeParm = "🅃",
--                         TemplateTemplateParm = "🅃",
--                         TemplateParamObject = "🅃",
--                     },
--                     --[[ These require codicons (https://github.com/microsoft/vscode-codicons)
--                     role_icons = {
--                         type = "",
--                         declaration = "",
--                         expression = "",
--                         specifier = "",
--                         statement = "",
--                         ["template argument"] = "",
--                     },

--                     kind_icons = {
--                         Compound = "",
--                         Recovery = "",
--                         TranslationUnit = "",
--                         PackExpansion = "",
--                         TemplateTypeParm = "",
--                         TemplateTemplateParm = "",
--                         TemplateParamObject = "",
--                     }, ]]

--                     highlights = {
--                         detail = "Comment",
--                     },
--                 },
--                 memory_usage = {
--                     border = "none",
--                 },
--                 symbol_info = {
--                     border = "none",
--                 },
--             },
--         }
--     end,
--     event = 'LspAttach'
--     -- ft = { "c", "cpp" }
-- }

-- use 'razzmatazz/csharp-language-server'

-- TODO:
{
    'ray-x/navigator.lua',
    event = 'LspAttach'
},

-- TODO:
{
    'rmagatti/goto-preview',
    config = function()
        require('goto-preview').setup()
    end,
    event = 'LspAttach'
},

-- TODO:
{
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    config = function()
        require("symbols-outline").setup()
    end
},

-- TODO:
{
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
        require("inc_rename").setup()
    end
},

-- TODO:
{
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    config = function()
        require('aerial').setup({})
    end
},

{
    'weilbith/nvim-code-action-menu',
    config = function ()
        vim.g.code_action_menu_window_border = 'rounded'
    end,
    cmd = 'CodeActionMenu'
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Markdown    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: https://github.com/DanRoscigno/nvim-markdown-grammarly
{
    'davidgranstrom/nvim-markdown-preview',
    cmd = 'MarkdownPreview'
},
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
{
    'MattesGroeger/vim-bookmarks',
    keys = { 'ba', 'bm', 'bn', 'bp', 'bs'},
    config = function()
        vim.cmd[[
            let g:bookmark_annotation_sign = ''
            let g:bookmark_display_annotation = 1
            let g:bookmark_highlight_lines = 1
            let g:bookmark_location_list = 1
            let g:bookmark_no_default_key_mappings = 1
            let g:bookmark_save_per_working_dir = 1
            let g:bookmark_sign = ''
            nmap ba <Plug>BookmarkAnnotate
            nmap bm <Plug>BookmarkToggle
            nmap bn <Plug>BookmarkNext
            nmap bp <Plug>BookmarkPrev
            nmap bs <Plug>BookmarkShowAll
        ]]
    end
},

-- https://github.com/ThePrimeagen/harpoon --> plenary
{
    'kshenoy/vim-signature',
},
-- use 'chentoast/marks.nvim'
-- use 'crusj/bookmarks.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Orgmode     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/TravonteD/org-capture-filetype
-- https://github.com/akinsho/org-bullets.nvim

{
    'nvim-neorg/neorg',
    config = function()
        -- require('nvim-treesitter')
        require('neorg').setup {
            load = {
                ["core.highlights"]              = {},
                ["core.integrations.treesitter"] = {},
                ["core.neorgcmd"]                = {},
                ["core.norg.completion"]         = { config = { engine = 'nvim-cmp' } },
                ["core.norg.concealer"]          = {},
                ["core.norg.esupports.hop"]      = {},
                ["core.norg.esupports.indent"]   = {},
                ["core.norg.qol.toc"]            = {},
                ["core.norg.qol.todo_items"]     = {},
                ["core.syntax"]                  = {}
            }
        }
        vim.cmd [[
        au InsertEnter *.norg :Neorg toggle-concealer
        au InsertLeave *.norg :Neorg toggle-concealer
        ]]
    end,
    dependencies = 'nvim-telescope/telescope.nvim',
    ft = "norg"
},

-- use 'nvim-orgmode/orgmode'
-- https://github.com/ranjithshegde/orgWiki.nvim
-- use {
--      'lukas-reineke/headlines.nvim',
--      config = function()
--          require('headlines').setup()
--      end,
--  }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Quickfix    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'folke/trouble.nvim',
    cmd = 'TroubleToggle'
},

{
    'kevinhwang91/nvim-bqf',
    config = function()
        require('bqf').setup({
            auto_resize_height = true,
            preview = {
                border_chars = {'│', '│', '─', '─', '╭', '╮', '╰', '╯', '█'}
            }
        })
    end,
    ft = 'qf'
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Rooter     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Screen Saver  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'tamton-aquib/zone.nvim',
},

{
    'tamton-aquib/duck.nvim',
},

{
    'folke/drop.nvim',
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Sessions    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
  'rmagatti/auto-session',
  config = function()
    vim.g.auto_session_suppress_dirs = { "C:\\Users\\aloknigam" }
    require("auto-session").setup({})
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Snippets    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'dcampos/nvim-snippy',
    config = function()
        require('snippy').setup({
            mappings = {
                is = {
                    ['<Tab>'] = 'expand_or_advance',
                    ['<S-Tab>'] = 'previous',
                }
            }
        })
    end,
    dependencies = 'honza/vim-snippets'
},
-- https://github.com/ellisonleao/carbon-now.nvim
-- https://github.com/hrsh7th/vim-vsnip
-- https://github.com/norcalli/snippets.nvim
-- https://github.com/notomo/cmp-neosnippet
-- https://github.com/quangnguyen30192/cmp-nvim-ultisnips
-- https://github.com/rafamadriz/friendly-snippets
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/smjonas/snippet-converter.nvim
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Status Line  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'nvim-lualine/lualine.nvim',
    config = function()
        -- local navic = require("nvim-navic")
        require('lualine').setup {
            options = {
        --         icons_enabled = true,
        --         theme = 'auto',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
        --         disabled_filetypes = {
        --             statusline = {},
        --             winbar = {},
        --         },
        --         ignore_focus = {},
        --         always_divide_middle = true,
        --         globalstatus = false,
        --         refresh = {
        --             statusline = 1000,
        --             tabline = 1000,
        --             winbar = 1000,
        --         }
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {
                    {
                        'filename',
                        file_status = true,      -- Displays file status (readonly status, modified status)
                        newfile_status = false,   -- Display new file status (new file means no write after created)
                        path = 0,                -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory

                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        -- for other components. (terrible name, any suggestions?)
                        symbols = {
                            modified = '[+]',      -- Text to show when the file is modified.
                            readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]',     -- Text to show for new created file before first writting
                        }
                    }
                },
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
        -- tabline = {
        --     lualine_a = {'filename'},
        -- },
        winbar = {
            lualine_b = {
                -- { navic.get_location, cond = navic.is_available },
                -- { function () return require('lspsaga.symbolwinbar').get_symbol_node() end}
            }
        },
        inactive_winbar = {
            lualine_a = {'filename'},
        --     lualine_b = {
        --         { navic.get_location, cond = navic.is_available }
            -- }
        },
        --     extensions = {}
        }
    end,
    -- dependencies = "melkster/modicator.nvim",
    event = 'CursorHold'
},
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: use {
--     'akinsho/bufferline.nvim',
--     config = function()
--         require("bufferline").setup {
--             options = {
--                 mode = "tabs",
--                 diagnostics = "nvim_lsp",
--                 separator_style = "thick",
--                 always_show_bufferline = false
--             }
--         }
--     end
-- }
-- use 'mengelbrecht/lightline-bufferline'
-- use {
--     'nanozuki/tabby.nvim',
--     config = function()
--         require('tabby').setup()
--     end
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Telescope   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'crispgm/telescope-heading.nvim',
    config = function()
        require('telescope').load_extension('heading')
    end,
    ft = 'markdown'
},

{
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    config = function()
        require('telescope').setup({
            defaults = {
                dynamic_preview_title = true,
                entry_prefix = "   ",
                file_ignore_patterns = {},
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                initial_mode = "insert",
                multi_icon = " ",
                prompt_prefix = "  ",
                selection_caret = " ",
                timeout = 2000,
            },
            extensions = {
                heading = {
                    treesitter = true
                }
            },
        })
    end,
    dependencies = 'nvim-lua/plenary.nvim'
},

{
    'princejoogie/dir-telescope.nvim',
    cmd = { "FileInDirectory", "GrepInDirectory" },
    config = function()
        require("dir-telescope").setup({
            hidden = true,
            respect_gitignore = true,
        })
    end,
    dependencies = 'nvim-telescope/telescope.nvim',
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Terminal    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    "akinsho/toggleterm.nvim",
    cmd = 'ToggleTerm',
    config = function()
        require("toggleterm").setup()
    end,
    -- tag = '*'
},
-- https://github.com/elijahdanko/ttymux.nvim
-- https://github.com/jlesquembre/nterm.nvim
-- https://github.com/kassio/neoterm
-- https://github.com/nat-418/termitary.nvim
-- https://github.com/nikvdp/neomux
-- https://github.com/numToStr/FTerm.nvim
-- https://github.com/oberblastmeister/termwrapper.nvim
-- https://github.com/pianocomposer321/consolation.nvim
-- https://github.com/s1n7ax/nvim-terminal
-- https://github.com/voldikss/vim-floaterm
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Tests      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/andythigpen/nvim-coverage
-- https://github.com/klen/nvim-test
-- https://github.com/nvim-neotest/neotest
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Treesitter   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/Wansmer/treesj
{
    'nvim-treesitter/nvim-treesitter',
    config = function()
        local ignore_install = { "help", "norg", "norg_meta", "yaml" }
        require('nvim-treesitter.configs').setup {
            auto_install = true,
            highlight = {
                additional_vim_regex_highlighting = false,
                disable = ignore_install,
                enable = true
            },
            ignore_install = ignore_install,
            -- markid = {
            --     enable = true,
            --     queries = { default = '(identifier) @markid' }
            -- },
            rainbow = {
                enable = true,
                -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
                -- colors = {}, -- table of hex strings
                -- termcolors = {} -- table of colour name strings
            }
        }
    end,
    dependencies = 'p00f/nvim-ts-rainbow',
    event = 'User VeryLazy',
    -- event = 'User LazyLoad0',
},

-- TODO: use {
--     'm-demare/hlargs.nvim',
--     after = 'nvim-treesitter',
--     config = function()
--         require('hlargs').setup()
--     end
-- }

{
    'nvim-treesitter/nvim-treesitter-context',
    cmd = 'TSContextToggle',
    config = function()
        require('treesitter-context').setup {
            separator = '━',
            patterns = {
                lua = {
                    'field'
                }
            }
        }
    end
},

{
    'nvim-treesitter/playground',
    cmd = 'TSHighlightCapturesUnderCursor'
},

-- {
--     'p00f/nvim-ts-rainbow',
--     after = 'nvim-treesitter'
-- },
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      TUI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use({
--   'folke/noice.nvim',
--   config = function()
--     require("noice").setup()
--   end,
--   requires = {
--     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
--     "MunifTanjim/nui.nvim",
--     -- OPTIONAL:
--     --   `nvim-notify` is only needed, if you want to use the notification view.
--     --   If not available, we use `mini` as the fallback
--     "rcarriga/nvim-notify",
--     }
-- })

{
    'rcarriga/nvim-notify',
    config = function()
        local notify = require('notify')
        notify.setup({
            background_colour = vim.api.nvim_get_hl_by_name('Normal', true).background and 'Normal' or '#000000',
            minimum_width = 0,
            render = 'minimal',
            stages = 'slide'
        })
        vim.notify = notify
    end,
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Utilities   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'AckslD/nvim-trevJ.lua'

{
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
},

-- https://github.com/ElPiloto/significant.nvim

{
    'andrewferrier/debugprint.nvim',
    config = function()
        local debugprint = require('debugprint')
        debugprint.setup({
            create_keymaps = false,
            create_commands = false
        })
        vim.keymap.set("n", "<Leader>dd", function()
            debugprint.deleteprints()
        end)
        vim.keymap.set("n", "<Leader>dp", function()
            debugprint.debugprint()
        end)
        vim.keymap.set("n", "<Leader>dP", function()
            debugprint.debugprint({ above = true })
        end)
        vim.keymap.set("n", "<Leader>dv", function()
            debugprint.debugprint({ variable = true })
        end)
        vim.keymap.set("n", "<Leader>dV", function()
            debugprint.debugprint({ above = true, variable = true })
        end)
        vim.keymap.set("v", "<Leader>dv", function()
            debugprint.debugprint({ variable = true })
        end)
        vim.keymap.set("v", "<Leader>dV", function()
            debugprint.debugprint({ above = true, variable = true })
        end)
    end,
    keys = { "<Leader>dp", "<Leader>dP", "<Leader>dv", "<Leader>dV", }
},

-- use 'cbochs/portal.nvim'

-- use 'chipsenkbeil/distant.nvim'

{
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
},

-- https://github.com/folke/neoconf.nvim

-- use 'jbyuki/instant.nvim'

{ 'kwkarlwang/bufjump.nvim' },

{ 'kylechui/nvim-surround' },

{ 'lewis6991/impatient.nvim' },

-- use 'mg979/vim-visual-multi'

-- https://github.com/nat-418/scamp.nvim

{
    'nacro90/numb.nvim',
    cond = function()
        return vim.api.nvim_get_mode().mode == 'c'
    end,
    config = function()
        require('numb').setup()
    end,
    event = "CmdlineEnter",
},

{
    -- Lua copy https://github.com/ojroques/nvim-osc52
    'ojroques/vim-oscyank',
    enabled = function()
        -- Check if connection is ssh
        return os.getenv("SSH_CLIENT") ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif]]
    end
},

{
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
},

{
    'tversteeg/registers.nvim',
    config = function()
        require("registers").setup({
            show = '*+"',
            show_empty = false,
            register_user_command = false,
            symbols = {
                tab = '»'
            },
            window = {
                border = 'rounded'
            }
        })
    end,
    keys = { "\"" , "\"" , "<C-R>" }
},
-- <~>
}

require("lazy").setup(Plugins, LazyConfig)
-- vim: fmr=</>,<~>
