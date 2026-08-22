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
      - unknown  : issues with no usable footprint - investigate before batching them

    Footprint patterns are expanded against the repository's tracked files (via git
    ls-files) so directory prefixes and globs resolve to concrete file sets before any
    overlap is measured. When the repo file list is unavailable the raw normalised pattern
    is used verbatim.

    The packer runs a greedy "least conflict first" pass seeded from every eligible
    candidate and keeps the best-scoring slot (largest, then lowest total internal overlap,
    then lowest seed issue for determinism). Each pass seeds with one candidate, then
    repeatedly adds the remaining candidate whose maximum pairwise overlap with the current
    slot is the lowest, stopping once that minimum overlap reaches -HighConflict or the slot
    is full.

.PARAMETER FootprintPath
    Path to a JSON file: an array of objects { issue, title, files:[...], global?:bool }.
    "files" are repo-relative paths, directory prefixes, or globs the issue is expected to
    change. "global":true forces the issue into the solo bucket regardless of footprint
    size. An entry with no usable "files" is routed to the unknown bucket, not batched.

.PARAMETER SlotSize
    Maximum number of issues to place in one slot. Must be positive.

.PARAMETER GlobalThreshold
    Expanded footprint size (file count) at or above which an issue is treated as "touches
    everything" and moved to the solo bucket. Must be positive.

.PARAMETER HighConflict
    Pairwise shared-file count at or above which two issues are considered too conflicting to
    share a slot. Defaults to 1, so any shared file excludes a pairing. Must be positive.

.PARAMETER RepoRoot
    Optional path to the repository root used to expand footprint globs with git ls-files.
    Defaults to the current directory's repo.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FootprintPath,
    [ValidateRange(1, [int]::MaxValue)][int]$SlotSize = 10,
    [ValidateRange(1, [int]::MaxValue)][int]$GlobalThreshold = 12,
    [ValidateRange(1, [int]::MaxValue)][int]$HighConflict = 1,
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $FootprintPath)) {
    throw "Footprint file not found: $FootprintPath"
}

$raw = Get-Content -Raw -Path $FootprintPath | ConvertFrom-Json
$raw = @($raw)
if ($raw.Count -eq 0) {
    throw "Footprint JSON must be a non-empty array of candidate issues."
}

# Best-effort tracked-file list so directory/glob footprints expand to concrete files.
$script:repoFiles = $null
try {
    $rootArg = if ($RepoRoot) { @("-C", $RepoRoot) } else { @() }
    $listed = & git @rootArg ls-files 2>$null
    if ($LASTEXITCODE -eq 0 -and $listed) {
        $script:repoFiles = @($listed | ForEach-Object { $_.Replace("\", "/").ToLowerInvariant() })
    }
} catch {
    $script:repoFiles = $null
}

function Expand-Pattern([string]$pat) {
    $p = $pat.Trim().Replace("\", "/").TrimStart("./").ToLowerInvariant()
    if (-not $p) { return @() }
    $trimmed = $p.TrimEnd("/")
    if ($null -eq $script:repoFiles) { return @($trimmed) }
    $like = if ($p.EndsWith("/")) { "$trimmed/*" } else { $p }
    $like = $like.Replace("**", "*")
    $hit = foreach ($f in $script:repoFiles) {
        if ($f -eq $trimmed -or $f.StartsWith("$trimmed/") -or $f -like $like) { $f }
    }
    $hit = @($hit | Sort-Object -Unique)
    if ($hit.Count -eq 0) { return @($trimmed) }   # stale/unmatched path: keep literal
    $hit
}

$seen = @{}
$items = foreach ($i in $raw) {
    if ($null -eq $i.issue) { throw "Every footprint entry needs an 'issue' number." }
    $num = 0
    if (-not [int]::TryParse([string]$i.issue, [ref]$num) -or $num -le 0) {
        throw "Issue numbers must be positive integers; got '$($i.issue)'."
    }
    if ($seen.ContainsKey($num)) { throw "Duplicate issue in footprint: #$num." }
    $seen[$num] = $true

    $rawFiles = @($i.files) | Where-Object { $_ -and $_.ToString().Trim() }
    $expanded = [System.Collections.Generic.List[string]]::new()
    foreach ($pat in $rawFiles) { Expand-Pattern $pat | ForEach-Object { $expanded.Add($_) } }
    $files = @($expanded | Sort-Object -Unique)

    [pscustomobject]@{
        Issue   = $num
        Title   = [string]$i.title
        Files   = [string[]]$files
        Count   = $files.Count
        Global  = [bool]$i.global
        Unknown = ($rawFiles.Count -eq 0)
    }
}

function Get-Overlap([string[]]$a, [string[]]$b) {
    if ($a.Count -eq 0 -or $b.Count -eq 0) { return 0 }
    $set = [System.Collections.Generic.HashSet[string]]::new([string[]]$a)
    ($b | Where-Object { $set.Contains($_) }).Count
}

function Get-TotalOverlap($slot) {
    $t = 0
    for ($x = 0; $x -lt $slot.Count; $x++) {
        for ($y = $x + 1; $y -lt $slot.Count; $y++) {
            $t += Get-Overlap $slot[$x].Files $slot[$y].Files
        }
    }
    $t
}

function Invoke-GreedyPack($pool, $seed) {
    $slot = [System.Collections.Generic.List[object]]::new()
    $rest = [System.Collections.Generic.List[object]]::new()
    foreach ($p in $pool) { if ($p.Issue -ne $seed.Issue) { $rest.Add($p) } }

    $seed | Add-Member -NotePropertyName SlotOverlap -NotePropertyValue 0 -Force
    $seed | Add-Member -NotePropertyName ConflictsWith -NotePropertyValue $null -Force
    $slot.Add($seed)

    while ($rest.Count -gt 0 -and $slot.Count -lt $SlotSize) {
        $best = $null; $bestOverlap = [int]::MaxValue; $bestWith = $null
        foreach ($cand in $rest) {
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
        $null = $rest.Remove($best)
    }
    , $slot
}

# Buckets. An explicit global flag always wins; otherwise a huge or unknown footprint routes
# out of the batchable pool rather than being treated as conflict-free.
$solo    = @($items | Where-Object { $_.Global -or (-not $_.Unknown -and $_.Count -ge $GlobalThreshold) })
$unknown = @($items | Where-Object { $_.Unknown -and -not $_.Global })
$pool    = @($items | Where-Object { -not $_.Global -and -not $_.Unknown -and $_.Count -lt $GlobalThreshold })

$slot = [System.Collections.Generic.List[object]]::new()
if ($pool.Count -gt 0) {
    $best = $null
    foreach ($seed in ($pool | Sort-Object Count, Issue)) {
        $candidateSlot = Invoke-GreedyPack $pool $seed
        $score = [pscustomobject]@{
            Count   = $candidateSlot.Count
            Overlap = (Get-TotalOverlap $candidateSlot)
            Seed    = $seed.Issue
            Slot    = $candidateSlot
        }
        $better = $null -eq $best -or
            $score.Count -gt $best.Count -or
            ($score.Count -eq $best.Count -and $score.Overlap -lt $best.Overlap) -or
            ($score.Count -eq $best.Count -and $score.Overlap -eq $best.Overlap -and $score.Seed -lt $best.Seed)
        if ($better) { $best = $score }
    }
    $slot = $best.Slot
}

$slotIssues = @($slot | ForEach-Object { $_.Issue })
$deferred = [System.Collections.Generic.List[object]]::new()
foreach ($cand in $pool) {
    if ($slotIssues -contains $cand.Issue) { continue }
    $maxOv = 0; $withIssue = $null
    foreach ($m in $slot) {
        $ov = Get-Overlap $cand.Files $m.Files
        if ($ov -gt $maxOv) { $maxOv = $ov; $withIssue = $m.Issue }
    }
    $reason = if ($slot.Count -ge $SlotSize) { "slot full" }
              elseif ($maxOv -ge $HighConflict) { "conflict too high ($maxOv shared with #$withIssue)" }
              else { "deferred (no capacity this pass)" }
    $deferred.Add([pscustomobject]@{
        issue = $cand.Issue; title = $cand.Title; overlap = $maxOv
        conflictsWith = $withIssue; reason = $reason
    })
}

$result = [pscustomobject]@{
    slot     = @($slot | ForEach-Object { [pscustomobject]@{
        issue = $_.Issue; title = $_.Title; files = $_.Count
        slotOverlap = ($_.SlotOverlap ?? 0); conflictsWith = $_.ConflictsWith } })
    deferred = @($deferred)
    solo     = @($solo | ForEach-Object { [pscustomobject]@{
        issue = $_.Issue; title = $_.Title; files = $_.Count
        reason = $(if ($_.Global) { "flagged global" } else { "footprint $($_.Count) >= $GlobalThreshold" }) } })
    unknown  = @($unknown | ForEach-Object { [pscustomobject]@{
        issue = $_.Issue; title = $_.Title
        reason = "no usable footprint - investigate before batching" } })
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
Write-Host "== Unknown footprint (investigate, do not batch yet) ==" -ForegroundColor Magenta
if ($result.unknown.Count -eq 0) { Write-Host "  (none)" }
foreach ($u in $result.unknown) { Write-Host ("  #{0}  {1}  -- {2}" -f $u.issue, $u.title, $u.reason) }
Write-Host ""
Write-Host "== JSON =="
$result | ConvertTo-Json -Depth 6
