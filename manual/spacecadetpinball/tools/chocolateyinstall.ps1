# Other steps for installing spacecadetpinball with Chocolatey

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
# Note: If you change installation directory name, the original game directory
# and decompile directory will not merge.
$installationDirName = '3D Pinball x64'
# Note: If you install outside the package directory, the auto-uninstaller will
# not work; create an uninstallation script.
$installationDirPath = Join-Path "$toolsDirPath" "$installationDirName"
# $installationDirPath = 'C:\Games\spacecadetpinball'
$shortcutName = 'Pinball'
$addDesktopShortcut = $true
$addStartMenuShortcut = $true
$addGameDirShortcut = $true
$logShortcuts = $true

## Helper functions
## These have error handling tucked into them already
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## Source code - https://github.com/chocolatey/choco/tree/master/src/chocolatey.resources/helpers/functions

## Outputs the bitness of the OS (either "32" or "64")
## Documantation - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-OSArchitectureWidth.ps1
# $osBitness = Get-ProcessorBits

## Install Visual Studio Package
## Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyvsixpackage
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyVsixPackage.ps1
# Install-ChocolateyVsixPackage $packageName $url [$vsVersion] [-checksum $checksum -checksumType $checksumType]
# Install-ChocolateyVsixPackage @packageArgs

# Download and unpack a zip file
# Documentation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyzippackage
# Source code - 
# Path
$url = 'https://ia902303.us.archive.org/28/items/3d-pinball-x64/3D%20Pinball%20x64.zip'
$unzipDirPath = Split-Path $installationDirPath
# Arguments
$originalGameArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $unzipDirPath
  url           = $url
  checksum      = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  checksumType  = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # checksum64    = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  # checksumType64= 'sha256' # Default is checksumType
}
Install-ChocolateyZipPackage @originalGameArgs

# Extract decompilation archive
# Documantation - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-ChocolateyUnzip.ps1
# Paths
$zipArchivePath = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx86Win.zip'
$zipArchive64Path = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx64Win.zip'
# Arguments
$decompiledArgs = @{
  PackageName    = "$($packageName)"
  FileFullPath   = "$zipArchivePath"
  FileFullPath64 = "$zipArchive64Path"
  Destination    = "$installationDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @decompiledArgs

## Add specific folders to the path
## Any executables found in the chocolatey package folder will
## already be on the path. This is used in addition to that or
## for cases when a native installer doesn't add things to the path.
## Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
# Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

## Set persistent Environment variables
## Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyenvironmentvariable
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyEnvironmentVariable.ps1
# Install-ChocolateyEnvironmentVariable -variableName "SOMEVAR" -variableValue "value" [-variableType = 'Machine' #Defaults to 'User']

## Adding a shim when not automatically found - Chocolatey automatically shims exe files found in package directory.
## Guide - https://docs.chocolatey.org/en-us/create/create-packages#how-do-i-exclude-executables-from-getting-shims
## Documantation - https://docs.chocolatey.org/en-us/create/functions/install-binfile
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-BinFile.ps1
# Install-BinFile

## Set up file association
## Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyfileassociation
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyFileAssociation.ps1
# Install-ChocolateyFileAssociation

## Other needs: use regular PowerShell to do so, or see if it can be accomplished with the helper functions
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## See here for examples and availability: https://community.chocolatey.org/packages?q=id%3A.extension

# Add shortcuts
# Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyShortcut.ps1
if ($addDesktopShortcut -or $addStartMenuShortcut) {
  # Paths
  $executableDirPath = $installationDirPath
  $executablePath = Join-Path "$installationDirPath" -ChildPath 'SpaceCadetPinball.exe'
  $desktopShortcutPath = "$env:UserProfile\Desktop\$shortcutName.lnk"
  $startMenuShortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Games\$shortcutName.lnk"
  $gameDirShortcutPath = Join-Path "$installationDirPath" -ChildPath "Launch $shortuctName.lnk"
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
    description      = "Begins a game of 3-D Pinball."
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
    description      = "Begins a game of 3-D Pinball."
  }
  Install-ChocolateyShortcut @startMenuShortcutArgs
  # Log
  if ($logShortcuts) {
    "$startMenuShortcutPath" | Out-File "$shortcutsLog" -Append
  }
}
  # Add game directory shortcut
  if ($addGameDirShortcut) {
    # Arguments
    $gameDirShortcutArgs = @{
      shortcutFilePath = "$gameDirShortcutPath"
      targetPath       = "$executablePath"
      workingDirectory = "$executableDirPath"
      description      = "Begins a game of 3-D Pinball."
    }
    Install-ChocolateyShortcut @gameDirShortcutArgs
    # Log
    if ($logShortcuts) {
      "$gameDirShortcutPath" | Out-File "$shortcutsLog" -Append
    }
}
