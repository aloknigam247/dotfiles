--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
local border_shape = {
    { '╭', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╮', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '╯', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '╰', 'FloatBorder' },
    { '│', 'FloatBorder' },
}

vim.cmd[[autocmd User PackerCompileDone lua vim.notify("PackerCompile Done", vim.log.levels.INFO)]]

require('packer').startup({
config = {
    auto_clean = true,
    auto_reload_compiled = false,
    -- PERF: [ABSTRACT IDE] Move to lua dir so impatient.nvim can cache it
    -- compile_path = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua',
    display = {
        open_fn = function()
            local result, win, buf = require('packer.util').float {
                border = border_shape
            }
            vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')
            return result, win, buf
        end
    },
    ensure_dependencies = true,
    git = {
        clone_timeout = 600, -- Timeout, in seconds, for git clones
    },
    log = {
        -- level = 'debug'
    },
    -- profile = {
    --     enable = true,
    --     threshold = 0.0001
    -- },
    -- autoremove = true
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Packer     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
function(use)
use 'wbthomason/packer.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Aligns     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'dhruvasagar/vim-table-mode',
    cmd = 'TableModeEnable'
}

-- use 'echasnovski/mini.align'

use {
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Auto Pairs   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
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
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Coloring    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use {
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
-- }

use {
    'RRethy/vim-illuminate',
    after = 'nvim-treesitter',
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
    event = 'CursorHold'
}

-- use 'azabiong/vim-highlighter'

use {
    'folke/lsp-colors.nvim',
    event = "LspAttach"
}

-- https://github.com/folke/paint.nvim

use {
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
    end,
    event = "CursorHold"
}

use {
    'kevinhwang91/nvim-hlslens',
    config = function()
        require('hlslens').setup()
    end,
    keys = {
        { "n", "n" },
        { "n", "N" },
        { "n", "*" },
        { "n", "#" },
        { "n", "g*" },
        { "n", "g#" },
    }
}

use {
    'melkster/modicator.nvim',
    after = 'lualine.nvim',
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
    lock = true
}

use {
    'norcalli/nvim-colorizer.lua',
    cmd = "ColorizerToggle",
    config = function()
        require('colorizer').setup()
    end
}

use {
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
}

use {
    -- https://github.com/xiyaowong/nvim-transparent
    'tribela/vim-transparent',
    cmd = 'TransparentToggle'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Colorscheme   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>

-- https://github.com/lifepillar/vim-colortemplate
-- https://github.com/folke/styler.nvim
use 'tjdevries/colorbuddy.vim' -- onebuddy gruvbuddy

use { 'Domeee/mosel.nvim'            }
use { 'EdenEast/nightfox.nvim'       }
use { 'LunarVim/darkplus.nvim'       }
use { 'Mofiqul/adwaita.nvim'         }
use { 'NLKNguyen/papercolor-theme'   }
use { 'Shatur/neovim-ayu'            }
use { 'Th3Whit3Wolf/one-nvim'        }
use { 'Th3Whit3Wolf/onebuddy'        }
use { 'Yazeed1s/oh-lucy.nvim'        }
use { 'aca/vim-monokai-pro'          }
use { 'atelierbram/Base2Tone-nvim'   }
use { 'catppuccin/nvim'              }
use { 'cpea2506/one_monokai.nvim'    }
use { 'fenetikm/falcon'              }
use { 'folke/tokyonight.nvim'        }
use { 'gbprod/nord.nvim'             }
use { 'glepnir/zephyr-nvim'          }
use { 'jsit/toast.vim'               }
use { 'kaiuri/nvim-juliana'          }
use { 'kvrohit/mellow.nvim'          }
use { 'lmburns/kimbox'               }
use { 'luisiacc/gruvbox-baby'        }
use { 'marko-cerovac/material.nvim'  }
use { 'maxmx03/FluoroMachine.nvim'   }
use { 'metalelf0/jellybeans-nvim'    }
use { 'mhartington/oceanic-next'     }
use { 'ntk148v/vim-horizon'          }
use { 'nxvu699134/vn-night.nvim'     }
use { 'olimorris/onedarkpro.nvim'    }
use { 'projekt0n/github-nvim-theme'  }
use { 'rafamadriz/neon'              }
use { 'ray-x/aurora'                 }
use { 'ray-x/starry.nvim'            }
use { 'rebelot/kanagawa.nvim'        }
use { 'rmehri01/onenord.nvim'        }
use { 'rose-pine/neovim'             }
use { 'sainnhe/edge'                 }
use { 'sainnhe/everforest'           }
use { 'sainnhe/sonokai'              }
use { 'sam4llis/nvim-tundra'         }
use { 'savq/melange'                 }
use { 'shaunsingh/moonlight.nvim'    }
use { 'sickill/vim-monokai'          }
use { 'tanvirtin/monokai.nvim'       }
use { 'theniceboy/nvim-deus'         }
use { 'tiagovla/tokyodark.nvim'      }
use { 'titanzero/zephyrium'          }
use { 'tjdevries/gruvbuddy.nvim'     }
use { 'tomasiser/vim-code-dark'      }
use { 'w3barsi/barstrata.nvim'       }
use { 'wuelnerdotexe/vim-enfocado'   }
use { 'yashguptaz/calvera-dark.nvim' }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'b3nj5m1n/kommentary',
    config = function()
        require('kommentary.config').configure_language("default", {
            prefer_single_line_comments = true,
        })
        vim.api.nvim_set_keymap("n", "<C-t>", "<Plug>kommentary_line_default", {})
        vim.api.nvim_set_keymap("v", "<C-t>", "<Plug>kommentary_visual_default", {})
    end,
    keys = { "<C-t>" },
    setup = function()
        vim.g.kommentary_create_default_mappings = false
    end
}
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Completion   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
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
                { name = 'path' },
                { name = 'snippy' }
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

    end,
    event = "CmdlineEnter",
    module = "cmp"
}

use {
    'dcampos/cmp-snippy',
    after = 'nvim-cmp'
}

use {
    'hrsh7th/cmp-buffer',
    after = 'nvim-cmp'
}

use {'hrsh7th/cmp-cmdline',
    after = 'nvim-cmp'
}

use {
    'hrsh7th/cmp-nvim-lsp', -- use 'kwkarlwang/cmp-nvim-insert-text-lsp'
    after = 'nvim-cmp'
}

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
-- https://github.com/jbyuki/one-small-step-for-vimkind
-- https://github.com/nvim-telescope/telescope-vimspector.nvim
-- https://github.com/puremourning/vimspector
-- https://github.com/sakhnik/nvim-gdb
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/tpope/vim-scriptease
-- https://github.com/vim-scripts/Conque-GDB
-- use 'Pocco81/dap-buddy.nvim'
-- use 'mfussenegger/nvim-dap'
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
use {
    'mrbjarksen/neo-tree-diagnostics.nvim',
    after = 'neo-tree.nvim',
    module = 'neo-tree.sources.diagnostics' -- if wanting to lazyload
}

use {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
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
    end
}
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
-- use 'hotwatermorning/auto-git-diff'
-- use 'ldelossa/gh.nvim'
use {
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
            current_line_blame_formatter = '  <author>  <committer_time>  <summary>`'
        }

        -- Navigation
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

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
    event = 'CursorHold'
}

use {
    'rhysd/git-messenger.vim',
    cmd = "GitMessenger"
}

use {
    'sindrets/diffview.nvim',
    cmd = "DiffviewOpen"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Icons      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
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
    event = 'CursorHold'
}

use {
    'kyazdani42/nvim-web-devicons',
    after = "nvim-material-icon",
    config = function()
        require'nvim-web-devicons'.setup({
            override = require('nvim-material-icon').get_icons()
        })
    end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Indentation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true
        })
    end,
    event = "CursorHold"
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Libraries   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'MunifTanjim/nui.nvim',
    module = 'nui'
}

use {
    'kevinhwang91/promise-async',
    module = 'promise-async'
}

use {
    'nvim-lua/plenary.nvim',
    module = 'plenary'
}
-- use 'nvim-lua/popup.nvim'
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Lint      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'mfussenegger/nvim-lint'
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      LSP       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- use 'Decodetalkers/csharpls-extended-lsp.nvim'
-- use 'Hoffs/omnisharp-extended-lsp.nvim'
-- https://github.com/lvimuser/lsp-inlayhints.nvim
-- https://github.com/DNLHC/glance.nvim

use {
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
}

-- TODO:
use {
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
}

use {
    'neovim/nvim-lspconfig',
    event = 'CursorHold',
    cond = function() return true end,
}

use {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded"
            }
        })
    end,
    module = 'mason'
}

use {
    'williamboman/mason-lspconfig.nvim',
    after = 'nvim-lspconfig',
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
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            -- vim.keymap.set('n', '<space>wl', function()
            --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
            -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
            vim.cmd[[
            aunmenu PopUp
            nnoremenu PopUp.Declaration\ (gD) <Cmd>lua vim.lsp.buf.declaration()<CR>
            nnoremenu PopUp.Definition\ (gd) <Cmd>lua vim.lsp.buf.definition()<CR>
            nnoremenu PopUp.Implementation\ (gi) <Cmd>lua vim.lsp.buf.implementation()<CR>
            nnoremenu PopUp.References\ (gr) <Cmd>lua vim.lsp.buf.references()<CR>
            nnoremenu PopUp.Hover\ (\\h) <Cmd>lua vim.lsp.buf.hover()<CR>
            nnoremenu PopUp.Rename\ (\\rn) <Cmd>lua vim.lsp.buf.rename()<CR>
            nnoremenu PopUp.Type\ Definition\ (gt) <Cmd>lua vim.lsp.buf.type_definition()<CR>
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
                        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        capabilities = capabilities,
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
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true)
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
        vim.cmd('LspStart')
    end
}

use {
    'ray-x/lsp_signature.nvim',
    config = function()
        require "lsp_signature".setup({
            hint_enable = false,
            noice = false
        })
    end,
    event = 'LspAttach'
}

-- TODO:
use {
    -- BUG: references windows is very slow
    'RishabhRD/nvim-lsputils',
    config = function()
        -- vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
        -- vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler -- using nvim-bqf
        -- vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
        -- vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
        -- vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
        -- vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
        -- vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
        -- vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
    end,
    event = 'LspAttach'
}
use {
    'RishabhRD/popfix',
    event = 'LspAttach'
}

-- TODO:
use({
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = function()
        require('lspsaga').init_lsp_saga({
            -- "single" | "double" | "rounded" | "bold" | "plus"
            border_style = "rounded",
            diagnostic_header = { " ", " ", " ", "ﴞ " },
            -- finder icons
            finder_icons = {
                def = '  ',
                ref = '諭 ',
                link = '  ',
            },
            finder_action_keys = {
                open = {'o', '<CR>'},
                vsplit = 's',
                split = 'i',
                tabe = 't',
                quit = {'q', '<ESC>'},
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
                show_file = true,
                -- define how to customize filename, eg: %:., %
                -- if not set, use default value `%:t`
                -- more information see `vim.fn.expand` or `expand`
                -- ## only valid after set `show_file = true`
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
            custom_kind = {}
        })
    end,
    event = 'LspAttach'
})

use {
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
}

-- TODO:
use {
    'jayp0521/mason-null-ls.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'jose-elias-alvarez/null-ls.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'ldelossa/litee-bookmarks.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'ldelossa/litee-calltree.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'ldelossa/litee-filetree.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'ldelossa/litee-symboltree.nvim',
    event = "LspAttach"
}

-- TODO:
use {
    'ldelossa/litee.nvim',
    event = "LspAttach"
}

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
--     ft = { "c", "cpp" }
-- }

-- use 'razzmatazz/csharp-language-server'

-- TODO:
use {
    'ray-x/navigator.lua',
    event = 'LspAttach'
}

-- TODO:
use {
    'rmagatti/goto-preview',
    config = function()
        require('goto-preview').setup()
    end,
    event = 'LspAttach'
}

-- TODO:
use {
    'simrat39/symbols-outline.nvim',
    config = function()
        require("symbols-outline").setup()
    end,
    event = 'LspAttach'
}

-- TODO:
use {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
        require("inc_rename").setup()
    end,
    event = 'LspAttach'
}

-- TODO:
use {
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    config = function()
        require('aerial').setup({})
    end
}

-- TODO:
use {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Markdown    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: https://github.com/DanRoscigno/nvim-markdown-grammarly
use {
    'davidgranstrom/nvim-markdown-preview',
    cmd = 'MarkdownPreview'
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
use {
    'MattesGroeger/vim-bookmarks',
    keys = { "bm", "ba" },
    setup = function()
        vim.cmd[[
        let g:bookmark_no_default_key_mappings = 1
        nmap bm <Plug>BookmarkToggle
        nmap ba <Plug>BookmarkShowAll
        ]]
    end
}

-- https://github.com/ThePrimeagen/harpoon --> plenary
use {
    'kshenoy/vim-signature',
    cmd = 'marks'
}
-- use 'chentoast/marks.nvim'
-- use 'crusj/bookmarks.nvim'
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Orgmode     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- https://github.com/TravonteD/org-capture-filetype
-- https://github.com/akinsho/org-bullets.nvim

use {
    'nvim-neorg/neorg',
    after = "nvim-treesitter",
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
    ft = "norg"
}

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
use {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle'
}

-- TODO: use {
--     'kevinhwang91/nvim-bqf',
--     after = "nvim-lspconfig",
--     config = function()
--         require('bqf').setup({
--             auto_resize_height = true,
--             preview = {
--                 border_chars = {'│', '│', '─', '─', '╭', '╮', '╰', '╯', '█'}
--             }
--         })
--     end,
--     event = 'QuickFixCmdPre'
--     -- ft = 'qf'
-- }
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      Rooter    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Sessions   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
  'rmagatti/auto-session',
  config = function()
    vim.g.auto_session_suppress_dirs = { "C:\\Users\\aloknigam" }
    require("auto-session").setup({})
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     Snippets   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    'dcampos/nvim-snippy',
    after = 'nvim-cmp',
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
    opt = true,
    requires = { -- BUG: fix this
        'honza/vim-snippets'
    }
}
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
use {
    'nvim-lualine/lualine.nvim',
    config = function()
        local navic = require("nvim-navic")
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
                { navic.get_location, cond = navic.is_available }
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
    event = 'CursorHold'
}
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
use {
    'crispgm/telescope-heading.nvim',
    after = 'telescope.nvim',
    config = function()
        require('telescope').load_extension('heading')
    end,
    ft = 'markdown'
}

use {
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
    end
}

use {
    'princejoogie/dir-telescope.nvim',
    after = "telescope.nvim",
    cmd = { "FileInDirectory", "GrepInDirectory" },
    config = function()
        require("dir-telescope").setup({
            hidden = true,
            respect_gitignore = true,
        })
    end
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Terminal    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
use {
    "akinsho/toggleterm.nvim",
    cmd = 'ToggleTerm',
    config = function()
        require("toggleterm").setup()
    end,
    tag = '*'
}
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
-- TODO: https://github.com/Wansmer/treesj
use {
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
    event = 'CursorHold',
    module = 'nvim-treesitter'
}

-- TODO: use {
--     'm-demare/hlargs.nvim',
--     after = 'nvim-treesitter',
--     config = function()
--         require('hlargs').setup()
--     end
-- }

use {
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
}

use {
    'nvim-treesitter/playground',
    cmd = 'TSHighlightCapturesUnderCursor'
}

use {
    'p00f/nvim-ts-rainbow',
    after = 'nvim-treesitter'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━       TUI      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: https://github.com/tamton-aquib/zone.nvim
-- TODO: https://github.com/tamton-aquib/duck.nvim
-- TODO: https://github.com/Eandrju/cellular-automaton.nvim
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

use {
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
    module = 'notify'
}
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Utilities   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: use 'AckslD/nvim-trevJ.lua'

use {
    'AndrewRadev/inline_edit.vim',
    cmd = 'InlineEdit'
}

-- https://github.com/ElPiloto/significant.nvim -- NOTE: awesome plugin but not usage now

use {
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
}

use 'cbochs/portal.nvim'

-- use 'chipsenkbeil/distant.nvim'

use {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
}

-- https://github.com/folke/neoconf.nvim

-- use 'jbyuki/instant.nvim' -- NOTE: good but no use case now

use 'kwkarlwang/bufjump.nvim'

use 'kylechui/nvim-surround'

use 'lewis6991/impatient.nvim'

-- use 'mg979/vim-visual-multi'

-- TODO: https://github.com/nat-418/scamp.nvim

use {
    'nacro90/numb.nvim',
    cond = function()
        return vim.api.nvim_get_mode().mode == 'c'
    end,
    config = function()
        require('numb').setup()
    end,
    event = "CmdlineEnter",
}

use {
    -- Lua copy https://github.com/ojroques/nvim-osc52
    'ojroques/vim-oscyank',
    cond = function()
        -- Check if connection is ssh
        return os.getenv("SSH_CLIENT") ~= nil
    end,
    config = function()
        vim.cmd[[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif]]
    end
}

use {
    'rickhowe/spotdiff.vim',
    cmd = 'Diffthis'
}

use {
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
    keys = {
        { "n", "\"" },
        { "v", "\"" },
        { "i", "<C-R>"}
    }
}
end
})
-- <~>
-- vim: fmr=</>,<~>
