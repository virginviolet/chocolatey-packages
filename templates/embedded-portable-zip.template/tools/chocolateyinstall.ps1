# Other steps for installing [[PackageName]] with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$shortcutName = "$($packageName)"
$addDesktopShortcut = $true
$addStartMenuShortcut = $true
$logShortcuts = $true
# $installationDirPath = 'C:\Tools\[[PackageName]]'
$installationDirPath = $toolsDirPath

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## Outputs the bitness of the OS (either "32" or "64")
## - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
# $osBitness = Get-ProcessorBits

## Install Visual Studio Package - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyvsixpackage
# Install-ChocolateyVsixPackage $packageName $url [$vsVersion] [-checksum $checksum -checksumType $checksumType]
# Install-ChocolateyVsixPackage @packageArgs

# Extract archive
# - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
# Paths
# In Chocolatey scripts, ALWAYS use absolute paths
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchivePath = Join-Path $toolsDirPath -ChildPath 'NAME_OF_EMBEDDED_ZIP_FILE.zip'
# Arguments
$unzipArgs = @{
  PackageName  = "$($packageName)"
  FileFullPath = "$zipArchivePath"
  Destination  = "$installationDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @unzipArgs

## Add specific folders to the path
## Any executables found in the chocolatey package folder will
## already be on the path. This is used in addition to that or
## for cases when a native installer doesn't add things to the path.
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
#Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

## Set persistent Environment variables
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyenvironmentvariable
#Install-ChocolateyEnvironmentVariable -variableName "SOMEVAR" -variableValue "value" [-variableType = 'Machine' #Defaults to 'User']

## Adding a shim when not automatically found - Chocolatey automatically shims exe files found in package directory.
## - https://docs.chocolatey.org/en-us/create/functions/install-binfile
## - https://docs.chocolatey.org/en-us/create/create-packages#how-do-i-exclude-executables-from-getting-shims
# Install-BinFile

## Set up file association
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyfileassociation
# Install-ChocolateyFileAssociation

## Other needs: use regular PowerShell to do so, or see if it can be accomplished with the helper functions
## - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## - https://community.chocolatey.org/packages?q=id%3A.extension for examples and availability.

# Add shortcuts
# - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut
if ($addDesktopShortcut -or $addStartMenuShortcut) {
  # Paths
  $executableDirPath = $toolsDirPath
  $executablePath = Join-Path $executableDirPath "$($packageName).exe"
  $desktopShortcutPath = "$env:UserProfile\Desktop\$shortcutName.lnk"
  $startMenuShortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$shortcutName.lnk"
  $iconPath = Join-Path "$executableDirPath" -ChildPath "$($packageName).ico"
  if ($logShortcuts) {
    $packagePath = $env:ChocolateyPackageFolder
    $shortcutsLog = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
  }
}
# Add desktop shortcut
if ($addDesktopShortcut) {
  # Arguments
  $desktopShortcutArgs = @{
    shortcutFilePath = "$desktopShortcutPath"
    targetPath       = "$executablePath"
    workingDirectory = "$executableDirPath"
    arguments        = "C:\test.txt"
    iconLocation     = "$iconPath"
    description      = "This is the description."
  }
  Install-ChocolateyShortcut @desktopShortcutArgs
  # Log
  if ($logShortcuts) {
    "$desktopShortcutPath" | Out-File "$shortcutsLog" -Append
  }
}
# Add start menu shortcut
if ($addStartMenuShortcut) {
  # Arguments
  $startMenuShortcutArgs = @{
    shortcutFilePath = "$startMenuShortcutPath"
    targetPath       = "$executablePath"
    workingDirectory = "$executableDirPath"
    arguments        = "C:\test.txt"
    iconLocation     = "$iconPath"
    description      = "This is the description."
  }
  Install-ChocolateyShortcut @startMenuShortcutArgs
  # Log
  if ($logShortcuts) {
    "$startMenuShortcutPath" | Out-File "$shortcutsLog" -Append
  }
}
