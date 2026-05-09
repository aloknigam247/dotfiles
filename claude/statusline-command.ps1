[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Read stdin via .NET to skip the PowerShell pipeline + Out-String formatter pass.
$j = [Console]::In.ReadToEnd() | ConvertFrom-Json

$e = [char]27

# Per-theme truecolor palette. Light uses Solarized's saturated accents; dark uses
# ~55% luminance variants so pills don't scream on the dark terminal bg.
$themes = @{
    light = @{
        blue    = "#268BD2"   # Solarized blue
        cyan    = "#2AA198"   # Solarized cyan
        gray    = "#586E75"   # Solarized base01
        green   = "#859900"   # Solarized green
        magenta = "#D33682"   # Solarized magenta
        orange  = "#CB4B16"   # Solarized orange
        red     = "#DC322F"   # Solarized red
        text    = "#FDF6E3"   # Solarized base3 — pill foreground
        violet  = "#6C71C4"   # Solarized violet
        yellow  = "#B58900"   # Solarized yellow
    }
    dark = @{
        blue    = "#1B6193"   # Solarized blue    @ 70% luminance
        cyan    = "#1D716A"   # Solarized cyan    @ 70%
        gray    = "#586E75"   # Solarized base01  (already a dark gray)
        green   = "#5D6B00"   # Solarized green   @ 70%
        magenta = "#94265B"   # Solarized magenta @ 70%
        orange  = "#8E340F"   # Solarized orange  @ 70%
        red     = "#9A2321"   # Solarized red     @ 70%
        text    = "#FDF6E3"   # Solarized base3 — pill foreground
        violet  = "#4C4F89"   # Solarized violet  @ 70%
        yellow  = "#7F6000"   # Solarized yellow  @ 70%
    }
}
$c = $themes[$(if ($env:THEME -eq "dark") { "dark" } else { "light" })]

$reset = "$e[0m"
$bold  = "$e[1m"

# Nerd Font icons
$iBolt    = ""
$iBranch  = ""
$iCapL    = "`u{E0B6}"
$iCapR    = "`u{E0B4}"
$iClock   = "󰥔"
$iDirty   = ""
$iDollar  = ""
$iFolder  = ""
$iInr     = "₹"
$iRobot   = "󰚩"
$iSession = "󰍹"
$iTree    = ""

function Hex2Ansi([string]$hex, [int]$layer) {
    $r = [convert]::ToInt32($hex.Substring(1, 2), 16)
    $g = [convert]::ToInt32($hex.Substring(3, 2), 16)
    $b = [convert]::ToInt32($hex.Substring(5, 2), 16)
    return "$e[$layer;2;$r;$g;${b}m"
}

$textFg = Hex2Ansi $c.text 38

function Pill([string]$text, [string]$hex) {
    $fg = Hex2Ansi $hex 38
    $bg = Hex2Ansi $hex 48
    return "${fg}${iCapL}${bg}${textFg}${bold}${text}${reset}${fg}${iCapR}${reset}"
}

# ── Two rows: top (identity + key metrics), bottom (stats) ──

$top = @()
$bottom = @()

# Top: Model, Project, Branch, Worktree, Agent, Cost, Context
if ($j.model.display_name) {
    $top += Pill "$iBolt $($j.model.display_name)" $c.blue
}

if ($j.workspace.project_dir) {
    $dir = [IO.Path]::GetFileName($j.workspace.project_dir)
} elseif ($j.cwd) {
    $dir = [IO.Path]::GetFileName($j.cwd)
}
if ($dir) {
    $plus = if ($j.workspace.added_dirs -and $j.workspace.added_dirs.Count -gt 0) { " +" } else { "" }
    $top += Pill "$iFolder $dir$plus" $c.cyan
}

try {
    $cwd = if ($j.workspace.current_dir) { $j.workspace.current_dir } else { $j.cwd }
    # One `git status --porcelain --branch` returns branch + dirty in a single
    # subprocess. Replaces two separate `git` spawns (`branch --show-current` +
    # `status --porcelain`); each git.exe spawn on Windows is ~15-80ms so this
    # halves git overhead per refresh. First line is "## branch...upstream/...";
    # any subsequent line means the worktree is dirty.
    $lines = @(git -C $cwd status --porcelain=v1 --branch 2>$null)
    if ($lines.Count -gt 0) {
        $head = ($lines[0] -split "\.\.\.", 2)[0]   # strip "...upstream/branch" suffix
        if ($head -match "^## (.+)$") {
            $branch = $Matches[1] -replace "^user/aloknigam/", "~/"
            $dirtyMark = if ($lines.Count -gt 1) { " $iDirty" } else { "" }
            $top += Pill "$iBranch $branch$dirtyMark" $c.green
        }
    }
} catch {}

# Bottom: Agent, Worktree, Duration, Cost, Context, Session
if ($j.agent -and $j.agent.name) {
    $bottom += Pill "$iRobot $($j.agent.name)" $c.magenta
}

if ($j.worktree -and $j.worktree.name) {
    $bottom += Pill "$iTree $($j.worktree.name)" $c.orange
}

if ($null -ne $j.cost.total_duration_ms) {
    $ts = [timespan]::FromMilliseconds($j.cost.total_duration_ms)
    $hh = [math]::Floor($ts.TotalHours).ToString("00")
    $mm = $ts.Minutes.ToString("00")
    $bottom += Pill "$iClock ${hh}:${mm}" $c.orange
}

if ($null -ne $j.cost.total_cost_usd) {
    $cost = [math]::Round($j.cost.total_cost_usd, 2)
    $inrRate = $null
    $cachePath = "$env:TEMP\usdinr_rate.json"

    # Always read the cache first (use stale value as fallback). [IO.File] is
    # leaner than Get-Content/Get-Item for this hot path.
    if ([IO.File]::Exists($cachePath)) {
        try { $inrRate = ([IO.File]::ReadAllText($cachePath) | ConvertFrom-Json).rate } catch {}
        $stale = ((Get-Date) - [IO.File]::GetLastWriteTime($cachePath)).TotalDays -ge 1
    } else {
        $stale = $true
    }

    # On stale cache, refresh with a 1s timeout — render must NOT block on the
    # network. If the request fails we silently keep the stale rate from above.
    if ($stale) {
        try {
            $resp = Invoke-RestMethod -Uri "https://open.er-api.com/v6/latest/USD" -TimeoutSec 1
            $inrRate = [math]::Round($resp.rates.INR, 1)
            @{ rate = $inrRate } | ConvertTo-Json | Set-Content $cachePath -Encoding UTF8
        } catch {}
    }
    if ($null -ne $inrRate) {
        $inrCost = [int]($cost * $inrRate)
        $bottom += Pill "$iDollar$cost / $iInr$inrCost" $c.yellow
    } else {
        $bottom += Pill "$iDollar$cost" $c.yellow
    }
}

if ($j.session_id) {
    $bottom += Pill "$iSession $($j.session_id)" $c.gray
}

if ($null -ne $j.context_window.used_percentage) {
    $pct = [int]$j.context_window.used_percentage
    $filled = [math]::Round($pct / 5)
    $empty = 20 - $filled
    $bar = "`u{2593}" * $filled + "`u{2591}" * $empty
    $barColor = if ($pct -ge 80) { $c.red } elseif ($pct -ge 50) { $c.yellow } else { $c.violet }
    $top += Pill "$bar ${pct}%" $barColor
}

# ── Output ──
$output = ($top -join " ")
if ($bottom.Count -gt 0) {
    $output += "`n" + ($bottom -join " ")
}
$output
