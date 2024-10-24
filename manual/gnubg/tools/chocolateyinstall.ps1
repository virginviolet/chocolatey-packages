# Other steps for installing gnubg with Chocolatey

# Preferences
$ErrorActionPreference = 'Stop' # stop on all errors

# Prevent force install if any of these programs are running
# (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1
# unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
# GUI version of the game
Start-CheckandThrow "gnubg" > $null
# Command line version of the game
Start-CheckandThrow "gnubg-cli" > $null
# Bundled program for generating bearoff databases
Start-CheckandThrow "makebearoff" > $null
# Bundled program for generating databases for Hypergammon
Start-CheckandThrow "makehyper" > $null
# Bundled program for generating a GNU Backgammon binary weights file
Start-CheckandThrow "makeweights" > $null

# Close the following program if it is running
# Bundled program for dumping a position from the
# GNU Backgammon bearoff database
# Check PowerShell version
# (Start-CheckandStop uses Write-Host, so output can only be suppressed
# in PowerShell > 5.0)
if ($PSVersionTable.PSVersion.Major -ge 5) {
  # Redirect to Success stream before $null,
  # in case the author ever decides to move away from Write-Host
  Write-Debug "PowerShell >= 5.0"
  Start-CheckandStop "bearoffdump" 6>&1 > $null
} else {
  Write-Debug "PowerShell < 5.0"
  Start-CheckandStop "bearoffdump" > $null
}

# Run EXE installer
# - https://docs.chocolatey.org/en-us/create/functions/install-chocolateyinstallpackage
# Start AutoHotKey script to hide compiler window
$toolsDirPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$exeInstallerPath = Join-Path $toolsDirPath 'gnubg-1_08_003-20240428-setup.exe'
$ahk1ScriptPath = Join-Path $toolsDirPath -ChildPath 'install_ahk1.ahk'
$ahk2ScriptPath = Join-Path $toolsDirPath -ChildPath 'install_ahk2.ahk'
# Get AutoHotKey path
try {
  # IMPROVE Move to Preferences section
  $autoHotKeyPath = $(Get-Command autohotkey).Source
  # Set custom AutoHotKey path (comment out previous line
  # and uncomment next line)
  # $autoHotKeyPath = "C:\Program Files\AutoHotkey\AutoHotkey.exe"
} catch [System.Management.Automation.CommandNotFoundException] {
  Write-Error "AutoHotKey not found.`n$_"
} catch {
  Write-Error "$_"
}
# Run AutoHotKey script that a hides window that appears during installation
# Run the script correct script for the found version of AutoHotKey
$ahkVersionMajor = $(Get-Command $autoHotKeyPath).Version.Major
if ($ahkVersionMajor -ge 2) {
  Write-Debug "AutoHotKey >= 2.0"
  $ahkStatements = "/ErrorStdOut=utf-8 ""$ahk2ScriptPath"""
  Start-Process "$autoHotKeyPath" -ArgumentList $ahkStatements -NoNewWindow 2>&1
} else {
  Write-Debug "AutoHotKey < 2.0"
  $ahkStatements = "/ErrorStdOut=utf-8 ""$ahk1ScriptPath"""
  Start-Process "$autoHotKeyPath" -ArgumentList $ahkStatements -NoNewWindow 2>&1
}
# Arguments
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDirPath
  fileType       = 'EXE'
  file           = $exeInstallerPath
  softwareName   = 'GNU Backgammon*' # Display name as it appears in "Installed apps" or "Programs and Features".
  # Checksums
  checksum       = '68CD01D92A99E6EC4BDB5F544C14ECBFCC7D9119AFB0D2AC189698B309E62D06'
  checksumType   = 'sha256' # Default is md5, can also be sha1, sha256 or sha512
  # No 64-bit version has yet been made and published
  # checksum64     = 'INSERT_CHECKSUM'
  # checksumType64 = 'sha256' # Default is checksumType
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # Exit codes indicating success
  validExitCodes = @(0) # Inno Setup
}
# Installer, will assert administrative rights
Install-ChocolateyInstallPackage @packageArgs
