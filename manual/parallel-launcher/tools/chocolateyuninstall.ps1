# Initialization
$ErrorActionPreference = 'Stop'
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# Preferences
$installDirPath = 'C:\Program Files (x86)\parallel-launcher'
$pdfManualInstallPath = Join-Path "$installDirPath" -ChildPath 'Manual.pdf'

# Function
function Get-ProcessNames {
  param (  
    [parameter(Mandatory = $true, Position = 0)]
    [string]
    $CommandLine
  )
  $commandLineEscaped = $CommandLine -replace '\\', '\\' `
    -replace ':', '\:' -replace '\(', '\(' -replace '\)', '\)'
  $processNames = Get-WmiObject Win32_Process | Where-Object {
    $_.CommandLine -match $commandLineEscaped
  } | ForEach-Object {
    Write-Output "$($_.Name)"
  }
  return $processNames
}

# Prevent uninstall if retroarch (which Parallel Launcher uses) is running, to ensure
# no progress is lost
# This cannot be moved to chocolateybeforemodify.ps1 unless this feature is added:
# https://github.com/chocolatey/choco/issues/1731
Start-CheckandThrow "retroarch"

# Uninstall
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'Parallel Launcher*'
  fileType       = 'EXE'
  # silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes = @(0) # Inno Setup
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# Perform action based on the number of matching keys
if ($keys.Count -eq 0) {
  # If 0 keys matched
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($keys.Count -gt 1) {
  # If more than 1 matches were found
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
} elseif ($keys.Count -eq 1) {
  # If 1 match was found
  $keys | ForEach-Object {
    # Adjust arguments
    # - You probably will need to sanitize $packageArgs['file'] as it comes from the registry and could be in a variety of fun but unusable formats
    # - Ensure you don't pass double quotes in $file (aka $packageArgs['file']) - otherwise you will get "Illegal characters in path when you attempt to run this"
    $packageArgs['file'] = "$($_.UninstallString)" # NOTE: You may need to split this if it contains spaces
    # - Split args from exe in $packageArgs['file'] and pass those args through $packageArgs['silentArgs'] or ignore them
    # - Review the code for auto-uninstaller for all of the fun things it does in sanitizing - https://github.com/chocolatey/choco/blob/bfe351b7d10c798014efe4bfbb100b171db25099/src/chocolatey/infrastructure.app/services/AutomaticUninstallerService.cs#L142-L192
    $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
    # Load Wait-ProcessStart function
    $WaitProcessStartPath = Join-Path "$toolsDirPath" -ChildPath 'Wait-ProcessStart'
    . $WaitProcessStartPath
    # Run uninstaller
    Uninstall-ChocolateyPackage @packageArgs
    # The uninstaller exe ('unins000.exe') generates a new process
    # with a random name. When original exe stops, Chocolatey thinks the
    # installation is finished. We have to catch the new process,
    # so that we can wait until the uninstaller is really finished.
    $processes = (Get-ProcessNames -CommandLine "$installDirPath")
    if ($processes -is [string]) {
      # If one process matched, '$processes' will be a string
      $process = $processes
    } else {
      # If multiple processes matched, use the last match
      $process = $processes[-1]
    }
    Wait-ProcessStart $process -Milliseconds 30000 -Interval 100
    try {
      Write-Verbose "Wating for uninstaller to finish..."
      Wait-Process $process -Timeout 900 # 15 minutes
      Write-Debug "Uninstaller seems to have finished."
    } catch [System.Management.Automation.SessionStateUnauthorizedAccessException] {
      Write-Output "Waiting for process '$process' timed out.`n$_"
    } catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
      Write-Debug "Process '$process' not found.`n$_"
    } catch {
      Write-Warning "Could not find process '$process'.`n$_"
    }
  }
}

# Uninstall manual
$exists = Test-Path "$pdfManualInstallPath" -PathType Leaf
if ($exists) {
  try {
    Write-Verbose "Uninstalling manual..."
    Remove-Item "$pdfManualInstallPath"
    Write-Debug "Manual uninstalled."
  } catch {
    Write-Warning "Could not uninstall manual.`n$_"
  }
} else {
  $message = "Manual could not be found. " + `
    "It may have been uninstalled by other means."
  Write-Warning $message
}

# Remove empty directories
$RemoveEmptyDirectoriesPath = Join-Path "$toolsDirPath" -ChildPath 'Remove-EmptyDirectories'
. $RemoveEmptyDirectoriesPath
$InvokeEmptyDirectoryRemovalPath = Join-Path "$toolsDirPath" -ChildPath 'Invoke-EmptyDirectoryRemoval'
. $InvokeEmptyDirectoryRemovalPath;
Write-Debug "Running 'Invoke-EmptyDirectoryRemoval ""$installDirPath"" ""installation""'..."
Invoke-EmptyDirectoryRemoval "$installDirPath" "installation"
$dataDirPath = Join-Path "$Env:LOCALAPPDATA" -ChildPath 'parallel-launcher'
Write-Debug "Running 'Invoke-EmptyDirectoryRemoval ""$dataDirPath"" ""application data""'..."
Invoke-EmptyDirectoryRemoval "$dataDirPath" "application data"
