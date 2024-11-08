# Other steps for installing frotz.install with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

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

## Extract archive
## Documantation - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-ChocolateyUnzip.ps1
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

# Install
# Documantation - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyInstallPackage.ps1
# Paths
# In Chocolatey scripts, ALWAYS use absolute paths
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exeInstallerPath = Join-Path $toolsDirPath 'NAME_OF_EMBEDDED_INSTALLER_FILE.exe'
$exeInstaller64Path = Join-Path $toolsDirPath 'NAME_OF_EMBEDDED_INSTALLER_FILE.exe'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath # Will fail on 32-bit systems if missing
  file64         = $exeInstaller64Path
  softwareName   = 'frotz.install*' # Display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = 'INSERT_CHECKSUM'
  checksumType   = 'sha256'
  checksum64     = 'INSERT_CHECKSUM'
  checksumType64 = 'sha256'
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
  #                                 "AutoHotkey (Portable)" - https://community.chocolatey.org/packages/autohotkey.portable
  # Exit codes indicating success
  # validExitCodes = @(0) # NSIS
  # validExitCodes = @(0) # Inno Setup
  # validExitCodes = @(0) # Other; insert other valid exit codes here
}
# Run installer
# Will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs

## Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
## Documantation - https://docs.chocolatey.org/en-us/create/functions/start-chocolateyprocessasadmin
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
