# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors
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
# [ ] Test
Start-CheckandThrow "zelda" > $null

# Prevent uninstall if the quest editor is running, so that no progress is lost
# [ ] Test
Start-CheckandThrow "zquest" > $null

# Stop the launcher
# [ ] Test
Start-CheckandStop "zlaunch" > $null

# Extract archive
# [ ] Test
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath '2.53_Win_Release_2-17APRIL2019.zip'
$executableDir = $toolsDir
$unzipArgs = @{
  FileFullPath = $zipArchive
  Destination  = $toolsDir
}
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
  $executableGame = Join-Path $executableDir "zelda.exe"
  $executableLauncher = Join-Path $executableDir "zlaunch.exe"
  $executableZQuest = Join-Path $executableDir "zquest.exe"
  # Descriptions
  $descriptionGame = "A tribute to the greatest video game of all time."
  $descriptionLauncher = "Launcher for Zelda Classic."
  $descriptionZQuest = "Game editor for Zelda Classic."
}
# TODO Remove comments
if ($installDesktopShortcuts) {
  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameGame.lnk" -targetPath $executableGame -workingDirectory $executableDir -description $descriptionGame
  
  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameLauncher.lnk" -targetPath $executableLauncher -workingDirectory $executableDir -description $descriptionLauncher

  Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\$desktopDirectory$shortcutNameZQuest.lnk" -targetPath $executableZQuest -workingDirectory $executableDir -description $descriptionZQuest
}

if ($installStartMenuShortcuts) {
  ## Add start menu shortcut
  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameGame.lnk" -targetPath $executableGame -workingDirectory $executableDir -description $descriptionGame

  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameLauncher.lnk" -targetPath $executableLauncher -workingDirectory $executableDir -description $descriptionLauncher

  Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$startmenuDirectory$shortcutNameZQuest.lnk" -targetPath $executableZQuest -workingDirectory $executableDir -description $descriptionZQuest
}


## Outputs the bitness of the OS (either "32" or "64")
## - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
#$osBitness = Get-ProcessorBits

## Set persistent Environment variables
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyenvironmentvariable
#Install-ChocolateyEnvironmentVariable -variableName "SOMEVAR" -variableValue "value" [-variableType = 'Machine' #Defaults to 'User']

## Set up a file association
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyfileassociation
#Install-ChocolateyFileAssociation

## Adding a shim when not automatically found - Chocolatey automatically shims exe files found in package directory.
## - https://docs.chocolatey.org/en-us/create/functions/install-binfile
## - https://docs.chocolatey.org/en-us/create/create-packages#how-do-i-exclude-executables-from-getting-shims
#Install-BinFile

## Other needs: use regular PowerShell to do so or see if there is a function already defined
## - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## - https://community.chocolatey.org/packages?q=id%3A.extension for examples and availability.
