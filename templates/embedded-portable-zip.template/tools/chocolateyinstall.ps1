# Additional installation steps for Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$shortcutName = "$packageName"
$addDesktopShortcut = $true
$addStartMenuShortcut = $true

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## To avoid quoting issues, you might assemble your -Statements in a variable and pass it in
## Example
#$appPath = "$env:ProgramFiles\appname"
##Will resolve to C:\Program Files\appname
#$statementsToRun = "/C `"$appPath\bin\installservice.bat`""
#Start-ChocolateyProcessAsAdmin $statementsToRun cmd -validExitCodes $validExitCodes

# Extract archive
# Paths
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchivePath = Join-Path $toolsDirPath -ChildPath 'example.zip'
$executableDirPath = $toolsDirPath
$executablePath = Join-Path $executableDirPath "$($packageName).exe"
# Arguments
$unzipArgs = @{
  FileFullPath = $zipArchivePath
  Destination  = $toolsDirPath
}
# Unzip file to the specified location - auto overwrites existing content
# - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
Get-ChocolateyUnzip @unzipArgs

## Add specific folders to the path - any executables found in the chocolatey package
## folder will already be on the path.
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
#Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

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

# Add shortcuts
# - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut
if ($addDesktopShortcut -or $addStartMenuShortcut) {
  # XXX
  # TODO Arguments to array
  # TODO Fix unzip call to enable logging
  # TODO Save to log
  # TODO Remove from log in chocolateyuninstall.ps1
  # TODO Rename scripts for letter casing
  # Paths
  $desktopShortcutPath = "$env:UserProfile\Desktop\$shortcutName.lnk"
  $startMenuShortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$shortcutName.lnk"
  $iconPath = Join-Path $executableDirPath -ChildPath "$($packageName).ico"
}
# Add desktop shortcut
if ($addDesktopShortcut) {
  # Arguments
  $desktopShortcutArgs = @{
    shortcutFilePath = $desktopShortcutPath
    targetPath       = $executablePath
    workingDirectory = $executableDirPath
    arguments        = "C:\test.txt"
    iconLocation     = $iconPath
    description      = "This is the description."
  }
  Install-ChocolateyShortcut @desktopShortcutArgs
}
# Add start menu shortcut
if ($addStartMenuShortcut) {
  # Arguments
  $desktopShortcutArgs = @{
    shortcutFilePath = $startMenuShortcutPath
    targetPath       = $executablePath
    workingDirectory = $executableDirPath
    arguments        = "C:\test.txt"
    iconLocation     = $iconPath
    description      = "This is the description."
  }
  Install-ChocolateyShortcut @startMenuShortcutPath
}