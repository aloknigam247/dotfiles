# Creates a GitHub issue from a triage draft markdown file in one shot.
#
# The draft's first "# " heading becomes the issue title; the remainder is the body.
# Ensures each requested label exists (creates missing ones), then creates the
# issue assigned to the current user. Optionally links related issues via the
# GitHub issue relationships (blocked-by / blocking / parent).
#
# Usage (run from anywhere inside the repo):
#   & .\.github\skills\triage\scripts\new_issue.ps1 `
#     -Complexity low -Draft tmp\triage-issue.md -Label bug,tech-debt `
#     -BlockedBy 12,15 -Blocking 20 -Parent 10

param(
    [Parameter(Mandatory)][ValidateSet("low", "medium", "high")][string]$Complexity,
    [Parameter(Mandatory)][string]$Draft,     # path to draft md (first '# ' line = title)
    [Parameter(Mandatory)][string[]]$Label,   # one or more category labels
    [int[]]$BlockedBy = @(),                  # issue numbers this new issue is blocked by
    [int[]]$Blocking = @(),                   # issue numbers this new issue blocks
    [ValidateRange(1, [int]::MaxValue)][int]$Parent
)

$ErrorActionPreference = "Stop"

$complexityLabel = "complexity: $($Complexity.ToLowerInvariant())"
$Label = @($Label | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($Label.Count -eq 0) { throw "At least one non-empty label is required." }
foreach ($l in $Label) {
    if ($l -match "^\s*complexity\s*:" -and $l -cne $complexityLabel) {
        throw "Label '$l' conflicts with -Complexity '$Complexity'; use '$complexityLabel'."
    }
}
$Label = @($Label | Where-Object { $_ -cne $complexityLabel }) + $complexityLabel

if ($Parent -and $Label -cnotcontains "sub-issue") { $Label += "sub-issue" }

# Operate from the repo root so the temp body file lands in the repo's tmp/.
$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root

$existing = gh label list --json name --jq ".[].name"
if ($LASTEXITCODE -ne 0) { throw "Could not list GitHub labels." }
foreach ($l in $Label) {
    if ($existing -cnotcontains $l) {
        gh label create "$l" --description "$l" --force | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Could not ensure GitHub label '$l'." }
    }
}

$lines = Get-Content $Draft
$title = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# ', ''
$idx = ($lines | Select-String -Pattern '^# ' | Select-Object -First 1).LineNumber

New-Item -ItemType Directory -Force -Path "tmp" | Out-Null
$body = "tmp/triage-body-$([guid]::NewGuid().ToString()).md"
($lines[$idx..($lines.Count - 1)]) | Set-Content -Encoding utf8 $body

$labelArgs = @()
foreach ($l in $Label) { $labelArgs += @("--label", $l) }

$relArgs = @()
if ($BlockedBy.Count) { $relArgs += @("--blocked-by", ($BlockedBy -join ",")) }
if ($Blocking.Count)  { $relArgs += @("--blocking", ($Blocking -join ",")) }
if ($Parent) { $relArgs += @("--parent", $Parent) }

try {
    $url = gh issue create --title "$title" --body-file "$body" @labelArgs @relArgs --assignee "@me"
    if ($LASTEXITCODE -ne 0 -or -not $url) {
        throw "Issue creation failed or no URL. Check GitHub for partial creation before retrying. Output: $url"
    }
} finally {
    Remove-Item $body -ErrorAction SilentlyContinue
}

Write-Output "TITLE: $title"
Write-Output "URL: $url"
