$ErrorActionPreference = 'Stop' # stop on all errors

function Test-PathBool($p) {
    return [bool](Test-Path -Path $p)
}

$unzipDir = "C:\Games\Zelda 3 Launcher"
$zelda3Dir = Join-Path $unzipDir -ChildPath 'zelda3'
$saveDir = Join-Path $zelda3Dir -ChildPath 'saves'
$saveFile = Join-Path $saveDir -ChildPath 'sram.dat'
$saveDirRef = Join-Path $saveDir -ChildPath 'ref'
$config = Join-Path $zelda3Dir -ChildPath 'zelda3.ini'

# Prevent uninstall if the game is running, so that no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "zelda3"

$unzipDirExists = Test-PathBool $unzipDir
if (-Not $unzipDirExists) {
    Write-Warning "Installation directory does not exist. The software may have been removed manually."
} else {

    # Remove save directory if empty
    $exists = Test-PathBool $saveDir
    $empty = -Not (Test-PathBool $saveDir\*)
    if ($exists -And $empty) {
        Remove-Item $saveDir
    }
    
    # To clean, we get everything we want to keep and move it to a temporary safe place ($TEMP), then delete everything in the original directory, then move the keeping-things back into the directory.
    
    $zelda3Exists = Test-PathBool $zelda3Dir
    $zelda3Empty = -Not (Test-PathBool $zelda3Dir\*)
    if ($zelda3Exists -And $zelda3Empty) {
        # Remove game directory
        Remove-Item $zelda3Dir
    } elseif ($zelda3Exists -And -Not $zelda3Empty) {
        Write-Warning 'Zelda 3 will be removed.'
        Write-Warning 'Settings and save data will be backed up.'
        Pause # Pause so that the user have time to read, and can abort if desired. Chocolatey stops Pause after 30 seconds by default.
    }
    
    # Detour to move existing backup directories to temporary location. We have to do this _before_ cleaning the launcher directory (or backups will get removed), but _after_ the "Zelda 3 will be removed" output and associated Pause, because otherwise, if the user aborts the script during the pause, they wouldn't be able to find their backups because we would have silently moved them away to the $TEMP already.
    $backupDirs = Get-ChildItem -Path $unzipDir -Directory -Filter "zelda3.bak*"
    $backupDirsExists = [bool]($backupDirs)
    $tempBackupsDir = Join-Path $env:TEMP -ChildPath 'zelda3baks'
    $tempBackupsDirExists = Test-PathBool $tempBackupsDir
    $tempBakDir = ''
    if ($backupDirsExists) {
        if (-Not $tempBackupsDirExists) {
            New-Item -Path $tempBackupsDir -ItemType "directory" 1> $null
            $tempBackupsDirExists = $true
        }
        foreach ($backupDir in $backupDirs) {
            $tempBakDir = Join-Path $tempBackupsDir -ChildPath $backupDir.Name
            Move-Item -Path $backupDir.FullName -Destination $tempBakDir
        }
    }

    # Clean game directory, backup if necessary
    if ($zelda3Exists -And -Not $zelda3Empty) {
        
        # Remove reference save files directory
        $saveDirRefexists = Test-PathBool $saveDirRef
        if ($saveDirRefexists) {
            Remove-Item $saveDirRef -Recurse -Force
        }

        # Set backup directory name
        $lastModified = Get-Date # Initialize variable
        $configDate = $lastModified # Initialize variable
        $saveDate = $lastModified # Initialize variable
        $saveFileExists = Test-PathBool $saveFile
        $configExists = Test-PathBool $config
        if ($configExists) {
            $configDate = (Get-Item $config).LastWriteTime
            $lastModified = $configDate
        }
        if ($saveFileExists) {
            $saveDate = (Get-Item $saveFile).LastWriteTime
            $lastModified = $saveDate
        }
        # It would make sense to here set $lastModified to whichever was modified last ($saveDate or $configDate). However, in an edge case scenario, this might cause save data to be unintentionally overwritten when config is newer than save data. This could be alternatively solved via prompting, but that is not desirable for Chocolatey. So let's just prioritize last modified date of save file (i.e. $saveDate) over the config file's date ($configDate). We might lose config in rare cases, but at least save data won't be lost.
        $lastModified = $lastModified.ToString("yyyy-MM-dd_HHmmss")
        $zelda3BackupName = "zelda3.bak@$lastModified" # If the zelda3 directory exists, the launcher will think the game is built (perhaps a bug report should be submitted to the launcher repo for that), so we let the directory be named $zelda3BackupName istead. This, of course, lets us have multiple backups, each with a timestamp in directory name, arguably simplifying uninstallation when there are existing backup(s). We let the user deal with that manually instead.
        $tempBakDir = Join-Path $tempBackupsDir -ChildPath $zelda3BackupName
        $tempBakDirExists = Test-PathBool $tempBakDir
        $saveDirExists = Test-PathBool $saveDir
        
        # Move save data to backup directory in temporary location
        if ($saveDirExists) {
            $tempZelda3BackupSaves = Join-Path $tempBakDir -ChildPath 'saves'
            if (-Not $tempBackupsDirExists) {
                New-Item -Path $tempBackupsDir -ItemType "directory" 1> $null
                $tempBackupsDirExists = $true
            }
            if (-Not $tempBakDirExists) {
                # It would only exist in an edge case where there is backup with the same date.
                New-Item -Path $tempBakDir -ItemType "directory" 1> $null
            }
            $exists = Test-PathBool $tempZelda3BackupSaves
            if ($exists) {
                # IMPROVE Merge directory instead of replace
                Remove-Item -Path $tempZelda3BackupSaves -Recurse  # Overwrite directory in edge case
            }
            Move-Item -Path $saveDir -Destination $tempZelda3BackupSaves
        }

        # Move config to backup directory in temporary location
        if ($configExists) {
            $tempBakDirExists = Test-PathBool $tempBakDir
            if (-Not $tempBackupsDirExists) {
                New-Item -Path $tempBackupsDir -ItemType "directory" 1> $null
                $tempBackupsDirExists = $true
            }
            if (-Not $tempBakDirExists) {
                New-Item -Path $tempBakDir -ItemType "directory" 1> $null
            }
            $tempZelda3BackupConfig = Join-Path $tempBakDir -ChildPath 'zelda3.ini'
            Move-Item -Path $config -Destination $tempZelda3BackupConfig -Force # Overwrite in edge case
        }

    }

    # Remove everything in the launcher directory, including zelda3
    Remove-Item $unzipDir\* -Force -Recurse

    # Move backup(s) back to the game directory
    $tempBackupsDirExists = Test-PathBool $tempBackupsDir
    if ($tempBackupsDirExists) {
        $tempBackupDirs = Get-ChildItem -Path $tempBackupsDir -Directory
        foreach ($backupDir in $tempBackupDirs) {
            $bakDir = Join-Path $unzipDir -ChildPath $backupDir.Name
            Move-Item -Path $backupDir.FullName -Destination $bakDir
        }
        Remove-Item $tempBackupsDir
        Write-Warning 'Manually remove the configuration and save data backup if desired. (See this package''s description for details.)'
        Start-Sleep -Seconds 5 # time to read
    }

    # Remove Launcher installation directory if empty
    $unzipDirEmpty = -Not (Test-PathBool $unzipDir\*)
    if ($unzipDirEmpty) {
        Remove-Item $unzipDir -Force -Recurse
    }

}

# Remove desktop shortcut if it exists (it's plausible the user might have removed it)
$exists = Test-PathBool "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
if ($exists) {
    Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
}

# Remove start menu shortcut if it exists (it's plausible the user might have removed it)
$exists = Test-PathBool "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"
if ($exists) {
    Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"
}

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'