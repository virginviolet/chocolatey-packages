# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
# $toolsDir = "C:\ProgramData\chocolatey\lib\flips\tools"
# $zipArchive = Join-Path $toolsDir -ChildPath 'flips-windows.zip'
$unzipDir = Join-Path $toolsDir -ChildPath 'flips-windows'
$executableDir = Join-Path $unzipDir -ChildPath 'builds\windows-x64-gui.zip'
$removeRegistryKeys = Join-Path $toolsDir -ChildPath 'removeregistrykeys.ps1'

# Check if running in administrative shell
function Test-Administrator {  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

# Until the following feature is implemented, I prefer to remove process in both chocolateyuninstall and chocolateybeforemodify:
# https://github.com/chocolatey/choco/issues/1731
Remove-Process "flips" # TODO test

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName '$zipArchive' # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Uninstall-ChocolateyZipPackage will remove the FILES from the archive.
# If you wish to remove the DIRECTORY they were extracted too,
# you'll additionally have to handle that in this script.
Remove-Item $unzipDir -Recurse -Force

# Remove desktop shortcut if it exists (it's plausible the user might have removed it)
$exists = [bool](Test-Path -Path "$env:UserProfile\Desktop\Floating IPS.lnk")
if ($exists) {
    Remove-Item "$env:UserProfile\Desktop\Floating IPS.lnk"
}

# Check if start menu shortcut exists (it's plausible the user might have removed it)
$exists = [bool](Test-Path -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Floating IPS.lnk")
# If administrative shell
if (Test-Administrator) {
    # Remove start menu shortcut if it exists
    if ($exists) {
        Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Floating IPS.lnk"
    }
} else {
    # Untested in real non-admin Choco scenario
    if ($exists) {
        Write-Warning "You are not running from an elevated shell. Start menu shortcut will not be removed.";
    }
}

# Remove registry keys (mostly file associations)
& $removeRegistryKeys $executableDir

# [x] Separate file ext removal into its own script