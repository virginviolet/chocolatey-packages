# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$unzipDir   = "C:\Games\Zelda 3 Launcher"
$zelda3Dir  = Join-Path $unzipDir 'zelda3'
$saveDir    = Join-Path $zelda3Dir 'Saves'
$config     = Join-Path $zelda3Dir 'zelda.ini'
$tempZelda3 = Join-Path $env:TEMP 'zelda3'
# $tempZelda3 = Join-Path $toolsDir 'zelda3'

Write-Warning 'Zelda 3 will be removed if found in the Zelda 3 Launcher directory.'
Write-Warning 'Settings and save files will not be removed.'
# Start-Sleep 10

# Move saves and confg to temporary location (because Powershell is hell), if they exist
New-Item -ItemType Directory -Path $tempZelda3
Write-Warning "Created folder."
# Start-Sleep 5

# Remove reference save files if they exist
try {Remove-Item $(Join-Path $saveDir ref) -Force -Recurse} catch {}

# If we cannot move, the folders and file likely do not exist, which is fine.
try {Move-Item -Path $saveDir -Destination $tempZelda3} catch {Write-Warning "Could not move saves."}
try {Move-Item -Path $config -Destination $tempZelda3} catch {Write-Warning "Could not move config."}

# Remove everything in the launcher directory, including zelda3 (including saves and config)
Remove-Item $unzipDir\* -Force -Recurse

# Move saves and config back to the game directory
try {Move-Item -Path $tempZelda3 -Destination $unzipDir} catch {Write-Warning "Could not move save files and config from $env:TEMP\zelda3 back to $unzipDir\zelda3."}
Remove-Item $tempZelda3 -Recurse -Force

try {Remove-Item "C:\Games\Zelda 3 Launcher\triforce.ico"} catch {}
try {Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"} catch {}
try {Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"} catch {}

# Delete empty installation directories.

# This directory is not likely to both exist and be empty, but just in case.
try {
  $FolderNotEmpty = Test-Path -Path $saveDir\*
  if (-Not $FolderNotEmpty){
    Remove-Item $saveDir
  }
} catch {}

# This directory is not likely to both exist and be empty, but just in case.
try {
  $FolderNotEmpty = Test-Path -Path $zelda3Dir\*
  if (-Not $FolderNotEmpty){
    Remove-Item $zelda3Dir
  }
} catch {}

try {
  $FolderNotEmpty = Test-Path -Path $unzipDir\*
  if (-Not $FolderNotEmpty){
    Remove-Item $unzipDir
  }
} catch {}

# This directory is not likely exist at this point, but just in case.
try {
  $FolderNotEmpty = Test-Path -Path $tempZelda3\*
  if (-Not $FolderNotEmpty){
    Remove-Item $unzipDir
  }
} catch {}


Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyZipPackage $packageName # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.

