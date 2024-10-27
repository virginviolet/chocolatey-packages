# Other steps for uninstalling [[PackageName]] with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## References
## "Uninstall". https://docs.chocolatey.org/en-us/choco/commands/uninstall
## "Uninstall-ChocolateyPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## "Uninstall-ChocolateyZipPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$removeShortcuts = $true
$installationDirPath = 'C:\Tools\[[PackageName]]' # Only necessary if you did not unpack to package directory

## Helper functions
## These have error handling tucked into them already
## Documantation - https://docs.chocolatey.org/en-us/create/functions

# Remove extracted files
# Only necessary if you did not unpack to package directory
# Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "NAME_OF_EMBEDDED_ZIP_FILE.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs

# Remove installation directory
# Only necessary if you did not unpack to package directory
# Inform user if installation directory is not empty
$empty = -not (Test-Path $installationDirPath\*)
if (-not $empty) {
    $message = "Data remains in the installation directory. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: '$installationDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
}
# Remove installation directory if it is empty
else {
    Write-Debug "Installation directory is empty."
    Write-Debug "Removing installation directory."
    Remove-Item $installationDirPath
    Write-Debug "Installation directory removed."
}

# Remove shortcuts
# Look for shortcuts log
$packagePath = $env:ChocolateyPackageFolder
$shortcutsLogPath = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
$exists = Test-Path -Path "$shortcutsLogPath" -PathType Leaf
if ($removeShortcuts -and -not $exists) {
    Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
}
elseif ($exists) {
    Write-Debug "Shortcuts log found."
    # Read log line-per-line and remove files
    $shortcutsLog = Get-Content "$shortcutsLogPath"
    foreach ($fileInLog in $shortcutsLog) {
        if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
            try {
                Write-Debug "Removing shortcut '$fileInLog'."
                Remove-Item -Path "$fileInLog" -Force
                Write-Debug "Removed shortcut '$fileInLog'."
            }
            catch {
                Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
            }
        }
    }
}

## Remove persistent Environment variable
## Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
# Uninstall-ChocolateyEnvironmentVariable

## Remove shim
## Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
# Uninstall-BinFile # Only needed if you used Install-BinFile

## Other needs: use regular PowerShell to do so, or see if it can be accomplished with the helper functions
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## There may also be functions available in extension packages
## See here for examples and availability: https://community.chocolatey.org/packages?q=id%3A.extension

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

