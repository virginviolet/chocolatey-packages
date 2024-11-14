<#
  .SYNOPSIS
  Uninstalls GNU Backgammon (GnuBG).

  .DESCRIPTION
  Chocolatey executes this script to uninstall GNU Backgammon (GnuBG).  
  It ensures that no related processes are running before proceeding with the uninstallation.
  Additionally, it temporary moves the GNU Backgammon preferences directories to prevent GUI prompts
  during the uninstallation process.

  .EXAMPLE
  chooco uninstall gnubg -y
  Uninstalls the gnubg package.

  .NOTES
  - The script prevents uninstallation if any related processes are running to avoid data loss.
  - It moves the GNU Backgammon preferences directory to a temporary location before uninstallation
    and restores it afterwards.
  - It includes debug and verbose messages to provide detailed information during execution.

  .LINK
  https://community.chocolatey.org/packages/gnubg
  https://github.com/virginviolet/chocolatey-packages/tree/main/manual/gnubg
#>

# Other steps for uninstalling gnubg with Chocolatey

# Initialization
$ErrorActionPreference = 'Stop' # Stop on all errors

# Prevent uninstall if any of these programs are running
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

# Remove empty GNUbg preferences folders
# (This mitigates the installer showing a GUI prompt 
# when GNUbg preferences directory exists)
# Remove '.gnubg/backup/' directory if it exists and is empty
$gnuBgPreferencesDir = Join-Path "$env:UserProfile" -ChildPath '.gnubg/'
$gnuBgPreferencesBackupDir = Join-Path "$gnuBgPreferencesDir" -ChildPath 'backup/'
$exists = Test-Path "$gnuBgPreferencesBackupDir" -PathType Container
$empty = -not ([bool](Test-Path "$gnuBgPreferencesBackupDir\*"))
if ($exists -and $empty) {
  Write-Debug "Empty GNU Backgammon preferences backup directory found. Removing..."
  Remove-Item -Path $gnuBgPreferencesBackupDir
  Write-Debug "Empty GNU Backgammon preferences backup directory removed."
}
# Remove '.gnubg/' directory if it is empty
$exists = Test-Path "$gnuBgPreferencesDir" -PathType Container
$empty = -not ([bool](Test-Path "$gnuBgPreferencesDir\*"))
if ($exists -and $empty) {
  Write-Debug "Empty GNU Backgammon preferences directory found. Removing..."
  Remove-Item -Path $gnuBgPreferencesDir
  Write-Debug "Empty GNU Backgammon preferences directory removed."
}

# Uninstall
# Arguments for 'Get-UninstallRegistryKey' and 'Uninstall-ChocolateyPackage'
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'GNU Backgammon*' # Name used in "Installed apps" or "Programs and Features".
  fileType       = 'EXE'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # Exit codes indicating success
  validExitCodes = @(0) # Inno Setup
}
# Get uninstall registry keys that match the softwareName pattern
[array]$keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
# Perform action based on the number of matching keys
# If 0 keys matched
if ($keys.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
  # If more than 1 keys matched
} elseif ($keys.Count -gt 1) {
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
  # If 1 key matched
} elseif ($keys.Count -eq 1) {
  # Uninstall
  # Adjust arguments
  $keys | ForEach-Object {
    $packageArgs['file'] = "$($_.UninstallString)"
    $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
    # Move GNU Backgammon preferences directory to TEMP before uninstalling
    # (otherwise, the installer will show a GUI prompt)
    $shouldRestorePrefsDir = $false
    $gnuBgPreferencesTempDir = Join-Path $env:TEMP -ChildPath '.gnubg/'
    # Move directory if it exists
    $exists = Test-Path "$gnuBgPreferencesDir" -PathType Container
    if ($exists) {
      Write-Warning "GNU Backgammon preferences directory found."
      Write-Warning "GNU Backgammon preferences directory will *not* be removed."
      # Pause so that the user has time to read.
      # Chocolatey stops Pause after 30 seconds by default.
      Pause
      # Edge case where there already exists a directory named '.gnubg/' in TEMP
      # (likely from a failed previous uninstallation)
      $gnuBgPreferencesTempDirExists = Test-Path "$gnuBgPreferencesTempDir" -PathType Container
      if ($gnuBgPreferencesTempDirExists) {
        $message = "A GNU Backgammon preferences directory already exists in " `
          + "the temporary direcotry. Please move or remove it, then run the " `
          + "uninstallation again. `n" `
          + "Location: '$gnuBgPreferencesTempDir'"
        Write-Error "$message"
      }
      Write-Verbose "Moving '.gnubg/' from '$env:UserProfile' to '$env:TEMP'..."
      Move-Item -Path $gnuBgPreferencesDir -Destination "$env:TEMP" -Force
      Write-Verbose "Moved '.gnubg/' from '$env:UserProfile' to '$env:TEMP'."
      $shouldRestorePrefsDir = $true
    } else {
      Write-Debug "GNU Backgammon preferences directory not found."
    }
    # Run uninstaller and restore '.gnubg\' from TEMP
    if ($shouldRestorePrefsDir) {
      # If installation fails, restore '.gnubg\' to its original location
      # before stopping the script.
      try {
        Write-Debug "Running installer..."
        Uninstall-ChocolateyPackage @packageArgs
      } catch {
        # Restore GNUbg preferences directory if installation failed.
        Write-Verbose "Installation failed."
        Write-Error "Could not install $env:ChocolateyPackageName.`n$_"
      } finally {
        Write-Verbose "Restoring preferences directory..."
        Write-Verbose "Moving '.gnubg/' from '$env:TEMP' to '$env:UserProfile'..."
        Move-Item -Path $gnuBgPreferencesTempDir -Destination "$env:UserProfile" -Force
        Write-Verbose "Moved '.gnubg/' from '$env:TEMP' to '$env:UserProfile'."
        Write-Verbose "Preferences directory restored."
      }
      # Inform user if preferences exists.
      $exists = Test-Path -Path "$gnuBgPreferencesDir" -PathType Container
      $message = "GNU Backgammon preferences directory remains.`n" `
        + "Manually remove it if you do not wish to keep it.`n" `
        + "GNU Backgammon preferences directory: $gnuBgPreferencesDir"
      Write-Warning $message
       # Give the user time to read
      Start-Sleep -Seconds 5
    } else {
      # Uninstall directly
      # It feels, perhaps unfoundedly, safer to not use try-catch
      # for Chocolatey package installation, so let's avoid it when possible
      Write-Debug "Running installer..."
      Uninstall-ChocolateyPackage @packageArgs
    }
  }
}
