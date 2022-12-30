"
"  █████╗ ██╗      ██████╗ ██╗  ██╗    ███╗   ██╗██╗ ██████╗  █████╗ ███╗   ███╗
" ██╔══██╗██║     ██╔═══██╗██║ ██╔╝    ████╗  ██║██║██╔════╝ ██╔══██╗████╗ ████║
" ███████║██║     ██║   ██║█████╔╝     ██╔██╗ ██║██║██║  ███╗███████║██╔████╔██║
" ██╔══██║██║     ██║   ██║██╔═██╗     ██║╚██╗██║██║██║   ██║██╔══██║██║╚██╔╝██║
" ██║  ██║███████╗╚██████╔╝██║  ██╗    ██║ ╚████║██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝

" syntax off
" au BufRead * echo "BufRead"
" au BufEnter * echo "BufEnter"
" au BufReadPost * echo "BufReadPost"
" au BufWinEnter * echo "BufWinEnter"
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Plugins      ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
lua << EOF
-- require("lazy").setup(plugins, opts)
vim.api.nvim_create_autocmd('UIEnter', {callback = function()
    -- vim.defer_fn(function() vim.api.nvim_exec_autocmds('User', {pattern = 'LazyLoad0'}) end, 0)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LazyLoad0'})
end})


vim.notify = function(msg, level, opt)
    require('notify') -- lazy loads nvim-notify and set vim.notify = notify
    vim.notify(msg, level, opt)
end

function ColoRand()
    local colos = {
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
        { 'base16-cupertino',                     'dark',  'base16' },
        { 'base16-da-one-black',                  'dark',  'base16' },
        { 'base16-da-one-gray',                   'dark',  'base16' },
        { 'base16-da-one-ocean',                  'dark',  'base16' },
        { 'base16-da-one-paper',                  'dark',  'base16' },
        { 'base16-da-one-sea',                    'dark',  'base16' },
        { 'base16-da-one-white',                  'dark',  'base16' },
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
        { 'base16-emil',                          'dark',  'base16' },
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
        { 'base16-fruit-soda',                    'dark',  'base16' },
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
        { 'base16-isotope',                       'dark',  'base16' },
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
        { 'base16-tomorrow',                      'dark',  'base16' },
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
        { 'dracula',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'dracula_blood',                        'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
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
        { 'github_dark',                          'dark',  'github' },
        { 'github_light',                         'light', 'github' },
        { 'gruvbox-baby',                         'dark',  '_' },
        { 'habamax',                              'dark',  '_' },
        { 'horizon',                              'dark',  '_' },
        { 'industry',                             'dark',  '_' },
        { 'juliana',                              'dark',  '_' },
        { 'kanagawa',                             'dark',  '_' },
        { 'kimbox',                               'dark',  '_' },
        { 'koehler',                              'dark',  '_' },
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
        { 'mellow',                               'dark',  '_' },
        { 'middlenight_blue',                     'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
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
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'dark' end },
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'default' end },
        { 'neon',                                 'dark',  '_',              precmd = function() vim.g.neon_style = 'doom' end },
        { 'neon',                                 'light', '_',              precmd = function() vim.g.neon_style = 'light' end },
        { 'nightfox',                             'dark',  'nightfox' },
        { 'nord',                                 'dark',  '_' },
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
        { 'rose-pine',                            'dark',  '_' },
        { 'rose-pine',                            'dark',  '_',              precmd = function() require('rose-pine').setup({dark_variant = 'main'}) end },
        { 'rose-pine',                            'dark',  '_',              precmd = function() require('rose-pine').setup({dark_variant = 'moon'}) end },
        { 'shine',                                'light', '_' },
        { 'slate',                                'dark',  '_' },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'andromeda' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'atlantis' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'default' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'maia' end },
        { 'sonokai',                              'dark',  '_',              precmd = function() vim.g.sonokai_style = 'shusia' end },
        { 'terafox',                              'dark',  'nightfox' },
        { 'toast',                                'dark',  '_' },
        { 'toast',                                'light', '_' },
        { 'tokyodark',                            'dark',  '_' },
        { 'tokyonight-day',                       'light', 'tokyonight' },
        { 'tokyonight-moon',                      'dark',  'tokyonight' },
        { 'tokyonight-night',                     'dark',  'tokyonight' },
        { 'tokyonight-storm',                     'dark',  'tokyonight' },
        { 'torte',                                'dark',  '_' },
        { 'tundra',                               'dark',  '_' },
        { 'ukraine',                              'dark',  'starry',         precmd = function() require('starry').setup({custom_highlights = { LineNr = { underline = false } } }) end },
        { 'vn-night',                             'dark',  '_' },
        { 'zellner',                              'light', '_' },
        { 'zephyr',                               'dark',  '_' },
        { 'zephyrium',                            'dark',  '_' },
    }
    math.randomseed(os.time())
    local ind = math.random(1, table.getn(colos))
    local selection = colos[ind]
    local scheme = selection[1]
    local bg = selection[2]
    local module = selection[3]
    local precmd = selection.precmd
    vim.g.ColoRand = scheme .. ':' .. bg .. ':' .. module
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
    Namespace     = ' ',
    Null          = ' ',
    Number        = ' ',
    Object        = ' ',
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
EOF

autocmd BufRead plugins.lua lua require('plugins')
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰    Variables     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let &titleold = getcwd()           " Set console title to path on vim exit
let c_curly_error = 1              " Show curly braces error
let c_space_errors = 1             " Highlight trailing spaces
let g:markdown_folding = 1         " Enable markdown folding
let g:python_recommended_style = 0 " Disable inbuilt python tabs settings
let g:diff_translations = 0        " Disables localisations and speeds up syntax highlighting in diff mode
let g:load_doxygen_syntax = 1      " Recognize doxygen comment style
let g:netrw_liststyle = 3          " Set netrw style as tree
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Config Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set autowrite             " Auto write changes
set clipboard=unnamedplus " Use + clipboard buffer
set foldnestmax=2         " Max fold level
set nobackup              " Do not create backup file
set path+=**              " Look for all files in sub dirs
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰ Editor Settings  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set bomb                              " Keep the BOM file marker
set breakindent                       " Every wrapped line will continue visually indented
set completeopt=menu,menuone,noselect " For nvim-cmp
set cpoptions+=Z                      " When using w! while the 'readonly' option is set, don't reset 'readonly'
set expandtab                         " Convert tabs to spaces
" set formatoptions=tcroqwanvbl1jp      " Set auto formating options 'fo-table'
set history=1000                      " Increase undo limit
set linebreak                         " Break wrapped line at 'breakat'
set nofixendofline                    " Do not change end of line
set noswapfile                        " Disable swap files
set nowritebackup                     " Disable intermediate backup file
set shiftwidth=4                      " When shifting, indent using spaces
set tabstop=4                         " Indent using spaces
set textwidth=100                     " Set text width to 100
set wrap                              " Enable wrap
set updatetime=500                    " CursorHold time
set wrapmargin=0                      " Disable wrap margin
setglobal bomb                        " Keep the BOM file marker
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Filetype     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" autocmd BufNewFile,BufRead *.csproj set filetype=csproj
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰   UI Settings    ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
let g:netrw_banner = 0       " Turn off banner in netrw
let g:vimsyn_embed = 'lpr'   " embededded script highlight
" set background=light         " Select appropriate colors for dark or light
set cinoptions+=l1,N-s,E-s,(0,w1
set cmdheight=0              " Hide command line
set confirm                  " Raise dialog on quit if file has unsaved changes
set culopt=number,screenline " Highlight current line and line number of current window
set cursorline               " Highlight the line currently under cursor
set diffopt+=vertical        " Open diff in vertical sp:set lit
set inccommand=split         " Show effects of command in preview windows
set fillchars=fold:\         " No dot characters in fold
set foldmethod=marker        " Set fold method to marker
set laststatus=3             " Disable global statusline
" set lazyredraw               " Don't redraw screen on macros, registers and other commands.
set lcs=lead:·,trail:•,multispace:·,tab:»\ ,nbsp:⦸,extends:»,precedes:«
set list                     " Show special characters
set mouse=a                  " Enable mouse support
set noshowmode               " Don't show INSERT/NOMRAL/VISUAL modes
set number                   " Enable line number
set pumblend=10              " pseudo-transparency effect for popup-menu
set shortmess=FIWmno         " Short messages
set signcolumn=auto:9        " Set max size of signcolumn
set splitbelow               " Place new window below on :split
set splitright               " Place new window right on :vsplit
set termguicolors            " Enable true colors support
set title                    " Set console title
set visualbell               " Flash the screen instead of beeping on errors
set whichwrap=b,s,<,>,[,]    " move cursor across lines, Normal: <,>, Insert:[,]
set wildignore="*.exe"       " Files to ignore in wildmenu
set wildignorecase           " Ignore case
set wildmenu                 " Enable wild menu
set winblend=10              " pseudo-transparency effect for float window
sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
sign define DiagnosticSignHint  text= texthl=DiagnosticSignHint  linehl= numhl=
sign define DiagnosticSignInfo  text= texthl=DiagnosticSignInfo  linehl= numhl=
sign define DiagnosticSignWarn  text= texthl=DiagnosticSignWarn  linehl= numhl=
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰  Search Options  ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive when query contains an uppercase letter
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰     Mappings     ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
imap <C-Left> <C-\><C-O>B
imap <C-Right> <C-\><C-O>E<C-\><C-O>a
imap <C-a> <C-\><C-O>^
imap <C-e> <C-\><C-O>$
map <C-Left> B
map <C-Right> E
map <C-a> ^
map <C-e> $
" usefull mapping
" gq format lines
" gw format lines with cursor remains at same place
" vip select paragraph
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       GUI        ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{
if exists("g:neovide")
    " let g:neovide_cursor_animation_length=0.13
    let g:neovide_cursor_animation_length=0
    " let g:neovide_cursor_trail_size = 0.8
    " let g:neovide_cursor_vfx_mode = "railgun"
    " let g:neovide_cursor_vfx_particle_density = 15.0
    " let g:neovide_cursor_vfx_particle_lifetime=5
    " let g:neovide_floating_blur_amount_x = 2.0
    " let g:neovide_floating_blur_amount_y = 10.0
    let g:neovide_fullscreen = v:false
    " let g:neovide_refresh_rate = 120
    let g:neovide_remember_window_size = v:false
    let g:neovide_scroll_animation_length = 0.0
    let g:neovide_transparency=0.95
    " let g:neovide_underline_automatic_scaling = v:true
    set guifont=VictorMono_NF:h13
    map <F11> :execute "let g:neovide_fullscreen = xor(g:neovide_fullscreen, v:true)"<CR>
endif
" }}}

"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❰       MISC       ❱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
" {{{

let g:termdebug_wide = 163
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif " remember file position when closed
autocmd FilterWritePre * if &diff | setlocal wrap< | endif
autocmd VimLeave * let &t_me="\e[0 q" " resets cursor


" Make cursor _ for visual modes
set guicursor=n-c-sm:block,i-ci-ve:ver25,r-cr-o-v:hor20
" Temporary solution to neovim cursor not reset 
augroup RestoreCursorShapeOnExit
    autocmd!
    autocmd VimLeave * set guicursor=a:ver20 " sets cursor to vertical bar
augroup END


" highlight ColorColumn ctermbg=white
" call matchadd('ColorColumn', '\%101v', 100)
" augroup vimrc_autocmds
"   autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"   autocmd BufEnter * match OverLength /\%101v/
" augroup END

" let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
let &shell = 'pwsh'
let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
set shellquote= shellxquote=


let g:startuptime_event_width = 0

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
function! SynT()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
lua << EOF
-- Blink on yank
-- au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=300, on_visual=true}
vim.api.nvim_create_autocmd(
	"TextYankPost",
	{
		desc = "highlight text on yank",
		pattern = "*",
		group = group,
		callback = function()
			vim.highlight.on_yank {
				higroup="ColorColumn", timeout=300, on_visual=true
			}
		end,
	}
)
EOF
" }}}
highlight ConflictMarkerBegin guibg=#2f7366
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guibg=#2f628e
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81

lua << EOF
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
    require('init')
    ColoRand()
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

url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

vim.fn.matchadd("HighlightURL", url_matcher, 1)
EOF
highlight HighlightURL gui=underline cterm=underline
