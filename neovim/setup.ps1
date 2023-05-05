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
    "ftplugin" = "$env:LOCALAPPDATA\nvim\ftplugin";
    "init.lua" = "$env:LOCALAPPDATA\nvim\lua\init.lua";
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "en.utf-8.add" = "$env:LOCALAPPDATA\nvim\spell\en.utf-8.add"
}


