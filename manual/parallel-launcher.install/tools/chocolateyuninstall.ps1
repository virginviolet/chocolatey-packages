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

# This is not working$uninstalling = Get-Process "unins000*"
if ($uninstalling) {
  Write-Output 'Waiting for uninstaller to finish...'
  Wait-Process -Name "unins000*" -Timeout 3600 # 60 minutes
}

Remove-Item $fileManual

# Delete empty installation folder.
$FolderNotEmpty = Test-Path -Path $fileManualDir\*
if (-Not $FolderNotEmpty){
    Remove-Item $fileManualDir
}