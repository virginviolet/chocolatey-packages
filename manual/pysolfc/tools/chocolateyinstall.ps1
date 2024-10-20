# Other steps for installing pysolfc with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors

# Run EXE installer
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$exeInstallerPath = Join-Path $toolsDirPath 'PySolFC_3.1.0_setup.exe'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath
  softwareName   = 'PySol Fan Club edition*' # Display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = 'CDAE0B60A48C6A7C763BC549AA71FB52C586E2C5C4652B78DD4178953020F489'
  checksumType   = 'sha256'
  # No 64-bit version has yet been distributed
  # checksum64     = ''
  # checksumType64 = 'sha256'
  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
}
## Installer, will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs
