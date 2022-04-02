# Set Aliases (need to be first to make completion work)
Set-Alias k -Value kubectl
Set-Alias kns -Value Select-KubeNamespace
Set-Alias kctx -Value Select-KubeContext

# Set Profile Path
#$PROFILE_PATH = Split-Path -Path ${PROFILE}
$SCRIPT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
# Source functions
. "${SCRIPT_PATH}\Profile_Functions.ps1"
. "${SCRIPT_PATH}\Kubectl_Completion.ps1"

# Define modules to be used
${MODULES} = @(
  'PSReadLine'
  , 'oh-my-posh'
  , 'posh-git'
  , 'Pscx'
  , 'PSFzf'
  , 'Recycle'
  , 'Terminal-Icons'
  , 'GuiCompletion'
  , 'PSKubeContext'
)

#Update-Module

# Load Modules and install if necessary
foreach (${MODULE} in ${MODULES}) { LoadModule ${MODULE} }

# Set Powershell Theme
Set-PoshPrompt -Theme powerlevel10k_rainbow

# Set PSReadLine options
Set-PSReadLineOption -PredictionSource History

# Set Keyhandlers
#Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-GuiCompletion }
#Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion -CaseInsensitive}
Set-PSReadLineKeyHandler -Key Ctrl+d -Function ViExit
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+q -ScriptBlock { SaveInHistory }

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000;

# PSFzf settings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Reload $env:PATH
${ENV:PATH} = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Register Completions
Register-PSKubeContextComplete
