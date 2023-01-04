﻿--[[
  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
 ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
 ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
 ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
]]
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Configurations ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
-- TODO: format on paste
-- vim.notify = function(msg, level, opt)
--     require('notify') -- lazy loads nvim-notify and set vim.notify = notify
--     vim.notify(msg, level, opt)
-- end

-- Blink on yank
-- au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true}
vim.api.nvim_create_autocmd(
	"TextYankPost",
	{
		desc = "highlight text on yank",
		pattern = "*",
		-- group = group,
		callback = function()
			vim.highlight.on_yank {
				higroup="Search", timeout=300, on_visual=true
			}
		end,
	}
)

function ColoRand()
    local colos = {
        { 'NeoSolarized',                         'dark',  '_' },
        { 'NeoSolarized',                         'light', '_' },
        { 'OceanicNext',                          'dark',  '_' },
        { 'PaperColor',                           'dark',  '_' },
        { 'PaperColor',                           'light', '_' },
        { 'adwaita',                              'dark',  '_' },
        { 'adwaita',                              'light', '_' },
        { 'aurora',                               'dark',  '_' },
        { 'ayu-dark',                             'dark',  'ayu' },
        { 'ayu-light',                            'light', 'ayu' },
        { 'ayu-mirage',                           'dark',  'ayu' },
        { 'barstrata',                            'dark',  '_' },
        { 'base16-3024',                          'dark',  'base16' },
        { 'base16-apathy',                        'dark',  'base16' },
        { 'base16-apprentice',                    'dark',  'base16' },
        { 'base16-ashes',                         'dark',  'base16' },
        { 'base16-atelier-cave',                  'dark',  'base16' },
        { 'base16-atelier-cave-light',            'light', 'base16' },
        { 'base16-atelier-dune',                  'dark',  'base16' },
        { 'base16-atelier-dune-light',            'light', 'base16' },
        { 'base16-atelier-estuary',               'dark',  'base16' },
        { 'base16-atelier-estuary-light',         'light', 'base16' },
        { 'base16-atelier-forest',                'dark',  'base16' },
        { 'base16-atelier-forest-light',          'light', 'base16' },
        { 'base16-atelier-heath',                 'dark',  'base16' },
        { 'base16-atelier-heath-light',           'light', 'base16' },
        { 'base16-atelier-lakeside',              'dark',  'base16' },
        { 'base16-atelier-lakeside-light',        'light', 'base16' },
        { 'base16-atelier-plateau',               'dark',  'base16' },
        { 'base16-atelier-plateau-light',         'light', 'base16' },
        { 'base16-atelier-savanna',               'dark',  'base16' },
        { 'base16-atelier-savanna-light',         'light', 'base16' },
        { 'base16-atelier-seaside',               'dark',  'base16' },
        { 'base16-atelier-seaside-light',         'light', 'base16' },
        { 'base16-atelier-sulphurpool',           'dark',  'base16' },
        { 'base16-atelier-sulphurpool-light',     'light', 'base16' },
        { 'base16-atlas',                         'dark',  'base16' },
        { 'base16-ayu-dark',                      'dark',  'base16' },
        { 'base16-ayu-light',                     'light', 'base16' },
        { 'base16-ayu-mirage',                    'dark',  'base16' },
        { 'base16-bespin',                        'dark',  'base16' },
        { 'base16-black-metal',                   'dark',  'base16' },
        { 'base16-black-metal-bathory',           'dark',  'base16' },
        { 'base16-black-metal-burzum',            'dark',  'base16' },
        { 'base16-black-metal-dark-funeral',      'dark',  'base16' },
        { 'base16-black-metal-gorgoroth',         'dark',  'base16' },
        { 'base16-black-metal-immortal',          'dark',  'base16' },
        { 'base16-black-metal-khold',             'dark',  'base16' },
        { 'base16-black-metal-marduk',            'dark',  'base16' },
        { 'base16-black-metal-mayhem',            'dark',  'base16' },
        { 'base16-black-metal-nile',              'dark',  'base16' },
        { 'base16-black-metal-venom',             'dark',  'base16' },
        { 'base16-blueforest',                    'dark',  'base16' },
        { 'base16-blueish',                       'dark',  'base16' },
        { 'base16-brewer',                        'dark',  'base16' },
        { 'base16-bright',                        'dark',  'base16' },
        { 'base16-brogrammer',                    'dark',  'base16' },
        { 'base16-brushtrees',                    'dark',  'base16' },
        { 'base16-brushtrees-dark',               'dark',  'base16' },
        { 'base16-catppuccin',                    'dark',  'base16' },
        { 'base16-chalk',                         'dark',  'base16' },
        { 'base16-circus',                        'dark',  'base16' },
        { 'base16-classic-dark',                  'dark',  'base16' },
        { 'base16-classic-light',                 'light', 'base16' },
        { 'base16-codeschool',                    'dark',  'base16' },
        { 'base16-colors',                        'dark',  'base16' },
        { 'base16-cupcake',                       'dark',  'base16' },
        { 'base16-cupertino',                     'light', 'base16' },
        { 'base16-da-one-black',                  'dark',  'base16' },
        { 'base16-da-one-gray',                   'dark',  'base16' },
        { 'base16-da-one-ocean',                  'dark',  'base16' },
        { 'base16-da-one-paper',                  'light', 'base16' },
        { 'base16-da-one-sea',                    'dark',  'base16' },
        { 'base16-da-one-white',                  'light', 'base16' },
        { 'base16-danqing',                       'dark',  'base16' },
        { 'base16-darcula',                       'dark',  'base16' },
        { 'base16-darkmoss',                      'dark',  'base16' },
        { 'base16-darktooth',                     'dark',  'base16' },
        { 'base16-darkviolet',                    'dark',  'base16' },
        { 'base16-decaf',                         'dark',  'base16' },
        { 'base16-default-dark',                  'dark',  'base16' },
        { 'base16-default-light',                 'light', 'base16' },
        { 'base16-dirtysea',                      'dark',  'base16' },
        { 'base16-dracula',                       'dark',  'base16' },
        { 'base16-edge-dark',                     'dark',  'base16' },
        { 'base16-edge-light',                    'light', 'base16' },
        { 'base16-eighties',                      'dark',  'base16' },
        { 'base16-embers',                        'dark',  'base16' },
        { 'base16-emil',                          'light', 'base16' },
        { 'base16-equilibrium-dark',              'dark',  'base16' },
        { 'base16-equilibrium-gray-dark',         'dark',  'base16' },
        { 'base16-equilibrium-gray-light',        'light', 'base16' },
        { 'base16-equilibrium-light',             'light', 'base16' },
        { 'base16-espresso',                      'dark',  'base16' },
        { 'base16-eva',                           'dark',  'base16' },
        { 'base16-eva-dim',                       'dark',  'base16' },
        { 'base16-everforest',                    'dark',  'base16' },
        { 'base16-flat',                          'dark',  'base16' },
        { 'base16-framer',                        'dark',  'base16' },
        { 'base16-fruit-soda',                    'light', 'base16' },
        { 'base16-gigavolt',                      'dark',  'base16' },
        { 'base16-github',                        'light', 'base16' },
        { 'base16-google-dark',                   'dark',  'base16' },
        { 'base16-google-light',                  'light', 'base16' },
        { 'base16-gotham',                        'dark',  'base16' },
        { 'base16-grayscale-dark',                'dark',  'base16' },
        { 'base16-grayscale-light',               'light', 'base16' },
        { 'base16-greenscreen',                   'dark',  'base16' },
        { 'base16-gruber',                        'dark',  'base16' },
        { 'base16-gruvbox-dark-hard',             'dark',  'base16' },
        { 'base16-gruvbox-dark-medium',           'dark',  'base16' },
        { 'base16-gruvbox-dark-pale',             'dark',  'base16' },
        { 'base16-gruvbox-dark-soft',             'dark',  'base16' },
        { 'base16-gruvbox-light-hard',            'light', 'base16' },
        { 'base16-gruvbox-light-medium',          'light', 'base16' },
        { 'base16-gruvbox-light-soft',            'light', 'base16' },
        { 'base16-gruvbox-material-dark-hard',    'dark',  'base16' },
        { 'base16-gruvbox-material-dark-medium',  'dark',  'base16' },
        { 'base16-gruvbox-material-dark-soft',    'dark',  'base16' },
        { 'base16-gruvbox-material-light-hard',   'light', 'base16' },
        { 'base16-gruvbox-material-light-medium', 'light', 'base16' },
        { 'base16-gruvbox-material-light-soft',   'light', 'base16' },
        { 'base16-hardcore',                      'dark',  'base16' },
        { 'base16-harmonic-dark',                 'dark',  'base16' },
        { 'base16-harmonic-light',                'light', 'base16' },
        { 'base16-heetch',                        'dark',  'base16' },
        { 'base16-heetch-light',                  'light', 'base16' },
        { 'base16-helios',                        'dark',  'base16' },
        { 'base16-hopscotch',                     'dark',  'base16' },
        { 'base16-horizon-dark',                  'dark',  'base16' },
        { 'base16-horizon-light',                 'light', 'base16' },
        { 'base16-horizon-terminal-dark',         'dark',  'base16' },
        { 'base16-horizon-terminal-light',        'light', 'base16' },
        { 'base16-humanoid-dark',                 'dark',  'base16' },
        { 'base16-humanoid-light',                'light', 'base16' },
        { 'base16-ia-dark',                       'dark',  'base16' },
        { 'base16-ia-light',                      'light', 'base16' },
        { 'base16-icy',                           'dark',  'base16' },
        { 'base16-irblack',                       'dark',  'base16' },
        { 'base16-kanagawa',                      'dark',  'base16' },
        { 'base16-katy',                          'dark',  'base16' },
        { 'base16-kimber',                        'dark',  'base16' },
        { 'base16-lime',                          'dark',  'base16' },
        { 'base16-macintosh',                     'dark',  'base16' },
        { 'base16-marrakesh',                     'dark',  'base16' },
        { 'base16-materia',                       'dark',  'base16' },
        { 'base16-material',                      'dark',  'base16' },
        { 'base16-material-darker',               'dark',  'base16' },
        { 'base16-material-lighter',              'light', 'base16' },
        { 'base16-material-palenight',            'dark',  'base16' },
        { 'base16-material-vivid',                'dark',  'base16' },
        { 'base16-mellow-purple',                 'dark',  'base16' },
        { 'base16-mexico-light',                  'light', 'base16' },
        { 'base16-mocha',                         'dark',  'base16' },
        { 'base16-monokai',                       'dark',  'base16' },
        { 'base16-nebula',                        'dark',  'base16' },
        { 'base16-nord',                          'dark',  'base16' },
        { 'base16-nova',                          'dark',  'base16' },
        { 'base16-ocean',                         'dark',  'base16' },
        { 'base16-oceanicnext',                   'dark',  'base16' },
        { 'base16-one-light',                     'light', 'base16' },
        { 'base16-onedark',                       'dark',  'base16' },
        { 'base16-outrun-dark',                   'dark',  'base16' },
        { 'base16-pandora',                       'dark',  'base16' },
        { 'base16-papercolor-dark',               'dark',  'base16' },
        { 'base16-papercolor-light',              'light', 'base16' },
        { 'base16-paraiso',                       'dark',  'base16' },
        { 'base16-pasque',                        'dark',  'base16' },
        { 'base16-phd',                           'dark',  'base16' },
        { 'base16-pico',                          'dark',  'base16' },
        { 'base16-pinky',                         'dark',  'base16' },
        { 'base16-pop',                           'dark',  'base16' },
        { 'base16-porple',                        'dark',  'base16' },
        { 'base16-primer-dark',                   'dark',  'base16' },
        { 'base16-primer-dark-dimmed',            'dark',  'base16' },
        { 'base16-primer-light',                  'light', 'base16' },
        { 'base16-purpledream',                   'dark',  'base16' },
        { 'base16-qualia',                        'dark',  'base16' },
        { 'base16-railscasts',                    'dark',  'base16' },
        { 'base16-rebecca',                       'dark',  'base16' },
        { 'base16-rose-pine',                     'dark',  'base16' },
        { 'base16-rose-pine-dawn',                'dark',  'base16' },
        { 'base16-rose-pine-moon',                'dark',  'base16' },
        { 'base16-sagelight',                     'dark',  'base16' },
        { 'base16-sakura',                        'dark',  'base16' },
        { 'base16-sandcastle',                    'dark',  'base16' },
        { 'base16-seti',                          'dark',  'base16' },
        { 'base16-shades-of-purple',              'dark',  'base16' },
        { 'base16-shadesmear-dark',               'dark',  'base16' },
        { 'base16-shadesmear-light',              'light', 'base16' },
        { 'base16-shapeshifter',                  'dark',  'base16' },
        { 'base16-silk-dark',                     'dark',  'base16' },
        { 'base16-silk-light',                    'light', 'base16' },
        { 'base16-snazzy',                        'dark',  'base16' },
        { 'base16-solarflare',                    'dark',  'base16' },
        { 'base16-solarflare-light',              'light', 'base16' },
        { 'base16-solarized-dark',                'dark',  'base16' },
        { 'base16-solarized-light',               'light', 'base16' },
        { 'base16-spaceduck',                     'dark',  'base16' },
        { 'base16-spacemacs',                     'dark',  'base16' },
        { 'base16-stella',                        'dark',  'base16' },
        { 'base16-still-alive',                   'dark',  'base16' },
        { 'base16-summercamp',                    'dark',  'base16' },
        { 'base16-summerfruit-dark',              'dark',  'base16' },
        { 'base16-summerfruit-light',             'light', 'base16' },
        { 'base16-synth-midnight-dark',           'dark',  'base16' },
        { 'base16-synth-midnight-light',          'light', 'base16' },
        { 'base16-tango',                         'dark',  'base16' },
        { 'base16-tender',                        'dark',  'base16' },
        { 'base16-tokyo-city-dark',               'dark',  'base16' },
        { 'base16-tokyo-city-light',              'light', 'base16' },
        { 'base16-tokyo-city-terminal-dark',      'dark',  'base16' },
        { 'base16-tokyo-city-terminal-light',     'light', 'base16' },
        { 'base16-tokyo-night-dark',              'dark',  'base16' },
        { 'base16-tokyo-night-light',             'light', 'base16' },
        { 'base16-tokyo-night-storm',             'dark',  'base16' },
        { 'base16-tokyo-night-terminal-dark',     'dark',  'base16' },
        { 'base16-tokyo-night-terminal-light',    'light', 'base16' },
        { 'base16-tokyo-night-terminal-storm',    'dark',  'base16' },
        { 'base16-tokyodark',                     'dark',  'base16' },
        { 'base16-tokyodark-terminal',            'dark',  'base16' },
        { 'base16-tomorrow',                      'light', 'base16' },
        { 'base16-tomorrow-night',                'dark',  'base16' },
        { 'base16-tomorrow-night-eighties',       'dark',  'base16' },
        { 'base16-tube',                          'dark',  'base16' },
        { 'base16-twilight',                      'dark',  'base16' },
        { 'base16-unikitty-dark',                 'dark',  'base16' },
        { 'base16-unikitty-light',                'light', 'base16' },
        { 'base16-unikitty-reversible',           'dark',  'base16' },
        { 'base16-uwunicorn',                     'dark',  'base16' },
        { 'base16-vice',                          'dark',  'base16' },
        { 'base16-vulcan',                        'dark',  'base16' },
        { 'base16-windows-10',                    'dark',  'base16' },
        { 'base16-windows-10-light',              'light', 'base16' },
        { 'base16-windows-95',                    'dark',  'base16' },
        { 'base16-windows-95-light',              'light', 'base16' },
        { 'base16-windows-highcontrast',          'dark',  'base16' },
        { 'base16-windows-highcontrast-light',    'light', 'base16' },
        { 'base16-windows-nt',                    'dark',  'base16' },
        { 'base16-windows-nt-light',              'light', 'base16' },
        { 'base16-woodland',                      'dark',  'base16' },
        { 'base16-xcode-dusk',                    'dark',  'base16' },
        { 'base16-zenburn',                       'dark',  'base16' },
        { 'base2tone_cave_dark',                  'dark',  'base2tone' },
        { 'base2tone_cave_light',                 'light', 'base2tone' },
        { 'base2tone_desert_dark',                'dark',  'base2tone' },
        { 'base2tone_desert_light',               'light', 'base2tone' },
        { 'base2tone_drawbridge_dark',            'dark',  'base2tone' },
        { 'base2tone_drawbridge_light',           'light', 'base2tone' },
        { 'base2tone_earth_dark',                 'dark',  'base2tone' },
        { 'base2tone_earth_light',                'light', 'base2tone' },
        { 'base2tone_evening_dark',               'dark',  'base2tone' },
        { 'base2tone_evening_light',              'light', 'base2tone' },
        { 'base2tone_field_dark',                 'dark',  'base2tone' },
        { 'base2tone_field_light',                'light', 'base2tone' },
        { 'base2tone_forest_dark',                'dark',  'base2tone' },
        { 'base2tone_forest_light',               'light', 'base2tone' },
        { 'base2tone_garden_dark',                'dark',  'base2tone' },
        { 'base2tone_garden_light',               'light', 'base2tone' },
        { 'base2tone_heath_dark',                 'dark',  'base2tone' },
        { 'base2tone_heath_light',                'light', 'base2tone' },
        { 'base2tone_lake_dark',                  'dark',  'base2tone' },
        { 'base2tone_lake_light',                 'light', 'base2tone' },
        { 'base2tone_lavender_dark',              'dark',  'base2tone' },
        { 'base2tone_lavender_light',             'light', 'base2tone' },
        { 'base2tone_mall_dark',                  'dark',  'base2tone' },
        { 'base2tone_mall_light',                 'light', 'base2tone' },
        { 'base2tone_meadow_dark',                'dark',  'base2tone' },
        { 'base2tone_meadow_light',               'light', 'base2tone' },
        { 'base2tone_morning_dark',               'dark',  'base2tone' },
        { 'base2tone_morning_light',              'light', 'base2tone' },
        { 'base2tone_motel_light',                'light', 'base2tone' },
        { 'base2tone_pool_dark',                  'dark',  'base2tone' },
        { 'base2tone_pool_light',                 'light', 'base2tone' },
        { 'base2tone_porch_dark',                 'dark',  'base2tone' },
        { 'base2tone_porch_light',                'light', 'base2tone' },
        { 'base2tone_sea_dark',                   'dark',  'base2tone' },
        { 'base2tone_sea_light',                  'light', 'base2tone' },
        { 'base2tone_space_dark',                 'dark',  'base2tone' },
        { 'base2tone_space_light',                'light', 'base2tone' },
        { 'base2tone_suburb_dark',                'dark',  'base2tone' },
        { 'base2tone_suburb_light',               'light', 'base2tone' },
        { 'calvera',                              'dark',  '_' },
        { 'carbonfox',                            'dark',  'nightfox' },
        { 'catppuccin-frappe',                    'dark',  'catppuccin' },
        { 'catppuccin-latte',                     'dark',  'catppuccin' },
        { 'catppuccin-macchiato',                 'dark',  'catppuccin' },
        { 'catppuccin-mocha',                     'dark',  'catppuccin' },
        { 'cobalt2',                              'dark',  '_' },
        { 'codedark',                             'dark',  '_' },
        { 'darkblue',                             'dark',  '_' },
        { 'darker',                               'dark',  '_' },
        { 'darkplus',                             'dark',  '_' },
        { 'darksolar',                            'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'dawnfox',                              'dark',  'nightfox' },
        { 'dayfox',                               'dark',  'nightfox' },
        { 'deepocean',                            'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'delek',                                'light', '_' },
        { 'desert',                               'dark',  '_' },
        { 'deus',                                 'dark',  '_' },
        { 'doubletrouble',                        'dark',  '_' },
        { 'dracula',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'dracula_blood',                        'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'duckbones',                            'dark',  'zenbones' },
        { 'duskfox',                              'dark',  'nightfox' },
        { 'earlysummer',                          'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'edge',                                 'dark',  '_' },
        { 'edge',                                 'light', '_' },
        { 'emerald',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'enfocado',                             'dark',  '_' },
        { 'enfocado',                             'light', '_' },
        { 'everforest',                           'dark',  '_' },
        { 'everforest',                           'light', '_' },
        { 'falcon',                               'dark',  '_' },
        { 'fluoromachine',                        'dark',  '_' },
        { 'forestbones',                          'dark',  'zenbones' },
        { 'forestbones',                          'light', 'zenbones' },
        { 'github_dark',                          'dark',  'github' },
        { 'github_light',                         'light', 'github' },
        { 'gruvbox',                              'dark',  '_' },
        { 'gruvbox',                              'light', '_' },
        { 'gruvbox-baby',                         'dark',  '_' },
        { 'gruvbuddy',                            'dark',  '_' },
        { 'habamax',                              'dark',  '_' },
        { 'horizon',                              'dark',  '_' },
        { 'industry',                             'dark',  '_' },
        { 'juliana',                              'dark',  '_' },
        { 'kanagawa',                             'dark',  '_' },
        { 'kanagawabones',                        'dark',  'zenbones' },
        { 'kimbox',                               'dark',  '_' },
        { 'limestone',                            'light', 'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'lunaperche',                           'dark',  '_' },
        { 'mariana',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'material',                             'dark',  '_',              precmd = function() vim.g.material_style = 'darker' end },
        { 'material',                             'dark',  '_',              precmd = function() vim.g.material_style = 'deep ocean' end },
        { 'material',                             'dark',  '_',              precmd = function() vim.g.material_style = 'lighter' end },
        { 'material',                             'dark',  '_',              precmd = function() vim.g.material_style = 'oceanic' end },
        { 'material',                             'dark',  '_',              precmd = function() vim.g.material_style = 'palenight' end },
        { 'material',                             'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'melange',                              'dark',  '_' },
        { 'melange',                              'light', '_' },
        { 'mellifluous',                          'dark',  '_' },
        { 'mellifluous',                          'light', '_' },
        { 'mellow',                               'dark',  '_' },
        { 'middlenight_blue',                     'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'minimal',                              'dark',  '_' },
        { 'minimal-base16',                       'dark',  'minimal' },
        { 'monokai',                              'dark',  'monokai.nvim' },
        { 'monokai',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'monokai',                              'dark',  'vim-monokai' },
        { 'monokai_pro',                          'dark',  '_' },
        { 'monokai_pro',                          'dark',  'monokai.nvim' },
        { 'monokai_ristretto',                    'dark',  'monokai.nvim' },
        { 'monokai_soda',                         'dark',  'monokai.nvim' },
        { 'moonlight',                            'dark',  '_' },
        { 'moonlight',                            'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'mosel',                                'dark',  '_' },
        { 'murphy',                               'dark',  '_' },
        { 'neobones',                             'dark',  'zenbones' },
        { 'neobones',                             'light', 'zenbones' },
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'dark' end },
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'default' end },
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'doom' end },
        { 'neon',                                 'light', '_',              precmd = function() vim.g.neon_style = 'light' end },
        { 'nightfox',                             'dark',  'nightfox' },
        { 'nord',                                 'dark',  '_' },
        { 'nordbones',                            'dark',  'zenbones' },
        { 'nordfox',                              'dark',  'nightfox' },
        { 'oceanic',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'oh-lucy',                              'dark',  '_' },
        { 'oh-lucy-evening',                      'dark',  'oh-lucy' },
        { 'one-nvim',                             'dark',  '_' },
        { 'one_monokai',                          'dark',  '_' },
        { 'onedark',                              'dark',  'onedarkpro' },
        { 'onedark_dark',                         'dark',  'onedarkpro' },
        { 'onedark_vivid',                        'dark',  'onedarkpro' },
        { 'onelight',                             'light', '_' },
        { 'onenord',                              'dark',  '_' },
        { 'onenord',                              'light', '_' },
        { 'oxocarbon',                            'dark',  '_' },
        { 'oxocarbon',                            'light', '_' },
        { 'pablo',                                'dark',  '_' },
        { 'palenight',                            'dark',  '_' },
        { 'peachpuff',                            'dark',  '_' },
        { 'pink-panic',                           'dark',  '_' },
        { 'poimandres',                           'dark',  '_', precmd = function() require('poimandres').setup() end },
        { 'rose-pine',                            'dark',  '_' },
        { 'rose-pine',                            'dark',  '_',              precmd = function() require('rose-pine').setup({dark_variant = 'main'}) end },
        { 'rose-pine',                            'dark',  '_',              precmd = function() require('rose-pine').setup({dark_variant = 'moon'}) end },
        { 'rosebones',                            'dark',  'zenbones' },
        { 'rosebones',                            'light', 'zenbones' },
        { 'seoulbones',                           'dark',  'zenbones' },
        { 'seoulbones',                           'light', 'zenbones' },
        { 'sherbet',                              'dark',  '_' },
        { 'shine',                                'light', '_' },
        { 'slate',                                'dark',  '_' },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'andromeda' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'atlantis' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'default' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'maia' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'shusia' end },
        { 'substrata',                            'dark',  '_' },
        { 'terafox',                              'dark',  'nightfox' },
        { 'toast',                                'dark',  '_' },
        { 'toast',                                'light', '_' },
        { 'tokyobones',                           'dark',  'zenbones' },
        { 'tokyobones',                           'light', 'zenbones' },
        { 'tokyodark',                            'dark',  '_' },
        { 'tokyonight-day',                       'light', 'tokyonight' },
        { 'tokyonight-moon',                      'dark',  'tokyonight' },
        { 'tokyonight-night',                     'dark',  'tokyonight' },
        { 'tokyonight-storm',                     'dark',  'tokyonight' },
        { 'torte',                                'dark',  '_' },
        { 'tundra',                               'dark',  '_' },
        { 'ukraine',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'vimbones',                             'dark',  'zenbones' },
        { 'vn-night',                             'dark',  '_' },
        { 'zellner',                              'light', '_' },
        { 'zenbones',                             'dark',  '_' },
        { 'zenbones',                             'light', '_' },
        { 'zenburned',                            'dark',  'zenbones' },
        { 'zenwritten',                           'dark',  'zenbones' },
        { 'zenwritten',                           'light', 'zenbones' },
        { 'zephyr',                               'dark',  '_' },
        { 'zephyrium',                            'dark',  '_' },
    }
    math.randomseed(os.time())
    local ind = math.random(1, #colos)
    local selection = colos[ind]
    local scheme = selection[1]
    local bg = selection[2]
    local module = selection[3]
    local precmd = selection.precmd
    -- vim.g.ColoRand = ind .. ':' .. scheme .. ':' .. bg .. ':' .. module
    vim.notify("Colorscheme " .. ind .. ':' .. scheme .. ':' .. bg .. ':' .. module)
    vim.o.background = bg
    if (module == '_') then
        vim.api.nvim_exec_autocmds('User', {pattern = scheme})
    else
        -- require(module)
        vim.api.nvim_exec_autocmds('User', {pattern = module})
    end
    if (precmd) then
        precmd()
    end
    vim.cmd.colorscheme(scheme)
    vim.cmd[[highlight clear CursorLine]]
end

vim.api.nvim_create_user_command('ColoRand', ColoRand, { nargs = 0 })

vim.g.cmp_kinds = {
    Array         = ' ',
    Boolean       = ' ',
    Class         = ' ',
    Color         = ' ',
    Constant      = ' ',
    Constructor   = ' ',
    Enum          = ' ',
    EnumMember    = ' ',
    Event         = ' ',
    Field         = ' ',
    File          = ' ',
    Folder        = ' ',
    Function      = ' ',
    History       = ' ',
    Interface     = ' ',
    Key           = ' ',
    Keyword       = ' ',
    Method        = ' ',
    Module        = ' ',
    Namespace     = 'ﬥ ',
    Null          = ' ',
    Number        = ' ',
    Object        = ' ',
    Operator      = ' ',
    Options       = ' ',
    Package       = ' ',
    Property      = ' ',
    Reference     = ' ',
    Snippet       = ' ',
    String        = ' ',
    Struct        = ' ',
    Text          = ' ',
    TypeParameter = ' ',
    Unit          = ' ',
    Value         = ' ',
    Variable      = ' '
}

vim.g.kindshl_dark = {
    Array         = { fg = '#F42272' },
    Boolean       = { fg = '#B8B8F3' },
    Class         = { fg = '#519872' },
    Color         = { fg = '#A4B494' },
    Constant      = { fg = '#C5E063' },
    Constructor   = { fg = '#4AAD52' },
    Enum          = { fg = '#E3B5A4' },
    EnumMember    = { fg = '#AF2BBF' },
    Event         = { fg = '#6C91BF' },
    Field         = { fg = '#5BC8AF' },
    File          = { fg = '#EF8354' },
    Folder        = { fg = '#BFC0C0' },
    Function      = { fg = '#E56399' },
    History       = { fg = '#C2F8CB' },
    Interface     = { fg = '#8367C7' },
    Key           = { fg = '#D1AC00' },
    Keyword       = { fg = '#20A4F3' },
    Method        = { fg = '#D7D9D7' },
    Module        = { fg = '#F2FF49' },
    Namespace     = { fg = '#FF4242' },
    Null          = { fg = '#C1CFDA' },
    Number        = { fg = '#FB62F6' },
    Object        = { fg = '#F18F01' },
    Operator      = { fg = '#048BA8' },
    Options       = { fg = '#99C24D' },
    Package       = { fg = '#AFA2FF' },
    Property      = { fg = '#CED097' },
    Reference     = { fg = '#1B2CC1' },
    Snippet       = { fg = '#7692FF' },
    String        = { fg = '#FEEA00' },
    Struct        = { fg = '#D81159' },
    Text          = { fg = '#0496FF' },
    TypeParameter = { fg = '#FFFFFC' },
    Unit          = { fg = '#C97B84' },
    Value         = { fg = '#C6DDF0' },
    Variable      = { fg = '#B7ADCF' }
}

vim.g.kindshl_light = {
    Array         = { fg = '#0B6E4F' },
    Boolean       = { fg = '#69140E' },
    Class         = { fg = '#1D3557' },
    Color         = { fg = '#FA9F42' },
    Constant      = { fg = '#744FC6' },
    Constructor   = { fg = '#755C1B' },
    Enum          = { fg = '#A167A5' },
    EnumMember    = { fg = '#B80C09' },
    Event         = { fg = '#53A548' },
    Field         = { fg = '#E2DC12' },
    File          = { fg = '#486499' },
    Folder        = { fg = '#A74482' },
    Function      = { fg = '#228CDB' },
    History       = { fg = '#85CB33' },
    Interface     = { fg = '#537A5A' },
    Key           = { fg = '#645DD7' },
    Keyword       = { fg = '#E36414' },
    Method        = { fg = '#197278' },
    Module        = { fg = '#EC368D' },
    Namespace     = { fg = '#2F9C95' },
    Null          = { fg = '#56666B' },
    Number        = { fg = '#A5BE00' },
    Object        = { fg = '#80A1C1' },
    Operator      = { fg = '#F1DB4B' },
    Options       = { fg = '#2292A4' },
    Package       = { fg = '#B98EA7' },
    Property      = { fg = '#3777FF' },
    Reference     = { fg = '#18A999' },
    Snippet       = { fg = '#BF0D4B' },
    String        = { fg = '#D5573B' },
    Struct        = { fg = '#75485E' },
    Text          = { fg = '#5762D5' },
    TypeParameter = { fg = '#5D2E8C' },
    Unit          = { fg = '#FF6666' },
    Value         = { fg = '#2EC4B6' },
    Variable      = { fg = '#548687' }
}

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

local fname = vim.fn.expand('%')
local lazyfile = "lazyplugins.lua"
-- if fname:sub(-#lazyfile) ==  lazyfile then
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
    vim.cmd([[ let g:loaded_clipboard_provider = 1 ]])
    vim.api.nvim_create_autocmd('User', { pattern='VeryLazy', callback = function()
    vim.cmd([[
    unlet g:loaded_clipboard_provider
    runtime autoload/provider/clipboard.vim
    ]])
end})
-- else
--     require('impatient')
--     vim.api.nvim_create_autocmd('VIMEnter', {callback = ColoRand})
-- end

vim.diagnostic.config({
    float = {
        source = true
    },
    severity_sort = true,
    virtual_text = {
        prefix = ' ',
        source = true
    }
})

url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

vim.fn.matchadd("HighlightURL", url_matcher, 1)

sleeper = {
    timer = vim.loop.new_timer(),
    last = 1,
    sleeps = {
        { start = function() require('drop').setup({theme = "leaves"}); require('drop').show(); end, stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "snow"}); require('drop').show(); end,   stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "stars"}); require('drop').show(); end,  stop = function() require('drop').hide() end },
        { start = function() require('drop').setup({theme = "xmas"}); require('drop').show(); end,   stop = function() require('drop').hide() end },
        { start = function() require('duck').hatch('🐌') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🐤') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('👻') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🤖') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('duck').hatch('🦜') end,                                        stop = function() if #require('duck').ducks_list > 0 then require('duck').cook() end end },
        { start = function() require('zone.styles.epilepsy').start({stage = "aura"}) end,            stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.epilepsy').start({stage = "ictal"}) end,           stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.treadmill').start({}) end,                         stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
        { start = function() require('zone.styles.vanish').start({}) end,                            stop = function() pcall(vim.api.nvim_win_close, zone_win, true) pcall(vim.api.nvim_buf_delete, zone_buf, {force=true}) end },
    }
}

function resetSleeper()
    sleeper.timer:stop()
    sleeper.sleeps[sleeper.last].stop()

    sleeper.timer:start(300000, 0, vim.schedule_wrap(function()
        sleeper.sleeps[sleeper.last].start()
        local new_sleeps = (sleeper.last) % table.getn(sleeper.sleeps) + 1
        sleeper.last = new_sleeps
    end
    ))
end

vim.api.nvim_create_autocmd({'CursorHold'} , {callback = resetSleeper})
vim.api.nvim_create_autocmd({'CursorMoved', "CursorMovedI"} , {callback = function() sleeper.sleeps[sleeper.last].stop() end})

LazyConfig = {
    root = vim.fn.stdpath("data") .. "/lazy", -- directory where plugins will be installed
    defaults = {
        lazy = false, -- should plugins be lazy-loaded?
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
        size = { width = 0.8, height = 0.8 },
        border = "rounded",
        icons = {
            not_loaded = "",
            loaded = "",
            cmd = " ",
            config = "",
            event = "",
            ft = " ",
            init = " ",
            keys = " ",
            plugin = " ",
            runtime = " ",
            source = " ",
            start = "",
            task = " ",
            lazy = " ",
            list = { "●", "", "", "" },
        },
        throttle = 20, -- how frequently should the ui process render events
        custom_keys = {},
    },
    diff = {
        cmd = "git",
    },
    checker = {
        enabled = false,
        concurrency = nil, ---@type number? set to 1 to check for updates very slowly
        notify = true, -- get a notification when new updates are found
        frequency = 3600, -- check for updates every hour
    },
    change_detection = {
        enabled = true,
        notify = true, -- get a notification when changes are found
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
            ttl = 3600 * 24 * 5, -- keep unused modules for up to 5 days
        },
        reset_packpath = true, -- reset the package path to improve startup time
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
            paths = {}, -- add any custom paths here that you want to indluce in the rtp
            disabled_plugins = {
                "gzip",
                -- "health",
                "man",
                -- "matchit",
                -- "matchparen",
                "netrwPlugin",
                "spellfile",
                "tarPlugin",
                -- "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    readme = {
        root = vim.fn.stdpath("state") .. "/lazy/readme",
        files = { "README.md" },
        skip_if_doc_exists = true,
    },
}
Plugins = {
-- <~>
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
    -- https://github.com/m4xshen/autoclose.nvim
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
                'lsp',
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

        local bg
        if (vim.o.background ==  "dark") then
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 0
            local bs = string.format("%X", bg)
            bg = LightenDarkenColor(bs, 40)
        else
            bg = vim.api.nvim_get_hl_by_name('Normal', true).background or 16777215
            local bs = string.format("%X", bg)
            bg = LightenDarkenColor(bs, -40)
        end
        vim.api.nvim_set_hl(0, "IlluminatedWordText", {
            bg = bg,
            underline = true
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
},

-- use 'azabiong/vim-highlighter'

{
    'folke/lsp-colors.nvim',
    event = "LspAttach"
},

-- https://github.com/folke/paint.nvim

{
    'folke/todo-comments.nvim',
    config = function()
        require("todo-comments").setup({
            keywords = {
                THOUGHT = { icon = "🤔", color = "info"}
            }
        })
        vim.keymap.set("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        vim.keymap.set("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })
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
    'norcalli/nvim-colorizer.lua',
    cmd = "ColorizerToggle",
    config = function()
        require('colorizer').setup()
    end
},

{
    'nvim-zh/colorful-winsep.nvim',
    config = function ()
        require('colorful-winsep').setup({
            symbols = { "─", "│", "╭", "╮", "╰", "╯" },
        })
    end,
    event = 'WinNew'
},

{
    't9md/vim-quickhl',
    keys = {
        { '<Leader>w', '<Plug>(quickhl-manual-this-whole-word)', mode = 'n' },
        { '<Leader>w', '<Plug>(quickhl-manual-this)',            mode = 'x' },
        { '<Leader>W', '<Plug>(quickhl-manual-reset)',           mode = 'n' },
        { '<Leader>W', '<Plug>(quickhl-manual-reset)',           mode = 'x' }
    }
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

{ 'Domeee/mosel.nvim',                event = 'User mosel'                                                   },
{ 'EdenEast/nightfox.nvim',           event = 'User nightfox'                                                },
{ 'LunarVim/darkplus.nvim',           event = 'User darkplus'                                                },
{ 'Mofiqul/adwaita.nvim',             event = 'User adwaita'                                                 },
{ 'NLKNguyen/papercolor-theme',       event = 'User PaperColor'                                              },
{ 'RRethy/nvim-base16',               event = 'User base16'                                                  },
{ 'Scysta/pink-panic.nvim',           event = 'User pink-panic',  dependencies = 'rktjmp/lush.nvim'          },
{ 'Shatur/neovim-ayu',                event = 'User ayu'                                                     },
{ 'Th3Whit3Wolf/one-nvim',            event = 'User one-nvim'                                                },
{ 'Tsuzat/NeoSolarized.nvim',         event = 'User NeoSolarized'                                            },
{ 'Yazeed1s/minimal.nvim',            event = 'User minimal'                                                 },
{ 'Yazeed1s/oh-lucy.nvim',            event = 'User oh-lucy'                                                 },
{ 'aca/vim-monokai-pro',              event = 'User monokai_pro'                                             },
{ 'atelierbram/Base2Tone-nvim',       event = 'User base2tone'                                               },
{ 'catppuccin/nvim',                  event = 'User catppuccin'                                              },
{ 'cpea2506/one_monokai.nvim',        event = 'User one_monokai'                                             },
{ 'ellisonleao/gruvbox.nvim',         event = 'User gruvbox'                                                 },
{ 'fenetikm/falcon',                  event = 'User falcon'                                                  },
{ 'folke/tokyonight.nvim',            event = 'User tokyonight'                                              },
{ 'gbprod/nord.nvim',                 event = 'User nord'                                                    },
{ 'glepnir/zephyr-nvim',              event = 'User zephyr'                                                  },
{ 'jsit/toast.vim',                   event = 'User toast'                                                   },
{ 'kaiuri/nvim-juliana',              event = 'User juliana'                                                 },
{ 'kvrohit/mellow.nvim',              event = 'User mellow'                                                  },
{ 'kvrohit/substrata.nvim',           event = 'User substrata'                                               },
{ 'lalitmee/cobalt2.nvim',            event = 'User cobalt2',     dependencies = 'tjdevries/colorbuddy.nvim' },
{ 'lewpoly/sherbet.nvim',             event = 'User sherbet'                                                 },
{ 'lmburns/kimbox',                   event = 'User kimbox'                                                  },
{ 'luisiacc/gruvbox-baby',            event = 'User gruvbox-baby'                                            },
{ 'marko-cerovac/material.nvim',      event = 'User material'                                                },
{ 'maxmx03/FluoroMachine.nvim',       event = 'User fluoromachine'                                           },
{ 'mcchrish/zenbones.nvim',           event = 'User zenbones',    dependencies = 'rktjmp/lush.nvim'          },
{ 'mhartington/oceanic-next',         event = 'User OceanicNext'                                             },
{ 'muchzill4/doubletrouble',          event = 'User doubletrouble'                                           },
{ 'ntk148v/vim-horizon',              event = 'User horizon'                                                 },
{ 'nxvu699134/vn-night.nvim',         event = 'User vn-night'                                                },
{ 'nyoom-engineering/oxocarbon.nvim', event = 'User oxocarbon'                                               },
{ 'olimorris/onedarkpro.nvim',        event = 'User onedarkpro'                                              },
{ 'olivercederborg/poimandres.nvim',  event = 'User poimandres'                                              },
{ 'projekt0n/github-nvim-theme',      event = 'User github'                                                  },
{ 'rafamadriz/neon',                  event = 'User neon'                                                    },
{ 'ramojus/mellifluous.nvim',         event = 'User mellifluous', dependencies = 'rktjmp/lush.nvim'          },
{ 'ray-x/aurora',                     event = 'User aurora'                                                  },
{ 'ray-x/starry.nvim',                event = 'User starry'                                                  },
{ 'rebelot/kanagawa.nvim',            event = 'User kanagawa'                                                },
{ 'rmehri01/onenord.nvim',            event = 'User onenord'                                                 },
{ 'rose-pine/neovim',                 event = 'User rose-pine'                                               },
{ 'sainnhe/edge',                     event = 'User edge'                                                    },
{ 'sainnhe/everforest',               event = 'User everforest'                                              },
{ 'sainnhe/sonokai',                  event = 'User sonokai'                                                 },
{ 'sam4llis/nvim-tundra',             event = 'User tundra'                                                  },
{ 'savq/melange',                     event = 'User melange'                                                 },
{ 'shaunsingh/moonlight.nvim',        event = 'User moonlight'                                               },
{ 'sickill/vim-monokai',              event = 'User vim-monokai'                                             },
{ 'tanvirtin/monokai.nvim',           event = 'User monokai.nvim'                                            },
{ 'theniceboy/nvim-deus',             event = 'User deus'                                                    },
{ 'tiagovla/tokyodark.nvim',          event = 'User tokyodark'                                               },
{ 'titanzero/zephyrium',              event = 'User zephyrium'                                               },
{ 'tjdevries/gruvbuddy.nvim',         event = 'User gruvbuddy',   dependencies = 'tjdevries/colorbuddy.nvim' },
{ 'tomasiser/vim-code-dark',          event = 'User codedark'                                                },
{ 'w3barsi/barstrata.nvim',           event = 'User barstrata'                                               },
{ 'wuelnerdotexe/vim-enfocado',       event = 'User enfocado'                                                },
{ 'yashguptaz/calvera-dark.nvim',     event = 'User calvera'                                                 },
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Comments    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'b3nj5m1n/kommentary',
    config = function()
        require('kommentary.config').configure_language("default", {
            prefer_single_line_comments = true,
        })
    end,
    init = function()
        vim.g.kommentary_create_default_mappings = false
    end,
    keys = {
        {'<C-t>', '<Plug>kommentary_line_default', mode = 'n'},
        {'<C-t>', '<Plug>kommentary_visual_default', mode = 'v'},
    }
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
                fields = { "kind", "abbr", "menu" },
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
                { name = "buffer-lines" },
                { name = 'neorg' },
                { name = 'nerdfont' },
                { name = 'nvim_insert_text_lsp' },
                { name = 'nvim_lsp' },
                { name = 'path' },
                { name = 'snippy' },
                { name = 'treesitter' }
            }),
            window = {
                documentation = cmp.config.window.bordered(),
            }
        })

        local kind_hl = vim.g.kindshl_dark
        if vim.o.background == 'light' then
            kind_hl = vim.g.kindshl_light
        end
        for key, value in pairs(kind_hl) do
            vim.api.nvim_set_hl(0, 'CmpItemKind' .. key, value)
        end
    end,
    -- use 'kwkarlwang/cmp-nvim-insert-text-lsp'
    dependencies = { "aloknigam247/cmp-path", "amarakon/nvim-cmp-buffer-lines", "chrisgrieser/cmp-nerdfont", "dcampos/cmp-snippy", "dcampos/nvim-snippy","hrsh7th/cmp-buffer", "hrsh7th/cmp-cmdline", "hrsh7th/cmp-nvim-lsp", "kwkarlwang/cmp-nvim-insert-text-lsp", "ray-x/cmp-treesitter" },
    event = { "CmdlineEnter", "InsertEnter" },
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
-- https://github.com/jay-babu/mason-nvim-dap.nvim
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
{
    "danymat/neogen",
    cmd = 'Neogen',
    config = function()
        require('neogen').setup {}
    end,
    dependencies = 'nvim-treesitter/nvim-treesitter'
},
-- https://github.com/kkoomen/vim-doge
-- https://github.com/nvim-treesitter/nvim-tree-docs
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ File Explorer  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    -- TODO: lazy load
    'nvim-tree/nvim-tree.lua',
    config = function()
        require("nvim-tree").setup {
            auto_reload_on_write = true,
            disable_netrw = true,
            hijack_cursor = false,
            hijack_netrw = true,
            hijack_unnamed_buffer_when_opening = true,
            ignore_buffer_on_setup = false,
            open_on_setup = false,
            open_on_setup_file = false,
            sort_by = "name",
            root_dirs = {},
            prefer_startup_root = false,
            sync_root_with_cwd = true,
            reload_on_bufenter = false,
            respect_buf_cwd = false,
            on_attach = "disable",
            remove_keymaps = false,
            select_prompts = false,
            view = {
                adaptive_size = false,
                centralize_selection = false,
                width = 30,
                hide_root_folder = false,
                side = "left",
                preserve_window_proportions = false,
                number = false,
                relativenumber = false,
                signcolumn = "yes",
                mappings = {
                    custom_only = false,
                    list = {
                        -- user mappings go here
                    },
                },
                float = {
                    enable = false,
                    quit_on_focus_loss = true,
                    open_win_config = {
                        relative = "editor",
                        border = "rounded",
                        width = 30,
                        height = 30,
                        row = 1,
                        col = 1,
                    },
                },
            },
            renderer = {
                add_trailing = true,
                group_empty = false,
                highlight_git = true,
                full_name = true,
                highlight_opened_files = "all",
                root_folder_label = ":~:s?$?/..?",
                indent_width = 2,
                indent_markers = {
                    enable = true,
                    inline_arrows = true,
                    icons = {
                        corner = "╰",
                        edge = "│",
                        item = "│",
                        bottom = "─",
                        none = " ",
                    },
                },
                icons = {
                    webdev_colors = true,
                    git_placement = "after",
                    padding = " ",
                    symlink_arrow = " 壟 ",
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        bookmark = "",
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "✗",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
                special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
                symlink_destination = true,
            },
            hijack_directories = {
                enable = true,
                auto_open = true,
            },
            update_focused_file = {
                enable = true,
                debounce_delay = 15,
                update_root = true,
                ignore_list = {},
            },
            ignore_ft_on_setup = {},
            system_open = {
                cmd = "",
                args = {},
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                show_on_open_dirs = false,
                debounce_delay = 50,
                severity = {
                    min = vim.diagnostic.severity.HINT,
                    max = vim.diagnostic.severity.ERROR,
                },
                icons = {
                    error   = "",
                    hint    = "",
                    info    = "",
                    warning = "",
                },
            },
            filters = {
                dotfiles = false,
                git_clean = false,
                no_buffer = false,
                custom = {},
                exclude = {},
            },
            filesystem_watchers = {
                enable = true,
                debounce_delay = 50,
                ignore_dirs = {},
            },
            git = {
                enable = true,
                ignore = true,
                show_on_dirs = true,
                show_on_open_dirs = true,
                timeout = 400,
            },
            actions = {
                use_system_clipboard = true,
                change_dir = {
                    enable = true,
                    global = false,
                    restrict_above_cwd = false,
                },
                expand_all = {
                    max_folder_discovery = 300,
                    exclude = { ".git" },
                },
                file_popup = {
                    open_win_config = {
                        col = 1,
                        row = 1,
                        relative = "cursor",
                        border = "rounded",
                        style = "minimal",
                    },
                },
                open_file = {
                    quit_on_open = false,
                    resize_window = true,
                    window_picker = {
                        enable = true,
                        picker = "default",
                        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                        exclude = {
                            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                            buftype = { "nofile", "terminal", "help" },
                        },
                    },
                },
                remove_file = {
                    close_window = true,
                },
            },
            trash = {
                cmd = "gio trash",
                require_confirm = true,
            },
            live_filter = {
                prefix = "[FILTER]: ",
                always_show_folders = true,
            },
            tab = {
                sync = {
                    open = false,
                    close = false,
                    ignore = {},
                },
            },
            notify = {
                threshold = vim.log.levels.INFO,
            },
            log = {
                enable = false,
                truncate = false,
                types = {
                    all = false,
                    config = false,
                    copy_paste = false,
                    dev = false,
                    diagnostics = false,
                    git = false,
                    profile = false,
                    watcher = false,
                },
            },
    }
    end
},
-- {
--     'nvim-neo-tree/neo-tree.nvim',
--     cmd = 'Neotree',
--     module = false,
--     config = function()
--         vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
--         require('neo-tree').setup({
--             default_component_configs = {
--                 git_status = {
--                     symbols = {
--                         -- Change type
--                         added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
--                         modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
--                         deleted   = "",-- this can only be used in the git_status source
--                         renamed   = "",-- this can only be used in the git_status source
--                         -- Status type
--                         untracked = "",
--                         ignored   = "",
--                         unstaged  = "",
--                         staged    = "",
--                         conflict  = "",
--                     }
--                 },
--                 icon = {
--                     folder_closed = '',
--                     folder_open = '',
--                     folder_empty = '',
--                     default = ''
--                 },
--                 indent = {
--                     last_indent_marker = '╰'
--                 }
--             },
--             diagnostics = {
--               autopreview = true, -- Whether to automatically enable preview mode
--               autopreview_config = {}, -- Config table to pass to autopreview (for example `{ use_float = true }`)
--               autopreview_event = "neo_tree_buffer_enter", -- The event to enable autopreview upon (for example `"neo_tree_window_after_open"`)
--               bind_to_cwd = true,
--               diag_sort_function = "severity", -- "severity" means diagnostic items are sorted by severity in addition to their positions.
--                                                -- "position" means diagnostic items are sorted strictly by their positions.
--                                                -- May also be a function.
--               follow_behavior = { -- Behavior when `follow_current_file` is true
--                 always_focus_file = true, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file.
--                 expand_followed = true, -- Ensure the node of the followed file is expanded
--                 collapse_others = true, -- Ensure other nodes are collapsed
--               },
--             },
--             filesystem = {
--                 follow_current_file = true,
--                 hijack_netrw_behavior = 'open_current'
--             },
--             popup_border_style = "rounded",
--             sources = {
--                 "diagnostics",
--                 "filesystem"
--             }
--         })
--     end,
--     dependencies = { 'MunifTanjim/nui.nvim', 'mrbjarksen/neo-tree-diagnostics.nvim', 'nvim-lua/plenary.nvim' }
-- },
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
                csproj = {
                    color = '#854CC7',
                    cterm_color = '98',
                    icon = '',
                    name = "Csproj"
                },
                norg = {
                    icon = '',
                    name = "Neorg"
                }
            }
        })
    end,
    lazy = true
},

{
    'kyazdani42/nvim-web-devicons',
    config = function()
        require'nvim-web-devicons'.setup({
            override = require('nvim-material-icon').get_icons()
        })
        require("nvim-web-devicons").set_default_icon('', '#6d8086', 66)
    end,
    lazy = true
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
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        capabilities = require('cmp_nvim_insert_text_lsp').update_capabilities(capabilities)
        mason_lspconfig.setup_handlers {
            function (server_name)
                local lspconfig = require('lspconfig')
                if server_name == "powershell_es" then
                    lspconfig.powershell_es.setup {
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services" -LogPath "./powershell_es.log" -SessionDetailsPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal'},
                        -- cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -BundledModulesPath "C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices" -LogPath "./powershell_es.log" -SessionDetailsPath "./powershell_es.session.json" -FeatureFlags @() -AdditionalModules @() -HostName "nvim" -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal -EnableConsoleRepl'},
                        cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "Import-Module 'C:\\Users\\aloknigam\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services\\PowerShellEditorServices\\PowerShellEditorServices.psd1'; Start-EditorServices -HostName 'Visual Studio Code Host' -HostProfileId 'Microsoft.VSCode' -HostVersion '2022.12.1' -AdditionalModules @('PowerShellEditorServices.VSCode') -BundledModulesPath 'c:\\Users\\aloknigam\\.vscode\\extensions\\ms-vscode.powershell-2022.12.1\\modules' -EnableConsoleRepl -LogLevel 'Normal' -LogPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\logs\\1671314645-cea5c434-0147-4205-b2be-5907f5a8b7de1671314642966\\EditorServices.log' -SessionDetailsPath 'c:\\Users\\aloknigam\\AppData\\Roaming\\Code\\User\\globalStorage\\ms-vscode.powershell\\sessions\\PSES-VSCode-39524-314832.json' -FeatureFlags @() -Stdio"},
                        -- bundle_path = 'C:/Users/aloknigam/AppData/Local/nvim-data/mason/packages/powershell-editor-services',
                        capabilities = capabilities,
                        -- root_dir = function() return 'C:/Users/aloknigam/learn/powershell' end,
                        root_dir = function() return vim.fn.getcwd() end,
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
    lazy = true
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
        require('neorg').setup {
            load = {
                ["core.highlights"]              = {},
                ["core.integrations.treesitter"] = { config = { install_parsers = false } },
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
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
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
    lazy = true
},

{
    'tamton-aquib/duck.nvim',
    lazy = true
},

{
    'folke/drop.nvim',
    lazy = true
},
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Sessions    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
  'rmagatti/auto-session',
  config = function()
    vim.g.auto_session_suppress_dirs = { "C:\\Users\\aloknigam", "~" }
    require("auto-session").setup({
        post_delete_cmds = {
            "let g:auto_session_enabled = v:false",
            "unlet g:session_icon"
        },
        post_restore_cmds = {
            "let g:session_icon = ''"
        },
        post_save_cmds = {
            "let g:session_icon = ''"
        }
    })
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end,
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
    dependencies = 'honza/vim-snippets',
    lazy = true
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
        Icon_index = 0
        local function LspIcon()
            local icons = {"䷀", "䷪",  "䷍", "䷈", "䷉", "䷌", "䷫"}
            -- local icons = {'ﯺ', 'ﯸ', 'ﯹ'}
            Icon_index = (Icon_index) % #icons + 1
            return icons[Icon_index]
        end
        -- local navic = require("nvim-navic")
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
        --         disabled_filetypes = {
        --             statusline = {},
        --             winbar = {},
        --         },
        --         ignore_focus = {},
        --         always_divide_middle = true,
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
                        color = { gui = 'bold,italic' },
                        fmt = function(str)
                            return str:sub(1,1)
                        end
                    }
                },
                lualine_b = {
                    {
                        'branch',
                        color = { gui = 'bold' },
                        icon = {'', color = {fg = '#F14C28'}},
                        on_click = function()
                            vim.cmd("Telescope git_branches")
                        end
                    },
                    {
                        'diff',
                        on_click = function()
                            vim.cmd("Telescope git_status")
                        end
                    },
                    {
                        'diagnostics',
                        on_click = function()
                            vim.cmd('TroubleToggle')
                        end,
                        sources = { 'nvim_diagnostic' },
                        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                    }
                },
                lualine_c = {
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
                        newfile_status = false,   -- Display new file status (new file means no write after created)
                        on_click = function()
                            vim.cmd("NvimTreeToggle")
                        end,
                        path = 0,                -- 0: Just the filename
                        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                        symbols = {
                            modified = '●',      -- Text to show when the file is modified.
                            readonly = '',      -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]',     -- Text to show for new created file before first writting
                        }
                    }
                },
                lualine_x = {
                    {
                        LspIcon,
                        cond = function()
                            return vim.lsp.get_active_clients({bufnr = 0})[1] ~= nil
                        end,
                        on_click = function()
                            vim.cmd("LspInfo")
                        end,
                        separator = ''
                    },
                    { 'g:session_icon', separator = '' },
                    'fileformat',
                    'encoding'
                },
                lualine_y = {
                    {
                        'progress',
                        on_click = function ()
                            local satellite = require('satellite')
                            if satellite.enabled then
                                vim.cmd("SatelliteDisable")
                                satellite.enabled = false
                            else
                                vim.cmd("SatelliteEnable")
                                satellite.enabled = true
                            end
                        end
                    }
                },
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
        extensions = { 'nvim-tree', 'quickfix', 'symbols-outline', 'toggleterm' }
        }
    end,
    event = 'CursorHold'
},
-- <~>
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    Tab Line    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
    'akinsho/bufferline.nvim',
    config = function()
        local sym_map = {
            ['error']   = ' ',
            ['hint']    = ' ',
            ['info']    = ' ',
            ['warning'] = ' ',
        }
        require("bufferline").setup {
            options = {
                always_show_bufferline = false,
                diagnostics = "nvim_lsp",
                middle_mouse_command = 'bdelete! %d',
                mode = "tabs",
                right_mouse_command = nil,
                separator_style = "thick",
                diagnostics_indicator = function(_, _, diagnostics_dict, context)
                    if context.buffer:current() then
                        return ''
                    end
                    local res = ''
                    for k, v in pairs(diagnostics_dict) do
                        res = res .. sym_map[k] .. v .. ' '
                    end
                    return res
                end,
                indicator = {
                    style = 'underline'
                }
            }
        }
    end,
    event = 'TabNew'
},
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
    'RRethy/nvim-treesitter-endwise',
    ft = 'lua'
},

{
    'nvim-treesitter/nvim-treesitter',
    config = function()
        require('nvim-treesitter.configs').setup {
            auto_install = true,
            endwise = {
                enable = true,
            },
            highlight = {
                additional_vim_regex_highlighting = false,
                disable = { "help", "norg", "norg_meta", "yaml" },
                enable = true
            },
            ignore_install = { "help", "norg", "norg_meta", "yaml" },
            -- markid = {
            --     enable = true,
            --     queries = { default = '(identifier) @markid' }
            -- },
            rainbow = {
                enable = true,
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
            }
        }
    end,
    dependencies = 'p00f/nvim-ts-rainbow',
    event = 'User VeryLazy',
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
-- <~>
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      TUI       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</>
{
  'folke/noice.nvim',
  config = function()
      require("noice").setup({
          cmdline = {
              enabled = true, -- enables the Noice cmdline UI
              view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
              opts = {}, -- global options for the cmdline. See section on views
              ---@type table<string, CmdlineFormat>
              format = {
                  -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                  -- view: (default is cmdline view)
                  -- opts: any options passed to the view
                  -- icon_hl_group: optional hl_group for the icon
                  -- title: set to anything or empty string to hide
                  cmdline = { pattern = "^:", icon = "", lang = "vim" },
                  search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                  search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                  filter = { pattern = "^:%s*!", icon = "$", lang = "powershell" },
                  lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
                  help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                  input = {}, -- Used by input()
                  -- lua = false, -- to disable a format, set to `false`
              },
          },
          messages = {
              -- NOTE: If you enable messages, then the cmdline is enabled automatically.
              -- This is a current Neovim limitation.
              enabled = false, -- enables the Noice messages UI
              view = "notify", -- default view for messages
              view_error = "notify", -- view for errors
              view_warn = "notify", -- view for warnings
              view_history = "messages", -- view for :messages
              view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
          },
          popupmenu = {
              enabled = true, -- enables the Noice popupmenu UI
              ---@type 'nui'|'cmp'
              backend = "cmp", -- backend to use to show regular cmdline completions
              ---@type NoicePopupmenuItemKind|false
              -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
              kind_icons = {}, -- set to `false` to disable icons
          },
          -- default options for require('noice').redirect
          -- see the section on Command Redirection
          ---@type NoiceRouteConfig
          redirect = {
              view = "popup",
              filter = { event = "msg_show" },
          },
          -- You can add any custom commands below that will be available with `:Noice command`
          ---@type table<string, NoiceCommand>
          commands = {
              history = {
                  -- options for the message history that you get with `:Noice`
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
              -- :Noice last
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
              -- :Noice errors
              errors = {
                  -- options for the message history that you get with `:Noice`
                  view = "popup",
                  opts = { enter = true, format = "details" },
                  filter = { error = true },
                  filter_opts = { reverse = true },
              },
          },
          notify = {
              -- Noice can be used as `vim.notify` so you can route any notification like other messages
              -- Notification messages have their level and other properties set.
              -- event is always "notify" and kind can be any log level as a string
              -- The default routes will forward notifications to nvim-notify
              -- Benefit of using Noice for this is the routing and consistent history view
              enabled = true,
              view = "notify",
          },
          lsp = {
              progress = {
                  enabled = true,
                  -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                  -- See the section on formatting for more details on how to customize.
                  --- @type NoiceFormat|string
                  format = "lsp_progress",
                  --- @type NoiceFormat|string
                  format_done = "lsp_progress_done",
                  throttle = 1000 / 30, -- frequency to update lsp progress message
                  view = "mini",
              },
              override = {
                  -- override the default lsp markdown formatter with Noice
                  ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                  -- override the lsp markdown formatter with Noice
                  ["vim.lsp.util.stylize_markdown"] = false,
                  -- override cmp documentation with Noice (needs the other options to work)
                  ["cmp.entry.get_documentation"] = false,
              },
              hover = {
                  enabled = true,
                  view = nil, -- when nil, use defaults from documentation
                  ---@type NoiceViewOptions
                  opts = {}, -- merged with defaults from documentation
              },
              signature = {
                  enabled = true,
                  auto_open = {
                      enabled = true,
                      trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                      luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                      throttle = 50, -- Debounce lsp signature help request by 50ms
                  },
                  view = nil, -- when nil, use defaults from documentation
                  ---@type NoiceViewOptions
                  opts = {}, -- merged with defaults from documentation
              },
              message = {
                  -- Messages shown by lsp servers
                  enabled = true,
                  view = "notify",
                  opts = {},
              },
              -- defaults for hover and signature help
              documentation = {
                  view = "hover",
                  ---@type NoiceViewOptions
                  opts = {
                      lang = "markdown",
                      replace = true,
                      render = "plain",
                      format = { "{message}" },
                      win_options = { concealcursor = "n", conceallevel = 3 },
                  },
              },
          },
          markdown = {
              hover = {
                  ["|(%S-)|"] = vim.cmd.help, -- vim help links
                  ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
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
              checker = true, -- Disable if you don't want health checks to run
          },
          smart_move = {
              -- noice tries to move out of the way of existing floating windows.
              enabled = true, -- you can disable this behaviour here
              -- add any filetypes here, that shouldn't trigger smart move.
              excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
          },
          ---@type NoicePresets
          presets = {
              -- you can enable a preset by setting it to true, or a table that will override the preset config
              -- you can also add custom presets that you can enable/disable with enabled=true
              bottom_search = false, -- use a classic bottom cmdline for search
              command_palette = false, -- position the cmdline and popupmenu together
              long_message_to_split = false, -- long messages will be sent to a split
              inc_rename = false, -- enables an input dialog for inc-rename.nvim
              lsp_doc_border = false, -- add a border to hover docs and signature help
          },
          throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
          ---@type NoiceConfigViews
          views = {}, ---@see section on views
          ---@type NoiceRouteConfig[]
          routes = {}, --- @see section on routes
          ---@type table<string, NoiceFilter>
          status = {}, --- @see section on statusline components
          ---@type NoiceFormatOptions
          format = {}, --- @see section on formatting
      })
  end,
  enabled = false,
  dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
},

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

-- https://github.com/EtiamNullam/deferred-clipboard.nvim

{
    -- https://github.com/rareitems/printer.nvim
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
    'chrisbra/csv.vim',
    config = function()
        vim.g.csv_default_delim = ','
    end,
    ft = 'csv'
},

{
    'dstein64/vim-startuptime',
    cmd = 'StartupTime'
},

-- https://github.com/emileferreira/nvim-strict
-- https://github.com/folke/neoconf.nvim
-- use 'jbyuki/instant.nvim'
-- https://github.com/jghauser/mkdir.nvim

{
    'kwkarlwang/bufjump.nvim',
    lazy = true
},

{
    'lewis6991/satellite.nvim',
    cmd = 'SatelliteEnable',
    config = function()
        require('satellite').setup({ winblend = vim.o.winblend })
        vim.cmd('hi link ScrollView lualine_a_normal')
    end
},

{
    'kylechui/nvim-surround',
    lazy = true
},

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
    cond = function()
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

-- https://github.com/shortcuts/no-neck-pain.nvim

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
    keys = {
        { '"', mode = 'n'     },
        { '"', mode = 'v'     },
        { '<C-R>', mode = 'i' }
    }
}
-- https://github.com/utilyre/barbecue.nvim
}

require("lazy").setup(Plugins, LazyConfig)
ColoRand()
-- <~>
-- vim: fmr=</>,<~>
