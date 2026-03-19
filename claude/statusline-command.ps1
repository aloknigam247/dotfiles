[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$j = ($input | Out-String) | ConvertFrom-Json

$e = [char]27

# Colors chosen for contrast on #FDF6E3 (solarized light) background
$blue    = "$e[38;5;33m"
$green   = "$e[38;5;28m"
$red     = "$e[38;5;160m"
$magenta = "$e[38;5;127m"
$cyan    = "$e[38;5;30m"
$orange  = "$e[38;5;166m"
$gray    = "$e[38;5;240m"
$teal    = "$e[38;5;37m"
$reset   = "$e[0m"
$sep     = " $gray·$reset "

# Nerd Font icons
$iBolt   = ""
$iFolder = ""
$iBranch = ""
$iTree   = ""
$iRobot  = "󰚩"
$iDollar = ""
$iClock  = "󰥔"
$iPlus   = ""
$iMinus  = ""
$iDelta  = ""

# ── Two rows: top (identity + key metrics), bottom (stats) ──

$top = @()
$bottom = @()

# Top: Model, Project, Branch, Worktree, Agent, Cost, Context
if ($j.model.display_name) {
    $top += "${blue}$iBolt $($j.model.display_name)${reset}"
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
        $top += "${green}$iBranch $branch${reset}"
    }
} catch {}

if ($null -ne $j.cost.total_cost_usd) {
    $cost = [math]::Round($j.cost.total_cost_usd, 2)
    $top += "${green}$iDollar $cost${reset}"
}

if ($null -ne $j.context_window.used_percentage) {
    $pct = [int]$j.context_window.used_percentage
    $filled = [math]::Round($pct / 10)
    $empty = 10 - $filled
    $bar = "█" * $filled + "░" * $empty
    $barColor = if ($pct -ge 80) { $red } elseif ($pct -ge 50) { $orange } else { $teal }
    $top += "${barColor}$bar ${pct}%${reset}"
}

# Bottom: Agent, Worktree, Duration, Lines changed
if ($j.agent -and $j.agent.name) {
    $bottom += "${magenta}$iRobot $($j.agent.name)${reset}"
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

if ($null -ne $j.cost.total_lines_added -or $null -ne $j.cost.total_lines_removed) {
    $added = if ($null -ne $j.cost.total_lines_added) { $j.cost.total_lines_added } else { 0 }
    $removed = if ($null -ne $j.cost.total_lines_removed) { $j.cost.total_lines_removed } else { 0 }
    $changed = $added + $removed
    $bottom += "${green}$iPlus $added ${red}$iMinus $removed ${gray}$iDelta $changed${reset}"
}

# ── Output ──
$output = ($top -join $sep)
if ($bottom.Count -gt 0) {
    $output += "`n" + ($bottom -join $sep)
}
$output
