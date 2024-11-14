# Other steps for installing gnubg with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors
# $autoHotKeyPath = 'C:\Program Files\AutoHotkey\AutoHotkey.exe'

# Prevent force install if any of these programs are running
# (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1
# unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
# GUI version of the game
Start-CheckandThrow -ProcessName "gnubg"
# Command line version of the game
Start-CheckandThrow -ProcessName "gnubg-cli"
# Bundled program for generating bearoff databases
Start-CheckandThrow -ProcessName "makebearoff"
# Bundled program for generating databases for Hypergammon
Start-CheckandThrow -ProcessName "makehyper"
# Bundled program for generating a GNU Backgammon binary weights file
Start-CheckandThrow -ProcessName "makeweights"

# Close the following program if it is running
# Bundled program for dumping a position from the
# GNU Backgammon bearoff database
# Check PowerShell version
# (Start-CheckandStop uses Write-Host, so output can only be suppressed
# in PowerShell > 5.0)
if ($PSVersionTable.PSVersion.Major -ge 5) {
  Write-Debug "PowerShell >= 5.0"
  Start-CheckandStop -ProcessName "bearoffdump" 6> $null
} else {
  Write-Debug "PowerShell < 5.0"
  Start-CheckandStop -ProcessName "bearoffdump"
}

# Load helper to get process ID later
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$helpersPath = Join-Path -Path $toolsDirPath -ChildPath 'helpers'
Write-Debug "Loading helper 'Get-ProcessId' from '$helpersPath'..."
$getProcessIdPath = Join-Path -Path $helpersPath -ChildPath 'Get-ProcessId'
. $getProcessIdPath
Write-Debug "Helper loaded."

# Get AutoHotkey path
if ($autoHotKeyPath) {
  Write-Debug "AutoHotkey path is set to '$autoHotKeyPath'."
} else {
  Write-Debug "Loading helper 'Get-AutoHotkeyPath' from '$helpersPath'..."
  $getAutoHotkeyPath = Join-Path -Path $helpersPath -ChildPath 'Get-AutoHotkeyPath'
  . $getAutoHotkeyPath
  Write-Debug "Helper loaded."
  $packagePath = Split-Path -Parent $toolsDirPath
  $libPath = Split-Path -Parent $packagePath
  $autoHotKeyPath = Get-AutoHotkeyPath -LibPath $libPath
}
# Get AutoHotkey version
$ahkVersionMajor = $(Get-Command $autoHotKeyPath).Version.Major
Write-Debug "AutoHotkey v$ahkVersionMajor found."

# Run AutoHotkey script that a hides the compiler window that appears during installation
# Run the correct script for the correct AutoHotkey version
$ahk1ScriptPath = Join-Path -Path $toolsDirPath -ChildPath 'install_ahk1.ahk'
$ahk2ScriptPath = Join-Path -Path $toolsDirPath -ChildPath 'install_ahk2.ahk'
if ($ahkVersionMajor -ge 2) {
  Write-Debug "AutoHotkey >= 2.0"
  $ahkScriptPath = $ahk2ScriptPath
} else {
  Write-Debug "AutoHotkey < 2.0"
  $ahkScriptPath = $ahk1ScriptPath
}
$ahkStatements = "/ErrorStdOut=utf-8 ""$ahkScriptPath"""
$ahkProcess = Start-Process -FilePath $autoHotKeyPath -ArgumentList $ahkStatements -NoNewWindow -PassThru 2>&1
Write-Debug "AutoHotkey script '$ahkScriptPath' executed."

try {
  Write-Debug "Getting AutoHotkey process ID."
  $ahkProcessId = Get-ProcessId -CommandLine "$ahkScriptPath"
  Write-Debug "AutoHotkey process ID: '$ahkProcessId'."
} catch {
  Write-Warning "Could not get AutoHotkey process ID.`n$_"
}

# Install
# Installer path
$exeInstallerPath = Join-Path $toolsDirPath 'gnubg-1_08_003-20240428-setup.exe'
# Arguments
$packageArgs = @{
  packageName    = "$($packageName)"
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath
  softwareName   = 'GNU Backgammon*' # Name used in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = '68CD01D92A99E6EC4BDB5F544C14ECBFCC7D9119AFB0D2AC189698B309E62D06'
  checksumType   = 'sha256'
  # No 64-bit version has yet been released
  # checksum64     = 'INSERT_CHECKSUM'
  # checksumType64 = 'sha256'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # Exit codes indicating success
  validExitCodes = @(0) # Inno Setup
}
# Run the installer (will assert administrative rights)
try {
  Install-ChocolateyInstallPackage @packageArgs
} catch {
  # Untested
  Write-Warning "Installation failed. Terminating AutoHotkey script."
  $errorMessage = $_
  try {
    Stop-Process -Id $ahkProcessId -Force
  } catch {
    Write-Error "Could not terminate AutoHotkey script.`n$_"
    throw
  }
  Write-Error "Could not install '$($packageName)'.`n$ErrorMessage"
  throw
}
