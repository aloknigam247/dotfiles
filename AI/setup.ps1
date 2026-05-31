$files = @{
    "copilot-instructions.md" = "~\.copilot\copilot-instructions.md"
    "mcp-config.json" = "~\.copilot\mcp-config.json"
    "skills" = "~\.copilot\skills"
}

$files_copy = @{
    "settings.json" = "~\.copilot\settings.json"
}

$winget_pkgs = @(
    "GitHub.Copilot.Prerelease"
)
