# Violet Perfectionist Helpers

**Violet Perfectionist Helpers** currently one has two helpers, the main one being Invoke-EmptyDirectoryRemoval. The other one, Remove-EmptyDirectories, is meant to be used by the main one, but can be used alone.

Helpers for installing and uninstalling shortcuts might soon be added.

## Helper functions

### Invoke-EmptyDirectoryRemoval

#### Description

This helper removes empty directories recursively in the specified directory, and then removes the directory itself if it is empty.

If the directory is not empty, the following warning will be shown:

```text
Data remains in the &gt;name&lt; directory.
Manually remove the &gt;name&lt; directory if you do not wish to keep the data.
&gt;Name&lt; directory: '&gt;Path&lt;'"
```

#### Syntax

```powershell
Invoke-EmptyDirectoryRemoval
    [-Path] &gt;String[]&lt; [-Name &gt;String[]&lt;]
```

#### Examples

##### Example 1: Remove installation directory if it has no files

```powershell
Invoke-EmptyDirectoryRemoval "C:\Program Files (x86)\Example Program" "installation"
```

The `Name` parameter is only used for output messages. For example, the above code might result in the following warning:

```text
Data remains in the installation directory.
Manually remove the installation directory if you do not wish to keep the data.
Installation directory: 'C:\Program Files (x86)\Example Program'"
```

##### Example 2: Remove application data directory if it has no files

```powershell
Invoke-EmptyDirectoryRemoval "$Env:AppData\example_program" "application data"
```

#### Parameters

```powershell
-Path
```

Specifies the directory to process.

| Type:                      | String[] |
| Position                   | 0        |
| Default value              | None     |
| Required                   | True     |
| Accept pipeline input      | Unknown  |
| Accept wildcard characters | Unknown  |

```powershell
-Name
```

Specifies what to the directory will be referred to in output messages.

If left out, the messages will simply say `directory`, rather than `&gt;name&lt; directory`.

| Type:                      | String[] |
| Position                   | 1        |
| Default value              | None     |
| Required                   | False    |
| Accept pipeline input      | Unknown  |
| Accept wildcard characters | Unknown  |
