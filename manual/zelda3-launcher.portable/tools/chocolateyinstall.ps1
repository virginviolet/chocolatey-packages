# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:/path/to/thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^/s*#"} | % {$_ -replace '(^.*?)/s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# 1. See the _TODO.md that is generated top level and read through that
# 2. Follow the documentation below to learn how to create a package for the package type you are creating.
$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'Zelda_3_Launcher_v1.3.6.0.zip'
$unzipDir   = "C:/Games/Zelda 3 Launcher"
$executable = Join-Path $unzipDir -ChildPath 'Zelda 3 Launcher.exe'
$triforceIcon = Join-Path $toolsDir -ChildPath 'triforce.ico'

$unzipArgs = @{
  FileFullPath = $zipArchive
  Destination = $unzipDir
}

Get-ChocolateyUnzip @unzipArgs
Copy-Item $triforceIcon $unzipDir # In case the user wants to use this icon for either the launcher or the game (as of typing, the launcher does not add an icon to zelda3.exe when building it).
Install-ChocolateyShortcut -ShortcutFilePath "$env:UserProfile/Desktop/Zelda 3 Launcher.lnk" -TargetPath $executable -WorkingDirectory $unzipDir
Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/Zelda 3 Launcher.lnk" -TargetPath $executable -WorkingDirectory $unzipDir