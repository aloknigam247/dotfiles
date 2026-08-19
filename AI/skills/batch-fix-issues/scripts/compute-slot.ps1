#Requires -Version 7
<#
.SYNOPSIS
    Groups candidate issues into a low-conflict batch "slot" from their file footprints.

.DESCRIPTION
    Reads a JSON array of candidate issues, each with the set of files it is expected to
    touch, and partitions them into:
      - slot     : issues packed into the current slot, chosen to minimise cross-conflict
      - deferred : issues whose overlap with a slot member is too high for this slot
      - solo     : issues that touch so much they must never share a slot (run alone)

    The greedy packer seeds the slot with the smallest footprint, then repeatedly adds the
    remaining candidate whose maximum pairwise overlap with the current slot is the lowest
    ("least conflict first"). It stops adding once that minimum overlap reaches
    -HighConflict (conflicts too high to batch) or the slot is full.

.PARAMETER FootprintPath
    Path to a JSON file: an array of objects { issue, title, files:[...], global?:bool }.
    "files" are repo-relative paths (or glob-ish path prefixes) the issue is expected to change.
    "global":true forces the issue into the solo bucket regardless of footprint size.

.PARAMETER SlotSize
    Maximum number of issues to place in one slot.

.PARAMETER GlobalThreshold
    Footprint size (file count) at or above which an issue is treated as "touches everything"
    and moved to the solo bucket.

.PARAMETER HighConflict
    Pairwise shared-file count at or above which two issues are considered too conflicting to
    share a slot.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FootprintPath,
    [int]$SlotSize = 4,
    [int]$GlobalThreshold = 12,
    [int]$HighConflict = 4
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $FootprintPath)) {
    throw "Footprint file not found: $FootprintPath"
}

$raw = Get-Content -Raw -Path $FootprintPath | ConvertFrom-Json

function Get-NormFiles([object]$issue) {
    $files = @($issue.files) | Where-Object { $_ } | ForEach-Object {
        $_.ToString().Trim().Replace("\", "/").TrimStart("./").ToLowerInvariant()
    }
    , ([string[]]($files | Sort-Object -Unique))
}

$items = foreach ($i in $raw) {
    $f = Get-NormFiles $i
    [pscustomobject]@{
        Issue  = [int]$i.issue
        Title  = [string]$i.title
        Files  = $f
        Count  = $f.Count
        Global = [bool]$i.global
    }
}

function Get-Overlap([string[]]$a, [string[]]$b) {
    if ($a.Count -eq 0 -or $b.Count -eq 0) { return 0 }
    $set = [System.Collections.Generic.HashSet[string]]::new([string[]]$a)
    ($b | Where-Object { $set.Contains($_) }).Count
}

# solo: touches everything (explicit flag or footprint >= threshold)
$solo = @($items | Where-Object { $_.Global -or $_.Count -ge $GlobalThreshold })
$pool = [System.Collections.Generic.List[object]]::new()
$items | Where-Object { -not ($_.Global -or $_.Count -ge $GlobalThreshold) } |
    Sort-Object Count, Issue | ForEach-Object { $pool.Add($_) }

$slot = [System.Collections.Generic.List[object]]::new()
$deferred = [System.Collections.Generic.List[object]]::new()

if ($pool.Count -gt 0) {
    $slot.Add($pool[0]); $pool.RemoveAt(0)
}

while ($pool.Count -gt 0 -and $slot.Count -lt $SlotSize) {
    $best = $null; $bestOverlap = [int]::MaxValue; $bestWith = $null
    foreach ($cand in $pool) {
        $maxOv = 0; $withIssue = $null
        foreach ($m in $slot) {
            $ov = Get-Overlap $cand.Files $m.Files
            if ($ov -gt $maxOv) { $maxOv = $ov; $withIssue = $m.Issue }
        }
        if ($maxOv -lt $bestOverlap) { $bestOverlap = $maxOv; $best = $cand; $bestWith = $withIssue }
    }
    if ($bestOverlap -ge $HighConflict) { break }   # least conflict is still too high -> stop
    $best | Add-Member -NotePropertyName SlotOverlap -NotePropertyValue $bestOverlap -Force
    $best | Add-Member -NotePropertyName ConflictsWith -NotePropertyValue $bestWith -Force
    $slot.Add($best)
    $null = $pool.Remove($best)
}

# whatever is left in the pool is deferred (too conflicting for this slot, or slot full)
foreach ($cand in $pool) {
    $maxOv = 0; $withIssue = $null
    foreach ($m in $slot) {
        $ov = Get-Overlap $cand.Files $m.Files
        if ($ov -gt $maxOv) { $maxOv = $ov; $withIssue = $m.Issue }
    }
    $reason = if ($slot.Count -ge $SlotSize) { "slot full" }
              elseif ($maxOv -ge $HighConflict) { "conflict too high ($maxOv shared with #$withIssue)" }
              else { "deferred" }
    $deferred.Add([pscustomobject]@{ issue = $cand.Issue; title = $cand.Title; overlap = $maxOv; conflictsWith = $withIssue; reason = $reason })
}

$result = [pscustomobject]@{
    slot     = @($slot     | ForEach-Object { [pscustomobject]@{ issue = $_.Issue; title = $_.Title; files = $_.Count; slotOverlap = ($_.SlotOverlap ?? 0); conflictsWith = $_.ConflictsWith } })
    deferred = @($deferred)
    solo     = @($solo     | ForEach-Object { [pscustomobject]@{ issue = $_.Issue; title = $_.Title; files = $_.Count; reason = $(if ($_.Global) { "flagged global" } else { "footprint $($_.Count) >= $GlobalThreshold" }) } })
}

Write-Host "== Proposed slot (batch together) ==" -ForegroundColor Green
if ($result.slot.Count -eq 0) { Write-Host "  (none)" }
foreach ($s in $result.slot) {
    $c = if ($s.slotOverlap -gt 0) { " (overlap $($s.slotOverlap) with #$($s.conflictsWith))" } else { " (no conflict)" }
    Write-Host ("  [ ] #{0}  {1}{2}" -f $s.issue, $s.title, $c)
}
Write-Host ""
Write-Host "== Deferred to a later slot ==" -ForegroundColor Yellow
if ($result.deferred.Count -eq 0) { Write-Host "  (none)" }
foreach ($d in $result.deferred) { Write-Host ("  #{0}  {1}  -- {2}" -f $d.issue, $d.title, $d.reason) }
Write-Host ""
Write-Host "== Solo (do not batch - touches everything) ==" -ForegroundColor Red
if ($result.solo.Count -eq 0) { Write-Host "  (none)" }
foreach ($o in $result.solo) { Write-Host ("  #{0}  {1}  -- {2}" -f $o.issue, $o.title, $o.reason) }
Write-Host ""
Write-Host "== JSON =="
$result | ConvertTo-Json -Depth 6
