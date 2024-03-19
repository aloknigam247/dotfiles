$scoop_pkgs = @(
    "mingw",
    "neovim-nightly",
    "pandoc"
)

$winget_pkgs = @(
    "OpenJS.NodeJS"
)

$files = @{
    "en.utf-8.add" = "$env:LOCALAPPDATA\nvim\spell\en.utf-8.add";
    "init.lua" = "$env:LOCALAPPDATA\nvim\lua\init.lua";
    "init.vim" = "$env:LOCALAPPDATA\nvim\init.vim";
    "snippets" = "$env:LOCALAPPDATA\nvim\snippets"
}