$choco_pkgs = @(
    "mingw"
)

$winget_pkgs = @(
    "Neovim.Neovim",
    "OpenJS.NodeJS",
    "Python.Python.3"
)

$files = @{
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "site" = "$env:LOCALAPPDATA\nvim-data\site";
}
