# Additional steps for uninstalling [[PackageName]] with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$removeShortcuts = $true

# Remove extracted files
# Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
# Arguments
$uninstallZipArgs = @{
    Packagename = "$($packageName)"
    ZipFileName = "example.zip"
}
Uninstall-ChocolateyZipPackage @uninstallZipArgs

# Uninstall-ChocolateyZipPackage will remove the FILES from the archive.
# This removes the DIRECTORY they were extracted too.
Remove-Item "C:\tools\example\"

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

## OTHER HELPER FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
