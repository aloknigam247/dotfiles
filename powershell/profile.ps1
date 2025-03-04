#          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#          ┃                       Color palette                       ┃
#          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Light theme
$light_palette = @{
    prompt = @{
        dir_icon = @{
            bg = "#DDDDDD"
            fg = "#8467D7"
        }
        dir_path = "#956A71"
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
    cmdline = @{
        command = "#9183EC"
        comment = "#989FCE"
        defaultToken = "#495057"
        emphasis = "#36A1AC"
        keyword = "#6A994E"
        listPrediction = "#DF6C75"
        listPredictionSelected = "#E7ECEF"
        number = "#F24333"
        parameter = "#F42C04"
        selection = "#95AFA4"
        string = "#CA6702"
        variable = "#f77f00"
    }
}

# Dark theme
$dark_palette = @{
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
}

# ╭─────────────────╮
# │ Themes Settings │
# ╰─────────────────╯
$theme = "Light"

if ($theme -eq "Light") {
    $palette = $light_palette
    $bat_theme = "OneHalfLight"
} else {
    $palette = $dark_palette
    $bat_theme = "Visual Studio Dark+"
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
            Remove-Item .git\index.lock # fix lock error
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


# ╭─────────╮
# │ Aliases │
# ╰─────────╯
# ─[ Msys2 ]───────────────────────────────────────────────────────────
New-Alias -Name pacman -Value D:\Scoop\apps\msys2\current\usr\bin\pacman.exe

# ─[ Common ]──────────────────────────────────────────────────────────
New-Alias -Name "/" -Value C:\Users\aloknigam\scoop\shims\rg.exe
New-Alias -Name "//" -Value C:\Users\aloknigam\scoop\shims\fd.exe

# ╭───────────╮
# │ Functions │
# ╰───────────╯
Remove-Alias ls
Remove-Alias rm
# FIX: bat colorscheme for light and dark
function bat  { D:\Scoop\shims\bat.exe --style="numbers,changes" --italic-text=always --theme $bat_theme $args }
function grep { D:\Scoop\apps\msys2\current\usr\bin\grep.exe --color=auto -En $args }
function la   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AF --color=auto $args }
function lla  { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -AlF --color=auto $args }
function ls   { D:\Scoop\apps\msys2\current\usr\bin\ls.exe -F --color=auto $args }
function pdbg { code .; python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client $args }
function rm   { D:\Scoop\apps\msys2\current\usr\bin\rm.exe -rf $args }
function tree { C:\Users\aloknigam\scoop\shims\tre.exe -a $args }
function v    { D:\scoop\shims\neovide.exe --size=1500x1254 --no-tabs --mouse-cursor-icon "i-beam" -- $args }

function e() {
    $code_ext = @("cs", "ps1", "psm1")

    if ($null -eq $args) {
        $ext = ""
    } else {
        $ext = $args.split(".")[-1]
    }

    if ( $null -ne $env:SSH_CLIENT ) {
        nvim @args
    }
    elseif ( $ext -in $code_ext) {
        code @args
    } else {
        v @args
    }
}

function whatis($arg) {
    $cm = Get-Command $arg -ErrorAction SilentlyContinue
    $type = $cm.CommandType

    if ($type -eq "Function") {
        Format-Text "󰊕 $arg" -fg "#FF0022" -styles bold, italic
        $temp_file = "$env:TEMP\tmp.ps1"
        Write-Output $cm.Definition > $temp_file
        bat -p -P $temp_file
        Remove-Item $temp_file
    } elseif ($type -eq "Application") {
        Format-Text " $arg" -fg "#EEE82C" -styles bold, italic
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

# ─[ Git functions ]───────────────────────────────────────────────────
Remove-Alias -Force gc
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

Remove-Alias -Force gl
function gl {
    git log --color=always --pretty="%C(#B4AD2D) %C(#DBD56E)%h %Creset- %C(#88AB75) %s %C(#216E82)󰔟 %ar on %ah %C(#7D7C84)<%C(#ACABB0)%an %C(#7D7C84) %ae>%C(#DE8F6E)%d" $args
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
        $head = "`e[$head" + "m"
        if ($headOnly -eq $true) {
            return $head 
        }
        $head += $text
        if ($noreset -eq $false) {
            $head += "`e[0m"
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
$env:FZF_DEFAULT_OPTS='
    --height=~70% --layout=reverse --border=rounded --border-label=" FZF " --border-label-pos=5 --info=inline --prompt=" " --pointer="➤ " --preview="bat.exe --style=numbers {}" --preview-window="right,70%,border-rounded" --preview-label="(Preview)" --scheme=path --marker=""
    --color=fg:#FFFFFF,bg:-1,hl:#71B7C2
    --color=fg+:#78C5FF,bg+:-1,hl+:#A7DAEB
    --color=info:#AFAF87,prompt:#57EDBB,pointer:#DB2929
    --color=marker:#F0A1A1,spinner:#F2F759,header:#8CCDCF'

# ╭────────────────╮
# │ Prompt Styling │
# ╰────────────────╯
function populatePrompt {
    # Initial executions
    $script:dir_icon = " "
    $script:git_branch = ""
    $script:git_index = ""
    $script:git_stash = ""
    $script:git_sync = ""
    $script:git_working = ""
    $script:git_sep = ""

    $script:git_status = Get-GitStatus

    if ($script:git_status -ne $null) {
        $script:dir_icon = " "

        # git branch
        $git_branch = $script:git_status.Branch
        if ($git_branch.StartsWith("(") -and $git_branch.EndsWith(")")) {
            if ($git_branch.EndsWith("...)")) {
                $script:git_branch = " " + $git_branch.Substring(1, $git_branch.Length - 5)
            } else {
                $script:git_branch = "󰓽 " + $git_branch.Substring(1, $git_branch.Length - 2)
            }
        } else {
            $script:git_branch = " " + $git_branch.Replace("user/$env:username", "~")
        }

        # git dirty check
        if ($script:git_status.HasWorking) {
            $script:git_working = "󰦓 "
        }
        if ($script:git_status.HasIndex) {
            $script:git_index = "󰦓 "
        }
        if ($script:git_status.StashCount) {
            $script:git_stash = "󰪶 "
        }

        # git ahead and behind count
        $git_sync = ""
        if ($script:git_status.AheadBy) {
            $git_sync += "󱦲" + $script:git_status.AheadBy
        }
        if ($script:git_status.BehindBy) {
            $git_sync += "󱦳" + $script:git_status.BehindBy
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
        $script:dir_icon = " "
    } elseif ($env:ODC_LOADED) {
        $script:dir_icon = "󰅟 "
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
        text = ""
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
    "Command" = (Format-Text -headOnly -fg $palette.cmdline.command -styles "bold");
    "Comment" = (Format-Text -headOnly -fg $palette.cmdline.comment);
    "ContinuationPrompt" = (Format-Text -headOnly -fg $palette.cmdline.defaultToken);
    "Default" = (Format-Text -headOnly -fg $palette.cmdline.defaultToken);
    "Emphasis" = (Format-Text -headOnly -fg $palette.cmdline.emphasis);
    "Keyword" = (Format-Text -headOnly -fg $palette.cmdline.keyword -styles "italic");
    "ListPrediction" = (Format-Text -headOnly -fg $palette.cmdline.listPrediction);
    "ListPredictionSelected" = (Format-Text -headOnly -bg $palette.cmdline.listPredictionSelected -styles "bold");
    "Member" = (Format-Text -headOnly -styles "italic");
    "Number" = (Format-Text -headOnly -fg $palette.cmdline.number);
    "Parameter" = (Format-Text -headOnly -fg $palette.cmdline.parameter);
    "Selection" = (Format-Text -headOnly -bg $palette.cmdline.selection);
    "String" = (Format-Text -headOnly -fg $palette.cmdline.string);
    "Variable" = (Format-Text -headOnly -fg $palette.cmdline.variable);
}

Set-PSReadLineOption -ContinuationPrompt "... " -TerminateOrphanedConsoleApps

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