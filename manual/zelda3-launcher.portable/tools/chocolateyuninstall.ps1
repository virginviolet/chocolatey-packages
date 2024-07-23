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
# $tempZelda3 = Join-Path $toolsDir 'zelda3'

Write-Warning 'Zelda 3 will be removed if found in the Zelda 3 Launcher directory.'
Write-Warning 'Settings and save files will not be removed.'
# Start-Sleep 10

# Remove reference saves files directory if empty (not likely though)
$Exists = Test-Path -Path $saveDirRef
$Empty = -Not $(Test-Path -Path $saveDirRef/*)
if ($Empty){
    Remove-Item $saveDirRef
}

# Remove Save directory if empty (not likely though)
$Exists = Test-Path -Path $saveDir
$Empty = -Not $(Test-Path -Path $saveDir/*)
if ($Empty){
    Remove-Item $saveDir
}

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

}

$Exists = Test-Path -Path $zelda3Dir
$Empty = -Not $(Test-Path -Path $zelda3Dir/*)

if ($Exists -And -Not $Empty){
    Remove-Item $zelda3Dir
}

# Remove desktop shortcut if it exist (it's plausible the user might have removed it)
$Exists = Test-Path -Path "$env:UserProfile/Desktop/Zelda 3 Launcher.lnk"

if ($Exists){
    Remove-Item "$env:UserProfile/Desktop/Zelda 3 Launcher.lnk"
}

# Remove start menu shortcut if it exist (it's plausible the user might have removed it)
$Exists = Test-Path -Path "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Zelda 3 Launcher.lnk"

if ($Exists){
    Remove-Item "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Zelda 3 Launcher.lnk"
}


Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyZipPackage $packageName # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.

