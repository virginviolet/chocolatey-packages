# Other steps for uninstalling spacecadetpinball with Chocolatey

## References
## "Uninstall". https://docs.chocolatey.org/en-us/choco/commands/uninstall
## "Uninstall-ChocolateyPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## "Uninstall-ChocolateyZipPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$removeShortcuts = $true
$installationDirPath = 'C:\Tools\spacecadetpinball' # Only necessary if you did not unpack to package directory

## Helper functions
## These have error handling tucked into them already
## Documantation - https://docs.chocolatey.org/en-us/create/functions
## Source code - https://github.com/chocolatey/choco/tree/master/src/chocolatey.resources/helpers/functions

## Outputs the bitness of the OS (either "32" or "64")
## Documantation - https://docs.chocolatey.org/en-us/create/functions/get-osarchitecturewidth
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Get-OSArchitectureWidth.ps1
# $osBitness = Get-ProcessorBits

# Remove extracted files
# Only necessary if you did not unpack to package directory
# Documantation - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
## Source code - https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/UnInstall-ChocolateyZipPackage.ps1
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx64Win.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx64Win.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx86Win.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "3D Pinball x64.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs

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

