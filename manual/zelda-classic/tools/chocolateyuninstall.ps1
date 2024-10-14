# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors
$installationDirName = "Zelda Classic" # Used for $installationDir and $tempBakDir
$installationDirPath = "C:\Games\$installationDirName\" # I had issues when installed to package directory

# Archive name
$zipName = '2.53_Win_Release_2-17APRIL2019.zip'

# Look for user data, and if found, inform that it will not be removed
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
    # [ ] Test
    Write-Debug "Removing empty 'Quests' directory."
    Remove-Item $questsDirPath
} elseif ($saveExists -and $questsDirExists) {
    # [ ] Test
    Write-Debug "Save found."
    Write-Debug "Quests dir found."
    $message = "Custom quests and save data will *not* be removed. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: $installationDirPath"
    Write-Warning $message
    $userDataExists = $true
} elseif ($saveExists) {
    # [ ] Test
    Write-Debug "Save found."
    $message = "Save data will *not* be removed. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: $installationDirPath"
    Write-Warning $message
    $userDataExists = $true
} elseif ($questsDirExists) {
    # [ ] Test
    Write-Debug "Quests dir found."
    $message = "Custom quests will *not* be removed. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: $installationDirPath"
    Write-Warning $message
    $userDataExists = $true
}
# Pause so that the user have time to read, and can abort if desired. Chocolatey stops Pause after 30 seconds by default.
Pause

# Uninstall files
Uninstall-ChocolateyZipPackage -PackageName $env:ChocolateyPackageName -ZipFileName $zipName

# Inform user if installation directory is not empty (only if we haven't already informed.).
$empty = -not (Test-Path $installationDirPath\*)
if ($empty -and -not $userDataExists) {
    # [ ] Test
    $message = "User data remains in the installation directory. `n" `
        + "Manually remove the installation directory if you do not wish to keep the data.`n" `
        + "Installation directory: $installationDirPath"
    Write-Warning $message
    Start-Sleep -Seconds 5 # time to read
}
# Remove installation directory if empty
if ($empty) {
    # [ ] Test
    Remove-Item $installationDirPath
}

# Remove shortcuts
# Find shortcuts log
$shortcutsLogPath = Join-Path "$env:ChocolateyPackageFolder" -ChildPath 'shortcuts.txt'
$exists = Test-Path -Path $shortcutsLogPath -PathType Leaf
if ($exists) {
    # $shortcutsLogPath
    $shortcutsLog = Get-Content $shortcutsLogPath
    foreach ($fileInLog in $shortcutsLog) {
        if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
            try {
                Write-Debug "Removing shortcut '$fileInLog'."
                Remove-Item -Path "$fileInLog" -Force
            }
            catch {
                Write-Warning "Could not remove shortcut $fileInLog.`n" `
                + $_
            }
            Write-Debug "Removed shortcut '$fileInLog'."
        }
    }
}

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
