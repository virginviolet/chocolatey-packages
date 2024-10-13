# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# Preferences
$ErrorActionPreference = 'Stop' # stop on all error
$installationDir = "C:\Games\Zelda Classic\" # I had issues when installed to package directory
$installDesktopShortcuts = $true
$installStartMenuShortcuts = $true
$shortcutNameGame = "Zelda Classic"
$shortcutNameLauncher = "Zelda Classic Launcher"
$shortcutNameZQuest = "ZQuest"
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
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath '2.53_Win_Release_2-17APRIL2019.zip'
$unzipArgs = @{
  FileFullPath = $zipArchive
  Destination  = $installationDir
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
  $executableGame = Join-Path $installationDir "zelda.exe"
  $executableLauncher = Join-Path $installationDir "zlaunch.exe"
  $executableZQuest = Join-Path $installationDir "zquest.exe"
  # Descriptions
  $descriptionGame = "A tribute to the greatest video game of all time."
  $descriptionLauncher = "Launcher for Zelda Classic."
  $descriptionZQuest = "Game editor for Zelda Classic."
}
# TODO Remove comments
if ($installDesktopShortcuts) {
  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameGame.lnk" -targetPath $executableGame -workingDirectory $installationDir -description $descriptionGame
  
  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameLauncher.lnk" -targetPath $executableLauncher -workingDirectory $installationDir -description $descriptionLauncher

  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameZQuest.lnk" -targetPath $executableZQuest -workingDirectory $installationDir -description $descriptionZQuest
}

if ($installStartMenuShortcuts) {
  ## Add start menu shortcut
  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameGame.lnk" -targetPath $executableGame -workingDirectory $installationDir -description $descriptionGame

  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameLauncher.lnk" -targetPath $executableLauncher -workingDirectory $installationDir -description $descriptionLauncher

  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameZQuest.lnk" -targetPath $executableZQuest -workingDirectory $installationDir -description $descriptionZQuest
}
