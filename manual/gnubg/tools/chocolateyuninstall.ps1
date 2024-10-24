# Other steps for uninstalling gnubg with Chocolatey

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage

# Preferences
$ErrorActionPreference = 'Stop' # Stop on all errors

# Prevent uninstall if any of these programs are running
# (so that no progress is lost)
# This cannot be moved to chocolateybeforemodify.ps1
# unless the feature suggested in the following issue is added:
# https://github.com/chocolatey/choco/issues/1731
# GUI version of the game
Start-CheckandThrow "gnubg"
# Command line version of the game
Start-CheckandThrow "gnubg-cli"
# Bundled program for generating bearoff databases
Start-CheckandThrow "makebearoff"
# Bundled program for generating databases for Hypergammon
Start-CheckandThrow "makehyper"
# Bundled program for generating a GNU Backgammon binary weights file
Start-CheckandThrow "makeweights"

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

# Remove empty GNUbg preferences folders
# (This mitigates the installer showing a GUI prompt when GNUbg preferences directory exists)
# Remove '.gnubg/backup/' directory if it exists and is empty
$gnuBgPreferencesDir = Join-Path "$env:UserProfile" -ChildPath '.gnubg/'
$gnuBgPreferencesBackupDir = Join-Path "$gnuBgPreferencesDir" -ChildPath 'backup/'
$exists = Test-Path "$gnuBgPreferencesBackupDir" -PathType Container
$empty = -not ([bool](Test-Path "$gnuBgPreferencesBackupDir\*"))
# Pause
if ($exists -and $empty) {
  # [x] Test
  Write-Debug "Empty GNU Backgammon preferences backup directory found. Removing..."
  # Pause
  Remove-Item $gnuBgPreferencesBackupDir
  Write-Debug "Empty GNU Backgammon preferences backup directory removed."
  # Pause
}
# Remove '.gnubg/' directory if it is empty
$exists = Test-Path "$gnuBgPreferencesDir" -PathType Container
$empty = -not ([bool](Test-Path "$gnuBgPreferencesDir\*"))
# TODO Check if .gnubg/backup empty
if ($exists -and $empty) {
  # [x] Test
  Write-Debug "Empty GNU Backgammon preferences directory found. Removing..."
  # Pause
  Remove-Item $gnuBgPreferencesDir
  Write-Debug "Empty GNU Backgammon preferences directory removed."
  # Pause
}

# Uninstall
# Arguments for 'Get-UninstallRegistryKey' and 'Uninstall-ChocolateyPackage'
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'GNU Backgammon*' # Display name as it appears in "Installed apps" or "Programs and Features".
  fileType       = 'EXE'
  # Uncomment matching installer type (sorted by most to least common)
  # silentArgs   = '/S'           # NSIS
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  # silentArgs   = '/s'           # InstallShield
  # silentArgs   = '/s /v"/qn"'   # InstallShield with MSI
  # silentArgs   = '/s'           # Wise InstallMaster
  # silentArgs   = '-s'           # Squirrel
  # silentArgs   = '-q'           # Install4j
  # silentArgs   = '-s -u'        # Ghost
  # Note that some installers, in addition to the silentArgs above, may also need assistance of AHK to achieve silence.
  # silentArgs   = ''             # none; make silent with input macro script like AutoHotKey (AHK)
  #       https://community.chocolatey.org/packages/autohotkey.portable
  # Exit codes indicating success
  # validExitCodes = @(0) # NSIS
  validExitCodes = @(0) # Inno Setup
  # validExitCodes= @(0) # Insert other valid exit codes here
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
    # - You probably will need to sanitize $packageArgs['file'] as it comes from the registry and could be in a variety of fun but unusable formats
    # - Ensure you don't pass double quotes in $file (aka $packageArgs['file']) - otherwise you will get "Illegal characters in path when you attempt to run this"
    $packageArgs['file'] = "$($_.UninstallString)" # NOTE: You may need to split this if it contains spaces
    # - Split args from exe in $packageArgs['file'] and pass those args through $packageArgs['silentArgs'] or ignore them
    # - Review the code for auto-uninstaller for all of the fun things it does in sanitizing - https://github.com/chocolatey/choco/blob/bfe351b7d10c798014efe4bfbb100b171db25099/src/chocolatey/infrastructure.app/services/AutomaticUninstallerService.cs#L142-L192
    $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
    # Move GNU Backgammon preferences directory to TEMP before uninstalling
    # (otherwise, the installer will show a GUI prompt)
    $shouldRestorePrefsDir = $false
    $gnuBgPreferencesTempDir = Join-Path $env:TEMP -ChildPath '.gnubg/'
    # Move directory if it exists
    # XXX
    # [x] Test
    $exists = Test-Path "$gnuBgPreferencesDir" -PathType Container
    if ($exists) {
      # [x] Test
      Write-Warning "GNU Backgammon preferences directory found."
      Write-Warning "GNU Backgammon preferences directory will *not* be removed."
      # Pause so that the user has time to read.
      # Chocolatey stops Pause after 30 seconds by default.
      Pause
      # Edge case where there already exists a directory named '.gnubg/' in TEMP
      # (likely from a failed previous uninstallation)
      $gnuBgPreferencesTempDirExists = Test-Path "$gnuBgPreferencesTempDir" -PathType Container
      if ($gnuBgPreferencesTempDirExists) {
        # [x] Test
        $message = "A GNU Backgammon preferences directory already exists in " `
          + "the temporary direcotry. Please move or remove it, then run the " `
          + "uninstallation again. `n" `
          + "Location: '$gnuBgPreferencesTempDir'"
        Write-Error "$message"
      }
      Write-Verbose "Moving '.gnubg/' from '$env:UserProfile' to '$env:TEMP'..."
      Move-Item $gnuBgPreferencesDir -Destination "$env:TEMP" -Force
      Write-Verbose "Moved '.gnubg/' from '$env:UserProfile' to '$env:TEMP'."
      $shouldRestorePrefsDir = $true
    } else {
      # [x] Test
      Write-Debug "GNU Backgammon preferences directory not found."
      # Pause
    }
    # Run uninstaller and restore '.gnubg\' from '$env:TEMP'
    if ($shouldRestorePrefsDir) {
      # If installation fails, restore '.gnubg\' to its original location before stopping the script.
      # [x] Test
      try {
        Write-Debug "Running installer..."
        # Pause
        # throw
        Uninstall-ChocolateyPackage @packageArgs
      } catch {
        # [x] Test
        # Restore GNUbg preferences directory if installation failed.
        Write-Verbose "Installation failed."
        Write-Error "Could not install $env:ChocolateyPackageName.`n$_"
        # Pause
      } finally {
        Write-Verbose "Restoring preferences directory..."
        Write-Verbose "Moving '.gnubg/' from '$env:TEMP' to '$env:UserProfile'..."
        # Pause
        Move-Item $gnuBgPreferencesTempDir -Destination "$env:UserProfile" -Force
        Write-Verbose "Moved '.gnubg/' from '$env:TEMP' to '$env:UserProfile'."
        Write-Verbose "Preferences directory restored."
      }
      # [x] Test
      # Inform user if preferences exists.
      $exists = Test-Path "$gnuBgPreferencesDir" -PathType Container
      $message = "GNU Backgammon preferences directory remains.`n" `
        + "Manually remove it if you do not wish to keep it.`n" `
        + "GNU Backgammon preferences directory: $gnuBgPreferencesDir"
      Write-Warning $message
       # Give the user time to read
      Start-Sleep -Seconds 5
    } else {
      # [x] Test
      # Uninstall directly
      # It feels, perhaps unfoundedly, safer to not use try-catch
      # for Chocolatey package installation, so let's avoid it when possible
      Write-Debug "Running installer..."
      # Pause
      Uninstall-ChocolateyPackage @packageArgs
    }
  }
}

## Remove persistent Environment variable
# Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable

## Remove shim
# Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile

## Remove shortcuts
## Look for shortcuts log
# $packagePath = $env:ChocolateyPackageFolder
# $shortcutsLogPath = Join-Path "$packagePath" -ChildPath "shortcuts.txt"
# $exists = Test-Path -Path "$shortcutsLogPath" -PathType Leaf
# if ($removeShortcuts -and -not $exists) {
#     Write-Warning "Cannot uninstall shortcuts.`nShortcuts log not found."
# }
# elseif ($exists) {
#     Write-Debug "Shortcuts log found."
#     # Read log line-per-line and remove files
#     $shortcutsLog = Get-Content "$shortcutsLogPath"
#     foreach ($fileInLog in $shortcutsLog) {
#         if ($null -ne $fileInLog -and '' -ne $fileInLog.Trim()) {
#             try {
#                 Write-Debug "Removing shortcut '$fileInLog'."
#                 Remove-Item -Path "$fileInLog" -Force
#                 Write-Debug "Removed shortcut '$fileInLog'."
#             }
#             catch {
#                 Write-Warning "Could not remove shortcut '$fileInLog'.`n$_"
#             }
#         }
#     }
# }

## OTHER HELPER FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
