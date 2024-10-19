# Additional steps for installing vpinball with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors
$patchInstallDirPath = "C:\Visual Pinball"

# Prevent force install or upgrade if the program is running (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1 unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "VPinball8" > $null
Start-CheckandThrow "VPinball99_PhysMod5_Updated" > $null
Start-CheckandThrow "VPinball921" > $null
Start-CheckandThrow "VPinball995" > $null
Start-CheckandThrow "VPinballX" > $null
Start-CheckandThrow "PinMAME" > $null
Start-CheckandThrow "PinMAME32" > $null
Start-CheckandThrow "UltraDMD" > $null

# Prevent force install or upgrade if the FlexDMD install tool is running
Start-CheckandThrow "FlexDMDUI" > $null

# Stop VPinMame Test
Start-CheckandStop "VPinMameTest" > $null

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## Outputs the bitness of the OS (either "32" or "64")
## - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
# $osBitness = Get-ProcessorBits

## Install Visual Studio Package - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyvsixpackage
# Install-ChocolateyVsixPackage $packageName $url [$vsVersion] [-checksum $checksum -checksumType $checksumType]
# Install-ChocolateyVsixPackage @packageArgs

# Run EXE installer
# - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$ExeInstallerPath = Join-Path $toolsDirPath 'Main.Download.Installer.-.VPX72setup.exe'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $ExeInstallerPath
  softwareName   = 'Visual Pinball*' # The display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = '9661673BD65D3B5E201F8FC7DD6215643BB07D70599B4C232465B6E915505475'
  checksumType   = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # There is only a 64-bit developer build currently
  # checksum64     = 'INSERT_CHECKSUM'
  # checksumType64 = 'sha256' # Default is checksumType
  # Silent arguments
  # Uncomment matching installer type (sorted by most to least common)
  silentArgs   = '/S'           # NSIS
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
  validExitCodes = @(0) # NSIS
}
# Installer, will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs

# Extract archive
# - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
Write-Host "Installing patch for $($packageName)..."
# Paths
$zipArchivePath = Join-Path $toolsDirPath -ChildPath 'VPinballX73_Minimal.zip'
# Arguments
$unzipArgs = @{
  PackageName  = "$($packageName)"
  FileFullPath = "$zipArchivePath"
  Destination  = "$patchInstallDirPath"
}
# Unzip file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @unzipArgs
Write-Host "$($packageName) has been patched."

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
