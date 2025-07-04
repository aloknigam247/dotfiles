# ─[ Don't load for non interactive session ]─────────────────────────────
function IsShellInteractive {
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
if ($(IsShellInteractive) -eq $false) {
    return
}

#          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#          ┃                       Color palette                       ┃
#          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Light theme
$light_palette = @{
    cmdline = @{
        command = "#1E66F5"
        comment = "#8C8FA1"
        defaultToken = "#4C4F69"
        emphasis = "#04A5E5"
        keyword = "#40A02B"
        listPrediction = "#E64553"
        listPredictionSelected = "#E6E9EF"
        number = "#209FB5"
        parameter = "#D20F39"
        selection = "#95AFA4"
        string = "#CA6702"
        type = "#8839EF"
        variable = "#FE640B"
    }
    git = @{
        commit = "#04A5E5"
        commit_icon = "#1E66F5"
        contact_bracket = "#DC8A78"
        head = "#FE640B"
        message = "#40A02B"
        timestamp = "#179299"
        user_email = "#DD7878"
        user_name = "#D20F39"
    }
    prompt = @{
        dir_icon = @{
            bg = "#7287FD"
            fg = "#BBFA0F"
        }
        dir_path = "#EFF1F5"
        git = @{
            bg = "#CCD0DA"
            branch = "#8839EF"
            index = "#DF8E1D"
            sep = "#FFFFFF"
            stash = "#E64553"
            sync = "#40a02b"
            working = "#2B78CA"
        }
    }
}

# Dark theme
$dark_palette = @{
    cmdline = @{
       command = "#9183EC"
       comment = "#989FCE"
       emphasis = "#ECBA82"
       keyword = "#F7F4F3"
       listPrediction = "#C1D37F"
       listPredictionSelected = "#3C6E71"
       number = "#F24333"
       parameter = "#F42C04"
       selection = "#3C6E71"
       string = "#E4FF1A"
    }
    prompt = @{
        dir_icon = @{
            bg = "#736CED"
            fg = "#C5D86D"
        }
        dir_path = "#FEF9FF"
        git = @{
            bg = "#BDBDBD"
            branch = "#FFFFFF"
            index = "#FDD649"
            sep = "#FFFFFF"
            stash = "#DF5601"
            sync = "#BBFA0F"
            working = "#2B78CA"
        }
    }
}

# ╭─────────────────╮
# │ Themes Settings │
# ╰─────────────────╯
$theme = "Light"

if ($theme -eq "Light") {
    $palette = $light_palette
    $bat_theme = "Catppuccin Latte"
    $lazygit_theme = "light.yml"
} else {
    $palette = $dark_palette
    $bat_theme = "Visual Studio Dark+"
    $lazygit_theme = "dark.yml"
}

$palette.fzf = @{
    header = $palette.cmdline.header
    info = $palette.cmdline.comment
    marker = $palette.cmdline.emphasis
    pointer = $palette.cmdline.parameter
    prompt = $palette.cmdline.command
    text_fg = $palette.cmdline.defaultToken
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
            $dt = Get-Date
            git add .
            git commit -m "Updated at $dt"
            Remove-Item .git\index.lock -ErrorAction SilentlyContinue # fix lock error
            git push

            # Send ballon notification
            Add-Type -AssemblyName System.Windows.Forms
            $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
            $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
            $balmsg.BalloonTipText = " "
            $balmsg.BalloonTipTitle = "dotfiles updated"
            $balmsg.Visible = $true
            $balmsg.ShowBalloonTip(20000)
        }
    } | Out-Null
}

 # ╭───────╮
 # │ Icons │
 # ╰───────╯
$icons = @{
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
    odc = "$([char]0xdb84)$([char]0xdf91) " # f1391
    remote = "$([char]0xeb3a) "
    sep_right = "$([char]0xe0b4)"
    type_app = "$([char]0xf120) "
    windows = "$([char]0xe70f) "
}


# ╭─────────╮
# │ Aliases │
# ╰─────────╯
# ─[ Msys2 ]───────────────────────────────────────────────────────────
New-Alias -Name pacman -Value D:\Scoop\apps\msys2\current\usr\bin\pacman.exe -ErrorAction SilentlyContinue

# ─[ Common ]──────────────────────────────────────────────────────────
New-Alias -Name "/" -Value C:\Users\aloknigam\scoop\shims\rg.exe -ErrorAction SilentlyContinue
New-Alias -Name "//" -Value C:\Users\aloknigam\scoop\shims\fd.exe -ErrorAction SilentlyContinue

# ╭───────────────────╮
# │ Generic Functions │
# ╰───────────────────╯
Remove-Item -Force alias:ls -ErrorAction SilentlyContinue
Remove-Item -Force alias:rm -ErrorAction SilentlyContinue
function bat  { D:\Scoop\shims\bat.exe --style="numbers,changes" --italic-text=always --theme $bat_theme $args }
function grep { D:\Scoop\apps\msys2\current\usr\bin\grep.exe --color=auto -En $args }
function la   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AF --color=auto $args }
function lla  { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AlF --color=auto $args }
function ls   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -F --color=auto $args }
function pdbg { code .; python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client $args }
function rm   { D:\Scoop\apps\msys2\current\usr\bin\rm.exe -rf $args }
function tree { C:\Users\aloknigam\scoop\shims\tre.exe -a $args }
function v    { D:\scoop\shims\neovide.exe --size=1500x1230 --no-tabs --mouse-cursor-icon "i-beam" -- $args }
function lazygit { C:\Users\aloknigam\scoop\shims\lazygit.exe -ucf "$env:APPDATA\lazygit\$($lazygit_theme)" }

function e() {
    $code_patterns = @(".*\.cs$", ".*\.ps1$", ".*\.psm1$", "^CMakeLists.txt$")

    # use nvim for SSH
    if ( $null -ne $env:SSH_CLIENT ) {
        nvim @args
        return
    }

    # check for vscode
    $first_arg = $args[0]
    foreach ( $pattern in $code_patterns ) {
        if ($first_arg -match $pattern) {
            code @args
            return
        }
    }

    # default is nvim GUI
    v @args
}

function whatis($arg) {
    $cm = Get-Command $arg -ErrorAction SilentlyContinue
    $type = $cm.CommandType

    if ($type -eq "Function") {
        Format-Text "󰊕 $arg" -fg "#CC001B" -styles bold, italic
        $temp_file = "$env:TEMP\tmp.ps1"
        Write-Output $cm.Definition > $temp_file
        bat -p -P $temp_file
        Remove-Item $temp_file
    } elseif ($type -eq "Application") {
        Format-Text "${icons.type_app} $arg" -fg "#4B7639" -styles bold, italic
        $cm.Source
    } elseif ($type -eq "Alias") {
        Format-Text " $arg" -fg "#5D2E8C" -styles bold, italic
        $cm.DisplayName
    } else {
        Write-Host "Unknown"
    }
}

# ─[ Path functions ]──────────────────────────────────────────────────
function desktop { Set-Location $([Environment]::GetFolderPath("Desktop")) }
function docs { Join-Path $([Environment]::GetFolderPath("Desktop")) "\Docs\Work" | Set-Location }

# ─[ Git functions ]───────────────────────────────────────────────────
Remove-Item -Force alias:gc -ErrorAction SilentlyContinue
function gc {
    git checkout $args
    $stash = git stash list
    if ( $null -ne $stash ) {
        if ( $stash.Gettype() -eq [String] ) {
            Format-Text -bg "#F97068" -fg "#FFFFFF" $stash
        } elseif ( $stash.Gettype() -eq [Object[]] ) {
            foreach ( $st in $stash ) {
                Format-Text -bg "#F97068" -fg "#FFFFFF" $st
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

function gs {
    git status --ignore-submodules=all --short --branch --show-stash --ahead-behind $args
}

function gwa {
    $branch_exists = git rev-parse --verify $args

    if ($branch_exists){
        git worktree add ..\$args
        Set-Location ..\$args
    } else {
        git worktree add ..\$args -b $args
        Set-Location ..\$args
    }
}

function gwd {
    $branch_name = (Get-Location).Path.Split("\")[-1]
    cd ..\main
    git worktree remove $branch_name
    git branch -D $branch_name
}

# ─[ Get TODOs from current directory ]────────────────────────────────
function Get-TODO {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("all", "random", "stats")]
        [String] $type = "All"
    )

    process {
        $tag_list = @("BUG", "DOCME", "FEAT", "FIX", "FIXME", "PERF", "REFACTOR", "TEST", "TODO", "THOUGHT")

        if ($type -eq "All") {
            # Get list of all
            $pattern = $tag_list -join "|"
            rg "($pattern):"  --trim --sort path -nw --color=always
        }
        elseif ($type -eq "Random") {
            # Get random tag
            $pattern = $tag_list -join "|"
            rg "($pattern):"  --trim --sort path -nw --color=always | Get-Random -Count 3
        }
        elseif ($type -eq "Stats") {
            # Generate count per tag
            $tag_map = @{}
            $total = 0
            foreach ($tag in $tag_list) {
                $count = (rg "${tag}:" -cwI | Measure-Object -Sum).Sum
                if ($count -gt 0) {
                    $total += $count
                    $tag_map[$tag] = $count
                }
            }
            Format-Table -AutoSize -HideTableHeaders -InputObject $tag_map
            Write-Host "TOTAL    $total" -ForegroundColor Blue
        }
    }
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

# ╭────────────────╮
# │ Autocompletion │
# ╰────────────────╯
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward # Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward # Autocompletion for arrow keys
try{
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd # Zsh like prediction but advanced
} catch {
    # Write-Error "Error occurred in setting PredictionSource"
    # Write-Error $_
}

# ─[ posh-git ]────────────────────────────────────────────────────────
Import-Module posh-git
$GitPromptSettings.EnableStashStatus = $true

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

# https://minsw.github.io/fzf-color-picker/
$env:FZF_DEFAULT_OPTS="
    --height=~70% --layout=reverse --border=rounded --border-label=' FZF ' --border-label-pos=5 --info=inline --prompt=' ' --pointer='➤ ' --preview='bat.exe --style=numbers --color=always --italic-text=always --theme `"$bat_theme`" {}' --preview-window='right,70%,border-rounded' --preview-label='(Preview)' --scheme=path --marker=' '
    --color=fg:$($palette.fzf.text_fg),bg:-1,hl:#71B7C2
    --color=fg+:$($palette.fzf.pointer),bg+:-1,hl+:#A7DAEB
    --color=info:$($palette.fzf.info),prompt:$($palette.fzf.prompt),pointer:$($palette.fzf.pointer)
    --color=marker:$($palette.fzf.marker),spinner:#F2F759,header:$($palette.fzf.header)
"

# ╭────────────────╮
# │ Prompt Styling │
# ╰────────────────╯
function populatePrompt {
    # Initial executions
    $script:dir_icon = $icons.windows
    $script:git_branch = ""
    $script:git_index = ""
    $script:git_stash = ""
    $script:git_sync = ""
    $script:git_working = ""
    $script:git_sep = ""

    $script:git_status = Get-GitStatus

    if ($script:git_status -ne $null) {
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
}

function promptGen($separator, $segments) {
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

        if ($seg.cond -ne $null) {
            $res = Invoke-Command $seg.cond
            if ($res -eq $false) {
                continue
            }
        }

        $sep_params = $separator.Clone()
        $sep_params.bg = $block_bg
        if ($separator.fg -eq $null) {
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
    if ($separator.fg -eq $null) {
        $sep_params.fg = $sep_fg
    }
    $out += Format-Text @sep_params
    $out += " "

    $ExecutionContext.InvokeCommand.ExpandString($out)
}

function prompt {
    # Populate $script values
    populatePrompt

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
                styles = "bold"
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
            cond = { return $script:git_status -ne $null }
        }
    )

    promptGen $separator $segments
}

# https://learn.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-7.4#-colors
Set-PSReadLineOption -Colors @{
    "Command" = (Format-Text -headOnly -fg $palette.cmdline.command);
    "Comment" = (Format-Text -headOnly -fg $palette.cmdline.comment);
    "ContinuationPrompt" = (Format-Text -headOnly -fg $palette.cmdline.defaultToken);
    "Default" = (Format-Text -headOnly -fg $palette.cmdline.defaultToken);
    "Emphasis" = (Format-Text -headOnly -fg $palette.cmdline.emphasis);
    "Keyword" = (Format-Text -headOnly -fg $palette.cmdline.keyword -styles "italic");
    "Member" = (Format-Text -headOnly -styles "italic");
    "Number" = (Format-Text -headOnly -fg $palette.cmdline.number);
    "Parameter" = (Format-Text -headOnly -fg $palette.cmdline.parameter);
    "Selection" = (Format-Text -headOnly -bg $palette.cmdline.selection);
    "String" = (Format-Text -headOnly -fg $palette.cmdline.string);
    "Type" = (Format-Text -headOnly -fg $palette.cmdline.type);
    "Variable" = (Format-Text -headOnly -fg $palette.cmdline.variable);
}

if (-not $PSVersionTable.PSVersion.ToString().StartsWith("5.1")) {
    Set-PSReadLineOption -Colors @{
        "ListPrediction" = (Format-Text -headOnly -fg $palette.cmdline.listPrediction);
        "ListPredictionSelected" = (Format-Text -headOnly -bg $palette.cmdline.listPredictionSelected -styles "bold");
    }
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

# ╭───────────╮
# │ Utilities │
# ╰───────────╯
# ─[ Autocomplete quotes ]─────────────────────────────────────────────
Set-PSReadLineKeyHandler -Key '"',"'" `
                         -BriefDescription SmartInsertQuote `
                         -LongDescription "Insert paired quotes if not already on a quote" `
                         -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken
    {
        param($tokens, $cursor)

        foreach ($token in $tokens)
        {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

# ─[ Autocomplete brackets ]───────────────────────────────────────────
Set-PSReadLineKeyHandler -Key "(","{","[" `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> "(" { [char]")"; break }
        <#case#> "{" { [char]"}"; break }
        <#case#> "[" { [char]"]"; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    if ($selectionStart -ne -1)
    {
      # Text is selected, wrap it in brackets
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    } else {
      # No text is selected, insert a pair
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ")","]","}" `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

# ─[ Surround by () on selected text or entire line ]──────────────────
Set-PSReadLineKeyHandler -Key "Alt+(" `
                         -BriefDescription ParenthesizeSelection `
                         -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
                         -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, "(" + $line.SubString($selectionStart, $selectionLength) + ")")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "(" + $line + ")")
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
}