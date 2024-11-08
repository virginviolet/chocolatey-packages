# Install Zelda Classic

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
$installationDirPath = "C:\Games\Zelda Classic" # I had issues when installed to package directory
$installDesktopShortcuts = $true
$installStartMenuShortcuts = $true
$shortcutBaseNameGame = "Zelda Classic"
$shortcutBaseNameLauncher = "Zelda Classic Launcher"
$shortcutBaseNameZQuest = "ZQuest"
$StartMenuDirectory = "Zelda Classic\"
$desktopDirectory = ""

# Prevent force install or upgrade if the game is running (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1 unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "zelda" > $null

# Prevent force install or upgrade if the quest editor is running (so that no progress is lost)
Start-CheckandStop "zquest"

# Stop the launcher
Start-CheckandStop "zlaunch"

# Stop the launcher
Start-CheckandStop "romview-w"

# Extract archive
# Paths
$zipArchivePath = Join-Path $toolsDirPath -ChildPath '2.53_Win_Release_2-17APRIL2019.zip'
# Arguments
$unzipArgs = @{
  PackageName  = "zelda-classic"
  FileFullPath = $zipArchivePath
  Destination  = $installationDirPath
}
# Extract
Get-ChocolateyUnzip @unzipArgs

## Add shortcuts
# Paths
if ($installDesktopShortcuts -or $installStartMenuShortcuts) {
  # Load helper
  $helpersDirPath = Join-Path "$toolsDirPath" -ChildPath "helpers"
  $InvokeChocoShortcutInstallation = Join-Path "$helpersDirPath" -ChildPath "Invoke-ChocoShortcutInstallation"
  . $InvokeChocoShortcutInstallation

  # Targets
  $executableGamePath = Join-Path $installationDirPath -ChildPath "zelda.exe"
  $executableLauncherPath = Join-Path $installationDirPath -ChildPath "zlaunch.exe"
  $executableZQuestPath = Join-Path $installationDirPath -ChildPath "zquest.exe"
  # Descriptions
  $descriptionGame = "A tribute to the greatest video game of all time."
  $descriptionLauncher = "Launcher for Zelda Classic."
  $descriptionZQuest = "Game editor for Zelda Classic."
}
# Add desktop shortcuts
if ($installDesktopShortcuts) {
  # Game
  Invoke-ChocoShortcutInstallation -Desktop "$desktopDirectory$shortcutBaseNameGame.lnk" `
    -TargetPath $executableGamePath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionGame
  # Launcher
  Invoke-ChocoShortcutInstallation -Desktop "$desktopDirectory$shortcutBaseNameLauncher.lnk" `
    -TargetPath $executableLauncherPath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionLauncher
  # Editor
  Invoke-ChocoShortcutInstallation -Desktop "$desktopDirectory$shortcutBaseNameZQuest.lnk" `
    -TargetPath $executableZQuestPath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionZQuest
}
## Add start menu shortcuts
if ($installStartMenuShortcuts) {
  # Game
  Invoke-ChocoShortcutInstallation -StartMenu "$StartMenuDirectory$shortcutBaseNameGame.lnk" `
    -TargetPath $executableGamePath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionGame
  # Launcher
  Invoke-ChocoShortcutInstallation -StartMenu "$StartMenuDirectory$shortcutBaseNameLauncher.lnk" `
    -TargetPath $executableLauncherPath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionLauncher
  # Editor
  Invoke-ChocoShortcutInstallation -StartMenu "$StartMenuDirectory$shortcutBaseNameZQuest.lnk" `
    -TargetPath $executableZQuestPath `
    -WorkingDirectory $installationDirPath `
    -Description $descriptionZQuest
}
