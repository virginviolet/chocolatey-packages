$ErrorActionPreference = 'Stop'
$fileManualDir = 'C:\Program Files (x86)\parallel-launcher'
$fileManual    = Join-Path $fileManualDir 'Manual.pdf'
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'parallel-launcher'
  fileType      = 'MSI'
  validExitCodes= @(0, 3010, 1605, 1614, 1641)
  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
}

$ErrorActionPreference = 'SilentlyContinue'

# This is not working
$uninstalling = Get-Process "Setup/Uninstall*"
if ($uninstalling) {
  "Waiting for setup to finish..."
  Wait-Process -Name "Setup/Uninstall*" -Timeout 180 2> $null
}

Remove-Item $fileManual 2> $null

# Delete empty installation folder.
$FolderNotEmpty = Test-Path -Path $fileManualDir\*
if (-Not $FolderNotEmpty){
    Remove-Item $fileManualDir 2> $null
}