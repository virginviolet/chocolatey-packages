# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:/path/to/thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^/s*#"} | % {$_ -replace '(^.*?)/s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$unzipDir   = "C:/Games/Zelda 3 Launcher"
$zelda3Dir  = Join-Path $unzipDir 'zelda3'
$saveDir    = Join-Path $zelda3Dir 'Saves'
$saveDirRef = Join-Path $saveDir 'ref'
$config     = Join-Path $zelda3Dir 'zelda.ini'
$tempZelda3 = Join-Path $env:TEMP 'zelda3'

# Try to remove reference saves files directory
try {Remove-Item $saveDirRef} catch {}

# Remove Save directory if empty (not likely though)
# Having $ErrorActionPreference set to 'Stop' makes it stop on `Test-Path` if the path does not exist.
# Therefore, I have to wrap them into try catch statemnts.
try {
    $Exists = Test-Path -Path $saveDir
    $Empty = -Not $(Test-Path -Path $saveDir/*)
    if ($Empty){
        Remove-Item $saveDir
    }
} catch {}

try {
    Write-Warning 'Zelda 3 WILL be removed.'
    Write-Warning 'Settings and save files will NOT be removed.'
    Start-Sleep 10
    $Exists = Test-Path -Path $zelda3Dir
    $Empty = -Not $(Test-Path -Path $zelda3Dir/*)

    if ($Exists -And -Not $Empty){
        # Move saves and confg to temporary location (because Powershell is hell)
        New-Item -ItemType Directory -Path $tempZelda3
        Write-Warning "Created directory."
        # Start-Sleep 5
        
        # Remove reference save files
        $Exists = Test-Path -Path $saveDirRef
        if ($Exists) {
            Remove-Item $saveDirRef -Recurse -Force
        }

        # Move Saves to temporary location
        $Exists = Test-Path -Path $saveDir
        if ($Exists) {
            Move-Item -Path $saveDir -Destination $tempZelda3
        }

        # Move config to temporary location
        $Exists = Test-Path -Path $config
        if ($Exists) {
            Move-Item -Path $config -Destination $tempZelda3
        }

        # Remove everything in the launcher directory, including zelda3
        Remove-Item $unzipDir/* -Force -Recurse

        # Move saves and config back to the game directory
        Move-Item -Path $tempZelda3 -Destination $unzipDir

        Write-Warning 'Remove config file save files manually if so desired.'
    } else {
        # Remove the launcher directory
        Remove-Item $unzipDir -Force -Recurse
        }
} catch {}

# Try to remove desktop shortcut (it's plausible the user might have removed it)
try {Remove-Item "$env:UserProfile/Desktop/Zelda 3 Launcher.lnk"} catch {}

# Try to remove start menu shortcut (it's plausible the user might have removed it)
try {Remove-Item "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Zelda 3 Launcher.lnk"} catch {}

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'