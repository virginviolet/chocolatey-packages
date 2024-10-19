﻿# Other steps for uninstalling pysolfc with Chocolatey

# Uninstallation is not silent without this script

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
# Arguments for Uninstall-ChocolateyPackage and Uninstall-ChocolateyPackage
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'PySol Fan Club edition*'  # Display Name as it appears in "Installed apps" or "Programs and Features".
  fileType      = 'EXE'
  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes= @(0) # Inno Setup
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# If 1 match was found
if ($keys.Count -eq 1) {
  $keys | % {
    $packageArgs['file'] = "$($_.UninstallString)"
    $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
    # Run uninstaller
    Uninstall-ChocolateyPackage @packageArgs
  }
# If 0 matches was found
} elseif ($keys.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
# If more than 1 matches were found
} elseif ($keys.Count -gt 1) {
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $keys | % { Write-Warning "- $($_.DisplayName)" }
}