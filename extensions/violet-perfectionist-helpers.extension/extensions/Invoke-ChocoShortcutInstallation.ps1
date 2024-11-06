enum VioletUsers {
  Auto
  All
  Current
}

function Invoke-ChocoShortcutInstallation {
  <#
.SYNOPSIS
Create shortcut and log it for easy removal with Invoke-ChocoShortcutUninstallation. 

.NOTES
None

.INPUTS
None

.OUTPUTS
None

.PARAMETER ShortcutFilePath
Specifies the path where the shortcut will be saved.

.PARAMETER Desktop
(Alternative to ShortcutFilePath) Specifies the path relative to the desktop where the shortcut will be saved.

.PARAMETER StartMenu
(Alternative to ShortcutFilePath) Specifies the path relative to the Start Menu where the shortcut will be saved.

.PARAMETER TargetPath
Specifies the file that the shortcut will point to.

.PARAMETER WorkingDirectory
OPTIONAL - Sets the shortcut's working directory.

.PARAMETER Arguments
OPTIONAL - Sets arguments to the target program that will be used when using the shortcut.

.PARAMETER IconLocation
OPTIONAL - Sets the path to a custom icon that the shortcut will use.

.PARAMETER Description
OPTIONAL - Sets a description for the shortcut that appears when hovering over the shortcut.

.PARAMETER WindowStyle
OPTIONAL - Sets the window type for the target application.

0 = Hidden, 1 = Normal Size, 3 = Maximized, 7 - Minimized.

Full list table 3.9 here: https://technet.microsoft.com/en-us/library/ee156605.aspx

.PARAMETER RunAsAdmin
OPTIONAL - Specifies that the shortcut should run as administrator.

.PARAMETER PinToTaskbar
OPTIONAL - Pins the shortcut to the taskbar.

.PARAMETER LogPath
OPTIONAL - Specifies the path to where the shortcut log will be created or appended to.

.PARAMETER Users
OPTIONAL - When the StartMenu parameter is used, the Users parameter specifies whether to
  a. install the shortcut for all users,
  b. install the shortcut for the current user only, or
  c. install the shortcut for all users if the process elevated, and otherwise
       install it for the current user only

All = All users
Current = Current user
Auto = Decide automatically based on elevation (default)

.PARAMETER IgnoredArguments
Handles superflous splatted arguments. Do not use directly.

.EXAMPLE
Install-ChocolateyShortcut -Desktop "Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"

.EXAMPLE
Install-ChocolateyShortcut -StartMenu "Text Editors\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"

.EXAMPLE
Install-ChocolateyShortcut -StartMenu "Text Editors\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe" -Users All

.EXAMPLE
Install-ChocolateyShortcut -StartMenu "Text Editors\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe" -Users All

.EXAMPLE
Install-ChocolateyShortcut -ShortcutFilePath "C:\Program Files\Notepad++\notepad++.exe" `
  -TargetPath "C:\Notepad++" `
  -WorkingDirectory "C:\" `
  -Arguments "C:\Notes.txt" `
  -IconLocation "$Env:UserProfile\My Icons\Notepad++.ico" `
  -Description "Open Notes.txt with Notepad++"
  -WindowStyle 3 `
  -RunAsAdmin `
  -PinToTaskbar
  -LogPath "C:\Logs\Notepad++\shortcuts.txt"

.LINK
Install-ChocolateyShortcut

#>
  param(
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ManualPath')][string] $ShortcutFilePath,
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Desktop')][string] $Desktop,
    [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'StartMenu')][string] $StartMenu,
    [parameter(Mandatory = $true, Position = 1)][string] $TargetPath,
    [parameter(Mandatory = $false, Position = 2)][string] $WorkingDirectory,
    [parameter(Mandatory = $false, Position = 3)][string] $Arguments,
    [parameter(Mandatory = $false, Position = 4)][string] $IconLocation,
    [parameter(Mandatory = $false, Position = 5)][string] $Description,
    [parameter(Mandatory = $false, Position = 6)][int] $WindowStyle,
    [parameter(Mandatory = $false, Position = 7)][string] $LogPath = $(Join-Path "$Env:chocolateyPackageFolder" -ChildPath "shortcuts.txt"),
    [Alias("User")][parameter(Mandatory = $false, Position = 8)][VioletUsers] $Users = [VioletUsers]::Auto,
    [parameter(Mandatory = $false)][switch] $RunAsAdmin,
    [parameter(Mandatory = $false)][switch] $PinToTaskbar,
    [parameter(ValueFromRemainingArguments = $true)][Object[]]$IgnoredArguments
  )
  
  # Add shortcut
  # Paths
  if ($Desktop -ne "" -and $null -ne $Desktop) {
    # If Desktop parameter is used
    $desktopPath = Join-Path $Env:UserProfile -ChildPath "Desktop"
    $ShortcutFilePath = Join-Path $desktopPath -ChildPath $Desktop
  } elseif ($StartMenu -ne "" -and $null -ne $StartMenu) {
    # If StartMenu parameter is used
    if ($Users -eq [VioletUsers]::All) {
      # Make shortcut available to all users
      $startMenuPath = Convert-Path "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\"
    } elseif ($Users -eq [VioletUsers]::Current) {
      # Make shortcut available to current user only
      $startMenuPath = Convert-Path "$Env:AppData\Microsoft\Windows\Start Menu\Programs\"
    } elseif ($Users -eq [VioletUsers]::Auto) {
      $isElevated = Test-ProcessAdminRights
      if ($isElevated) {
        # Make shortcut available to all users
        $startMenuPath = Convert-Path "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\"
      } else {
        # Make shortcut available to current user only
        $startMenuPath = Convert-Path "$Env:AppData\Microsoft\Windows\Start Menu\Programs\"
      }
    }
    $ShortcutFilePath = Join-Path "$startMenuPath" -ChildPath $StartMenu
  }
    # Arguments
    $desktopShortcutArgs = @{
      shortcutFilePath = "$ShortcutFilePath"
      targetPath       = "$TargetPath"
      workingDirectory = "$WorkingDirectory"
      arguments        = "$Arguments"
      iconLocation     = "$IconLocation"
      description      = "$Description"
    }
    Install-ChocolateyShortcut @desktopShortcutArgs
    # Log
    Write-Verbose "Logging shortcut path..."
    "$ShortcutFilePath" | Out-File "$LogPath" -Append
    Write-Debug "Shortcut path logged."
  }

New-Alias -Name Invoke-ChocoShortcutInstall -Value Invoke-ChocoShortcutInstallation
