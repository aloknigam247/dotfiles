$scoop_pkgs = @(
    "mingw",
    "pandoc"
)

$winget_pkgs = @(
    "Neovim.Neovim",
    "OpenJS.NodeJS",
    "Python.Python.3"
)

$files = @{
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "plugins.lua" = "$env:LOCALAPPDATA\nvim\lua\plugins.lua";
    "site" = "$env:LOCALAPPDATA\nvim-data\site";
}
