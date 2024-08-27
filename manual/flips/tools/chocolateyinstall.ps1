# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# In Chocolatey scripts, ALWAYS use absolute paths - $toolsDir gets you to the package's tools directory.
$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'flips-windows.zip'
$unzipDir = Join-Path $toolsDir -ChildPath 'flips-windows'
$executableDir = Join-Path $unzipDir -ChildPath 'builds\windows-x64-gui.zip'
$executable = Join-Path $executableDir "flips.exe"

$unzipArgs = @{
  FileFullPath = $zipArchive
  Destination  = $unzipDir
}

## TODO: "flips.exe" → "Floating IPS"

## Helper functions - these have error handling tucked into them already
## see https://docs.chocolatey.org/en-us/create/functions

## Unzips a file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @unzipArgs

## Add desktop shortcut
Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\Floating IPS.lnk" -targetPath $executable -workingDirectory $executableDir -description "Apply IPS and BPS patches."

## Add start menu shortcut
Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Floating IPS.lnk" -targetPath $executable -WorkingDirectory $executableDir -description "Apply IPS and BPS patches."

## Other needs: use regular PowerShell to do so or see if there is a function already defined
# - https://docs.chocolatey.org/en-us/create/functions
# There may also be functions available in extension packages
# - https://community.chocolatey.org/packages?q=id%3A.extension for examples and availability.
