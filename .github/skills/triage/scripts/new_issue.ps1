# Creates a GitHub issue from a triage draft markdown file in one shot.
#
# The draft's first "# " heading becomes the issue title; the remainder is the body.
# Ensures each requested label exists (creates missing ones), then creates the
# issue assigned to the current user. Optionally adds native sub-issue and
# blocked-by links through the GitHub REST API (blocked-by / blocking / parent).
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

function Get-IssueId([int]$Number) {
    $id = gh api "repos/{owner}/{repo}/issues/$Number" --jq ".id"
    if ($LASTEXITCODE -ne 0 -or -not $id) { throw "Could not read the id of issue #$Number." }
    return [long]$id
}

function Add-NativeLink([string]$Path, [string]$Field, [long]$Id) {
    $out = gh api -X POST $Path -F "$Field=$Id" 2>&1
    if ($LASTEXITCODE -eq 0) { return }
    $listed = gh api --paginate $Path --jq ".[].id"
    if ($LASTEXITCODE -eq 0 -and @($listed) -contains "$Id") { return }
    throw "Could not link $Path ($Field=$Id) and the edge is not listed. Output: $out"
}

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

# Resolve every related issue first so a bad number fails before anything is created.
$blockerIds = @($BlockedBy | ForEach-Object { Get-IssueId $_ })
foreach ($n in $Blocking) { $null = Get-IssueId $n }
if ($Parent) { $null = Get-IssueId $Parent }

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

try {
    $url = gh issue create --title "$title" --body-file "$body" @labelArgs --assignee "@me"
    if ($LASTEXITCODE -ne 0 -or "$url" -notmatch "/issues/(\d+)\s*$") {
        throw "Issue creation failed or no URL. Check GitHub for partial creation before retrying. Output: $url"
    }
    $number = [int]$Matches[1]
} finally {
    Remove-Item $body -ErrorAction SilentlyContinue
}

Write-Output "TITLE: $title"
Write-Output "URL: $url"

$issues = "repos/{owner}/{repo}/issues"
$newId = Get-IssueId $number
if ($Parent) { Add-NativeLink "$issues/$Parent/sub_issues" "sub_issue_id" $newId }
foreach ($blockerId in $blockerIds) { Add-NativeLink "$issues/$number/dependencies/blocked_by" "issue_id" $blockerId }
foreach ($n in $Blocking) { Add-NativeLink "$issues/$n/dependencies/blocked_by" "issue_id" $newId }
