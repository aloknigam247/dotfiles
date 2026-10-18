# ─[ Don't load for non interactive session ]─────────────────────────────
function _IsShellInteractive {
    $options = [Environment]::GetCommandLineArgs() | Select-Object -Skip 1
    if ($options.Length -gt 0) {
        $option_string = $options -join " "
        if ($option_string -match "^-noexit.*init.ps1$") {
            return $true
        }
        return $false
    }
    if (($options -contains "-noni") -or ($options -contains "-noninteractive")) {
        return $false
    }
    if (($options -contains "-command") -or ($options -contains "-c") -or
        ($options -contains "-file") -or ($options -contains "-f")) {
        return $false
    }
    return $true
}
if ($(_IsShellInteractive) -eq $false) {
    return
}

# ╭─────────────╮
# │ Auto Update │
# ╰─────────────╯
if ((Get-Process -Id $PID).parent.ProcessName -eq "WindowsTerminal") {
    Start-Job {
        Set-Location D:/dotfiles
        git pull
        $git_status = git status --short

        if ($git_status) {
            # Send toast notification via WinRT
            $toast_text = ($git_status -join [char]10)
            powershell.exe -NoProfile -Command "& {
                [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
                [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
                `$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
                `$xml.LoadXml('<toast><visual><binding template=""ToastGeneric""><text>Dotfiles Update</text><text>$toast_text</text></binding></visual></toast>')
                [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Microsoft.WindowsTerminal_8wekyb3d8bbwe!App').Show([Windows.UI.Notifications.ToastNotification]::new(`$xml))
            }"

            $dt = Get-Date
            git add .
            git commit -m "Updated at $dt" --no-verify
            Remove-Item .git\index.lock -ErrorAction SilentlyContinue # fix lock error
            git push
        }
    } | Out-Null
}

# ╭─────────────────╮
# │ Themes Settings │
# ╰─────────────────╯
$catppuccin_latte = @{
    Base = "#EFF1F5"
    Blue = "#1E66F5"
    Crust = "#DCE0E8"
    Flamingo = "#DD7878"
    Green = "#40A02B"
    Lavender = "#7287FD"
    Mantle = "#E6E9EF"
    Maroon = "#E64553"
    Mauve = "#8839EF"
    Overlay0 = "#9CA0B0"
    Overlay1 = "#8C8FA1"
    Overlay2 = "#7C7F93"
    Peach = "#FE640B"
    Pink = "#EA76CB"
    Red = "#D20F39"
    Rosewater = "#DC8A78"
    Sapphire = "#209FB5"
    Sky = "#04A5E5"
    Subtext0 = "#6C6F85"
    Subtext1 = "#5C5F77"
    Surface0 = "#CCD0DA"
    Surface1 = "#BCC0CC"
    Surface2 = "#ACB0BE"
    Teal = "#179299"
    Text = "#4C4F69"
    Yellow = "#DF8E1D"
    # Precomputed blends: <Color>_<opacity %> over Base
    Maroon_25 = "#EDC6CD"
    Overlay2_25 = "#D2D5DD"
}

$catppuccin_mocha = @{
    Base = "#1E1E2E"
    Blue = "#89B4FA"
    Crust = "#11111B"
    Flamingo = "#F2CDCD"
    Green = "#A6E3A1"
    Lavender = "#B4BEFE"
    Mantle = "#181825"
    Maroon = "#EBA0AC"
    Mauve = "#CBA6F7"
    Overlay0 = "#6C7086"
    Overlay1 = "#7F849C"
    Overlay2 = "#9399B2"
    Peach = "#FAB387"
    Pink = "#F5C2E7"
    Red = "#F38BA8"
    Rosewater = "#F5E0DC"
    Sapphire = "#74C7EC"
    Sky = "#89DCEB"
    Subtext0 = "#A6ADC8"
    Subtext1 = "#BAC2DE"
    Surface0 = "#313244"
    Surface1 = "#45475A"
    Surface2 = "#585B70"
    Teal = "#94E2D5"
    Text = "#CDD6F4"
    Yellow = "#F9E2AF"
    # Precomputed blends: <Color>_<opacity %> over Base
    Maroon_25 = "#513F4E"
    Overlay2_25 = "#3B3D4F"
}

function _buildPalette {
    param([hashtable]$theme)

    $result = @{
        cmdline = @{
            command = $theme.Blue
            comment = $theme.Overlay2
            defaultToken = $theme.Text
            emphasis = $theme.Red
            error = $theme.Red
            inlinePrediction = $theme.Overlay0
            keyword = $theme.Mauve
            listPrediction = $theme.Subtext1
            listPredictionSelected = $theme.Surface0
            listPredictionTooltip = $theme.Overlay0
            member = $theme.Lavender
            number = $theme.Peach
            operator = $theme.Sky
            parameter = $theme.Maroon
            selection = $theme.Overlay2_25
            string = $theme.Green
            type = $theme.Yellow
            variable = $theme.Text
        }
        git = @{
            commit = $theme.Flamingo
            commit_icon = $theme.Blue
            contact_bracket = $theme.Overlay2
            head = $theme.Blue
            message = $theme.Text
            timestamp = $theme.Overlay2
            user_email = $theme.Mauve
            user_name = $theme.Mauve
        }
        prompt = @{
            dir_icon = @{
                bg = $theme.Blue
                fg = $theme.Base
            }
            dir_path = $theme.Base
            git = @{
                bg = $theme.Crust
                branch = $theme.Text
                index = $theme.Green
                sep = $theme.Overlay0
                stash = $theme.Maroon
                sync = $theme.Teal
                working = $theme.Blue
            }
            long_cmd = @{
                bg = $theme.Mauve
                fg = $theme.Base
            }
        }
    }

    $result.fzf = @{
        bg               = $theme.Mantle
        border           = $theme.Lavender
        header           = $theme.Red
        info             = $theme.Mauve
        label            = $theme.Text
        marker           = $theme.Lavender
        marker_fg        = $theme.Green
        pointer          = $theme.Mauve
        prompt           = $theme.Mauve
        prompt_hl        = $theme.Red
        selected         = $theme.Surface1
        spinner          = $theme.Rosewater
        spinner_hl       = $theme.Red
        text_bg          = $theme.Base
        text_fg          = $theme.Text
        text_selected_bg = $theme.Surface0
        text_selected_fg = $theme.Rosewater
    }

    return $result
}

function _buildThemeState {
    param([int]$apps_use_light_theme)

    if ($apps_use_light_theme -eq 1) {
        $catppuccin = $catppuccin_latte
        $current_theme = "Catppuccin Latte"
        $lazygit_theme = "light.yml"
        $mode = "light"
    } elseif ($apps_use_light_theme -eq 0) {
        $catppuccin = $catppuccin_mocha
        $current_theme = "Catppuccin Mocha"
        $lazygit_theme = "dark.yml"
        $mode = "dark"
    } else {
        throw "AppsUseLightTheme returned unsupported value '$apps_use_light_theme'."
    }

    $delta_features = $current_theme.ToLower().Replace(" ", "-")
    return @{
        apps_use_light_theme = $apps_use_light_theme
        bat_theme = $current_theme
        catppuccin = $catppuccin
        current_theme = $current_theme
        delta_features = $delta_features
        glow_style = "D:\dotfiles\glow\$delta_features.json"
        lazygit_theme = $lazygit_theme
        mode = $mode
        palette = _buildPalette $catppuccin
    }
}

# get system theme
$system_theme = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
# Windows Terminal switches colorScheme via the dark/light object in settings.json natively (1.22+)
$theme_state = _buildThemeState ([int]$system_theme.AppsUseLightTheme)
$bat_theme = $theme_state.bat_theme
$catppuccin = $theme_state.catppuccin
$current_theme = $theme_state.current_theme
$env:DELTA_FEATURES = $theme_state.delta_features
$env:GLOW_STYLE = $theme_state.glow_style
$env:THEME = $theme_state.mode
$lazygit_theme = $theme_state.lazygit_theme
$palette = $theme_state.palette

# LS Colors
function _buildLSColors {
    param([hashtable]$theme)

    $html_sgr = "38;2;{0};{1};{2}" -f
        [int]"0x$($theme.Peach.Substring(1, 2))",
        [int]"0x$($theme.Peach.Substring(3, 2))",
        [int]"0x$($theme.Peach.Substring(5, 2))"
    $javascript_sgr = "38;2;{0};{1};{2}" -f
        [int]"0x$($theme.Yellow.Substring(1, 2))",
        [int]"0x$($theme.Yellow.Substring(3, 2))",
        [int]"0x$($theme.Yellow.Substring(5, 2))"
    return "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;07;31;05:mi=00:su=07;31:sg=30;43:ca=07;31:tw=07;32:ow=30;107:st=07;34:ex=04;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.nupkg=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*.C=00;32:*.c=00;32:*.cc=00;32:*.cpp=00;32:*.h=00;32:*.py=00;32:*.sv=00;32:*.tcl=00;32:*.v=00;32:*.vim=00;32:*.log=00;33:*.err=00;31:*README*=00;35:*Makefile=00;36:*.make=00;36:*.yml=00;36:*.yaml=00;36:*.ps1=01;33:*.psd1=01;33:*.psm1=01;33:*.ps1xml=01;33:*.md=00;33:*.lua=01;34:*.json=01;36:*.csproj=01;35:*.sln=01;35:*.cs=01;32:*.csharp=01;32:*.colors=01;36" +
        ":*.cjs=${javascript_sgr}:*.htm=${html_sgr}:*.html=${html_sgr}" +
        ":*.js=${javascript_sgr}:*.jsx=${javascript_sgr}:*.mjs=${javascript_sgr}"
}

$env:LS_COLORS = _buildLSColors $catppuccin

 # ╭───────╮
 # │ Icons │
 # ╰───────╯
$icons = @{
    fzf_marker = "$([char]0xf42e)"
    fzf_pointer = "$([char]0x27a4)"
    fzf_prompt = "$([char]0xf4b5)"
    git_aheadby = "$([char]0xdb86)$([char]0xddb2)"
    git_behindby = "$([char]0xdb86)$([char]0xddb3)"
    git_branch = "$([char]0xf418) "
    git_commit = "$([char]0xeafc) "
    git_icon = "$([char]0xf1d2) "
    git_stash = "$([char]0xdb82)$([char]0xdeb6) " #f0ab6
    git_tag = "$([char]0xdb81)$([char]0xdcfd) " # f04fd
    git_working = "$([char]0xdb81)$([char]0xdc16) " # f0416
    gitlog_commit = "$([char]0xeafc)"
    gitlog_email = "$([char]0xeb1c)"
    gitlog_message = "$([char]0xeb26)"
    gitlog_timestamp = "$([char]0xdb81)$([char]0xdd1f)"
    odc = "󰅟 "
    remote = "$([char]0xeb3a) "
    sep_right = "$([char]0xe0b4)"
    type_app = "$([char]0xf120) "
    windows = "$([char]0xe70f) "
}


# ╭─────────╮
# │ Keymaps │
# ╰─────────╯
Set-PSReadLineKeyHandler -Chord "Ctrl+g" -Function ViEditVisually

# ╭─────────╮
# │ Aliases │
# ╰─────────╯
# ─[ Msys2 ]───────────────────────────────────────────────────────────
New-Alias -Name pacman -Value D:\Scoop\apps\msys2\current\usr\bin\pacman.exe -ErrorAction SilentlyContinue

# ─[ Common ]──────────────────────────────────────────────────────────
New-Alias -Name "/" -Value rg -ErrorAction SilentlyContinue
New-Alias -Name "//" -Value fd -ErrorAction SilentlyContinue

# ╭─────────────────╮
# │ Utility Methods │
# ╰─────────────────╯
function _ParseRootArg {
    param([object[]]$argv)
    $root_dir = $PWD.Path
    $filtered = @()
    $skip = $false
    for ($i = 0; $i -lt $argv.Count; $i++) {
        if ($skip) { $skip = $false; continue }
        if ($argv[$i] -eq "--root" -and $i + 1 -lt $argv.Count) {
            $candidate = $argv[$i + 1]
            if (Test-Path -Path $candidate -PathType Container) {
                $root_dir = (Resolve-Path $candidate).Path
            } else {
                throw "Invalid directory: $candidate"
            }
            $skip = $true
        } else {
            $filtered += $argv[$i]
        }
    }
    return @{ RootDir = $root_dir; Args = $filtered }
}

function Get-AgencySubcommands {
    @(
        "artifact", "batch", "config", "create", "eval", "feedback", "finish-pr", "gh-app",
        "help", "hub", "marketplace", "mcp", "plugin", "plugins", "ring", "session-manager",
        "support", "update", "vscode"
    )
}

function Get-AiBackend {
    param([string]$RootDir)
    $gitDir = $null
    $isOrigin = $false
    $directory = [System.IO.DirectoryInfo]::new($RootDir)
    while ($directory) {
        $marker = [System.IO.Path]::Combine($directory.FullName, ".git")
        if ([System.IO.Directory]::Exists($marker)) {
            $gitDir = $marker
            break
        }
        if ([System.IO.File]::Exists($marker)) {
            $pointer = [System.IO.File]::ReadAllText($marker).Trim()
            if ($pointer -notmatch "^gitdir:\s*(.+)$") {
                throw "Invalid gitdir pointer: $marker"
            }
            $gitDir = [System.IO.Path]::GetFullPath($Matches[1], $directory.FullName)
            break
        }
        $directory = $directory.Parent
    }
    if (-not $gitDir) {
        return "copilot"
    }

    $commonFile = [System.IO.Path]::Combine($gitDir, "commondir")
    if ([System.IO.File]::Exists($commonFile)) {
        $pointer = [System.IO.File]::ReadAllText($commonFile).Trim()
        if (-not $pointer) {
            throw "Invalid commondir pointer: $commonFile"
        }
        $gitDir = [System.IO.Path]::GetFullPath($pointer, $gitDir)
    }
    $configFile = [System.IO.Path]::Combine($gitDir, "config")
    foreach ($line in [System.IO.File]::ReadAllLines($configFile)) {
        if ($line -cmatch "^\s*\[(?i:remote)\s+`"origin`"\s*\]\s*(?:[#;].*)?$") {
            $isOrigin = $true
        } elseif ($line -match "^\s*\[") {
            $isOrigin = $false
        } elseif ($isOrigin -and $line -match "^\s*url\s*=\s*(?:`"([^`"]*)`"|([^#;]*))") {
            $url = if ($Matches.ContainsKey(1)) { $Matches[1] } else { $Matches[2].Trim() }
            if ($url -match "github\.com") {
                return "copilot"
            }
            return "agency"
        }
    }
    return "agency"
}

function Start-CpTower {
    # Fire-and-forget so `copilot` never blocks: a cheap name check skips the launch
    # when an instance is already up, otherwise start it hidden and return immediately.
    if (Get-Process -Name cptower -ErrorAction SilentlyContinue) { return }
    $exe = "D:\dotfiles\cptower\dist\cptower.exe"
    if (Test-Path $exe) {
        $log_dir = Join-Path $env:XDG_CONFIG_HOME "cptower"
        $log_file = Join-Path $log_dir "cptower.log"
        New-Item -ItemType Directory -Path $log_dir -Force -ErrorAction Stop | Out-Null

        # cptower signs AHP clients in to hosts as this GitHub CLI account.
        $command = "`"`"$exe`" --github-user aloknigam_microsoft > `"$log_file`" 2>&1`""
        Start-Process -FilePath $env:ComSpec -ArgumentList "/d", "/s", "/c", $command -WindowStyle Hidden | Out-Null
    }
}

# ╭───────────────────╮
# │ Generic Functions │
# ╰───────────────────╯
Remove-Item -Force alias:ls -ErrorAction SilentlyContinue
Remove-Item -Force alias:rm -ErrorAction SilentlyContinue
function bg   { wt -f -d $PWD.Path --colorScheme $current_theme pwsh -NoProfile -C "$args" }
function fd   { C:\Users\aloknigam\scoop\shims\fd.exe --hyperlink=auto $args }
function grep { D:\Scoop\apps\msys2\current\usr\bin\grep.exe --color=auto -En $args }
function la   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AF --color=auto $args }
function lazygit { C:\Users\aloknigam\scoop\shims\lazygit.exe -ucf "$env:APPDATA\lazygit\config.yml,$env:APPDATA\lazygit\$($lazygit_theme)" }
function lla  { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AlF --color=auto $args }
function ls   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -F --color=auto $args }
function nvim { C:\Users\aloknigam\scoop\shims\nvim.exe $args; Write-Host -NoNewline "`e[0 q" }
function pdbg { code .; python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client $args }
function rg   { C:\Users\aloknigam\scoop\shims\rg.exe -LS --hyperlink-format vscode $args }
function rm   { D:\Scoop\apps\msys2\current\usr\bin\rm.exe -rf $args }
function tree { C:\Users\aloknigam\scoop\shims\tre.exe -a $args }
function mdview { D:\mdview\target\release\mdview.exe $args }

function ai {
    try {
        $root_dir = (_ParseRootArg $args).RootDir
    } catch {
        $root_dir = $PWD.Path
    }

    $backend = Get-AiBackend -RootDir $root_dir
    & $backend @args
}

function bat {
    param([string]$file)
    if ($file.ToLower().EndsWith('.md')) {
        glow $file
    } else {
        D:\Scoop\shims\bat.exe --style="numbers,changes" --italic-text=always --theme $bat_theme $file
    }
}

$copilot_context = "long_context"
$copilot_model = "gpt-6-astra"
$copilot_reasoning_effort = "max"

function agency {
    try {
        $parsed = _ParseRootArg $args
    } catch {
        Write-Error $_
        return
    }
    $first = if ($parsed.Args.Count) { $parsed.Args[0] } else { $null }
    $isCopilot = $first -and ($first -in @("copilot", "cp"))
    $isSubcommand = $first -and ((Get-AgencySubcommands) -contains $first)
    $root_dir = $parsed.RootDir

    if (-not ($isSubcommand -or $isCopilot)) {
        Start-CpTower
    }

    wt -f -d $root_dir pwsh -c {
        param([string[]]$argList, $copilot_context, $copilot_model, $copilot_reasoning_effort, $isCopilot, $isSubcommand)

        if (-not (Get-Command agency.exe -ErrorAction SilentlyContinue)) {
            Write-Host "agency not installed - installing via aka.ms/InstallTool.ps1..." -ForegroundColor Yellow
            iex "& { $(irm aka.ms/InstallTool.ps1) } agency"
        }

        if ($isSubcommand -or $isCopilot) {
            agency.exe @argList
        } else {
            agency.exe copilot --model $copilot_model --reasoning-effort $copilot_reasoning_effort --context $copilot_context @argList
        }

        $ok = $?
        if ($isSubcommand) {
            Read-Host -Prompt "Press any key to exit"
        } elseif (-not $ok) {
            Read-Host -Prompt "Agency exited with error, press any key to exit"
        }
    } -args $parsed.Args, $copilot_context, $copilot_model, $copilot_reasoning_effort, $isCopilot, $isSubcommand
}

function copilot {
    Start-CpTower

    try {
        $parsed = _ParseRootArg $args
    } catch {
        Write-Error $_
        return
    }
    $root_dir = $parsed.RootDir

    wt -f -d $root_dir pwsh -c {
        param([string[]]$argList, $copilot_context, $copilot_model, $copilot_reasoning_effort)
        copilot.exe --model $copilot_model --reasoning-effort $copilot_reasoning_effort --context $copilot_context @argList
        if ($? -eq $False) { Read-Host -Prompt "Copilot exited with error, press any key to exit" }
    } -args $parsed.Args, $copilot_context, $copilot_model, $copilot_reasoning_effort
}

function e {
    $quoted_args = $args | ForEach-Object { '"{0}"' -f ($_ -replace '\\+$') }
    $arg_str = $quoted_args -join " "
    if (Test-Path "D:\qvim\build\release\RelWithDebInfo\qvim.exe") {
        if ($args.Count -eq 0) {
            D:\qvim\build\release\RelWithDebInfo\qvim.exe
        } else {
            D:\qvim\build\release\RelWithDebInfo\qvim.exe $arg_str
        }
    } else {
        wt -f -d $PWD.Path --colorScheme $current_theme cmd /C "nvim $arg_str"
    }
}

function whatis($arg) {
    $cm = Get-Command $arg -ErrorAction SilentlyContinue
    $type = $cm.CommandType

    if ($type -eq "Function") {
        Format-Pill "󰊕 $arg" -bg $catppuccin.Blue -fg $catppuccin.Base -styles italic
        $temp_file = "$env:TEMP\tmp.ps1"
        Write-Output $cm.Definition > $temp_file
        D:\Scoop\shims\bat.exe -P --style="numbers,changes" --italic-text=always --theme $bat_theme $temp_file
        Remove-Item $temp_file
    } elseif ($type -eq "Application") {
        Format-Pill "$($icons.type_app) Application" -bg $catppuccin.Green -fg $catppuccin.Base -styles italic
        $cm.Source
    } elseif ($type -eq "Alias") {
        Format-Pill " Alias" -bg $catppuccin.Lavender -fg $catppuccin.Base  -styles italic
        $cm.DisplayName
    } else {
        Write-Host "Unknown"
    }
}

# ─( Path functions )──────────────────────────────────────────────────
function desktop { Set-Location $([Environment]::GetFolderPath("Desktop")) }
function notes { Join-Path $([Environment]::GetFolderPath("Desktop")) "\Docs\Work\notes" | Set-Location }

# ─( Git functions )───────────────────────────────────────────────────
Remove-Item -Force alias:gc -ErrorAction SilentlyContinue
function gc {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Ref
    )
    git checkout @Ref
    $stash = git stash list
    if ($null -ne $stash) {
        if ($stash.GetType() -eq [String]) {
            Format-Text -bg $catppuccin.Maroon_25 -fg $catppuccin.Text $stash
        } elseif ($stash.GetType() -eq [Object[]]) {
            foreach ($st in $stash) {
                Format-Text -bg $catppuccin.Maroon_25 -fg $catppuccin.Text $st
            }
        } else {
            Write-Host $stash
        }
    }
}

Remove-Item -Force alias:gl -ErrorAction SilentlyContinue
function gl {
    git log --color=always --pretty="%C($($palette.git.commit_icon))$($icons.gitlog_commit) %C($($palette.git.commit))%h %Creset- %C($($palette.git.message))$($icons.gitlog_message) %s %C($($palette.git.timestamp))$($icons.gitlog_timestamp) %ar on %ah %C($($palette.git.contact_bracket))<%C($($palette.git.user_name))%an %C($($palette.git.user_email))$($icons.gitlog_email) %ae%C($($palette.git.contact_bracket))>%C($($palette.git.head))%d" $args
}

function gs { git status --ignore-submodules=all --short --branch --show-stash --ahead-behind $args }

function gwa {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $Branch
    )
    $branch_exists = git rev-parse --verify $Branch 2>$null
    if ($branch_exists) {
        git worktree add ..\$Branch
        Set-Location ..\$Branch
    } else {
        git worktree add ..\$Branch -b $Branch
        Set-Location ..\$Branch
    }
}

function gwd {
    $branch_name = (Get-Location).Path.Split("\")[-1]
    $main_repo = (git rev-parse --path-format=absolute --git-common-dir).Replace("/.git","")
    Set-Location $main_repo
    git worktree remove $branch_name
    git branch -D $branch_name --force
}

# ─[ Format text for colors and formatting ]───────────────────────────
function Format-Text {
    param(
        [Parameter(ParameterSetName = "Complete")]
        [Parameter(Position=0)]
        [String]$text,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [String]$bg,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [String]$fg,

        [Parameter(ParameterSetName = "Complete")]
        [Parameter(ParameterSetName = "HeadOnly")]
        [ValidateSet("blink","bold","hidden","italic","reverse","strikethrough","underline")]
        [Array]$styles,

        [Parameter(ParameterSetName = "HeadOnly")]
        [Switch]$headonly,

        [Parameter(ParameterSetName = "Complete")]
        [Switch]$noreset
    )

    $esc = [char]27
    $head = ""

    # create background header
    if ($bg -ne "") {
        $bg_r_hex = "0x$($bg.Substring(1, 2))"
        $bg_g_hex = "0x$($bg.Substring(3, 2))"
        $bg_b_hex = "0x$($bg.Substring(5, 2))"
        $bg_r = [int]$bg_r_hex
        $bg_g = [int]$bg_g_hex
        $bg_b = [int]$bg_b_hex
        $head = "48;2;$bg_r;$bg_g;$bg_b"
    }

    # create foreground header
    if ($fg -ne "") {
        if ($head -ne "") { $head += ";" } # separator
        $fg_r_hex = "0x$($fg.Substring(1, 2))"
        $fg_g_hex = "0x$($fg.Substring(3, 2))"
        $fg_b_hex = "0x$($fg.Substring(5, 2))"
        $fg_r = [int]$fg_r_hex
        $fg_g = [int]$fg_g_hex
        $fg_b = [int]$fg_b_hex
        $head += "38;2;$fg_r;$fg_g;$fg_b"
    }

    # create effects header
    foreach ($style in $styles) {
        if ($head -ne "") { $head += ";" } # separator
        switch ($style) {
            "blink"         { $head += "5" }
            "bold"          { $head += "1" }
            "hidden"        { $head += "8" }
            "italic"        { $head += "3" }
            "reverse"       { $head += "7" }
            "strikethrough" { $head += "9" }
            "underline"     { $head += "4" }
        }
    }

    if ($head -ne "") {
        $head = "$esc[$head" + "m"
        if ($headOnly -eq $true) {
            return $head 
        }
        $head += $text
        if ($noreset -eq $false) {
            $head += "$esc[0m"
        }
    } else {
        $head = $text
    }

    return $head
}

function Format-Pill {
    param(
        [Parameter(Mandatory, Position = 0)]
        [String]$text,

        [Parameter(Mandatory)]
        [String]$bg,

        [Parameter(Mandatory)]
        [String]$fg,

        [ValidateSet("blink","bold","hidden","italic","reverse","strikethrough","underline")]
        [Array]$styles
    )

    $left_cap = "`u{E0B6}"
    $right_cap = "`u{E0B4}"

    $pill = Format-Text $left_cap -fg $bg -noreset
    if ($styles.Count -gt 0) {
        $pill += Format-Text "$text" -fg $fg -bg $bg -styles $styles
    } else {
        $pill += Format-Text "$text" -fg $fg -bg $bg
    }
    $pill += Format-Text $right_cap -fg $bg

    return $pill
}

# ╭───────────╮
# │ FZF Setup │
# ╰───────────╯
# https://www.devguru.com/content/technologies/wsh/wshshell-sendkeys.html
Import-Module PSFzf

Set-PsFzfOption `
    -PSReadlineChordProvider "Alt+p" `
    -PSReadlineChordReverseHistory "Alt+h" `
    -PSReadlineChordSetLocation "Alt+d" `
    -PSReadlineChordReverseHistoryArgs "Alt+a"
Set-PSReadLineKeyHandler -Key Alt+t -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

# ╭────────────────╮
# │ Autocompletion │
# ╰────────────────╯
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward # Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward # Autocompletion for arrow keys
if (-not $PSVersionTable.PSVersion.ToString().StartsWith("5.1")) {
    try{
        if ($env:COMPUTERNAME -eq "ALOKNIGAM") {
            Import-Module -Name PSDirectoryPredictor -ErrorAction SilentlyContinue
        }
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced
    } catch {
        Write-Error "Error occurred in setting PredictionSource"
        Write-Error $_
    }
}

# ─[ git tab completion ]──────────────────────────────────────────────
# Must register after PSFzf — PSFzf registers its own broken `git` completer
# (depends on posh-git's Expand-GitCommand). Re-registering here wins.
Import-Module GitCompleter -ErrorAction SilentlyContinue
Register-GitCompleter

# ─[ winget tab completion ]───────────────────────────────────────────
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
        }
}

Register-ArgumentCompleter -Native -CommandName agency, ai, copilot -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    if ($commandAst.GetCommandName() -notin @("agency", "ai", "copilot")) {
        return
    }

    $agencyFlags = @(
        "--agent", "--agent-type", "--branch", "--copilot-log-name", "--copilot-session-file",
        "--generate-result", "--help", "--hub", "--input", "--marketplace-project", "--mcp",
        "--no-aec", "--no-config-cache", "--no-config-plugins", "--no-default-mcps", "--no-input-processing",
        "--organization", "--plugin", "--plugins", "--profile", "--profile-only", "--project", "--prompt",
        "--repository", "--result-type", "--session-id", "--session-manager", "--source", "--type", "-a", "-h", "-p"
    )
    $copilotFlags = @(
        "--acp", "--add-dir", "--add-github-mcp-tool", "--add-github-mcp-toolset", "--additional-mcp-config", "--agent",
        "--allow-all", "--allow-all-mcp-server-instructions", "--allow-all-paths", "--allow-all-tools",
        "--allow-all-urls", "--allow-tool", "--allow-url", "--assisted-approval", "--attachment", "--auto-tier",
        "--autopilot", "--available-tools", "--banner", "--bash-env", "--connect", "--context", "--continue",
        "--deny-tool", "--deny-url", "--disable-builtin-mcps", "--disable-mcp-server", "--disallow-temp-dir",
        "--dynamic-retrieval", "--effort", "--enable-all-github-mcp-tools", "--enable-mcp-server", "--enable-memory",
        "--enable-reasoning-summaries", "--excluded-tools", "--experimental", "--extension-sdk-path", "--fleet",
        "--help", "--interactive", "--log-dir", "--log-level", "--max-ai-credits", "--max-autopilot-continues",
        "--mcp-github-auth", "--mode", "--model", "--mouse", "--name", "--no-ask-user", "--no-auto-update",
        "--no-bash-env", "--no-color", "--no-custom-instructions", "--no-eager-powershell-resolution",
        "--no-experimental", "--no-mouse", "--no-remote", "--no-remote-export", "--output-format", "--plain-diff",
        "--plan", "--plugin-dir", "--prompt", "--reasoning-effort", "--remote", "--remote-export", "--resume",
        "--screen-reader", "--secret-env-vars", "--session-id", "--share", "--share-gist", "--silent", "--stream",
        "--usage-output-file", "--version", "--yolo", "-C", "-h", "-i", "-n", "-p", "-r", "-s", "-v"
    )
    $copilotSubcommands = @(
        "app", "completion", "config", "help", "init", "instruction", "login", "lsp", "mcp", "memories",
        "plugin", "plugins", "sandbox", "sessions", "skill", "update", "version", "workflow"
    )
    $effortValues = @("high", "low", "max", "medium", "minimal", "none", "xhigh")
    $insertPrefix = ""
    $isAgentValue = $false
    $isNativeAgency = $false
    $option = ""
    $sourceValues = @("company", "organization", "personal", "playground", "repo", "spec")
    $enums = @{
        "--context" = @("default", "long_context")
        "--effort" = $effortValues
        "--log-level" = @("all", "debug", "default", "error", "info", "none", "warning")
        "--mode" = @("autopilot", "interactive", "plan")
        "--output-format" = @("json", "text")
        "--reasoning-effort" = $effortValues
        "--stream" = @("off", "on")
    }
    $elements = @($commandAst.CommandElements | Where-Object {
        $_.Extent.EndOffset -lt $cursorPosition -or
            ($_.Extent.EndOffset -eq $cursorPosition -and -not $wordToComplete)
    })
    $arguments = @($elements | Select-Object -Skip 1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
            $_.Value
        } else {
            $_.Extent.Text
        }
    })
    if ($arguments.Count -gt 0 -and $arguments[-1] -eq "--root") {
        [System.Management.Automation.CompletionCompleters]::CompleteFilename($wordToComplete) |
            Where-Object ResultType -EQ ProviderContainer
        return
    }

    $parsed = _ParseRootArg $arguments
    $arguments = @($parsed.Args)
    $backend = if ($commandAst.GetCommandName() -eq "ai") {
        Get-AiBackend -RootDir $parsed.RootDir
    } else {
        $commandAst.GetCommandName()
    }
    $flags = @($copilotFlags + "--root")
    $subcommands = $copilotSubcommands
    if ($backend -eq "agency") {
        $agencySubcommands = @(Get-AgencySubcommands)
        $flags += $agencyFlags
        $enums["--agent-type"] = $sourceValues
        $enums["--result-type"] = @("pr", "standard")
        $enums["--source"] = $sourceValues
        $enums["--type"] = $sourceValues
        if ($arguments.Count -gt 0 -and $arguments[0] -in @("copilot", "cp")) {
            $arguments = @($arguments | Select-Object -Skip 1)
        } elseif ($arguments.Count -gt 0 -and $arguments[0] -in $agencySubcommands) {
            $isNativeAgency = $true
        } else {
            $subcommands += @($agencySubcommands + @("copilot", "cp"))
        }
    }

    $prefix = $wordToComplete
    if ($arguments.Count -gt 0) {
        $option = $arguments[-1]
    }
    $equalsIndex = $wordToComplete.IndexOf("=")
    if ($equalsIndex -gt 0) {
        $equalsOption = $wordToComplete.Substring(0, $equalsIndex)
        if ($enums.ContainsKey($equalsOption) -or $equalsOption -eq "--agent" -or
            ($backend -eq "agency" -and $equalsOption -eq "-a")) {
            $insertPrefix = $wordToComplete.Substring(0, $equalsIndex + 1)
            $option = $equalsOption
            $prefix = $wordToComplete.Substring($equalsIndex + 1)
        }
    }

    if ($isNativeAgency) {
        $candidates = @("--help", "--root")
        $insertPrefix = ""
        $prefix = $wordToComplete
    } elseif ($enums.ContainsKey($option)) {
        $candidates = $enums[$option]
    } elseif ($option -eq "--agent" -or ($backend -eq "agency" -and $option -eq "-a")) {
        $isAgentValue = $true
        $source = ""
        if ($backend -eq "agency") {
            for ($i = 0; $i -lt $arguments.Count; $i++) {
                if ($arguments[$i] -in @("--agent-type", "--source", "--type") -and
                    $i + 1 -lt $arguments.Count) {
                    $source = $arguments[++$i]
                } elseif ($arguments[$i] -match "^--(?:agent-type|source|type)=(.*)$") {
                    $source = $Matches[1]
                }
            }
        }
        $agentDirectories = @(
            if (-not $source -or $source -eq "personal") {
                $homeDir = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $HOME ".copilot" }
                Join-Path $homeDir "agents"
            }
            if (-not $source -or $source -eq "repo") {
                $projectRoot = $parsed.RootDir
                $directory = [System.IO.DirectoryInfo]::new($projectRoot)
                while ($directory) {
                    if (Test-Path -LiteralPath (Join-Path $directory.FullName ".git")) {
                        $projectRoot = $directory.FullName
                        break
                    }
                    $directory = $directory.Parent
                }
                Join-Path $projectRoot ".github\agents"
            }
        )
        $candidates = @(
            foreach ($agentDirectory in $agentDirectories) {
                try {
                    if (Test-Path -LiteralPath $agentDirectory -PathType Container -ErrorAction Stop) {
                        Get-ChildItem -LiteralPath $agentDirectory -Filter "*.md" -File -ErrorAction Stop |
                            ForEach-Object { $_.BaseName -replace "\.agent$", "" }
                    }
                } catch [System.UnauthorizedAccessException], [System.IO.IOException],
                    [System.Management.Automation.ItemNotFoundException] {
                    Write-Warning "Unable to read agents in '${agentDirectory}': $($_.Exception.Message)"
                }
            }
        )
    } elseif ($arguments.Count -eq 0) {
        $candidates = @($flags + $subcommands)
    } else {
        $candidates = $flags
    }

    if ($prefix.Length -gt 0 -and $prefix[0] -in @("'", "`"")) {
        $quote = $prefix[0]
        $prefix = $prefix.Substring(1)
        if ($prefix.EndsWith([string]$quote)) {
            $prefix = $prefix.Substring(0, $prefix.Length - 1)
        }
        if ($quote -eq "'") {
            $prefix = $prefix.Replace("''", "'")
        }
    }
    foreach ($candidate in $candidates | Sort-Object -CaseSensitive -Unique) {
        if ($candidate -and $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $text = $candidate
            if ($isAgentValue -and $candidate -match "[^\w.-]") {
                $escaped = $candidate.Replace("'", "''")
                $text = "'$escaped'"
            }
            [System.Management.Automation.CompletionResult]::new(
                "$insertPrefix$text", $candidate, "ParameterValue", $candidate)
        }
    }
}

# https://vitormv.github.io/fzf-themes
function _buildFzfDefaultOpts {
    param(
        [string]$bat_theme_name,
        [hashtable]$theme_palette
    )

    $options = ""
    $options += " --height=~70%"
    $options += " --layout=reverse"
    $options += " --border=none"
    $options += " --border-label=' FZF '"
    $options += " --border-label-pos=5"
    $options += " --info=inline"
    $options += " --prompt='$($icons.fzf_prompt) '"
    $options += " --pointer='$($icons.fzf_pointer) '"
    $options += " --preview='bat.exe"
    $options += " --style=numbers"
    $options += " --color=always"
    $options += " --italic-text=always"
    $options += " --theme `"$bat_theme_name`" {}'"
    $options += " --preview-window='right,60%,border-rounded'"
    $options += " --preview-label='(Preview)'"
    $options += " --scheme=path"
    $options += " --marker='$($icons.fzf_marker) '"
    $options += " --separator=' '"
    $options += " --margin='0,0,0,1'"
    $options += " --scrollbar='▐'"
    $options += " --info='right'"
    $options += " --color=bg+:$($theme_palette.fzf.text_selected_bg)"
    $options += " --color=bg:$($theme_palette.fzf.bg)"
    $options += " --color=border:$($theme_palette.fzf.border)"
    $options += " --color=fg+:$($theme_palette.fzf.text_fg)"
    $options += " --color=fg:$($theme_palette.fzf.text_fg)"
    $options += " --color=header:$($theme_palette.fzf.header)"
    $options += " --color=hl+:$($theme_palette.fzf.prompt_hl)"
    $options += " --color=hl:$($theme_palette.fzf.spinner_hl)"
    $options += " --color=info:$($theme_palette.fzf.info)"
    $options += " --color=label:$($theme_palette.fzf.label)"
    $options += " --color=marker:$($theme_palette.fzf.marker)"
    $options += " --color=pointer:$($theme_palette.fzf.pointer)"
    $options += " --color=prompt:$($theme_palette.fzf.prompt)"
    $options += " --color=selected-bg:$($theme_palette.fzf.selected)"
    $options += " --color=spinner:$($theme_palette.fzf.spinner)"
    return $options
}

$env:FZF_DEFAULT_OPTS = _buildFzfDefaultOpts $bat_theme $palette

$env:EDITOR = "nvim"

# ╭────────────────╮
# │ Prompt Styling │
# ╰────────────────╯
Set-PSReadlineKeyHandler Enter {
    $script:cmd_start_time = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

function Get-GitStatus {
    # -uno skips expensive untracked file recursion in large repos
    $raw = git --no-optional-locks status --porcelain=v2 --branch --show-stash -uno 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }

    $result = @{
        AheadBy    = 0
        BehindBy   = 0
        Branch     = ""
        HasIndex   = $false
        HasWorking = $false
        StashCount = 0
    }

    foreach ($line in $raw) {
        if ($line.StartsWith("# branch.head ")) {
            $head = $line.Substring(14)
            if ($head -eq "(detached)") {
                $sha = git --no-optional-locks rev-parse --short HEAD 2>$null
                $result.Branch = "($sha...)"
            } else {
                $result.Branch = $head
            }
        } elseif ($line.StartsWith("# branch.ab ")) {
            $parts = $line.Substring(13).Split(" ")
            $result.AheadBy = [int]$parts[0].TrimStart("+")
            $result.BehindBy = [int]$parts[1].TrimStart("-")
        } elseif ($line.StartsWith("# stash ")) {
            $result.StashCount = [int]$line.Substring(8)
        } elseif ($line.StartsWith("1 ") -or $line.StartsWith("2 ") -or $line.StartsWith("u ")) {
            $xy = $line.Substring(2, 2)
            if ($xy[0] -ne ".") { $result.HasIndex = $true }
            if ($xy[1] -ne ".") { $result.HasWorking = $true }
        }
    }

    # fast untracked check — --directory avoids recursing into untracked dirs
    if (-not $result.HasWorking) {
        $untracked = git --no-optional-locks ls-files --others --exclude-standard --directory --no-empty-directory 2>$null
        if ($untracked) { $result.HasWorking = $true }
    }

    return [PSCustomObject]$result
}

function _populatePrompt {
    # Initial executions
    $script:dir_icon = $icons.windows
    $script:git_branch = ""
    $script:git_index = ""
    $script:git_stash = ""
    $script:git_sync = ""
    $script:git_working = ""
    $script:git_sep = ""

    $script:git_status = Get-GitStatus

    if ($null -ne $script:git_status) {
        $script:dir_icon = $icons.git_icon

        # git branch
        $git_branch = $script:git_status.Branch
        if ($git_branch.StartsWith("(") -and $git_branch.EndsWith(")")) {
            if ($git_branch.EndsWith("...)")) {
                $script:git_branch = $icons.git_commit + $git_branch.Substring(1, $git_branch.Length - 5)
            } else {
                $script:git_branch = $icons.git_tag + $git_branch.Substring(1, $git_branch.Length - 2)
            }
        } else {
            $script:git_branch = $icons.git_branch + $git_branch.Replace("user/$env:username", "~")
        }

        # git dirty check
        if ($script:git_status.HasWorking) {
            $script:git_working = $icons.git_working
        }
        if ($script:git_status.HasIndex) {
            $script:git_index = $icons.git_working
        }
        if ($script:git_status.StashCount) {
            $script:git_stash = $icons.git_stash
        }

        # git ahead and behind count
        $git_sync = ""
        if ($script:git_status.AheadBy) {
            $git_sync += "$($icons.git_aheadby)$($script:git_status.AheadBy)"
        }
        if ($script:git_status.BehindBy) {
            $git_sync += "$($icons.git_behindby)$($script:git_status.BehindBy)"
        }
        $script:git_sync = $git_sync

        if ($script:git_working -ne "" -or
            $script:git_index -ne "" -or
            $script:git_stash -ne "" -or
            $script:git_sync -ne "") {
            $script:git_sep = " "
        }
    }

    if ($null -ne $env:SSH_CLIENT) {
        $script:dir_icon = $icons.remote
    } elseif ($env:INETROOT) {
        $script:dir_icon = $icons.odc
    }

    # Command execution durations
    $script:cmd_duration = ""
    if ($script:cmd_start_time -ne $null) {
        $current_time = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

        $duration = $current_time - $script:cmd_start_time
        if ($duration -ge 3600) {
            $hours = [math]::Floor($duration / 3600)
            $minutes = [math]::Floor(($duration % 3600) / 60)
            $formatted = "${hours}h:${minutes}m"
        } elseif ($duration -ge 60) {
            $minutes = [math]::Floor($duration / 60)
            $seconds = [math]::Floor($duration % 60)
            $formatted = "${minutes}m:${seconds}s"
        } else {
            $formatted = ""
        }

        $script:cmd_duration = $formatted
    }
}

function _promptGen($separator, $segments) {
    # Prompt rendering
    $i = 0
    $out = ""
    $seg = $segments[$i]
    $block_bg = $seg.bg

    foreach ($block in $seg.blocks) {
        $block_params = $block
        $block_params.bg = $block_bg
        $out += Format-Text @block_params
    }
    $sep_fg = $block_bg

    for ($i = 1; $i -lt $segments.Count; $i++) {
        $seg = $segments[$i]
        $block_bg = $seg.bg

        if ($null -ne $seg.cond) {
            $res = Invoke-Command $seg.cond
            if ($res -eq $false) {
                continue
            }
        }

        $sep_params = $separator.Clone()
        $sep_params.bg = $block_bg
        if ($null -eq $separator.fg) {
            $sep_params.fg = $sep_fg
        }
        $out += Format-Text @sep_params

        $out += Format-Text -text " " -bg $block_bg
        foreach ($block in $seg.blocks) {
            $block_params = $block
            $block_params.bg = $block_bg
            $out += Format-Text @block_params
        }
        $sep_fg = $block_bg
    }

    $sep_params = $separator.Clone()
    $sep_params.bg = $null
    if ($null -eq $separator.fg) {
        $sep_params.fg = $sep_fg
    }
    $out += Format-Text @sep_params
    $out += " "

    $ExecutionContext.InvokeCommand.ExpandString($out)
}

function _getPSReadLineColors {
    $options = Get-PSReadLineOption
    $colors = @{
        "Command" = $options.CommandColor
        "Comment" = $options.CommentColor
        "ContinuationPrompt" = $options.ContinuationPromptColor
        "Default" = $options.DefaultTokenColor
        "Emphasis" = $options.EmphasisColor
        "Error" = $options.ErrorColor
        "Keyword" = $options.KeywordColor
        "Member" = $options.MemberColor
        "Number" = $options.NumberColor
        "Operator" = $options.OperatorColor
        "Parameter" = $options.ParameterColor
        "Selection" = $options.SelectionColor
        "String" = $options.StringColor
        "Type" = $options.TypeColor
        "Variable" = $options.VariableColor
    }

    if (-not $PSVersionTable.PSVersion.ToString().StartsWith("5.1")) {
        $colors["InlinePrediction"] = $options.InlinePredictionColor
        $colors["ListPrediction"] = $options.ListPredictionColor
        $colors["ListPredictionSelected"] = $options.ListPredictionSelectedColor
        $colors["ListPredictionTooltip"] = $options.ListPredictionTooltipColor
    }

    return $colors
}

function _buildPSReadLineColors {
    param([hashtable]$theme_palette)

    $colors = @{
        "Command" = (Format-Text -headOnly -fg $theme_palette.cmdline.command)
        "Comment" = (Format-Text -headOnly -fg $theme_palette.cmdline.comment -styles "italic")
        "ContinuationPrompt" = (Format-Text -headOnly -fg $theme_palette.cmdline.defaultToken)
        "Default" = (Format-Text -headOnly -fg $theme_palette.cmdline.defaultToken)
        "Emphasis" = (Format-Text -headOnly -fg $theme_palette.cmdline.emphasis)
        "Error" = (Format-Text -headOnly -fg $theme_palette.cmdline.error)
        "Keyword" = (Format-Text -headOnly -fg $theme_palette.cmdline.keyword -styles "italic")
        "Member" = (Format-Text -headOnly -fg $theme_palette.cmdline.member -styles "italic")
        "Number" = (Format-Text -headOnly -fg $theme_palette.cmdline.number)
        "Operator" = (Format-Text -headOnly -fg $theme_palette.cmdline.operator)
        "Parameter" = (Format-Text -headOnly -fg $theme_palette.cmdline.parameter)
        "Selection" = (
            Format-Text -headOnly -fg $theme_palette.cmdline.defaultToken -bg $theme_palette.cmdline.selection
        )
        "String" = (Format-Text -headOnly -fg $theme_palette.cmdline.string)
        "Type" = (Format-Text -headOnly -fg $theme_palette.cmdline.type)
        "Variable" = (Format-Text -headOnly -fg $theme_palette.cmdline.variable)
    }

    if (-not $PSVersionTable.PSVersion.ToString().StartsWith("5.1")) {
        $colors["InlinePrediction"] = Format-Text -headOnly -fg $theme_palette.cmdline.inlinePrediction
        $colors["ListPrediction"] = Format-Text -headOnly -fg $theme_palette.cmdline.listPrediction -styles "italic"
        $colors["ListPredictionSelected"] =
            Format-Text -headOnly -bg $theme_palette.cmdline.listPredictionSelected -styles "bold"
        $colors["ListPredictionTooltip"] =
            Format-Text -headOnly -fg $theme_palette.cmdline.listPredictionTooltip -styles "italic"
    }

    return $colors
}

function _applyPSReadLineColors {
    param([hashtable]$colors)

    Set-PSReadLineOption -Colors $colors
}

function _applyPSStyleColors {
    param([hashtable]$theme)

    if ($null -eq (Get-Variable PSStyle -ErrorAction SilentlyContinue)) {
        return
    }

    $directory_rgb = @(
        [int]"0x$($theme.Blue.Substring(1, 2))"
        [int]"0x$($theme.Blue.Substring(3, 2))"
        [int]"0x$($theme.Blue.Substring(5, 2))"
    ) -join ";"
    $PSStyle.FileInfo.Directory = "`e[38;2;${directory_rgb}m"
    $PSStyle.FileInfo.Executable = Format-Text -headOnly -fg $theme.Green -styles "bold"
    ".7z", ".cab", ".gz", ".nupkg", ".tar", ".tgz", ".zip" | ForEach-Object {
        $PSStyle.FileInfo.Extension[$_] = Format-Text -headOnly -fg $theme.Red -styles "bold"
    }
    ".ps1", ".ps1xml", ".psd1", ".psm1" | ForEach-Object {
        $PSStyle.FileInfo.Extension[$_] = Format-Text -headOnly -fg $theme.Yellow -styles "bold"
    }
    $PSStyle.FileInfo.SymbolicLink = Format-Text -headOnly -fg $theme.Teal -styles "bold"
    $PSStyle.Formatting.CustomTableHeaderLabel = Format-Text -headOnly -fg $theme.Green -styles "bold", "italic"
    $PSStyle.Formatting.Debug = Format-Text -headOnly -fg $theme.Teal -styles "bold"
    $PSStyle.Formatting.Error = Format-Text -headOnly -fg $theme.Red -styles "bold"
    $PSStyle.Formatting.ErrorAccent = Format-Text -headOnly -fg $theme.Blue -styles "bold"
    $PSStyle.Formatting.FeedbackAction = Format-Text -headOnly -fg $theme.Blue
    $PSStyle.Formatting.FeedbackName = Format-Text -headOnly -fg $theme.Subtext1
    $PSStyle.Formatting.FeedbackText = Format-Text -headOnly -fg $theme.Text
    $PSStyle.Formatting.FormatAccent = Format-Text -headOnly -fg $theme.Green -styles "bold"
    $PSStyle.Formatting.TableHeader = Format-Text -headOnly -fg $theme.Green -styles "bold"
    $PSStyle.Formatting.Verbose = Format-Text -headOnly -fg $theme.Sky -styles "bold"
    $PSStyle.Formatting.Warning = Format-Text -headOnly -fg $theme.Yellow -styles "bold"
    $PSStyle.Progress.Style = Format-Text -headOnly -fg $theme.Mauve -styles "bold"
}

function _getPSStyleSnapshot {
    $extension_names = @(
        ".7z"
        ".cab"
        ".gz"
        ".nupkg"
        ".ps1"
        ".ps1xml"
        ".psd1"
        ".psm1"
        ".tar"
        ".tgz"
        ".zip"
    )

    if ($null -eq (Get-Variable PSStyle -ErrorAction SilentlyContinue)) {
        return @{ available = $false }
    }

    $extensions = @{}
    foreach ($extension_name in $extension_names) {
        $exists = $PSStyle.FileInfo.Extension.ContainsKey($extension_name)
        $extensions[$extension_name] = @{
            exists = $exists
            value = if ($exists) { $PSStyle.FileInfo.Extension[$extension_name] } else { $null }
        }
    }

    return @{
        available = $true
        extensions = $extensions
        file_info = @{
            directory = $PSStyle.FileInfo.Directory
            executable = $PSStyle.FileInfo.Executable
            symbolic_link = $PSStyle.FileInfo.SymbolicLink
        }
        formatting = @{
            custom_table_header_label = $PSStyle.Formatting.CustomTableHeaderLabel
            debug = $PSStyle.Formatting.Debug
            error = $PSStyle.Formatting.Error
            error_accent = $PSStyle.Formatting.ErrorAccent
            feedback_action = $PSStyle.Formatting.FeedbackAction
            feedback_name = $PSStyle.Formatting.FeedbackName
            feedback_text = $PSStyle.Formatting.FeedbackText
            format_accent = $PSStyle.Formatting.FormatAccent
            table_header = $PSStyle.Formatting.TableHeader
            verbose = $PSStyle.Formatting.Verbose
            warning = $PSStyle.Formatting.Warning
        }
        progress_style = $PSStyle.Progress.Style
    }
}

function _restorePSStyleSnapshot {
    param([hashtable]$snapshot)

    if (-not $snapshot.available) {
        return
    }

    $PSStyle.FileInfo.Directory = $snapshot.file_info.directory
    $PSStyle.FileInfo.Executable = $snapshot.file_info.executable
    $PSStyle.FileInfo.SymbolicLink = $snapshot.file_info.symbolic_link
    foreach ($extension_name in $snapshot.extensions.Keys) {
        $extension = $snapshot.extensions[$extension_name]
        if ($extension.exists) {
            $PSStyle.FileInfo.Extension[$extension_name] = $extension.value
        } else {
            $PSStyle.FileInfo.Extension.Remove($extension_name)
        }
    }
    $PSStyle.Formatting.CustomTableHeaderLabel = $snapshot.formatting.custom_table_header_label
    $PSStyle.Formatting.Debug = $snapshot.formatting.debug
    $PSStyle.Formatting.Error = $snapshot.formatting.error
    $PSStyle.Formatting.ErrorAccent = $snapshot.formatting.error_accent
    $PSStyle.Formatting.FeedbackAction = $snapshot.formatting.feedback_action
    $PSStyle.Formatting.FeedbackName = $snapshot.formatting.feedback_name
    $PSStyle.Formatting.FeedbackText = $snapshot.formatting.feedback_text
    $PSStyle.Formatting.FormatAccent = $snapshot.formatting.format_accent
    $PSStyle.Formatting.TableHeader = $snapshot.formatting.table_header
    $PSStyle.Formatting.Verbose = $snapshot.formatting.verbose
    $PSStyle.Formatting.Warning = $snapshot.formatting.warning
    $PSStyle.Progress.Style = $snapshot.progress_style
}

function _snapshotThemeState {
    $environment_names = @(
        "DELTA_FEATURES"
        "FZF_DEFAULT_OPTS"
        "GLOW_STYLE"
        "LS_COLORS"
        "THEME"
    )
    $global_names = @(
        "bat_theme"
        "catppuccin"
        "current_theme"
        "lazygit_theme"
        "palette"
    )

    $environment = @{}
    foreach ($environment_name in $environment_names) {
        $environment_item = Get-Item -Path "Env:$environment_name" -ErrorAction SilentlyContinue
        $environment[$environment_name] = @{
            exists = $null -ne $environment_item
            value = if ($environment_item) { $environment_item.Value } else { $null }
        }
    }

    $globals = @{}
    foreach ($global_name in $global_names) {
        $global_variable = Get-Variable -Name $global_name -Scope Global -ErrorAction SilentlyContinue
        $globals[$global_name] = @{
            exists = $null -ne $global_variable
            value = if ($global_variable) { $global_variable.Value } else { $null }
        }
    }

    return @{
        apps_use_light_theme = $global:dotfiles_theme_state.apps_use_light_theme
        environment = $environment
        globals = $globals
        ps_readline = _getPSReadLineColors
        ps_style = _getPSStyleSnapshot
    }
}

function _publishThemeState {
    param(
        [hashtable]$candidate,
        [string]$fzf_default_opts,
        [string]$ls_colors,
        [hashtable]$ps_readline_colors
    )

    _applyPSReadLineColors $ps_readline_colors
    _applyPSStyleColors $candidate.catppuccin

    $env:DELTA_FEATURES = $candidate.delta_features
    $env:FZF_DEFAULT_OPTS = $fzf_default_opts
    $env:GLOW_STYLE = $candidate.glow_style
    $env:LS_COLORS = $ls_colors
    $env:THEME = $candidate.mode
    $global:bat_theme = $candidate.bat_theme
    $global:catppuccin = $candidate.catppuccin
    $global:current_theme = $candidate.current_theme
    $global:lazygit_theme = $candidate.lazygit_theme
    $global:palette = $candidate.palette
    $global:dotfiles_theme_state.apps_use_light_theme = $candidate.apps_use_light_theme
}

function _restoreThemeState {
    param([hashtable]$snapshot)

    $rollback_errors = [System.Collections.Generic.List[string]]::new()

    try {
        _applyPSReadLineColors $snapshot.ps_readline
    } catch {
        $rollback_errors.Add("PSReadLine: $($_.Exception.Message)")
    }
    try {
        _restorePSStyleSnapshot $snapshot.ps_style
    } catch {
        $rollback_errors.Add("PSStyle: $($_.Exception.Message)")
    }

    foreach ($environment_name in $snapshot.environment.Keys) {
        $environment = $snapshot.environment[$environment_name]
        try {
            if ($environment.exists) {
                Set-Item -Path "Env:$environment_name" -Value $environment.value
            } else {
                Remove-Item -Path "Env:$environment_name" -ErrorAction SilentlyContinue
            }
        } catch {
            $rollback_errors.Add("${environment_name}: $($_.Exception.Message)")
        }
    }

    foreach ($global_name in $snapshot.globals.Keys) {
        $global_variable = $snapshot.globals[$global_name]
        try {
            if ($global_variable.exists) {
                Set-Variable -Name $global_name -Scope Global -Value $global_variable.value
            } else {
                Remove-Variable -Name $global_name -Scope Global -ErrorAction SilentlyContinue
            }
        } catch {
            $rollback_errors.Add("${global_name}: $($_.Exception.Message)")
        }
    }

    $global:dotfiles_theme_state.apps_use_light_theme = $snapshot.apps_use_light_theme
    if ($rollback_errors.Count -gt 0) {
        throw "Theme rollback failed: $($rollback_errors -join '; ')"
    }
}

function _getWindowsThemeWorker {
    return {
        param(
            [int]$generation,
            [string]$mode,
            [string]$theme_file
        )

        $applied = $false
        $current_theme = $null
        $launched = $false
        $system_uses_light_theme = $null
        $ErrorActionPreference = "Stop"
        $normalized_theme_file = [System.IO.Path]::GetFullPath($theme_file)
        $target_system_uses_light_theme = if ($mode -eq "light") { 1 } else { 0 }
        if (-not (Test-Path -LiteralPath $normalized_theme_file -PathType Leaf)) {
            throw "Windows theme file not found: $normalized_theme_file"
        }

        try {
            Start-Process -FilePath $normalized_theme_file -ErrorAction Stop
            $launched = $true
            for ($attempt = 0; $attempt -lt 5; $attempt++) {
                Start-Sleep -Seconds 10
                $system_uses_light_theme = Get-ItemPropertyValue `
                    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
                    -Name "SystemUsesLightTheme" `
                    -ErrorAction Stop
                if ($system_uses_light_theme -eq $target_system_uses_light_theme) {
                    $applied = $true
                    break
                }
            }
            if (-not $applied) {
                throw "Windows theme did not synchronize SystemUsesLightTheme after five checks: $normalized_theme_file"
            }
            $current_theme = Get-ItemPropertyValue `
                -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" `
                -Name "CurrentTheme" `
                -ErrorAction Stop
        } finally {
            if ($launched) {
                Get-Process -Name "SystemSettings" -ErrorAction SilentlyContinue |
                    ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
            }
        }

        [pscustomobject]@{
            current_theme = $current_theme
            generation = $generation
            mode = $mode
            success = $true
            system_uses_light_theme = $system_uses_light_theme
            theme_file = $normalized_theme_file
        }
    }
}

function _requestWindowsThemeApply {
    param(
        [int]$generation,
        [string]$mode
    )

    if ($mode -notin @("dark", "light")) {
        throw "Unsupported Windows theme mode '$mode'."
    }

    $state = $global:dotfiles_theme_state
    $state.windows_apply_timer.Stop()
    Remove-Event -SourceIdentifier "Dotfiles.WindowsThemeApply" -ErrorAction SilentlyContinue
    $state.windows_generation = $generation
    $state.windows_mode = $mode
    $state.windows_request_armed = $true
    $state.windows_request_at = [DateTime]::UtcNow
    $state.windows_apply_timer.Start()
}

function _completeWindowsThemeJob {
    param([System.Management.Automation.Job]$job)

    $state = $global:dotfiles_theme_state
    if (-not $state -or $job.InstanceId -ne $state.windows_job_instance_id) {
        return
    }

    $completed_generation = $state.windows_job_generation
    $job_errors = @(
        $job.ChildJobs | ForEach-Object {
            $_.Error | ForEach-Object { $_.Exception.Message }
            if ($_.JobStateInfo.Reason) {
                $_.JobStateInfo.Reason.Message
            }
        }
    )
    $results = @($job | Receive-Job -ErrorAction SilentlyContinue)
    $result = $results | Where-Object success | Select-Object -Last 1
    $state.windows_job = $null
    $state.windows_job_generation = -1
    $state.windows_job_instance_id = [guid]::Empty

    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue

    if (-not $result) {
        $message = if ($job_errors.Count -gt 0) {
            $job_errors -join "; "
        } elseif ($results.Count -gt 0) {
            "Windows theme job returned no success result: $($results | ConvertTo-Json -Compress)"
        } else {
            "Windows theme job ended without a success result."
        }
        $Host.UI.WriteWarningLine("Windows theme application failed: $message")
    }

    if ($completed_generation -ne $state.windows_generation -or
        -not $result -or $result.mode -ne $state.windows_mode) {
        if ($completed_generation -ne $state.windows_generation) {
            _requestWindowsThemeApply $state.windows_generation $state.windows_mode
        }
    }
}

function _startWindowsThemeJob {
    param(
        [int]$generation,
        [string]$mode
    )

    $job_name = "Dotfiles.WindowsThemeApplyJob"
    $theme_directory = Join-Path $HOME "AppData\Local\Microsoft\Windows\Themes"
    $state = $global:dotfiles_theme_state
    $theme_file = Join-Path $theme_directory "$mode.theme"

    if ($state.windows_job -and $state.windows_job.State -in @("NotStarted", "Running")) {
        return
    }
    if (-not (Test-Path -LiteralPath $theme_file -PathType Leaf)) {
        throw "Windows theme file not found: $theme_file"
    }

    $worker = _getWindowsThemeWorker
    $job = Start-Job `
        -Name $job_name `
        -ScriptBlock $worker `
        -ArgumentList $generation, $mode, $theme_file `
        -ErrorAction Stop
    $state.windows_job = $job
    $state.windows_job_generation = $generation
    $state.windows_job_instance_id = $job.InstanceId
}

function _removeThemeWatcher {
    $source_identifiers = @(
        "Dotfiles.ThemeChanged"
        "Dotfiles.ThemeRefreshRetry"
        "Dotfiles.WindowsThemeApply"
    )
    $retry_timer = $global:dotfiles_theme_retry_timer
    $state = $global:dotfiles_theme_state
    $windows_timer = $global:dotfiles_windows_theme_timer

    if ($retry_timer) {
        $retry_timer.Stop()
    }
    if ($windows_timer) {
        $windows_timer.Stop()
    }

    foreach ($source_identifier in $source_identifiers) {
        Unregister-Event -SourceIdentifier $source_identifier -ErrorAction SilentlyContinue
        Remove-Event -SourceIdentifier $source_identifier -ErrorAction SilentlyContinue
        Get-Job -ErrorAction SilentlyContinue |
            Where-Object Name -eq $source_identifier |
            Stop-Job -ErrorAction SilentlyContinue
        Get-Job -ErrorAction SilentlyContinue |
            Where-Object Name -eq $source_identifier |
            Remove-Job -Force -ErrorAction SilentlyContinue
    }

    if ($state.windows_job) {
        Stop-Job -Job $state.windows_job -ErrorAction SilentlyContinue
        Remove-Job -Job $state.windows_job -Force -ErrorAction SilentlyContinue
    }
    Get-Job -Name "Dotfiles.WindowsThemeApplyJob" -ErrorAction SilentlyContinue |
        Stop-Job -ErrorAction SilentlyContinue
    Get-Job -Name "Dotfiles.WindowsThemeApplyJob" -ErrorAction SilentlyContinue |
        Remove-Job -Force -ErrorAction SilentlyContinue

    if ($retry_timer) {
        $retry_timer.Dispose()
    }
    if ($windows_timer) {
        $windows_timer.Dispose()
    }

    Remove-Variable dotfiles_theme_retry_timer -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable dotfiles_theme_state -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable dotfiles_windows_theme_timer -Scope Global -ErrorAction SilentlyContinue
}

function _refreshTheme {
    $registry_path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $apps_use_light_theme = Get-ItemPropertyValue -Path $registry_path -Name "AppsUseLightTheme" -ErrorAction Stop

    if ($apps_use_light_theme -eq $global:dotfiles_theme_state.apps_use_light_theme) {
        return $false
    }

    $candidate = _buildThemeState ([int]$apps_use_light_theme)
    $fzf_default_opts = _buildFzfDefaultOpts $candidate.bat_theme $candidate.palette
    $ls_colors = _buildLSColors $candidate.catppuccin
    $ps_readline_colors = _buildPSReadLineColors $candidate.palette
    $snapshot = _snapshotThemeState

    try {
        _publishThemeState $candidate $fzf_default_opts $ls_colors $ps_readline_colors
        _requestWindowsThemeApply $global:dotfiles_theme_state.generation $candidate.mode
    } catch {
        $apply_error = $_
        try {
            _restoreThemeState $snapshot
        } catch {
            $Host.UI.WriteWarningLine("Theme refresh rollback failed: $($_.Exception.Message)")
        }
        throw $apply_error
    }

    return $true
}

function _invokeThemeRefresh {
    param([int]$generation)

    $state = $global:dotfiles_theme_state
    if (-not $state -or $generation -ne $state.generation) {
        return
    }

    try {
        _refreshTheme | Out-Null
        $state.last_error = ""
        $state.retry_armed = $false
        $state.retry_count = 0
        $state.retry_exhausted = $false
        $state.timer.Stop()
    } catch {
        $message = $_.Exception.Message
        if ($message -ne $state.last_error) {
            $Host.UI.WriteWarningLine("Theme refresh failed: $message")
            $state.last_error = $message
        }
        if ($state.retry_count -ge 3) {
            if (-not $state.retry_exhausted) {
                $Host.UI.WriteWarningLine("Theme refresh stopped after three retries.")
                $state.retry_exhausted = $true
            }
            $state.retry_armed = $false
            return
        }

        $state.retry_count++
        $state.retry_armed = $true
        $state.retry_armed_at = [DateTime]::UtcNow
        $state.retry_generation = $generation
        $state.timer.Stop()
        $state.timer.Start()
    }
}

function _registerThemeWatcher {
    param([int]$apps_use_light_theme)

    $change_source = "Dotfiles.ThemeChanged"
    $retry_source = "Dotfiles.ThemeRefreshRetry"
    $windows_source = "Dotfiles.WindowsThemeApply"

    _removeThemeWatcher

    $initial_theme = _buildThemeState $apps_use_light_theme
    $retry_timer = [System.Timers.Timer]::new(1000)
    $retry_timer.AutoReset = $false
    $windows_timer = [System.Timers.Timer]::new(300)
    $windows_timer.AutoReset = $false
    $state = [hashtable]::Synchronized(@{
        apps_use_light_theme = $apps_use_light_theme
        generation = 0
        last_error = ""
        retry_armed = $false
        retry_armed_at = [DateTime]::MinValue
        retry_count = 0
        retry_exhausted = $false
        retry_generation = 0
        timer = $retry_timer
        windows_apply_timer = $windows_timer
        windows_generation = 0
        windows_job = $null
        windows_job_generation = -1
        windows_job_instance_id = [guid]::Empty
        windows_mode = $initial_theme.mode
        windows_request_armed = $false
        windows_request_at = [DateTime]::MinValue
    })
    $global:dotfiles_theme_retry_timer = $retry_timer
    $global:dotfiles_theme_state = $state
    $global:dotfiles_windows_theme_timer = $windows_timer

    Register-ObjectEvent -InputObject $retry_timer -EventName "Elapsed" -SourceIdentifier $retry_source -Action {
        $state = $global:dotfiles_theme_state
        $signal_time = $event.SourceEventArgs.SignalTime.ToUniversalTime()

        if (-not $state -or -not $state.retry_armed) {
            return
        }
        if ($state.retry_generation -ne $state.generation -or $signal_time -lt $state.retry_armed_at) {
            return
        }

        $state.retry_armed = $false
        _invokeThemeRefresh $state.retry_generation
    } | Out-Null

    Register-ObjectEvent -InputObject $windows_timer -EventName "Elapsed" -SourceIdentifier $windows_source -Action {
        $state = $global:dotfiles_theme_state
        $signal_time = $event.SourceEventArgs.SignalTime.ToUniversalTime()

        if (-not $state) {
            return
        }
        if ($state.windows_job) {
            if ($state.windows_job.State -in @("Completed", "Failed", "Stopped")) {
                _completeWindowsThemeJob $state.windows_job
            } else {
                $state.windows_apply_timer.Start()
                return
            }
        }
        if (-not $state.windows_request_armed) {
            return
        }
        if ($signal_time -lt $state.windows_request_at) {
            return
        }

        $state.windows_request_armed = $false
        try {
            _startWindowsThemeJob $state.windows_generation $state.windows_mode
            $state.windows_apply_timer.Start()
        } catch {
            $Host.UI.WriteWarningLine("Windows theme job failed to start: $($_.Exception.Message)")
        }
    } | Out-Null

    $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $key_path = "$sid\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"
    $query = "SELECT * FROM RegistryValueChangeEvent WHERE Hive='HKEY_USERS' AND " +
        "KeyPath='$key_path' AND ValueName='AppsUseLightTheme'"

    Register-CimIndicationEvent -Namespace "root/default" -Query $query -SourceIdentifier $change_source -Action {
        $state = $global:dotfiles_theme_state
        if (-not $state) {
            return
        }

        $state.timer.Stop()
        $state.retry_armed = $false
        Remove-Event -SourceIdentifier "Dotfiles.ThemeRefreshRetry" -ErrorAction SilentlyContinue
        $state.generation++
        $state.retry_count = 0
        $state.retry_exhausted = $false
        _invokeThemeRefresh $state.generation
    } | Out-Null

    _requestWindowsThemeApply $state.windows_generation $state.windows_mode
}

function prompt {
    # Populate $script values
    _populatePrompt

    $separator = @{
        text = $icons.sep_right
    }

    $segments = @(
        @{
            bg = $palette.prompt.dir_icon.bg
            blocks = @{
                text = "$script:dir_icon"
                fg   = $palette.prompt.dir_icon.fg
            }, @{
                text   = "$((Get-Location).ToString().Replace($HOME, "~"))"
                fg     = $palette.prompt.dir_path
            }
        },
        @{
            bg = $palette.prompt.git.bg
            blocks = @{
                text = "$script:git_branch"
                fg   = $palette.prompt.git.branch
                styles = "italic"
            }, @{
                text = "$script:git_sep"
                fg   = $palette.prompt.git.sep
            }, @{
                text = "$script:git_working"
                fg   = $palette.prompt.git.working
            }, @{
                text = "$script:git_index"
                fg   = $palette.prompt.git.index
            }, @{
                text = "$script:git_stash"
                fg   = $palette.prompt.git.stash
            }, @{
                text = "$script:git_sync"
                fg   = $palette.prompt.git.sync
            }
            cond = { return $null -ne $script:git_status }
        },
        @{
            bg = $palette.prompt.long_cmd.bg
            blocks = @{
                text = "$script:cmd_duration"
                fg = $palette.prompt.long_cmd.fg
                styles = "bold"
            }
            cond = { return $script:cmd_duration -ne "" }
        }
    )

    _promptGen $separator $segments
}

# PowerShell output colors (PSStyle requires PowerShell 7.2+)
_applyPSStyleColors $catppuccin
# https://learn.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-7.4#-colors
_applyPSReadLineColors (_buildPSReadLineColors $palette)
try {
    _registerThemeWatcher ([int]$system_theme.AppsUseLightTheme)
} catch {
    _removeThemeWatcher
    $Host.UI.WriteWarningLine("Theme watcher registration failed: $($_.Exception.Message)")
}

Set-PSReadLineOption -ContinuationPrompt "... "

# ─[ Source rg command line completer ]────────────────────────────────
. D:\Scoop\apps\ripgrep\current\complete\_rg.ps1

# ─[ Neovim settings ]─────────────────────────────────────────────────
$env:XDG_CACHE_HOME  = "D:\apps"
$env:XDG_CONFIG_HOME = "D:\apps"
$env:XDG_DATA_HOME   = "D:\apps"
$env:XDG_LOG_HOME    = "D:\apps"
$env:XDG_STATE_HOME  = "D:\apps"

# ─[ Settings ]────────────────────────────────────────────────────────
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit # exit on ^D
$PSNativeCommandUseErrorActionPreference = $false
$env:PSModulePath += ";D:\Dev.aloknigam"
$env:PYTHONPYCACHEPREFIX = "$env:LOCALAPPDATA\Temp"
$env:RUFF_CACHE_DIR = "$env:LOCALAPPDATA\Temp"
$env:LESSUTFCHARDEF="23fb-23fe:p,2665:p,26a1:p,2b58:p,e000-e00a:p,e0a0-e0a2:p,e0a3:p,e0b0-e0b3:p,e0b4-e0c8:p,e0ca:p,e0cc-e0d4:p,e200-e2a9:p,e300-e3e3:p,e5fa-e6a6:p,e700-e7c5:p,ea60-ebeb:p,f000-f2e0:p,f300-f32f:p,f400-f532:p,f500-fd46:p,f0001-f1af0:p" # fix less nerd fond rendering

# ─[ Copilot Settings ]────────────────────────────────────────────────
$env:COPILOT_AUTO_UPDATE = "false"
$env:COPILOT_OTEL_ENABLED = "false"

# ─[ Agency Settings ]─────────────────────────────────────────────────
$env:AGENCY_NO_UPDATE_CHECK  = $true

# ─[ User bin on PATH ]────────────────────────────────────────────────
$env:PATH = "$env:PATH;$HOME\bin"
