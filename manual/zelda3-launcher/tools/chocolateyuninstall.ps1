﻿$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$unzipDir   = "C:\Games\Zelda 3 Launcher"
$zelda3Dir  = Join-Path $unzipDir 'zelda3'
$saveDir    = Join-Path $zelda3Dir 'saves'
$saveDirRef = Join-Path $saveDir 'ref'
$config     = Join-Path $zelda3Dir 'zelda3.ini'
$tempZelda3 = Join-Path $env:TEMP 'zelda3.bak'
$backupZelda3 = Join-Path $unzipDir 'zelda3.bak'


# Prevent uninstall if the game is running, so that no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless this feature is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "zelda3"

# Remove reference save files directory
# `-ea 0` overrides $ErrorActionPreference, otherwise the script would stop
# when Test-Path checks a path that doesn't exist.
# We could skip checking if directory exists and just use `-ea 0` for the main
# command, but then we won't catch any errors at all.
$exists = [bool](Test-Path -Path $saveDirRef -ea 0)
$empty = -Not ([bool](Test-Path -Path $saveDirRef\* -ea 0))
if ($exists -And $empty){
    Remove-Item $saveDirRef
}

# Remove save directory if empty
$exists = [bool](Test-Path -Path $saveDir -ea 0)
$empty = -Not ([bool](Test-Path -Path $saveDir\* -ea 0))
if ($exists -And $empty){
    Remove-Item $saveDir
}

# Remove zelda3 directory (game directory)
$exists = [bool](Test-Path -Path $zelda3Dir -ea 0)
$empty = -Not ([bool](Test-Path -Path $zelda3Dir\* -ea 0))
if ($exists -And -Not $empty){
    Write-Warning 'Zelda 3 will be removed.'
    Write-Warning 'Settings and save data will be backed up.'
    Pause # Pause to abort
    
    # Remove reference save files
    $exists = [bool](Test-Path -Path $saveDirRef -ea 0)
    if ($exists) {
        Remove-Item $saveDirRef -Recurse -Force
    }
    
    $backupExists = [bool](Test-Path -Path $backupZelda3 -ea 0)
    $backupEmpty = -Not ([bool](Test-Path -Path $backupZelda3\* -ea 0))
    $savesExists = [bool](Test-Path -Path $tempZelda3 -ea 0)
    $configExists = [bool](Test-Path -Path $config -ea 0)
    
    # Move either existing backup, or save data and confg, to temporary location (because Powershell is hell)
    if ($backupExists -And (-Not $backupEmpty)) {
        if ($savesExists -Or $configExists) {
            Write-Warning "Existing backup found. Overwrite?"
            New-Item -ItemType Directory -Path $tempZelda3 # TODO replace with `Move-Item -Path`?
            # XXX
            # Pause 30 seconds, throw
            # if no: Move existing backup to $tempZelda3 (because Powershell is hell)
        }
    }
    else {
        if ($savesExists) {
            # Move save data to temporary location (because Powershell is hell)
            New-Item -ItemType Directory -Path $tempZelda3 # TODO replace with `Move-Item -Path`?
            Move-Item -Path $saveDir -Destination $tempZelda3
        }
        if ($configExists) {
            # Move config to temporary location (because Powershell is hell)
            New-Item -ItemType Directory -Path $tempZelda3 # TODO replace with `Move-Item -Path`?
            Move-Item -Path $config -Destination $tempZelda3
        }
    }

    # Remove everything in the launcher directory, including zelda3
    Remove-Item $unzipDir\* -Force -Recurse

    # Move save data and config back to the game directory
    # If the zelda3 folder exists, the launcher will think the game is built, so we let the folder be named $tempZelda3 istead. 
    Move-Item -Path $tempZelda3 -Destination $unzipDir

    Write-Warning 'Manually remove the configuration and save data backup if so desired. (See this package''s description for more details.)'
    Start-Sleep -Seconds 5 # time to read
} else {
    # Remove the launcher directory
    Remove-Item $unzipDir -Force -Recurse
    }

# Remove desktop shortcut if it exists (it's plausible the user might have removed it)
$exists = [bool](Test-Path -Path "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk" -ea 0)
if ($exists) {
    Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
}

# Remove start menu shortcut if it exists (it's plausible the user might have removed it)
$exists = [bool](Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk" -ea 0)
if ($exists) {
    Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"
}

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'