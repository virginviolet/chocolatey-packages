# Other steps for installing windows-frotz.install with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

# Prevent force upgrade if the program is running
# (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1
# unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow -ProcessName "Frotz"

# Install
# Paths
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exeInstallerPath = Join-Path -Path $toolsDirPath -ChildPath 'WindowsFrotzInstaller.exe'
# There is currently no 64-bit version
# $exeInstaller64Path = Join-Path $toolsDirPath 'NAME_OF_EMBEDDED_INSTALLER_FILE.exe'
# Arguments
$packageArgs = @{
  packageName    = "$($packageName)"
  fileType       = 'EXE'
  file           = $exeInstallerPath # Will fail on 32-bit systems if missing
  # file64         = $exeInstaller64Path
  softwareName   = 'Windows Frotz' # Display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = 'fd57458e73f64bdd2204b34ffb7f30125cf36919c6c6ceaa91d61380ca68be80'
  checksumType   = 'sha256'
  # checksum64     = 'INSERT_CHECKSUM'
  checksumType64 = 'sha256'
  # Silent arguments
  silentArgs   = '/S'           # NSIS
  validExitCodes = @(0) # NSIS
}
# Run installer
# Will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs
