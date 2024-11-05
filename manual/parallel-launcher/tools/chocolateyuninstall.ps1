# Initialization
$ErrorActionPreference = 'Stop'

# Preferences
$installationDirPath = 'C:\Program Files (x86)\parallel-launcher'
$pdfManualInstallPath = Join-Path "$installationDirPath" -ChildPath 'Manual.pdf'

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
if ($keys.Count -eq 0) {
  # If 0 keys matched
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($keys.Count -gt 1) {
  # If more than 1 matches were found
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
} elseif ($keys.Count -eq 1) {
  # If 1 match was found
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
$exists = Test-Path "$pdfManualInstallPath" -PathType Leaf
if ($exists) {
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

# See if installation directory exists
$installDirExists = Test-Path "$installationDirPath" -PathType Container
if ($installDirExists) {
  # Remove empty directories inside the installation directory
  Write-Debug "Installation directory found."
  $toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
  $RemoveEmptyFolders = Join-Path $toolsDirPath -ChildPath 'Remove-EmptyFolders'
  . $RemoveEmptyFolders "C:\Program Files (x86)\parallel-launcher" -Recurse
  # See if the installation directory is empty
  $installDirEmpty = -not (Test-Path "$installationDirPath\*")
  if (-not $installDirEmpty) {
    # Inform user if directory is not empty (edge case)
    $message = "Data remains in the installation directory. `n" + `
      "Manually remove the installation directory " + `
      "if you do not wish to keep the data.`n" + `
      "Installation directory: '$installationDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
  } else {
    # Remove directory if it is empty
    Write-Debug "Installation directory is empty."
    Write-Debug "Removing installation directory..."
    Remove-Item "$installationDirPath"
    Write-Debug "Installation directory removed."
  }
} else {
  # Only write a debug message (edge case)
  Write-Debug "Installation directory not found."
}

# See if the application's data directory exists
$dataDirPath = Join-Path "$Env:LOCALAPPDATA" -ChildPath 'parallel-launcher'
$dataDirExists = Test-Path "$dataDirPath" -PathType Container
if ($dataDirExists) {
  Write-Debug "Data directory found."
  # Remove empty directories inside the application's data directory
  $toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
  $RemoveEmptyFolders = Join-Path "$toolsDirPath" -ChildPath 'Remove-EmptyFolders.ps1'
  . $RemoveEmptyFolders "$dataDirPath" -Recurse
  # See if the application's data directory is empty
  $dataDirEmpty = -not (Test-Path "$dataDirPath\*")
  if (-not $dataDirEmpty) {
    # Inform user if directory is not empty
    $message = "Data remains in the application's data directory. `n" + `
      "Manually remove the application's data directory " + `
      "if you do not wish to keep the data.`n" + `
      "Data directory: '$dataDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
  } else {
    # Remove directory if it is empty
    Write-Debug "Data directory is empty."
    Write-Debug "Removing data directory..."
    Remove-Item $dataDirPath
    Write-Debug "Data directory removed."
  }
} else {
  # Only write a debug message if the directory is not found (edge case)
  Write-Debug "Data directory not found."
}
