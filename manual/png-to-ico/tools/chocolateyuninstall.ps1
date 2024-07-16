$ErrorActionPreference = 'Inquire'

# Specify the name or path of a .bat file to terminate
$targetBatFile = "png_to_ico.bat"

# Get all cmd processes
$cmdProcesses = Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE Name = 'cmd.exe'"

foreach ($process in $cmdProcesses) {
    # Get the command line arguments of the process
    $commandLine = $process.CommandLine

    # Check if the command line contains the target .bat file
    if ($commandLine -like "*$targetBatFile*") {
        Write-Host "Terminating process $($process.ProcessId) running $targetBatFile"
        # Terminate the process
        Stop-Process -Id $process.ProcessId -Force
    }
}

$ErrorActionPreference = 'SilentlyContinue'

Stop-Process -Name "png_to_ico_setup.exe" -F
Stop-Process -Name "png_to_ico_uninstaller.exe" -F

Import-Module -Name 'C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1'

$ErrorActionPreference = 'Stop'
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'PNG-to-ICO'
  fileType      = 'EXE'
  silentArgs   = '/S'
  validExitCodes= @(0)
}

[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % {
    $packageArgs['file'] = "$($_.UninstallString.Trim('"'))"
    $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"

Uninstall-ChocolateyPackage @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}

