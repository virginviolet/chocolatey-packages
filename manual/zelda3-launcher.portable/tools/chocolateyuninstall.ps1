$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$unzipDir   = "C:\Games\Zelda 3 Launcher"
$zelda3Dir  = Join-Path $unzipDir 'zelda3'
$saveDir    = Join-Path $zelda3Dir 'saves'
$saveDirRef = Join-Path $saveDir 'ref'
$config     = Join-Path $zelda3Dir 'zelda3.ini'
$tempZelda3 = Join-Path $env:TEMP 'zelda3'


# Prevent uninstall if the game is running, so that no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless this feature is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "zelda3"

# Remove reference save files directory
# `-ea 0` overrides $ErrorActionPreference, otherwise the script would stop
# when Test-Path checks a path that doesn't exist.
# We could skip checking if directory exists and just use `-ea 0` for the main
# command, but then we won't catch any errors at all.
$exists = Test-Path -Path $saveDirRef -ea 0
$empty = -Not (Test-Path -Path $saveDirRef\* -ea 0)
if ($exists -And $empty){
    Remove-Item $saveDirRef
}

# Remove Save directory if empty
$exists = Test-Path -Path $saveDir -ea 0
$empty = -Not (Test-Path -Path $saveDir\* -ea 0)
if ($exists -And $empty){
    Remove-Item $saveDir
}

$exists = Test-Path -Path $zelda3Dir -ea 0
$empty = -Not (Test-Path -Path $zelda3Dir\* -ea 0)
if ($exists -And -Not $empty){
    Write-Warning 'Zelda 3 WILL be removed.'
    Write-Warning 'Settings and save data will NOT be removed.'
    Pause # Pause to abort
    # Move save data and confg to temporary location (because Powershell is hell)
    New-Item -ItemType Directory -Path $tempZelda3
    
    # Remove reference save files
    $exists = Test-Path -Path $saveDirRef -ea 0
    if ($exists) {
        Remove-Item $saveDirRef -Recurse -Force
    }

    # Move save data to temporary location
    $exists = Test-Path -Path $saveDir -ea 0
    if ($exists) {
        Move-Item -Path $saveDir -Destination $tempZelda3
    }

    # Move config to temporary location
    $exists = Test-Path -Path $config -ea 0
    if ($exists) {
        Move-Item -Path $config -Destination $tempZelda3
    }

    # Remove everything in the launcher directory, including zelda3
    Remove-Item $unzipDir\* -Force -Recurse

    # Move save data and config back to the game directory
    Move-Item -Path $tempZelda3 -Destination $unzipDir

    Write-Warning 'Remove configuration file save data manually if so desired. (See this package''s description for more details.)'
    Start-Sleep -Seconds 5 # time to read
} else {
    # Remove the launcher directory
    Remove-Item $unzipDir -Force -Recurse
    }

# Remove desktop shortcut if it exists (it's plausible the user might have removed it)
$exists = Test-Path -Path "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk" -ea 0
if ($exists) {
    Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
}

# Remove start menu shortcut if it exists (it's plausible the user might have removed it)
$exists = Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk" -ea 0
if ($exists) {
    Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"
}

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'