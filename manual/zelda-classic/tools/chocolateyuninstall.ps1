# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors
$installationDirPath = "C:\Games\Zelda Classic\"

# Archive name
$zipName = '2.53_Win_Release_2-17APRIL2019.zip'

# Inform that user data will not be removed
# (This isn't important, but it's code that I salvaged from an earlier
# version of this script that I learned was needlessly complex.)
# Paths
$questsDirPath = Join-Path $installationDirPath -ChildPath "Quests"
$savePath = Join-Path $installationDirPath -ChildPath "zc.sav"
# Look for save
$saveExists = Test-Path $savePath -PathType Leaf
# Look for custom quests
$questsDirExists = Test-Path $questsDirPath -PathType Container
# Remove Quests directory if empty
$empty = -not (Test-Path $questsDirPath\*)
# Inform of user data non-removal
if ($questsDirExists -and $empty) {
    # [x] Test
    Write-Verbose "Removing empty 'Quests' directory."
    Remove-Item $questsDirPath
    Write-Verbose "Removed empty 'Quests' directory."
} elseif ($saveExists -and $questsDirExists) {
    # [x] Test
    Write-Debug "Save found."
    Write-Debug "Quests dir found."
    Write-Warning "Quests and save data will *not* be removed."
    # Pause so that the user have time to read, and can abort if desired. Chocolatey stops Pause after 30 seconds by default.
    Pause
} elseif ($saveExists) {
    # [x] Test
    Write-Debug "Save found."
    Write-Warning "Save data will *not* be removed."
    Pause
} elseif ($questsDirExists) {
    # [x] Test
    Write-Debug "Quests dir found."
    Write-Warning "Custom quests will *not* be removed."
    Pause
}

# Uninstall extracted files
Uninstall-ChocolateyZipPackage -PackageName $env:ChocolateyPackageName -ZipFileName $zipName

# Inform user if installation directory is not empty.
$empty = -not (Test-Path $installationDirPath\*)
if (-not $empty) {
    # [x] Test
    $message = "User data remains in the installation directory. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: $installationDirPath"
    Write-Warning $message
    Start-Sleep -Seconds 5 # time to read
}
# Remove installation directory if empty
else {
    # [x] Test
    Write-Debug "Installation directory is empty."
    Write-Debug "Removing installation directory."
    Remove-Item $installationDirPath
    Write-Debug "Installation directory removed."
}

# Remove shortcuts
# Look for shortcuts log
$shortcutsLogPath = Join-Path "$env:ChocolateyPackageName" -ChildPath 'shortcuts.txt'
$exists = Test-Path -Path $shortcutsLogPath -PathType Leaf
if ($exists) {
    # [x] Test
    Write-Debug "Shortcuts log found."
    # Read log line-per-line and remove files
    $shortcutsLog = Get-Content $shortcutsLogPath
    foreach ($fileInLog in $shortcutsLog) {
        if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
            try {
                # [x] Test
                Write-Debug "Removing shortcut '$fileInLog'."
                Remove-Item -Path "$fileInLog" -Force
                # [x] Test
                Write-Debug "Removed shortcut '$fileInLog'."
            }
            catch {
                # [x] Test
                Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
            }
        }
    }
}
else {
    # [x] Test
    Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
}

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
