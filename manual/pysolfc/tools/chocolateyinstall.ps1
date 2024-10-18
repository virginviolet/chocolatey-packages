# Other steps for installing pysolfc with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors

# Run EXE installer
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$ExeInstallerPath = Join-Path $toolsDirPath 'PySolFC_3.0.0_setup.exe'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $ExeInstallerPath
  softwareName   = 'PySol Fan Club edition*' # Display Name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = '66DEB447B2FDC9EA1B32E4E1A920A4BE69301C11CB8337E10CCFBA76AB5CB42F'
  checksumType   = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # No 64-bit version has yet been distributed
  # checksum64     = ''
  # checksumType64 = 'sha256' # Default is checksumType
  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
}
## Installer, will assert administrative rights
## - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
Install-ChocolateyInstallPackage @packageArgs # https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
