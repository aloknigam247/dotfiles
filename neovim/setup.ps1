$env:XDG_CACHE_HOME  = "D:\apps"
$env:XDG_CONFIG_HOME = "D:\apps"
$env:XDG_DATA_HOME   = "D:\apps"
$env:XDG_LOG_HOME    = "D:\apps"
$env:XDG_STATE_HOME  = "D:\apps"

$scoop_pkgs = @(
    "mingw",
    "neovim-nightly",
    "neovide"
    "pandoc"
)

$winget_pkgs = @(
    "OpenJS.NodeJS"
)

$files = @{
    "en.utf-8.add" = "$env:XDG_CONFIG_HOME\nvim\spell\en.utf-8.add";
    "init.lua" = "$env:XDG_CONFIG_HOME\nvim\lua\init.lua";
    "init.vim" = "$env:XDG_CONFIG_HOME\nvim\init.vim";
    "snippets" = "$env:XDG_CONFIG_HOME\nvim\snippets"
}
