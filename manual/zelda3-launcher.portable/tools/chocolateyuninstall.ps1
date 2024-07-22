# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$UnzipDirectory = Join-Path $toolsDir 'Zelda 3 Launcher'

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName 'Zelda_3_Launcher_v1.3.6.0.zip'

# Remove-Item $UnzipDirectory

Remove-Item "$env:UserProfile\Desktop\Zelda 3 Launcher.lnk"
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Zelda 3 Launcher.lnk"

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyZipPackage $packageName # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.

