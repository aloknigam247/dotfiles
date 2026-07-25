# Creates a GitHub issue from a triage draft markdown file in one shot.
#
# The draft's first "# " heading becomes the issue title; the remainder is the body.
# Ensures each requested label exists (creates missing ones), then creates the
# issue assigned to the current user.
#
# Usage (run from anywhere inside the repo):
#   pwsh -NoProfile -ExecutionPolicy Bypass `
#     -File .github/skills/triage/scripts/new-issue.ps1 `
#     -Draft tmp/triage-issue.md -Label bug -Label tech-debt

param(
    [Parameter(Mandatory)][string]$Draft,    # path to draft md (first '# ' line = title)
    [Parameter(Mandatory)][string[]]$Label   # one or more category labels
)

$ErrorActionPreference = "Stop"

# Operate from the repo root so the temp body file lands in the repo's tmp/.
$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root

$existing = gh label list --json name --jq ".[].name"
foreach ($l in $Label) {
    if ($existing -notcontains $l) { gh label create "$l" --description "$l" --force | Out-Null }
}

$lines = Get-Content $Draft
$title = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# ', ''
$idx = ($lines | Select-String -Pattern '^# ' | Select-Object -First 1).LineNumber

New-Item -ItemType Directory -Force -Path "tmp" | Out-Null
$body = "tmp/triage-body-$([guid]::NewGuid().ToString()).md"
($lines[$idx..($lines.Count - 1)]) | Set-Content -Encoding utf8 $body

$labelArgs = @()
foreach ($l in $Label) { $labelArgs += @("--label", $l) }

$url = gh issue create --title "$title" --body-file "$body" @labelArgs --assignee "@me"
Remove-Item $body -ErrorAction SilentlyContinue

Write-Output "TITLE: $title"
Write-Output "URL: $url"
