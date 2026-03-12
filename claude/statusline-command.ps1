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

# ── Single line: Model │ Project │ Branch │ Worktree │ Agent │ Cost │ Duration │ Lines │ Context ──

$parts = @()

if ($j.model.display_name) {
    $parts += "${blue}$iBolt $($j.model.display_name)${reset}"
}

if ($j.workspace.project_dir) {
    $dir = Split-Path -Leaf $j.workspace.project_dir
} elseif ($j.cwd) {
    $dir = Split-Path -Leaf $j.cwd
}
if ($dir) {
    $parts += "${cyan}$iFolder $dir${reset}"
}

try {
    $cwd = if ($j.workspace.current_dir) { $j.workspace.current_dir } else { $j.cwd }
    $branch = git -C $cwd branch --show-current 2>$null
    if ($branch) {
        $parts += "${green}$iBranch $branch${reset}"
    }
} catch {}

if ($j.worktree -and $j.worktree.name) {
    $parts += "${orange}$iTree $($j.worktree.name)${reset}"
}

if ($j.agent -and $j.agent.name) {
    $parts += "${magenta}$iRobot $($j.agent.name)${reset}"
}

if ($null -ne $j.cost.total_cost_usd) {
    $cost = [math]::Round($j.cost.total_cost_usd, 2)
    $parts += "${green}$iDollar $cost${reset}"
}

if ($null -ne $j.cost.total_duration_ms) {
    $ts = [timespan]::FromMilliseconds($j.cost.total_duration_ms)
    $hh = [math]::Floor($ts.TotalHours).ToString("00")
    $mm = $ts.Minutes.ToString("00")
    $parts += "${orange}$iClock ${hh}:${mm}${reset}"
}

if ($null -ne $j.cost.total_lines_added -or $null -ne $j.cost.total_lines_removed) {
    $added = if ($null -ne $j.cost.total_lines_added) { $j.cost.total_lines_added } else { 0 }
    $removed = if ($null -ne $j.cost.total_lines_removed) { $j.cost.total_lines_removed } else { 0 }
    $changed = $added + $removed
    $parts += "${green}$iPlus $added ${red}$iMinus $removed ${gray}$iDelta $changed${reset}"
}

if ($null -ne $j.context_window.used_percentage) {
    $pct = [int]$j.context_window.used_percentage
    $filled = [math]::Round($pct / 10)
    $empty = 10 - $filled
    $bar = "█" * $filled + "░" * $empty
    $barColor = if ($pct -ge 80) { $red } elseif ($pct -ge 50) { $orange } else { $teal }
    $parts += "${barColor}$bar ${pct}%${reset}"
}

# ── Responsive: split into two lines if terminal is too narrow ──
$line = $parts -join $sep

# Strip ANSI escape sequences to measure visible width
$visible = $line -replace "$e\[[0-9;]*m", ""
$cols = try { [Console]::WindowWidth } catch { 120 }

if ($visible.Length -gt $cols -and $parts.Count -ge 4) {
    $half = [math]::Ceiling($parts.Count / 2)
    $row1 = $parts[0..($half - 1)] -join $sep
    $row2 = $parts[$half..($parts.Count - 1)] -join $sep
    "$row1`n$row2"
} else {
    $line
}
