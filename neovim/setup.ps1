$scoop_pkgs = @(
    "mingw",
    "pandoc"
)

$winget_pkgs = @(
    "Neovim.Neovim.Nightly",
    "OpenJS.NodeJS",
    "Python.Python.3"
)

$files = @{
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "plugins.lua" = "$env:LOCALAPPDATA\nvim\lua\plugins.lua";
    "init.lua" = "$env:LOCALAPPDATA\nvim\lua\init.lua";
}
