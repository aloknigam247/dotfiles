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
$sep     = " $gray│$reset "

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

# ── Line 1: Model │ Project │ Git Branch │ Worktree │ Agent ──

$line1 = @()

if ($j.model.display_name) {
    $line1 += "${blue}$iBolt $($j.model.display_name)${reset}"
}

if ($j.workspace.project_dir) {
    $dir = Split-Path -Leaf $j.workspace.project_dir
} elseif ($j.cwd) {
    $dir = Split-Path -Leaf $j.cwd
}
if ($dir) {
    $line1 += "${cyan}$iFolder $dir${reset}"
}

try {
    $cwd = if ($j.workspace.current_dir) { $j.workspace.current_dir } else { $j.cwd }
    $branch = git -C $cwd branch --show-current 2>$null
    if ($branch) {
        $line1 += "${green}$iBranch $branch${reset}"
    }
} catch {}

if ($j.worktree -and $j.worktree.name) {
    $line1 += "${orange}$iTree $($j.worktree.name)${reset}"
}

if ($j.agent -and $j.agent.name) {
    $line1 += "${magenta}$iRobot $($j.agent.name)${reset}"
}

# ── Line 2: Cost │ Duration │ Lines Changed │ Context Bar ──

$line2 = @()

if ($null -ne $j.cost.total_cost_usd) {
    $cost = [math]::Round($j.cost.total_cost_usd, 2)
    $line2 += "${green}$iDollar $cost${reset}"
}

if ($null -ne $j.cost.total_duration_ms) {
    $ts = [timespan]::FromMilliseconds($j.cost.total_duration_ms)
    $hh = [math]::Floor($ts.TotalHours).ToString("00")
    $mm = $ts.Minutes.ToString("00")
    $line2 += "${orange}$iClock ${hh}:${mm}${reset}"
}

if ($null -ne $j.cost.total_lines_added -or $null -ne $j.cost.total_lines_removed) {
    $added = if ($null -ne $j.cost.total_lines_added) { $j.cost.total_lines_added } else { 0 }
    $removed = if ($null -ne $j.cost.total_lines_removed) { $j.cost.total_lines_removed } else { 0 }
    $changed = $added + $removed
    $line2 += "${green}$iPlus $added ${red}$iMinus $removed ${gray}$iDelta $changed${reset}"
}

if ($null -ne $j.context_window.used_percentage) {
    $pct = [int]$j.context_window.used_percentage
    $filled = [math]::Round($pct / 10)
    $empty = 10 - $filled
    $bar = "█" * $filled + "░" * $empty
    $barColor = if ($pct -ge 80) { $red } elseif ($pct -ge 50) { $orange } else { $teal }
    $line2 += "${barColor}$bar ${pct}%${reset}"
}

$out = ($line1 -join $sep)
if ($line2.Count -gt 0) {
    $out += "`n" + ($line2 -join $sep)
}
$out
