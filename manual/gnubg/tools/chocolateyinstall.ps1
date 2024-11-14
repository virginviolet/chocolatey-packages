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
  Write-Debug "PowerShell >= 5.0"
  Start-CheckandStop "bearoffdump" 6> $null
} else {
  Write-Debug "PowerShell < 5.0"
  Start-CheckandStop "bearoffdump"
}

function Get-AutoHotkeyExePath {
  param (
    [string] $InstallDirPath
  )
  $executables = @(
    'AutoHotkey.exe'
    'AutoHotkeyU64.exe'
    'AutoHotkeyA64.exe'
    'AutoHotkeyU32.exe'
    'AutoHotkeyA32.exe'
  )
  foreach ($executable in $executables) {
    $autoHotKeyPathTestPath = Join-Path -Path -ChildPath $executable
    if (Test-Path $autoHotKeyPathTestPath -PathType Leaf) {
      Write-Debug "AutoHotKey found at '$autoHotKeyPath'."
      return $autoHotKeyPathTestPath
    }
  }
  Write-Debug "AutoHotKey not found."
}

# Get AutoHotKey path
$toolsDirPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exeInstallerPath = Join-Path $toolsDirPath 'gnubg-1_08_003-20240428-setup.exe'
if ($autoHotKeyPath) {
  $autoHotKeyPathFound = $true
  Write-Debug "AutoHotKey path is set to '$autoHotKeyPath'."
}
if (-not $autoHotKeyPathFound) {
  Write-Debug "Finding AutoHotKey path..."
  $ahkPortableInstalled = choco list --limit-output -e autohotkey.portable
  $ahkInstallInstalled = choco list --limit-output -e autohotkey.install
} if ($ahkPortableInstalled) {
  Write-Debug "autohotkey.portable is installed."
  $libPath = Split-Path -Parent "$($packagePath)"
  try {
    $autoHotKeyPath = Convert-Path -Path "$libPath\tools\AutoHotkey\AutoHotkey.exe"
    break
  } catch [System.Management.Automation.CommandNotFoundException] {
    if (-not $ahkInstallInstalled) {
      Write-Error "AutoHotKey not found. Please reinstall autohotkey.portable.`n$_"
    } else {
      Write-Warning "AutoHotKey not found. Please reinstall autohotkey.portable.`n$_"
    }
  } catch {
    if (-not $ahkInstallInstalled) {
      Write-Error "$_"
    } else {
      Write-Warning "$_"
    }
  }
  if ($ahkInstallInstalled) {
    Write-Debug "autohotkey.install is installed."
    try {
      Write-Debug "Looking for AutoHotKey path in registry..."
      $regKeyPath = "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey"
      $regKeyValueName = "InstallDir"
      $installDir = Get-ItemPropertyValue -Path $regKeyPath -Name $regKeyValueName
      $installDirExists = Test-Path ($installDir) -PathType Container
      if ($installDirExists) {
        $autoHotKeyPath = Get-AutoHotkeyPath -Path $installDir
        if ($autoHotKeyPath) {
          Write-Warning "AutoHotKey path found in the registry."
          break
        }
      }
    } catch [System.Management.Automation.ItemNotFoundException] {
      $message = "Could not get registry key.`n" + `
        "The key '$Path' does not exist.`n$_"
      Write-Warning $message
    } catch [System.Management.Automation.PSArgumentException] {
      $message = "Could not get registry key.`n" + 
      "The key '$Path' does not have the value '$Name'.`n$_"
      Write-Warning $message
    } catch {
      Write-Warning $_
    }
    Write-Warning "AutoHotKey not found in the registry."
    $installDir = Get-AppInstallLocation 'AutoHotKey*'
    if ($installDir) {
      $installDirExists = Test-Path ($installDir) -PathType Container
      if ($installDirExists) {
        $autoHotKeyPath = Get-AutoHotkeyPath -Path $installDir
        if ($autoHotKeyPath) {
          break
        }
      }
    }
  }
  Write-Error "AutoHotKey not found."
}

# Get the AutoHotKey version
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

# Run AutoHotKey script that a hides the compiler window that appears during installation
# Run the script correct script for the found version of AutoHotKey
$ahk1ScriptPath = Join-Path $toolsDirPath -ChildPath 'install_ahk1.ahk'
$ahk2ScriptPath = Join-Path $toolsDirPath -ChildPath 'install_ahk2.ahk'
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

# Install
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
Install-ChocolateyInstallPackage @packageArgs
