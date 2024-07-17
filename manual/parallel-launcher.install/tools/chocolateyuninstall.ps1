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

# It seems chocolatey waits to run the auto uninstaller until after this script,
# which is unfortunate.
# Start-Sleep -Seconds 10

$uninstalledPackage = Test-Dependency "parallel-launcher.install"
if (-Not $uninstalledPackage) {
  Write-Warning 'Waiting 10 seconds because the auto uninstaller has not finished yet...'
  Start-Sleep -Seconds 10
} else {
  Write-Warning 'Package is uninstalled.'

$uninstallerRunning = Get-Process "unins000*"
if ($uninstallerRunning) {
  Write-Warning 'Waiting for uninstaller to finish...'
  Wait-Process -Name "unins000*" -Timeout 3600 # 60 minutes
} else {
  Write-Warning 'No uninstaller is running.'
}
}

Remove-Item $fileManual

# Delete empty installation folder.
$FolderNotEmpty = Test-Path -Path $fileManualDir\*
if (-Not $FolderNotEmpty){
    Remove-Item $fileManualDir
}

Write-Warning 'Done!'