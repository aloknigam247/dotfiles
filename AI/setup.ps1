$files = @{
    "copilot-instructions.md" = "~\.copilot\copilot-instructions.md"
    "mcp-config.json" = "~\.copilot\mcp-config.json"
    "skills" = "~\.copilot\skills"
}

$files_copy = @{
    "settings.json" = "~\.copilot\settings.json"
}

$pip_pkgs = @(
    "python-pptx"
    "pywin32"
)

$winget_pkgs = @(
    "GitHub.Copilot"
)
