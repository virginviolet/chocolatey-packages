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

# Run EXE installer
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
  # Silent argument
  silentArgs   = '/S'           # NSIS
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
