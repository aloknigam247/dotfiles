$npm_pkgs = @(
    "@commitlint/cli",
    "@commitlint/config-conventional"
)

$scoop_pkgs = @(
    "delta"
)

$files = @{
    ".gitconfig" = "~\.gitconfig";
    "catppuccin.gitconfig" = "~\.config\git\catppuccin.gitconfig";
    "commitlint.config.js" = "~\.config\git\commitlint.config.js";
    "hooks/commit-msg" = "~\.config\git\hooks\commit-msg"
}
