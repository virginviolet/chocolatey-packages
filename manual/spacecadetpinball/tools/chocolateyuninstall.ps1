# Other steps for uninstalling spacecadetpinball with Chocolatey

# This script is required for Chocolatey to remove the shortcuts

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$packagePath = "$(Split-Path -Parent "$toolsDirPath")"

# Preferences
$removeShortcuts = $true
$installationDirName = '3D Pinball x64'
$installationDirPath = Join-Path -Path "$toolsDirPath" -ChildPath "$installationDirName"

# Remove shortcuts
# Look for shortcuts log
$shortcutsLogPath = Join-Path -Path "$packagePath" -ChildPath "shortcuts.txt"
$exists = Test-Path -LiteralPath "$shortcutsLogPath" -PathType Leaf
if ($removeShortcuts -and -not $exists) {
    Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
} elseif ($exists) {
    Write-Debug "Shortcuts log found."
    # Read log line-per-line and remove files
    $shortcutsLog = Get-Content -Path "$shortcutsLogPath"
    foreach ($fileInLog in $shortcutsLog) {
        if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
            try {
                Write-Debug "Removing shortcut '$fileInLog'."
                Remove-Item -Path "$fileInLog" -Force
                Write-Debug "Removed shortcut '$fileInLog'."
            } catch [System.Management.Automation.ItemNotFoundException] {
                # Prevent warning when trying to remove a
                # shortcut in install directory
                $shortcutDirPath = $(Split-Path -Path "$fileInLog")
                if ($shortcutDirPath -eq $installationDirPath) {
                    $message = "Shortcut '$fileInLog' has already been " + `
                        "removed."
                    Write-Debug $message
                } else {
                    Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
                }
            } catch {
                Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
            }
        }
    }
}

# Check whether the game data directory exists, and if it is empty
$gameDataDirPath = Join-Path -Path "$env:APPDATA" -ChildPath 'SpaceCadetPinball'
$exists = (Test-Path "$gameDataDirPath" -PathType Container)
$empty = -not (Test-Path "$gameDataDirPath\*")
if ($exists -and -not $empty) {
    # Inform user that the game data directory is not empty
    $message = "Data remains in the game data directory (highscore and " + `
        "settings).`n" + `
        "Manually remove the directory if you do not wish" + `
        "to keep the data.`n" + `
        "Game data directory: '$gameDataDirPath'"
    Write-Warning "$message"
    Start-Sleep -Seconds 5 # Time to read
}
elseif ($exists -and $empty) {
    # Remove the game data directory if it is empty (edge case)
    Write-Debug "Game data directory is empty."
    Write-Debug "Removing Game data directory."
    Remove-Item -LiteralPath "$gameDataDirPath"
    Write-Debug "Game data directory directory removed."
} elseif (-not $exists) {
    Write-Debug "Game data directory (settings and highscore) not found."
}
