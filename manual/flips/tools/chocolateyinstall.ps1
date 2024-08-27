$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath 'flips-windows.zip'
$unzipDir = Join-Path $toolsDir -ChildPath 'flips-windows'
$executableDir = Join-Path $unzipDir -ChildPath 'builds\windows-x64-gui.zip'
$exe = "flips.exe"
$executable = Join-Path $executableDir -ChildPath $exe

$unzipArgs = @{
  FileFullPath = $zipArchive
  Destination  = $unzipDir
}

## Unzips file to the specified location - auto overwrites existing content
Get-ChocolateyUnzip @unzipArgs

# Add friendly app name (default is 'flips.exe')
# for current user only, because... I don't know, then I won't have to rewrite a function in removeregistrykeys.ps1 and make it more complicated.
$friendlyAppName = "Floating IPS"
$keyPath = "REGISTRY::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
$valueName = Join-Path $executableDir -ChildPath "$exe.FriendlyAppName"
$valueData = $friendlyAppName
$valueOk = [bool](Get-ItemProperty -Path $keyPath -Name $valueName -ea 0) # value exists
if ($valueOk) {
  Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -Type STRING
} else {
  New-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -Type STRING
}

## Add desktop shortcut
Install-ChocolateyShortcut -shortcutFilePath "$env:UserProfile\Desktop\Floating IPS.lnk" -targetPath $executable -workingDirectory $executableDir -description "Apply IPS and BPS patches."

## Add start menu shortcut
Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Floating IPS.lnk" -targetPath $executable -WorkingDirectory $executableDir -description "Apply IPS and BPS patches."
