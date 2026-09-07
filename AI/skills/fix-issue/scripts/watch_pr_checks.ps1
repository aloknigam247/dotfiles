<#
.SYNOPSIS
    Polls the GitHub checks for the current branch's PR until they conclude, then dumps
    the logs of any failing job.

.DESCRIPTION
    Used by the "fix-issue" skill (step 7). Exits 0 when all checks pass, 1 when one or
    more checks fail (after printing their logs), and 2 on timeout or setup error.
#>
[CmdletBinding()]
param(
    [int]$IntervalSeconds = 20,
    [int]$TimeoutMinutes = 45,
    [int]$LogLines = 120
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found on PATH."
    exit 2
}

$prJson = gh pr view --json number,url,headRefName,state 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "No PR found for the current branch:`n$prJson"
    exit 2
}
$pr = $prJson | ConvertFrom-Json
Write-Host "Watching checks for PR #$($pr.number) ($($pr.headRefName)) -> $($pr.url)"

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$checks = $null

while ((Get-Date) -lt $deadline) {
    $raw = gh pr checks $pr.number --json name,state,bucket,link 2>&1
    if ($LASTEXITCODE -ne 0 -and "$raw" -match "no checks reported") {
        Write-Host "No checks reported yet; waiting..."
        Start-Sleep -Seconds $IntervalSeconds
        continue
    }
    if ($LASTEXITCODE -ne 0 -and -not ("$raw".TrimStart().StartsWith("["))) {
        Write-Host "gh pr checks error: $raw"
        Start-Sleep -Seconds $IntervalSeconds
        continue
    }

    $checks = $raw | ConvertFrom-Json
    $pending = @($checks | Where-Object { $_.bucket -eq "pending" })

    $summary = ($checks | ForEach-Object { "  [{0,-8}] {1}" -f $_.bucket, $_.name }) -join "`n"
    Write-Host "`n$(Get-Date -Format 'HH:mm:ss') - $($checks.Count) check(s), $($pending.Count) pending"
    Write-Host $summary

    if ($pending.Count -eq 0) { break }
    Start-Sleep -Seconds $IntervalSeconds
}

if ($null -eq $checks) {
    Write-Host "Timed out before any checks were reported."
    exit 2
}
if (@($checks | Where-Object { $_.bucket -eq "pending" }).Count -gt 0) {
    Write-Host "Timed out after $TimeoutMinutes minute(s) with checks still pending."
    exit 2
}

$failed = @($checks | Where-Object { $_.bucket -in @("fail", "cancel") })
if ($failed.Count -eq 0) {
    Write-Host "`nAll checks passed."
    exit 0
}

Write-Host "`n$($failed.Count) failing check(s):"
foreach ($f in $failed) {
    Write-Host "`n===== $($f.name) [$($f.bucket)] ====="
    Write-Host $f.link

    $runId = $null
    if ($f.link -match "/runs/(\d+)") { $runId = $Matches[1] }
    if (-not $runId) {
        Write-Host "(no workflow run id in link; open the URL above)"
        continue
    }

    $log = gh run view $runId --log-failed 2>&1
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace("$log")) {
        # --log dumps the whole run; cap it so a megabyte log doesn't blow up context.
        $log = gh run view $runId --log 2>&1 | Select-Object -Last ($LogLines * 2)
    }
    $lines = "$log" -split "`r?`n"
    if ($lines.Count -gt $LogLines) {
        Write-Host "(showing last $LogLines of $($lines.Count) log lines)"
        $lines = $lines[-$LogLines..-1]
    }
    $lines | ForEach-Object { Write-Host $_ }
}

exit 1
