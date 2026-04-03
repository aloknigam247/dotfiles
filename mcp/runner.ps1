param(
    [Parameter(Mandatory)][string]$CommandFile,
    [Parameter(Mandatory)][string]$StdoutFile,
    [Parameter(Mandatory)][string]$StderrFile,
    [Parameter(Mandatory)][string]$SentinelFile,
    [string]$WorkingDirectory
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Command = Get-Content -Path $CommandFile -Raw -Encoding UTF8

# Set working directory if provided
if ($WorkingDirectory -and (Test-Path $WorkingDirectory)) {
    Set-Location $WorkingDirectory
}

# Reset so we only capture exit codes from the actual command
$global:LASTEXITCODE = 0

function New-SharedWriter([string]$Path) {
    $stream = [System.IO.FileStream]::new(
        $Path,
        [System.IO.FileMode]::Create,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::ReadWrite
    )
    $writer = [System.IO.StreamWriter]::new($stream, [System.Text.UTF8Encoding]::new($false))
    $writer.AutoFlush = $true
    return $writer
}

$outWriter = New-SharedWriter $StdoutFile
$errWriter = New-SharedWriter $StderrFile

# Command header
Write-Host ""
Write-Host "  $Command" -ForegroundColor Cyan
Write-Host ("  " + ([string][char]0x2500) * 60) -ForegroundColor DarkGray
Write-Host ""

# Execute command — separate stdout and stderr streams
$script:hasErrors = $false
try {
    $sb = [scriptblock]::Create($Command)
    & $sb 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            $script:hasErrors = $true
            $line = $_.ToString()
            Write-Host $line -ForegroundColor Red
            $errWriter.WriteLine($line)
        } else {
            $line = if ($_ -is [string]) { $_ } else { ($_ | Out-String -Width 300).TrimEnd() }
            Write-Host $line
            $outWriter.WriteLine($line)
        }
    }
} catch {
    $script:hasErrors = $true
    $msg = $_.Exception.Message
    Write-Host "ERROR: $msg" -ForegroundColor Red
    $errWriter.WriteLine($msg)
}

$outWriter.Close()
$errWriter.Close()

# Determine exit code: $LASTEXITCODE for external commands, $hasErrors for PS cmdlets
if ($LASTEXITCODE -ne 0) {
    $exitCode = $LASTEXITCODE
} elseif ($script:hasErrors) {
    $exitCode = 1
} else {
    $exitCode = 0
}

# Signal completion with exit code
[System.IO.File]::WriteAllText($SentinelFile, "$exitCode", [System.Text.UTF8Encoding]::new($false))

# Wait for user to close tab
Write-Host ""
Write-Host "  Press any key to close..." -ForegroundColor DarkYellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
