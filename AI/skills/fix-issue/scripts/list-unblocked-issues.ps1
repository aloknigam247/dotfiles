<#
.SYNOPSIS
    Lists open issues that are NOT blocked by any still-open issue.

.DESCRIPTION
    Used by the "fix-issue" skill (Input / step 1 dependency pre-scan). An issue is treated as
    blocked when any of these point at an issue that is still open:
      - a native GitHub issue dependency (`blocked_by`),
      - a `blocked` / `blocked-by` / `on-hold` label,
      - body/comment text matching `blocked by #N`, `depends on #N`, or `Status: blocked`.

    Prints only the unblocked issues by default. Use -ShowBlocked to also list the blocked ones
    with the open blockers that gate them. Emits JSON with -Json for programmatic consumption.

.EXAMPLE
    pwsh -NoProfile -File list-unblocked-issues.ps1

.EXAMPLE
    pwsh -NoProfile -File list-unblocked-issues.ps1 -ShowBlocked -Limit 50
#>
[CmdletBinding()]
param(
    [int]$Limit = 30,
    [switch]$ShowBlocked,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found on PATH."
    exit 2
}

$repo = gh repo view --json nameWithOwner --jq .nameWithOwner
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace("$repo")) {
    Write-Error "Could not resolve the current repository (are you inside a gh-authenticated repo?)."
    exit 2
}

$apiVersion = "2026-03-10"

# Resolve an issue's state, caching lookups so a shared blocker is fetched once.
$stateCache = @{}
function Get-IssueState([int]$Number) {
    if ($stateCache.ContainsKey($Number)) { return $stateCache[$Number] }
    $state = gh api "repos/$repo/issues/$Number" --jq '.state' 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace("$state")) { $state = "unknown" }
    $stateCache[$Number] = $state
    return $state
}

$openIssues = gh issue list --state open --limit $Limit `
    --json number,title,labels,assignees,updatedAt,body | ConvertFrom-Json

$results = foreach ($issue in $openIssues) {
    $blockers = [System.Collections.Generic.List[int]]::new()

    # 1. Native GitHub issue dependencies.
    $nativeRaw = gh api -H "X-GitHub-Api-Version: $apiVersion" `
        "repos/$repo/issues/$($issue.number)/dependencies/blocked_by" --jq '.[].number' 2>$null
    if ($LASTEXITCODE -eq 0 -and $nativeRaw) {
        foreach ($n in $nativeRaw) { [void]$blockers.Add([int]$n) }
    }

    # 2. Label signals.
    $labelNames = @($issue.labels | ForEach-Object { $_.name.ToLower() })
    $hasBlockLabel = @($labelNames | Where-Object { $_ -in @("blocked", "blocked-by", "on-hold") }).Count -gt 0

    # 3. Body text signals: "blocked by #N", "depends on #N".
    if ($issue.body) {
        foreach ($m in [regex]::Matches($issue.body, '(?i)(?:blocked by|depends on)\s+#(\d+)')) {
            [void]$blockers.Add([int]$m.Groups[1].Value)
        }
    }
    $hasStatusBlocked = $issue.body -and ($issue.body -match '(?i)Status:\s*blocked')

    # Keep only blockers that are themselves still open.
    $openBlockers = @($blockers | Sort-Object -Unique | Where-Object { (Get-IssueState $_) -eq "open" })

    $isBlocked = ($openBlockers.Count -gt 0) -or $hasBlockLabel -or $hasStatusBlocked

    [PSCustomObject]@{
        number       = $issue.number
        title        = $issue.title
        labels       = $labelNames
        assignee     = if ($issue.assignees.Count -gt 0) { $issue.assignees[0].login } else { "unassigned" }
        updatedAt    = $issue.updatedAt
        blocked      = $isBlocked
        openBlockers = $openBlockers
        blockLabel   = $hasBlockLabel
        statusBlocked = [bool]$hasStatusBlocked
    }
}

$unblocked = @($results | Where-Object { -not $_.blocked } | Sort-Object updatedAt)
$blocked = @($results | Where-Object { $_.blocked } | Sort-Object number)

if ($Json) {
    if ($ShowBlocked) { $results | ConvertTo-Json -Depth 5 }
    else { $unblocked | ConvertTo-Json -Depth 5 }
    exit 0
}

Write-Host "Unblocked issues ($($unblocked.Count) of $($results.Count) open):`n"
foreach ($i in $unblocked) {
    $lbl = if ($i.labels.Count -gt 0) { "[" + ($i.labels -join ",") + "] " } else { "" }
    Write-Host ("  #{0,-4} {1}{2}  ({3})" -f $i.number, $lbl, $i.title, $i.assignee)
}

if ($ShowBlocked -and $blocked.Count -gt 0) {
    Write-Host "`nBlocked (excluded from auto-selection):`n"
    foreach ($i in $blocked) {
        $reasons = @()
        if ($i.openBlockers.Count -gt 0) { $reasons += "blocked by " + (($i.openBlockers | ForEach-Object { "#$_" }) -join ", ") }
        if ($i.blockLabel) { $reasons += "block label" }
        if ($i.statusBlocked) { $reasons += "Status: blocked" }
        Write-Host ("  #{0,-4} {1}  (⛔ {2})" -f $i.number, $i.title, ($reasons -join "; "))
    }
}

exit 0
