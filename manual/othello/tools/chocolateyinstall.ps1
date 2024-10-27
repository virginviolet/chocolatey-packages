# Other steps for installing othello with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

# Run EXE installer
# Paths
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$exeInstallerPath = Join-Path $toolsDirPath 'Othello_Setup.exe'
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath
  softwareName   = 'Othello version*' # Display name as it appears in "Installed apps" or "Programs and Features".
  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
  checksum       = '1D0EA3FDC4160FD79FD39969EA568BDBDCE745FDEFEF13449AEBED07B18105C1'
  checksumType   = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
}
# Run installer
Install-ChocolateyInstallPackage @packageArgs
