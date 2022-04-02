# Install and Import given module
function LoadModule (${MODULE}) {
  if (Get-Module | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is already imported say nothing
  } elseif (Get-Module -ListAvailable | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is not imported, but available on disk then import
    Import-Module ${MODULE}
  } elseif (Find-Module -Name ${MODULE} | Where-Object { $_.Name -eq ${MODULE} }) {
    # If module is not imported, not available on disk, but is in an online gallery then install and import
    Write-Host "Module ${MODULE} will be installed"
    Install-Module -Name ${MODULE} -Force -Scope CurrentUser
    Import-Module ${MODULE}
  } else {
    # If the module is not imported, not available and not in an online gallery then abort
    Write-Host "Module ${MODULE} not imported, not available and not in an online gallery, exiting."
  }
}

# Clear current command line but save in history
function SaveInHistory {
  $LINE = $null
  $CURSOR = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]${LINE}, [ref]${CURSOR})
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory(${LINE})
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# Compute file hashes - useful for checking successful downloads
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# From https://github.com/Pscx/Pscx
function sudo() { Invoke-Elevated @args }

# Reload profile
function reload() { & ${PROFILE} }
