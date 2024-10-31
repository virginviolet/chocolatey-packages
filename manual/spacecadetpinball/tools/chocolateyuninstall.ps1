# Other steps for uninstalling spacecadetpinball with Chocolatey

# This script is required for Chocolatey to remove the shortcuts

## References
## "Uninstall". https://docs.chocolatey.org/en-us/choco/commands/uninstall
## "Uninstall-ChocolateyPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## "Uninstall-ChocolateyZipPackage". https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
$removeShortcuts = $true
$installationDirName = '3D Pinball x64'
$installationDirPath = Join-Path "$toolsDirPath" "$installationDirName"
# $installationDirPath = 'C:\Tools\spacecadetpinball'

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

# Uninstall the decompilation release files
# Arguments
$decompiledX64WinArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx64Win.zip"
}
Uninstall-ChocolateyZipPackage @decompiledX64WinArgs > $null
# Arguments
$decompiledX86WinArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx86Win.zip"
}
Uninstall-ChocolateyZipPackage @decompiledX86WinArgs > $null
# Arguments
$decompiledX86WinXpArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "SpaceCadetPinballx86WinXP.zip"
}
Uninstall-ChocolateyZipPackage @decompiledX86WinXpArgs > $null

# Uninstall the original game files
# Arguments
$originalGameArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "3D Pinball x64.zip"
}
Uninstall-ChocolateyZipPackage @originalGameArgs > $null

# Remove shortcuts
# Look for shortcuts log
$packagePath = Get-ChocolateyPath -PathType 'PackagePath'
$shortcutsLogPath = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
$exists = Test-Path -Path "$shortcutsLogPath" -PathType Leaf
if ($removeShortcuts -and -not $exists) {
    Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
} elseif ($exists) {
    Write-Debug "Shortcuts log found."
    # Read log line-per-line and remove files
    $shortcutsLog = Get-Content "$shortcutsLogPath"
    foreach ($fileInLog in $shortcutsLog) {
        if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
            try {
                Write-Debug "Removing shortcut '$fileInLog'."
                Remove-Item -Path "$fileInLog" -Force
                Write-Debug "Removed shortcut '$fileInLog'."
            } catch [System.Management.Automation.ItemNotFoundException] {
                $shortcutDirPath = $(Split-Path -Path $fileInLog)
                if ($shortcutDirPath -eq $installationDirPath) {
                    # As far as I understand, directories created
                    # through 'Install-ChocolateyZipPackage' get removed
                    # by 'Uninstall-ChocolateyZipPackage'. Thus, the shortcut
                    # in the installation directory will already have been
                    # deleted at this point in the script. Not finding that
                    # shortcut should not throw a warning. That's what this
                    # catch block is for.
                    # [ ] Test
                    $message = "Shortcut '$fileInLog' has already been " + `
                        "removed."
                    Write-Debug $message
                } else {
                    Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
                }
            } catch {
                Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
            }
        }
    }
}

# Check whether the installation directory exists and if it is empty
# (This is stock code in virginviolet's scripts)
$exists = (Test-Path "$installationDirPath" -PathType Container)
$empty = -not (Test-Path "$installationDirPath\*")
if ($exists -and -not $empty) {
    # Inform user that the installation directory is not empty (edge case)
    $message = "Data remains in the installation directory. `n" + `
        "Manually remove the directory if you do not" + `
        "wish to keep the data.`n" + `
        "Installation directory: '$installationDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
} elseif ($exists -and $empty) {
    # Remove installation directory if it is empty (edge case;
    # may be possible if not unpacked to package directory)
    Write-Debug "Installation directory is empty."
    Write-Debug "Removing installation directory."
    Remove-Item $installationDirPath
    Write-Debug "Installation directory removed."
} elseif (-not $exists) {
    Write-Debug "Installation directory has been removed."
}

# Check whether the game data directory exists and if it is empty
$gameDataDirPath = Join-Path $env:APPDATA -ChildPath 'SpaceCadetPinball'
$exists = (Test-Path "$gameDataDirPath" -PathType Container)
$empty = -not (Test-Path "$gameDataDirPath\*")
if ($exists -and -not $empty) {
    # Inform user that the game data directory is not empty
    # [x] Test
    $message = "Data remains in the game data directory (highscore and " + `
        "settings).`n" + `
        "Manually remove the directory if you do not wish" + `
        "to keep the data.`n" + `
        "Game data directory: '$installationDirPath'"
    Write-Warning $message
    Start-Sleep -Seconds 5 # Time to read
}
elseif ($exists -and $empty) {
    # Remove the game data directory if it is empty (edge case)
    # [x] Test
    Write-Debug "Game data directory is empty."
    Write-Debug "Removing Game data directory."
    Remove-Item $gameDataDirPath
    Write-Debug "Game data directory directory removed."
} elseif (-not $exists) {
    # [x] Test
    Write-Debug "Game data directory (settings and highscore) not found."
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
