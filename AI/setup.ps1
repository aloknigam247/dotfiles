$files = @{
    "copilot-instructions.md" = "~\.copilot\copilot-instructions.md"
    "mcp-config.json" = "~\.copilot\mcp-config.json"
    "skills" = "~\.copilot\skills"
}

$files_copy = @{
    "settings.json" = "~\.copilot\settings.json"
}

$npm_pkgs = @(
    "@mermaid-js/mermaid-cli"
)

$pip_pkgs = @(
    "kaleido"
    "plotly"
    "python-pptx"
)

$scoop_pkgs = @(
    "d2"
)

$winget_pkgs = @(
    "GitHub.Copilot.Prerelease"
    "JGraph.Draw"
)

# mmdc renders through a headless Chrome that puppeteer downloads out-of-band
# (Chrome for Testing CDN, cached under ~/.cache/puppeteer). There is no
# declarative slot for it, so fetch once when the cache is missing.
$chromeCache = Join-Path $env:USERPROFILE ".cache\puppeteer\chrome-headless-shell"
if ((Get-Command npx -ErrorAction SilentlyContinue) -and -not (Test-Path $chromeCache)) {
    npx --yes puppeteer browsers install chrome-headless-shell
}
