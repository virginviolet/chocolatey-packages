﻿$ErrorActionPreference = 'Stop' # stop on all errors
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
Remove-Process "flips"

Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -ZipFileName '$zipArchive' # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage

# Uninstall-ChocolateyZipPackage will remove the FILES from the archive.
# This removes the DIRECTORY they were extracted too.
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
