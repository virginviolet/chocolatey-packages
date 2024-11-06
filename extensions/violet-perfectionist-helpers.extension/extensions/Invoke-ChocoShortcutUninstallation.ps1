enum VioletUsers {
  Auto
  All
  Current
}

function Invoke-ChocoShortcutUninstallation {
  <#
.SYNOPSIS
Removes shortcut listed in a log created by Invoke-ChocoShortcutUninstallation. 

.NOTES
None

.INPUTS
None

.OUTPUTS
None

.PARAMETER Path
OPTIONAL - Specifies the path log is located. Only necessary if you set a custom path in Invoke-ChocoShortcutInstallation.

.PARAMETER IgnoredArguments
Handles superflous splatted arguments. Do not use directly.

.EXAMPLE
Invoke-ChocoShortcutUninstallation

.EXAMPLE
Invoke-ChocoShortcutUninstallation "C:\logs\Notepad++\shortcuts.txt"

#>
  param(
    [Alias("LogPath")][parameter(Mandatory = $false, Position = 1)][string] $Path = $(Join-Path "$Env:chocolateyPackageFolder" -ChildPath "shortcuts.txt"),
    [parameter(ValueFromRemainingArguments = $true)][Object[]]$IgnoredArguments
  )
  
  # Delete shortcuts
  # Look for shortcuts log
  # TODO Remove duplicate entries
  $logExists = Test-Path "$Path" -PathType Leaf
  if (-not $logExists) {
    Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
  } else {
    Write-Debug "Shortcuts log found."
    # Read log line-per-line and delete files
    $shortcutsLog = Get-Content "$Path"
    foreach ($fileInLog in $shortcutsLog) {
      if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
        try {
          Write-Verbose "Deleted shortcut '$fileInLog'."
          Remove-Item -Path "$fileInLog" -Force
          Write-Debug "Shortcut '$fileInLog' deleted."
        } catch {
          Write-Warning "Could not delete shortcut '$fileInLog'.`n$_"
        }
      }
    }
  }
}
