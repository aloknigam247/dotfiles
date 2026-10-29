<#
.SYNOPSIS
    Lists unblocked open issues without an open parent.

.DESCRIPTION
    Uses only native GitHub parent and blocked_by relationships. Closed parents and blockers
    do not exclude an issue. Labels and body text do not determine eligibility.
    Use -Json to emit a JSON array.

.EXAMPLE
    pwsh -NoProfile -File list_unblocked_issues.ps1

.EXAMPLE
    pwsh -NoProfile -File list_unblocked_issues.ps1 -Json
#>
[CmdletBinding()]
param(
    [switch]$Json
)

$env:GH_TOKEN = $null

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$apiVersion = "2026-03-10"
$ErrorActionPreference = "Stop"
$parentStates = @{}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found on PATH."
    exit 2
}

function Get-GitHubObjects([string]$Endpoint) {
    $json = gh api --paginate --slurp -H "X-GitHub-Api-Version: $apiVersion" $Endpoint
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub request failed: $Endpoint"
    }
    foreach ($page in ($json | ConvertFrom-Json)) {
        $page
    }
}

$repo = gh repo view --json nameWithOwner --jq .nameWithOwner
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace("$repo")) {
    Write-Error "Could not resolve the current repository (are you inside a gh-authenticated repo?)."
    exit 2
}

$openIssues = @(Get-GitHubObjects "repos/$repo/issues?state=open&per_page=100" |
    Where-Object { -not $_.pull_request })
$openIssueUrls = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($issue in $openIssues) {
    [void]$openIssueUrls.Add($issue.url)
}

$results = @(foreach ($issue in $openIssues) {
    $parentUrl = $issue.parent_issue_url
    if ($parentUrl) {
        if ($openIssueUrls.Contains($parentUrl)) { continue }
        if (-not $parentStates.ContainsKey($parentUrl)) {
            $parent = Get-GitHubObjects $parentUrl
            if ($parent.state -notin @("closed", "open")) {
                throw "GitHub returned an invalid parent state: $parentUrl"
            }
            $parentStates[$parentUrl] = $parent.state
        }
        if ($parentStates[$parentUrl] -eq "open") { continue }
    }

    $dependencies = @(Get-GitHubObjects "repos/$repo/issues/$($issue.number)/dependencies/blocked_by?per_page=100")
    foreach ($dependency in $dependencies) {
        if ($dependency.state -notin @("closed", "open")) {
            throw "GitHub returned an invalid blocker state for issue #$($issue.number)."
        }
    }
    if ($dependencies.state -contains "open") { continue }

    [PSCustomObject]@{
        number       = $issue.number
        title        = $issue.title
        labels       = @($issue.labels | ForEach-Object { $_.name.ToLower() })
        assignee     = if ($issue.assignees.Count -gt 0) { $issue.assignees[0].login } else { "unassigned" }
        updatedAt    = $issue.updated_at
        blocked      = $false
        openBlockers = @()
    }
})

$unblocked = @($results | Sort-Object updatedAt)

if ($Json) {
    ConvertTo-Json -InputObject $unblocked -Depth 5
    exit 0
}

Write-Host "Unblocked top-level issues ($($unblocked.Count)):`n"
foreach ($i in $unblocked) {
    $lbl = if ($i.labels.Count -gt 0) { "[" + ($i.labels -join ",") + "] " } else { "" }
    Write-Host ("  #{0,-4} {1}{2}  ({3})" -f $i.number, $lbl, $i.title, $i.assignee)
}

exit 0
