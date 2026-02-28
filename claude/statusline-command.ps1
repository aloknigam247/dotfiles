$j = ($input | Out-String) | ConvertFrom-Json

$parts = @()

$parts += $j.model.display_name

if ($j.agent -and $j.agent.name) {
    $parts += "[agent: $($j.agent.name)]"
}

try {
    $gitBranch = git -C $j.cwd branch --show-current 2>$null
    if ($gitBranch) {
        $parts += "git:$gitBranch"
    }
} catch {}

if ($j.cwd) {
    $parts += Split-Path -Leaf $j.cwd
}

if ($null -ne $j.context_window.used_percentage) {
    $parts += "ctx:$($j.context_window.used_percentage)%"
}

$parts -join " | "
