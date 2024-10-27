# Other steps for installing [[PackageName]] with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors
# $shortcutName = "$($packageName)"
# $addDesktopShortcut = $true
# $addStartMenuShortcut = $true
# $logShortcuts = $true

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## Outputs the bitness of the OS (either "32" or "64")
## - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
# $osBitness = Get-ProcessorBits

## Install Visual Studio Package - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyvsixpackage
# Install-ChocolateyVsixPackage $packageName $url [$vsVersion] [-checksum $checksum -checksumType $checksumType]
# Install-ChocolateyVsixPackage @packageArgs

## Extract archive
## - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
## Paths
## In Chocolatey scripts, ALWAYS use absolute paths
# $toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
# $zipArchivePath = Join-Path $toolsDirPath -ChildPath 'example.zip'
# # Arguments
# $unzipArgs = @{
#   PackageName  = "$($packageName)"
#   FileFullPath = "$zipArchivePath"
#   Destination  = "$toolsDirPath"
# }
## Unzip file to the specified location - auto overwrites existing content
# Get-ChocolateyUnzip @unzipArgs

# Run EXE installer
# - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
# Paths
# In Chocolatey scripts, ALWAYS use absolute paths
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$exeInstallerPath = Join-Path $toolsDirPath 'NAME_OF_EMBEDDED_INSTALLER_FILE.EXE'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath
  softwareName   = '[[PackageName]]*' # Display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = 'INSERT_CHECKSUM'
  checksumType   = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  checksum64     = 'INSERT_CHECKSUM'
  checksumType64 = 'sha256' # Default is checksumType
  # Silent arguments
  # Uncomment matching installer type (sorted by most to least common)
  # silentArgs   = '/S'           # NSIS
  # silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # silentArgs   = '/s'           # InstallShield
  # silentArgs   = '/s /v"/qn"'   # InstallShield with MSI
  # silentArgs   = '/s'           # Wise InstallMaster
  # silentArgs   = '-s'           # Squirrel
  # silentArgs   = '-q'           # Install4j
  # silentArgs   = '-s'           # Ghost
  # Note that some installers, in addition to the silentArgs above, may also need assistance of AHK to achieve silence.
  # silentArgs   = ''             # None; make silent with input macro script like AutoHotKey (AHK)
  #       https://community.chocolatey.org/packages/autohotkey.portable
  # Exit codes indicating success
  # validExitCodes = @(0) # NSIS
  # validExitCodes = @(0) # Inno Setup
  validExitCodes = @(0) # Other; insert other valid exit codes here
}
# Installer, will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs

## Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
## - https://docs.chocolatey.org/en-us/create/functions/start-chocolateyprocessasadmin
# Start-ChocolateyProcessAsAdmin 'STATEMENTS_TO_RUN' 'Optional_Application_If_Not_PowerShell' -validExitCodes $validExitCodes
## To avoid quoting issues, you can also assemble your -Statements in another variable and pass it in
# $appPath = "$env:ProgramFiles\appname"
# #Will resolve to C:\Program Files\appname
# $statementsToRun = "/C `"$appPath\bin\installservice.bat`""
# Start-ChocolateyProcessAsAdmin $statementsToRun cmd -validExitCodes $validExitCodes

## Add specific folders to the path
## Any executables found in the chocolatey package folder will
## already be on the path. This is used in addition to that or
## for cases when a native installer doesn't add things to the path.
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateypath
# Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

## Set persistent Environment variables
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyenvironmentvariable
# Install-ChocolateyEnvironmentVariable -variableName "SOMEVAR" -variableValue "value" [-variableType = 'Machine' #Defaults to 'User']

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

## Add shortcuts
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut
# if ($addDesktopShortcut -or $addStartMenuShortcut) {
#   # Paths
#   $executableDirPath = $toolsDirPath
#   $executablePath = Join-Path $executableDirPath "$($packageName).exe"
#   $desktopShortcutPath = "$env:UserProfile\Desktop\$shortcutName.lnk"
#   $startMenuShortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$shortcutName.lnk"
#   $iconPath = Join-Path "$installerDirPath" -ChildPath "$($packageName).ico"
#   if ($logShortcuts) {
#     $packagePath = $env:ChocolateyPackageFolder
#     $shortcutsLog = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
#   }
# }
## Add desktop shortcut
# if ($addDesktopShortcut) {
#   # Arguments
#   $desktopShortcutArgs = @{
#     shortcutFilePath = "$desktopShortcutPath"
#     targetPath       = "$executablePath"
#     workingDirectory = "$installerDirPath"
#     arguments        = "C:\test.txt"
#     iconLocation     = "$iconPath"
#     description      = "This is the description."
#   }
#   Install-ChocolateyShortcut @desktopShortcutArgs
#   # Log
#   if ($logShortcuts) {
#     "$desktopShortcutPath" | Out-File "$shortcutsLog" -Append
#   }
# }
## Add start menu shortcut
# if ($addStartMenuShortcut) {
#   # Arguments
#   $startMenuShortcutArgs = @{
#     shortcutFilePath = "$startMenuShortcutPath"
#     targetPath       = "$executablePath"
#     workingDirectory = "$installerDirPath"
#     arguments        = "C:\test.txt"
#     iconLocation     = "$iconPath"
#     description      = "This is the description."
#   }
#   Install-ChocolateyShortcut @startMenuShortcutArgs
#   # Log
#   if ($logShortcuts) {
#     "$startMenuShortcutPath" | Out-File "$shortcutsLog" -Append
#   }
# }
