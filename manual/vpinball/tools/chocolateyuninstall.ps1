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
  # silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # silentArgs   = '/s'           # InstallShield
  # silentArgs   = '/s /v"/qn"'   # InstallShield with MSI
  # silentArgs   = '/s'           # Wise InstallMaster
  # silentArgs   = '-s'           # Squirrel
  # silentArgs   = '-q'           # Install4j
  # silentArgs   = '-s -u'        # Ghost
  # Note that some installers, in addition to the silentArgs above, may also need assistance of AHK to achieve silence.
  # silentArgs   = ''             # none; make silent with input macro script like AutoHotKey (AHK)
  #       https://community.chocolatey.org/packages/autohotkey.portable
  validExitCodes = @(0) # NSIS
  # validExitCodes = @(0) # Inno Setup
  # validExitCodes= @(0) # Insert other valid exit codes here
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# If 1 match was found
if ($keys.Count -eq 1) {
  $keys | % {
    # Adjust arguments
    # - You probably will need to sanitize $packageArgs['file'] as it comes from the registry and could be in a variety of fun but unusable formats
    # - Ensure you don't pass double quotes in $file (aka $packageArgs['file']) - otherwise you will get "Illegal characters in path when you attempt to run this"
    $packageArgs['file'] = "$($_.UninstallString)" # NOTE: You may need to split this if it contains spaces
    # - Split args from exe in $packageArgs['file'] and pass those args through $packageArgs['silentArgs'] or ignore them
    # - Review the code for auto-uninstaller for all of the fun things it does in sanitizing - https://github.com/chocolatey/choco/blob/bfe351b7d10c798014efe4bfbb100b171db25099/src/chocolatey/infrastructure.app/services/AutomaticUninstallerService.cs#L142-L192
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

## Remove persistent Environment variable
# Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable

## Remove shim
# Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile

## OTHER HELPER FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
