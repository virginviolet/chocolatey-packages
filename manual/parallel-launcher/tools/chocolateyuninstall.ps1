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

# Prevent uninstall if retroarch (which Parallel Launcher uses) is running, to ensure
# no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless this feature is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "retroarch"

# It seems chocolatey waits to run the auto uninstaller until after this script has finished,
# rending this block actually useless. Maybe there is a workaround that I have not found.
# It's not a huge deal, but chocolatey will report successful uninstallation before the uninstaller has fininshed.
# Start-Sleep -Seconds 30 # Uncomment to see that the auto-uninstaller runs after this script.
$uninstallerRunning = Get-Process -Name "unins000*"
if ($uninstallerRunning) {
  Write-Output 'Waiting for uninstaller to finish...'
  Wait-Process -Name "unins000*" -Timeout 180 # 3 minutes
}

$exists = Test-Path -Path $fileManual -ea 0
if ($exists){
  Remove-Item $fileManual
}

# Delete empty installation folder.
$empty = -Not (Test-Path -Path $fileManualDir\* -ea 0)
if ($empty){
  Remove-Item $fileManualDir
}
