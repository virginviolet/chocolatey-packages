# Other steps for uninstalling windows-frotz.install with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## References
## "Uninstall". https://docs.chocolatey.org/en-us/choco/commands/uninstall
## "Uninstall-ChocolateyPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$programFilesX86DirPath = ${Env:ProgramFiles(x86)}


# Preferences
# 'installPath' is only used for removing friendly app name
$intstallDirPath = Join-Path -Path $programFilesX86DirPath -ChildPath 'Windows Frotz'

# Prevent uninstall if the program is running
# (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1
# unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow -ProcessName "Frotz"

# Uninstall
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  softwareName = 'Windows Frotz' # Display name as it appears in "Installed apps" or "Programs and Features".
  fileType     = 'EXE'
  # Silent arguments
  silentArgs   = '/S'           # NSIS
  # Exit codes indicating success
  validExitCodes = @(0) # NSIS
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
}
if ($keys.Count -eq 1) {
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

# See if config exists in the registry and is not empty
$configPath = "HKEY_CURRENT_USER\Software\David Kinder\Frotz\"
$configExists = Test-RegistryKey -Path "$configPath\*"
if ($configExists) {
  $message = "Settings remain in the registry.`n" + `
  "Settings registry path: " + ": '$configPath'"
  Write-Warning $message
  Start-Pause -Seconds 5 # Time to read
}

# Remove friendly app names
# Paths
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exeInstallerPath = Join-Path -Path $toolsDirPath -ChildPath 'WindowsFrotzInstaller.exe'
Remove-FriendlyAppName -Path $intstallDirPath
Remove-FriendlyAppName -Path $exeInstallerPath
