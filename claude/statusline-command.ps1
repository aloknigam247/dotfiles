[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$j = ($input | Out-String) | ConvertFrom-Json

$e = [char]27

# Colors chosen for contrast on #FDF6E3 (solarized light) background
$blue    = "$e[38;5;33m"
$cyan    = "$e[38;5;30m"
$gray    = "$e[38;5;240m"
$green   = "$e[38;5;28m"
$magenta = "$e[38;5;127m"
$orange  = "$e[38;5;166m"
$red     = "$e[38;5;160m"
$reset   = "$e[0m"
$bold    = "$e[1m"
$italic  = "$e[3m"
$sep     = " $gray·$reset "
$teal    = "$e[38;5;37m"
$yellow  = "$e[38;5;136m"

# Nerd Font icons
$iBolt    = ""
$iBranch  = ""
$iClock   = "󰥔"
$iDelta   = ""
$iDollar  = ""
$iFolder  = ""
$iInr     = "₹"
$iMinus   = ""
$iPlus    = ""
$iRobot   = "󰚩"
$iSession = "󰍹"
$iTree    = ""

# ── Two rows: top (identity + key metrics), bottom (stats) ──

$top = @()
$bottom = @()

# Top: Model, Project, Branch, Worktree, Agent, Cost, Context
if ($j.model.display_name) {
    $top += "${bold}${blue}$iBolt $($j.model.display_name)${reset}"
}

if ($j.workspace.project_dir) {
    $dir = Split-Path -Leaf $j.workspace.project_dir
} elseif ($j.cwd) {
    $dir = Split-Path -Leaf $j.cwd
}
if ($dir) {
    $top += "${cyan}$iFolder $dir${reset}"
}

try {
    $cwd = if ($j.workspace.current_dir) { $j.workspace.current_dir } else { $j.cwd }
    $branch = git -C $cwd branch --show-current 2>$null
    if ($branch) {
        $branch = $branch -replace "^user/aloknigam/", "~/"
        $top += "${green}$iBranch $branch${reset}"
    }
} catch {}

if ($null -ne $j.cost.total_lines_added -or $null -ne $j.cost.total_lines_removed) {
    $added = if ($null -ne $j.cost.total_lines_added) { $j.cost.total_lines_added } else { 0 }
    $removed = if ($null -ne $j.cost.total_lines_removed) { $j.cost.total_lines_removed } else { 0 }
    $changed = $added + $removed
    $top += "${green}$iPlus $added ${red}$iMinus $removed ${gray}$iDelta $changed${reset}"
}

# Bottom: Agent, Worktree, Duration, Cost, Context, Session
if ($j.agent -and $j.agent.name) {
    $bottom += "${bold}${magenta}$iRobot $($j.agent.name)${reset}"
}

if ($j.worktree -and $j.worktree.name) {
    $bottom += "${orange}$iTree $($j.worktree.name)${reset}"
}

if ($null -ne $j.cost.total_duration_ms) {
    $ts = [timespan]::FromMilliseconds($j.cost.total_duration_ms)
    $hh = [math]::Floor($ts.TotalHours).ToString("00")
    $mm = $ts.Minutes.ToString("00")
    $bottom += "${orange}$iClock ${hh}:${mm}${reset}"
}

if ($null -ne $j.cost.total_cost_usd) {
    $cost = [math]::Round($j.cost.total_cost_usd, 2)
    $inrRate = $null
    $cachePath = "$env:TEMP/usdinr_rate.json"
    if (Test-Path $cachePath) {
        $cacheAge = (Get-Date) - (Get-Item $cachePath).LastWriteTime
        if ($cacheAge.TotalDays -lt 1) {
            try { $inrRate = (Get-Content $cachePath -Raw | ConvertFrom-Json).rate } catch {}
        }
    }
    if ($null -eq $inrRate) {
        try {
            $resp = Invoke-RestMethod -Uri "https://open.er-api.com/v6/latest/USD" -TimeoutSec 5
            $inrRate = [math]::Round($resp.rates.INR, 1)
            @{ rate = $inrRate } | ConvertTo-Json | Set-Content $cachePath -Encoding UTF8
        } catch {}
    }
    if ($null -ne $inrRate) {
        $inrCost = [int]($cost * $inrRate)
        $bottom += "${green}$iDollar${cost}${reset}${gray}/${reset}${teal}${iInr}${inrCost}${reset}"
    } else {
        $bottom += "${green}$iDollar$cost${reset}"
    }
}

if ($j.session_id) {
    $bottom += "${italic}${gray}$iSession $($j.session_id)${reset}"
}

if ($null -ne $j.context_window.used_percentage) {
    $pct = [int]$j.context_window.used_percentage
    $filled = [math]::Round($pct / 5)
    $empty = 20 - $filled
    $bar = "`u{2588}" * $filled + "`u{2591}" * $empty
    $barColor = if ($pct -ge 80) { $red } elseif ($pct -ge 50) { $orange } else { $teal }
    $bottom += "${barColor}$bar ${pct}%${reset}"
}

# ── Output ──
$output = ($top -join $sep)
if ($bottom.Count -gt 0) {
    $output += "`n" + ($bottom -join $sep)
}
$output
