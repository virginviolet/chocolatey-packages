# Other steps for uninstalling frotz.install with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## References
## "Uninstall". https://docs.chocolatey.org/en-us/choco/commands/uninstall
## "Uninstall-ChocolateyPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

## Helper functions
## These have error handling tucked into them already
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## Source code - https://github.com/chocolatey/choco/tree/master/src/chocolatey.resources/helpers/functions

## Outputs the bitness of the OS (either "32" or "64")
## Documantation - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-OSArchitectureWidth.ps1
# $osBitness = Get-ProcessorBits

# Uninstall
# Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
# Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Uninstall-ChocolateyPackage.ps1
# Arguments for Get-UninstallRegistryKey and Uninstall-ChocolateyPackage
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  softwareName = 'frotz.install*' # Display name as it appears in "Installed apps" or "Programs and Features".
  fileType     = 'EXE'
  # Silent arguments
  # Uncomment matching installer type (sorted by most to least common)
  # silentArgs   = '/S'           # NSIS
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
  # Exit codes indicating success
  # validExitCodes = @(0) # NSIS
  # validExitCodes = @(0) # Inno Setup
  # validExitCodes = @(0) # Other; insert other valid exit codes here
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

## Remove persistent Environment variable
## Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Uninstall-ChocolateyEnvironmentVariable.ps1
# Uninstall-ChocolateyEnvironmentVariable

## Remove shim
## Only necessary if you used Install-BinFile
## Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Uninstall-BinFile.ps1
# Uninstall-BinFile

## Other needs: use regular PowerShell to do so, or see if it can be accomplished with the helper functions
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## See here for examples and availability: https://community.chocolatey.org/packages?q=id%3A.extension
