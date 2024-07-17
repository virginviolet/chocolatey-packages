$ErrorActionPreference = 'Inquire'

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
