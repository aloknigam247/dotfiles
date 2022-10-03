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
    # "packer.nvim" = "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim";
    # "plug.vim" = "$env:LOCALAPPDATA\nvim-data\site\autoload\plug.vim";
    "plugins.lua" = "$env:LOCALAPPDATA\nvim\lua\plugins.lua";
}
