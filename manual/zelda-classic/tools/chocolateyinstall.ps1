# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# Preferences
$ErrorActionPreference = 'Stop' # stop on all error
$installationDirPath = "C:\Games\Zelda Classic" # I had issues when installed to package directory
$installDesktopShortcuts = $true
$installStartMenuShortcuts = $true
$logShortcuts = $true
$shortcutBaseNameGame = "Zelda Classic"
$shortcutBaseNameLauncher = "Zelda Classic Launcher"
$shortcutBaseNameZQuest = "ZQuest"
$StartMenuDirectory = "Zelda Classic\"
$desktopDirectory = ""

# Prevent uninstall if the game is running, so that no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
# [x] Test
Start-CheckandThrow "zelda" > $null

# Prevent uninstall if the quest editor is running, so that no progress is lost
# [x] Test
Start-CheckandStop "zquest" > $null

# Stop the launcher
# [x] Test
Start-CheckandStop "zlaunch" > $null

# Stop the launcher
# [x] Test
Start-CheckandStop "romview-w" > $null

# Extract archive
# [x] Test
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchivePath = Join-Path $toolsDirPath -ChildPath '2.53_Win_Release_2-17APRIL2019.zip'
$unzipArgs = @{
  PackageName  = "zelda-classic"
  FileFullPath = $zipArchivePath
  Destination  = $installationDirPath
}
# Extract archive
Get-ChocolateyUnzip @unzipArgs

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## To avoid quoting issues, you can also assemble your -Statements in another variable and pass it in
#$appPath = "$env:ProgramFiles\appname"
##Will resolve to C:\Program Files\appname
#$statementsToRun = "/C `"$appPath\bin\installservice.bat`""
#Start-ChocolateyProcessAsAdmin $statementsToRun cmd -validExitCodes $validExitCodes

## add specific folders to the path - any executables found in the chocolatey package
## folder will already be on the path.
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
#Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

## Add desktop shortcuts
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
}
# TODO Remove comments
if ($logShortcuts -and ($installDesktopShortcuts -or $installStartMenuShortcuts)) {
  $shortcutsLog = Join-Path "$env:ChocolateyPackageFolder" -ChildPath "shortcuts.txt"
}
if ($installDesktopShortcuts) {
  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameGame.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableGamePath -workingDirectory $installationDirPath -description $descriptionGame
  if ($logShortcuts) {
    $shortcutsLog = Join-Path "$env:ChocolateyPackageFolder" -ChildPath "shortcuts.txt"
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }

  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameLauncher.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableLauncherPath -workingDirectory $installationDirPath -description $descriptionLauncher
  if ($logShortcuts) {
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }
  
  $shortcutDesktop = "$env:UserProfile\Desktop\$desktopDirectory$shortcutBaseNameZQuest.lnk"
  Install-ChocolateyShortcut -shortcutFilePath $shortcutDesktop -targetPath $executableZQuestPath -workingDirectory $installationDirPath -description $descriptionZQuest
  if ($logShortcuts) {
    "$shortcutDesktop" | Out-File "$shortcutsLog" -Append
  }
}

if ($installStartMenuShortcuts) {
  ## Add start menu shortcut
  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameGame.lnk" 
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableGamePath -workingDirectory $installationDirPath -description $descriptionGame
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }

  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameLauncher.lnk"
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableLauncherPath -workingDirectory $installationDirPath -description $descriptionLauncher
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }

  $shortcutStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutBaseNameZQuest.lnk"
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutStart -targetPath $executableZQuestPath -workingDirectory $installationDirPath -description $descriptionZQuest
  if ($logShortcuts) {
    "$shortcutStart" | Out-File "$shortcutsLog" -Append
  }
}
