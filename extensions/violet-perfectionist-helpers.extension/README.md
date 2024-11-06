**Violet Perfectionist Helpers** is a Chocolatey extension that adds a few helper functions.

### Helper functions

The following helpers are currently included:

- Invoke-ChocoShortcutInstallation
- Invoke-ChocoShortcutUninstallation
- Invoke-EmptyDirectoryRemoval
- Remove-EmptyDirectories (meant to be used by Invoke-EmptyDirectoryRemoval, but can be used alone)

#### Invoke-ChocoShortcutInstallation

##### Description

This helper Installs a shortcut with Install-ChocolateyShortcut and logs the shortcut path to a file (by default in the package directory). Every subsequent shortcut created (within the same chocolateyInstall script) will be appended to the same log file. That log file can then be used by [Invoke-ChocoShortcutUninstallation](https://community.chocolatey.org/packages/violet-perfectionist-helpers.extension/#Invoke-ChocoShortcutUninstallation) to uninstall all shortcuts for that package.

It allows for all the same parameters as Install-ChocolateyShortcut.

##### Syntax

```powershell
Install-ChocolateyShortcut
    [-ShortcutFilePath] <String>;
    [-TargetPath] <String>;
    [-WorkingDirectory] <String>;
    [-Arguments] <String>;
    [-IconLocation] <String>;
    [-Description] <String>;
    [-WindowStyle] <String>;
    [-RunAsAdmin] <SwitchParameter>;
    [-PinToTaskbar] <SwitchParameter>;
    [-LogPath] <String>;
```

```powershell
Install-ChocolateyShortcut
    [-Desktop] <String>;
    [-TargetPath] <String>;
    [-WorkingDirectory] <String>;
    [-Arguments] <String>;
    [-IconLocation] <String>;
    [-Description] <String>;
    [-WindowStyle] <String>;
    [-RunAsAdmin] <SwitchParameter>;
    [-PinToTaskbar] <SwitchParameter>;
    [-LogPath] <String>;
```

```powershell
Install-ChocolateyShortcut
    [-StartMenu] <String>;
    [-TargetPath] <String>;
    [-WorkingDirectory] <String>;
    [-Arguments] <String>;
    [-IconLocation] <String>;
    [-Description] <String>;
    [-WindowStyle] <String>;
    [-RunAsAdmin] <SwitchParameter>;
    [-PinToTaskbar] <SwitchParameter>;
    [-LogPath] <String>;
    [-Users] <String>;
```

##### Examples

###### Example 1: Add shortcut to the desktop

```powershell
Install-ChocolateyShortcut -Desktop "Text Editors\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"
```

###### Example 2: Add Start Menu shortcut

```powershell
Install-ChocolateyShortcut -StartMenu "Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"
```

When the `Users` parameter is omitted, who the shortcut will be available to will be automatically decided based on elevation status.
If the process is elevated, a shortcut will be created for everyone, otherwise a shortcut for the current user only will be created.

Who the shortcut will be available to is based on where it is installed. See example 3 and 4.

```powershell
Install-ChocolateyShortcut -Desktop "Text Editors\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"
```

###### Example 3: Add Start Menu shortcut available to all users (requires administrative shell)

```powershell
Install-ChocolateyShortcut -StartMenu "Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe" -Users All
```

This will place the shortcut in `$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\`.

###### Example 4: Add Start Menu shortcut available to current user

```powershell
Install-ChocolateyShortcut -StartMenu "Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe" -Users Current
```

This will place the shortcut in `$Env:AppData\Microsoft\Windows\Start Menu\Programs\`.

###### Example 5: Add shortcut with specific properties at a custom path, and log to a custom path

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

##### Parameters

```powershell
-ShortcutFilePath
```

Specifies the path where the shortcut will be saved.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Desktop
```

(Alternative to ShortcutFilePath) Specifies the path relative to the desktop where the shortcut will be saved.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Desktop
```

(Alternative to ShortcutFilePath) Specifies the path relative to the Start Menu where the shortcut will be saved.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-StartMenu
```

(Alternative to ShortcutFilePath) Specifies the path relative to the Start Menu where the shortcut will be saved.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-TargetPath
```

Specifies the file that the shortcut will point to.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 1       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-WorkingDirectory
```

Sets the shortcut's working directory.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 2       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Arguments
```

Sets arguments to the target program that will be used when using the shortcut.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 3       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-IconLocation
```

Sets the path to a custom icon that the shortcut will use.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 4       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Description
```

Sets a description for the shortcut that appears when hovering over the shortcut.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 5       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-WindowStyle
```

Sets the window type for the target application.

0 = Hidden, 1 = Normal Size, 3 = Maximized, 7 - Minimized.

Full list table 3.9 here: https://technet.microsoft.com/en-us/library/ee156605.aspx

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | Int     |
| Position                   | 6       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-LogPath
```

Specifies the path to where the shortcut log will be created or appended to.

| Property                   | Value   |
| -------------------------- | ---------------------------------------------- |
| Type:                      | String                                         |
| Position                   | 7                                              |
| Default value              | `"$Env:chocolateyPackageFolder\shortcuts.txt"` |
| Required                   | False                                          |
| Accept pipeline input      | Unknown                                        |
| Accept wildcard characters | Unknown                                        |

```powershell
-Users
```

OPTIONAL - When the StartMenu parameter is used, the Users parameter specifies whether to
  a. install the shortcut for all users,
  b. install the shortcut for the current user only, or
  c. install the shortcut for all users if the process elevated, and otherwise
       install it for the current user only

All = All users
Current = Current user
Auto = Decide automatically based on elevation (default)

`All` will place the shortcut in `$Env:AppData\Microsoft\Windows\Start Menu\Programs\`.
`Current` will place the shortcut in `$Env:AppData\Microsoft\Windows\Start Menu\Programs\`.

`User` is an alias for `Users`.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 8       |
| Default value              | Auto    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-RunAsAdmin
```

Specifies that the shortcut should run as administrator.

| Property                   | Value            |
| -------------------------- | ---------------- |
| Type:                      | SwitchParameter  |
| Position                   | Named            |
| Default value              | None             |
| Required                   | False            |
| Accept pipeline input      | Unknown          |
| Accept wildcard characters | Unknown          |

```powershell
-PinToTaskbar
```

Pins the shortcut to the taskbar.


| Property                   | Value            |
| -------------------------- | ---------------- |
| Type:                      | SwitchParameter  |
| Position                   | Named            |
| Default value              | None             |
| Required                   | False            |
| Accept pipeline input      | Unknown          |
| Accept wildcard characters | Unknown          |

#### Invoke-ChocoShortcutUninstallation

##### Description

Removes shortcut listed in a log created by Invoke-ChocoShortcutUninstallation.

##### Syntax

```powershell
Invoke-EmptyDirectoryRemoval
    [-Path] <String>;
```

##### Examples

##### Example 1: Uninstall shortcuts

```powershell
Invoke-ChocoShortcutUninstallation
```

##### Example 2: Uninstall shortcuts with custom path to the log file

```powershell
Invoke-ChocoShortcutUninstallation "C:\logs\Notepad++\shortcuts.txt"
```

##### Parameters

```powershell
-Path
```

Specifies the path log is located. Only necessary if you set a custom path in Invoke-ChocoShortcutInstallation.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Name
```
Specifies what the directory will be referred to in output messages.

If left out, the messages will simply say `directory`, rather than `<name>; directory`.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 1       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

#### Invoke-EmptyDirectoryRemoval

##### Description

This helper deletes empty directories recursively in the specified directory, and then deletes the directory itself if it is empty.

If the directory is not empty, the following warning will be shown:

```text
Data remains in the <name>; directory.
Manually delete the <name>; directory if you do not wish to keep the data.
<Name>; directory: '<Path>;'"
```

Remove-EmptyDirectories is adapted from auberginehill's [remove-empty-folders](https://github.com/auberginehill/remove-empty-folders) script.

##### Syntax

```powershell
Invoke-EmptyDirectoryRemoval
    [-Path] <String>; [-Name <String>;]
```

##### Examples

###### Example 1: Delete installation directory if it has no files

`Invoke-EmptyDirectoryRemoval "C:\Program Files (x86)\Example Program" "installation"`

The `Name` parameter is only used for output messages. For example, the above code might result in the following warning:

```text
Data remains in the installation directory.
Manually delete the installation directory if you do not wish to keep the data.
Installation directory: 'C:\Program Files (x86)\Example Program'"
```

###### Example 2: Delete application data directory if it has no files

```powershell
Invoke-EmptyDirectoryRemoval "$Env:AppData\example_program" "application data"
```

##### Parameters

```powershell
-Path
```

Specifies the directory to process.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 0       |
| Default value              | None    |
| Required                   | True    |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |

```powershell
-Name
```
Specifies what the directory will be referred to in output messages.

If left out, the messages will simply say `directory`, rather than `<name>; directory`.

| Property                   | Value   |
| -------------------------- | ------- |
| Type:                      | String  |
| Position                   | 1       |
| Default value              | None    |
| Required                   | False   |
| Accept pipeline input      | Unknown |
| Accept wildcard characters | Unknown |
