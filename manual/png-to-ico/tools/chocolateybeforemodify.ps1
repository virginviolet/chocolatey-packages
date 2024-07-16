<<<<<<< HEAD
﻿# This runs before upgrade or uninstall.
# Use this file to do things like stop services prior to upgrade or uninstall.
# NOTE: It is an anti-pattern to call chocolateyUninstall.ps1 from here. If you
#  need to uninstall an MSI prior to upgrade, put the functionality in this
#  file without calling the uninstall script. Make it idempotent in the
#  uninstall script so that it doesn't fail when it is already uninstalled.
# NOTE: For upgrades - like the uninstall script, this script always runs from
#  the currently installed version, not from the new upgraded package version.

=======
﻿$ErrorActionPreference = 'Inquire'

# Specify the name or path of the .bat file to terminate
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
>>>>>>> 29da5e3ae705b68d3c3e7d589d82bc82eb1b94b4
