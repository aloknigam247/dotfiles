<#
.SYNOPSIS
    Lists open leaf issues without open blockers.

.DESCRIPTION
    Uses GitHub's blocked-issue search filter and native sub_issues relationships. Having a parent is allowed.
    Closed sub-issues and blockers do not exclude an issue. Labels and body text do not determine eligibility.
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
$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found on PATH."
    exit 2
}

function Get-UnblockedCandidates([string]$Repository) {
    $query = @'
query($q: String!, $endCursor: String) {
  search(type: ISSUE_ADVANCED, query: $q, first: 100, after: $endCursor) {
    pageInfo { hasNextPage endCursor }
    issueCount
    nodes {
      ... on Issue {
        number
        title
        labels(first: 100) { nodes { name } }
        assignees(first: 1) { nodes { login } }
        updatedAt
        subIssues(first: 100) {
          totalCount
          nodes { state }
        }
      }
    }
  }
}
'@
    $search = "repo:$Repository is:issue is:open -is:blocked"
    $json = gh api graphql --paginate --slurp -f query=$query -f q=$search
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub search failed: $search"
    }

    $issues = [System.Collections.Generic.List[object]]::new()
    $expectedCount = $null
    $retrievedCount = 0
    foreach ($page in ($json | ConvertFrom-Json)) {
        if ($page.errors) {
            throw "GitHub search returned GraphQL errors: $($page.errors.message -join '; ')"
        }
        $expectedCount = $page.data.search.issueCount
        foreach ($issue in $page.data.search.nodes) {
            $retrievedCount++
            if ($issue.subIssues.totalCount -gt 100) {
                throw "Issue #$($issue.number) has more than 100 sub-issues; eligibility is unknown."
            }
            if ($issue.labels.totalCount -gt 100) {
                throw "Issue #$($issue.number) has more than 100 labels; results are incomplete."
            }
            if (-not ($issue.subIssues.nodes | Where-Object state -eq "OPEN")) {
                $issues.Add($issue)
            }
        }
    }
    if ($retrievedCount -ne $expectedCount) {
        throw "GitHub search returned $retrievedCount of $expectedCount issues; eligibility is incomplete."
    }
    $issues.ToArray()
}

$repo = gh repo view --json nameWithOwner --jq .nameWithOwner
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace("$repo")) {
    Write-Error "Could not resolve the current repository (are you inside a gh-authenticated repo?)."
    exit 2
}

$results = @(foreach ($issue in (Get-UnblockedCandidates $repo)) {
    [PSCustomObject]@{
        number       = $issue.number
        title        = $issue.title
        labels       = @($issue.labels.nodes | ForEach-Object { $_.name.ToLower() })
        assignee     = if ($issue.assignees.nodes.Count -gt 0) { $issue.assignees.nodes[0].login } else { "unassigned" }
        updatedAt    = $issue.updatedAt
        blocked      = $false
        openBlockers = @()
    }
})

$unblocked = @($results | Sort-Object updatedAt)

if ($Json) {
    ConvertTo-Json -InputObject $unblocked -Depth 5
    exit 0
}

Write-Host "Unblocked leaf issues ($($unblocked.Count)):`n"
foreach ($i in $unblocked) {
    $lbl = if ($i.labels.Count -gt 0) { "[" + ($i.labels -join ",") + "] " } else { "" }
    Write-Host ("  #{0,-4} {1}{2}  ({3})" -f $i.number, $lbl, $i.title, $i.assignee)
}

exit 0
