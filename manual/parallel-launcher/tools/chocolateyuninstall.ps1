# Initialization
$ErrorActionPreference = 'Stop'

# Preferences
$installationDirPath = 'C:\Program Files (x86)\parallel-launcher'
$pdfManualInstallPath = Join-Path $installationDirPath -ChildPath 'Manual.pdf'

# Prevent uninstall if retroarch (which Parallel Launcher uses) is running, to ensure
# no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless this feature is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "retroarch"

# Uninstall
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'Parallel Launcher*'
  fileType       = 'EXE'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# Perform action based on the number of matching keys
# If 0 keys matched
if ($keys.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
  # If more than 1 matches were found
} elseif ($keys.Count -gt 1) {
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
}
# If 1 match was found
if ($keys.Count -eq 1) {
  $keys | ForEach-Object {
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
}

# Uninstall manual
$manualExists = Test-Path $pdfManualInstallPath -PathType Leaf
if ($manualExists) {
  try {
    Write-Verbose "Uninstalling manual..."
    Remove-Item "$pdfManualInstallPath"
    Write-Debug "Manual uninstalled."
  } catch {
    Write-Warning "Could not uninstall manual.`n$_"
  }
} else {
  $message = "Manual could not be found. " + `
    "It may have been uninstalled by other means."
  Write-Warning $message
}

# Remove installation directory
# Inform user if installation directory is not empty (edge case?)
$exists = Test-Path $installationDirPath -PathType Container
$empty = -not (Test-Path $installationDirPath\*)
if ($exists -and -not $empty) {
  $message = "Data remains in the installation directory. `n" + `
    "Manually remove the installation directory " + `
    "if you do not wish to keep the data.`n" + `
    "Installation directory: '$installationDirPath'"
  Write-Warning $message
  Start-Sleep -Seconds 5 # Time to read
}
else {
  # Remove installation directory if it is empty
  Write-Debug "Installation directory is empty."
  Write-Debug "Removing installation directory."
  Remove-Item $installationDirPath
  Write-Debug "Installation directory removed."
}
