# Uninstall Zelda Classic

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$installationDirPath = "C:\Games\Zelda Classic\"

# Archive name
$zipName = '2.53_Win_Release_2-17APRIL2019.zip'

# Prevent uninstall if the game is running (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1 unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "zelda" > $null

# Prevent uninstall if the quest editor is running (so that no progress is lost)
Start-CheckandStop "zquest" > $null

# Stop the launcher
Start-CheckandStop "zlaunch" > $null

# Stop the launcher
Start-CheckandStop "romview-w" > $null

# Inform that user data will not be removed
# (This isn't important, but it's code that I salvaged from an earlier
# version of this script that I learned was needlessly complex.)
# Paths
$questsDirPath = Join-Path "$installationDirPath" -ChildPath "Quests"
$savePath = Join-Path "$installationDirPath" -ChildPath "zc.sav"
# Look for save
$saveExists = Test-Path "$savePath" -PathType Leaf
# Look for custom quests
$questsDirExists = Test-Path "$questsDirPath" -PathType Container
# Remove Quests directory if empty
$empty = -not (Test-Path "$questsDirPath\*")
# Inform of user data non-removal
if ($questsDirExists -and $empty) {
    Write-Verbose "Removing empty 'Quests' directory."
    Remove-Item $questsDirPath
    Write-Verbose "Removed empty 'Quests' directory."
} elseif ($saveExists -and $questsDirExists) {
    Write-Debug "Save found."
    Write-Debug "Quests dir found."
    Write-Warning "Quests and save data will *not* be removed."
    # Pause so that the user have time to read.
    # Chocolatey stops Pause after 30 seconds by default.
    Pause
} elseif ($saveExists) {
    Write-Debug "Save found."
    Write-Warning "Save data will *not* be removed."
    Pause
} elseif ($questsDirExists) {
    Write-Debug "Quests dir found."
    Write-Warning "Custom quests will *not* be removed."
    Pause
}

# Uninstall extracted files
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packagePath = Split-Path -Parent $toolsDirPath
Uninstall-ChocolateyZipPackage -PackageName $packagePath -ZipFileName $zipName

# See if installation directory exists
$dirExists = Test-Path "$installationDirPath" -PathType Container
if ($dirExists) {
    $empty = -not (Test-Path "$installationDirPath\*")
    if (-not $empty) {
        # Inform user if installation directory is not empty.
        $message = "User data remains in the installation directory. `n" + `
            "Manually remove the installation directory if you do not" + `
            "wish to keep the data.`n" + `
            "Installation directory: '$installationDirPath'"
        Write-Warning $message
        Start-Sleep -Seconds 5 # Time to read
    } else {
        # Remove installation directory if empty
        Write-Debug "Installation directory is empty."
        Write-Debug "Removing installation directory."
        Remove-Item "$installationDirPath"
        Write-Debug "Installation directory removed."
    }
}

# Uninstall shortcuts
# Load helper
$helpersDirPath = Join-Path "$toolsDirPath" -ChildPath "helpers"
$InvokeChocoShortcutUninstallationPath = Join-Path "$helpersDirPath" -ChildPath "Invoke-ChocoShortcutUninstallation"
. $InvokeChocoShortcutUninstallationPath
# Remove shortcuts using log created by Invoke-ChocoShortcutInstallation
Invoke-ChocoShortcutUninstallation
