# Other steps for uninstalling [[PackageName]] with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

# Uninstall
# Arguments for Get-UninstallRegistryKey and Uninstall-ChocolateyPackage
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  softwareName = 'embedded-install-exe.template*' # Display name as it appears in "Installed apps" or "Programs and Features".
  fileType     = 'EXE'
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
  validExitCodes = @(0) # Other; insert other valid exit codes here
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

## Remove persistent Environment variable
# Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable

## Remove shim
# Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile

## Remove shortcuts
## Look for shortcuts log
# $packagePath = $env:ChocolateyPackageFolder
# $shortcutsLogPath = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
# $exists = Test-Path -Path "$shortcutsLogPath" -PathType Leaf
# if ($removeShortcuts -and -not $exists) {
#     Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
# }
# elseif ($exists) {
#     Write-Debug "Shortcuts log found."
#     # Read log line-per-line and remove files
#     $shortcutsLog = Get-Content "$shortcutsLogPath"
#     foreach ($fileInLog in $shortcutsLog) {
#         if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
#             try {
#                 Write-Debug "Removing shortcut '$fileInLog'."
#                 Remove-Item -Path "$fileInLog" -Force
#                 Write-Debug "Removed shortcut '$fileInLog'."
#             }
#             catch {
#                 Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
#             }
#         }
#     }
# }

## OTHER HELPER FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
