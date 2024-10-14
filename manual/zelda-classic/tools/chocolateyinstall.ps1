# Install Zelda Classic

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$installationDirPath = "C:\Games\Zelda Classic" # I had issues when installed to package directory
$installDesktopShortcuts = $true
$installStartMenuShortcuts = $true
$logShortcuts = $true
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
Start-CheckandStop "zquest" > $null

# Stop the launcher
Start-CheckandStop "zlaunch" > $null

# Stop the launcher
Start-CheckandStop "romview-w" > $null

# Extract archive
# Paths
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
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
  # Targets
  $executableGamePath = Join-Path $installationDirPath -ChildPath "zelda.exe"
  $executableLauncherPath = Join-Path $installationDirPath -ChildPath "zlaunch.exe"
  $executableZQuestPath = Join-Path $installationDirPath -ChildPath "zquest.exe"
  # Descriptions
  $descriptionGame = "A tribute to the greatest video game of all time."
  $descriptionLauncher = "Launcher for Zelda Classic."
  $descriptionZQuest = "Game editor for Zelda Classic."
  if ($logShortcuts) {
    $shortcutsLog = Join-Path "$env:ChocolateyPackageFolder" -ChildPath "shortcuts.txt"
  }
}
# Add desktop shortcuts
if ($installDesktopShortcuts) {
  # Game
  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameGame.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableGamePath -workingDirectory $installationDirPath -description $descriptionGame
  if ($logShortcuts) {
    $shortcutsLog = Join-Path "$env:ChocolateyPackageFolder" -ChildPath "shortcuts.txt"
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }
  # Launcher
  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameLauncher.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableLauncherPath -workingDirectory $installationDirPath -description $descriptionLauncher
  if ($logShortcuts) {
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }
  # Editor
  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameZQuest.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableZQuestPath -workingDirectory $installationDirPath -description $descriptionZQuest
  if ($logShortcuts) {
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }
}
## Add start menu shortcuts
if ($installStartMenuShortcuts) {
  # Game
  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameGame.lnk" 
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableGamePath -workingDirectory $installationDirPath -description $descriptionGame
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }
  # Launcher
  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameLauncher.lnk"
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableLauncherPath -workingDirectory $installationDirPath -description $descriptionLauncher
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }
  # Editor
  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameZQuest.lnk"
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableZQuestPath -workingDirectory $installationDirPath -description $descriptionZQuest
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }
}
