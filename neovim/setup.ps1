$scoop_pkgs = @(
    "mingw",
    "neovim-nightly",
    "pandoc"
)

$winget_pkgs = @(
    "OpenJS.NodeJS",
    "Python.Python.3"
)

$files = @{
    "init.lua" = "$env:LOCALAPPDATA\nvim\lua\init.lua";
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "en.utf-8.add" = "$env:LOCALAPPDATA\nvim\spell\en.utf-8.add"
}


