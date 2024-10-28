# Other steps for installing spacecadetpinball with Chocolatey

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
$installationDirPath = Join-Path "$toolsDirPath" '3D Pinball'
# $installationDirPath = 'C:\Games\spacecadetpinball'
$shortcutName = "$($packageName)"
$addDesktopShortcut = $true
$addStartMenuShortcut = $true
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
# Arguments
$originalGameArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $installationDirPath
  url           = $url
  checksum      = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  checksumType  = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # checksum64    = 'AF6B1B5A3C0B9D13C58DFEFC937982A0357D209962A81003B11C8FA58EF56329'
  # checksumType64= 'sha256' # Default is checksumType
}
Install-ChocolateyZipPackage @originalGameArgs

# Rename extracted directory
$extractedDirectory = Join-Path $installationDirPath -ChildPath '3D Pinball x64'
$installationDirName = Split-Path "$installationDirPath" -Leaf
Write-Output "Renaming '$extractedDirectory' to '$installationDirName'..."
Pause
Rename-Item "$extractedDirectory" -NewName "$installationDirName"
Write-Debug "Renamed '$extractedDirectory' to '$installationDirName'."
Pause

# Prevent incorrect shimming
# by creating a '.ignore' file and a '.gui' file
$executableDirPath = Join-Path "$installationDirPath" # Also used for shortcuts
$dotIgnorePath = Join-Path "$executableDirPath" -ChildPath 'PINBALL.exe.ignore'
$dotGuiPath = Join-Path "$executableDirPath" -ChildPath 'SpaceCadetPinball.exe.gui'
Write-Verbose "Creating file '$dotIgnorePath'..."
New-Item -Path "$dotIgnorePath" -ItemType File > $null
Write-Debug "File '$dotIgnorePath' created."
Write-Verbose "Creating file '$dotGuiPath'..."
New-Item -Path $dotGuiPath -ItemType File > $null
Write-Debug "File '$dotGuiPath' created."

Pause

# Extract archive
# Documantation - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-ChocolateyUnzip.ps1
# Paths
# In Chocolatey scripts, ALWAYS use absolute paths
$zipArchivePath = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx86Win.zip'
$zipArchive64Path = Join-Path $toolsDirPath -ChildPath 'SpaceCadetPinballx64Win.zip'
# Arguments
$unzipArgs = @{
  PackageName    = "$($packageName)"
  FileFullPath   = "$zipArchivePath"
  FileFullPath64 = "$zipArchive64Path"
  Destination    = "$installationDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @unzipArgs

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
<# 
# Add shortcuts
# Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyShortcut.ps1
if ($addDesktopShortcut -or $addStartMenuShortcut) {
  # Paths
  $executablePath = Join-Path "$executableDirPath" -ChildPath 'PINBALL.exe.ignore'
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
 #>