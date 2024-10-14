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
$installationDir = "C:\Games\$installationDirName\" # I had issues when installed to package directory

# Backup and uninstall
$exists = Test-Path $installationDir -ItemType Directory
if (-not $exists) {
    Write-Warning "Installation directory does not exist. The software may have been removed manually."
} else {
    # To clean, we get everything we want to keep and move it to a temporary safe place ($TEMP), then delete everything in the original directory, then move the keeping-things back into the directory.
    # Paths
    $questsDir = Join-Path $installationDir -ChildPath "Quests"
    $save = Join-Path $installationDir -ChildPath "zc.sav"
    $configZc = Join-Path $installationDir -ChildPath "zc.cfg"
    $configAg = Join-Path $installationDir -ChildPath "ag.cfg"
    $configZQuest = Join-Path $installationDir -ChildPath "zquest.cfg"
    $tempBakDir = Join-Path $TEMP -ChildPath $installationDirName
    # Inform of backup and set variable
    $saveExists = Test-Path $save -PathType Leaf
    $questsDirExists = Test-Path $questsDir -PathType Container
    $configZcExists = Test-Path $configZc -PathType Leaf
    $configAgExists = Test-Path $configAg -PathType Leaf
    $configZQuestExists = Test-Path $configZQuest -PathType Leaf
    # Remove Quests directory if empty (so that we won't make a backup of it then)
    $empty = -not (Test-Path $saveDir\*)
    if ($questsDirExists -and $empty) {
        Write-Debug "Removing empty 'Quests' directory."
        Remove-Item $questsDir
    }
    Write-Warning 'Zelda Classic will be removed.'
    # 1 1 1
    if ($saveExists -and $questsDirExists -and ($configZcExists -or $configAgExists -or $configZQuestExists)) {
        Write-Debug "Save found."
        Write-Debug "Quests dir found."
        Write-Debug "Config file(s) found."
        Write-Warning 'Settings, custom quests and save data will be backed up.'
        $willBackup = $true
    }
    # 1 1 0
    elseif ($saveExists -and $questsDirExists) {
        Write-Debug "Save found."
        Write-Debug "Quests dir found."
        Write-Warning 'Custom quests and save data will be backed up.'
        $willBackup = $true
    }
    # 1 0 1
    elseif ($saveExists -and ($configZcExists -or $configAgExists -or $configZQuestExists)) {
        Write-Debug "Save found."
        Write-Debug "Config file(s) found."
        Write-Warning 'Settings and save data will be backed up.'
        $willBackup = $true
    }
    # 0 1 1
    elseif ($questsDirExists -and ($configZcExists -or $configAgExists -or $configZQuestExists)) {
        Write-Debug "Quests dir found."
        Write-Debug "Config file(s) found."
        Write-Warning 'Settings and custom quests backed up.'
        $willBackup = $true
    }
    # 1 0 0
    elseif ($saveExists) {
        Write-Debug "Save found."
        Write-Warning 'Save data will be backed up.'
        $willBackup = $true
    }
    # 0 1 0
    elseif ($questsDirExists) {
        Write-Debug "Quests dir found."
        Write-Warning 'Custom quests will be backed up.'
        $willBackup = $true
    }
    # 0 0 1
    elseif ($configZcExists -or $configAgExists -or $configZQuestExists) {
        Write-Debug "Config file(s) found."
        Write-Warning 'Settings will be backed up.'
        $willBackup = $true
    }
    # Pause so that the user have time to read, and can abort if desired. Chocolatey stops Pause after 30 seconds by default.
    Pause
    # Clean game directory, backup if necessary
    if ($willBackup) {
        # Make directory for backup data
        New-Item -Path $tempBakDir -ItemType "directory" 1> $null
        # Move backup data to temporary location
        Write-Debug "Moving backup data to temporary location."
        # Move quests
        if ($questsDirExists) {
            Write-Debug "Moving quests dir to temporary location."
            Move-Item -Path $questsDir -Destination $tempBakDir
        }
        # Move save
        if ($saveExists) {
            Write-Debug "Moving save to temporary location."
            Move-Item -Path $save -Destination $tempBakDir
        }
        # Move ZC config
        if ($configZcExists) {
            Write-Debug "Moving ZC config to temporary location."
            Move-Item -Path $configZc -Destination $tempBakDir
        }
        # Move AG config
        if ($configAgExists) {
            Write-Debug "Moving AG config to temporary location."
            Move-Item -Path $configAg -Destination $tempBakDir
        }
        # Move ZQuest config
        if ($configZQuestExists) {
            Write-Debug "Moving ZQuest config to temporary location."
            Move-Item -Path $configZQuest -Destination $tempBakDir
        }
        # XXX
    }
    # Remove installation directory
    Remove-Item $installationDir -Recurse -Force
    if ($willBackup) {
        # Move the backup directory in place of the installation directory
        Move-Item -Path $tempBakDir -Destination $installationDir
        Write-Warning "Backup complete."
        $message = "Manually remove the installation directory if you do not wish to keep the data.`n" `
            + "Installation directory: $installationDir"
        Write-Warning $message
        Start-Sleep -Seconds 5 # time to read
    } else {
        # Remove installation directory if empty
        $empty = -not (Test-Path $installationDir\*)
        if ($empty) {
            Remove-Item $installationDir -Force -Recurse
        }
    }
}
    

# Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName '2.53_Win_Release_2-17APRIL2019.zip' # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage


# Uninstall-ChocolateyZipPackage will remove the FILES from the archive.
# This removes the DIRECTORY they were extracted too.
# Remove-Item 'C:\example'

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.
