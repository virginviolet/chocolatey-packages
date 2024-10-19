# Additional steps for uninstalling vpinball with Chocolatey

# Without this script, installation will not be silent, and patch would not be removed

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$patchInstallDirPath = 'C:\Visual Pinball' # Only necessary if you did not unpack to package directory

# Prevent uninstall if the program is running (so that no progress is lost)
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

# Stop VPinMame Test if it is running
Start-CheckandStop "VPinMameTest" > $null

# Uninstall
# Arguments for Get-UninstallRegistryKey and Uninstall-ChocolateyPackage
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  softwareName = 'Visual Pinball*'  # Part or all of the Display Name as it appears in Programs and Features.
  fileType     = 'EXE'
  # Uncomment matching installer type (sorted by most to least common)
  silentArgs   = '/S'           # NSIS
  validExitCodes = @(0) # NSIS
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# If 1 match was found
if ($keys.Count -eq 1) {
  $keys | % {
    # Adjust arguments
    $packageArgs['file'] = "$($_.UninstallString)" # NOTE: You may need to split this if it contains spaces
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

# Remove extracted files
Write-Host "Uninstalling patch for $($packageName)..."
# Arguments
$uninstallZipArgs = @{
  Packagename = "$($packageName)"
  ZipFileName = "VPinballX73_Minimal.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs
Write-Host "Patch for $($packageName) has been uninstalled."

# Remove installation directory
# Inform user if the installation directory is not empty
$empty = -not (Test-Path $patchInstallDirPath\*)
if (-not $empty) {
    $message = "Data remains in the installation directory. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: '$patchInstallDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
}
# Remove installation directory if it is empty
else {
    Write-Debug "Installation directory is empty."
    Write-Debug "Removing installation directory."
    Remove-Item $patchInstallDirPath
    Write-Debug "Installation directory removed."
}
