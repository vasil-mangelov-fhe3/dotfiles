${MODULES} = @(
  "PSReadLine"
  , "oh-my-posh"
  , "posh-git"
  , "Pscx"
  , "PSFzf"
  , "Recycle"
  , "Terminal-Icons"
  , "Get-ChildItemColor"
)

function LoadModule (${MODULE}) {
  if (Get-Module | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is imported say nothing
  } elseif (Get-Module -ListAvailable | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is not imported, but available on disk then import
    Import-Module ${MODULE}
  } elseif (Find-Module -Name ${MODULE} | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is not imported, not available on disk, but is in online gallery then install and import
    Install-Module -Name ${MODULE} -Force -Scope CurrentUser
    Import-Module ${MODULE}
  } else {
    # If the module is not imported, not available and not in the online gallery then abort
    write-host "Module ${MODULE} not imported, not available and not in an online gallery, exiting."
  }
}

#Update-Module

foreach (${MODULE} in ${MODULES}) {   
  LoadModule ${MODULE}
}

Set-PoshPrompt -Theme powerlevel10k_rainbow

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadLineKeyHandler  -Key Alt+q `
  -BriefDescription SaveInHistory `
  -LongDescription "Save current line in history but do not execute" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000;

# PSFzf settings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# From https://github.com/Pscx/Pscx
function sudo() {
  Invoke-Elevated @args
}
function reload() {
  & ${PROFILE}
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")